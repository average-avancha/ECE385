module RA_four_bit (input [3:0] A, 
					 input [3:0] B, 
					 input cin, 
					 output logic [3:0] Sum, 
					 output logic cout);
					 
	logic c0, c1, c2;
	
	full_adder FA0 (.x(A[0]), .y(B[0]), .z(cin), .s(Sum[0]), .c(c1));
    full_adder FA1 (.x(A[1]), .y(B[1]), .z(c1), .s(Sum[1]), .c(c2));
    full_adder FA2 (.x(A[2]), .y(B[2]), .z(c2), .s(Sum[2]), .c(c3));
    full_adder FA3 (.x(A[3]), .y(B[3]), .z(c3), .s(Sum[3]), .c(cout));
endmodule 