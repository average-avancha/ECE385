/************************************************************************
AES Decryption Core Logic

Dong Kai Wang, Fall 2017

For use with ECE 385 Experiment 9
University of Illinois ECE Department
************************************************************************/

module AES (
	input	 logic CLK,
	input  logic RESET,
	input  logic AES_START,
	output logic AES_DONE,
	input  logic [127:0] AES_KEY,
	input  logic [127:0] AES_MSG_ENC,
	output logic [127:0] AES_MSG_DEC
);
//	1. Add round key
//  2. [1.invShift rows 2.InvSubbytes 3. AddRoundkey 4. InvMixColumns] * 9
//  3. Invshiftrows, Insubbytes,Addroundkey
//
//InvMixColumns and keyexpansion only instantiate once
//Invsubbytes can be instatiated multiple types
//*NEED TO WRITE ROTATION AND ADDKEYROUND modules*
//*NEED TO DESIGN STATE MACHINE*

	logic [1407:0] keySchedule;
	logic [127:0] key_state [11];//cypherkey is last state(key_state[10])
	logic [127:0] msg_reg, msg_reg_in;//make sure u make into register
	logic [1:0] InvColSelect,InvColDecSelect;//make sure u use in FSM
	logic [2:0] mainMuxSelect;
	logic [3:0] roundKeySelect;
	logic [31:0] InvColMuxOut,InvColOut, InvColDec0,InvColDec1,InvColDec2,InvColDec3;
	logic [127:0] inputRoundKey, roundKeytoMux, shiftRowtoMux;
	logic [7:0] sub0,sub1,sub2,sub3,sub4,sub5,sub6,sub7,sub8,sub9,sub10,sub11,sub12,sub13,sub14,sub15;
// Note that KeyExpansion does not complete in single clock cycle.
// Run simulation to see how many clock cycles it takes for key schedule to complete.
	KeyExpansion keyExpansion(.clk(CLK), .Cipherkey(AES_KEY),.KeySchedule(keySchedule));
	
	
	always_ff @ (posedge CLK) begin //This always_ff is for everything NOT state machine
		if (RESET) begin 
			for(int i=0;i<11;i++)
				begin 
				key_state[i] <= 128'b0;
				end
			end
		else begin
		msg_reg <= msg_reg_in;
		key_state[0] <= keySchedule[127:0];key_state[1] <= keySchedule[255:128];key_state[2] <= keySchedule[383:256];
		key_state[3] <= keySchedule[511:384];key_state[4] <= keySchedule[639:512];key_state[5] <= keySchedule[767:640];
		key_state[6] <= keySchedule[895:768];key_state[7] <= keySchedule[1023:896];key_state[8] <= keySchedule[1151:1024];
		key_state[9] <= keySchedule[1279:1152];key_state[10] <= keySchedule[1407:1280];
		end
	end


//Mux before invmixcolumns
mux2 InvColMux(.d0(msg_reg[127:96]),.d1(msg_reg[95:64]),.d2(msg_reg[63:32]),.d3(msg_reg[31:0]),
				.s(InvColSelect), .y(InvColMuxOut));

//InvMixColumns Module		
InvMixColumns InvMixCol( .in(InvColMuxOut),.out(InvColOut));

//Decoder for invmixcol
dec2 InvMixColDec(.y(InvColOut),.s(InvColDecSelect),.d0(InvColDec0),
					.d1(InvColDec1),.d2(InvColDec2),.d3(InvColDec3),.clk(CLK));
						
//Mux as input to the current state register
mux3 #(128) mainMux  (.d0(roundKeytoMux),.d1(shiftRowtoMux),
							.d2({InvColDec0,InvColDec1,InvColDec2,InvColDec3}),
							.d3({sub15,sub14,sub13,sub12,sub11,sub10,sub9,sub8,sub7,sub6,sub5,sub4,sub3,sub2,sub1,sub0}),
							.d4(AES_MSG_ENC),.d5(msg_reg),
							.s(mainMuxSelect), 
							.y(msg_reg_in));
//Key_state mux to roundkeymodule											
mux11 #(128) roundKeyMux (.d0(key_state[0]), .d1(key_state[1]), .d2(key_state[2]), .d3(key_state[3]),
 .d4(key_state[4]), .d5(key_state[5]), .d6(key_state[6]), .d7(key_state[7]), .d8(key_state[8]), .d9(key_state[9]), .d10(key_state[10]),
 .s(roundKeySelect), .y(inputRoundKey));												

//Roundkeymodule to mainmux											
AddRoundKey roundKeyMod(.currstate(msg_reg), .key(inputRoundKey),
							.out(roundKeytoMux));	
							
