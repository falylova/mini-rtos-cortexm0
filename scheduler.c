#include "scheduler.h"
#include <stdio.h>

#define SYST_CSR  (*((volatile uint32_t*)0xE000E010))
#define SYST_RVR  (*((volatile uint32_t*)0xE000E014))
#define SYST_CVR  (*((volatile uint32_t*)0xE000E018))
#define SCB_ICSR  (*((volatile uint32_t*)0xE000ED04))

TCB     tcb[MAX_TASKS];
uint8_t currentTask = 0;
uint8_t nextTask    = 0;

volatile uint32_t task_switches = 0;

/* -------------------------------------------------- */
/*  Affichage lisible dans la console / Watch          */
/*  "Task 1", "Task 2", "Task 3"                       */
/* -------------------------------------------------- */
static const char *task_name[MAX_TASKS] =
{
    "Task 1",
    "Task 2",
    "Task 3"
};

void print_current_task(void)
{
    printf("Running : %s  |  Total switches : %lu\n",
           task_name[currentTask],
           task_switches);
}

/* -------------------------------------------------- */

void Task_Create(void (*task)(void), uint8_t id)
{
    uint32_t *top = &tcb[id].stack[STACK_SIZE - 1];

    *top-- = 0x01000000u;    /* xPSR  : Thumb bit      */
    *top-- = (uint32_t)task; /* PC    : adresse tache  */
    *top-- = 0xFFFFFFFDu;    /* LR    : EXC_RETURN     */
    *top-- = 0u;             /* R12                    */
    *top-- = 0u;             /* R3                     */
    *top-- = 0u;             /* R2                     */
    *top-- = 0u;             /* R1                     */
    *top-- = 0u;             /* R0                     */
    *top-- = 0u;             /* R11                    */
    *top-- = 0u;             /* R10                    */
    *top-- = 0u;             /* R9                     */
    *top-- = 0u;             /* R8                     */
    *top-- = 0u;             /* R7                     */
    *top-- = 0u;             /* R6                     */
    *top-- = 0u;             /* R5                     */
    *top   = 0u;             /* R4   <- SP ici         */

    tcb[id].sp = top;
}

void Scheduler_Init(void)
{
    currentTask = 0;
    nextTask    = 0;
}

extern void Start_First_Task(void);

void Scheduler_Start(void)
{
    SYST_RVR = 48000u - 1u; /* 1 ms a 48 MHz          */
    SYST_CVR = 0u;
    SYST_CSR = 7u;          /* Enable + IRQ + CPU clk */

    Start_First_Task();
}

void SysTick_Handler(void)
{
    nextTask = (currentTask + 1u) % MAX_TASKS;
    task_switches++;

    print_current_task();   /* affiche la tache qui vient de finir son slot */

    SCB_ICSR |= (1u << 28); /* declenche PendSV */
}
