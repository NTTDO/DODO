module top(
	input clk,reset,start,
	input [191:0] data_in,//code_in
	output [191:0] data_out,
	output reg busy
);
	reg start_encoder,start_ifft_fft,start_decoder;
	wire [383:0] data_out_encoder,data_out_demodulation,data_out_decoder;
	reg [191:0] data_in_encoder,data_in_decoder,data_out_reg;
	reg [383:0] data_in_modulation;
	wire [2047:0]data_imag,data_real,data_imag_out,data_real_out;
	reg [2047:0]data_real_demodulation,data_imag_demodulation,data_real_quantum,data_imag_quantum;
	wire done_encoder,done_ifft_fft;
	reg flag_0,flag_1,flag_2,flag_3;
	
	assign data_out = data_out_reg;
	
	top_encoder u0(
		.clk(clk),
		.reset(reset),
		.start(start_encoder),
		.m_text(data_in_encoder),
		.encoder(data_out_encoder),
		.done(done_encoder)
	);
	QAM_64 u1(
		.data_in(data_in_modulation),
		.data_real(data_real),
		.data_imag(data_imag)
	);
	FFT_IFFT u2(
		.clk(clk),
		.reset(reset),
		.start(start_ifft_fft),
		.done(done_ifft_fft),
		.data_ready(),
		.input_real(data_real),
		.input_imag(data_imag),
		.data_real_buffer(data_real_out),
		.data_imag_buffer(data_imag_out)
	);
	top_quantum u2(
		.data_real(data_real_out),
		.data_imag(data_imag_out),
		.out_real(data_real_quantum),
		.out_imag(data_imag_quantum)
	);
	DEQAM_64 u3(
		.data_real_in(data_real_demodulation),
		.data_imag_in(data_imag_demodulation),
		.data_out(data_out_demodulation)
	);
	viterbi_decoder u4(
		.clk(clk),
		.reset(reset),
		.start(start_decoder),
		.code_in(data_in_decoder),
		.data_out(data_out_decoder),
		.done(done_decoder)
	);
	always @(posedge clk or negedge reset)begin
		if(!reset)begin
			busy 			<= 0;
			start_decoder 	<= 0;
			start_ifft_fft  <= 0;
			start_encoder	<= 0;
			flag_0			<= 0;
			flag_1			<= 0;
			flag_2			<= 0;
			flag_3			<= 0;
			data_in_decoder	<= 0;
			data_real_demodulation	<= 0;
			data_imag_demodulation	<= 0;
			data_in_modulation		<= 0;
			 
		end else begin
			if(start)begin
				start_decoder <= 1;
				flag_0 		  <= 1;
			end
			if(flag_0 && done_encoder)begin
				flag_0		  <= 0;
				flag_1 		  <= 1;				
				data_in_modulation	<= data_out_encoder;
				start_ifft_fft		<= 1;
			end
			if(flag_1&&done_ifft_fft)begin
				flag_1		<= 0;
				flag_2 		<= 1;
				data_real_demodulation	<= data_real_quantum;
				data_imag_demodulation	<= data_imag_quantum;
			end 
			if(flag_2)begin
				flag_2 		<= 0;
				flag_3		<= 1;
				start_decoder	<= 0;
			end
			if(flag_3&&done_decoder)begin
				flag_3		<= 0;
				data_out_reg	<= data_out_decoder;
			end
		end
			
	end
	
endmodule







