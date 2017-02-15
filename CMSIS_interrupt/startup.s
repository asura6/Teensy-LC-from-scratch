/* Startup code for a AKL26Z64VFT4
 * Robin Isaksson 2017
 */ 
.syntax unified
.arch armv6-m 
.thumb 

/* Initial vector table */
        .section "vectors" 
    .long    STACK_TOP             /* Top of Stack */
    .long    _reset_Handler        /* Reset Handler */
    .long    NMI_Handler           /* NMI Handler */
    .long    HardFault_Handler     /* Hard Fault Handler */
    .long    0                     /* Reserved */
    .long    0                     /* Reserved */
    .long    0                     /* Reserved */
    .long    0                     /* Reserved */
    .long    0                     /* Reserved */
    .long    0                     /* Reserved */
    .long    0                     /* Reserved */
    .long    SVC_Handler           /* SVCall Handler */
    .long    0                     /* Reserved */
    .long    0                     /* Reserved */
    .long    PendSV_Handler        /* PendSV Handler */
    .long    SysTick_Handler       /* SysTick Handler */

    /* External interrupts */
    .long   DMA0_IRQHandler         /* DMA channel 0 transfer complete interrupt */
    .long   DMA1_IRQHandler         /* DMA channel 1 transfer complete interrupt */
    .long   DMA2_IRQHandler         /* DMA channel 2 transfer complete interrupt */
    .long   DMA3_IRQHandler         /* DMA channel 3 transfer complete interrupt */
    .long   Default_Handler         /* Reserved interrupt 20 */
    .long   FTFA_IRQHandler         /* FTFA interrupt */
    .long   LVD_LVW_IRQHandler      /* Low Voltage Detect, Low Voltage Warning */
    .long   LLW_IRQHandler          /* Low Leakage Wakeup */
    .long   I2C0_IRQHandler         /* I2C0 interrupt */
    .long   I2C1_IRQHandler         /* I2C0 interrupt 25 */
    .long   SPI0_IRQHandler         /* SPI0 interrupt */
    .long   SPI1_IRQHandler         /* SPI1 interrupt */
    .long   UART0_IRQHandler        /* UART0 status/error interrupt */
    .long   UART1_IRQHandler        /* UART1 status/error interrupt */
    .long   UART2_IRQHandler        /* UART2 status/error interrupt */
    .long   ADC0_IRQHandler         /* ADC0 interrupt */
    .long   CMP0_IRQHandler         /* CMP0 interrupt */
    .long   TPM0_IRQHandler         /* TPM0 fault, overflow and channels interrupt */
    .long   TPM1_IRQHandler         /* TPM1 fault, overflow and channels interrupt */
    .long   TPM2_IRQHandler         /* TPM2 fault, overflow and channels interrupt */
    .long   RTC_IRQHandler          /* RTC interrupt */
    .long   RTC_Seconds_IRQHandler  /* RTC seconds interrupt */
    .long   PIT_IRQHandler          /* PIT timer interrupt */
    .long   I2S0_IRQHandler         /* I2S0 transmit interrupt */
    .long   USB0_IRQHandler         /* USB0 interrupt */
    .long   DAC0_IRQHandler         /* DAC interrupt */
    .long   TSI0_IRQHandler         /* TSI0 interrupt */
    .long   MCG_IRQHandler          /* MCG interrupt */
    .long   LPTimer_IRQHandler      /* LPTimer interrupt */
    .long   Default_Handler         /* Reserved interrupt 45 */
    .long   PORTA_IRQHandler        /* Port A interrupt */
    .long   PORTC_IRQHandler        /* Port C interrupt */


/* These bytes are used for configuring security (p443) */
        .section "flash_config_field","a",%progbits
.long   0xFFFFFFFF
.long   0xFFFFFFFF
.long   0xFFFFFFFF
.long   0xFFFFFFFE

/* Startup code */
.text
.thumb_func
_reset_Handler: 
        /* The watchdog timer is a protection-feature that resets the device if
         * it is not manually reset. We turn it off */
        @@ Turn off watchdog
        ldr     r0, =0x40048100 @@SIM_COPC = 4004_8100 (p232)
        movs    r1, #0
        str     r1, [r0] 

        /* Copy data from flash to RAM */
_startup: 
        @@ Copy data to RAM 
        ldr     r0, =FLASH_DATA_START
        ldr     r1, =SRAM_DATA_START
        ldr     r2, =SRAM_DATA_SIZE 
        @@ If data is zero then do not copy 
        cmp     r2, #0 
        beq     _BSS_init 
        /* Initialize data by loading it to SRAM_L */
        ldr     r3, =0 @@ i = 0 
_RAM_copy: 
        ldr    r4, [r0, r3] @@ r4 = FLASH_DATA_START[i] 
        str    r4, [r1, r3] @@ SRAM_DATA_START[i] = r4 
        adds    r3, #4       @@ i++ 
        cmp     r3, r2       @@ if i < SRAM_DATA_SIZE then branch 
        blt     _RAM_copy    @@ otherwise loop again 

        /* Initialize uninitialized variables to zero (required for C) */
