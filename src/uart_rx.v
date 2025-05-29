//Rx
module uart_rx #(parameter  BAUDRATE = 115200, 
                            CLOCK_FREQ = 27000000)
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
// to make the rx input synchronous (2-stage flip-flop synchronizer):
reg rx_sync_1;
reg rx_sync_2;

// Baud period
localparam  BAUD_TICKS = CLOCK_FREQ / BAUDRATE; 
            
// State machine
reg [1:0] state;
localparam  IDLE = 2'b00,
            START = 2'b01, // to offset the bit reading to the middle of the period
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
        rx_sync_1 <= 1;
        rx_sync_2 <= 1;
        state <= IDLE;
      end
    else 
      begin
        rx_sync_1 <= rx;        // Stage 1
        rx_sync_2 <= rx_sync_1; // Stage 2
        
        rx_ready <= 0;

        case (state)
            IDLE: 
              begin
                data_out <= 8'h00;
                rx_shift <= 8'h00;
                if (!rx_sync_2) 
                  begin  // Start bit detected
                    baud_counter <= 0;
                    bit_idx <= 0;
                    state <= START;
                  end
              end
            START: // to the middle of the reading period
              begin
                if (baud_counter >= (BAUD_TICKS / 2) - 1'b1) // Wait half bit to sample in middle
                  begin
                    if (!rx_sync_2)
                      begin
                        baud_counter <= 0;
                        state <= READ; 
                      end
                    else
                        state <= IDLE; // False start bit, go back 
                  end 
                else
                    baud_counter <= baud_counter + 1'b1;
              end
            READ: 
              begin
                if (baud_counter >= BAUD_TICKS - 1'b1) 
                  begin
                    if (bit_idx < 8) // only store the 8 bit data
                        rx_shift <= {rx_sync_2, rx_shift[7:1]};    
                    else if (bit_idx == 8)
                      begin
                        // at this part it waits for the stop bit
                      end 
                    else if (bit_idx > 8)   // wait for the 9th bit which should be the stop bit (1'b1)
                        state <= DONE;
                    bit_idx <= bit_idx + 1'b1;
                    baud_counter <= 0;
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
