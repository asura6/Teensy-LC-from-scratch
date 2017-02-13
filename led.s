.syntax unified
.arch armv6-m
.thumb

.global _LED_loop
.thumb_func
_LED_loop: @@ Turn on and off the LED
        bl      _LED_on
        bl      _Delay
        bl      _LED_off
        bl      _Delay
        b       _LED_loop @@Never leave this loop


_Delay: @@ Wait *at least* a clock cyclea 
        nop
        mov     pc, lr @@Return to caller


_LED_on: @@ Change pin C5 to output digital high
        ldr     r0, =0x400FF080 @@ GPIOC_PDOR = 400F_F080 (p842) 
        ldr     r1, =0x20       
        str     r1, [r0] 
        mov     pc, lr @@Return to caller


_LED_off: @@ Change pin C5 to output digital low
        ldr     r0, =0x400FF080 @@ GPIOC_PDOR = 400F_F080 (p842) 
        ldr     r1, =0x00       
        str     r1, [r0] 
        mov     pc, lr @@Return to caller 
