//Trigger Control
module out_trigger 
(
    input clock,          // clk input
    input n_reset,        // reset input
    input new_pattern_in,
    input [1:0] pulse_rate,
    output reg [5:0] led   // 6 LEDS pin 
);

// Pulses/time variables
localparam  PULSE_WIDTH_1 = 27000,  // 1ms at 27MHz 
            PULSE_WIDTH_2 = 54000,  // 2ms at 27MHz 
            PULSE_WIDTH_3 = 135000, // 5ms at 27MHz 
            PULSE_WIDTH_4 = 270000; // 10ms at 27MHz 
reg [24:0] pulse_counter;
reg [24:0] pulse_width;
// pulse options selection
localparam  RATE1 = 2'b00,
            RATE2 = 2'b01,
            RATE3 = 2'b10,
            RATE4 = 2'b11;

// State machine
reg [1:0] state;
localparam  IDLE = 2'b00,
            PULSE_SELECT = 2'b01,
            START = 2'b10,
            DONE = 2'b11;

always @(posedge clock or negedge n_reset)
begin
    if (!n_reset)
      begin
        pulse_counter <= 0;
        pulse_width <= PULSE_WIDTH_1;
		led <= 6'b111111; // all LEDs are off this way on the Tang Nano
        state <= IDLE;
      end
    else 
      begin
        case(state)
            IDLE:
                if (new_pattern_in) // Section to detect when there's a new input being received
                    state <= PULSE_SELECT;
            PULSE_SELECT:
              begin
                case(pulse_rate)
                    RATE1: pulse_width <= PULSE_WIDTH_1;
                    RATE2: pulse_width <= PULSE_WIDTH_2;
                    RATE3: pulse_width <= PULSE_WIDTH_3;
                    RATE4: pulse_width <= PULSE_WIDTH_4;
                endcase
                pulse_counter <= 0;
                state <= START;
              end
            START:
              begin
                if (pulse_counter < pulse_width - 1'b1) // for it to count the exact amount of pulses until turning the pulse OFF
                  begin
                    led <= 6'b111110;
                    pulse_counter <= pulse_counter + 1'b1;
                  end
                else
                    state <= DONE;
              end
            DONE:
              begin
                led <= 6'b111111;
                pulse_width <= PULSE_WIDTH_1;
                state <= IDLE;
              end
        endcase
      end
end


endmodule