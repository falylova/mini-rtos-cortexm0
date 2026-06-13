#ifndef SCHEDULER_H
#define SCHEDULER_H

#include <stdint.h>

#define MAX_TASKS   3
#define STACK_SIZE  128

typedef struct
{
    uint32_t *sp;
    uint32_t  stack[STACK_SIZE];
} TCB;

extern TCB     tcb[MAX_TASKS];
extern uint8_t currentTask;
extern uint8_t nextTask;

void Scheduler_Init  (void);
void Task_Create     (void (*task)(void), uint8_t id);
void Scheduler_Start (void);

#endif
