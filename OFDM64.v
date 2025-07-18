module OFDM64(
	input clk,reset,start,
	input [191:0] data_in,//code_in
	output [191:0] data_out,
	//output [2047:0]data_imag,data_real,data_real_out,data_imag_out,
	//output reg [2047:0]data_real_demodulation,data_imag_demodulation,
	//output [383:0]data_out_encoder,
	output reg busy
);	
	//reg [191:0] data_in; 
	reg start_encoder,start_ifft_fft,start_decoder;
	wire [383:0]  data_out_demodulation,data_out_encoder;
	reg [191:0] data_in_encoder,data_out_reg;
	wire [191:0] data_out_decoder;
	reg [383:0] data_in_modulation,data_in_decoder;
	wire [2047:0]data_real_quantum,data_imag_quantum;
	reg [2047:0]data_real_out_temp,data_imag_out_temp;
	wire  [2047:0]data_imag,data_real,data_real_out,data_imag_out;
	reg [2047:0]data_real_demodulation,data_imag_demodulation;
	wire done_encoder,done_ifft_fft,done_decoder;
	reg flag_0,flag_1,flag_2,flag_3,flag_2_0,flag_2_1;
	integer x = 0;
	integer y = 0;
	integer i;
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
		.real_out_fft(data_real_out),
		.imag_out_fft(data_imag_out)
	);
	top_quantum ux(
		.data_real(data_real_out_temp),
		.data_imag(data_imag_out_temp),
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
			flag_2_0        <= 0;
			data_in_decoder	<= 0;
			data_in_encoder <= 0;
			data_real_demodulation	<= 0;
			data_imag_demodulation	<= 0;
			data_in_modulation		<= 0;
			 
		end else begin
			if(start)begin
				start_encoder <= 1;
				flag_0 		  <= 1;
				data_in_encoder <= data_in;
			end
			if(flag_0 && done_encoder)begin
				flag_0		  <= 0;
				flag_1 		  <= 1;				
				data_in_modulation	<= data_out_encoder;
				start_ifft_fft		<= 1;
			end
			if(flag_1&&done_ifft_fft)begin
				flag_1		<= 0; 
				flag_2_0 	<= 1;
			end 
			if(flag_2_0)begin
				flag_2_0 <= 0;
				flag_2_1 <= 1;
				data_real_out_temp[2047:2016] <= data_real_out[2047:2016];
				data_imag_out_temp[2047:2016] <= data_imag_out[2047:2016];
				data_real_out_temp[2015 : 1984] <= data_real_out[31:0];
				data_real_out_temp[1983 : 1952] <= data_real_out[63:32];
				data_real_out_temp[1951 : 1920] <= data_real_out[95:64];
				data_real_out_temp[1919 : 1888] <= data_real_out[127:96];
				data_real_out_temp[1887 : 1856] <= data_real_out[159:128];
				data_real_out_temp[1855 : 1824] <= data_real_out[191:160];
				data_real_out_temp[1823 : 1792] <= data_real_out[223:192];
				data_real_out_temp[1791 : 1760] <= data_real_out[255:224];
				data_real_out_temp[1759 : 1728] <= data_real_out[287:256];
				data_real_out_temp[1727 : 1696] <= data_real_out[319:288];
				data_real_out_temp[1695 : 1664] <= data_real_out[351:320];
				data_real_out_temp[1663 : 1632] <= data_real_out[383:352];
				data_real_out_temp[1631 : 1600] <= data_real_out[415:384];
				data_real_out_temp[1599 : 1568] <= data_real_out[447:416];
				data_real_out_temp[1567 : 1536] <= data_real_out[479:448];
				data_real_out_temp[1535 : 1504] <= data_real_out[511:480];
				data_real_out_temp[1503 : 1472] <= data_real_out[543:512];
				data_real_out_temp[1471 : 1440] <= data_real_out[575:544];
				data_real_out_temp[1439 : 1408] <= data_real_out[607:576];
				data_real_out_temp[1407 : 1376] <= data_real_out[639:608];
				data_real_out_temp[1375 : 1344] <= data_real_out[671:640];
				data_real_out_temp[1343 : 1312] <= data_real_out[703:672];
				data_real_out_temp[1311 : 1280] <= data_real_out[735:704];
				data_real_out_temp[1279 : 1248] <= data_real_out[767:736];
				data_real_out_temp[1247 : 1216] <= data_real_out[799:768];
				data_real_out_temp[1215 : 1184] <= data_real_out[831:800];
				data_real_out_temp[1183 : 1152] <= data_real_out[863:832];
				data_real_out_temp[1151 : 1120] <= data_real_out[895:864];
				data_real_out_temp[1119 : 1088] <= data_real_out[927:896];
				data_real_out_temp[1087 : 1056] <= data_real_out[959:928];
				data_real_out_temp[1055 : 1024] <= data_real_out[991:960];
				data_real_out_temp[1023 : 992] <= data_real_out[1023:992];
				data_real_out_temp[991 : 960] <= data_real_out[1055:1024];
				data_real_out_temp[959 : 928] <= data_real_out[1087:1056];
				data_real_out_temp[927 : 896] <= data_real_out[1119:1088];
				data_real_out_temp[895 : 864] <= data_real_out[1151:1120];
				data_real_out_temp[863 : 832] <= data_real_out[1183:1152];
				data_real_out_temp[831 : 800] <= data_real_out[1215:1184];
				data_real_out_temp[799 : 768] <= data_real_out[1247:1216];
				data_real_out_temp[767 : 736] <= data_real_out[1279:1248];
				data_real_out_temp[735 : 704] <= data_real_out[1311:1280];
				data_real_out_temp[703 : 672] <= data_real_out[1343:1312];
				data_real_out_temp[671 : 640] <= data_real_out[1375:1344];
				data_real_out_temp[639 : 608] <= data_real_out[1407:1376];
				data_real_out_temp[607 : 576] <= data_real_out[1439:1408];
				data_real_out_temp[575 : 544] <= data_real_out[1471:1440];
				data_real_out_temp[543 : 512] <= data_real_out[1503:1472];
				data_real_out_temp[511 : 480] <= data_real_out[1535:1504];
				data_real_out_temp[479 : 448] <= data_real_out[1567:1536];
				data_real_out_temp[447 : 416] <= data_real_out[1599:1568];
				data_real_out_temp[415 : 384] <= data_real_out[1631:1600];
				data_real_out_temp[383 : 352] <= data_real_out[1663:1632];
				data_real_out_temp[351 : 320] <= data_real_out[1695:1664];
				data_real_out_temp[319 : 288] <= data_real_out[1727:1696];
				data_real_out_temp[287 : 256] <= data_real_out[1759:1728];
				data_real_out_temp[255 : 224] <= data_real_out[1791:1760];
				data_real_out_temp[223 : 192] <= data_real_out[1823:1792];
				data_real_out_temp[191 : 160] <= data_real_out[1855:1824];
				data_real_out_temp[159 : 128] <= data_real_out[1887:1856];
				data_real_out_temp[127 : 96] <= data_real_out[1919:1888];
				data_real_out_temp[95 : 64] <= data_real_out[1951:1920];
				data_real_out_temp[63 : 32] <= data_real_out[1983:1952];
				data_real_out_temp[31 : 0] <= data_real_out[2015:1984];
                
				data_imag_out_temp[2015 : 1984] <= data_imag_out[31:0];
				data_imag_out_temp[1983 : 1952] <= data_imag_out[63:32];
				data_imag_out_temp[1951 : 1920] <= data_imag_out[95:64];
				data_imag_out_temp[1919 : 1888] <= data_imag_out[127:96];
				data_imag_out_temp[1887 : 1856] <= data_imag_out[159:128];
				data_imag_out_temp[1855 : 1824] <= data_imag_out[191:160];
				data_imag_out_temp[1823 : 1792] <= data_imag_out[223:192];
				data_imag_out_temp[1791 : 1760] <= data_imag_out[255:224];
				data_imag_out_temp[1759 : 1728] <= data_imag_out[287:256];
				data_imag_out_temp[1727 : 1696] <= data_imag_out[319:288];
				data_imag_out_temp[1695 : 1664] <= data_imag_out[351:320];
				data_imag_out_temp[1663 : 1632] <= data_imag_out[383:352];
				data_imag_out_temp[1631 : 1600] <= data_imag_out[415:384];
				data_imag_out_temp[1599 : 1568] <= data_imag_out[447:416];
				data_imag_out_temp[1567 : 1536] <= data_imag_out[479:448];
				data_imag_out_temp[1535 : 1504] <= data_imag_out[511:480];
				data_imag_out_temp[1503 : 1472] <= data_imag_out[543:512];
				data_imag_out_temp[1471 : 1440] <= data_imag_out[575:544];
				data_imag_out_temp[1439 : 1408] <= data_imag_out[607:576];
				data_imag_out_temp[1407 : 1376] <= data_imag_out[639:608];
				data_imag_out_temp[1375 : 1344] <= data_imag_out[671:640];
				data_imag_out_temp[1343 : 1312] <= data_imag_out[703:672];
				data_imag_out_temp[1311 : 1280] <= data_imag_out[735:704];
				data_imag_out_temp[1279 : 1248] <= data_imag_out[767:736];
				data_imag_out_temp[1247 : 1216] <= data_imag_out[799:768];
				data_imag_out_temp[1215 : 1184] <= data_imag_out[831:800];
				data_imag_out_temp[1183 : 1152] <= data_imag_out[863:832];
				data_imag_out_temp[1151 : 1120] <= data_imag_out[895:864];
				data_imag_out_temp[1119 : 1088] <= data_imag_out[927:896];
				data_imag_out_temp[1087 : 1056] <= data_imag_out[959:928];
				data_imag_out_temp[1055 : 1024] <= data_imag_out[991:960];
				data_imag_out_temp[1023 : 992] <= data_imag_out[1023:992];
				data_imag_out_temp[991 : 960] <= data_imag_out[1055:1024];
				data_imag_out_temp[959 : 928] <= data_imag_out[1087:1056];
				data_imag_out_temp[927 : 896] <= data_imag_out[1119:1088];
				data_imag_out_temp[895 : 864] <= data_imag_out[1151:1120];
				data_imag_out_temp[863 : 832] <= data_imag_out[1183:1152];
				data_imag_out_temp[831 : 800] <= data_imag_out[1215:1184];
				data_imag_out_temp[799 : 768] <= data_imag_out[1247:1216];
				data_imag_out_temp[767 : 736] <= data_imag_out[1279:1248];
				data_imag_out_temp[735 : 704] <= data_imag_out[1311:1280];
				data_imag_out_temp[703 : 672] <= data_imag_out[1343:1312];
				data_imag_out_temp[671 : 640] <= data_imag_out[1375:1344];
				data_imag_out_temp[639 : 608] <= data_imag_out[1407:1376];
				data_imag_out_temp[607 : 576] <= data_imag_out[1439:1408];
				data_imag_out_temp[575 : 544] <= data_imag_out[1471:1440];
				data_imag_out_temp[543 : 512] <= data_imag_out[1503:1472];
				data_imag_out_temp[511 : 480] <= data_imag_out[1535:1504];
				data_imag_out_temp[479 : 448] <= data_imag_out[1567:1536];
				data_imag_out_temp[447 : 416] <= data_imag_out[1599:1568];
				data_imag_out_temp[415 : 384] <= data_imag_out[1631:1600];
				data_imag_out_temp[383 : 352] <= data_imag_out[1663:1632];
				data_imag_out_temp[351 : 320] <= data_imag_out[1695:1664];
				data_imag_out_temp[319 : 288] <= data_imag_out[1727:1696];
				data_imag_out_temp[287 : 256] <= data_imag_out[1759:1728];
				data_imag_out_temp[255 : 224] <= data_imag_out[1791:1760];
				data_imag_out_temp[223 : 192] <= data_imag_out[1823:1792];
				data_imag_out_temp[191 : 160] <= data_imag_out[1855:1824];
				data_imag_out_temp[159 : 128] <= data_imag_out[1887:1856];
				data_imag_out_temp[127 : 96] <= data_imag_out[1919:1888];
				data_imag_out_temp[95 : 64] <= data_imag_out[1951:1920];
				data_imag_out_temp[63 : 32] <= data_imag_out[1983:1952];
				data_imag_out_temp[31 : 0] <= data_imag_out[2015:1984];
			      
			end
			if(flag_2_1)begin
			 flag_2_1 <= 0;
			 flag_2   <= 1;
			 data_real_demodulation	<= data_real_quantum;
			 data_imag_demodulation	<= data_imag_quantum;
			end
			if(flag_2)begin
				flag_2 		<= 0;
				flag_3		<= 1;
				 
				start_decoder	<= 1;
				data_in_decoder <= data_out_demodulation;
			end
			if(flag_3&&done_decoder)begin
				flag_3		    <= 0;
				data_out_reg	<= data_out_decoder;
			end
		end
	end
	
endmodule







