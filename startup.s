/* Startup code for a AKL26Z64VFT4
 * Robin Isaksson 2017
 */

.syntax unified
.arch armv6-m 
.thumb 

/* Initial vector table */
        .section "vectors" 
.long STACK_TOP  //  Stack pointer
.long _start     //  Program counter

/* These bytes are used for configuring security (p443) */
        .section "flashcfg"
.long   0xFFFFFFFF
.long   0xFFFFFFFF
.long   0xFFFFFFFF
.long   0xFFFFFFFE

/* Startup code */
.text
.thumb_func
_start: 
        /* The watchdog timer is a protection-feature that resets the device if
         * it is not manually reset. We turn it off */
        @@ Turn off watchdog
        ldr     r0, =0x40048100 @@SIM_COPC = 4004_8100 (p232)
        movs    r1, #0
        str     r1, [r0] 
 
_startup: 
        @@ Copy data to RAM 
        ldr     r0, =FLASH_DATA_START
        ldr     r1, =SRAM_DATA_START
        ldr     r2, =SRAM_DATA_SIZE 
        @@ If data is zero then do not copy 
        cmp     r2, #0 
        beq     _BSS_init 
        @@ Initialize data by loading it to SRAM_L
        ldr     r3, =0 @@ i = 0 

_RAM_copy: 
        ldrb    r4, [r0, r3] @@ r4 = FLASH_DATA_START[i] 
        strb    r4, [r1, r3] @@ SRAM_DATA_START[i] = r4 
        adds    r3, #1       @@ i++ 
        cmp     r3, r2       @@ if i < SRAM_DATA_SIZE then branch 
        blt     _RAM_copy    @@ otherwise loop again 

_BSS_init: 
        ldr     r0, =BSS_START 
        ldr     r1, =BSS_END
        ldr     r2, =BSS_SIZE 
        @@ If BSS size is zero then do not initialize
        cmp     r2, #0
        beq     _end_of_init
        @@ Initialize BSS variables to zero 
        ldr     r3, =0x0 @@ i = 0 
        ldr     r4, =0x0 @@ r4 = 0


_zero: 
        str     r4, [r0, r3] @@ BSS_START[i] = 0
        adds    r3, #4       @@ i++
        cmp     r3, r2       @@ if i < BSS_SIZE then branch
        blt     _zero        @@ otherwise loop again 

                /* Here control is given to the C-main function. Take note that
                 * no heap is initialized. */
_end_of_init:   bl   main

_halt:  b       _halt
        .end 
