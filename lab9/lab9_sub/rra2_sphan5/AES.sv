/************************************************************************
AES Decryption Core Logic

Dong Kai Wang, Fall 2017

For use with ECE 385 Experiment 9
University of Illinois ECE Department
************************************************************************/

module AES (
	input  logic CLK,
	input  logic RESET,
	input  logic AES_START,
	output logic AES_DONE,
	input  logic [127:0] AES_KEY,
	input  logic [127:0] AES_MSG_ENC,
	output logic [127:0] AES_MSG_DEC
);
	logic [1407:0] key_schedule;
	logic [127:0] curr_roundkey, next_roundkey, msg_dec, next_state, ARK_OUT, ISR_OUT, IMC_OUT, ISB_OUT, IMC_REG;
	logic [1:0] curr_func, curr_col;
	logic [3:0] LD_COL, curr_round;
	logic [31:0] word, next_word, inversed_word;
//	logic [31:0] col_0, col_1, col_2, col_3; 
	logic LD_MSG, INIT_REG, LD_RK;


	//state machine 
	DEC_SYS decryption_FSM (.CLK, .RESET, .AES_START, .AES_DONE, .round(curr_round), .LD_FUNC(curr_func), .CURR_COL(curr_col), .LD_IMC_REG(LD_COL), .LD_MSG_DEC(LD_MSG), .INIT_REG, .LD_RK); 

	//function declarations
	KeyExpansion  keyExpansion_  (.clk(CLK),         .Cipherkey(AES_KEY),      .KeySchedule(key_schedule));
	addRoundKey   addRoundKey_   (.state(msg_dec),   .roundKey(curr_roundkey), .out(ARK_OUT));
	InvShiftRows  InvShiftRows_  (.data_in(msg_dec), .data_out(ISR_OUT));
	InvMixColumns InvMixColumns_ (.in(word),         .out(inversed_word));

	//byte-by-byte inverse 
	InvSubBytes InvSubBytes_0  (.clk(CLK), .in(msg_dec[127:120]), .out(ISB_OUT[127:120]));
	InvSubBytes InvSubBytes_1  (.clk(CLK), .in(msg_dec[119:112]), .out(ISB_OUT[119:112]));
	InvSubBytes InvSubBytes_2  (.clk(CLK), .in(msg_dec[111:104]), .out(ISB_OUT[111:104]));
	InvSubBytes InvSubBytes_3  (.clk(CLK), .in(msg_dec[103:96]),  .out(ISB_OUT[103:96]));
	InvSubBytes InvSubBytes_4  (.clk(CLK), .in(msg_dec[95:88]),   .out(ISB_OUT[95:88]));
	InvSubBytes InvSubBytes_5  (.clk(CLK), .in(msg_dec[87:80]),   .out(ISB_OUT[87:80]));
	InvSubBytes InvSubBytes_6  (.clk(CLK), .in(msg_dec[79:72]),   .out(ISB_OUT[89:72]));
	InvSubBytes InvSubBytes_7  (.clk(CLK), .in(msg_dec[71:64]),   .out(ISB_OUT[71:64]));
	InvSubBytes InvSubBytes_8  (.clk(CLK), .in(msg_dec[63:56]),   .out(ISB_OUT[63:56]));
	InvSubBytes InvSubBytes_9  (.clk(CLK), .in(msg_dec[55:48]),   .out(ISB_OUT[55:48]));
	InvSubBytes InvSubBytes_10 (.clk(CLK), .in(msg_dec[47:40]),   .out(ISB_OUT[47:40]));
	InvSubBytes InvSubBytes_11 (.clk(CLK), .in(msg_dec[39:32]),   .out(ISB_OUT[39:32]));
	InvSubBytes InvSubBytes_12 (.clk(CLK), .in(msg_dec[31:24]),   .out(ISB_OUT[31:24]));
	InvSubBytes InvSubBytes_13 (.clk(CLK), .in(msg_dec[23:16]),   .out(ISB_OUT[23:16]));
	InvSubBytes InvSubBytes_14 (.clk(CLK), .in(msg_dec[15:8]),    .out(ISB_OUT[15:8]));
	InvSubBytes InvSubBytes_15 (.clk(CLK), .in(msg_dec[7:0]),     .out(ISB_OUT[7:0]));
	
	//register for building the final result of InvMixCols
	assign IMC_OUT = IMC_REG;
	always_ff @ (posedge CLK) begin
		if(RESET)
			IMC_REG <= 32'b0;
		else if(LD_COL[0])
			IMC_REG[127:96] <= inversed_word;
		else if(LD_COL[1])
			IMC_REG[95:64] <= inversed_word;
		else if(LD_COL[2])
			IMC_REG[63:32] <= inversed_word;
		else if(LD_COL[3])
			IMC_REG[31:0] <= inversed_word;
		else
			IMC_REG <= IMC_REG;
	end

	//msg_dec register, holds the current state of the decrypted message
	always_ff @ (posedge CLK) begin
		if(RESET || INIT_REG)
			msg_dec <= AES_MSG_ENC;
		else if(LD_MSG)  //if we're still in the decryption cycle, update the current state with the next appropriate output from the functions
			msg_dec <= next_state;
		else 					  //otherwise hold the current state
			msg_dec <= msg_dec;
	end
	
	always_ff @ (posedge CLK) begin
		if(RESET)
			curr_roundkey <= key_schedule[127:0];
		else if(LD_RK)  
			curr_roundkey <= next_roundkey;
		else 					  //otherwise hold the current state
			curr_roundkey <= curr_roundkey;
	end
	
	always_comb begin
		//grab the current round key from the expanded key schedule for ARK
		case(curr_round)
			4'b0000:  next_roundkey = key_schedule[127:0];
			4'b0001:  next_roundkey = key_schedule[255:128];
			4'b0010:  next_roundkey = key_schedule[383:256];
			4'b0011:  next_roundkey = key_schedule[511:384];
			4'b0100:  next_roundkey = key_schedule[639:512];
			4'b0101:  next_roundkey = key_schedule[767:640];
			4'b0110:  next_roundkey = key_schedule[895:768];
			4'b0111:  next_roundkey = key_schedule[1023:896];
			4'b1000:  next_roundkey = key_schedule[1151:1024];
			4'b1001:  next_roundkey = key_schedule[1279:1152];
			4'b1010:  next_roundkey = key_schedule[1407:1280];
			default:  next_roundkey = 128'bx;
			
		endcase

		//grab the current word from the msg_dec state to use for InvMixcol
		case(curr_col)
			2'b00:   word = msg_dec[127:96];
			2'b01:   word = msg_dec[95:64];
			2'b10:   word = msg_dec[63:32];
			2'b11:   word = msg_dec[31:0];
			default: word = 32'bx;
		endcase

		//based on the current round and part of the round, the next_state will be the output of 1 of the 4 functions
		case(curr_func)
			2'b00: next_state = ARK_OUT;
			2'b01: next_state = ISR_OUT;
			2'b10: next_state = IMC_OUT;
			2'b11: next_state = ISB_OUT;
			default: ;
		endcase
	end

	assign AES_MSG_DEC = msg_dec;
	//assign AES_MSG_DEC = key_schedule[1023:896];
	//assign AES_MSG_DEC = curr_roundkey;
	//assign AES_MSG_DEC = IMC_REG;
	
