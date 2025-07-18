module FFT_IFFT(
	input clk,reset,start,
	output reg done,data_ready,
	input [2047:0] input_real,
	input [2047:0] input_imag,
	output[2047:0]real_out_fft,imag_out_fft,
	output reg done_state,
	input busy_in
);
	reg start_fft,start_ifft;
	reg [2047:0]data_real_buffer,data_imag_buffer;
	reg [2047:0] data_real_buffer_temp,data_imag_buffer_temp;
	wire busy_fft,busy_ifft,data_ready_ifft,data_ready_fft;
	reg [2047:0]input_real_temp,input_imag_temp,input_imag_temp_temp,input_real_temp_temp;
	wire[2047:0] real_out_ifft ,imag_out_ifft  ;
	wire[2047:0] real_out_ifft_AWGN ,imag_out_ifft_AWGN;
	reg [3:0] state,next_state;
	reg [3:0] count_fix,count_fix_next;
	reg [7:0] counter,counter_next;
	reg [7:0] counter1,counter1_next;
	reg [7:0] counter2,counter2_next;
	wire [2047:0] mem_data_real,mem_data_imag;
    wire [2559:0] imag_cp,real_cp;
    wire [2559:0] imag_cp_AWGN,real_cp_AWGN;
	parameter START      = 4'd0,
			  LOOP       = 4'd1,
			  BEGIN_IFFT = 4'd2,
			  HOLD       = 4'd3,
			  BEGIN_FFT  = 4'd4;
			  
	Memory_AWGN #(.REAL_FILE("E:/OFDM_64/OFDM_64_ver3_AWGN_pipline/real.txt"),
	  .IMAG_FILE("E:/OFDM_64/OFDM_64_ver3_AWGN_pipline/imag.txt"),
	  .SIZE(64)) mem(
			.clk(clk),
			.mem_data_real(mem_data_real),
			.mem_data_imag(mem_data_imag)
	  );
	IFFT ifft_0(
		.clk(clk),
		.reset(reset),
		.start(start_ifft),
		.busy(busy_ifft),
		.enable_fft_ifft(1'b1),
		.data_ready(data_ready_ifft),
		.input_real(input_real_temp),
		.input_imag(input_imag_temp),
		.real_out(real_out_ifft),
		.imag_out(imag_out_ifft)
	);
	assign imag_cp = {imag_out_ifft[511:0],imag_out_ifft};
	assign real_cp = {real_out_ifft[511:0],real_out_ifft};
	
	genvar i;
	generate
		for(i=0;i<64;i= i+1)begin : add_AWGN_real
			add_sub reals(
				.A(real_cp[32*i +:32]),
				.B(mem_data_real[32*i +:32]),
				.result(real_out_ifft_AWGN[32*i +:32])
			);
		end
	endgenerate
	
	genvar i_0;
	generate
		for(i_0=0;i_0<64;i_0 = i_0 + 1)begin : add_AWGN_imag
			add_sub imags(
				.A(imag_cp[32*i_0 +:32]),
				.B(mem_data_imag[32*i_0 +:32]),
				.result(imag_out_ifft_AWGN[32*i_0 +:32])
			);
		end
	endgenerate
	IFFT fft_0(
		.clk(clk),
		.reset(reset),
		.start(start_fft),
		.busy(busy_fft),
		.enable_fft_ifft(1'b0),
		.data_ready(data_ready_fft),
		.input_real(data_real_buffer),
		.input_imag(data_imag_buffer),
		.real_out(real_out_fft),
		.imag_out(imag_out_fft)
	);
    always @(posedge clk or negedge reset)begin
        if(!reset)begin
            state    <= 0;
            counter  <= 0;
            counter1 <= 0;
			done	 <= 0;
			counter2 <= 0;
			count_fix<= 0;
			input_imag_temp <= 0;
			input_real_temp <= 0;
        end else begin
            state 		<=  (busy_in)?next_state:0;
            input_imag_temp <= (busy_in)?input_imag_temp_temp:0;
            input_real_temp <= (busy_in)?input_real_temp_temp :0;
            counter 	<=   (busy_in)?counter_next:0 ;
            counter1 	<=   counter1_next ;
			counter2	<=  (busy_in)?counter2_next:0;
			count_fix   <=  count_fix_next;
			done 		<=  (counter2 == 8'd48)?  1'b1 : 1'b0;
			
        end 
    end 
    always@(*)begin
        data_real_buffer  = (counter == 8'd24 || counter == 8'd0)?real_out_ifft_AWGN:data_real_buffer;
        data_imag_buffer  = (counter == 8'd24 || counter == 8'd0)?imag_out_ifft_AWGN:data_imag_buffer;
    end
	always@(*) begin
		counter2_next = counter2;
		if(start)begin
			counter2_next = counter2_next + 1;
		end
 
	end
    always @(*) begin
        next_state    = state;
        counter_next  = counter; 
        counter1_next = counter1;
        count_fix_next = count_fix;
		done_state = 0;
		start_ifft = 0;
		start_fft = 0;
		input_imag_temp_temp = input_imag_temp;
		input_real_temp_temp = input_real_temp;
        case(state)
            START:begin
                if(start)begin
                    next_state = BEGIN_IFFT;
                end
            end
            BEGIN_IFFT: begin
                start_ifft = 1;
                input_real_temp_temp = input_real;
			 	input_imag_temp_temp = input_imag;
				next_state = LOOP;
			 	start_fft = 1;
            end 
            LOOP:begin
                start_fft = 1;
                if(counter== 8'd3)begin
                    counter_next  = 0;
                     
                    input_real_temp_temp  = input_real;
				    input_imag_temp_temp  = input_imag; 
				   
				    done_state = 1;
                end else begin
                    counter_next = counter_next + 1;
                end
            end
        endcase
    end
   		 
	
endmodule




 