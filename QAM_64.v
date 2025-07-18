module QAM_64(
	input [383:0] data_in,
	output [2047:0] data_real,data_imag
);
	genvar i;
	generate
		for(i = 0;i <64;i = i + 1)begin: qam
			QAM_64_real r(
				.data_in(data_in[6*i +: 6]),
				.data_out(data_real[32*i +: 32])
			);
			QAM_64_imag r0(
				.data_in(data_in[6*i +: 6]),
				.data_out(data_imag[32*i +: 32])
			);	
		end
	endgenerate


endmodule 