//Inv shift row to mainmux					
InvShiftRows shiftRowsMod(.data_in(msg_reg), .data_out(shiftRowtoMux));
			


//STATE LOGIC 			
enum logic [7:0] {WAIT,DONE,AddRoundKeyInitial1,AddRoundKeyInitial2,AddRoundKeyInitial3,AddRoundKeyInitial4,InvShiftRows1,
				AddRoundKey1,AddRoundKey2,AddRoundKey3,AddRoundKey4,
				InvShiftRows2,InvShiftRows3,InvSubBytes1,InvSubBytes2,InvSubBytes3,
				InvMixCols1,InvMixCols2,InvMixCols3,InvMixCols4,Checker,
				InvShiftRowsFinal1,InvShiftRowsFinal2,InvShiftRowsFinal3,
				InvSubBytesFinal1,InvSubBytesFinal2,InvSubBytesFinal3,
				AddRoundKeyFinal1,AddRoundKeyFinal2,AddRoundKeyFinal3,dummy}   State, Next_state; 
			
logic [3:0] tracker;
logic [3:0] tracker_in;
	always_ff @ (posedge CLK)
	begin
		if (RESET) 
		begin
			State <= WAIT;
			tracker<=4'b0000;
		end
		else 
			State <= Next_state;
			tracker<=tracker_in;
	end
	
   always_comb
	begin 
		// Default next state is staying at current state 
		
		Next_state = State;
		AES_DONE=1'b0;
		tracker_in = tracker;
		mainMuxSelect = 3'b111;
		roundKeySelect = 4'b0000;
		InvColSelect = 2'b00;
		InvColDecSelect = 2'b00;

		unique case (State) //BTW APPARENTLY YOU CAN USE TRACKER++ AND IT WILL WORK
			WAIT:
			begin
			tracker_in = 4'b0000;
			if(AES_START == 1'b1)
			Next_state = AddRoundKeyInitial1;
			else Next_state = WAIT; 
			end
			AddRoundKeyInitial1:
			begin
			mainMuxSelect = 3'b100;//AES MSG ENCRY
			Next_state = AddRoundKeyInitial2;
			end
			AddRoundKeyInitial2:
			begin 
			roundKeySelect = tracker;
			mainMuxSelect = 3'b000;
			Next_state= AddRoundKeyInitial3;
			end
			AddRoundKeyInitial3: 
			begin
			Next_state = AddRoundKeyInitial4;
			end
			AddRoundKeyInitial4:
			begin
			tracker_in++;
			Next_state = InvShiftRows2;
			end
			InvShiftRows2:
			begin
			mainMuxSelect = 3'b001;
			Next_state = InvShiftRows3;
			end
			InvShiftRows3:
			begin
			Next_state = InvSubBytes1;
			end
			InvSubBytes1:
			begin
			mainMuxSelect = 3'b111;
			Next_state = InvSubBytes2;
			end
			InvSubBytes2:
			begin
			mainMuxSelect = 3'b011;
			Next_state = InvSubBytes3;
			end
			InvSubBytes3:
			begin
			Next_state = AddRoundKey1;
			end
			AddRoundKey1:
			begin
			mainMuxSelect = 3'b111;
			Next_state = AddRoundKey2;
			end
			AddRoundKey2:
			begin 
			roundKeySelect = tracker;
			mainMuxSelect = 3'b000;
			Next_state= AddRoundKey3;
			end
			AddRoundKey3: 
			begin
			Next_state = AddRoundKey4;
			end
			AddRoundKey4:
			begin
			tracker_in++;
			Next_state = InvMixCols1;
			end
			InvMixCols1:
			begin
			InvColSelect = 2'b00;
			InvColDecSelect = 2'b00;
			Next_state=InvMixCols2;
			end
			InvMixCols2:
			begin
			InvColSelect = 2'b01;
			InvColDecSelect = 2'b01;
			Next_state=InvMixCols3;
			end
			InvMixCols3:
			begin
			InvColSelect = 2'b10;
			InvColDecSelect = 2'b10;
			Next_state=InvMixCols4;
			end
			InvMixCols4:
			begin 
			InvColSelect = 2'b11;
			InvColDecSelect = 2'b11;
			Next_state = Checker;
			end
			Checker:
			begin
			mainMuxSelect = 3'b010;
			if(tracker == 4'b1010)
			Next_state = InvShiftRowsFinal1;
			else
			Next_state = InvShiftRows2;
			end
			InvShiftRowsFinal1:
			begin
			mainMuxSelect = 3'b111;
			Next_state = InvShiftRowsFinal2;
			end
			InvShiftRowsFinal2:
			begin
			mainMuxSelect = 3'b001;
			Next_state = InvShiftRowsFinal3;
			end
			InvShiftRowsFinal3:
			begin
			Next_state = InvSubBytesFinal1;
			end
			InvSubBytesFinal1:
			begin
			mainMuxSelect = 3'b111;
			Next_state = InvSubBytesFinal2;
			end
			InvSubBytesFinal2:
			begin
			mainMuxSelect = 3'b011;
			Next_state = InvSubBytesFinal3;
			end
			InvSubBytesFinal3:
			begin
			Next_state = AddRoundKeyFinal1;
			end
			AddRoundKeyFinal1:
			begin
			mainMuxSelect = 3'b111;
			Next_state = AddRoundKeyFinal2;
			end
			AddRoundKeyFinal2:
			begin 
			roundKeySelect = tracker;
			mainMuxSelect = 3'b000;
			Next_state= AddRoundKeyFinal3;
			end
			AddRoundKeyFinal3: 
			begin
			Next_state = DONE;
			end
			DONE:
			begin
			AES_DONE = 1'b1;
			if(AES_START == 1'b0)
			begin
			Next_state = WAIT;
			end
			else
			begin
			Next_state = DONE;
			end
			end
			
			default: ;
		


	endcase
	end

assign AES_MSG_DEC = msg_reg;		
			
			
	/*
		Initial AddKey
		1. mainMuxSelect so AES_ENC -> Current Register
		2. roundKeySelect so state is input to addRoundKey
		3. mainMuxSelect so OUtput of addRoundKey is back in current register
		4. 
	
	*/
	/* InvShiftRows
		1. mainMuxSelect so ShiftRows -> Current Register
	*/
	/* INVSubBytes
		1.mainMuxSelect so subbytes -> Current Register
	*/
	/*InvMixColumn
		1. InvColSelect for each state 
		2. at same time do InvColDecSelect
		3. May need wait state since register
		4. mainMuxSelect let d2 pass through
	*/

/* Parallel InvSubBytes Operation*/	
InvSubBytes (.clk(CLK),.in(msg_reg[7:0]),.out(sub0));	
InvSubBytes (.clk(CLK),.in(msg_reg[15:8]),.out(sub1));												
InvSubBytes (.clk(CLK),.in(msg_reg[23:16]),.out(sub2));												
InvSubBytes (.clk(CLK),.in(msg_reg[31:24]),.out(sub3));												
InvSubBytes (.clk(CLK),.in(msg_reg[39:32]),.out(sub4));												
InvSubBytes (.clk(CLK),.in(msg_reg[47:40]),.out(sub5));
InvSubBytes (.clk(CLK),.in(msg_reg[55:48]),.out(sub6));												
InvSubBytes (.clk(CLK),.in(msg_reg[63:56]),.out(sub7));	
InvSubBytes (.clk(CLK),.in(msg_reg[71:64]),.out(sub8));												
InvSubBytes (.clk(CLK),.in(msg_reg[79:72]),.out(sub9));												
InvSubBytes (.clk(CLK),.in(msg_reg[87:80]),.out(sub10));												
InvSubBytes (.clk(CLK),.in(msg_reg[95:88]),.out(sub11));												
InvSubBytes (.clk(CLK),.in(msg_reg[103:96]),.out(sub12));
InvSubBytes (.clk(CLK),.in(msg_reg[111:104]),.out(sub13));	
InvSubBytes (.clk(CLK),.in(msg_reg[119:112]),.out(sub14));
InvSubBytes (.clk(CLK),.in(msg_reg[127:120]),.out(sub15));	

endmodule




module AddRoundKey(input logic [127:0] currstate, input logic [127:0] key,
							output logic [127:0] out);
assign out = currstate ^ key;
endmodule

module mux2 #(parameter width =32) (input logic [width-1:0] d0,d1,d2,d3,
												input logic [1:0] s, 
												output logic [width-1:0] y);
always_comb 
	begin 
		case(s)
		2'b00:
		y = d0;
		2'b01:
		y = d1;
		2'b10:
		y = d2;
		default:
		y = d3;
		
		endcase
	end

endmodule
/*Decoder for InvMixColumns*/
module dec2 #(parameter width =32) (input logic [width-1:0] y,
												input logic [1:0] s, 
												output logic [width-1:0] d0,d1,d2,d3,input logic clk);

		logic [width-1:0] d0_in,d1_in,d2_in,d3_in;
			
	always_ff @(posedge clk)
	begin 
		d0 <= d0_in;
		d1 <= d1_in;
		d2 <= d2_in;
		d3 <= d3_in;
	end
	
always_comb 
	begin 
	d0_in = d0;
	d1_in = d1;
	d2_in = d2;
	d3_in = d3;
		case(s)
		2'b00:
		d0_in = y;
		2'b01:
		d1_in = y;
		2'b10:
		d2_in = y;
		default:
		d3_in = y;
		endcase
	end

endmodule




module mux3 #(parameter width =32) (input logic [width-1:0] d0,d1,d2,d3,d4,d5,
												input logic [2:0] s, 
												output logic [width-1:0] y);

