module OFDM64_ver_pipline (
	input clk,reset,start,rx,
	//input [191:0] data_in,//code_in
	//output [191:0] data_out,
	//output [2047:0]data_imag,data_real,data_real_out,data_imag_out,
	//output reg [2047:0]data_real_demodulation,data_imag_demodulation,
	//output [383:0]data_out_encoder,
	output reg busy,
 	// input [1151:0] data_in_encoder,
	output tx ,
	output [31:0] num
);
	parameter	START 		= 4'd0,
				RECEIVE	 	= 4'd1,
				ENCODE		= 4'd2,
				MODULA 		= 4'd3,
				BUFFER		= 4'd4,
				EX			= 4'd5,
				HOLD     	= 4'd6,
				DECODE  	= 4'd7,
				SEND 		= 4'd8,
				DEMODU      = 4'd9,
				QUANTUM     = 4'd10 ;
	reg [191:0]data_in[0:5];
	wire [7:0] data_rx;
	reg [3:0] state,next_state;
	wire done_send;
	wire done_receive;
	reg busy_in;
	reg start_encoder,start_ifft_fft,start_tx,start_rx;
	wire done_ifft_fft;
	wire [5:0]done_decoder;
	wire[383:0]  data_out_demodulation[0:5];
	wire [2303:0] data_out_encoder;
	reg [1151:0] data_in_encoder,data_out_reg;
	reg [1151:0] data_tx;	
	wire [191:0] data_out_decoder[0:5];
	wire [5:0] done_encoder;
	reg  start_decoder;
	reg [2303:0] data_in_modulation;
	reg [383:0] data_in_decoder[0:5];
	wire done_state;
	wire [2047:0]data_real_quantum[0:5],data_imag_quantum[0:5];
	reg [2047:0]data_real_out_temp,data_imag_out_temp;
	wire [2047:0]data_imag[0:5],data_real[0:5];
	wire [2047:0]data_real_out,data_imag_out;
	reg [2047:0] data_real_ex,data_imag_ex;
	reg [2047:0]data_real_demodulation[0:5],data_imag_demodulation[0:5];
	reg [2047:0] data_buffer_ex_real[0:5];
	reg [2047:0] data_buffer_ex_imag[0:5];
	reg [2:0] count_ex,count_ex_next ;
	reg [2:0] count_deco;
	reg [2:0] count_state_ex;
	reg [15:0]counter_rx,count_send,counter_hold;
	reg [1151:0] data_buffer,data_check;
