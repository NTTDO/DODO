module tb();
	reg clk,reset,start,rx;
	wire busy;
	wire tx;
 	//reg[1151:0]data_in_encoder;
	OFDM64_ver_pipline top_0(
		.clk(clk),
		.reset(reset),
		.start(start),
		.busy(busy),
		.tx(tx),
		.rx(rx)
		//.data_in_encoder(data_in_encoder)
		
	);
    localparam CLK_PERIOD = 20;        
    localparam CLK_FRE = 50;           
	localparam BAUD_RATE = 115200;     
	localparam CYCLE = CLK_FRE * 1000000 / BAUD_RATE; 
	initial begin 
		clk = 0; 
		forever #(CLK_PERIOD/2) clk = ~clk;   
	end 
	integer i;
	initial begin
			
		reset = 0;
		start = 0;
		#10 
		reset = 1;
		start = 1;
	  
		// data_in_encoder = 1152'he5c1448e7229128bb6cc511651d7e45c97ba74aad8868099eeeeeeeeeeeeee1111eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeddddddddddddddddddddddddddddddddddddddddddddddddccccccccccccccccccccccccccccccccccccccccccccccccbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa; 
       //  	#10 
       // wait(!busy);

	  
      //  data_in_encoder = 1152'h11ffffffffffffffffffffffffffffffffffffffffffffff123456eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeddddddddddddddddddddddddddddddddddddddddddddddddccccccccccccccccccccccccccccccccccccccccccccccccbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa; 
       
      //   data_in_encoder = 1152'hffffff8e7229128bb6cc511651d7e45c97ba74aad886809922222222222222222222222222222222222222222222222233333333333333333333333333333333333333333333333344444444444444444444444444444444444444444444444455555555555555555555555555555555555555555555555566666666666666666666666666666666666666666666ffff;
      //   #100
      //  wait(!busy);
 
	  
        //data_in_encoder = 1152'h11ffffffffffffffffffffffffffffffffffffffffffffffeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeddddddddddddddddddddddddddddddddddddddddddddddddccccccccccccccccccccccccccccccccccccccccccccccccbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa; 
       
      //   data_in_encoder = 1152'h1234111111aa111111111111111111111111111111111111222222222222222222222222222222222222222222222222333333333333333333333333333333333333333333333333444444444444444444444444444444444444444444444444555555555555555555555555555555555555555555555555666666666666666666666666666666666666666666661234;
     //   #100
          for (i = 0; i < 24; i = i + 1) begin
            send_byte(8'hA1);
            #(CLK_PERIOD);
        end
        for (i = 0; i < 24; i = i + 1) begin 
            send_byte(8'hBB);
            #(CLK_PERIOD);
        end
        for (i = 0; i < 24; i = i + 1) begin
            send_byte(8'hCC);
            #(CLK_PERIOD);
        end
        for (i = 0; i < 24; i = i + 1) begin
            send_byte(8'hDD);
            #(CLK_PERIOD);
        end
        for (i = 0; i < 24; i = i + 1) begin
            send_byte(8'hEf);
            #(CLK_PERIOD);
        end
        for (i = 0; i < 24; i = i + 1) begin
            send_byte(8'h6F);
             #(CLK_PERIOD);   
        end
        #10
        wait(!busy)
       
     
        for (i = 0; i < 24; i = i + 1) begin
            send_byte(8'h11);
            #(CLK_PERIOD);
        end
        for (i = 0; i < 24; i = i + 1) begin
            send_byte(8'h22);
            #(CLK_PERIOD);
        end
        for (i = 0; i < 24; i = i + 1) begin
            send_byte(8'h33);
            #(CLK_PERIOD);
        end
        for (i = 0; i < 24; i = i + 1) begin
            send_byte(8'h44);
            #(CLK_PERIOD);
        end
        for (i = 0; i < 24; i = i + 1) begin
            send_byte(8'h55);
            #(CLK_PERIOD);
        end
        for (i = 0; i < 24; i = i + 1) begin
            send_byte(8'h6f);
             #(CLK_PERIOD);   
        end
       
       
        wait(!busy) 
		 
		$finish;
	end
	initial begin
	#1000
	     wait(!busy);
        $display("in = %h",top_0.data_imag_out_temp);
        $display("in = %h",top_0.data_imag_out);
	end
task send_byte(input [7:0] data); 
	integer i; 
	begin 
		rx = 0; 
		repeat(CYCLE) @(posedge clk); 
		for (i = 0; i < 8; i = i + 1) begin 
			rx = data[i]; 
			repeat(CYCLE) @(posedge clk);  
		end 
		rx = 1; 
		repeat(CYCLE) @(posedge clk);  
	end 
endtask
endmodule