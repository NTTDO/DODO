module DEQAM_64(
	output [383:0] data_out,
	input [2047:0] data_real_in,data_imag_in
);
	genvar i;
	generate
		for(i = 0;i <64;i = i + 1)begin: qam
			DEQAM r0(
				.data_in({data_real_in[32*i +: 32],data_imag_in[32*i +: 32]}),
				.data_out(data_out[6*i +: 6])
			);	
		end
	endgenerate


endmodule 