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
	logic LD_MSG, INIT_REG;


	//state machine 
	DEC_SYS decryption_FSM (.CLK, .RESET, .AES_START, .AES_DONE, .round(curr_round), .LD_FUNC(curr_func), .CURR_COL(curr_col), .LD_IMC_REG(LD_COL), .LD_MSG_DEC(LD_MSG), .INIT_REG); 

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
	InvSubBytes InvSubBytes_6  (.clk(CLK), .in(msg_dec[79:72]),   .out(ISB_OUT[79:72]));
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
	
	always_comb begin
		//grab the current round key from the expanded key schedule for ARK
		case(curr_round)
			4'b0000:  curr_roundkey = key_schedule[127:0];
			4'b0001:  curr_roundkey = key_schedule[255:128];
			4'b0010:  curr_roundkey = key_schedule[383:256];
			4'b0011:  curr_roundkey = key_schedule[511:384];
			4'b0100:  curr_roundkey = key_schedule[639:512];
			4'b0101:  curr_roundkey = key_schedule[767:640];
			4'b0110:  curr_roundkey = key_schedule[895:768];
			4'b0111:  curr_roundkey = key_schedule[1023:896];
			4'b1000:  curr_roundkey = key_schedule[1151:1024];
			4'b1001:  curr_roundkey = key_schedule[1279:1152];
			4'b1010:  curr_roundkey = key_schedule[1407:1280];
			default:  curr_roundkey = 128'bx;
			
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
				output logic INIT_REG);

	enum logic [3:0]   {WAIT,
						KE,
						INIT,
						ARK,
						ISR,
						ISB,
						IMC_0,
						IMC_1,
						IMC_2,
						IMC_3,
						IMC_4,
						DONE} state, next_state; 

	always_ff @ (posedge CLK) begin
		if(RESET)
			state <= WAIT;
		else
			state <= next_state;
	end
	
	logic [3:0] key_wait, next_key_wait;
	always_ff @ (posedge CLK) begin
		if(RESET)
			key_wait <= 4'b0000;
		else
			key_wait <= next_key_wait;
	end

	logic [3:0] next_round;
	always_ff @ (posedge CLK) begin
		if(RESET)
			round <= 4'b0000;
		else
			round <= next_round;
	end

	always_comb begin
		//default control signals 
		next_state = state;
		next_round = round;
		next_key_wait = key_wait;
		AES_DONE = 1'b0;
		LD_FUNC = 2'b00;
		CURR_COL = 2'b00;
		LD_IMC_REG = 4'b0000;
		LD_MSG_DEC = 1'b0;
		INIT_REG = 1'b0;

		//assign next state
		unique case (state)
			WAIT :
				if(AES_START)
					next_state = KE;
			KE :
				if(key_wait > 4'b1001)
					next_state = INIT;
			INIT :
				next_state = ARK;
			ARK :
				if(round == 4'b0000)
					next_state = ISR;
				else if(round == 4'b1010)
					next_state = DONE;
				else
					next_state = IMC_0;
			ISR :
				next_state = ISB;
			ISB :
				next_state = ARK;
			IMC_0 :
				next_state = IMC_1;
			IMC_1 :
				next_state = IMC_2;
			IMC_2 :
				next_state = IMC_3;
			IMC_3 :
				next_state = IMC_4;
			IMC_4 :
				next_state = ISR;
			DONE :
				if(AES_START == 1'b0)
					next_state = WAIT;
			default :
				next_state = WAIT;
		endcase
		case (state)
			WAIT : 
				begin
					next_key_wait = 4'b0000;
					next_round = 4'b0000;
				end
			KE : 
				next_key_wait = key_wait + 1;
			INIT : 
				INIT_REG = 1'b1;
			ARK : 
				begin
					LD_FUNC = 2'b00;
					LD_MSG_DEC = 1'b1;
				end
			ISR : 
				begin
					next_round = round + 1;
					LD_FUNC = 2'b01;
					LD_MSG_DEC = 1'b1;
				end
			ISB : 
				begin
					LD_FUNC = 2'b11;
					LD_MSG_DEC = 1'b1;
				end
			IMC_0 : 
				begin
					CURR_COL = 2'b00;
					LD_IMC_REG = 4'b0001;
				end
			IMC_1 : 
				begin
					CURR_COL = 2'b01;
					LD_IMC_REG = 4'b0010;
				end
			IMC_2 : 
				begin
					CURR_COL = 2'b10;
					LD_IMC_REG = 4'b0100;
				end
			IMC_3 : 
				begin
					CURR_COL = 2'b11;
					LD_IMC_REG = 4'b1000;
				end
			IMC_4 : 
				begin
					LD_FUNC = 2'b10;
					LD_MSG_DEC = 1'b1;
				end
			DONE : 
				AES_DONE = 1'b1;
			default : ;
		endcase
	end
endmodule

