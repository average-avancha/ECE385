module carry_select_adder
(
    input   logic[15:0]     A,
    input   logic[15:0]     B,
    output  logic[15:0]     Sum,
    output  logic           CO
);
	 logic Cout3, Cout7, Cout11;
	 carry_select_adder_4bit CSA0 (.Cin(0), .A(A[3:0]), .B(B[3:0]), .Cout(Cout3), .S(Sum[3:0]));
	 carry_select_adder_4bit CSA1 (.Cin(Cout3), .A(A[7:4]), .B(B[7:4]), .Cout(Cout7), .S(Sum[7:4]));
	 carry_select_adder_4bit CSA2 (.Cin(Cout7), .A(A[11:8]), .B(B[11:8]), .Cout(Cout11), .S(Sum[11:8]));
	 carry_select_adder_4bit CSA3 (.Cin(Cout11), .A(A[15:12]), .B(B[15:12]), .Cout(CO), .S(Sum[15:12]));
	 
	 
endmodule

module carry_select_adder_4bit
(
	 input Cin,
	 input [3:0] A, B,
	 output Cout,
	 output [3:0] S
);
	 logic [3:0]S0, S1;
	 logic Cout0, Cout1;
	 full_adder_four_bit FA4B_0 (.x(A[3:0]), .y(B[3:0]), .cin(1'b0), .s(S0[3:0]), .cout(Cout0));
	 full_adder_four_bit FA4B_1 (.x(A[3:0]), .y(B[3:0]), .cin(1'b1), .s(S1[3:0]), .cout(Cout1));
	 two_to_one_MUX MUX0 (.input0(S0[0]), .input1(S1[0]), .select(Cin), .out(S[0]));
	 two_to_one_MUX MUX1 (.input0(S0[1]), .input1(S1[1]), .select(S[0]), .out(S[1]));
	 two_to_one_MUX MUX2 (.input0(S0[2]), .input1(S1[2]), .select(S[1]), .out(S[2]));
	 two_to_one_MUX MUX3 (.input0(S0[3]), .input1(S1[3]), .select(S[2]), .out(S[3]));
	 two_to_one_MUX MUX_OUT (.input0(Cout0), .input1(Cout1), .select(S[3]), .out(Cout));
endmodule

module full_adder_four_bit
(
	 input [3:0]x,
	 input [3:0]y,
	 input cin,
	 output [3:0]s,
	 output cout
);
	 logic c0, c1, c2;
	 full_adder FA0 (.x(x[0]), .y(y[0]), .cin(cin), .s(s[0]), .cout(c0));
	 full_adder FA1 (.x(x[1]), .y(y[1]), .cin(c0), .s(s[1]), .cout(c1));
	 full_adder FA2 (.x(x[2]), .y(y[2]), .cin(c1), .s(s[2]), .cout(c2));
	 full_adder FA3 (.x(x[3]), .y(y[3]), .cin(c2), .s(s[3]), .cout(cout));
endmodule

module two_to_one_MUX
(
	 input logic input0,
	 input logic input1,
	 input logic select,
	 output logic out
);
	 
	 always_comb begin
		 if (select)	out = input1;
		 else 			out = input0;
	 end
endmodule

module full_adder
(
		input x,
		input y,
		input cin,
		output logic s,
		output logic cout
);
		assign s = x ^ y ^ cin;
		assign cout = (x&y) | (y&cin) | (cin&x);
	
endmodule
