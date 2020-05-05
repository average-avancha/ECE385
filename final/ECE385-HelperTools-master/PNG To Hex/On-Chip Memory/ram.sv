/*
 * ECE385-HelperTools/PNG-To-Txt
 * Author: Rishi Thakkar
 *
 */

module  frameRAM
(
		//input [4:0] data_In,
		//input [18:0] write_address, 
		input [18:0] read_address,
		//input we,
		input Clk,
		output logic [3:0] data_Out
);

// mem has width of 4 bits and a total of 196608 addresses (height*width)
logic [3:0] mem [0:196607]; //Frame buffer 

initial
begin
	 $readmemh("sprite_bytes/PACMAN_spritesheet.txt", mem);
end


always_ff @ (posedge Clk) begin
	// if (we)
	// 	mem[write_address] <= data_In; we don't write to memory
	data_Out<= mem[read_address];
end

endmodule
