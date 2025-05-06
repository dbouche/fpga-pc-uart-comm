# This is a thread for reading data sent from the FPGA
def read_from_fpga(ser):
    while True:
        if ser.in_waiting:
            data = ser.read(1)
            print("[FPGA] →", data.hex(), data)

# This is a thread to send data to the FPGA using the command line
def write_to_fpga(ser):
    while True:
        cmd = input("[Python] Send: ")
        ser.write(cmd.encode())

import serial
import threading

ser = serial.Serial('COM18', 115200, timeout=1) # In this case the COM18 is the port where the FPGA connected

# The following is for the threads to run in parallel for sending or reading data
t1 = threading.Thread(target=read_from_fpga, args=(ser,), daemon=True)
t2 = threading.Thread(target=write_to_fpga, args=(ser,), daemon=True)

t1.start()
t2.start()

t1.join()
t2.join()
 
