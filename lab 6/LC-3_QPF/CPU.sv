module CPU  (input logic Run, Reset, Continue, Clk
			 input logic [2:0] nzp,
			 output logic [2:0] nzp,
			 inout logic [15:0] Data_CPU);
	logic LD_MAR, LD_MDR, LD_IR;
	logic [15:0] Bus, MAR_out, MDR_out, IR_in, IR_out;
	reg_16 MAR (.Clk, .Reset, .Load(LD_MAR), .D(Bus), .Q(MAR_out));
	reg_16 MAR (.Clk, .Reset, .Load(LD_MDR), .D(Bus), .Q(MDR_out));
	reg_16 MAR (.Clk, .Reset, .Load(LD_IR), .D(Bus), .Q(IR_out));	
endmodule

module reg_16	(input logic Clk, Reset, Load,
				 input logic [15:0] D,
				 output logic [15:0] Q);
	always_ff @ (posedge Clk)
    begin
	 	if (Reset)
			Q <= 16'h0;
		else if (Load)
			Q <= D;
		else
			Q <= Q;
    end
endmodule