always_comb 
	begin 
		case(s)
		3'b000:
		y = d0;
		3'b001:
		y = d1;
		3'b010:
		y = d2;
		3'b011:
		y = d3;
		3'b100:
		y=d4;
		default:
		y = d5;
		endcase
	end

endmodule
module mux11 #(parameter width =128) (input logic [width-1:0] d0,d1,d2,d3,d4,d5,d6,d7,d8,d9,d10,
												input logic [4:0] s, 
												output logic [width-1:0] y);

always_comb 
	begin 
	unique case(s)
		4'b0000:
		y = d0;
		4'b0001:
		y = d1;
		4'b0010:
		y = d2;
		4'b0011:
		y = d3;
		4'b0100:
		y = d4;
		4'b0101:
		y = d5;
		4'b0110:
		y = d6;
		4'b0111:
		y = d7;
		4'b1000:
		y = d8;
		4'b1001:
		y = d9;
		default:
		y = d10;
		endcase
	end	

endmodule


////STATE LOGIC 			
//enum logic [7:0] {WAIT,DONE,AddRoundKeyInitial1,AddRoundKeyInitial2,AddRoundKeyInitial3,AddRoundKeyInitial4,InvShiftRows1,
//				AddRoundKey1,AddRoundKey2,AddRoundKey3,AddRoundKey4,
//				InvShiftRows2,InvShiftRows3,InvSubBytes1,InvSubBytes2,InvSubBytes3,
//				InvMixCols1,InvMixCols2,InvMixCols3,InvMixCols4,Checker,
//				InvShiftRowsFinal1,InvShiftRowsFinal2,InvShiftRowsFinal3,
//				InvSubBytesFinal1,InvSubBytesFinal2,InvSubBytesFinal3,
//				AddRoundKeyFinal1,AddRoundKeyFinal2,AddRoundKeyFinal3}   State, Next_state; 
//			
//logic [3:0] tracker;
//logic [3:0] tracker_in;
//	always_ff @ (posedge CLK)
//	begin
//		if (RESET) 
//		begin
//			State <= WAIT;
//			tracker<=4'b0000;
//		end
//		else 
//			State <= Next_state;
//			tracker<=tracker_in;
//	end
//	
//   always_comb
//	begin 
//		// Default next state is staying at current state 
//		
//		Next_state = State;
//		AES_DONE=1'b0;
//		tracker_in = tracker;
//		mainMuxSelect = 3'b111;
//		roundKeySelect = tracker;//changed from 0000
//		InvColSelect = 2'b00;
//		InvColDecSelect = 2'b00;
//
//		unique case (State) //BTW APPARENTLY YOU CAN USE TRACKER++ AND IT WILL WORK
//			WAIT:
//			begin
//			if(AES_START == 1'b1)
//			begin
//			tracker_in = 4'b0000;
//			Next_state = AddRoundKeyInitial1;
//			end
//			else Next_state = WAIT; 
//			end
//			AddRoundKeyInitial1:
//			begin
//			mainMuxSelect = 3'b100;
//			Next_state = AddRoundKeyInitial2;
//			end
//			AddRoundKeyInitial2:
//			begin 
//			roundKeySelect = tracker;
//			mainMuxSelect = 3'b000;
//			Next_state= AddRoundKeyInitial3;
//			end
//			AddRoundKeyInitial3: 
//			begin
//			Next_state = AddRoundKeyInitial4;
//			end
//			AddRoundKeyInitial4:
//			begin
//			mainMuxSelect = 3'b111;
//			tracker_in++;
//			Next_state = InvShiftRows1;
//			end
//			InvShiftRows1:
//			begin
//			mainMuxSelect = 3'b111;
//			Next_state = InvShiftRows2;
//			end
//			InvShiftRows2:
//			begin
//			mainMuxSelect = 3'b001;
//			Next_state = InvShiftRows3;
//			end
//			InvShiftRows3:
//			begin
//			mainMuxSelect = 3'b111;
//			Next_state = InvSubBytes1;
//			end
//			InvSubBytes1:
//			begin
//			mainMuxSelect = 3'b111;
//			Next_state = InvSubBytes2;
//			end
//			InvSubBytes2:
//			begin
//			mainMuxSelect = 3'b011;
//			Next_state = InvSubBytes3;
//			end
//			InvSubBytes3:
//			begin
//			mainMuxSelect = 3'b111;
//			Next_state = AddRoundKey1;
//			end
//			AddRoundKey1:
//			begin
//			mainMuxSelect = 3'b111;
//			Next_state = AddRoundKey2;
//			end
//			AddRoundKey2:
//			begin 
//			case(tracker)
//			4'b0000: roundKeySelect = 4'b0000;
//			4'b0001: roundKeySelect = 4'b0001;
//			4'b0010: roundKeySelect = 4'b0010;
//			4'b0011: roundKeySelect = 4'b0011;
//			4'b0100: roundKeySelect = 4'b0100;
//			4'b0101: roundKeySelect = 4'b0101;
//			4'b0110: roundKeySelect = 4'b0110;
//			4'b0111: roundKeySelect = 4'b0111;
//			4'b1000: roundKeySelect = 4'b1000;
//			4'b1001: roundKeySelect = 4'b1001;
//			4'b1010: roundKeySelect = 4'b1010;
//			default: roundKeySelect = 4'b0000;
//			endcase
//			mainMuxSelect = 3'b000;
//			Next_state= AddRoundKey3;
//			end
//			AddRoundKey3: 
//			begin
//			mainMuxSelect = 3'b111;
//			Next_state = AddRoundKey4;
//			end
//			AddRoundKey4:
//			begin
//			mainMuxSelect = 3'b111;
//			tracker_in++;
//			if(tracker_in == 3'b0011)
//			Next_state = DONE;
//			else
//			Next_state = InvMixCols1;
//			end
//			InvMixCols1:
//			begin
//			InvColSelect = 2'b00;
//			InvColDecSelect = 2'b00;
//			Next_state=InvMixCols2;
//			end
//			InvMixCols2:
//			begin
//			InvColSelect = 2'b01;
//			InvColDecSelect = 2'b01;
//			Next_state=InvMixCols3;
//			end
//			InvMixCols3:
//			begin
//			InvColSelect = 2'b10;
//			InvColDecSelect = 2'b10;
//			Next_state=InvMixCols4;
//			end
//			InvMixCols4:
//			begin 
//			InvColSelect = 2'b11;
//			InvColDecSelect = 2'b11;
//			Next_state = Checker;
//			end
//			Checker:
//			begin
//			mainMuxSelect = 3'b010;//CHANGED FROM 111 -ish since you need to put the invmixcol in register
//			if(tracker == 4'b1010)
//			Next_state = InvShiftRowsFinal1;
//			else
//			Next_state = InvShiftRows1;
//			end
//			InvShiftRowsFinal1:
//			begin
//			mainMuxSelect = 3'b111;
//			Next_state = InvShiftRowsFinal2;
//			end
//			InvShiftRowsFinal2:
//			begin
//			mainMuxSelect = 3'b001;
//			Next_state = InvShiftRowsFinal3;
//			end
//			InvShiftRowsFinal3:
//			begin
//			mainMuxSelect = 3'b111;
//			Next_state = InvSubBytesFinal1;
//			end
//			InvSubBytesFinal1:
//			begin
//			mainMuxSelect = 3'b111;
//			Next_state = InvSubBytesFinal2;
//			end
//			InvSubBytesFinal2:
//			begin
//			mainMuxSelect = 3'b011;
//			Next_state = InvSubBytesFinal3;
//			end
//			InvSubBytesFinal3:
//			begin
//			mainMuxSelect = 3'b111;
//			Next_state = DONE;
//			end
//			AddRoundKeyFinal1:
//			begin
//			mainMuxSelect = 3'b111;
//			Next_state = AddRoundKeyFinal2;
//			end
//			AddRoundKeyFinal2:
//			begin 
//			roundKeySelect = tracker;
//			mainMuxSelect = 3'b000;
//			Next_state= AddRoundKeyFinal3;
//			end
//			AddRoundKeyFinal3: 
//			begin
//			Next_state = DONE;
//			end
//			DONE:
//			begin
//			mainMuxSelect = 3'b111;
//			AES_DONE = 1'b1;
//			Next_state = DONE;
//			end
//			default: ;
//		
//
//
//	endcase
//	end
//
//assign AES_MSG_DEC = msg_reg;


