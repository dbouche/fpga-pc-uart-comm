`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/21/2025 10:48:51 AM
// Design Name: 
// Module Name: uart_test
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module uart_test #(parameter  BAUDRATE =  115200, 
                        CLOCK_FREQ = 27000000);

logic sys_clk, sys_rst_n, rx, button;
logic tx, ttl_pulse;
logic [5:0] led;
logic [7:0] data;
logic [9:0] packet;
integer i;

top #(.BAUDRATE(BAUDRATE), .CLOCK_FREQ(CLOCK_FREQ))
    top1 (.sys_clk(sys_clk), .sys_rst_n(sys_rst_n), .rx(rx), .button(button), .tx(tx), .led(led), .ttl_pulse(ttl_pulse));

localparam  real    PERIOD = (1*10**9)/CLOCK_FREQ,
                    HALF_PERIOD = PERIOD/2;
localparam BAUD_PERIOD = (1*10**9)/BAUDRATE; //8680ns -> 8680ns x 11 = 95480

initial 
begin
    sys_rst_n = 1;
    sys_clk = 0;
    #15
    sys_rst_n = 0;
    #15
    sys_rst_n = 1;
    #7
    forever #HALF_PERIOD sys_clk = ~sys_clk;    
end

initial
begin
    rx = 1;
    button = 1;
    
    data = 8'b01010101; // 8'h55 
    packet = {1'b1, data, 1'b0}; // stop, data, start (bits)
    for (i=0; i < 10; i = i + 1'b1)
    begin
        #BAUD_PERIOD rx = packet[i]; // from LSB to MSB
    end
    
    #7000
    
    data = 8'b01000001; // 8'h41
    packet = {1'b1, data, 1'b0}; // stop, data, start (bits)
    for (i=0; i < 10; i = i + 1'b1)
    begin
        #BAUD_PERIOD rx = packet[i]; // from LSB to MSB
    end
    // Send received (8'h52)
    
    
#95480
#95480
#95480
#95480
$stop;
end

endmodule
