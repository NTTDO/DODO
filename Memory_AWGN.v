module Memory_AWGN #(
    parameter REAL_FILE = "",
    parameter IMAG_FILE = "",
    parameter SIZE = 64
)(
    input clk, 
    output reg [2047:0] mem_data_real,
    output reg [2047:0] mem_data_imag
                
);
    integer i;
    reg [31:0] MEM_REAL [0:SIZE-1]; 
    reg [31:0] MEM_IMAG [0:SIZE-1];
     

    initial begin
        for (i = 0; i < SIZE; i = i + 1) begin
            MEM_REAL[i] = 'h0;
            MEM_IMAG[i] = 'h0;
        end
        $readmemh(REAL_FILE, MEM_REAL);
        $readmemh(IMAG_FILE, MEM_IMAG);
    end

    always @(posedge clk) begin
            for (i = 0; i < SIZE; i = i + 1) begin
                mem_data_real[i*32 +: 32] <= MEM_REAL[i];
                mem_data_imag[i*32 +: 32] <= MEM_IMAG[i];
            end
    end

endmodule
