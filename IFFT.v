module IFFT(
	input clk,reset,start,
	input enable_fft_ifft, // 1 ifft , 0 fft 
	output reg busy,data_ready,
	input [2047:0] input_real,
	input [2047:0] input_imag,
	output [2047:0] real_out,imag_out
);	
wire [31:0] real_temp [0:63];
wire [31:0] imag_temp [0:63];	
		parameter 	IDLE    = 8'd0,
					START   = 8'd1,
					STATE_1 = 8'd2,
					STATE_2 = 8'd3,
					STATE_3 = 8'd4,
					STATE_4 = 8'd5,
					STATE_5 = 8'd6,
					STATE_6 = 8'd7,
					DONE    = 8'd8;
	reg temp_real,data_ready_next;
	wire [31:0] parameter_div = (enable_fft_ifft)?32'b01000010100000000000000000000000:32'b00111111100000000000000000000000;
	wire [31:0] result_state_1 [0:31];
	wire [31:0] result_state_2 [0:31]; 
	wire [31:0] result_state_3 [0:31]; 
	wire [31:0] result_state_4 [0:31];
	wire [31:0] result_state_5 [0:31];
	wire [31:0] result_state_6 [0:31]; 	
	
	reg  [31:0]line_out_real[0:63];
	reg  [31:0]line_out_imag[0:63];
	reg  [31:0]line_2_real[0:63];
	reg  [31:0]line_2_imag[0:63];
	reg  [31:0]line_3_real[0:63];
	reg  [31:0]line_3_imag[0:63];
	reg  [31:0]line_4_real[0:63];
	reg  [31:0]line_4_imag[0:63];
	reg  [31:0]line_5_real[0:63];
	reg  [31:0]line_5_imag[0:63];
	reg  [31:0]line_6_real[0:63];
	reg  [31:0]line_6_imag[0:63];
	
	reg  [31:0]line_out_real_temp[0:63];
	reg  [31:0]line_out_imag_temp[0:63];
	reg  [31:0]line_2_real_temp[0:63];
	reg  [31:0]line_2_imag_temp[0:63];
	reg  [31:0]line_3_real_temp[0:63];
	reg  [31:0]line_3_imag_temp[0:63];
	reg  [31:0]line_4_real_temp[0:63];
	reg  [31:0]line_4_imag_temp[0:63];
	reg  [31:0]line_5_real_temp[0:63];
	reg  [31:0]line_5_imag_temp[0:63];
	reg  [31:0]line_6_real_temp[0:63];
	reg  [31:0]line_6_imag_temp[0:63];
	
	reg [31:0]w_real[0:31];
	reg [31:0]w_imag[0:31];
	reg [31:0]w_6_real [0:31];
	reg [31:0]w_6_imag [0:31];
	reg [7:0] state,next_state;
	reg [7:0] counter_state,next_counter_state;
	reg [1:0] flag,next_flag; 
assign real_out = (flag == 2'b11)?{ 
    real_temp[0],  real_temp[32],  real_temp[16],  real_temp[48],  real_temp[8],  real_temp[40],  real_temp[24],  real_temp[56],
    real_temp[4],  real_temp[36],  real_temp[20], real_temp[52], real_temp[12], real_temp[44], real_temp[28], real_temp[60],
    real_temp[2], real_temp[34], real_temp[18], real_temp[50], real_temp[10], real_temp[42], real_temp[26], real_temp[58],
    real_temp[6], real_temp[38], real_temp[22], real_temp[54], real_temp[14], real_temp[46], real_temp[30], real_temp[62],
   
    real_temp[1], real_temp[33], real_temp[17], real_temp[49], real_temp[9], real_temp[41], real_temp[25], real_temp[57],
    real_temp[5], real_temp[37], real_temp[21], real_temp[53], real_temp[13], real_temp[45], real_temp[29], real_temp[61],
    real_temp[3], real_temp[35], real_temp[19], real_temp[51], real_temp[11], real_temp[43], real_temp[27], real_temp[59],
    real_temp[7], real_temp[39], real_temp[23], real_temp[55], real_temp[15], real_temp[47], real_temp[31], real_temp[63]
}:real_out;

