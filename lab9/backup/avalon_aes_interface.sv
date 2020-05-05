/************************************************************************
Avalon-MM Interface for AES Decryption IP Core

Dong Kai Wang, Fall 2017

For use with ECE 385 Experiment 9
University of Illinois ECE Department

Register Map:

 0-3 : 4x 32bit AES Key
 4-7 : 4x 32bit AES Encrypted Message
 8-11: 4x 32bit AES Decrypted Message
   12: Not Used
	13: Not Used
   14: 32bit Start Register
   15: 32bit Done Register

************************************************************************/

module avalon_aes_interface (
	// Avalon Clock Input
	input logic CLK,
	
	// Avalon Reset Input
	input logic RESET,
	
	// Avalon-MM Slave Signals
	input  logic AVL_READ,					// Avalon-MM Read
	input  logic AVL_WRITE,					// Avalon-MM Write
	input  logic AVL_CS,						// Avalon-MM Chip Select
	input  logic [3:0] AVL_BYTE_EN,		// Avalon-MM Byte Enable
	input  logic [3:0] AVL_ADDR,			// Avalon-MM Address
	input  logic [31:0] AVL_WRITEDATA,	// Avalon-MM Write Data
	output logic [31:0] AVL_READDATA,	// Avalon-MM Read Data
	
	// Exported Conduit
	output logic [31:0] EXPORT_DATA		// Exported Conduit Signal to LEDs
);

	logic[31:0] registers [16];
	logic [127:0] msg_dec;
	logic AES_START, AES_DONE;
	always_ff @ (posedge CLK) begin
		if(RESET) begin
			for(int i = 0; i < 16; i++) begin
				registers[i] <= 32'b0;
			end
		end
		else if(AVL_CS && AVL_WRITE) begin
			if(AVL_BYTE_EN[3])
				registers[AVL_ADDR][31:24] <= AVL_WRITEDATA[31:24];
			if(AVL_BYTE_EN[2])
				registers[AVL_ADDR][23:16] <= AVL_WRITEDATA[23:16];
			if(AVL_BYTE_EN[1])
				registers[AVL_ADDR][15:8] <= AVL_WRITEDATA[15:8];
			if(AVL_BYTE_EN[0])
				registers[AVL_ADDR][7:0] <= AVL_WRITEDATA[7:0];
		end
		else begin
			AES_START <= registers[14][0];
			registers[15][0] <= AES_DONE;
			registers[8]  <= msg_dec[127:96];
			registers[9]  <= msg_dec[95:64];
			registers[10] <= msg_dec[63:32];
			registers[11] <= msg_dec[31:0];
		end
	end
	
	always_comb begin
		EXPORT_DATA = {registers[0][31:16], registers[3][15:0]}; //hardcoded for week 1, change later
		AVL_READDATA = (AVL_READ && AVL_CS) ? registers[AVL_ADDR] : 32'b0;
	end
	
	//instansiate decryption module in the avalon interface
	AES decryption_core  (.CLK, 
								 .RESET,
								 .AES_START,
								 .AES_DONE,
								 .AES_KEY({registers[0], registers[1], registers[2], registers[3]}),
								 .AES_MSG_ENC({registers[4], registers[5], registers[6], registers[7]}),
								 .AES_MSG_DEC(msg_dec)
								 );					 
endmodule
