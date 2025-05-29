//Top
module top #(parameter  BAUDRATE =  115200, 
                        CLOCK_FREQ = 27000000)
(
    input sys_clk,          // clk input
    input sys_rst_n,        // reset input
    input rx,
    input button,
    output wire tx,
    output wire [5:0] led   // 6 LEDS pin 
);

// Constants to send data
localparam  CHARACTER = 8'h45, // Send any ASCII character (i.e., 0x45 = 'E')
            RECEIVED = 8'h52,   // Send back to the device that a data was received successfully (i.e., 0x52 = 'R') 
            ASCII_A = 8'h41,
            ASCII_B = 8'h42,
            ASCII_C = 8'h43,
            ASCII_D = 8'h44;

// Variables to connect across submodules: reg (created here) & wire (created inside a submodule or outside an always block)
//	for receiver: uart_rx
wire [7:0] rx_data;
reg [7:0] copy_rx_data;
wire rx_ready;
reg rx_ready_prev;
wire rx_ready_pulse;
//	for transmitter: uart_tx
reg tx_start;
reg [7:0] send_data;
reg [7:0] tx_data;
wire tx_busy;

// Variable for the button
reg button_prev;
wire button_falling_edge;

// Variable for the Spectrometer trigger
reg new_pattern_in; 
reg [1:0] pulse_rate;

// State machine
reg [1:0] state;
localparam  IDLE = 2'b00,
            RX_PROCESS = 2'b01,
            TX_SEND = 2'b10;

// Submodule instantiations
uart_rx  #(.BAUDRATE(BAUDRATE), .CLOCK_FREQ(CLOCK_FREQ)) 
        rx1 (.clock(sys_clk), .n_reset(sys_rst_n), .rx(rx), .data_out(rx_data), .rx_ready(rx_ready));

uart_tx  #(.BAUDRATE(BAUDRATE), .CLOCK_FREQ(CLOCK_FREQ)) 
        tx1 (.clock(sys_clk), .n_reset(sys_rst_n), .tx_start(tx_start), .data_in(tx_data), .tx(tx), .tx_busy(tx_busy));

out_trigger outt1 (.clock(sys_clk), .n_reset(sys_rst_n), .new_pattern_in(new_pattern_in), .pulse_rate(pulse_rate), .led(led));

// Main code
always @(posedge sys_clk or negedge sys_rst_n)
begin
	if (!sys_rst_n)
	  begin  
		tx_start <= 0; 
		tx_data <= 8'h00; // to standarize the use of this variable as in ASCII format 
        new_pattern_in <= 0;
        rx_ready_prev <= 0;
        copy_rx_data <= 0;
        pulse_rate <= 0;
        send_data <= 0;
        button_prev <= 0;
        state <= IDLE;
	  end
	else
	  begin
        // debouncing/sync variables
        rx_ready_prev <= rx_ready;
        button_prev <= button;
        
        // Deassert single-cycle control signals
        new_pattern_in <= 0;
        tx_start <= 0;

        case(state)
            IDLE:
              begin
                tx_data <= 8'h00;
                if (rx_ready_pulse) // prioritize the detection of data
                  begin
                    tx_start <= 0;
                    copy_rx_data <= rx_data; // store the data into a local variable
                    if (rx_data != 8'h00)
                        state <= RX_PROCESS;
                  end
                else if (button_falling_edge && !tx_busy)
                  begin
                    send_data <= CHARACTER;
                    state <= TX_SEND;
                  end
              end
            RX_PROCESS:
              begin
                if (copy_rx_data >= ASCII_A && copy_rx_data <= ASCII_D)
                  begin
                    new_pattern_in <= 1;
                    send_data <= RECEIVED;  // This is to acknowledge the byte sent to the FPGA was received (sends back an 'R')
                    case(copy_rx_data)
                        ASCII_A: pulse_rate <= 2'b00;
                        ASCII_B: pulse_rate <= 2'b01;
                        ASCII_C: pulse_rate <= 2'b10;
                        ASCII_D: pulse_rate <= 2'b11;
                    endcase
                    state <= TX_SEND; 
                  end
                else
                  begin
                    new_pattern_in <= 0;
                    send_data <= 0;
                    state <= IDLE;
                  end
                copy_rx_data <= 0; // clear store values befor storing the next one
              end
            TX_SEND:
              begin
                tx_data <= send_data; // this constant can be changed at the CHARACTER parameter 
                send_data <= 0;
                tx_start <= 1;
                state <= IDLE;
              end
        endcase	  
	  end
end

assign rx_ready_pulse = rx_ready & ~rx_ready_prev;
assign button_falling_edge = button_prev & ~button;

endmodule 
