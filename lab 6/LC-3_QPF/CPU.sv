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

module reg_file(input  logic Clk, Reset, LD_REG,
					 input  logic [15:0] Input,
					 input  logic [2 :0] DR, SR1, SR2, 
					 output logic [15:0] SR1_OUT, SR2_OUT);
		
		 logic[7:0][15:0] register;
		 
// 	 ABANDON USING REG_16 AND INSTANSIATING THEM IN HERE, TOO MUCH COMBINATIONAL LOGIC
//		 logic ld_0, ld_1, ld_2, ld_3, ld_4, ld_5, ld_6, ld_7; 
//		 logic input_0, input_1, input_2, input_3, input_4, input_5, input_6, input_7;
		 
//		 reg_16 R0 (.Clk, .Reset, .Shift_En(0), .Shift_In(), .Load(ld_0), .D(input0), .Shift_Out(), .Q(register[0]));
//		 reg_16 R1 (.Clk, .Reset, .Shift_En(0), .Shift_In(), .Load(ld_1), .D(input1), .Shift_Out(), .Q(register[1]));
//		 reg_16 R2 (.Clk, .Reset, .Shift_En(0), .Shift_In(), .Load(ld_2), .D(input2), .Shift_Out(), .Q(register[2]));
//		 reg_16 R3 (.Clk, .Reset, .Shift_En(0), .Shift_In(), .Load(ld_3), .D(input3), .Shift_Out(), .Q(register[3]));
//		 reg_16 R4 (.Clk, .Reset, .Shift_En(0), .Shift_In(), .Load(ld_4), .D(input4), .Shift_Out(), .Q(register[4]));
//		 reg_16 R5 (.Clk, .Reset, .Shift_En(0), .Shift_In(), .Load(ld_5), .D(input5), .Shift_Out(), .Q(register[5]));
//		 reg_16 R6 (.Clk, .Reset, .Shift_En(0), .Shift_In(), .Load(ld_6), .D(input6), .Shift_Out(), .Q(register[6]));
//		 reg_16 R7 (.Clk, .Reset, .Shift_En(0), .Shift_In(), .Load(ld_7), .D(input7), .Shift_Out(), .Q(register[7]));

		 always_ff @ (posedge Clk)
		 begin
			register[0] <= register[0];
			register[1] <= register[1];
			register[2] <= register[2];
			register[3] <= register[3];
			register[4] <= register[4];
			register[5] <= register[5];
			register[6] <= register[6];
			register[7] <= register[7];
			if(Reset)
				begin
					register[0] <= 16'h0;
					register[1] <= 16'h0;
					register[2] <= 16'h0;
					register[3] <= 16'h0;
					register[4] <= 16'h0;
					register[5] <= 16'h0;
					register[6] <= 16'h0;
					register[7] <= 16'h0;
				end
			else if (LD_REG)
				case(DR)
					3'b000: register[0] <= Input;
					3'b001: register[1] <= Input;
					3'b010: register[2] <= Input;
					3'b011: register[3] <= Input;
					3'b100: register[4] <= Input;
					3'b101: register[5] <= Input;
					3'b110: register[6] <= Input;
					3'b111: register[7] <= Input;
				endcase
		 end
		 
		 always_comb
		 begin
			case(SR1)
				3'b000: SR1_OUT = register[0];
				3'b001: SR1_OUT = register[1];
				3'b010: SR1_OUT = register[2];
				3'b011: SR1_OUT = register[3];
				3'b100: SR1_OUT = register[4];
				3'b101: SR1_OUT = register[5];
				3'b110: SR1_OUT = register[6];
				3'b111: SR1_OUT = register[7];
			endcase
			case(SR2)
				3'b000: SR2_OUT = register[0];
				3'b001: SR2_OUT = register[1];
				3'b010: SR2_OUT = register[2];
				3'b011: SR2_OUT = register[3];
				3'b100: SR2_OUT = register[4];
				3'b101: SR2_OUT = register[5];
				3'b110: SR2_OUT = register[6];
				3'b111: SR2_OUT = register[7];
			endcase
		 end
endmodule 