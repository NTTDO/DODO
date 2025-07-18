module top_quantum(
	input [2047:0]data_real,data_imag,
	output [2047:0]out_real,out_imag
);
	genvar i;
	generate
		for(i = 0;i <64;i = i + 1)begin: quantum
			quantum q0(
				.data_in(data_real[32*i +: 32]),
				.data_out(out_real[32*i +: 32])
			);	
			quantum q1(
				.data_in(data_imag[32*i +: 32]),
				.data_out(out_imag[32*i +: 32])
			);	
		end
	endgenerate
endmodule 