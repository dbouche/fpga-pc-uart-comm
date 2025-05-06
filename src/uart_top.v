module uart_top #(parameter BAUDRATE = 115200, 
                            CLOCK_FREQ = 27000000)(
    input sys_clk,          // clk input
    input sys_rst_n,        // reset input
    input rx,
    input button,
    output wire tx,
    output reg [5:0] led    // 6 LEDS pin 
);

// Constants to send data
parameter CHARACTER = 8'h41; // Send any ASCII character (i.e., 0x41 = 'A')

// Created variables to connect across submodules

// Variables to connect across submodules: reg (created here) & wire (created inside a submodule)
//	for receiver: uart_rx
wire [7:0] rx_data;
wire rx_ready;
//	for transmitter: uart_tx
reg tx_start;
reg [7:0] tx_data;
wire tx_busy;
reg tx_ready;
// variable for the button
reg hold_button;

uart_rx  #(.BAUDRATE(BAUDRATE), .CLOCK_FREQ(CLOCK_FREQ)) 
        rx1 (.clock(sys_clk), .n_reset(sys_rst_n), .rx(rx), .data_out(rx_data), .rx_ready(rx_ready));

uart_tx  #(.BAUDRATE(BAUDRATE), .CLOCK_FREQ(CLOCK_FREQ)) 
        tx1 (.clock(sys_clk), .n_reset(sys_rst_n), .tx_start(tx_start), .data_in(tx_data), .tx(tx), .tx_busy(tx_busy));


always @(posedge sys_clk or negedge sys_rst_n)
begin
	if (!sys_rst_n)
	  begin
		//tx <= 1;   
		led <= 6'b111111; // all LEDs are off this way on the Tang Nano
		tx_start <= 0; 
		tx_data <= 8'h00; // to standarize the use of this variable as in ASCII format 
        hold_button <= 0;
        tx_ready <= 1;
	  end
	else
	  begin
		if (rx_ready)
		  begin // Start-Block: to prioritize UART reception and avoid conflicts with any transmission
			tx_start <= 0;
            if (rx_data != 8'h00)
			  begin // Start-Block: to check a valid input has been received
                if (rx_data == 8'h46) // ASCII 'F'
                  begin
                    led <= 6'b111110;
                  end
                else if (rx_data == 8'h47) // ASCII 'G'
                  begin
                    led <= 6'b111100;
                  end 
              end // End-Block: to check a valid input has been received
		  end // End-Block: to prioritize UART reception and avoid conflicts with any transmission
		else
		  begin // Start-Block: Tx Logic
            // Detect falling edge of button (active-low press)
            if (!button && !hold_button)
              begin
                hold_button <= 1;
                tx_ready <= 1; // tx flag for the sending process
              end 
            else if (button && hold_button) 
              begin
                hold_button <= 0;  // Resets hold when button is released
              end

            // Start Tx only if the flag is ready, the process is not busy and the button was pressed 
            if (!tx_busy && tx_ready && hold_button) 
              begin
                tx_data <= CHARACTER; // this constant can be changed at the CHARACTER parameter 
                tx_start <= 1;
                tx_ready <= 0;
              end 
            else 
              begin
                tx_start <= 0;  // Ensure it's a one-cycle pulse
              end
		  end // End-Block: Tx Logic		  
	  end
end

endmodule 
