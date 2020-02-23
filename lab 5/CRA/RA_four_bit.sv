module RA_four_bit (input [3:0] x, 
					 input [3:0] y, 
					 input cin, 
					 output logic [3:0] s, 
					 output logic cout);
					 
	logic c0, c1, c2;
	
	full_adder FA0 (.x(x[0]), .y(y[0]), .z(cin), .s(s[0]), .c(c1));
    full_adder FA1 (.x(x[1]), .y(y[1]), .z(c1), .s(s[1]), .c(c2));
    full_adder FA2 (.x(x[2]), .y(y[2]), .z(c2), .s(s[2]), .c(c3));
    full_adder FA3 (.x(x[3]), .y(y[3]), .z(c3), .s(s[3]), .c(cout));
endmodule 