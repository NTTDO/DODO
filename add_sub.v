module add_sub(input [31:0]A,
               input [31:0]B,
               output reg  [31:0] result);

reg [31:0] A_swap, B_swap;   
wire [23:0] A_Mantissa = {1'b1, A_swap[22:0]}, B_Mantissa = {1'b1, B_swap[22:0]};  
wire [7:0] A_Exponent = A_swap[30:23], B_Exponent = B_swap[30:23];
wire A_sign = A_swap[31], B_sign = B_swap[31];

reg [23:0] Temp_Mantissa, B_shifted_mantissa;
 
reg [7:0] Exponent;
 
reg comp;
reg [7:0] diff_Exponent;
reg [32:0] Temp;
reg carry; 

integer i;
 
 
    always @(*) begin
    if (A == 32'b0 && B == 32'b0) begin
        result = 32'b0;  
    end else begin
        if (A[30:23] != B[30:23]) begin
            comp = (A[30:23] > B[30:23]) ? 1'b1 : 1'b0;   
        end else begin
            comp = (A[22:0] > B[22:0]) ? 1'b1 : 1'b0;    
        end

        A_swap = comp ? A : B;
        B_swap = comp ? B : A; 
        diff_Exponent = A_Exponent - B_Exponent;
        B_shifted_mantissa = (B_Mantissa >> diff_Exponent); 
        {carry, Temp_Mantissa} = (A_sign ~^ B_sign) ? A_Mantissa + B_shifted_mantissa : A_Mantissa - B_shifted_mantissa;
        Exponent = A_Exponent; 
        if (carry) begin
            Temp_Mantissa = Temp_Mantissa >> 1;
            Exponent = Exponent + 1;   
        end else begin 
            casez (Temp_Mantissa[23:0]) 
                24'b1??????????????????????? : Exponent = Exponent;         
                24'b01?????????????????????? : begin Temp_Mantissa = Temp_Mantissa << 1; Exponent = Exponent - 1; end
                24'b001????????????????????? : begin Temp_Mantissa = Temp_Mantissa << 2; Exponent = Exponent - 2; end
                24'b0001???????????????????? : begin Temp_Mantissa = Temp_Mantissa << 3; Exponent = Exponent - 3; end
                24'b00001??????????????????? : begin Temp_Mantissa = Temp_Mantissa << 4; Exponent = Exponent - 4; end
                24'b000001?????????????????? : begin Temp_Mantissa = Temp_Mantissa << 5; Exponent = Exponent - 5; end
                24'b0000001????????????????? : begin Temp_Mantissa = Temp_Mantissa << 6; Exponent = Exponent - 6; end
                24'b00000001???????????????? : begin Temp_Mantissa = Temp_Mantissa << 7; Exponent = Exponent - 7; end
                24'b000000001??????????????? : begin Temp_Mantissa = Temp_Mantissa << 8; Exponent = Exponent - 8; end
                24'b0000000001?????????????? : begin Temp_Mantissa = Temp_Mantissa << 9; Exponent = Exponent - 9; end
                24'b00000000001????????????? : begin Temp_Mantissa = Temp_Mantissa << 10; Exponent = Exponent - 10; end
                24'b000000000001???????????? : begin Temp_Mantissa = Temp_Mantissa << 11; Exponent = Exponent - 11; end
                24'b0000000000001??????????? : begin Temp_Mantissa = Temp_Mantissa << 12; Exponent = Exponent - 12; end
                24'b00000000000001?????????? : begin Temp_Mantissa = Temp_Mantissa << 13; Exponent = Exponent - 13; end
                24'b000000000000001????????? : begin Temp_Mantissa = Temp_Mantissa << 14; Exponent = Exponent - 14; end
                24'b0000000000000001???????? : begin Temp_Mantissa = Temp_Mantissa << 15; Exponent = Exponent - 15; end
                24'b00000000000000001??????? : begin Temp_Mantissa = Temp_Mantissa << 16; Exponent = Exponent - 16; end
                24'b000000000000000001?????? : begin Temp_Mantissa = Temp_Mantissa << 17; Exponent = Exponent - 17; end
                24'b0000000000000000001????? : begin Temp_Mantissa = Temp_Mantissa << 18; Exponent = Exponent - 18; end
                24'b00000000000000000001???? : begin Temp_Mantissa = Temp_Mantissa << 19; Exponent = Exponent - 19; end
                24'b000000000000000000001??? : begin Temp_Mantissa = Temp_Mantissa << 20; Exponent = Exponent - 20; end
                24'b0000000000000000000001?? : begin Temp_Mantissa = Temp_Mantissa << 21; Exponent = Exponent - 21; end
                24'b00000000000000000000001? : begin Temp_Mantissa = Temp_Mantissa << 22; Exponent = Exponent - 22; end
                24'b000000000000000000000001 : begin Temp_Mantissa = Temp_Mantissa << 23; Exponent = Exponent - 23; end
                default: begin Temp_Mantissa = 0; Exponent = 0; end
            endcase
        end
        
        result = ((A[30:0] == B[30:0]) && (A[31] ^ B[31])) ? 0 : {A_sign, Exponent, Temp_Mantissa[22:0]};
    end 
end
endmodule