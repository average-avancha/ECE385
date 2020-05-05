module mem_io (input logic Clk, Reset,
					input logic [19:0]  ADDR, 
					input logic CE, UB, LB, OE,
					output logic [15:0] sprite_data,
					output logic [3:0]  HEX0, HEX1, HEX2, HEX3);
					
	logic [15:0] hex_data;
	assign HEX0 = hex_data[3:0];
	assign HEX1 = hex_data[7:4];
	assign HEX2 = hex_data[11:8];
	assign HEX3 = hex_data[15:12];
	
	
endmodule
