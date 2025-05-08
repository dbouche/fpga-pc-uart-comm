# fpga-pc-uart-comm

## Project
The purpose of this project is to communicate an FPGA via UART protocol communication with a PC in this case. It is able to communicate two-ways using a python script on VS Code where it allows the user to enter a character to be sent and also displays a byte sent from the FPGA: 
* Send data to the FPGA: it would turn on a specific pattern of LEDs depending on the input byte on the keyboard + Enter (i.e., 'F' turns one LED, 'G' turns two LEDs)
* Receive data from the FPGA: the byte sent by the FPGA will be able to be shown on screen

## FPGA
The FPGA used for this project was the Tang Nano 9k (GWINR-9)

## Files
The folders are distributed like this:
* src/ : all the source files for the design Verilog file
* constraints/ : have the cst file to arrange the ports of the FPGA with the correct pin location and voltage bank needed
* python/ : have the pyserial script to communicate via serial with the USB connected to the FPGA

## Python
The code was run by using Python on Visual Studio Code. In case of not having previously install the serial communication for Python, type on the terminal line: **pip install pyserial**.
Also in case of not knowing which communication port is used by the PC, check the code on **python/check_com** to know which to use (i.e., COM4). 
