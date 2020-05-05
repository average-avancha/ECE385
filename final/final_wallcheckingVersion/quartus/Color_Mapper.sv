//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  10-06-2017                               --
//--
//    Fall 2017 Distribut                                                                       ion                                             --
//                                                                       --
//    For use with ECE 385 Lab 8                                         --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------

// color_mapper: Decide which color to be output to VGA for each pixel.
module color_mapper(input 			    is_Pac,
					input				is_Map,
					input        [9:0]  DrawX, DrawY,       // Current pixel coordinates
					input 	     [9:0]  DistX, DistY,
					input		 [15:0] sprite_data,
                    output logic [7:0]  VGA_R, VGA_G, VGA_B // VGA RGB output
					);
		logic [7:0] Red, Green, Blue;
		// Output colors to VGA
		assign VGA_R = Red;
		assign VGA_G = Green;
		assign VGA_B = Blue;
	
		always_comb begin
			if(is_Pac == 1'b1) begin //pacman sprite
				if(sprite_data[15 - DistX] == 1'b1) begin//colored pixel on a pacman sprite
					Red   = 8'hFF;
					Green = 8'hFF;
					Blue  = 8'h00;
				end
				else begin
					Red   = 8'hFF;
					Green = 8'h00;
					Blue  = 8'h00;
				end
			end
			else if(is_Map == 1'b1) begin //black map
				Red   = 8'h00;
				Green = 8'h00;
				Blue  = 8'h00;
			end
			else begin //gradient border
				Red = 8'h3f; 
				Green = 8'h00;
				Blue = 8'h7f - {1'b0, DrawX[9:3]};
			end
		end
endmodule
