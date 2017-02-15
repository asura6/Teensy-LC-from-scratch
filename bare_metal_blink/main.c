#include <stdint.h>
/* These are the adresses for the registers we need to access in order to
 * control the Teensy built-in LED. You can search these variable names in the
 * manual to find information pertaining to them. */
uint32_t *SIM_SCGC5  = (uint32_t *)0x40048038;
uint32_t *PORTC_PCR5 = (uint32_t *)0x4004B014;
uint32_t *GPIOC_PDDR = (uint32_t *)0x400FF094;
uint32_t *GPIOC_PDOR = (uint32_t *)0x400FF080;

void delay(void);

int main (void) { 
    *SIM_SCGC5 = 0x3F82;  /* Initialize clock for Port A to Port E */
    *PORTC_PCR5 = 0x0143; /* Change pin C5 to GPIO mode */
    *GPIOC_PDDR = 0x20;   /* Enable pin C5 as an output */

    while (1) { 
        *GPIOC_PDOR = 0x20; /* Make pin C5 logic high */
        delay(); /* Wait unspecified time */
        *GPIOC_PDOR = 0x00; /* Make pin c5 logic low */
        delay(); 
    }
    return 0; /* Give control back to the assembler program "startup.s"
                 This program continues by branching to the _halt address where
                 it loops indefinitely */
}

/* A very primitive delay function. This is just for illustration and should not
 * be used for time-critical applications. Use the built-in timers!*/
void delay (void) {
    uint16_t i;
    uint8_t j; 
    for (i = 0; i < 0xFFF; i++) {
        for (j = 0; j < 0xFF; j++) {
        }
    } 
}
