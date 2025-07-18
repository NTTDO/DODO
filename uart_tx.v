module uart_tx#(parameter CLK_FRE = 50000000, CLK_UART = 115200)( 
	input clk, rst, enable, 
	input [1151:0] data_in, 
	output reg busy_tx, tx 
); 
reg [15:0] counter2, counter4; 
reg flag; 
reg [7:0] mem[0:144]; 
reg [7:0] mem_buffer1; 
reg [15:0] tx_counter; 
	always @(posedge clk or negedge rst) begin 
		if (!rst) begin  
			busy_tx <= 0; 
			mem_buffer1 <= 0; 
			tx <= 1'b1;    
			counter2 <= 16'd0; 
			counter4 <= 16'd0;   
			flag <= 0; 
			tx_counter <= 16'd0; 
			   
		end else if (enable) begin 
                mem[0]   <= data_in[7:0];
                mem[1]   <= data_in[15:8];
                mem[2]   <= data_in[23:16];
                mem[3]   <= data_in[31:24];
                mem[4]   <= data_in[39:32];
                mem[5]   <= data_in[47:40];
                mem[6]   <= data_in[55:48];
                mem[7]   <= data_in[63:56];
                mem[8]   <= data_in[71:64];
                mem[9]   <= data_in[79:72];
                mem[10]  <= data_in[87:80];
                mem[11]  <= data_in[95:88];
                mem[12]  <= data_in[103:96];
                mem[13]  <= data_in[111:104];
                mem[14]  <= data_in[119:112];
                mem[15]  <= data_in[127:120];
                mem[16]  <= data_in[135:128];
                mem[17]  <= data_in[143:136];
                mem[18]  <= data_in[151:144];
                mem[19]  <= data_in[159:152];
                mem[20]  <= data_in[167:160];
                mem[21]  <= data_in[175:168];
                mem[22]  <= data_in[183:176];
                mem[23]  <= data_in[191:184];
                mem[24]  <= data_in[199:192];
                mem[25]  <= data_in[207:200];
                mem[26]  <= data_in[215:208];
                mem[27]  <= data_in[223:216];
                mem[28]  <= data_in[231:224];
                mem[29]  <= data_in[239:232];
                mem[30]  <= data_in[247:240];
                mem[31]  <= data_in[255:248];
                mem[32]  <= data_in[263:256];
                mem[33]  <= data_in[271:264];
                mem[34]  <= data_in[279:272];
                mem[35]  <= data_in[287:280];
                mem[36]  <= data_in[295:288];
                mem[37]  <= data_in[303:296];
                mem[38]  <= data_in[311:304];
                mem[39]  <= data_in[319:312];
                mem[40]  <= data_in[327:320];
                mem[41]  <= data_in[335:328];
                mem[42]  <= data_in[343:336];
                mem[43]  <= data_in[351:344];
                mem[44]  <= data_in[359:352];
                mem[45]  <= data_in[367:360];
                mem[46]  <= data_in[375:368];
                mem[47]  <= data_in[383:376];
                mem[48]  <= data_in[391:384];
                mem[49]  <= data_in[399:392];
                mem[50]  <= data_in[407:400];
                mem[51]  <= data_in[415:408];
                mem[52]  <= data_in[423:416];
                mem[53]  <= data_in[431:424];
                mem[54]  <= data_in[439:432];
                mem[55]  <= data_in[447:440];
                mem[56]  <= data_in[455:448];
                mem[57]  <= data_in[463:456];
                mem[58]  <= data_in[471:464];
                mem[59]  <= data_in[479:472];
                mem[60]  <= data_in[487:480];
                mem[61]  <= data_in[495:488];
                mem[62]  <= data_in[503:496];
                mem[63]  <= data_in[511:504];
                mem[64]  <= data_in[519:512];
                mem[65]  <= data_in[527:520];
                mem[66]  <= data_in[535:528];
                mem[67]  <= data_in[543:536];
                mem[68]  <= data_in[551:544];
                mem[69]  <= data_in[559:552];
                mem[70]  <= data_in[567:560];
                mem[71]  <= data_in[575:568];
                mem[72]  <= data_in[583:576];
                mem[73]  <= data_in[591:584];
                mem[74]  <= data_in[599:592];
                mem[75]  <= data_in[607:600];
                mem[76]  <= data_in[615:608];
                mem[77]  <= data_in[623:616];
                mem[78]  <= data_in[631:624];
                mem[79]  <= data_in[639:632];
                mem[80]  <= data_in[647:640];
                mem[81]  <= data_in[655:648];
                mem[82]  <= data_in[663:656];
                mem[83]  <= data_in[671:664];
                mem[84]  <= data_in[679:672];
                mem[85]  <= data_in[687:680];
                mem[86]  <= data_in[695:688];
                mem[87]  <= data_in[703:696];
                mem[88]  <= data_in[711:704];
                mem[89]  <= data_in[719:712];
                mem[90]  <= data_in[727:720];
                mem[91]  <= data_in[735:728];
                mem[92]  <= data_in[743:736];
                mem[93]  <= data_in[751:744];
                mem[94]  <= data_in[759:752];
                mem[95]  <= data_in[767:760];
                mem[96]  <= data_in[775:768];
                mem[97]  <= data_in[783:776];
                mem[98]  <= data_in[791:784];
                mem[99]  <= data_in[799:792];
                mem[100] <= data_in[807:800];
                mem[101] <= data_in[815:808];
                mem[102] <= data_in[823:816];
                mem[103] <= data_in[831:824];
                mem[104] <= data_in[839:832];
                mem[105] <= data_in[847:840];
                mem[106] <= data_in[855:848];
                mem[107] <= data_in[863:856];
                mem[108] <= data_in[871:864];
                mem[109] <= data_in[879:872];
                mem[110] <= data_in[887:880];
                mem[111] <= data_in[895:888];
                mem[112] <= data_in[903:896];
                mem[113] <= data_in[911:904];
                mem[114] <= data_in[919:912];
                mem[115] <= data_in[927:920];
                mem[116] <= data_in[935:928];
                mem[117] <= data_in[943:936];
                mem[118] <= data_in[951:944];
                mem[119] <= data_in[959:952];
                mem[120] <= data_in[967:960];
                mem[121] <= data_in[975:968];
                mem[122] <= data_in[983:976];
                mem[123] <= data_in[991:984];
                mem[124] <= data_in[999:992];
                mem[125] <= data_in[1007:1000];
                mem[126] <= data_in[1015:1008];
                mem[127] <= data_in[1023:1016];
                mem[128] <= data_in[1031:1024];
                mem[129] <= data_in[1039:1032];
                mem[130] <= data_in[1047:1040];
                mem[131] <= data_in[1055:1048];
                mem[132] <= data_in[1063:1056];
                mem[133] <= data_in[1071:1064];
                mem[134] <= data_in[1079:1072];
                mem[135] <= data_in[1087:1080];
                mem[136] <= data_in[1095:1088];
                mem[137] <= data_in[1103:1096];
                mem[138] <= data_in[1111:1104];
                mem[139] <= data_in[1119:1112];
                mem[140] <= data_in[1127:1120];
                mem[141] <= data_in[1135:1128];
                mem[142] <= data_in[1143:1136];
                mem[143] <= data_in[1151:1144];

			
			
			if (tx_counter < 16'd144) begin 
				mem_buffer1 <= mem[tx_counter]; 
				counter2 <= counter2 + 16'd1; 
				case (counter2)  
					CLK_FRE/CLK_UART * 0 : tx <= 0; 
					CLK_FRE/CLK_UART * 1 : tx <= mem_buffer1[0]; 
					CLK_FRE/CLK_UART * 2 : tx <= mem_buffer1[1];
					CLK_FRE/CLK_UART * 3 : tx <= mem_buffer1[2]; 
					CLK_FRE/CLK_UART * 4 : tx <= mem_buffer1[3]; 
					CLK_FRE/CLK_UART * 5 : tx <= mem_buffer1[4]; 
					CLK_FRE/CLK_UART * 6 : tx <= mem_buffer1[5]; 
					CLK_FRE/CLK_UART * 7 : tx <= mem_buffer1[6]; 
					CLK_FRE/CLK_UART * 8 : tx <= mem_buffer1[7]; 
					CLK_FRE/CLK_UART * 9 : begin 
						tx <= 1; 
						counter2 <= 16'd0; 
						tx_counter <= tx_counter + 1; 
						//counter4 <= counter4 + 1;  
					end 
				endcase 
 
			end else begin 
				tx <= 1; 
				busy_tx <= 1; 
			end 
		end else begin 
			tx    <= 1'b1;  
			counter2  <= 16'd0; 
			counter4  <= 16'd0;   
			flag   <= 0; 
			busy_tx  <= 0; 
			tx_counter  <= 16'd0;   
			 
		end 
	end 
endmodule 