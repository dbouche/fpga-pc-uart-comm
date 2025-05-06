
module uart_rx #(parameter BAUDRATE = 115200, 
                        CLOCK_FREQ = 27000000,
                        BAUD_TICKS = CLOCK_FREQ / BAUDRATE)
(
    input clock,          // clk input
    input n_reset,        // reset input
    input rx,
    output reg [7:0] data_out,
    output reg rx_ready
);

//Rx variables
reg [15:0] baud_counter; 
reg [3:0] bit_idx;
reg [7:0] rx_shift;
reg receiving;

always @(posedge clock or negedge n_reset) 
begin
    if (!n_reset)
      begin
        data_out <= 8'h00;
        rx_shift <= 8'h00;
        rx_ready <= 1; // to make the rx_ready as default
        baud_counter <= 0; 
        bit_idx <= 0;
        receiving <= 0;
      end
    else if (bit_idx == 8) // to tell the top module when it's done with the data
      begin // Start-Block: Finish processing the received byte, raise the 'done' flag and reset variables to avoid latches
        bit_idx <= 0;
        rx_ready <= 1; // Equivalent of a 'Done' flag
        data_out <= rx_shift;
        rx_shift <= 8'h00;
        receiving <= 0; // finish the process of receiving data
      end // End-Block: Finish processing the received byte, raise the 'done' flag and reset variables to avoid latches
    else 
      begin
        // Resetting variables to avoid the creation of latches
        rx_ready <= 0;
        data_out <= 0;
        // Main code for the appropiate period to process data
        baud_counter <= baud_counter + 1; // to wait for each bit to be read
        if (baud_counter >= BAUD_TICKS)
          begin // Start-Block: receiving each bit during the right period
            baud_counter <= 0;  // Resets the counter
            // Interaction with the data to be read:
            if (!receiving && !rx)
              begin
                receiving <= 1;
              end
            else if (receiving) 
              begin // Start-Block: Reading and storing the received data 
                rx_shift <= {rx, rx_shift[7:1]}; // Shifting the data from MSB to LSB
                bit_idx <= bit_idx + 1;
             end // End-Block: Reading and storing the received data 
          end // End-Block: receiving each bit during the right period    
      end
end

endmodule
