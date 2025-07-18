module top_encoder(
	input clk,
	input reset,
	input start,
	input [191:0] m_text,
	output [383:0] encoder,
	output done
);	
	wire  [23:0] done_temp;
	assign done = done_temp[0];
	genvar i;
	generate
		for(i = 0;i < 24;i = i + 1)begin: loop_encoder
			convolution_code encode(
				.clk(clk),
				.reset(reset),
				.start(start),
				.m_text_in(m_text[8*i +: 8]),
				.code_out(encoder[16*i +: 16]),
				.done(done_temp[i])
			);
		end
	endgenerate

endmodule