module uart_tx #(parameter  BAUDRATE = 115200, 
                            CLOCK_FREQ = 27000000,
                            BAUD_TICKS = CLOCK_FREQ / BAUDRATE)
(
    input clock,          // clk input
    input n_reset,        // reset input
    input tx_start,
    input [7:0] data_in,
    output reg tx,
    output reg tx_busy
);

// Tx variables
reg [15:0] baud_counter; 
reg [3:0] bit_idx;
reg [9:0] tx_shift; // start + data + stop bits

always @(posedge clock or negedge n_reset)
begin
    if (!n_reset)
      begin
        tx <= 1;
        tx_busy <= 0;
        baud_counter <= 0;
        bit_idx <= 0;
        tx_shift <= 10'b1111111111;
      end
    else
      begin
        if (!tx_busy) 
          begin
            if (tx_start) 
              begin
                // Load start bit, data bits, and stop bit(s)
                tx_shift <= {1'b1, data_in, 1'b0};  // LSB first
                tx_busy <= 1;
                bit_idx <= 0;
                baud_counter <= 0;
              end
          end 
        else 
          begin // Start-block: during transmission of data
            baud_counter <= baud_counter + 1;
            if (baud_counter >= BAUD_TICKS) 
              begin // Start-block: sending each bit during the right period
                baud_counter <= 0;
                tx <= tx_shift[bit_idx];
                bit_idx <= bit_idx + 1;

                if (bit_idx == 9) 
                  begin // Start-block: announce the send process is done and resets variables to avoid latches
                    tx <= 1;
                    tx_busy <= 0; // Done sending all bits
                    baud_counter <= 0;
                    bit_idx <= 0;
                    tx_shift <= 10'b1111111111;
                  end // End-block: announce the send process is done and resets variables to avoid latches
              end // End-block: sending each bit during the right period
          end // End-block: during transmission of data
      end
end

endmodule