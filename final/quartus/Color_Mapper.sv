//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  10-06-2017                               --
//--
//    Fall 2017 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 8                                         --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------

// color_mapper: Decide which color to be output to VGA for each pixel.
module color_mapper(input 			        is_Pac, is_Map, is_dot, is_red_ghost, is_orange_ghost, is_cyan_ghost, is_pink_ghost,
                                            is_cyan_scared, is_orange_scared, is_pink_scared, is_red_scared, losing_power, RELOAD_state, dying,
                    input        [8:0]      timer_powered_up, map_flash_timer,
					input        [9:0]      DrawX, DrawY,       // Current pixel coordinates
					input        [9:0]      DistX, DistY,		 // relative sprite coordinates
					input		    [15:0]     sprite_data, death_data,
					input		    [63:0]     ghost_data,
					input 		 [511:0]    map_data,
					output logic [7:0]      VGA_R, VGA_G, VGA_B // VGA RGB output
					);
		logic [7:0] Red, Green, Blue;
		logic [8:0] scared_blink;
		// Output colors to VGA
		assign VGA_R = Red;
		assign VGA_G = Green;
		assign VGA_B = Blue;
		
		//Combinational logic for scared check
		assign scared_blink = ((timer_powered_up < 9'd150 && timer_powered_up >= 9'd135) || (timer_powered_up < 9'd120 && timer_powered_up >= 9'd105) || (timer_powered_up < 9'd90 && timer_powered_up >= 9'd75) || (timer_powered_up < 9'd60 && timer_powered_up >= 9'd45) || (timer_powered_up < 9'd30 && timer_powered_up >= 9'd15));
		assign map_blink = ((map_flash_timer < 9'd150 && map_flash_timer >= 9'd135) || (map_flash_timer < 9'd120 && map_flash_timer >= 9'd105) || (map_flash_timer < 9'd90 && map_flash_timer >= 9'd75) || (map_flash_timer < 9'd60 && map_flash_timer >= 9'd45) || (map_flash_timer < 9'd30 && map_flash_timer >= 9'd15));
		always_comb begin
			if(is_Pac == 1'b1) begin //pacman sprite
				if(dying) begin
					if(death_data[15 - DistX] == 1'b1) begin
						Red   = 8'hFF;
						Green = 8'hFF;
						Blue  = 8'h00;
					end
					else begin
						Red   = 8'h00;
						Green = 8'h00;
						Blue  = 8'h00;
					end
				end
				else begin
					if(sprite_data[15 - DistX] == 1'b1) begin
						Red   = 8'hFF;
						Green = 8'hFF;
						Blue  = 8'h00;
					end
					else begin
						Red   = 8'h00;
						Green = 8'h00;
						Blue  = 8'h00;
					end
				end
			end
			else if (is_red_ghost == 1'b1) begin //red ghost 
				if(is_red_scared) begin
					if(losing_power && scared_blink) begin
						if(ghost_data[63 - (DistX << 2) -: 4] == 4'h3) begin //eye
							Red   = 8'hFF;
							Green = 8'h00;
							Blue  = 8'h00;
						end
						else if (ghost_data[63 - (DistX << 2) -: 4] == 4'h1) begin //body
							Red   = 8'hFC;
							Green = 8'hFC;
							Blue  = 8'hFF; 
						end
						else begin
							Red   = 8'h00;
							Green = 8'h00;
							Blue  = 8'h00;
						end
					end
					else begin
						if(ghost_data[63 - (DistX << 2) -: 4] == 4'h3) begin //body
							Red   = 8'hFC;
							Green = 8'hB4;
							Blue  = 8'hAA;
						end
						else if (ghost_data[63 - (DistX << 2) -: 4] == 4'h1) begin //pupil of the eye
							Red   = 8'h24;
							Green = 8'h24;
							Blue  = 8'hFF; 
						end
						else begin
							Red   = 8'h00;
							Green = 8'h00;
							Blue  = 8'h00;
						end
					end
				end
				else begin
					if(ghost_data[63 - (DistX << 2) -: 4] == 4'h2) begin //body
							Red   = 8'hFF;
							Green = 8'h00;
							Blue  = 8'h00;
						end
						else if (ghost_data[63 - (DistX << 2) -: 4] == 4'hA) begin //scalera of the eye
							Red   = 8'hFF;
							Green = 8'hFF;
							Blue  = 8'hFF;
						end
						else if (ghost_data[63 - (DistX << 2) -: 4] == 4'h1) begin //pupil of the eye
							Red   = 8'h21;
							Green = 8'h21;
							Blue  = 8'hFF; 
						end
						else begin
							Red   = 8'h00;
							Green = 8'h00;
							Blue  = 8'h00;
						end
				end
			end
			else if (is_orange_ghost == 1'b1) begin //orange ghost 
				if(is_orange_scared) begin
					if(losing_power && scared_blink) begin
						if(ghost_data[63 - (DistX << 2) -: 4] == 4'h3) begin //eye
							Red   = 8'hFF;
							Green = 8'h00;
							Blue  = 8'h00;
						end
						else if (ghost_data[63 - (DistX << 2) -: 4] == 4'h1) begin //body
							Red   = 8'hFC;
							Green = 8'hFC;
							Blue  = 8'hFF; 
						end
						else begin
							Red   = 8'h00;
							Green = 8'h00;
							Blue  = 8'h00;
						end
					end
					else begin
						if(ghost_data[63 - (DistX << 2) -: 4] == 4'h3) begin //body
							Red   = 8'hFC;
							Green = 8'hB4;
							Blue  = 8'hAA;
						end
						else if (ghost_data[63 - (DistX << 2) -: 4] == 4'h1) begin //pupil of the eye
							Red   = 8'h24;
							Green = 8'h24;
							Blue  = 8'hFF; 
						end
						else begin
							Red   = 8'h00;
							Green = 8'h00;
							Blue  = 8'h00;
						end
					end
				end
				else begin
					if(ghost_data[63 - (DistX << 2) -: 4] == 4'h2) begin //body
						Red   = 8'hFC;
						Green = 8'hB4;
						Blue  = 8'h55;
					end
					else if (ghost_data[63 - (DistX << 2) -: 4] == 4'hA) begin //scalera of the eye
						Red   = 8'hFF;
						Green = 8'hFF;
						Blue  = 8'hFF;
					end
					else if (ghost_data[63 - (DistX << 2) -: 4] == 4'h1) begin //pupil of the eye
						Red   = 8'h21;
						Green = 8'h21;
						Blue  = 8'hFF; 
					end
					else begin
						Red   = 8'h00;
						Green = 8'h00;
						Blue  = 8'h00;
					end
				end
			end
			else if (is_cyan_ghost == 1'b1) begin //cyan ghost 
				if(is_cyan_scared) begin
					if(losing_power && scared_blink) begin
						if(ghost_data[63 - (DistX << 2) -: 4] == 4'h3) begin //eye							
                            Red   = 8'hFF;
							Green = 8'h00;
							Blue  = 8'h00;
						end
						else if (ghost_data[63 - (DistX << 2) -: 4] == 4'h1) begin //body
							Red   = 8'hFC;
							Green = 8'hFC;
							Blue  = 8'hFF; 
						end
						else begin
							Red   = 8'h00;
							Green = 8'h00;
							Blue  = 8'h00;
						end
					end
					else begin
						if(ghost_data[63 - (DistX << 2) -: 4] == 4'h3) begin //body
							Red   = 8'hFC;
							Green = 8'hB4;
							Blue  = 8'hAA;
						end
						else if (ghost_data[63 - (DistX << 2) -: 4] == 4'h1) begin //pupil of the eye
							Red   = 8'h24;
							Green = 8'h24;
							Blue  = 8'hFF; 
						end
						else begin
							Red   = 8'h00;
							Green = 8'h00;
							Blue  = 8'h00;
						end
					end
				end
				else begin
					if(ghost_data[63 - (DistX << 2) -: 4] == 4'h2) begin //body 0, 252, 255	
						Red   = 8'h00;
						Green = 8'hFC;
						Blue  = 8'hFF;
					end
					else if (ghost_data[63 - (DistX << 2) -: 4] == 4'hA) begin //scalera of the eye
						Red   = 8'hFF;
						Green = 8'hFF;
						Blue  = 8'hFF;
					end
					else if (ghost_data[63 - (DistX << 2) -: 4] == 4'h1) begin //pupil of the eye
						Red   = 8'h21;
						Green = 8'h21;
						Blue  = 8'hFF; 
					end
					else begin
						Red   = 8'h00;
						Green = 8'h00;
						Blue  = 8'h00;
					end
				end
			end
			else if (is_pink_ghost) begin
                if(is_pink_scared) begin
					if(losing_power && scared_blink) begin
						if(ghost_data[63 - (DistX << 2) -: 4] == 4'h3) begin //eye
							Red   = 8'hFF;
							Green = 8'h00;
							Blue  = 8'h00;
						end
						else if (ghost_data[63 - (DistX << 2) -: 4] == 4'h1) begin //body
							Red   = 8'hFC;
							Green = 8'hFC;
							Blue  = 8'hFF; 
						end
						else begin
							Red   = 8'h00;
							Green = 8'h00;
							Blue  = 8'h00;
						end
					end
					else begin
						if(ghost_data[63 - (DistX << 2) -: 4] == 4'h3) begin //body
							Red   = 8'hFC;
							Green = 8'hB4;
							Blue  = 8'hAA;
						end
						else if (ghost_data[63 - (DistX << 2) -: 4] == 4'h1) begin //pupil of the eye
							Red   = 8'h24;
							Green = 8'h24;
							Blue  = 8'hFF; 
						end
						else begin
							Red   = 8'h00;
							Green = 8'h00;
							Blue  = 8'h00;
						end
					end
				end
				else begin
					if(ghost_data[63 - (DistX << 2) -: 4] == 4'h2) begin //body 0, 252, 255	
						Red   = 8'hFC;
						Green = 8'hB4;
						Blue  = 8'hFF;
					end
					else if (ghost_data[63 - (DistX << 2) -: 4] == 4'hA) begin //scalera of the eye
						Red   = 8'hFF;
						Green = 8'hFF;
						Blue  = 8'hFF;
					end
					else if (ghost_data[63 - (DistX << 2) -: 4] == 4'h1) begin //pupil of the eye
						Red   = 8'h21;
						Green = 8'h21;
						Blue  = 8'hFF; 
					end
					else begin
						Red   = 8'h00;
						Green = 8'h00;
						Blue  = 8'h00;
					end
				end
			end
			else if(is_dot == 1'b1) begin //dot
				Red 	= 8'hFF;
				Green = 8'hFF;
				Blue  = 8'h00;
			end
			else if(is_Map == 1'b1) begin //black map
				if(map_data[511 - DistX] == 1'b1) begin // wall
					if(RELOAD_state && map_blink) begin
						Red   = 8'hFC;
						Green = 8'hFC;
						Blue  = 8'hFF;
					end
					else begin
						Red   = 8'h00;
						Green = 8'h00;
						Blue  = 8'hFF;
					end
				end
				else begin //black path
					Red   = 8'h00;
					Green = 8'h00;
					Blue  = 8'h00;
				end
			end
			else begin 
				Red   = 8'h00; 
				Green = 8'h00;
				Blue  = 8'h00;
				//gradient border
//				Red = 8'h3f; 
//				Green = 8'h00;
//				Blue = 8'h7f - {1'b0, DrawX[9:3]};
			end
		end
endmodule 