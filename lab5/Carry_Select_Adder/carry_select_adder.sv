module carry_select_adder
(
    input   logic[15:0]     A,
    input   logic[15:0]     B,
    output  logic[15:0]     Sum,
    output  logic           CO
);
	 logic			Cout0, Cout1, Cout2; //Logic chaining the select adders
	 FA_4 CSA0 (.A(A[3:0]), .B(B[3:0]), .Cin(1'b0), .Sum(Sum[3:0]), .CO(Cout0)); //Initial 4-bit Full Adder for bits [3:0]
	 CSA_4 CSA1 (.A(A[7:4]), .B(B[7:4]), .Cin(Cout0), .Sum(Sum[7:4]), .CO(Cout1)); 
	 CSA_4 CSA2 (.A(A[11:8]), .B(B[11:8]), .Cin(Cout1), .Sum(Sum[11:8]), .CO(Cout2)); 
	 CSA_4 CSA3 (.A(A[15:12]), .B(B[15:12]), .Cin(Cout2), .Sum(Sum[15:12]), .CO(CO));
endmodule 

module CSA_4
(
	 input 	logic[3:0]		 A,
	 input	logic[3:0]		 B,
	 input 	logic				 Cin,
	 output	logic[3:0]		 Sum,
	 output 	logic				 CO
);
	 logic[3:0]		Sum0;
	 logic[3:0]		Sum1;
	 logic			c_0;
	 logic			c_1;
	 // 4 bit Carry Select Adder Module
	 FA_4 F0 (.A(A[3:0]), .B(B[3:0]), .Cin(1'b0), .Sum(Sum0[3:0]), .CO(c_0));
	 FA_4 F1 (.A(A[3:0]), .B(B[3:0]), .Cin(1'b1), .Sum(Sum1[3:0]), .CO(c_1));
	 MUX2to1 MUX0 (.in0(Sum0[0]), .in1(Sum1[0]), .select(Cin), .out(Sum[0]));
	 MUX2to1 MUX1 (.in0(Sum0[1]), .in1(Sum1[1]), .select(Sum[0]), .out(Sum[1]));
	 MUX2to1 MUX2 (.in0(Sum0[2]), .in1(Sum1[2]), .select(Sum[1]), .out(Sum[2]));
	 MUX2to1 MUX3 (.in0(Sum0[3]), .in1(Sum1[3]), .select(Sum[2]), .out(Sum[3]));
	 
	 MUX2to1 MUX_CO (.in0(c_0), .in1(c_1), .select(Sum[3]), .out(CO));
endmodule 

module FA_4
(
	 input 	logic[3:0] 		 A,
	 input 	logic[3:0] 		 B,
	 input	logic				 Cin,
	 output	logic[3:0]		 Sum,
	 output	logic		 		 CO
);
	 logic Cout0, Cout1, Cout2;
	 // 4 bit Full Adder Module
	 FA FA0 (.x(A[0]), .y(B[0]), .cin(Cin), .s(Sum[0]), .cout(Cout0));
	 FA FA1 (.x(A[1]), .y(B[1]), .cin(Cout0), .s(Sum[1]), .cout(Cout1));
	 FA FA2 (.x(A[2]), .y(B[2]), .cin(Cout1), .s(Sum[2]), .cout(Cout2));
	 FA FA3 (.x(A[3]), .y(B[3]), .cin(Cout2), .s(Sum[3]), .cout(CO));
	 
endmodule

module FA
(
	 //1 bit base Full Adder
	 input x,
	 input y,
	 input cin,
	 output logic s,
	 output logic cout
);
	 assign s = x ^ y ^ cin;
	 assign cout = (x&y) | (y&cin) | (cin&x);
	
endmodule 

module MUX2to1
(
	 input logic in0,
	 input logic in1,
	 input logic select,
	 output logic out
);
	 
	 always_comb begin
//		 if (select)	out = in1;
//		 else 			out = in0;
		 out = (select) ? in1 : in0;
	 end
endmodule

