module floating_point_div(
    input  [31:0] a,
    input  [31:0] b,
    output [31:0] result
);  
 
    reg [31:0]result_reg;
    wire sign_a  = a[31];
    wire sign_b  = b[31];
    wire [7:0] exponent_a = a[30:23];
    wire [7:0] exponent_b = b[30:23];
    wire [23:0] mantissa_a = {1'b1, a[22:0]};
    wire [23:0] mantissa_b = {1'b1, b[22:0]}; 
    wire result_sign = sign_a ^ sign_b; 
    wire [8:0] exponent_diff = exponent_a - exponent_b + 127;
     
    wire [47:0] dividend = {mantissa_a, 24'b0};
    wire [47:0] full_quotient = dividend / mantissa_b;  
    
    reg  [22:0] result_mantissa;
    reg  [7:0] result_exponent;
    always @(*) begin
        if((exponent_a == 8'b0 && a[22:0] == 23'b0))begin
            result_reg = 32'b0; 
        end else begin
            if (full_quotient[24] == 1'b1) begin 
                result_mantissa = full_quotient[23:1];
                result_exponent = exponent_diff[7:0];
            end else begin 
                result_mantissa = full_quotient[22:0];  
                result_exponent = exponent_diff[7:0] - 1;
            end
            result_reg = {result_sign, result_exponent, result_mantissa};
        end
    end
	 
    assign result = result_reg;

endmodule