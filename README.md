# Teensy-LC-from-scratch
Bare-metal programming of the Teensy-LC. A basic skeleton is put in place such
that a C environment is available.

This is a simple foundation for progamming the Teensy-LC without the Arduino
environment. All that is included is a simple assembler program which sets up
the Teensy-LC such that a main function can be programmed in C as well as a
pre-programmed main function which blinks the Teensy-LC LED.

The makefile might have to be modified in a non-Linux environment.

If teensy_loader_cli is installed then the program can be build and flashed to
the Teensy-LC by executing "make flash".
