module carry_lookahead_adder
(
    input   logic[15:0]     A,
    input   logic[15:0]     B,
    output  logic[15:0]     Sum,
    output  logic           CO
);

    /* TODO
     *
     * Insert code here to implement a CLA adder.
     * Your code should be completly combinational (don't use always_ff or always_latch).
     * Feel free to create sub-modules or other files. */
	  logic C0, C1, C2;
	  
	  four_bit_cla FRA0(.x(A[3:0]  ), .y(B[3:0]  ), .cin(0 ), .s(Sum[3:0]  ), .cout(c0));
	  four_bit_cla FRA1(.x(A[7:4]  ), .y(B[7:4]  ), .cin(c0), .s(Sum[7:4]  ), .cout(c1));
	  four_bit_cla FRA2(.x(A[11:8] ), .y(B[11:8] ), .cin(c1), .s(Sum[11:8] ), .cout(c2));
	  four_bit_cla FRA3(.x(A[15:12]), .y(B[15:12]), .cin(c2), .s(Sum[15:12]), .cout(CO));
	  
endmodule
	  
module four_bit_cla(
						input [3:0] x,
						input [3:0] y,
						input cin,
						output logic [3:0] s,
						output logic cout
						);
	wire [3:0] p,g,c;
 
	assign p = x^y;
	assign g = x&y;
 
	assign c[0] =cin;
	assign c[1] = g[0]|(p[0]&c[0]);
	assign c[2] = g[1] | (p[1]&g[0]) | p[1]&p[0]&c[0];
	assign c[3] = g[2] | (p[2]&g[1]) | p[2]&p[1]&g[0] | p[2]&p[1]&p[0]&c[0];
	assign cout = g[3] | (p[3]&g[2]) | p[3]&p[2]&g[1] | p[3]&p[2]&p[1]&p[0]&c[0];
	assign s = p^c;
			 
endmodule
