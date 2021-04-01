# SC407-I2C-example
This program is written for Turbo Pascal 3 for CP/M. It is a simple and rudimentary implementation of an I2C bus master driver, using bit-banging to the I2C port.
The slave device is an SC407 digital I/O board. Check https://smallcomputercentral.wordpress.com/ for more info on the boards.

# Environments
The driver program runs on the SC140 as well as the SC126 main board. The SC126 contains an I2C port on the main board; the SC140 works with an SC144 I2C bus master and RTC board.
Both setups were tested with an SC407 board which is an I2C slave device with digital I/O through buttons and LEDs.

# Usage
Load the .PAS-file into Turbo Pascal and just run it.

The test program starts by reading the buttons 8 times, which is just enough to test press all buttons. Hold down one button on the SC407 and then press ENTER. Repeat.
After the test reads the program writes a counter 0..255 to the LEDs. It is fast, so you mostly see flicker. You can modify the program and insert a small delay in the counter loop.

There is no real error handling, the ACK/NACK response is read but not used.

# Speed
The program was measured using a simple USB logic analyzer and PulseView. The timing diagrams indicate that the speed is approximately 10 KHz.
If you want higher performance you should probably implement the driver in Z80/Z180 assembler. Also, some optimization to the Pascal code is possible, but
the structure right now is a more readable program, easier to learn from and understand the details of I2C.
