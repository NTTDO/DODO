module uart_rx#( 
		parameter CLK_FRE = 50000000, CLK_UART = 115200 
		)( 
		input clk, rst, rx, enable, 
		output reg rx_done, 
		output reg [7:0] rx_out 
); 
 
//parameter CLK_FRE = 50000000, CLK_UART = 115200; 
reg [15:0] counter; 
reg data_re, flag; 
reg [9:0] mem_buffer; 
	always @(posedge clk or negedge rst) begin 
		if (!rst) begin 
			rx_done <= 0; 
			mem_buffer <= 0; 
			counter <= 0; 
			data_re <= 0; 
			rx_out <= 8'hff; 
			flag <= 0; 
		end else if (enable) begin 
			if (counter == 16'd0 && rx == 1'b0) begin 
				data_re <= 1'b1; 
			end else if (data_re) begin 
				case (counter)  
					CLK_FRE/(CLK_UART*2) * 1: 
						mem_buffer[0] <= rx; 
					CLK_FRE/(CLK_UART*2) * 3: 
						mem_buffer[1] <= rx; 
					CLK_FRE/(CLK_UART*2) * 5: 
						mem_buffer[2] <= rx; 
					CLK_FRE/(CLK_UART*2) * 7: 
						mem_buffer[3] <= rx; 
					CLK_FRE/(CLK_UART*2) * 9: 
						mem_buffer[4] <= rx; 
					CLK_FRE/(CLK_UART*2) * 11: 
						mem_buffer[5] <= rx; 
					CLK_FRE/(CLK_UART*2) * 13: 
						mem_buffer[6] <= rx; 
					CLK_FRE/(CLK_UART*2) * 15: 
						mem_buffer[7] <= rx; 
					CLK_FRE/(CLK_UART*2) * 17: 
						mem_buffer[8] <= rx; 
					CLK_FRE/(CLK_UART*2) * 19: begin 
						mem_buffer[9] <= rx; 
						data_re <= 1'b0; 
						flag <= 1; 
						rx_done <= 1; 
					end 
				endcase 
			end 
			if (data_re) begin 
				counter <= counter + 1; 
			end else begin 
				rx_done <= 0; 
				counter <= 0; 
			if (flag) begin 
				rx_out <= mem_buffer[8:1]; 
				flag <= 0; 
			end 
				mem_buffer <= 0; 
			end 
		end 
	end 
endmodule