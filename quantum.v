module quantum(
	input [31:0] data_in, 
	output reg [31:0] data_out 
);

  
	always @(*)begin
	data_out[31] = data_in[31] ? 1'b1 : 1'b0;
	 case(data_in[30])
		1'b0:begin
			data_out[30:0] = 31'b0111_1111_00000000000000000000000;
		end
		1'b1:begin
			case(data_in[30:23])
				8'b1000_0000:begin
					data_out[30:0] = 31'b1000_0000_10000000000000000000000;
				end
				8'b1000_0001:begin
					case(data_in[22])
						1'b0:begin
							data_out[30:0] = 31'b1000_0001_01000000000000000000000;
						end
						1'b1:begin
							data_out[30:0] = 31'b1000_0001_11000000000000000000000;
						end
					endcase
				end
				default:begin
					data_out[30:0] = 31'b1000_0001_11000000000000000000000;
				end
			endcase
		end
	 endcase
	end
endmodule 