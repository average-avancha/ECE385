module carry_lookahead_adder(input   logic[15:0]     A,
									  input   logic[15:0]     B,
									  output  logic[15:0]     Sum,
									  output  logic           CO);
   logic C0, C4, C8, C12;
	logic [3:0] P, G;
	 
	
	lookahead_adder4 CLA0 (.A(A[3 : 0]), .B(B[3 : 0]), .c_in(C0), .S(Sum[3 : 0]), .P(P[0]), .G(G[0]));
	lookahead_adder4 CLA1 (.A(A[7 : 4]), .B(B[7 : 4]), .c_in(C4), .S(Sum[7 : 4]), .P(P[1]), .G(G[1]));
	lookahead_adder4 CLA2 (.A(A[11: 8]), .B(B[11: 8]), .c_in(C8), .S(Sum[11: 8]), .P(P[2]), .G(G[2]));
	lookahead_adder4 CLA3 (.A(A[15:12]), .B(B[15:12]), .c_in(C12),.S(Sum[15:12]), .P(P[3]), .G(G[3]));
	
	assign C0 = 0;
	assign C4 =  G[0]  | (C0 &  P[0]);
	assign C8 =  G[1]  | (C4 &  P[1]);
	assign C12 = G[2]  | (C8 &  P[2]);
	assign CO =  G[3]	 | (C12 & P[3]);
endmodule

module lookahead_adder4(input  logic[3:0]  A,
								input  logic[3:0]  B,
								input  logic       c_in,
								output logic[3:0]  S,
								output logic P, G);
	logic c0, c1, c2, c3;
	logic [3:0] p, g;
	
	assign p = A^B;
	assign g = A&B;
	
	assign c0 = c_in;
	assign c1 = g[0] | (c0 & p[0]);
	assign c2 = g[1] | (c1 & p[1]);
	assign c3 = g[2] | (c2 & p[2]);
	
	full_adder FA0 (.x(A[0]), .y(B[0]), .z(c_in),   .s(S[0]));
	full_adder FA1 (.x(A[1]), .y(B[1]), .z(  c1),   .s(S[1]));
	full_adder FA2 (.x(A[2]), .y(B[2]), .z(  c2),   .s(S[2]));
	full_adder FA3 (.x(A[3]), .y(B[3]), .z(  c3),   .s(S[3]));
	
	assign P = (p[0] & p[1] & p[2] & p[3]);
	assign G = (g[3] | (g[2] & p[3]) | (g[1] & p[3] & p[2]) | (g[0] & p[3] & p[2] & p[1]));
	
endmodule


module full_adder(input  logic x, y, z,
						output logic s);
	assign s = x^y^z;
	
endmodule