//	assign data_out = data_out_reg;
	reg [31:0] sys,sys_reg;
	reg flag,flag1,flag2,flag3;
	uart_rx #(50000000, 115200)
		receive_0	(
			.clk(clk),
			.rst(reset),
			.rx(rx),
			.rx_done(done_receive),
			.rx_out(data_rx),// 8 bit 
			.enable(start_rx)
		);
	genvar i_0;
    generate
		for(i_0 = 0;i_0 < 6;i_0 = i_0 + 1) begin : encoder
			top_encoder encoder(
				.clk(clk),
				.reset(reset),
				.start(start_encoder),
				.m_text(data_in_encoder[192*i_0 +:192]),
				.encoder(data_out_encoder[384*i_0 +:384]),
				.done(done_encoder[i_0])
			);
		end
	endgenerate
	
	genvar i_1;
	generate
		for(i_1 = 0;i_1 < 6;i_1 = i_1 + 1) begin : modulation
			QAM_64 modulation(
				.data_in(data_in_modulation[384*i_1 +:384]),
				.data_real(data_real[i_1]),
				.data_imag(data_imag[i_1])
			);
		end
	endgenerate
	
	FFT_IFFT u2(
		.clk(clk),
		.reset(reset),
		.start(start_ifft_fft),
		.done(done_ifft_fft),
		.input_real(data_real_ex),
		.input_imag(data_imag_ex),
		.real_out_fft(data_real_out),
		.imag_out_fft(data_imag_out),
		.done_state(done_state),
		.busy_in(busy_in)
	);
	genvar i_4;
	generate
        for(i_4 = 0;i_4 < 6;i_4 = i_4 + 1) begin : quantum
            top_quantum ux(
                .data_real(data_buffer_ex_real[i_4]),
                .data_imag(data_buffer_ex_imag[i_4]),
                .out_real(data_real_quantum[i_4]),
                .out_imag(data_imag_quantum[i_4])
            );
        end
	endgenerate
	genvar i_2;
	generate
		for(i_2 = 0;i_2 < 6;i_2 = i_2 + 1) begin : demodulation
            DEQAM_64 u3(
                .data_real_in(data_real_demodulation[i_2]),
                .data_imag_in(data_imag_demodulation[i_2]),
                .data_out(data_out_demodulation[i_2])
            );
        end
    endgenerate
	uart_tx #(50000000,115200)
		send_0 (
			.clk(clk),
			.rst(reset),
			.enable(start_tx),
			.data_in(data_tx),
			.busy_tx(done_send),
			.tx(tx)
		);
	
	genvar i_3;
	generate
		for(i_3 = 0;i_3 < 6;i_3 = i_3 + 1) begin : decode
			viterbi_decoder decode(
				.clk(clk),
				.reset(reset),
				.start(start_decoder ),
				.code_in(data_out_demodulation[i_3]),
				.data_out(data_out_decoder[i_3]),
				.done(done_decoder[i_3])
			);
		end
	endgenerate
	check_BER #(1152)
	   check0(
	   .a(data_in_encoder),
	   .b(data_check),
	   .diff_count(num)
	);
	always @(posedge clk or negedge reset)begin
	   if(!reset)begin
	       state <=  START;
	       counter_rx <= 0;
	       busy  <= 0;
	       data_buffer <= 'd0;
	       start_rx   <= 0;
	       start_encoder	<= 0;
	       data_in_encoder <= 0;
	       data_in_modulation <= 0;
	       start_ifft_fft     <= 0;
	       count_ex <= 0;
	       flag <= 0;
	       flag1 <= 0;
	       flag2 <= 0;
	       flag3 <= 0;
	       count_deco <= 0;
	       count_state_ex <= 0;
	       start_decoder <= 0;
	       data_real_ex <= 0;
	       data_imag_ex <= 0;
	       count_ex_next <= 0;
	       counter_hold <= 0;
	       busy_in <= 0;
	       data_check <= 0;
	   end else begin
	       case(state)
	           START:begin
	               if(start)begin
	                  state <= RECEIVE ;
	                  //start_encoder <= 1;
	                  busy <= 1; 
	                  start_rx   <= 1;
	                  busy_in <= 1;
	                
	               end else begin
	                   state <= START;
	                   busy <= 0;
	                   busy_in <= 0;
	               end
	           end
	           RECEIVE:begin
                   if(counter_rx!=0)begin
                        case(counter_rx)
                        16'd144	:	data_buffer[7:0]     = data_rx;
						16'd143	:	data_buffer[15:8]    = data_rx;
						16'd142	:	data_buffer[23:16]   = data_rx;
						16'd141	:	data_buffer[31:24]   = data_rx;
						16'd140	:	data_buffer[39:32]   = data_rx;
						16'd139	:	data_buffer[47:40]   = data_rx;
						16'd138	:	data_buffer[55:48]   = data_rx;
						16'd137	:	data_buffer[63:56]   = data_rx;
						16'd136	:	data_buffer[71:64]   = data_rx;
						16'd135	:	data_buffer[79:72]   = data_rx;
						16'd134	:	data_buffer[87:80]   = data_rx;
						16'd133	:	data_buffer[95:88]   = data_rx;
						16'd132	:	data_buffer[103:96]  = data_rx;
						16'd131	:	data_buffer[111:104] = data_rx;
						16'd130	:	data_buffer[119:112] = data_rx;
						16'd129	:	data_buffer[127:120] = data_rx;
						16'd128	:	data_buffer[135:128] = data_rx;
						16'd127	:	data_buffer[143:136] = data_rx;
						16'd126	:	data_buffer[151:144] = data_rx;
						16'd125	:	data_buffer[159:152] = data_rx;
						16'd124	:	data_buffer[167:160] = data_rx;
						16'd123	:	data_buffer[175:168] = data_rx;
						16'd122	:	data_buffer[183:176] = data_rx;
						16'd121	:	data_buffer[191:184] = data_rx;
						16'd120	:	data_buffer[199:192] = data_rx;
						16'd119	:	data_buffer[207:200] = data_rx;
						16'd118	:	data_buffer[215:208] = data_rx;
						16'd117	:	data_buffer[223:216] = data_rx;
						16'd116	:	data_buffer[231:224] = data_rx;
						16'd115	:	data_buffer[239:232] = data_rx;
						16'd114	:	data_buffer[247:240] = data_rx;
						16'd113	:	data_buffer[255:248] = data_rx;
						16'd112	:	data_buffer[263:256] = data_rx;
						16'd111	:	data_buffer[271:264] = data_rx;
						16'd110	:	data_buffer[279:272] = data_rx;
						16'd109	:	data_buffer[287:280] = data_rx;
						16'd108	:	data_buffer[295:288] = data_rx;
						16'd107	:	data_buffer[303:296] = data_rx;
						16'd106	:	data_buffer[311:304] = data_rx;
						16'd105	:	data_buffer[319:312] = data_rx;
						16'd104	:	data_buffer[327:320] = data_rx;
						16'd103	:	data_buffer[335:328] = data_rx;
						16'd102	:	data_buffer[343:336] = data_rx;
						16'd101	:	data_buffer[351:344] = data_rx;
						16'd100	:	data_buffer[359:352] = data_rx;
						16'd99	:	data_buffer[367:360]  = data_rx;
						16'd98	:	data_buffer[375:368]  = data_rx;
						16'd97	:	data_buffer[383:376]  = data_rx;
						16'd96	:	data_buffer[391:384]  = data_rx;
						16'd95	:	data_buffer[399:392]  = data_rx;
						16'd94	:	data_buffer[407:400]  = data_rx;
						16'd93	:	data_buffer[415:408]  = data_rx;
						16'd92	:	data_buffer[423:416]  = data_rx;
						16'd91	:	data_buffer[431:424]  = data_rx;
						16'd90	:	data_buffer[439:432]  = data_rx;
						16'd89	:	data_buffer[447:440]  = data_rx;
						16'd88	:	data_buffer[455:448]  = data_rx;
						16'd87	:	data_buffer[463:456]  = data_rx;
						16'd86	:	data_buffer[471:464]  = data_rx;
						16'd85	:	data_buffer[479:472]  = data_rx;
						16'd84	:	data_buffer[487:480]  = data_rx;
						16'd83	:	data_buffer[495:488]  = data_rx;
						16'd82	:	data_buffer[503:496]  = data_rx;
						16'd81	:	data_buffer[511:504]  = data_rx;
						16'd80	:	data_buffer[519:512]  = data_rx;
						16'd79	:	data_buffer[527:520]  = data_rx;
						16'd78	:	data_buffer[535:528]  = data_rx;
						16'd77	:	data_buffer[543:536]  = data_rx;
						16'd76	:	data_buffer[551:544]  = data_rx;
						16'd75	:	data_buffer[559:552]  = data_rx;
						16'd74	:	data_buffer[567:560]  = data_rx;
						16'd73	:	data_buffer[575:568]  = data_rx;
						16'd72	:	data_buffer[583:576]  = data_rx;
						16'd71	:	data_buffer[591:584]  = data_rx;
						16'd70	:	data_buffer[599:592]  = data_rx;
						16'd69	:	data_buffer[607:600]  = data_rx;
						16'd68	:	data_buffer[615:608]  = data_rx;
						16'd67	:	data_buffer[623:616]  = data_rx;
						16'd66	:	data_buffer[631:624]  = data_rx;
						16'd65	:	data_buffer[639:632]  = data_rx;
						16'd64	:	data_buffer[647:640]  = data_rx;
						16'd63	:	data_buffer[655:648]  = data_rx;
						16'd62	:	data_buffer[663:656]  = data_rx;
						16'd61	:	data_buffer[671:664]  = data_rx;
						16'd60	:	data_buffer[679:672]  = data_rx;
						16'd59	:	data_buffer[687:680]  = data_rx;
						16'd58	:	data_buffer[695:688]  = data_rx;
						16'd57	:	data_buffer[703:696]  = data_rx;
						16'd56	:	data_buffer[711:704]  = data_rx;
						16'd55	:	data_buffer[719:712]  = data_rx;
						16'd54	:	data_buffer[727:720]  = data_rx;
						16'd53	:	data_buffer[735:728]  = data_rx;
						16'd52	:	data_buffer[743:736]  = data_rx;
						16'd51	:	data_buffer[751:744]  = data_rx;
						16'd50	:	data_buffer[759:752]  = data_rx;
						16'd49	:	data_buffer[767:760]  = data_rx;
						16'd48	:	data_buffer[775:768]  = data_rx;
						16'd47	:	data_buffer[783:776]  = data_rx;
						16'd46	:	data_buffer[791:784]  = data_rx;
						16'd45	:	data_buffer[799:792]  = data_rx;
						16'd44	:	data_buffer[807:800]  = data_rx;
						16'd43	:	data_buffer[815:808]  = data_rx;
						16'd42	:	data_buffer[823:816]  = data_rx;
						16'd41	:	data_buffer[831:824]  = data_rx;
						16'd40	:	data_buffer[839:832]  = data_rx;
						16'd39	:	data_buffer[847:840]  = data_rx;
						16'd38	:	data_buffer[855:848]  = data_rx;
						16'd37	:	data_buffer[863:856]  = data_rx;
						16'd36	:	data_buffer[871:864]  = data_rx;
						16'd35	:	data_buffer[879:872]  = data_rx;
						16'd34	:	data_buffer[887:880]  = data_rx;
						16'd33	:	data_buffer[895:888]  = data_rx;
						16'd32	:	data_buffer[903:896]  = data_rx;
						16'd31	:	data_buffer[911:904]  = data_rx;
						16'd30	:	data_buffer[919:912]  = data_rx;
						16'd29	:	data_buffer[927:920]  = data_rx;
						16'd28	:	data_buffer[935:928]  = data_rx;
						16'd27	:	data_buffer[943:936]  = data_rx;
						16'd26	:	data_buffer[951:944]  = data_rx;
						16'd25	:	data_buffer[959:952]  = data_rx;
						16'd24	:	data_buffer[967:960]  = data_rx;
						16'd23	:	data_buffer[975:968]  = data_rx;
						16'd22	:	data_buffer[983:976]  = data_rx;
						16'd21	:	data_buffer[991:984]  = data_rx;
						16'd20	:	data_buffer[999:992]  = data_rx;
						16'd19	:	data_buffer[1007:1000]= data_rx;
						16'd18	:	data_buffer[1015:1008]= data_rx;
						16'd17	:	data_buffer[1023:1016]= data_rx;
						16'd16	:	data_buffer[1031:1024]= data_rx;
						16'd15	:	data_buffer[1039:1032]= data_rx;
						16'd14	:	data_buffer[1047:1040]= data_rx;
						16'd13	:	data_buffer[1055:1048]= data_rx;
						16'd12	:	data_buffer[1063:1056]= data_rx;
						16'd11	:	data_buffer[1071:1064]= data_rx;
						16'd10	:	data_buffer[1079:1072]= data_rx;
						16'd9	:	data_buffer[1087:1080]= data_rx;
						16'd8	:	data_buffer[1095:1088]= data_rx;
						16'd7	:	data_buffer[1103:1096]= data_rx;
						16'd6	:	data_buffer[1111:1104]= data_rx;
						16'd5	:	data_buffer[1119:1112]= data_rx;
						16'd4	:	data_buffer[1127:1120]= data_rx;
						16'd3	:	data_buffer[1135:1128]= data_rx;
						16'd2	:	data_buffer[1143:1136]= data_rx;
						16'd1	:	data_buffer[1151:1144]= data_rx;
                        endcase
                   end
                    if(counter_rx != 16'd144)begin
                        if(done_receive)begin
                            counter_rx <= counter_rx + 16'd1;
                        end 
                    end else begin
                        counter_rx <= 16'd0;
                        state      <= HOLD;
                        start_rx   <= 0;
                         
                    end
	           end
	           ENCODE:begin
	           //  start_encoder <= 0; 
			 // data_in_encoder <= 'he5c1448e7229128bb6cc511651d7e45c97ba74aad8868099eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeddddddddddddddddddddddddddddddddddddddddddddddddccccccccccccccccccccccccccccccccccccccccccccccccbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa;
				  if(done_encoder[0])begin
				        start_encoder	<= 0;
					    state 		<= MODULA; 
					   // data_in_modulation <= data_out_encoder;
				   end 
	           end
	           HOLD:begin
	               	  start_encoder <= 1;
			          data_in_encoder <= data_buffer;
			          state <= ENCODE;
	              /* if(counter_hold == 4)begin
	                   counter_hold <= 0;
	                //   data_in_modulation <= data_out_encoder;
	                   state <= MODULA;
	               end else begin
	                   counter_hold <= counter_hold+1; 
	               end*/
	           end
	           MODULA: begin
                    state		       <= EX;
                    data_in_modulation <= data_out_encoder;
                 //   start_ifft_fft     <= 1;
			   end
			   EX:begin
                    start_ifft_fft <= 1;
                   // data_real_ex <= data_real[0];
                   // data_imag_ex <= data_imag[0];
                    if(count_state_ex != 6)begin
                        if(count_ex == 0)begin
                            count_ex <= 3;
                            data_real_ex <= data_real[count_state_ex];
                            data_imag_ex <= data_imag[count_state_ex];
                            count_state_ex <= count_state_ex + 1;
                        end else begin
                            count_ex <= count_ex - 1;
                        end
                    end   
                    if(done_ifft_fft)begin
                        flag1 <= 1;
                        start_ifft_fft <= 0;
                    end
                    if(done_state)begin
                        flag3 <= 1;
                    end
                    if(flag1&&flag3)begin
                        flag1 <= 1;
                        flag2 <= 1;
                        flag3 <= 0;
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
                    if(flag2)begin
                        if(count_deco!=6)begin
                            flag2 <= 0;
                            data_buffer_ex_real[count_deco] <= data_real_out_temp;
                            data_buffer_ex_imag[count_deco] <= data_imag_out_temp;
                            count_deco <= count_deco + 1;
                        end else begin
                            count_deco <= 0;
                            state <= DEMODU;
                            busy_in <= 0;
                        end
                    end
 
			   end
			   DEMODU:begin
			     state <= DECODE;
			     //start_ifft_fft <= 0;
			      
			     data_real_demodulation[0]<=data_real_quantum[0];
			     data_imag_demodulation[0]<=data_imag_quantum[0];
			     data_real_demodulation[1]<=data_real_quantum[1];
			     data_imag_demodulation[1]<=data_imag_quantum[1];
			     data_real_demodulation[2]<=data_real_quantum[2];
			     data_imag_demodulation[2]<=data_imag_quantum[2];
			     data_real_demodulation[3]<=data_real_quantum[3];
			     data_imag_demodulation[3]<=data_imag_quantum[3];
			     data_real_demodulation[4]<=data_real_quantum[4];
			     data_imag_demodulation[4]<=data_imag_quantum[4];
			     data_real_demodulation[5]<=data_real_quantum[5];
			     data_imag_demodulation[5]<=data_imag_quantum[5];
			   end
			   DECODE: begin
			    start_decoder <= 1;
			    data_in_decoder[0] <= data_out_demodulation[0];
			    data_in_decoder[1] <= data_out_demodulation[1];
			    data_in_decoder[2] <= data_out_demodulation[2];
			    data_in_decoder[3] <= data_out_demodulation[3];
			    data_in_decoder[4] <= data_out_demodulation[4];
			    data_in_decoder[5] <= data_out_demodulation[5];
			     if(done_decoder[0])begin
			         data_tx <= {data_out_decoder[0],data_out_decoder[1],data_out_decoder[2],data_out_decoder[3],data_out_decoder[4],data_out_decoder[5]};
			         state   <= SEND;
			         start_tx <= 1;
			         data_check <= {data_out_decoder[5],data_out_decoder[4],data_out_decoder[3],data_out_decoder[2],data_out_decoder[1],data_out_decoder[0]};
			         start_decoder <= 0;
			     end
			   end
			   SEND: begin
	       state <=  START;
	       counter_rx <= 0;
	       busy  <= 0;
	       data_buffer <= 'd0;
	       start_rx   <= 0;
	       start_encoder	<= 0;
	   //   data_in_encoder <= 0;
	       data_in_modulation <= 0;
	       start_ifft_fft     <= 0;
	       count_ex <= 0;
	       flag <= 0;
	       flag1 <= 0;
	       flag2 <= 0;
	       flag3 <= 0;
	       count_deco <= 0;
	       count_state_ex <= 0;
	       start_decoder <= 0;
	       data_real_ex <= 0;
	       data_imag_ex <= 0;
	       count_ex_next <= 0;
	       counter_hold <= 0;
	       busy_in <= 0;
	       data_check <= 0;
			      //      end
			   end
	       endcase 
	   end
	end 
                        
endmodule
	 
	 
	 
	 
	 
	 
	 
	 