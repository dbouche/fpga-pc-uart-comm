//Tx
module uart_tx #(parameter  BAUDRATE = 115200, 
                            CLOCK_FREQ = 27000000)
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
reg [9:0] tx_shift; // [9] = stop bit, [8:1] = data[0:7], [0] = start bit

// Baud period
localparam BAUD_TICKS = CLOCK_FREQ / BAUDRATE;

// State machine
reg [1:0] state;
localparam  IDLE = 2'b00,
            SEND = 2'b01,
            DONE = 2'b10;

always @(posedge clock or negedge n_reset)
begin
    if (!n_reset)
      begin
        tx <= 1;
        tx_busy <= 0;
        baud_counter <= 0;
        bit_idx <= 0;
        tx_shift <= 10'b1111111111;
        state <= IDLE;
      end
    else
      begin
        case(state)
            IDLE:
              begin
                tx <= 1;
                tx_busy <= 0; 
                if (tx_start)
                  begin
                    // Load start bit, data bits, and stop bit(s)
                    tx_shift <= {1'b1, data_in, 1'b0};  // LSB first
                    tx_busy <= 1;
                    bit_idx <= 0;
                    baud_counter <= 0;
                    state <= SEND;
                  end
              end
            SEND:
              begin
                if (baud_counter > BAUD_TICKS - 1'b1) 
                  begin // Start-block: sending each bit during the right period
                    if (bit_idx < 10)                    
                        tx <= tx_shift[bit_idx];                    
                    else 
                        state <= DONE;
                    baud_counter <= 0;    
                    bit_idx <= bit_idx + 1'b1;  
                  end // End-block: sending each bit during the right period
                else
                    baud_counter <= baud_counter + 1'b1;
              end
            DONE:
              begin
                tx <= 1;
                tx_busy <= 0; // Done sending all bits
                baud_counter <= 0;
                bit_idx <= 0;
                tx_shift <= 10'b1111111111;
                state <= IDLE;
              end
        endcase
      end
end

endmodule
