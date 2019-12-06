// Main.c - makes LEDG0 on DE2-115 board blink if NIOS II is set up correctly
// for ECE 385 - University of Illinois - Electrical and Computer Engineering
// Author: Zuofu Cheng
#include <stdio.h>
int main()
{
	int i = 0;
	volatile unsigned int *LED_PIO = (unsigned int*)0x90; //make a pointer to access the PIO block
	volatile unsigned int *ACCU_PIO = (unsigned int*)0x80;
	volatile unsigned int *RESET_PIO = (unsigned int*)0x70;
	volatile unsigned int *SW_PIO = (unsigned int*)0x60;
	unsigned int  temp;
	*LED_PIO = 0; //clear all LEDs
//	*ACCU_PIO = 1;
//	*RESET_PIO = 1;
//	*SW_PIO = 0;
//	int flag = 0;
	while ( (1+1) != 3) //infinite loop
	{
//		for (i = 0; i < 100000; i++); //software delay
//		*LED_PIO |= 0x1; //set LSB
//		for (i = 0; i < 100000; i++); //software delay
//		*LED_PIO &= ~0x1; //clear LSB
		temp = *LED_PIO;
		if(*RESET_PIO == 0)
		{
			*LED_PIO = 0;
			continue;
		}
		else if(*ACCU_PIO == 0)
		{
			printf("output is %u", *LED_PIO);
			temp += *SW_PIO;
			if(temp >= 256)
				*LED_PIO = temp - 256;
			else
				*LED_PIO = temp;
			while(*ACCU_PIO == 0) //prevent constant writing
			{
				i = 0;
			}
		}
	}
	return 1; //never gets here
}
