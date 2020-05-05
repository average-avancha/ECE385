module carry_select_adder
(
    input   logic[15:0]     A,
    input   logic[15:0]     B,
    output  logic[15:0]     Sum,
    output  logic           CO
);

    /* TODO
     *
     * Insert code here to implement a carry select.
     * Your code should be completly combinational (don't use always_ff or always_latch).
     * Feel free to create sub-modules or other files. */
	  logic C0, C1, C2;
	  
	  four_bit_csa FRA0(.x(A[3:0]  ), .y(B[3:0]  ), .cin(0 ), .s(Sum[3:0]  ), .cout(c0));
	  four_bit_csa FRA1(.x(A[7:4]  ), .y(B[7:4]  ), .cin(c0), .s(Sum[7:4]  ), .cout(c1));
	  four_bit_csa FRA2(.x(A[11:8] ), .y(B[11:8] ), .cin(c1), .s(Sum[11:8] ), .cout(c2));
	  four_bit_csa FRA3(.x(A[15:12]), .y(B[15:12]), .cin(c2), .s(Sum[15:12]), .cout(CO));
     
endmodule

module four_bit_csa(
						input [3:0] x,
						input [3:0] y,
						input cin,
						output logic [3:0] s,
						output logic cout
						);
 
	wire [3:0] s0,s1;
	wire c0,c1;
 
	four_bit_ra ra0(.x(x[3:0]),.y(y[3:0]),.cin(1'b0),.s(s0[3:0]),.cout(c0));
	four_bit_ra ra1(.x(x[3:0]),.y(y[3:0]),.cin(1'b1),.s(s1[3:0]),.cout(c1));
 
	MUX_2by1 mux_s(.in0(s0[3:0]),.in1(s1[3:0]),.select(cin),.out(s[3:0]));
	MUX_2by1 mux_c(.in0(c0),.in1(c1),.select(cin),.out(cout));

endmodule


module MUX_2by1( 
				input [3:0] in0,
				input [3:0] in1,
				input select,
				output [3:0] out
				);
	assign out = (select)?in1:in0;
	
endmodule

