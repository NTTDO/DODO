module DFT_2(flag,a1_res,a2_res,b1_im,b2_im,w_res,w_im,result);
 
	input [1:0] flag;
	input [31:0] a1_res,a2_res,b1_im,b2_im,w_res,w_im;
	output   [31:0] result;
	/*  flag = 00; Res 1
		flag = 01; im 1
		flag = 10; res 2
		flag = 11; im 2
	*/
	wire [31:0] temp_s1,temp_s0,temp_add1,temp_add0;
	wire [31:0] temp_mul1,temp_mul2;
	
	assign temp_mul1 = (flag == 2'b00) ? a2_res : (
					   (flag == 2'b01) ? b2_im  : (
					   (flag == 2'b10) ? {~a2_res[31],a2_res[30:0]} : {~b2_im[31],b2_im[30:0]}));
	
	floating_point_mul mult_fix_inst0(
		.a(temp_mul1),
		.b(w_res),
		.result(temp_s0)
	);
	
	assign temp_mul2 = (flag == 2'b00) ? {~b2_im[31],b2_im[30:0]} : (
					   (flag == 2'b01) ? a2_res : (
					   (flag == 2'b10) ? b2_im : {~a2_res[31],a2_res[30:0]} ));
	
	floating_point_mul mult_fix_inst1(
		.a(temp_mul2),
		.b(w_im),
		.result(temp_s1)
	);
	
	assign temp_add0 = (flag == 2'b00 || flag == 2'b10) ? a1_res : b1_im;
	
	add_sub add_sub_0(
		.A(temp_s0),
		.B(temp_add0),
		.result(temp_add1)
	);
	add_sub add_sub_1(
		.A(temp_add1),
		.B(temp_s1),
		.result(result)
	);
	
	
endmodule