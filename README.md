# Teensy-LC-from-scratch
Bare-metal programming of the Teensy-LC. 

You can find a simple program which sets up the Teensy-LC to be programmed in C
with minimal configuration. A sample which blinks the built-in LED is included.

If you want a more functional environment you can look at the example which
include most of the CMSIS functionality. There the sample includes a program
with a 48 MHz system clock put in place which blinks the built-in LED once every
second using interrupts from the low power timer.

The makefile might have to be modified in a non-Linux environment.

If teensy_loader_cli is installed then the program can be build and flashed to
the Teensy-LC by executing "make flash".
