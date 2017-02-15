# The output- and intermediary files will be named $(TARGET) 
TARGET = interrupt_driven_led_blinker

TOOLCHAIN = arm-none-eabi
CC = $(TOOLCHAIN)-gcc
AS = $(TOOLCHAIN)-as
LD = $(TOOLCHAIN)-ld
OCP = $(TOOLCHAIN)-objcopy

LDSCRIPT = $(wildcard *.ld)
SRCS = $(wildcard *.s)
SRCC = $(wildcard *.c)
OBJS = $(SRCS:.s=.o)
OBJS +=$(SRCC:.c=.o)

CFLAGS = -Wall -Wextra -mcpu=cortex-m0plus -mthumb -c -nostdlib -mlong-calls -Ilib
AFLAGS = -g -mcpu=cortex-m0plus -mthumb
LDFLAGS = -g -T $(LDSCRIPT) 
OCPFLAGS_HEX = -O ihex

default: $(TARGET).hex

%.o: %.s	
	$(AS) $(AFLAGS) $< -o $@

%.o: %.c	
	$(CC) $(CFLAGS) $< -o $@ 

$(TARGET).elf: $(OBJS) $(LDSCRIPT)
	$(LD) $(LDFLAGS) $(OBJS) -o $@

$(TARGET).hex: $(TARGET).elf
	$(OCP) $(OCPFLAGS_HEX) $< $@

clean:
	rm -f ./*.o ./*.elf ./*.bin ./*.syms ./*.hex

symbols: $(TARGET).elf
	$(TOOLCHAIN)-nm -n $<

flash:	$(TARGET).hex
	teensy_loader_cli -w --mcu=mkl26z64 $(TARGET).hex
