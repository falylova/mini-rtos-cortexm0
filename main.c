#include "scheduler.h"

extern void Task1(void);
extern void Task2(void);
extern void Task3(void);

int main(void)
{
    Scheduler_Init();

    Task_Create(Task1, 0);
    Task_Create(Task2, 1);
    Task_Create(Task3, 2);

    Scheduler_Start();
}
