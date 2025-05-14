//Rx
module uart_rx #(parameter  BAUDRATE = 115200, 
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

// State machine
reg [1:0] state;
localparam  IDLE = 2'b00,
            OFFSET = 2'b01, // to offset the bit reading to the middle of the period
            READ = 2'b10,
            DONE = 2'b11;

always @(posedge clock or negedge n_reset) 
begin
    if (!n_reset)
      begin
        data_out <= 8'h00;
        rx_shift <= 8'h00;
        rx_ready <= 0; // to make the rx_ready as default
        baud_counter <= 0; 
        bit_idx <= 0;
        state <= IDLE;
      end
    else 
      begin
        rx_ready <= 0;

        case (state)
            IDLE: 
              begin
                data_out <= 8'h00;
                rx_shift <= 8'h00;
                if (!rx) 
                  begin  // Start bit detected
                    baud_counter <= 0;
                    state <= OFFSET;
                  end
              end
            OFFSET: // to the middle of the reading period
              begin
                if (baud_counter >= BAUD_TICKS / 2) // Wait half bit to sample in middle
                  begin
                    baud_counter <= 0;
                    bit_idx <= 0;
                    state <= READ;
                  end 
                else
                    baud_counter <= baud_counter + 1'b1;
              end
            READ: 
              begin
                if (baud_counter >= BAUD_TICKS - 1'b1) 
                  begin
                    rx_shift <= {rx, rx_shift[7:1]};
                    bit_idx <= bit_idx + 1'b1;
                    baud_counter <= 0;
                    if (bit_idx == 7)
                        state <= DONE;
                  end 
                else
                    baud_counter <= baud_counter + 1'b1;
              end
            DONE: 
              begin
                data_out <= rx_shift;
                rx_ready <= 1;
                state <= IDLE;
              end
        endcase
    end
end

endmodule