_BSS_init: 
        ldr     r0, =BSS_START 
        ldr     r1, =BSS_END
        ldr     r2, =BSS_SIZE 
        /* If BSS size is zero then do not initialize */
        cmp     r2, #0
        beq     _end_of_init
        /* Initialize BSS variables to zero */
        ldr     r3, =0x0 @@ i = 0 
        ldr     r4, =0x0 @@ r4 = 0 
_BSS_zero: 
        str     r4, [r0, r3] @@ BSS_START[i] = 0
        adds    r3, #4       @@ i++
        cmp     r3, r2       @@ if i < BSS_SIZE then branch
        blt     _BSS_zero        @@ otherwise loop again 

        /* Here control is given to the C-main function. Take note that
         * no heap is initialized. */
_end_of_init:   bl   main 
_halt:  b       _halt 

/* Here are all the interrupt vectors. The macro below define each and every
 * one of the ones listed beolw as a weak symbol which can be overwritten by
 * including the corresponding function-name in a C-file (for example) */
.macro                 def_rewritable_handler   handler 
    .thumb_func
    .weak    \handler
    .type    \handler, %function
    \handler:   b  . @@ Branch forever in default state
.endm
       
def_rewritable_handler  NMI_Handler             /* NMI HANDLER */
def_rewritable_handler  HardFault_Handler       /* HARD FAULT Handler */
def_rewritable_handler  SVC_Handler             /* SVCALL Handler */
def_rewritable_handler  PendSV_Handler          /* PENDSV Handler */
def_rewritable_handler  SysTick_Handler         /* SYSTICK Handler */ 
def_rewritable_handler  DMA0_IRQHandler         /* DMA CHANNEL 0 TRANSFER COMPLETE INTERRUPT */
def_rewritable_handler  DMA1_IRQHandler         /* DMA CHANNEL 1 TRANSFER COMPLETE INTERRUPT */
def_rewritable_handler  DMA2_IRQHandler         /* DMA CHANNEL 2 TRANSFER COMPLETE INTERRUPT */
def_rewritable_handler  DMA3_IRQHandler         /* DMA CHANNEL 3 TRANSFER COMPLETE INTERRUPT */ 
def_rewritable_handler  Default_Handler         /* Reserved interrupt 20 */ 
def_rewritable_handler  FTFA_IRQHandler         /* FTFA INTERRUPT */
def_rewritable_handler  LVD_LVW_IRQHandler      /* LOW VOLTAGE DETECT, LOW VOLTAGE WARNING */
def_rewritable_handler  LLW_IRQHandler          /* LOW LEAKAGE WAKEUP */
def_rewritable_handler  I2C0_IRQHandler         /* I2C0 INTERRUPT */
def_rewritable_handler  I2C1_IRQHandler         /* I2C0 INTERRUPT 25 */
def_rewritable_handler  SPI0_IRQHandler         /* SPI0 INTERRUPT */
def_rewritable_handler  SPI1_IRQHandler         /* SPI1 INTERRUPT */
def_rewritable_handler  UART0_IRQHandler        /* UART0 STATUS/ERROR INTERRUPT */
def_rewritable_handler  UART1_IRQHandler        /* UART1 STATUS/ERROR INTERRUPT */
def_rewritable_handler  UART2_IRQHandler        /* UART2 STATUS/ERROR INTERRUPT */
def_rewritable_handler  ADC0_IRQHandler         /* ADC0 interrupt */ 
def_rewritable_handler  CMP0_IRQHandler         /* CMP0 INTERRUPT */
def_rewritable_handler  TPM0_IRQHandler         /* TPM0 FAULT, OVERFLOW AND CHANNELS INTERRUPT */
def_rewritable_handler  TPM1_IRQHandler         /* TPM1 FAULT, OVERFLOW AND CHANNELS INTERRUPT */
def_rewritable_handler  TPM2_IRQHandler         /* TPM2 FAULT, OVERFLOW AND CHANNELS INTERRUPT */
def_rewritable_handler  RTC_IRQHandler          /* RTC INTERRUPT */
def_rewritable_handler  RTC_Seconds_IRQHandler  /* RTC SECONDS INTERRUPT */
def_rewritable_handler  PIT_IRQHandler          /* PIT TIMER INTERRUPT */
def_rewritable_handler  I2S0_IRQHandler         /* I2S0 TRANSMIT INTERRUPT */
def_rewritable_handler  USB0_IRQHandler         /* USB0 INTERRUPT */
def_rewritable_handler  DAC0_IRQHandler         /* DAC INTERRUPT */
def_rewritable_handler  TSI0_IRQHandler         /* TSI0 INTERRUPT */
def_rewritable_handler  MCG_IRQHandler          /* MCG INTERRUPT */
def_rewritable_handler  LPTimer_IRQHandler      /* LPTIMER INTERRUPT */ 
def_rewritable_handler  PORTA_IRQHandler        /* PORT A INTERRUPT */
def_rewritable_handler  PORTC_IRQHandler        /* PORT C INTERRUPT */ 
        .end 
