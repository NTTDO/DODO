module convolution_code (
    input        clk,
    input        reset,    
    input        start,
    input  [7:0] m_text_in,
    output [15:0] code_out,
    output reg done
);

    parameter START    = 4'd0,
              STATE_00 = 4'd1,
              STATE_10 = 4'd2,
              STATE_01 = 4'd3,
              STATE_11 = 4'd4,
              DONE     = 4'd5;

    reg [3:0] state, next_state;
    reg [7:0] counter, next_counter;
    reg [7:0] counter_0, next_counter_0;
    reg       data;
    reg [15:0] data_out, next_data_out;
    
    assign code_out = data_out;
    
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            state    <= START;
            counter  <= 8'd0;
            data_out <= 16'd0;
		//	done     <= 0;
			counter_0 <= 0;
        end else begin
            state    <= next_state;
            counter  <= next_counter;
            data_out <= next_data_out;
            counter_0 <= (counter_0 != 8)?next_counter_0:0;
		//	done 	 <= (state == START)?1:0;
			 
        end
    end
    
    always @(*) begin
        done = 0;
        next_state     = state;
        next_counter   = counter;
        next_data_out  = data_out;
        data           = (counter!=8)?m_text_in[counter]:data;
        next_counter_0 = counter_0;
        next_counter_0 = next_counter_0 + 1; 
        case (state)
            START: begin
                if (start) begin
                    next_state   = STATE_00;
                    next_counter = 8'd0;
                end
            end
            
            STATE_00: begin
                if (!data) begin
                    next_state = STATE_00;
                    next_data_out[2*counter +: 2] = 2'b00;
                end else begin
                    next_state = STATE_10;
                    next_data_out[2*counter +: 2] = 2'b11;
                end
                next_counter = counter + 1;
            end
            
            STATE_10: begin
                if (!data) begin
                    next_state = STATE_01;
                    next_data_out[2*counter +: 2] = 2'b01;
                end else begin
                    next_state = STATE_11;
                    next_data_out[2*counter +: 2] = 2'b10;
                end
                next_counter = counter + 1;
            end
            
            STATE_01: begin
                if (!data) begin
                    next_state = STATE_00;
                    next_data_out[2*counter +: 2] = 2'b11;
                end else begin
                    next_state = STATE_10;
                    next_data_out[2*counter +: 2] = 2'b00;
                end
                next_counter = counter + 1;
            end
            
            STATE_11: begin
                if (!data) begin
                    next_state = STATE_01;
                    next_data_out[2*counter +: 2] = 2'b10;
                end else begin
                    next_state = STATE_11;
                    next_data_out[2*counter +: 2] = 2'b01;
                end
                next_counter = counter + 1;
            end
            
            DONE: begin 
                next_state   = START;
                next_counter = 8'd0;
                  
            end
        endcase
         
        if (counter == 8)begin
            next_state   = START;
            next_counter = 8'd0;
            done = 1;
           
        end
    end

endmodule
