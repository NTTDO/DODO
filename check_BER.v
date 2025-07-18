module check_BER #(parameter WIDTH = 16)(
    input [WIDTH-1:0] a,
    input [WIDTH-1:0] b,
    output reg [31:0] diff_count
);
    integer i;
    reg [WIDTH-1:0] diff_bits;

    always @(*) begin
        diff_bits = a ^ b;  
        diff_count = 0;
        for (i = 0; i < WIDTH; i = i + 1) begin
            if (diff_bits[i]) diff_count = diff_count + 1;
        end
    end

endmodule
