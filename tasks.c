#include <stdint.h>

volatile uint32_t c1 = 0;
volatile uint32_t c2 = 0;
volatile uint32_t c3 = 1;

volatile uint8_t active_task_id = 0;

void Task1(void)
{
    while (1)
    {
        active_task_id = 1;

        c1++;
				if (c1 > 10)
				c1=0;

    }
}

void Task2(void)
{
    while (1)
    {
        active_task_id = 2;

        c2 += 2;
        if (c2 > 20)
            c2 = 0;
    }
}

void Task3(void)
{
    while (1)
    {
        active_task_id = 3;

        c3 += 2;
        if (c3 > 21)
            c3 = 1;
    }
}