endmodule

module DEC_SYS (input logic CLK,
				input logic RESET, 
				input  logic AES_START,
				output logic AES_DONE,
				output logic [3:0] round,
				output logic [1:0] LD_FUNC,
				output logic [1:0] CURR_COL,
				output logic [3:0] LD_IMC_REG,
				output logic LD_MSG_DEC,
				output logic INIT_REG,
				output logic LD_RK);

	enum logic [6:0]   {WAIT,
						KE_0,
						KE_1,
						KE_2,
						KE_3,
						KE_4,
						KE_5,
						KE_6,
						KE_7,
						KE_8,
						KE_9,
						KE_10,
						ARK_0_0,
						ARK_0_1,
						ISR_1,
						ISB_1,
						ARK_1_0,
						ARK_1_1,
						IMC_1_0,
						IMC_1_1,
						IMC_1_2,
						IMC_1_3,
						IMC_1_4,
						ISR_2,
						ISB_2,
						ARK_2_0,
						ARK_2_1,
						IMC_2_0,
						IMC_2_1,
						IMC_2_2,
						IMC_2_3,
						IMC_2_4,
						ISR_3,
						ISB_3,
						ARK_3_0,
						ARK_3_1,
						IMC_3_0,
						IMC_3_1,
						IMC_3_2,
						IMC_3_3,
						IMC_3_4,
						ISR_4,
						ISB_4,
						ARK_4_0,
						ARK_4_1,
						IMC_4_0,
						IMC_4_1,
						IMC_4_2,
						IMC_4_3,
						IMC_4_4,
						ISR_5,
						ISB_5,
						ARK_5_0,
						ARK_5_1,
						IMC_5_0,
						IMC_5_1,
						IMC_5_2,
						IMC_5_3,
						IMC_5_4,
						ISR_6,
						ISB_6,
						ARK_6_0,
						ARK_6_1,
						IMC_6_0,
						IMC_6_1,
						IMC_6_2,
						IMC_6_3,
						IMC_6_4,
						ISR_7,
						ISB_7,
						ARK_7_0,
						ARK_7_1,
						IMC_7_0,
						IMC_7_1,
						IMC_7_2,
						IMC_7_3,
						IMC_7_4,
						ISR_8,
						ISB_8,
						ARK_8_0,
						ARK_8_1,
						IMC_8_0,
						IMC_8_1,
						IMC_8_2,
						IMC_8_3,
						IMC_8_4,
						ISR_9,
						ISB_9,
						ARK_9_0,
						ARK_9_1,
						IMC_9_0,
						IMC_9_1,
						IMC_9_2,
						IMC_9_3,
						IMC_9_4,
						ISR_10,
						ISB_10,
						ARK_10_0,
						ARK_10_1,
						DONE} state, next_state; 

	always_ff @ (posedge CLK) begin
		if(RESET)
			state <= WAIT;
		else
			state <= next_state;
	end
	
	always_comb begin
		//default control signals 
		next_state = state;
		LD_RK = 1'b0;
		AES_DONE = 1'b0;
		round = 4'b0000;
		LD_FUNC = 2'b00;
		CURR_COL = 2'b00;
		LD_IMC_REG = 4'b0000;
		LD_MSG_DEC = 1'b0;
		INIT_REG = 1'b0;

		//assign next state
		unique case (state)
			WAIT :
				if(AES_START)
					next_state = KE_0;
			KE_0 :
				next_state = KE_1;
			KE_1 :
				next_state = KE_2;
			KE_2 :
				next_state = KE_3;
			KE_3 :
				next_state = KE_4;
			KE_4 :
				next_state = KE_5;
			KE_5 :
				next_state = KE_6;
			KE_6 :
				next_state = KE_7;
			KE_7 :
				next_state = KE_8;
			KE_8 :
				next_state = KE_9;
			KE_9 :
				next_state = KE_10;
			KE_10 :
				next_state = ARK_0_0;
			ARK_0_0 :
				next_state = ARK_0_1;
			ARK_0_1 :
				next_state = ISR_1;
			ISR_1 :
				next_state = ISB_1;
			ISB_1 :
				next_state = ARK_1_0;
			ARK_1_0 :
				next_state = ARK_1_1;
			ARK_1_1:
				next_state = IMC_1_0;
			IMC_1_0 :
				next_state = IMC_1_1;
			IMC_1_1 :
				next_state = IMC_1_2;
			IMC_1_2 :
				next_state = IMC_1_3;
			IMC_1_3 :
				next_state = IMC_1_4;
			IMC_1_4 :
				next_state = ISR_2;
			ISR_2 :
				next_state = ISB_2;
			ISB_2 :
				next_state = ARK_2_0;
			ARK_2_0 :
				next_state = ARK_2_1;
			ARK_2_1:
				next_state = IMC_2_0;
			IMC_2_0 :
				next_state = IMC_2_1;
			IMC_2_1 :
				next_state = IMC_2_2;
			IMC_2_2 :
				next_state = IMC_2_3;
			IMC_2_3 :
				next_state = IMC_2_4;
			IMC_2_4 :
				next_state = ISR_3;
			ISR_3 :
				next_state = ISB_3;
			ISB_3 :
				next_state = ARK_3_0;
			ARK_3_0 :
				next_state = ARK_3_1;
			ARK_3_1:
				next_state = IMC_3_0;
			IMC_3_0 :
				next_state = IMC_3_1;
			IMC_3_1 :
				next_state = IMC_3_2;
			IMC_3_2 :
				next_state = IMC_3_3;
			IMC_3_3 :
				next_state = IMC_3_4;
			IMC_3_4 :
				next_state = ISR_4;
			ISR_4 :
				next_state = ISB_4;
			ISB_4 :
				next_state = ARK_4_0;
			ARK_4_0 :
				next_state = ARK_4_1;
			ARK_4_1:
				next_state = IMC_4_0;
			IMC_4_0 :
				next_state = IMC_4_1;
			IMC_4_1 :
				next_state = IMC_4_2;
			IMC_4_2 :
				next_state = IMC_4_3;
			IMC_4_3 :
				next_state = IMC_4_4;
			IMC_4_4 :
				next_state = ISR_5;
			ISR_5 :
				next_state = ISB_5;
			ISB_5 :
				next_state = ARK_5_0;
			ARK_5_0 :
				next_state = ARK_5_1;
			ARK_5_1:
				next_state = IMC_5_0;
			IMC_5_0 :
				next_state = IMC_5_1;
			IMC_5_1 :
				next_state = IMC_5_2;
			IMC_5_2 :
				next_state = IMC_5_3;
			IMC_5_3 :
				next_state = IMC_5_4;
			IMC_5_4 :
				next_state = ISR_6;
			ISR_6 :
				next_state = ISB_6;
			ISB_6 :
				next_state = ARK_6_0;
			ARK_6_0 :
				next_state = ARK_6_1;
			ARK_6_1:
				next_state = IMC_6_0;
			IMC_6_0 :
				next_state = IMC_6_1;
			IMC_6_1 :
				next_state = IMC_6_2;
			IMC_6_2 :
				next_state = IMC_6_3;
			IMC_6_3 :
				next_state = IMC_6_4;
			IMC_6_4 :
				next_state = ISR_7;
			ISR_7 :
				next_state = ISB_7;
			ISB_7 :
				next_state = ARK_7_0;
			ARK_7_0 :
				next_state = ARK_7_1;
			ARK_7_1:
				next_state = IMC_7_0;
			IMC_7_0 :
				next_state = IMC_7_1;
			IMC_7_1 :
				next_state = IMC_7_2;
			IMC_7_2 :
				next_state = IMC_7_3;
			IMC_7_3 :
				next_state = IMC_7_4;
			IMC_7_4 :
				next_state = ISR_8;
			ISR_8 :
				next_state = ISB_8;
			ISB_8 :
				next_state = ARK_8_0;
			ARK_8_0 :
				next_state = ARK_8_1;
			ARK_8_1:
				next_state = IMC_8_0;
			IMC_8_0 :
				next_state = IMC_8_1;
			IMC_8_1 :
				next_state = IMC_8_2;
			IMC_8_2 :
				next_state = IMC_8_3;
			IMC_8_3 :
				next_state = IMC_8_4;
			IMC_8_4 :
				next_state = ISR_9;
			ISR_9 :
				next_state = ISB_9;
			ISB_9 :
				next_state = ARK_9_0;
			ARK_9_0 :
				next_state = ARK_9_1;
			ARK_9_1:
				next_state = IMC_9_0;
			IMC_9_0 :
				next_state = IMC_9_1;
			IMC_9_1 :
				next_state = IMC_9_2;
			IMC_9_2 :
				next_state = IMC_9_3;
			IMC_9_3 :
				next_state = IMC_9_4;
			IMC_9_4 :
				next_state = ISR_10;
			ISR_10 :
				next_state = ISB_10;
			ISB_10 :
				next_state = ARK_10_0;
			ARK_10_0 :
				next_state = ARK_10_1;
			ARK_10_1:
				next_state = DONE;
			DONE :
				if(AES_START == 1'b0)
					next_state = WAIT;
			default :
				next_state = WAIT;
		endcase

		
		//default control signals 
		// next_state = state;
		// LD_RK = 1'b0;
		// AES_DONE = 1'b0;
		// round = 4'b0000;
		// LD_FUNC = 2'b00;
		// CURR_COL = 2'b00;
		// LD_IMC_REG = 4'b0000;
		// LD_MSG_DEC = 1'b0;
		// INIT_REG = 1'b0;


		case (state)
			WAIT : ;
			KE_0 : ;
			KE_1 : ;
			KE_2 : ;
			KE_3 : ;
			KE_4 : ;
			KE_5 : ;
			KE_6 : ;
			KE_7 : ;
			KE_8 : ;
			KE_9 : ;
			KE_10 : 
				INIT_REG = 1'b1;
			ARK_0_0 :
				begin
					round = 4'b0000;
					LD_RK = 1'b1;
				end
			ARK_0_1 : 
				begin
					round = 4'b0000;
					LD_FUNC = 2'b00;
					LD_MSG_DEC = 1'b1;
					LD_RK = 1'b1;
				end
			ISR_1 : 
				begin
					round = 4'b0001;
					LD_FUNC = 2'b01;
					LD_MSG_DEC = 1'b1;
				end
			ISB_1 : 
				begin
					round = 4'b0001;
					LD_FUNC = 2'b11;
					LD_MSG_DEC = 1'b1;
				end
			ARK_1_0:
				begin
					round = 4'b0001;
					LD_RK = 1'b1;
				end
			ARK_1_1 : 
				begin
					round = 4'b0001;
					LD_FUNC = 2'b00;
					LD_MSG_DEC = 1'b1;
					LD_RK = 1'b1;
				end
			IMC_1_0 : 
				begin
					round = 4'b0001;
					CURR_COL = 2'b00;
					LD_IMC_REG = 4'b0001;
				end
			IMC_1_1 : 
				begin
					round = 4'b0001;
					CURR_COL = 2'b01;
					LD_IMC_REG = 4'b0010;
				end
			IMC_1_2 : 
				begin
					round = 4'b0001;
					CURR_COL = 2'b10;
					LD_IMC_REG = 4'b0100;
				end
			IMC_1_3 : 
				begin
					round = 4'b0001;
					CURR_COL = 2'b11;
					LD_IMC_REG = 4'b1000;
				end
			IMC_1_4 : 
				begin
					round = 4'b0001;
					LD_FUNC = 2'b10;
					LD_MSG_DEC = 1'b1;
				end
			ISR_2 : 
				begin
					round = 4'b0010;
					LD_FUNC = 2'b01;
					LD_MSG_DEC = 1'b1;
				end
			ISB_2 : 
				begin
					round = 4'b0010;
					LD_FUNC = 2'b11;
					LD_MSG_DEC = 1'b1;
				end
			ARK_2_0:
				begin
					round = 4'b0010;
					LD_RK = 1'b1;
				end
			ARK_2_1 : 
				begin
					round = 4'b0010;
					LD_FUNC = 2'b00;
					LD_MSG_DEC = 1'b1;
					LD_RK = 1'b1;
				end
			IMC_2_0 : 
				begin
					round = 4'b0010;
					CURR_COL = 2'b00;
					LD_IMC_REG = 4'b0001;
				end
			IMC_2_1 : 
				begin
					round = 4'b0010;
					CURR_COL = 2'b01;
					LD_IMC_REG = 4'b0010;
				end
			IMC_2_2 : 
				begin
					round = 4'b0010;
					CURR_COL = 2'b10;
					LD_IMC_REG = 4'b0100;
				end
			IMC_2_3 : 
				begin
					round = 4'b0010;
					CURR_COL = 2'b11;
					LD_IMC_REG = 4'b1000;
				end
			IMC_2_4 : 
				begin
					round = 4'b0010;
					LD_FUNC = 2'b10;
					LD_MSG_DEC = 1'b1;
				end
			ISR_3 : 
				begin
					round = 4'b0011;
					LD_FUNC = 2'b01;
					LD_MSG_DEC = 1'b1;
				end
			ISB_3 : 
				begin
					round = 4'b0011;
					LD_FUNC = 2'b11;
					LD_MSG_DEC = 1'b1;
				end
			ARK_3_0:
				begin
					round = 4'b0011;
					LD_RK = 1'b1;
				end
			ARK_3_1 : 
				begin
					round = 4'b0011;
					LD_FUNC = 2'b00;
					LD_MSG_DEC = 1'b1;
					LD_RK = 1'b1;
				end
			IMC_3_0 : 
				begin
					round = 4'b0011;
					CURR_COL = 2'b00;
					LD_IMC_REG = 4'b0001;
				end
			IMC_3_1 : 
				begin
					round = 4'b0011;
					CURR_COL = 2'b01;
					LD_IMC_REG = 4'b0010;
				end
			IMC_3_2 : 
				begin
					round = 4'b0011;
					CURR_COL = 2'b10;
					LD_IMC_REG = 4'b0100;
				end
			IMC_3_3 : 
				begin
					round = 4'b0011;
					CURR_COL = 2'b11;
					LD_IMC_REG = 4'b1000;
				end
			IMC_3_4 : 
				begin
					round = 4'b0011;
					LD_FUNC = 2'b10;
					LD_MSG_DEC = 1'b1;
				end
			ISR_4 : 
				begin
					round = 4'b0100;
					LD_FUNC = 2'b01;
					LD_MSG_DEC = 1'b1;
				end
			ISB_4 : 
				begin
					round = 4'b0100;
					LD_FUNC = 2'b11;
					LD_MSG_DEC = 1'b1;
				end
			ARK_4_0:
				begin
					round = 4'b0100;
					LD_RK = 1'b1;
				end
			ARK_4_1 : 
				begin
					round = 4'b0100;
					LD_FUNC = 2'b00;
					LD_MSG_DEC = 1'b1;
					LD_RK = 1'b1;
				end
			IMC_4_0 : 
				begin
					round = 4'b0100;
					CURR_COL = 2'b00;
					LD_IMC_REG = 4'b0001;
				end
			IMC_4_1 : 
				begin
					round = 4'b0100;
					CURR_COL = 2'b01;
					LD_IMC_REG = 4'b0010;
				end
			IMC_4_2 : 
				begin
					round = 4'b0100;
					CURR_COL = 2'b10;
					LD_IMC_REG = 4'b0100;
				end
			IMC_4_3 : 
				begin
					round = 4'b0100;
					CURR_COL = 2'b11;
					LD_IMC_REG = 4'b1000;
				end
			IMC_4_4 : 
				begin
					round = 4'b0100;
					LD_FUNC = 2'b10;
					LD_MSG_DEC = 1'b1;
				end
			ISR_5 : 
				begin
					round = 4'b0101;
					LD_FUNC = 2'b01;
					LD_MSG_DEC = 1'b1;
				end
			ISB_5 : 
				begin
					round = 4'b0101;
					LD_FUNC = 2'b11;
					LD_MSG_DEC = 1'b1;
				end
			ARK_5_0:
				begin
					round = 4'b0101;
					LD_RK = 1'b1;
				end
			ARK_5_1 : 
				begin
					round = 4'b0101;
					LD_FUNC = 2'b00;
					LD_MSG_DEC = 1'b1;
					LD_RK = 1'b1;
				end
			IMC_5_0 : 
				begin
					round = 4'b0101;
					CURR_COL = 2'b00;
					LD_IMC_REG = 4'b0001;
				end
			IMC_5_1 : 
				begin
					round = 4'b0101;
					CURR_COL = 2'b01;
					LD_IMC_REG = 4'b0010;
				end
			IMC_5_2 : 
				begin
					round = 4'b0101;
					CURR_COL = 2'b10;
					LD_IMC_REG = 4'b0100;
				end
			IMC_5_3 : 
				begin
					round = 4'b0101;
					CURR_COL = 2'b11;
					LD_IMC_REG = 4'b1000;
				end
			IMC_5_4 : 
				begin
					round = 4'b0101;
					LD_FUNC = 2'b10;
					LD_MSG_DEC = 1'b1;
				end
			ISR_6 : 
				begin
					round = 4'b0110;
					LD_FUNC = 2'b01;
					LD_MSG_DEC = 1'b1;
				end
			ISB_6 : 
				begin
					round = 4'b0110;
					LD_FUNC = 2'b11;
					LD_MSG_DEC = 1'b1;
				end
			ARK_6_0:
				begin
					round = 4'b0110;
					LD_RK = 1'b1;
				end
			ARK_6_1 : 
				begin
					round = 4'b0110;
					LD_FUNC = 2'b00;
					LD_MSG_DEC = 1'b1;
					LD_RK = 1'b1;
				end
			IMC_6_0 : 
				begin
					round = 4'b0110;
					CURR_COL = 2'b00;
					LD_IMC_REG = 4'b0001;
				end
			IMC_6_1 : 
				begin
					round = 4'b0110;
					CURR_COL = 2'b01;
					LD_IMC_REG = 4'b0010;
				end
			IMC_6_2 : 
				begin
					round = 4'b0110;
					CURR_COL = 2'b10;
					LD_IMC_REG = 4'b0100;
				end
			IMC_6_3 : 
				begin
					round = 4'b0110;
					CURR_COL = 2'b11;
					LD_IMC_REG = 4'b1000;
				end
			IMC_6_4 : 
				begin
					round = 4'b0110;
					LD_FUNC = 2'b10;
					LD_MSG_DEC = 1'b1;
				end
			ISR_7 : 
				begin
					round = 4'b0111;
					LD_FUNC = 2'b01;
					LD_MSG_DEC = 1'b1;
				end
			ISB_7 : 
				begin
					round = 4'b0111;
					LD_FUNC = 2'b11;
					LD_MSG_DEC = 1'b1;
				end
			ARK_7_0:
				begin
					round = 4'b0111;
					LD_RK = 1'b1;
				end
			ARK_7_1 : 
				begin
					round = 4'b0111;
					LD_FUNC = 2'b00;
					LD_MSG_DEC = 1'b1;
					LD_RK = 1'b1;
				end
			IMC_7_0 : 
				begin
					round = 4'b0111;
					CURR_COL = 2'b00;
					LD_IMC_REG = 4'b0001;
				end
			IMC_7_1 : 
				begin
					round = 4'b0111;
					CURR_COL = 2'b01;
					LD_IMC_REG = 4'b0010;
				end
			IMC_7_2 : 
				begin
					round = 4'b0111;
					CURR_COL = 2'b10;
					LD_IMC_REG = 4'b0100;
				end
			IMC_7_3 : 
				begin
					round = 4'b0111;
					CURR_COL = 2'b11;
					LD_IMC_REG = 4'b1000;
				end
			IMC_7_4 : 
				begin
					round = 4'b0111;
					LD_FUNC = 2'b10;
					LD_MSG_DEC = 1'b1;
				end
			ISR_8 : 
				begin
					round = 4'b1000;
					LD_FUNC = 2'b01;
					LD_MSG_DEC = 1'b1;
				end
			ISB_8 : 
				begin
					round = 4'b1000;
					LD_FUNC = 2'b11;
					LD_MSG_DEC = 1'b1;
				end
			ARK_8_0:
				begin
					round = 4'b1000;
					LD_RK = 1'b1;
				end
			ARK_8_1 : 
				begin
					round = 4'b1000;
					LD_FUNC = 2'b00;
					LD_MSG_DEC = 1'b1;
					LD_RK = 1'b1;
				end
			IMC_8_0 : 
				begin
					round = 4'b1000;
					CURR_COL = 2'b00;
					LD_IMC_REG = 4'b0001;
				end
			IMC_8_1 : 
				begin
					round = 4'b1000;
					CURR_COL = 2'b01;
					LD_IMC_REG = 4'b0010;
				end
			IMC_8_2 : 
				begin
					round = 4'b1000;
					CURR_COL = 2'b10;
					LD_IMC_REG = 4'b0100;
				end
			IMC_8_3 : 
				begin
					round = 4'b1000;
					CURR_COL = 2'b11;
					LD_IMC_REG = 4'b1000;
				end
			IMC_8_4 : 
				begin
					round = 4'b1000;
					LD_FUNC = 2'b10;
					LD_MSG_DEC = 1'b1;
				end
			ISR_9 : 
				begin
					round = 4'b1001;
					LD_FUNC = 2'b01;
					LD_MSG_DEC = 1'b1;
				end
			ISB_9 : 
				begin
					round = 4'b1001;
					LD_FUNC = 2'b11;
					LD_MSG_DEC = 1'b1;
				end
			ARK_9_0:
				begin
					round = 4'b1001;
					LD_RK = 1'b1;
				end
			ARK_9_1 : 
				begin
					round = 4'b1001;
					LD_FUNC = 2'b00;
					LD_MSG_DEC = 1'b1;
					LD_RK = 1'b1;
				end
			IMC_9_0 : 
				begin
					round = 4'b1001;
					CURR_COL = 2'b00;
					LD_IMC_REG = 4'b0001;
				end
			IMC_9_1 : 
				begin
					round = 4'b1001;
					CURR_COL = 2'b01;
					LD_IMC_REG = 4'b0010;
				end
			IMC_9_2 : 
				begin
					round = 4'b1001;
					CURR_COL = 2'b10;
					LD_IMC_REG = 4'b0100;
				end
			IMC_9_3 : 
				begin
					round = 4'b1001;
					CURR_COL = 2'b11;
					LD_IMC_REG = 4'b1000;
				end
			IMC_9_4 : 
				begin
					round = 4'b1001;
					LD_FUNC = 2'b10;
					LD_MSG_DEC = 1'b1;
				end
			ISR_10 : 
				begin
					round = 4'b1010;
					LD_FUNC = 2'b01;
					LD_MSG_DEC = 1'b1;
				end
			ISB_10 : 
				begin
					round = 4'b1010;
					LD_FUNC = 2'b11;
					LD_MSG_DEC = 1'b1;
				end
			ARK_10_0:
				begin
					round = 4'b1010;
					LD_RK = 1'b1;
				end
			ARK_10_1 : 
				begin
					round = 4'b1010;
					LD_FUNC = 2'b00;
					LD_MSG_DEC = 1'b1;
					LD_RK = 1'b1;
				end
			DONE : 
				AES_DONE = 1'b1;
			default : ;
		endcase

	end
	
endmodule


// module MUX_4_to_1(input logic n,
// 						input logic [1:0] s,
// 						input logic [n-1: 0] a,
// 						input logic [n-1: 0] b,
// 						input logic [n-1: 0] c,
// 						input logic [n-1: 0] d
// 						output logic [n-1: 0] out);		
// 	always_comb begin
// 		case(s):
// 			2'b00: out = a;
// 			2'b01: out = b;
// 			2'b10: out = c;
// 			2'b11: out = d;
// 		endcase
// 	end
// endmodule

