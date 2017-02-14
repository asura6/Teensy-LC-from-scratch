/* Linkfile for a AKL26Z64VFT4
 * Robin Isaksson 2016 */ 

/* MEMORY STRUCTURE
 *  Program flash:   64 KB: 0x0000_0000 -> 0x0000_FFFF 
 *  SRAM:             8 KB:
 *              VALID: Ranges
 *              SRAM_L: 0x1FFF_F830 to 0x1FFF_FFFF
 *              SRAM_U: 0x2000_0000 to 0x2000_176F
 *
 *              SRAM_L should be used for data as it is mapped to
 *              the CODE bus and can access memory in one clock
 *              cycle whereas SRAM is connected to the system bus
 *              where instruction access are delayed on clock cycle.  
 */

MEMORY { 
    FLASH :      ORIGIN = 0x00000000, LENGTH = 64K
    /* We make SRAM_L and SRAM_H contiguous. If this is unwanted then it can be
     * modified by separating them and using SRAM_L for fast-read data and
     * SRAM_U for stack and heap. */
    /*SRAM_L :     ORIGIN = 0x1FFFF830, LENGTH = 2K */
    SRAM_L :     ORIGIN = 0x1FFFF830, LENGTH = 8K /* Contiguous memory block */

} 

SECTIONS {
    STACK_TOP = 0x20001770;
    . = 0x00000000;

   .text : {
       KEEP ( * (vectors) );
       . = 0x400; /* Save space for complete vector table */
       KEEP ( * (flashcfg) );
       * (.text); 
    } > FLASH

    .rodata : {
        * (.rodata);
    } > FLASH 
    FLASH_DATA_START = .; /*Where we will load from flash when writing to SRAM */ 

    /* Now we'll configure where we will keep our data outside off flash */ 
    . = 0x1FFFF830;
    SRAM_DATA_START = .; 

    .data : AT (FLASH_DATA_START) {
        * (.data);
    } > SRAM_L
    SRAM_DATA_END = .;
    SRAM_DATA_SIZE = SRAM_DATA_END - SRAM_DATA_START;

    BSS_START = .;
    .bss : {
        * (.bss);
        * (COMMON);
    } > SRAM_L
    BSS_END = .;
    BSS_SIZE = BSS_END - BSS_START; 
} 
