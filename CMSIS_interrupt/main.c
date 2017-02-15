/* Interrupt-driven LED blinker for AKL26Z64VFT4
 * Robin Isaksson 2017
 */
#include <MKL26Z4.h> 

void clock_init(void); 
void LPTimer_Config(void); 

int main(void) {
    clock_init(); //Initialie the oscillators
    SIM->SCGC5 |= SIM_SCGC5_PORTC_MASK; //Enable clock signal for the LED
    PORTC->PCR[5] = PORT_PCR_MUX(1U); //Make the LED pin GPIO
    PTC->PDDR = (1U<<5U); //LED pin as output 
    LPTimer_Config(); //Configure the low power timer 

    while(1){ 
        __WFI(); //Wait for instruction hint
    };
}

/**
 * @brief Configure the Low Power (LP) Timer
 */
void LPTimer_Config(void) {
    SIM->SCGC5 |= SIM_SCGC5_LPTMR_MASK; //Enable clock signal to the LPTMR
    LPTMR0->CSR = 0; // Disable it
    LPTMR0->PSR = LPTMR_PSR_PRESCALE(8) |LPTMR_PSR_PCS(3); //Prescalar set to 512, OSCERCLK 

    LPTMR0->CMR = 15625; //Set frequency of the interrupts
    //16 MHz / 512 / 15625 = 0.5Hz

    NVIC_ClearPendingIRQ(LPTimer_IRQn); //Clear any pending interrupt
    //Enable Timer in free running mode
    LPTMR0->CSR = LPTMR_CSR_TIE_MASK | LPTMR_CSR_TEN_MASK | LPTMR_CSR_TCF_MASK;
    //Enable the NVIC for the low power timer
    NVIC_EnableIRQ(LPTimer_IRQn); 
}

/**
 * @brief This is the interrupt handler for the timer. When the timer counter
 * reaches zero the LED is toggled.
 */
void LPTimer_IRQHandler(void) { 
    LPTMR0->CSR |= LPTMR_CSR_TCF_MASK;
    PTC->PTOR = (1U << 5U); 
}

/**
 * @brief Initializes the PLL oscillator to 96 Mhz giving the system- and core
 * clock 48 Mhz and the bus and flash clock 28 MHz.
 */
void clock_init (void) {
    uint16_t i; //Loop variable
    uint32_t temp_reg;

    /* When the microcontroller is powered up the MCG (Multipurpose Clock
     * Generator) is in FEI mode (FLL engaged internal) and we want to change
     * the clock mode to PEE (PLL Engaged External) running at 96 MHz which we'll
     * divide to 48 MHz for the core/system clock and to 24 MHz which we'll use
     * for the bus- and flash clock. We switch modes by first setting up the
     * bypassed mode for the FLL and then activating the PLL in bypassed mode and
     * then making it the reference at 96 MHz. */

    /* Enable capacitors for the crystal oscillator */ 
    OSC0->CR = OSC_CR_SC8P_MASK | OSC_CR_SC2P_MASK | OSC_CR_ERCLKEN_MASK;

    // first configure the oscillator settings in the MCG_C2 register
    // the RANGE value is determined by the external frequency. Since the RANGE 
    // parameter affects the FRDIV divide value it still needs to be set correctly even
    // if an external clock is being used  

    /* High frequency range (that includes 16 MHz), external reference clock */
    MCG->C2 = (MCG_C2_RANGE0(2) | MCG_C2_EREFS0_MASK); 

    // The FRDIV is determined by the reference clock frequency and should be set to
    // keep the FLL ref clock frequency within the correct range. For 8MHz ref this
    // needs to be a divide of 256
    // The CLKS bits must be set to b'10 to select the external reference clock
    // Clearing IREFS selects and enables the external oscillator 

    /* Select external reference clock for MCGOUTCLK, divide the external
     * reference clock by 512 (16 Mhz / 512 = 31.25 KHz which is required) */ 
    MCG->C1 = (MCG_C1_CLKS(2) | MCG_C1_FRDIV(4)); 

    /* When using an externa oscillator we should wait for the ready bits to be
     * set before proceeding with the configuration as we are not done yet */ 
    for (i = 0 ; i < 20000 ; i++) {
        /* When this bit is set to 1 the initialization cycles of the crystal
         * oscillator have completed */
        if (MCG->S & MCG_S_OSCINIT0_MASK) {break;}
    } 
    for (i = 0 ; i < 2000 ; i++) { 
        /* When this bit is cleared then the reference clock for the FLL is the
         * external oscillator */
        if (!(MCG->S & MCG_S_IREFST_MASK)) {break;} 
    } 
    for (i = 0 ; i < 2000 ; i++) { 
        /* We test to see if the clock mode status show an external reference
         * clock as the current clock mode */
        if (((MCG->S & MCG_S_CLKST_MASK) >> MCG_S_CLKST_SHIFT) == 0x2) {break;} 
    }

    /* Now we should be in FBE (FLL bypassed external mode). We make the
     * configurations to enter PBE (PLL bypassed external */ 

    /* We set the PLL external reference divider to a division factor of 4 which
     * divites our 16 MHz external clock to 4 MHz which is suitable */ 
    MCG->C5 |= MCG_C5_PRDIV0(3); 

    /* We enable the PLL and set the VDIV multiply factor to 24 */
    temp_reg = MCG->C6;
    temp_reg &= ~MCG_C6_VDIV0_MASK;
    temp_reg |= MCG_C6_PLLS_MASK | MCG_C6_VDIV0(0);
    MCG->C6 = temp_reg;

    /* We wait momentarily for these bits so we have time to fully enter PBE
     * mode */
    for (i = 0 ; i < 2000 ; i++) { 
        if (MCG->S & MCG_S_PLLST_MASK) {break;}
    } 
    for (i = 0 ; i < 4000 ; i++) {
        /* When this bit is set we have a PLL lock */
        if (MCG->S & MCG_S_LOCK0_MASK) {break;} 
    }

    /* PBE mode (PLL bypassed external) */

    /* Here we setup the necessary clock division for the core/system clock and
     * the bus- and flash clock. 96 PLL output -> 48 MHz and 24 MHz */
    SIM->CLKDIV1 = (1U << 28) | (1U << 16);

    // clear CLKS to switch CLKS mux to select the PLL as MCGCLKOUT
    /* Now we change the the Clock Source Select bits to use the output of the
     * PLL */
    MCG->C1 &= ~MCG_C1_CLKS_MASK; 
    /* We wait momentarily for the change to be reflected in the clock status */
    for (i = 0 ; i < 2000 ; i++)
    {
        /* We check that the PLL output is selected */
        if (((MCG->S & MCG_S_CLKST_MASK) >> MCG_S_CLKST_SHIFT) == 0x3) break; 
    }

    /* PEE mode */
}
