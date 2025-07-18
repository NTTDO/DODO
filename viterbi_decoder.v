module viterbi_decoder(
	input clk,reset,start,
	input [383:0] code_in,
	output [191:0] data_out, 
	output done 
);
	wire [23:0]done_temp;
	assign done = done_temp[0];

	genvar i;
	generate
		for(i = 0; i < 24;i = i + 1)begin :decoder
			viterbi_16bit decoder(
				.clk(clk),
				.reset(reset),
				.start(start),
				.code_in(code_in[16*i +: 16]),
				.data_out(data_out[8*i +: 8]),
				.done(done_temp[i])
			);
		end
	endgenerate
endmodule