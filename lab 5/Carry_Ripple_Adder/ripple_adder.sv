module ripple_adder
(
    input   logic[15:0]     A,
    input   logic[15:0]     B,
    output  logic[15:0]     Sum,
    output  logic           CO
);

	 logic C0, C1, C2;
	 
	 four_bit_RA FRA_0 (.x(A[3 : 0]), .y(B[3 : 0]), .c_in( 0), .s(Sum[3 : 0]), .c_out(C0));
	 four_bit_RA FRA_1 (.x(A[7 : 4]), .y(B[7 : 4]), .c_in(C0), .s(Sum[7 : 4]), .c_out(C1));
	 four_bit_RA FRA_2 (.x(A[11: 8]), .y(B[11: 8]), .c_in(C1), .s(Sum[11: 8]), .c_out(C2));
	 four_bit_RA FRA_3 (.x(A[15:12]), .y(B[15:12]), .c_in(C2), .s(Sum[15:12]), .c_out(CO));

	 
endmodule
