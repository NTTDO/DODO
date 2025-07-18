module viterbi_16bit (
    input clk,reset,start,
	input [15:0]code_in,
	//output [15:0] code_fix,
	output [7:0] data_out,
	output reg done
	
);
	parameter START 	= 4'd0,
			  STATE_1   = 4'd1,
			  STATE_2	= 4'd2,
			  STATE_3   = 4'd3,
			  STATE_4	= 4'd4,
			  STATE_5   = 4'd5,
			  STATE_6	= 4'd6,
			  STATE_7   = 4'd7,
			  STATE_8	= 4'd8,
			  BACK		= 4'd9,
			  DONE      = 4'd10;
			
	parameter NODE_1    = 3'd0,
			  NODE_2	= 3'd1,
			  NODE_3	= 3'd2,
			  NODE_4	= 3'd3;
	wire [15:0] encode;
	reg [7:0]node[0:3];
	reg [7:0]node_temp[0:3];
	reg [7:0] state,next_state; 
	reg [1:0]value;
	
	reg [7:0]value_state[7:0];
	reg flag_1,flag_2,flag_3,flag_4;
	reg [7:0] index,index_next;
	reg [2:0] back_path [0:7][0:3];
	reg [2:0] min_track,min_track_temp;
	reg [7:0] data_decode;
	reg [7:0]counter,next_counter;
	assign data_out = data_decode;
	assign encode = code_in;
	initial begin
	   value = 0;
	   data_decode = 0;
	   next_state  = 0;
	end
	always@(posedge clk or negedge reset)begin
		if(!reset)begin
			state 		<= 0; 
			index 		<= 0;
			node[0]		<= 0;
			node[3]		<= 0;
			node[2]		<= 0;
			node[1]		<= 0;
			counter     <= 7;
			min_track   <= 0;
			done        <= 0;
		end else begin
			index		<= index_next;
			state		<= next_state;
			counter     <= next_counter;
			node[0]		<= node_temp[0];
			node[1]		<= node_temp[1];
			node[2]		<= node_temp[2];
			node[3]		<= node_temp[3];
			min_track   <= min_track_temp;
			done        <= (state==DONE)?1:0;
		end
	end
	 integer i,j;
	always @(*)begin
		index_next 		= index;
		value 			= encode[2*index +: 2];
		node_temp[0] = 0;
        node_temp[1] = 0;
        node_temp[2] = 0;
        node_temp[3] = 0;
		next_counter = counter;
		min_track_temp = min_track;
		case(state)
			START :begin
				if(start)begin
					next_state = STATE_1;
					index_next = 0;
					min_track_temp  = 0; 
				end
			end
			STATE_1:begin
				node_temp[0] = value[1]^0 + value[0]^0 + node[0];
				node_temp[1] = {7'd0,value[1]^1} + {7'd0,value[0]^1} + node[0] ;
				node_temp[2] = 0;
				node_temp[3] = 0;
				back_path[0][0] = NODE_1;
				back_path[0][1] = NODE_1;
				back_path[0][2] = 0;
				back_path[0][3] = 0;
				next_state   = STATE_2; 
				index_next   = index_next + 1; 
			end
			STATE_2:begin
				node_temp[0] = {7'd0,value[1]^0} + {7'd0,value[0]^0} + node[0];
				node_temp[1] = {7'd0,value[1]^1} + {7'd0,value[0]^1} + node[0];
				node_temp[2] = {7'd0,value[1]^0} + {7'd0,value[0]^1} + node[1];
				node_temp[3] = {7'd0,value[1]^1} + {7'd0,value[0]^0} + node[1];
				next_state   = STATE_3; 
				back_path[1][0] = NODE_1;
				back_path[1][1] = NODE_1;
				back_path[1][2] = NODE_2;
				back_path[1][3] = NODE_2;
				index_next   = index_next + 1; 
			end
			STATE_3:begin
				node_temp[0] = (({7'd0,value[1]^0} + {7'd0,value[0]^0} + node[0])<=({7'd0,value[1]^1} + {7'd0,value[0]^1} + node[2]))?({7'd0,value[1]^0} + {7'd0,value[0]^0} + node[0]):({7'd0,value[1]^1} + {7'd0,value[0]^1} + node[2]);
				node_temp[1] = (({7'd0,value[1]^1} + {7'd0,value[0]^1} + node[0])<=({7'd0,value[1]^0} + {7'd0,value[0]^0} + node[2]))?({7'd0,value[1]^1} + {7'd0,value[0]^1} + node[0]):({7'd0,value[1]^0} + {7'd0,value[0]^0} + node[2]);
				node_temp[2] = (({7'd0,value[1]^0} + {7'd0,value[0]^1} + node[1])<=({7'd0,value[1]^1} + {7'd0,value[0]^0} + node[3]))?({7'd0,value[1]^0} + {7'd0,value[0]^1} + node[1]):({7'd0,value[1]^1} + {7'd0,value[0]^0} + node[3]);
				node_temp[3] = (({7'd0,value[1]^1} + {7'd0,value[0]^0} + node[1])<=({7'd0,value[1]^0} + {7'd0,value[0]^1} + node[3]))?({7'd0,value[1]^1} + {7'd0,value[0]^0} + node[1]):({7'd0,value[1]^0} + {7'd0,value[0]^1} + node[3]);
				next_state   = STATE_4; 
				back_path[2][0] = (({7'd0,value[1]^0} + {7'd0,value[0]^0} + node[0])<=({7'd0,value[1]^1} + {7'd0,value[0]^1} + node[2]))?NODE_1:NODE_3;
				back_path[2][1] = (({7'd0,value[1]^1} + {7'd0,value[0]^1} + node[0])<=({7'd0,value[1]^0} + {7'd0,value[0]^0} + node[2]))?NODE_1:NODE_3;
				back_path[2][2] = (({7'd0,value[1]^0} + {7'd0,value[0]^1} + node[1])<=({7'd0,value[1]^1} + {7'd0,value[0]^0} + node[3]))?NODE_2:NODE_4;
				back_path[2][3] = (({7'd0,value[1]^1} + {7'd0,value[0]^0} + node[1])<=({7'd0,value[1]^0} + {7'd0,value[0]^1} + node[3]))?NODE_2:NODE_4;
				index_next   = index_next + 1; 
			end
			STATE_4:begin
				node_temp[0] = (({7'd0,value[1]^0} + {7'd0,value[0]^0} + node[0])<=({7'd0,value[1]^1} + {7'd0,value[0]^1} + node[2]))?({7'd0,value[1]^0} + {7'd0,value[0]^0} + node[0]):({7'd0,value[1]^1} + {7'd0,value[0]^1} + node[2]);
				node_temp[1] = (({7'd0,value[1]^1} + {7'd0,value[0]^1} + node[0])<=({7'd0,value[1]^0} + {7'd0,value[0]^0} + node[2]))?({7'd0,value[1]^1} + {7'd0,value[0]^1} + node[0]):({7'd0,value[1]^0} + {7'd0,value[0]^0} + node[2]);
				node_temp[2] = (({7'd0,value[1]^0} + {7'd0,value[0]^1} + node[1])<=({7'd0,value[1]^1} + {7'd0,value[0]^0} + node[3]))?({7'd0,value[1]^0} + {7'd0,value[0]^1} + node[1]):({7'd0,value[1]^1} + {7'd0,value[0]^0} + node[3]);
				node_temp[3] = (({7'd0,value[1]^1} + {7'd0,value[0]^0} + node[1])<=({7'd0,value[1]^0} + {7'd0,value[0]^1} + node[3]))?({7'd0,value[1]^1} + {7'd0,value[0]^0} + node[1]):({7'd0,value[1]^0} + {7'd0,value[0]^1} + node[3]);
				index_next   = index_next + 1; 
				back_path[3][0] = (({7'd0,value[1]^0} + {7'd0,value[0]^0} + node[0])<=({7'd0,value[1]^1} + {7'd0,value[0]^1} + node[2]))?NODE_1:NODE_3;
				back_path[3][1] = (({7'd0,value[1]^1} + {7'd0,value[0]^1} + node[0])<=({7'd0,value[1]^0} + {7'd0,value[0]^0} + node[2]))?NODE_1:NODE_3;
				back_path[3][2] = (({7'd0,value[1]^0} + {7'd0,value[0]^1} + node[1])<=({7'd0,value[1]^1} + {7'd0,value[0]^0} + node[3]))?NODE_2:NODE_4;
				back_path[3][3] = (({7'd0,value[1]^1} + {7'd0,value[0]^0} + node[1])<=({7'd0,value[1]^0} + {7'd0,value[0]^1} + node[3]))?NODE_2:NODE_4;
				next_state   = STATE_5;
			end
			STATE_5:begin
				node_temp[0] = (({7'd0,value[1]^0} + {7'd0,value[0]^0} + node[0])<=({7'd0,value[1]^1} + {7'd0,value[0]^1} + node[2]))?({7'd0,value[1]^0} + {7'd0,value[0]^0} + node[0]):({7'd0,value[1]^1} + {7'd0,value[0]^1} + node[2]);
				node_temp[1] = (({7'd0,value[1]^1} + {7'd0,value[0]^1} + node[0])<=({7'd0,value[1]^0} + {7'd0,value[0]^0} + node[2]))?({7'd0,value[1]^1} + {7'd0,value[0]^1} + node[0]):({7'd0,value[1]^0} + {7'd0,value[0]^0} + node[2]);
				node_temp[2] = (({7'd0,value[1]^0} + {7'd0,value[0]^1} + node[1])<=({7'd0,value[1]^1} + {7'd0,value[0]^0} + node[3]))?({7'd0,value[1]^0} + {7'd0,value[0]^1} + node[1]):({7'd0,value[1]^1} + {7'd0,value[0]^0} + node[3]);
				node_temp[3] = (({7'd0,value[1]^1} + {7'd0,value[0]^0} + node[1])<=({7'd0,value[1]^0} + {7'd0,value[0]^1} + node[3]))?({7'd0,value[1]^1} + {7'd0,value[0]^0} + node[1]):({7'd0,value[1]^0} + {7'd0,value[0]^1} + node[3]);
				index_next   = index_next + 1; 
				back_path[4][0] = (({7'd0,value[1]^0} + {7'd0,value[0]^0} + node[0])<=({7'd0,value[1]^1} + {7'd0,value[0]^1} + node[2]))?NODE_1:NODE_3;
				back_path[4][1] = (({7'd0,value[1]^1} + {7'd0,value[0]^1} + node[0])<=({7'd0,value[1]^0} + {7'd0,value[0]^0} + node[2]))?NODE_1:NODE_3;
				back_path[4][2] = (({7'd0,value[1]^0} + {7'd0,value[0]^1} + node[1])<=({7'd0,value[1]^1} + {7'd0,value[0]^0} + node[3]))?NODE_2:NODE_4;
				back_path[4][3] = (({7'd0,value[1]^1} + {7'd0,value[0]^0} + node[1])<=({7'd0,value[1]^0} + {7'd0,value[0]^1} + node[3]))?NODE_2:NODE_4;
				next_state   = STATE_6;
			end
			STATE_6:begin
				node_temp[0] = (({7'd0,value[1]^0} + {7'd0,value[0]^0} + node[0])<=({7'd0,value[1]^1} + {7'd0,value[0]^1} + node[2]))?({7'd0,value[1]^0} + {7'd0,value[0]^0} + node[0]):({7'd0,value[1]^1} + {7'd0,value[0]^1} + node[2]);
				node_temp[1] = (({7'd0,value[1]^1} + {7'd0,value[0]^1} + node[0])<=({7'd0,value[1]^0} + {7'd0,value[0]^0} + node[2]))?({7'd0,value[1]^1} + {7'd0,value[0]^1} + node[0]):({7'd0,value[1]^0} + {7'd0,value[0]^0} + node[2]);
				node_temp[2] = (({7'd0,value[1]^0} + {7'd0,value[0]^1} + node[1])<=({7'd0,value[1]^1} + {7'd0,value[0]^0} + node[3]))?({7'd0,value[1]^0} + {7'd0,value[0]^1} + node[1]):({7'd0,value[1]^1} + {7'd0,value[0]^0} + node[3]);
				node_temp[3] = (({7'd0,value[1]^1} + {7'd0,value[0]^0} + node[1])<=({7'd0,value[1]^0} + {7'd0,value[0]^1} + node[3]))?({7'd0,value[1]^1} + {7'd0,value[0]^0} + node[1]):({7'd0,value[1]^0} + {7'd0,value[0]^1} + node[3]);
				index_next   = index_next + 1; 
				back_path[5][0] = (({7'd0,value[1]^0} + {7'd0,value[0]^0} + node[0])<=({7'd0,value[1]^1} + {7'd0,value[0]^1} + node[2]))?NODE_1:NODE_3;
				back_path[5][1] = (({7'd0,value[1]^1} + {7'd0,value[0]^1} + node[0])<=({7'd0,value[1]^0} + {7'd0,value[0]^0} + node[2]))?NODE_1:NODE_3;
				back_path[5][2] = (({7'd0,value[1]^0} + {7'd0,value[0]^1} + node[1])<=({7'd0,value[1]^1} + {7'd0,value[0]^0} + node[3]))?NODE_2:NODE_4;
				back_path[5][3] = (({7'd0,value[1]^1} + {7'd0,value[0]^0} + node[1])<=({7'd0,value[1]^0} + {7'd0,value[0]^1} + node[3]))?NODE_2:NODE_4;
				next_state   = STATE_7;
			end
			STATE_7:begin
				node_temp[0] = (({7'd0,value[1]^0} + {7'd0,value[0]^0} + node[0])<=({7'd0,value[1]^1} + {7'd0,value[0]^1} + node[2]))?({7'd0,value[1]^0} + {7'd0,value[0]^0} + node[0]):({7'd0,value[1]^1} + {7'd0,value[0]^1} + node[2]);
				node_temp[1] = (({7'd0,value[1]^1} + {7'd0,value[0]^1} + node[0])<=({7'd0,value[1]^0} + {7'd0,value[0]^0} + node[2]))?({7'd0,value[1]^1} + {7'd0,value[0]^1} + node[0]):({7'd0,value[1]^0} + {7'd0,value[0]^0} + node[2]);
				node_temp[2] = (({7'd0,value[1]^0} + {7'd0,value[0]^1} + node[1])<=({7'd0,value[1]^1} + {7'd0,value[0]^0} + node[3]))?({7'd0,value[1]^0} + {7'd0,value[0]^1} + node[1]):({7'd0,value[1]^1} + {7'd0,value[0]^0} + node[3]);
				node_temp[3] = (({7'd0,value[1]^1} + {7'd0,value[0]^0} + node[1])<=({7'd0,value[1]^0} + {7'd0,value[0]^1} + node[3]))?({7'd0,value[1]^1} + {7'd0,value[0]^0} + node[1]):({7'd0,value[1]^0} + {7'd0,value[0]^1} + node[3]);
				index_next   = index_next + 1; 
				back_path[6][0] = (({7'd0,value[1]^0} + {7'd0,value[0]^0} + node[0])<=({7'd0,value[1]^1} + {7'd0,value[0]^1} + node[2]))?NODE_1:NODE_3;
				back_path[6][1] = (({7'd0,value[1]^1} + {7'd0,value[0]^1} + node[0])<=({7'd0,value[1]^0} + {7'd0,value[0]^0} + node[2]))?NODE_1:NODE_3;
				back_path[6][2] = (({7'd0,value[1]^0} + {7'd0,value[0]^1} + node[1])<=({7'd0,value[1]^1} + {7'd0,value[0]^0} + node[3]))?NODE_2:NODE_4;
				back_path[6][3] = (({7'd0,value[1]^1} + {7'd0,value[0]^0} + node[1])<=({7'd0,value[1]^0} + {7'd0,value[0]^1} + node[3]))?NODE_2:NODE_4;
				next_state   = STATE_8;
			end
			STATE_8:begin
				node_temp[0] = (({7'd0,value[1]^0} + {7'd0,value[0]^0} + node[0])<=({7'd0,value[1]^1} + {7'd0,value[0]^1} + node[2]))?({7'd0,value[1]^0} + {7'd0,value[0]^0} + node[0]):({7'd0,value[1]^1} + {7'd0,value[0]^1} + node[2]);
				node_temp[1] = (({7'd0,value[1]^1} + {7'd0,value[0]^1} + node[0])<=({7'd0,value[1]^0} + {7'd0,value[0]^0} + node[2]))?({7'd0,value[1]^1} + {7'd0,value[0]^1} + node[0]):({7'd0,value[1]^0} + {7'd0,value[0]^0} + node[2]);
				node_temp[2] = (({7'd0,value[1]^0} + {7'd0,value[0]^1} + node[1])<=({7'd0,value[1]^1} + {7'd0,value[0]^0} + node[3]))?({7'd0,value[1]^0} + {7'd0,value[0]^1} + node[1]):({7'd0,value[1]^1} + {7'd0,value[0]^0} + node[3]);
				node_temp[3] = (({7'd0,value[1]^1} + {7'd0,value[0]^0} + node[1])<=({7'd0,value[1]^0} + {7'd0,value[0]^1} + node[3]))?({7'd0,value[1]^1} + {7'd0,value[0]^0} + node[1]):({7'd0,value[1]^0} + {7'd0,value[0]^1} + node[3]);
				index_next   = index_next + 1; 
				back_path[7][0] = (({7'd0,value[1]^0} + {7'd0,value[0]^0} + node[0])<=({7'd0,value[1]^1} + {7'd0,value[0]^1} + node[2]))?NODE_1:NODE_3;
				back_path[7][1] = (({7'd0,value[1]^1} + {7'd0,value[0]^1} + node[0])<=({7'd0,value[1]^0} + {7'd0,value[0]^0} + node[2]))?NODE_1:NODE_3;
				back_path[7][2] = (({7'd0,value[1]^0} + {7'd0,value[0]^1} + node[1])<=({7'd0,value[1]^1} + {7'd0,value[0]^0} + node[3]))?NODE_2:NODE_4;
				back_path[7][3] = (({7'd0,value[1]^1} + {7'd0,value[0]^0} + node[1])<=({7'd0,value[1]^0} + {7'd0,value[0]^1} + node[3]))?NODE_2:NODE_4;
				next_state   = BACK ;
				min_track_temp = (node_temp[0] <= node_temp[1] && node_temp[0] <= node_temp[2] && node_temp[0] <= node_temp[3]) ? NODE_1 :
                            (node_temp[1] <= node_temp[2] && node_temp[1] <= node_temp[3]) ? NODE_2 :
                            (node_temp[2] <= node_temp[3]) ? NODE_3 : NODE_4;
			end
			BACK: begin 
                data_decode[counter] = (min_track == NODE_1 || min_track == NODE_3) ? 1'b0 : 1'b1;
             
                min_track_temp = back_path[counter][min_track];
             
                if (counter == 0) begin
                    next_state   = DONE;
                    next_counter = 7;
                end else begin
                    next_counter = counter - 1;
                    next_state   = BACK;
                end
            end 
			DONE:begin
				index_next     = 0;
				next_state     = START;
				for(  i=0; i<8; i=i+1) begin
                    for(  j=0; j<4; j=j+1) begin
                        back_path[i][j] = 0;
                    end
                end
				//min_track_temp = 0;
				//data_decode    = 0;
			end
		endcase
	end
	
endmodule 
	
	
	
	
	
	 

