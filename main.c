#include <stm32f10x.h>
#include <system_stm32f10x.h>

static volatile uint16_t delay_remain = 0;

static void delay_init()
{
	NVIC_InitTypeDef NVIC_InitStruct;
	NVIC_InitStruct.NVIC_IRQChannel = SysTick_IRQn;
	NVIC_InitStruct.NVIC_IRQChannelPreemptionPriority = 0; //set to highest priority
	NVIC_InitStruct.NVIC_IRQChannelSubPriority = 0;
	NVIC_InitStruct.NVIC_IRQChannelCmd = ENABLE;
	NVIC_Init(&NVIC_InitStruct);

	SystemCoreClockUpdate(); //get the current system clock frequency (Hz)

	SysTick_Config(SystemCoreClock / 1000);
}

void SysTick_Handler()
{
	if (delay_remain > 0)
		delay_remain--;
}

// CANNOT be used in interrupt handler
static void delay_ms(uint16_t ms)
{
	delay_remain = ms;
	while (delay_remain > 0);
}

static void led_init()
{
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOB, ENABLE);

	GPIO_InitTypeDef GPIO_InitStruct;
	GPIO_InitStruct.GPIO_Pin = GPIO_Pin_12;
	GPIO_InitStruct.GPIO_Mode = GPIO_Mode_Out_PP;
	GPIO_InitStruct.GPIO_Speed = GPIO_Speed_2MHz;
	GPIO_Init(GPIOB, &GPIO_InitStruct);
}

static void led_on()  { GPIO_WriteBit(GPIOB, GPIO_Pin_12, Bit_RESET); }
static void led_off() { GPIO_WriteBit(GPIOB, GPIO_Pin_12, Bit_SET); }

int main()
{
	delay_init();
	led_init();

	while (1) {
		led_on();
		delay_ms(1000);
		led_off();
		delay_ms(1000);
	}
}