assign imag_out = (flag == 2'b11)?{ 
	imag_temp[0],  imag_temp[32],  imag_temp[16],  imag_temp[48],  imag_temp[8],  imag_temp[40],  imag_temp[24],  imag_temp[56],
    imag_temp[4],  imag_temp[36],  imag_temp[20], imag_temp[52], imag_temp[12], imag_temp[44], imag_temp[28], imag_temp[60],
    imag_temp[2], imag_temp[34], imag_temp[18], imag_temp[50], imag_temp[10], imag_temp[42], imag_temp[26], imag_temp[58],
    imag_temp[6], imag_temp[38], imag_temp[22], imag_temp[54], imag_temp[14], imag_temp[46], imag_temp[30], imag_temp[62],
   
    imag_temp[1], imag_temp[33], imag_temp[17], imag_temp[49], imag_temp[9], imag_temp[41], imag_temp[25], imag_temp[57],
    imag_temp[5], imag_temp[37], imag_temp[21], imag_temp[53], imag_temp[13], imag_temp[45], imag_temp[29], imag_temp[61],
    imag_temp[3], imag_temp[35], imag_temp[19], imag_temp[51], imag_temp[11], imag_temp[43], imag_temp[27], imag_temp[59],
    imag_temp[7], imag_temp[39], imag_temp[23], imag_temp[55], imag_temp[15], imag_temp[47], imag_temp[31], imag_temp[63]
}:imag_out;

	
	
	
	genvar a_div;
	generate
		for(a_div=0;a_div<64;a_div = a_div +1)begin :  div_state_imag
			floating_point_div DIV_real(
				.a(line_out_imag[a_div]),
				.b(parameter_div),
				.result(imag_temp[a_div])
			);
			floating_point_div DIV_imag(
				.a(line_out_real[a_div]),
				.b(parameter_div),
				.result(real_temp[a_div])
			);
		end
	endgenerate
	integer i;
	//state_1
	genvar i_0;
	generate
		for(i_0=31;i_0>=0;i_0 = i_0-1) begin: state_1
			DFT_2 DFT_2_inst(
				.flag(flag),
				.a2_res(input_real[32*i_0 +: 32]),
				.b2_im(input_imag[32*i_0 +: 32]),
				.a1_res(input_real[32*(i_0+32) +: 32]),
				.b1_im(input_imag[32*(i_0+32) +: 32]),
				.w_res(w_real[0]),
				.w_im(w_imag[0]),
				.result(result_state_1[i_0])
				
			);
		end
	endgenerate
	//state_2
	genvar j,x;
	generate
		for(j=0;j<16;j = j+1) begin: state_2_0
			DFT_2 DFT_2_inst(
				.flag(flag),
				.a2_res(line_2_real_temp[j]),
				.b2_im(line_2_imag_temp[j]),
				.a1_res(line_2_real_temp[j+16]),
				.b1_im(line_2_imag_temp[j+16]),
				.w_res(w_real[0]),
				.w_im(w_imag[0]),
				.result(result_state_2[j])
				
			);
		end
		
		for(x=32;x<48;x = x+1) begin: state_2_1
			DFT_2 DFT_2_inst(
				.flag(flag),
				.a2_res(line_2_real_temp[x]),
				.b2_im(line_2_imag_temp[x]),
				.a1_res(line_2_real_temp[x+16]),
				.b1_im(line_2_imag_temp[x+16]),
				.w_res(w_real[16]),
				.w_im(w_imag[16]),
				.result(result_state_2[x-16])
			);
		end
	endgenerate
	//state_3
	genvar a,b,c,d;
	generate
		for(a=0;a<8;a = a + 1) begin: state_3_0
			DFT_2 DFT_2_inst(
				.flag(flag),
				.a2_res(line_3_real_temp[a]),
				.b2_im(line_3_imag_temp[a]),
				.a1_res(line_3_real_temp[a+8]),
				.b1_im(line_3_imag_temp[a+8]),
				.w_res(w_real[0]),
				.w_im(w_imag[0]),
				.result(result_state_3[a])
				
			);
		end
		
		for(b=16;b<24;b = b + 1) begin: state_3_1
			DFT_2 DFT_2_inst(
				.flag(flag),
				.a2_res(line_3_real_temp[b]),
				.b2_im(line_3_imag_temp[b]),
				.a1_res(line_3_real_temp[b+8]),
				.b1_im(line_3_imag_temp[b+8]),
				.w_res(w_real[16]),
				.w_im(w_imag[16]),
				.result(result_state_3[b-8])
			);
		end
		
		for(c=32;c<40;c = c + 1) begin: state_3_2
			DFT_2 DFT_2_inst(
				.flag(flag),
				.a2_res(line_3_real_temp[c]),
				.b2_im(line_3_imag_temp[c]),
				.a1_res(line_3_real_temp[c+8]),
				.b1_im(line_3_imag_temp[c+8]),
				.w_res(w_real[8]),
				.w_im(w_imag[8]),
				.result(result_state_3[c-16])
			);
		end
		
		for(d=48;d<56;d = d + 1) begin: state_3_3
			DFT_2 DFT_2_inst(
				.flag(flag),
				.a2_res(line_3_real_temp[d]),
				.b2_im(line_3_imag_temp[d]),
				.a1_res(line_3_real_temp[d+8]),
				.b1_im(line_3_imag_temp[d+8]),
				.w_res(w_real[24]),
				.w_im(w_imag[24]),
				.result(result_state_3[d-24])
			);
		end	 
	endgenerate
	//state_4
	genvar e,f,g,h,o,k,m,n;
	generate
		for(e=0;e<4;e = e + 1) begin: state_4_0
			DFT_2 DFT_2_inst(
				.flag(flag),
				.a2_res(line_4_real_temp[e]),
				.b2_im(line_4_imag_temp[e]),
				.a1_res(line_4_real_temp[e+4]),
				.b1_im(line_4_imag_temp[e+4]),
				.w_res(w_real[0]),
				.w_im(w_imag[0]),
				.result(result_state_4[e])//1->4
				
			);
		end
		
		for(f=8;f<12;f = f + 1) begin: state_4_1
			DFT_2 DFT_2_inst(
				.flag(flag),
				.a2_res(line_4_real_temp[f]),
				.b2_im(line_4_imag_temp[f]),
				.a1_res(line_4_real_temp[f+4]),
				.b1_im(line_4_imag_temp[f+4]),
				.w_res(w_real[16]),
				.w_im(w_imag[16]),
				.result(result_state_4[f-4])//5->8
			);
		end
		
		for(g=16;g<20;g = g + 1) begin: state_4_2
			DFT_2 DFT_2_inst(
				.flag(flag),
				.a2_res(line_4_real_temp[g]),
				.b2_im(line_4_imag_temp[g]),
				.a1_res(line_4_real_temp[g+4]),
				.b1_im(line_4_imag_temp[g+4]),
				.w_res(w_real[8]),
				.w_im(w_imag[8]),
				.result(result_state_4[g-8])//8->12
			);
		end
		
		for(h=24;h<28;h = h + 1) begin: state_4_3
			DFT_2 DFT_2_inst(
				.flag(flag),
				.a2_res(line_4_real_temp[h]),
				.b2_im(line_4_imag_temp[h]),
				.a1_res(line_4_real_temp[h+4]),
				.b1_im(line_4_imag_temp[h+4]),
				.w_res(w_real[24]),
				.w_im(w_imag[24]),
				.result(result_state_4[h-12])//12->16
			);
		end
		//
		for(o=32;o<36;o = o + 1) begin: state_4_4
			DFT_2 DFT_2_inst(
				.flag(flag),
				.a2_res(line_4_real_temp[o]),
				.b2_im(line_4_imag_temp[o]),
				.a1_res(line_4_real_temp[o+4]),
				.b1_im(line_4_imag_temp[o+4]),
				.w_res(w_real[4]),
				.w_im(w_imag[4]),
				.result(result_state_4[o-16])//16->20
				
			);
		end
		
		for(k=40;k<44;k = k + 1) begin: state_4_5
			DFT_2 DFT_2_inst(
				.flag(flag),
				.a2_res(line_4_real_temp[k]),
				.b2_im(line_4_imag_temp[k]),
				.a1_res(line_4_real_temp[k+4]),
				.b1_im(line_4_imag_temp[k+4]),
				.w_res(w_real[20]),
				.w_im(w_imag[20]),
				.result(result_state_4[k-20])//20->24
			);
		end
		
		for(m=48;m<52;m = m + 1) begin: state_4_6
			DFT_2 DFT_2_inst(
				.flag(flag),
				.a2_res(line_4_real_temp[m]),
				.b2_im(line_4_imag_temp[m]),
				.a1_res(line_4_real_temp[m+4]),
				.b1_im(line_4_imag_temp[m+4]),
				.w_res(w_real[12]),
				.w_im(w_imag[12]),
				.result(result_state_4[m-24])//24->28
			);
		end
		
		for(n=56;n<60;n = n + 1) begin: state_4_7
			DFT_2 DFT_2_inst(
				.flag(flag),
				.a2_res(line_4_real_temp[n]),
				.b2_im(line_4_imag_temp[n]),
				.a1_res(line_4_real_temp[n+4]),
				.b1_im(line_4_imag_temp[n+4]),
				.w_res(w_real[28]),
				.w_im(w_imag[28]),
				.result(result_state_4[n-28])//28->32
			);
		end
		
	endgenerate
	
	// state_5
	 genvar a_0,a_1,a_2,a_3,a_4,a_5,a_6,a_7,a_8,a_9,a_10,a_11,a_12,a_13,a_14,a_15;
	generate
		 for(a_0=0;a_0<2;a_0 = a_0 + 1) begin: state_5_0
			DFT_2 DFT_2_inst(
				.flag(flag),
				.a2_res(line_5_real_temp[a_0]),
				.b2_im(line_5_imag_temp[a_0]),
				.a1_res(line_5_real_temp[a_0+2]),
				.b1_im(line_5_imag_temp[a_0+2]),
				.w_res(w_real[0]),
				.w_im(w_imag[0]),
				.result(result_state_5[a_0])//0->1
				
			);
		end
		
		for(a_1=4;a_1<6;a_1 = a_1 + 1) begin: state_5_1
			DFT_2 DFT_2_inst(
				.flag(flag),
				.a2_res(line_5_real_temp[a_1]),
				.b2_im(line_5_imag_temp[a_1]),
				.a1_res(line_5_real_temp[a_1+2]),
				.b1_im(line_5_imag_temp[a_1+2]),
				.w_res(w_real[16]),
				.w_im(w_imag[16]),
				.result(result_state_5[a_1-2])//2->3
			);
		end
		
		for(a_2=8;a_2<10;a_2 = a_2 + 1) begin: state_5_2
			DFT_2 DFT_2_inst(
				.flag(flag),
				.a2_res(line_5_real_temp[a_2]),
				.b2_im(line_5_imag_temp[a_2]),
				.a1_res(line_5_real_temp[a_2+2]),
				.b1_im(line_5_imag_temp[a_2+2]),
				.w_res(w_real[8]),
				.w_im(w_imag[8]),
				.result(result_state_5[a_2-4])//4->5
			);
		end
		
		for(a_3=12;a_3<14;a_3 = a_3 + 1) begin: state_5_3
			DFT_2 DFT_2_inst(
				.flag(flag),
				.a2_res(line_5_real_temp[a_3]),
				.b2_im(line_5_imag_temp[a_3]),
				.a1_res(line_5_real_temp[a_3+2]),
				.b1_im(line_5_imag_temp[a_3+2]),
				.w_res(w_real[24]),
				.w_im(w_imag[24]),
				.result(result_state_5[a_3-6])//6->7
			);
		end
		//
		for(a_4=16;a_4<18;a_4 = a_4 + 1) begin: state_5_4
			DFT_2 DFT_2_inst(
				.flag(flag),
				.a2_res(line_5_real_temp[a_4]),
				.b2_im(line_5_imag_temp[a_4]),
				.a1_res(line_5_real_temp[a_4+2]),
				.b1_im(line_5_imag_temp[a_4+2]),
				.w_res(w_real[4]),
				.w_im(w_imag[4]),
				.result(result_state_5[a_4-8])//8->9
				
			);
		end
		
		for(a_5=20;a_5<22;a_5 = a_5 + 1) begin: state_5_5
			DFT_2 DFT_2_inst(
				.flag(flag),
				.a2_res(line_5_real_temp[a_5]),
				.b2_im(line_5_imag_temp[a_5]),
				.a1_res(line_5_real_temp[a_5+2]),
				.b1_im(line_5_imag_temp[a_5+2]),
				.w_res(w_real[20]),
				.w_im(w_imag[20]),
				.result(result_state_5[a_5-10])//10->11
			);
		end
		
		for(a_6=24;a_6<26;a_6 = a_6 + 1) begin: state_5_6
			DFT_2 DFT_2_inst(
				.flag(flag),
				.a2_res(line_5_real_temp[a_6]),
				.b2_im(line_5_imag_temp[a_6]),
				.a1_res(line_5_real_temp[a_6+2]),
				.b1_im(line_5_imag_temp[a_6+2]),
				.w_res(w_real[12]),
				.w_im(w_imag[12]),
				.result(result_state_5[a_6-12])//12->13
			);
		end
		
		for(a_7=28;a_7<30;a_7 = a_7 + 1) begin: state_5_7
			DFT_2 DFT_2_inst(
				.flag(flag),
				.a2_res(line_5_real_temp[a_7]),
				.b2_im(line_5_imag_temp[a_7]),
				.a1_res(line_5_real_temp[a_7+2]),
				.b1_im(line_5_imag_temp[a_7+2]),
				.w_res(w_real[28]),
				.w_im(w_imag[28]),
				.result(result_state_5[a_7-14])//14->15
			);
		end
		
		for(a_8=32;a_8<34;a_8 = a_8 + 1) begin: state_5_8
			DFT_2 DFT_2_inst(
				.flag(flag),
				.a2_res(line_5_real_temp[a_8]),
				.b2_im(line_5_imag_temp[a_8]),
				.a1_res(line_5_real_temp[a_8+2]),
				.b1_im(line_5_imag_temp[a_8+2]),
				.w_res(w_real[2]),
				.w_im(w_imag[2]),
				.result(result_state_5[a_8-16])//16->17
				
			);
		end
		
		for(a_9=36;a_9<38;a_9 = a_9 + 1) begin: state_5_9
			DFT_2 DFT_2_inst(
				.flag(flag),
				.a2_res(line_5_real_temp[a_9]),
				.b2_im(line_5_imag_temp[a_9]),
				.a1_res(line_5_real_temp[a_9+2]),
				.b1_im(line_5_imag_temp[a_9+2]),
				.w_res(w_real[18]),
				.w_im(w_imag[18]),
				.result(result_state_5[a_9-18])//18->19
			);
		end
		
		for(a_10=40;a_10<42;a_10 = a_10 + 1) begin: state_5_10
			DFT_2 DFT_2_inst(
				.flag(flag),
				.a2_res(line_5_real_temp[a_10]),
				.b2_im(line_5_imag_temp[a_10]),
				.a1_res(line_5_real_temp[a_10+2]),
				.b1_im(line_5_imag_temp[a_10+2]),
				.w_res(w_real[10]),
				.w_im(w_imag[10]),
				.result(result_state_5[a_10-20])//20->21
			);
		end
		
		for(a_11=44;a_11<46;a_11 = a_11 + 1) begin: state_5_11
			DFT_2 DFT_2_inst(
				.flag(flag),
				.a2_res(line_5_real_temp[a_11]),
				.b2_im(line_5_imag_temp[a_11]),
				.a1_res(line_5_real_temp[a_11+2]),
				.b1_im(line_5_imag_temp[a_11+2]),
				.w_res(w_real[26]),
				.w_im(w_imag[26]),
				.result(result_state_5[a_11-22])//22->23
			);
		end
		//
		for(a_12=48;a_12<50;a_12 = a_12 + 1) begin: state_5_12
			DFT_2 DFT_2_inst(
				.flag(flag),
				.a2_res(line_5_real_temp[a_12]),
				.b2_im(line_5_imag_temp[a_12]),
				.a1_res(line_5_real_temp[a_12+2]),
				.b1_im(line_5_imag_temp[a_12+2]),
				.w_res(w_real[6]),
				.w_im(w_imag[6]),
				.result(result_state_5[a_12-24])//24->25
				
			);
		end
		
		for(a_13=52;a_13<54;a_13 = a_13 + 1) begin: state_5_13
			DFT_2 DFT_2_inst(
				.flag(flag),
				.a2_res(line_5_real_temp[a_13]),
				.b2_im(line_5_imag_temp[a_13]),
				.a1_res(line_5_real_temp[a_13+2]),
				.b1_im(line_5_imag_temp[a_13+2]),
				.w_res(w_real[22]),
				.w_im(w_imag[22]),
				.result(result_state_5[a_13-26])//26->27
			);
		end
		
		for(a_14=56;a_14<58;a_14 = a_14 + 1) begin: state_5_14
			DFT_2 DFT_2_inst(
				.flag(flag),
				.a2_res(line_5_real_temp[a_14]),
				.b2_im(line_5_imag_temp[a_14]),
				.a1_res(line_5_real_temp[a_14+2]),
				.b1_im(line_5_imag_temp[a_14+2]),
				.w_res(w_real[14]),
				.w_im(w_imag[14]),
				.result(result_state_5[a_14-28])//28->29
			);
		end
		
		for(a_15=60;a_15<62;a_15 = a_15 + 1) begin: state_5_15
			DFT_2 DFT_2_inst(
				.flag(flag),
				.a2_res(line_5_real_temp[a_15]),
				.b2_im(line_5_imag_temp[a_15]),
				.a1_res(line_5_real_temp[a_15+2]),
				.b1_im(line_5_imag_temp[a_15+2]),
				.w_res(w_real[30]),
				.w_im(w_imag[30]),
				.result(result_state_5[a_15-30])//30->31
			);
		end
	endgenerate
	//state_6
	genvar  x_y;
	generate
		for(x_y=0;x_y<64;x_y = x_y + 2) begin: state_6
			DFT_2 DFT_2_inst(
				.flag(flag),
				.a2_res(line_6_real_temp[x_y]),
				.b2_im(line_6_imag_temp[x_y]),
				.a1_res(line_6_real_temp[x_y+1]),
				.b1_im(line_6_imag_temp[x_y+1]),
				.w_res(w_6_real[x_y/2]),
				.w_im(w_6_imag[x_y/2]),
				.result(result_state_6[x_y/2]) 
			);
		end
	endgenerate
	 
	initial begin
		
		w_real[0] = 32'b0011_1111_100000000000000000000000;//1.0
		w_real[1] = 32'b00111111011111101100010001101101;//0.9951847266721969
		w_real[2] = 32'b00111111011110110001010010111110;//0.9807852804032304
		w_real[3] = 32'b00111111011101001111101000001011;//0.9569403357322088
		w_real[4] = 32'b00111111011011001000001101011110;//0.9238795325112867
		w_real[5] = 32'b00111111011000011100010110011000;//0.881921264348355
		w_real[6] = 32'b00111111010101001101101100110001;//0.8314696123025452
		w_real[7] = 32'b00111111010001011110010000000011;//0.773010453362737
		w_real[8] = 32'b00111111001101010000010011110011;//0.7071067811865476
		w_real[9] = 32'b00111111001000100110011110011001;//0.6343932841636455
		w_real[10] = 32'b00111111000011100011100111011010;//0.5555702330196023
		w_real[11] = 32'b00111110111100010101101011101010;//0.4713967368259978
		w_real[12] = 32'b00111110110000111110111100010101;//0.38268343236508984
		w_real[13] = 32'b00111110100101001010000000110001;//0.29028467725446233
		w_real[14] = 32'b00111110010001111100010111000010;//0.19509032201612833
		w_real[15] = 32'b00111101110010001011110100110110;//0.09801714032956077
		w_real[16] = 32'b00100100100011010011000100110010;//6.123233995736766e-17
		w_real[17] = 32'b10111101110010001011110100110110;//-0.09801714032956065
		w_real[18] = 32'b10111110010001111100010111000010;//-0.1950903220161282
		w_real[19] = 32'b10111110100101001010000000110001;//-0.29028467725446216
		w_real[20] = 32'b10111110110000111110111100010101;//-0.3826834323650897
		w_real[21] = 32'b10111110111100010101101011101010;//-0.4713967368259977
		w_real[22] = 32'b10111111000011100011100111011010;//-0.555570233019602
		w_real[23] = 32'b10111111001000100110011110011001;//-0.6343932841636454
		w_real[24] = 32'b10111111001101010000010011110011;//-0.7071067811865475
		w_real[25] = 32'b10111111010001011110010000000011;//-0.773010453362737
		w_real[26] = 32'b10111111010101001101101100110001;//-0.8314696123025453
		w_real[27] = 32'b10111111011000011100010110011000;//-0.8819212643483549
		w_real[28] = 32'b10111111011011001000001101011110;//-0.9238795325112867
		w_real[29] = 32'b10111111011101001111101000001011;//-0.9569403357322088
		w_real[30] = 32'b10111111011110110001010010111110;//-0.9807852804032304
		w_real[31] = 32'b10111111011111101100010001101101;//-0.9951847266721968
		
		w_imag[0] = 32'b00000000000000000000000000000000;//0.0
		w_imag[1] = 32'b10111101110010001011110100110110;//-0.0980171403295606
		w_imag[2] = 32'b10111110010001111100010111000010;//-0.19509032201612825
		w_imag[3] = 32'b10111110100101001010000000110001;//-0.29028467725446233
		w_imag[4] = 32'b10111110110000111110111100010101;//-0.3826834323650898
		w_imag[5] = 32'b10111110111100010101101011101010;//-0.47139673682599764
		w_imag[6] = 32'b10111111000011100011100111011010;//-0.5555702330196022
		w_imag[7] = 32'b10111111001000100110011110011001;//-0.6343932841636455
		w_imag[8] = 32'b10111111001101010000010011110011;//-0.7071067811865476
		w_imag[9] = 32'b10111111010001011110010000000011;//-0.7730104533627369
		w_imag[10] = 32'b10111111010101001101101100110001;//-0.8314696123025452
		w_imag[11] = 32'b10111111011000011100010110011000;//-0.8819212643483549
		w_imag[12] = 32'b10111111011011001000001101011110;//-0.9238795325112867
		w_imag[13] = 32'b10111111011101001111101000001011;//-0.9569403357322089
		w_imag[14] = 32'b10111111011110110001010010111110;//-0.9807852804032304
		w_imag[15] = 32'b10111111011111101100010001101101;//-0.9951847266721968
		w_imag[16] = 32'b10111111100000000000000000000000;//-1.0
		w_imag[17] = 32'b10111111011111101100010001101101;//-0.9951847266721969
		w_imag[18] = 32'b10111111011110110001010010111110;//-0.9807852804032304
		w_imag[19] = 32'b10111111011101001111101000001011;//-0.9569403357322089
		w_imag[20] = 32'b10111111011011001000001101011110;//-0.9238795325112867
		w_imag[21] = 32'b10111111011000011100010110011000;//-0.881921264348355
		w_imag[22] = 32'b10111111010101001101101100110001;//-0.8314696123025453
		w_imag[23] = 32'b10111111010001011110010000000011;//-0.7730104533627371
		w_imag[24] = 32'b10111111001101010000010011110011;//-0.7071067811865476
		w_imag[25] = 32'b10111111001000100110011110011001;//-0.6343932841636455
		w_imag[26] = 32'b10111111000011100011100111011010;//-0.5555702330196022
		w_imag[27] = 32'b10111110111100010101101011101010;//-0.4713967368259978
		w_imag[28] = 32'b10111110110000111110111100010101;//-0.3826834323650899
		w_imag[29] = 32'b10111110100101001010000000110001;//-0.2902846772544624
		w_imag[30] = 32'b10111110010001111100010111000010;//-0.1950903220161286
		w_imag[31] = 32'b10111101110010001011110100110110;//-0.09801714032956083
		
		w_6_real[0] = w_real[0];
		w_6_imag[0] = w_imag[0];
		
		w_6_real[1] = w_real[16];
		w_6_imag[1] = w_imag[16];
		
		w_6_real[2] = w_real[8];
		w_6_imag[2] = w_imag[8];
		
		w_6_real[3] = w_real[24];
		w_6_imag[3] = w_imag[24];
		
		w_6_real[4] = w_real[4];
		w_6_imag[4] = w_imag[4];
		
		w_6_real[5] = w_real[20];
		w_6_imag[5] = w_imag[20];
		
		w_6_real[6] = w_real[12];
		w_6_imag[6] = w_imag[12];
		
		w_6_real[7] = w_real[28];
		w_6_imag[7] = w_imag[28];
		
		w_6_real[8] = w_real[2];
		w_6_imag[8] = w_imag[2];
		
		w_6_real[9] = w_real[18];
		w_6_imag[9] = w_imag[18];
		
		w_6_real[10] = w_real[10];
		w_6_imag[10] = w_imag[10];
		
		w_6_real[11] = w_real[26];
		w_6_imag[11] = w_imag[26];
		
		w_6_real[12] = w_real[6];
		w_6_imag[12] = w_imag[6];
		
		w_6_real[13] = w_real[22];
		w_6_imag[13] = w_imag[22];
		
		w_6_real[14] = w_real[14];
		w_6_imag[14] = w_imag[14];
		
		w_6_real[15] = w_real[30];
		w_6_imag[15] = w_imag[30];
		
		w_6_real[16] = w_real[1];
		w_6_imag[16] = w_imag[1];
		
		w_6_real[17] = w_real[17];
		w_6_imag[17] = w_imag[17];
		
		w_6_real[18] = w_real[9];
		w_6_imag[18] = w_imag[9];
		
		w_6_real[19] = w_real[25];
		w_6_imag[19] = w_imag[25];
		
		w_6_real[20] = w_real[5];
		w_6_imag[20] = w_imag[5];
		
		w_6_real[21] = w_real[21];
		w_6_imag[21] = w_imag[21];
		
		w_6_real[22] = w_real[13];
		w_6_imag[22] = w_imag[13];
		
		w_6_real[23] = w_real[29];
		w_6_imag[23] = w_imag[29];
		
		w_6_real[24] = w_real[3];
		w_6_imag[24] = w_imag[3];
		
		w_6_real[25] = w_real[19];
		w_6_imag[25] = w_imag[19];
		
		w_6_real[26] = w_real[11];
		w_6_imag[26] = w_imag[11];
		
		w_6_real[27] = w_real[27];
		w_6_imag[27] = w_imag[27];
		
		w_6_real[28] = w_real[7];
		w_6_imag[28] = w_imag[7];
		
		w_6_real[29] = w_real[23];
		w_6_imag[29] = w_imag[23];
		
		w_6_real[30] = w_real[15];
		w_6_imag[30] = w_imag[15];
		
		w_6_real[31] = w_real[31];
		w_6_imag[31] = w_imag[31];
		for (i = 0; i < 64; i = i + 1) begin
					line_2_imag_temp[i] = 0;
					line_2_real_temp[i] = 0;
					line_3_imag_temp[i] = 0;
					line_3_real_temp[i] = 0;
					line_4_imag_temp[i] = 0;
					line_4_real_temp[i] = 0;
					line_5_imag_temp[i] = 0;
					line_5_real_temp[i] = 0;
					line_6_imag_temp[i] = 0;
					line_6_real_temp[i] = 0;
					line_out_imag_temp[i] = 0;
					line_out_real_temp[i] = 0;
		end
	end
	
	always @(posedge clk or negedge reset)begin
		if(!reset)begin
			state         <= IDLE;
			counter_state <= 0;
			flag          <= 2'b00;
			data_ready    <= 0;
		end else begin
			state <= next_state;
			flag  <= next_flag;
			counter_state <= next_counter_state;
			data_ready    <= data_ready_next;
		end
	end
	
	always@(*)begin
		next_flag = flag;
		case(next_counter_state)
			8'd0: next_flag = 2'b00;
			8'd1: next_flag = 2'b01;
			8'd2: next_flag = 2'b10;
			8'd3: next_flag = 2'b11;
			default: next_flag = 2'b00;
		endcase
	end
	
	always @(*) begin
		next_state = state;
		next_counter_state = counter_state;
		data_ready_next    = data_ready;
		case(state)
			IDLE:begin
				next_state <= START;
				data_ready_next = 0;
			end
			START:begin
				if(start)begin
					next_state = STATE_1;
					data_ready_next = 0;
				end
			end
			STATE_1:begin
				data_ready_next    = 0;
				if(next_counter_state == 8'd3) begin
					next_counter_state = 0;
					next_state         = STATE_2;
					data_ready_next    = 1;
				end else begin
					next_counter_state = next_counter_state + 1;
				end
			end
			STATE_2:begin
				data_ready_next    = 0;
				if(next_counter_state == 8'd3) begin
					next_counter_state = 0;
					next_state         = STATE_3;
					data_ready_next    = 1;
				end else begin
					next_counter_state = next_counter_state + 1;
				end
			end
			STATE_3:begin
				data_ready_next    = 0;
				if(next_counter_state == 8'd3) begin
					next_counter_state = 0;
					next_state         = STATE_4;
					data_ready_next    = 1;
				end else begin
					next_counter_state = next_counter_state + 1;
				end
			end
			STATE_4:begin
				data_ready_next    = 0;
				if(next_counter_state == 8'd3) begin
					next_counter_state = 0;
					next_state         = STATE_5;
					data_ready_next    = 1;
				end else begin
					next_counter_state = next_counter_state + 1;
				end
			end
			STATE_5:begin
				data_ready_next    = 0;
				if(next_counter_state == 8'd3) begin
					next_counter_state = 0;
					next_state         = STATE_6;
					data_ready_next    = 1;
				end else begin
					next_counter_state = next_counter_state + 1;
				end
			end
			STATE_6:begin
				data_ready_next    = 0;
				if(next_counter_state == 8'd3) begin
					next_counter_state = 0;
					next_state         = STATE_1;
					data_ready_next    = 1;
				end else begin
					next_counter_state = next_counter_state + 1;
				end
			end
			DONE:begin
				    next_state         = STATE_1;
					data_ready_next    = 1;
			end
		endcase
	end
	integer i_1_0,i_1_1,i_1_2,i_1_3;
	integer i_2_0,i_2_1,i_2_2,i_2_3,i_2_4,i_2_5,i_2_6,i_2_7;
	integer i_3_0,i_3_1,i_3_2,i_3_3,i_3_4,i_3_5,i_3_6,i_3_7,i_3_8,i_3_9,i_3_10,i_3_11;
 
	always@(posedge clk)begin
		case(flag)
			 2'b00:begin
				//state1
					for (i_1_0 = 0; i_1_0 < 32; i_1_0 = i_1_0 + 1) begin
						line_2_real[i_1_0] = result_state_1[i_1_0];  
					
					end
				//state2
					for (i_2_0 = 0; i_2_0 < 16; i_2_0 = i_2_0 + 1) begin
						line_3_real[i_2_0] = result_state_2[i_2_0]; 
					end
					for (i_2_1 = 32; i_2_1 < 48; i_2_1 = i_2_1 + 1) begin
						line_3_real[i_2_1] = result_state_2[i_2_1-16]; 
					end
				//state3
					for (i_3_0 = 0; i_3_0 < 8; i_3_0 = i_3_0 + 1) begin
						line_4_real[i_3_0] = result_state_3[i_3_0]; 
					end
					for (i_3_1 = 16; i_3_1 < 24; i_3_1 = i_3_1 + 1) begin
						line_4_real[i_3_1] = result_state_3[i_3_1-8]; 
					end
					for (i_3_2 = 32; i_3_2 < 40; i_3_2 = i_3_2 + 1) begin
						line_4_real[i_3_2] = result_state_3[i_3_2-16]; 
					end
					for (i_3_3 = 48; i_3_3 < 56; i_3_3 = i_3_3 + 1) begin
						line_4_real[i_3_3] = result_state_3[i_3_3-24]; 
					end
				//state4
					for (i = 0; i < 4; i = i + 1) begin
						line_5_real[i] = result_state_4[i]; 
					end
					for (i = 8; i < 12; i = i + 1) begin
						line_5_real[i] = result_state_4[i-4]; 
					end
					for (i = 16; i < 20; i = i + 1) begin
						line_5_real[i] = result_state_4[i-8]; 
					end
					for (i = 24; i < 28; i = i + 1) begin
						line_5_real[i] = result_state_4[i-12]; 
					end
					for (i = 32; i < 36; i = i + 1) begin
						line_5_real[i] = result_state_4[i-16]; 
					end
					for (i = 40; i < 44; i = i + 1) begin
						line_5_real[i] = result_state_4[i-20]; 
					end
					for (i = 48; i < 52; i = i + 1) begin
						line_5_real[i] = result_state_4[i-24]; 
					end
					for (i = 56; i < 60; i = i + 1) begin
						line_5_real[i] = result_state_4[i-28]; 
					end
				//state5
					line_6_real[0] = result_state_5[0];
					line_6_real[1] = result_state_5[1];
					line_6_real[4] = result_state_5[2];
					line_6_real[5] = result_state_5[3];
					line_6_real[8] = result_state_5[4];
					line_6_real[9] = result_state_5[5];
					line_6_real[12] = result_state_5[6];
					line_6_real[13] = result_state_5[7];
					line_6_real[16] = result_state_5[8];
					line_6_real[17] = result_state_5[9];
					line_6_real[20] = result_state_5[10];
					line_6_real[21] = result_state_5[11];
					line_6_real[24] = result_state_5[12];
					line_6_real[25] = result_state_5[13];
					line_6_real[28] = result_state_5[14];
					line_6_real[29] = result_state_5[15];
					line_6_real[32] = result_state_5[16];
					line_6_real[33] = result_state_5[17];
					line_6_real[36] = result_state_5[18];
					line_6_real[37] = result_state_5[19];
					line_6_real[40] = result_state_5[20];
					line_6_real[41] = result_state_5[21];
					line_6_real[44] = result_state_5[22];
					line_6_real[45] = result_state_5[23];
					line_6_real[48] = result_state_5[24];
					line_6_real[49] = result_state_5[25];
					line_6_real[52] = result_state_5[26];
					line_6_real[53] = result_state_5[27];
					line_6_real[56] = result_state_5[28];
					line_6_real[57] = result_state_5[29];
					line_6_real[60] = result_state_5[30];
					line_6_real[61] = result_state_5[31];
				//state6
					line_out_real[0] = result_state_6[0];
					line_out_real[2] = result_state_6[1];
					line_out_real[4] = result_state_6[2];
					line_out_real[6] = result_state_6[3];
					line_out_real[8] = result_state_6[4];
					line_out_real[10] = result_state_6[5];
					line_out_real[12] = result_state_6[6];
					line_out_real[14] = result_state_6[7];
					line_out_real[16] = result_state_6[8];
					line_out_real[18] = result_state_6[9];
					line_out_real[20] = result_state_6[10];
					line_out_real[22] = result_state_6[11];
					line_out_real[24] = result_state_6[12];
					line_out_real[26] = result_state_6[13];
					line_out_real[28] = result_state_6[14];
					line_out_real[30] = result_state_6[15];
					line_out_real[32] = result_state_6[16];
					line_out_real[34] = result_state_6[17];
					line_out_real[36] = result_state_6[18];
					line_out_real[38] = result_state_6[19];
					line_out_real[40] = result_state_6[20];
					line_out_real[42] = result_state_6[21];
					line_out_real[44] = result_state_6[22];
					line_out_real[46] = result_state_6[23];
					line_out_real[48] = result_state_6[24];
					line_out_real[50] = result_state_6[25];
					line_out_real[52] = result_state_6[26];
					line_out_real[54] = result_state_6[27];
					line_out_real[56] = result_state_6[28];
					line_out_real[58] = result_state_6[29];
					line_out_real[60] = result_state_6[30];
					line_out_real[62] = result_state_6[31];
				end
			 2'b01:begin
				//state1
				for (i_1_1 = 0; i_1_1 < 32; i_1_1 = i_1_1 + 1) begin
						line_2_imag[i_1_1] = result_state_1[i_1_1];  
				end
				//state2
				for (i_2_2 = 0; i_2_2 < 16; i_2_2 = i_2_2 + 1) begin
						line_3_imag[i_2_2] = result_state_2[i_2_2]; 
				end
					
				for (i_2_3 = 32; i_2_3 < 48; i_2_3 = i_2_3 + 1) begin
					line_3_imag[i_2_3] = result_state_2[i_2_3-16]; 
				end
				//state3
				for (i_3_4 = 0; i_3_4 < 8; i_3_4 = i_3_4 + 1) begin
					line_4_imag[i_3_4] = result_state_3[i_3_4]; 
				end
				for (i_3_5 = 16; i_3_5 < 24; i_3_5 = i_3_5 + 1) begin
					line_4_imag[i_3_5] = result_state_3[i_3_5-8]; 
				end
				for (i_3_6 = 32; i_3_6 < 40; i_3_6 = i_3_6 + 1) begin
					line_4_imag[i_3_6] = result_state_3[i_3_6-16]; 
				end
				for (i_3_7 = 48; i_3_7 < 56; i_3_7 = i_3_7 + 1) begin
					line_4_imag[i_3_7] = result_state_3[i_3_7-24]; 
				end
				//state4
				for (i = 0; i < 4; i = i + 1) begin
					line_5_imag[i] = result_state_4[i]; 
				end
				for (i = 8; i < 12; i = i + 1) begin
					line_5_imag[i] = result_state_4[i-4]; 
				end
				for (i = 16; i < 20; i = i + 1) begin
					line_5_imag[i] = result_state_4[i-8]; 
				end
				for (i = 24; i < 28; i = i + 1) begin
					line_5_imag[i] = result_state_4[i-12]; 
				end
				for (i = 32; i < 36; i = i + 1) begin
					line_5_imag[i] = result_state_4[i-16]; 
				end
				for (i = 40; i < 44; i = i + 1) begin
					line_5_imag[i] = result_state_4[i-20]; 
				end
				for (i = 48; i < 52; i = i + 1) begin
					line_5_imag[i] = result_state_4[i-24]; 
				end
				for (i = 56; i < 60; i = i + 1) begin
					line_5_imag[i] = result_state_4[i-28]; 
				end
				//state5
					line_6_imag[0] = result_state_5[0];
					line_6_imag[1] = result_state_5[1];
					line_6_imag[4] = result_state_5[2];
					line_6_imag[5] = result_state_5[3];
					line_6_imag[8] = result_state_5[4];
					line_6_imag[9] = result_state_5[5];
					line_6_imag[12] = result_state_5[6];
					line_6_imag[13] = result_state_5[7];
					line_6_imag[16] = result_state_5[8];
					line_6_imag[17] = result_state_5[9];
					line_6_imag[20] = result_state_5[10];
					line_6_imag[21] = result_state_5[11];
					line_6_imag[24] = result_state_5[12];
					line_6_imag[25] = result_state_5[13];
					line_6_imag[28] = result_state_5[14];
					line_6_imag[29] = result_state_5[15];
					line_6_imag[32] = result_state_5[16];
					line_6_imag[33] = result_state_5[17];
					line_6_imag[36] = result_state_5[18];
					line_6_imag[37] = result_state_5[19];
					line_6_imag[40] = result_state_5[20];
					line_6_imag[41] = result_state_5[21];
					line_6_imag[44] = result_state_5[22];
					line_6_imag[45] = result_state_5[23];
					line_6_imag[48] = result_state_5[24];
					line_6_imag[49] = result_state_5[25];
					line_6_imag[52] = result_state_5[26];
					line_6_imag[53] = result_state_5[27];
					line_6_imag[56] = result_state_5[28];
					line_6_imag[57] = result_state_5[29];
					line_6_imag[60] = result_state_5[30];
					line_6_imag[61] = result_state_5[31];
				 //state6
					line_out_imag[0] = result_state_6[0];
					line_out_imag[2] = result_state_6[1];
					line_out_imag[4] = result_state_6[2];
					line_out_imag[6] = result_state_6[3];
					line_out_imag[8] = result_state_6[4];
					line_out_imag[10] = result_state_6[5];
					line_out_imag[12] = result_state_6[6];
					line_out_imag[14] = result_state_6[7];
					line_out_imag[16] = result_state_6[8];
					line_out_imag[18] = result_state_6[9];
					line_out_imag[20] = result_state_6[10];
					line_out_imag[22] = result_state_6[11];
					line_out_imag[24] = result_state_6[12];
					line_out_imag[26] = result_state_6[13];
					line_out_imag[28] = result_state_6[14];
					line_out_imag[30] = result_state_6[15];
					line_out_imag[32] = result_state_6[16];
					line_out_imag[34] = result_state_6[17];
					line_out_imag[36] = result_state_6[18];
					line_out_imag[38] = result_state_6[19];
					line_out_imag[40] = result_state_6[20];
					line_out_imag[42] = result_state_6[21];
					line_out_imag[44] = result_state_6[22];
					line_out_imag[46] = result_state_6[23];
					line_out_imag[48] = result_state_6[24];
					line_out_imag[50] = result_state_6[25];
					line_out_imag[52] = result_state_6[26];
					line_out_imag[54] = result_state_6[27];
					line_out_imag[56] = result_state_6[28];
					line_out_imag[58] = result_state_6[29];
					line_out_imag[60] = result_state_6[30];
					line_out_imag[62] = result_state_6[31];
			 end
			 2'b10:begin
			 //state1
				for (i_1_2 = 0; i_1_2 < 32; i_1_2 = i_1_2 + 1) begin
						line_2_real[i_1_2+32] = result_state_1[i_1_2];  
				end
				//state2
				for (i_2_4 = 0; i_2_4 < 16; i_2_4 = i_2_4 + 1) begin
						line_3_real[i_2_4+16] = result_state_2[i_2_4]; 
					end
					
				for (i_2_5 = 32; i_2_5 < 48; i_2_5 = i_2_5 + 1) begin
					line_3_real[i_2_5+16] = result_state_2[i_2_5-16]; 
				end
				//state3
				for (i_3_8 = 8; i_3_8 < 16; i_3_8 = i_3_8 + 1) begin
					line_4_real[i_3_8] = result_state_3[i_3_8-8]; 
				end
				for (i_3_9 = 24; i_3_9 < 32; i_3_9 = i_3_9 + 1) begin
					line_4_real[i_3_9] = result_state_3[i_3_9-16]; 
				end
				for (i_3_10 = 40; i_3_10 < 48; i_3_10 = i_3_10 + 1) begin
					line_4_real[i_3_10] = result_state_3[i_3_10-24]; 
				end
				for (i_3_11 = 56; i_3_11 < 64; i_3_11 = i_3_11 + 1) begin
					line_4_real[i_3_11] = result_state_3[i_3_11-32]; 
				end
				//state4
				for (i = 4; i < 8; i = i + 1) begin
					line_5_real[i] = result_state_4[i-4]; 
				end
				for (i = 12; i < 16; i = i + 1) begin
					line_5_real[i] = result_state_4[i-8]; 
				end
				for (i = 20; i < 24; i = i + 1) begin
					line_5_real[i] = result_state_4[i-12]; 
				end
				for (i = 28; i < 32; i = i + 1) begin
					line_5_real[i] = result_state_4[i-16]; 
				end
				for (i = 36; i < 40; i = i + 1) begin
					line_5_real[i] = result_state_4[i-20]; 
				end
				for (i = 44; i < 48; i = i + 1) begin
					line_5_real[i] = result_state_4[i-24]; 
				end
				for (i = 52; i < 56; i = i + 1) begin
					line_5_real[i] = result_state_4[i-28]; 
				end
				for (i = 60; i < 64; i = i + 1) begin
					line_5_real[i] = result_state_4[i-32]; 
				end
				//state5
					line_6_real[2] = result_state_5[0];
					line_6_real[3] = result_state_5[1];
					line_6_real[6] = result_state_5[2];
					line_6_real[7] = result_state_5[3];
					line_6_real[10] = result_state_5[4];
					line_6_real[11] = result_state_5[5];
					line_6_real[14] = result_state_5[6];
					line_6_real[15] = result_state_5[7];
					line_6_real[18] = result_state_5[8];
					line_6_real[19] = result_state_5[9];
					line_6_real[22] = result_state_5[10];
					line_6_real[23] = result_state_5[11];
					line_6_real[26] = result_state_5[12];
					line_6_real[27] = result_state_5[13];
					line_6_real[30] = result_state_5[14];
					line_6_real[31] = result_state_5[15];
					line_6_real[34] = result_state_5[16];
					line_6_real[35] = result_state_5[17];
					line_6_real[38] = result_state_5[18];
					line_6_real[39] = result_state_5[19];
					line_6_real[42] = result_state_5[20];
					line_6_real[43] = result_state_5[21];
					line_6_real[46] = result_state_5[22];
					line_6_real[47] = result_state_5[23];
					line_6_real[50] = result_state_5[24];
					line_6_real[51] = result_state_5[25];
					line_6_real[54] = result_state_5[26];
					line_6_real[55] = result_state_5[27];
					line_6_real[58] = result_state_5[28];
					line_6_real[59] = result_state_5[29];
					line_6_real[62] = result_state_5[30];
					line_6_real[63] = result_state_5[31];
				  //state6
					line_out_real[1] = result_state_6[0];
					line_out_real[3] = result_state_6[1];
					line_out_real[5] = result_state_6[2];
					line_out_real[7] = result_state_6[3];
					line_out_real[9] = result_state_6[4];
					line_out_real[11] = result_state_6[5];
					line_out_real[13] = result_state_6[6];
					line_out_real[15] = result_state_6[7];
					line_out_real[17] = result_state_6[8];
					line_out_real[19] = result_state_6[9];
					line_out_real[21] = result_state_6[10];
					line_out_real[23] = result_state_6[11];
					line_out_real[25] = result_state_6[12];
					line_out_real[27] = result_state_6[13];
					line_out_real[29] = result_state_6[14];
					line_out_real[31] = result_state_6[15];
					line_out_real[33] = result_state_6[16];
					line_out_real[35] = result_state_6[17];
					line_out_real[37] = result_state_6[18];
					line_out_real[39] = result_state_6[19];
					line_out_real[41] = result_state_6[20];
					line_out_real[43] = result_state_6[21];
					line_out_real[45] = result_state_6[22];
					line_out_real[47] = result_state_6[23];
					line_out_real[49] = result_state_6[24];
					line_out_real[51] = result_state_6[25];
					line_out_real[53] = result_state_6[26];
					line_out_real[55] = result_state_6[27];
					line_out_real[57] = result_state_6[28];
					line_out_real[59] = result_state_6[29];
					line_out_real[61] = result_state_6[30];
					line_out_real[63] = result_state_6[31];
			 end
			 2'b11:begin
				//state1
				for (i_1_3 = 0; i_1_3 < 32; i_1_3 = i_1_3 + 1) begin
						line_2_imag[i_1_3+32] = result_state_1[i_1_3];  
				end
				//state2
				for (i_2_6 = 0; i_2_6 < 16; i_2_6 = i_2_6 + 1) begin
						line_3_imag[i_2_6+16] = result_state_2[i_2_6]; 
				end
					
				for (i_2_7 = 32; i_2_7 < 48; i_2_7 = i_2_7 + 1) begin
					line_3_imag[i_2_7+16] = result_state_2[i_2_7-16]; 
				end
				//state3
				for (i_3_8 = 8; i_3_8 < 16; i_3_8 = i_3_8 + 1) begin
					line_4_imag[i_3_8] = result_state_3[i_3_8-8]; 
				end
				for (i_3_9 = 24; i_3_9 < 32; i_3_9 = i_3_9 + 1) begin
					line_4_imag[i_3_9] = result_state_3[i_3_9-16]; 
				end
				for (i_3_10 = 40; i_3_10 < 48; i_3_10 = i_3_10 + 1) begin
					line_4_imag[i_3_10] = result_state_3[i_3_10-24]; 
				end
				for (i_3_11 = 56; i_3_11 < 64; i_3_11 = i_3_11 + 1) begin
					line_4_imag[i_3_11] = result_state_3[i_3_11-32]; 
				end
				//state4
				for (i = 4; i < 8; i = i + 1) begin
					line_5_imag[i] = result_state_4[i-4]; 
				end
				for (i = 12; i < 16; i = i + 1) begin
					line_5_imag[i] = result_state_4[i-8]; 
				end
				for (i = 20; i < 24; i = i + 1) begin
					line_5_imag[i] = result_state_4[i-12]; 
				end
				for (i = 28; i < 32; i = i + 1) begin
					line_5_imag[i] = result_state_4[i-16]; 
				end
				for (i = 36; i < 40; i = i + 1) begin
					line_5_imag[i] = result_state_4[i-20]; 
				end
				for (i = 44; i < 48; i = i + 1) begin
					line_5_imag[i] = result_state_4[i-24]; 
				end
				for (i = 52; i < 56; i = i + 1) begin
					line_5_imag[i] = result_state_4[i-28]; 
				end
				for (i = 60; i < 64; i = i + 1) begin
					line_5_imag[i] = result_state_4[i-32]; 
				end
				//state5
				line_6_imag[2] = result_state_5[0];
				line_6_imag[3] = result_state_5[1];
				line_6_imag[6] = result_state_5[2];
				line_6_imag[7] = result_state_5[3];
				line_6_imag[10] = result_state_5[4];
				line_6_imag[11] = result_state_5[5];
				line_6_imag[14] = result_state_5[6];
				line_6_imag[15] = result_state_5[7];
				line_6_imag[18] = result_state_5[8];
				line_6_imag[19] = result_state_5[9];
				line_6_imag[22] = result_state_5[10];
				line_6_imag[23] = result_state_5[11];
				line_6_imag[26] = result_state_5[12];
				line_6_imag[27] = result_state_5[13];
				line_6_imag[30] = result_state_5[14];
				line_6_imag[31] = result_state_5[15];
				line_6_imag[34] = result_state_5[16];
				line_6_imag[35] = result_state_5[17];
				line_6_imag[38] = result_state_5[18];
				line_6_imag[39] = result_state_5[19];
				line_6_imag[42] = result_state_5[20];
				line_6_imag[43] = result_state_5[21];
				line_6_imag[46] = result_state_5[22];
				line_6_imag[47] = result_state_5[23];
				line_6_imag[50] = result_state_5[24];
				line_6_imag[51] = result_state_5[25];
				line_6_imag[54] = result_state_5[26];
				line_6_imag[55] = result_state_5[27];
				line_6_imag[58] = result_state_5[28];
				line_6_imag[59] = result_state_5[29];
				line_6_imag[62] = result_state_5[30];
				line_6_imag[63] = result_state_5[31];
				 //state6
				line_out_imag[1] = result_state_6[0];
				line_out_imag[3] = result_state_6[1];
				line_out_imag[5] = result_state_6[2];
				line_out_imag[7] = result_state_6[3];
				line_out_imag[9] = result_state_6[4];
				line_out_imag[11] = result_state_6[5];
				line_out_imag[13] = result_state_6[6];
				line_out_imag[15] = result_state_6[7];
				line_out_imag[17] = result_state_6[8];
				line_out_imag[19] = result_state_6[9];
				line_out_imag[21] = result_state_6[10];
				line_out_imag[23] = result_state_6[11];
				line_out_imag[25] = result_state_6[12];
				line_out_imag[27] = result_state_6[13];
				line_out_imag[29] = result_state_6[14];
				line_out_imag[31] = result_state_6[15];
				line_out_imag[33] = result_state_6[16];
				line_out_imag[35] = result_state_6[17];
				line_out_imag[37] = result_state_6[18];
				line_out_imag[39] = result_state_6[19];
				line_out_imag[41] = result_state_6[20];
				line_out_imag[43] = result_state_6[21];
				line_out_imag[45] = result_state_6[22];
				line_out_imag[47] = result_state_6[23];
				line_out_imag[49] = result_state_6[24];
				line_out_imag[51] = result_state_6[25];
				line_out_imag[53] = result_state_6[26];
				line_out_imag[55] = result_state_6[27];
				line_out_imag[57] = result_state_6[28];
				line_out_imag[59] = result_state_6[29];
				line_out_imag[61] = result_state_6[30];
				line_out_imag[63] = result_state_6[31];
				
				for (i = 0; i < 64; i = i + 1) begin
					line_2_imag_temp[i] = line_2_imag[i];
					line_2_real_temp[i] = line_2_real[i];
					line_3_imag_temp[i] = line_3_imag[i];
					line_3_real_temp[i] = line_3_real[i];
					line_4_imag_temp[i] = line_4_imag[i];
					line_4_real_temp[i] = line_4_real[i];
					line_5_imag_temp[i] = line_5_imag[i];
					line_5_real_temp[i] = line_5_real[i];
					line_6_imag_temp[i] = line_6_imag[i];
					line_6_real_temp[i] = line_6_real[i];
					line_out_imag_temp[i] = line_out_imag[i];
					line_out_real_temp[i] = line_out_real[i];
				end
			 end 
		endcase
	end 
	 
	
	 
endmodule