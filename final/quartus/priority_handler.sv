module priority_handler(input 			Clk, Reset,
                                        is_Pac, is_dot, is_Map, is_red_ghost, is_orange_ghost, is_cyan_ghost, is_pink_ghost,
                                        is_cyan_scared, is_orange_scared, is_pink_scared, is_red_scared, dying,
						input  [6:0]    death_time, animation_count, red_ghost_animation_count, orange_ghost_animation_count, cyan_ghost_animation_count, pink_ghost_animation_count,
						input  [2:0]    direction_out, red_ghost_direction_out, orange_ghost_direction_out, cyan_ghost_direction_out, pink_ghost_direction_out,
						input  [9:0]	PacX, PacY, RedGhostX, RedGhostY, OrangeGhostX, OrangeGhostY, CyanGhostX, CyanGhostY, PinkGhostX, PinkGhostY, MapX, MapY,
						output [2:0]    direction,
						output [7:0]	ghost_addr, sprite_addr, death_addr,
						output [8:0]	map_addr,
						output [9:0]	DistX, DistY);
	parameter [7:0] death_padding = 8'd64; //Pacman dead
	parameter [7:0] ghost_padding = 8'd96; 
	parameter [7:0] sprite_padding = 8'd112; //Pacman alive
	parameter [8:0] map_padding = 9'd128;

	logic [2:0] next_direction, 
				next_red_ghost_direction, red_ghost_direction, 
				orange_ghost_direction, next_orange_ghost_direction, 
				cyan_ghost_direction, next_cyan_ghost_direction,
				pink_ghost_direction, next_pink_ghost_direction;
	
	
	//Pacman Direction Change Register
	always_ff @ (posedge Clk)begin
		if(Reset)
			direction <= 3'b000;
		else
			direction <= next_direction;
	end
	always_comb begin
		next_direction = direction_out;
		if(direction_out == 3'b111)
			next_direction = direction;
	end
	
	//RedGhost Direction Change Register
	always_ff @ (posedge Clk)begin
		if(Reset)
			red_ghost_direction <= 3'b000;
		else
			red_ghost_direction <= next_red_ghost_direction;
	end
	always_comb begin
		next_red_ghost_direction = red_ghost_direction_out;
		if(red_ghost_direction_out == 3'b111)
			next_red_ghost_direction = red_ghost_direction;
	end
	
	//OrangeGhost Direction Change Register
	always_ff @ (posedge Clk)begin
		if(Reset)
			orange_ghost_direction <= 3'b000;
		else
			orange_ghost_direction <= next_orange_ghost_direction;
	end
	always_comb begin
		next_orange_ghost_direction = orange_ghost_direction_out;
		if(orange_ghost_direction_out == 3'b111)
			next_orange_ghost_direction = orange_ghost_direction;
	end

	//CyanGhost Direction Change Register
	always_ff @ (posedge Clk)begin
		if(Reset)
			cyan_ghost_direction <= 3'b000;
		else
			cyan_ghost_direction <= next_cyan_ghost_direction;
	end
	always_comb begin
		next_cyan_ghost_direction = cyan_ghost_direction_out;
		if(cyan_ghost_direction_out == 3'b111)
			next_cyan_ghost_direction = cyan_ghost_direction;
	end

	//PinkGhost Direction Change Register
	always_ff @ (posedge Clk)begin
		if(Reset)
			pink_ghost_direction <= 3'b000;
		else
			pink_ghost_direction <= next_pink_ghost_direction;
	end
	always_comb begin
		next_pink_ghost_direction = pink_ghost_direction_out;
		if(pink_ghost_direction_out == 3'b111)
			next_pink_ghost_direction = pink_ghost_direction;
	end

	//Sprite Priority Handler
	always_comb begin
		if(is_Pac) begin
			DistX = PacX;
			DistY = PacY;
			map_addr = 9'bz;
			ghost_addr = 8'bz;
			if(dying) begin
                sprite_addr = 8'bz;
				if(death_time <= 8'd100 && death_time > 8'd92) begin
					death_addr = 8'h00 + PacY[7:0] + death_padding;
				end
				else if(death_time <= 8'd92 && death_time > 8'd84) begin
					death_addr = 8'h10 + PacY[7:0] + death_padding;
				end
				else if(death_time <= 8'd84 && death_time > 8'd76) begin
					death_addr = 8'h20 + PacY[7:0] + death_padding;
				end
				else if(death_time <= 8'd76 && death_time > 8'd68) begin
					death_addr = 8'h30 + PacY[7:0] + death_padding;
				end
				else if(death_time <= 8'd68 && death_time > 8'd60) begin
					death_addr = 8'h40 + PacY[7:0] + death_padding;
				end
				else if(death_time <= 8'd60 && death_time > 8'd52) begin
					death_addr = 8'h50 + PacY[7:0] + death_padding;
				end
				else if(death_time <= 8'd52 && death_time > 8'd44) begin
					death_addr = 8'h60 + PacY[7:0] + death_padding;
				end
				else if(death_time <= 8'd44 && death_time > 8'd36) begin
					death_addr = 8'h70 + PacY[7:0] + death_padding;
				end
				else if(death_time <= 8'd36 && death_time > 8'd28) begin
					death_addr = 8'h80 + PacY[7:0] + death_padding;
				end
				else if(death_time <= 8'd28 && death_time > 8'd20) begin
					death_addr = 8'h90 + PacY[7:0] + death_padding;
				end
				else if(death_time <= 8'd20 && death_time > 8'd12) begin
					death_addr = 8'hA0 + PacY[7:0] + death_padding;
				end
				else if(death_time <= 8'd12 && death_time > 8'd4) begin
					death_addr = 8'hB0 + PacY[7:0] + death_padding;
				end
				else if(death_time <= 8'd4) begin
					death_addr = 8'h00 + PacY[7:0]; //Black
				end
				else begin
					death_addr = 8'bz;
				end
			end
			else begin
				case (direction)
					3'b000 : begin //W--> Up
						death_addr = 8'bz;
						if(animation_count >= 7'd0 && animation_count < 7'd2)
							sprite_addr = 8'h00 + PacY[7:0] + sprite_padding;
						else if (animation_count >= 7'd2 && animation_count < 7'd4)
							sprite_addr = 8'h10 + PacY[7:0] + sprite_padding;
						else 
							sprite_addr = 8'h20 + PacY[7:0] + sprite_padding;
					end
					3'b001 : begin //A--> Left
						death_addr = 8'bz;
						if(animation_count >= 7'd0 && animation_count < 7'd2)
							sprite_addr = 8'h00 + PacY[7:0] + sprite_padding;
						else if (animation_count >= 7'd2 && animation_count < 7'd4)
							sprite_addr = 8'h30 + PacY[7:0] + sprite_padding;
						else
							sprite_addr = 8'h40 + PacY[7:0] + sprite_padding;
					end 
					3'b010 : begin //S--> Down
						death_addr = 8'bz;
						if(animation_count >= 7'd0 && animation_count < 7'd2)
							sprite_addr = 8'h00 + PacY[7:0] + sprite_padding;
						else if (animation_count >= 7'd2 && animation_count < 7'd4)
							sprite_addr = 8'h50 + PacY[7:0] + sprite_padding;
						else
							sprite_addr = 8'h60 + PacY[7:0] + sprite_padding;
					end
					3'b011 : begin //D--> Right
						death_addr = 8'bz;
						if(animation_count >= 7'd0 && animation_count < 7'd2)
							sprite_addr = 8'h00 + PacY[7:0] + sprite_padding;
						else if (animation_count >= 7'd2 && animation_count < 7'd4)
							sprite_addr = 8'h70 + PacY[7:0] + sprite_padding;
						else
							sprite_addr = 8'h80 + PacY[7:0] + sprite_padding;
					end
					default : begin//Shouldn't hit the default case
						sprite_addr = 8'h00 + DistY[7:0] + sprite_padding;
						death_addr = 8'bz;
					end
				endcase
			end
		end
		else if(is_red_ghost) begin
			map_addr = 9'bz;
			sprite_addr = 8'bz;
			death_addr = 8'bz;
			DistX = RedGhostX;
			DistY = RedGhostY;
			if(is_red_scared) begin
				if(red_ghost_animation_count >= 7'd0 && red_ghost_animation_count < 7'd3)
					ghost_addr = 8'h00 + RedGhostY[7:0] + ghost_padding;
				else 
					ghost_addr = 8'h10 + RedGhostY[7:0] + ghost_padding;
			end
			else begin
				case (red_ghost_direction)
					3'b000 : begin //W--> Up
						if(red_ghost_animation_count >= 7'd0 && red_ghost_animation_count < 7'd3)
							ghost_addr = 8'h20 + RedGhostY[7:0] + ghost_padding;
						else 
							ghost_addr = 8'h30 + RedGhostY[7:0] + ghost_padding;
					end
					3'b001 : begin //A--> Left
						if(red_ghost_animation_count >= 7'd0 && red_ghost_animation_count < 7'd3)
							ghost_addr = 8'h40 + RedGhostY[7:0] + ghost_padding;
						else
							ghost_addr = 8'h50 + RedGhostY[7:0] + ghost_padding;
					end 
					3'b010 : begin //S--> Down
						if(red_ghost_animation_count >= 7'd0 && red_ghost_animation_count < 7'd3)
							ghost_addr = 8'h60 + RedGhostY[7:0] + ghost_padding;
						else
							ghost_addr = 8'h70 + RedGhostY[7:0] + ghost_padding;
					end
					3'b011 : begin //D--> Right
						if(red_ghost_animation_count >= 7'd0 && red_ghost_animation_count < 7'd3)
							ghost_addr = 8'h80 + RedGhostY[7:0] + ghost_padding;
						else
							ghost_addr = 8'h90 + RedGhostY[7:0] + ghost_padding;
					end
					default : //Shouldn't hit the default case
						ghost_addr = 8'h20 + RedGhostY[7:0] + ghost_padding;
				endcase
			end
		end
		else if(is_orange_ghost) begin
			map_addr = 9'bz;
			sprite_addr = 8'bz;
			death_addr = 8'bz;
			DistX = OrangeGhostX;
			DistY = OrangeGhostY;
			if(is_orange_scared) begin
				if(orange_ghost_animation_count >= 7'd0 && orange_ghost_animation_count < 7'd3)
					ghost_addr = 8'h00 + OrangeGhostY[7:0] + ghost_padding;
				else 
					ghost_addr = 8'h10 + OrangeGhostY[7:0] + ghost_padding;
			end
			else begin
				case (orange_ghost_direction)
					3'b000 : begin //W--> Up
						if(orange_ghost_animation_count >= 7'd0 && orange_ghost_animation_count < 7'd3)
							ghost_addr = 8'h20 + OrangeGhostY[7:0] + ghost_padding;
						else 
							ghost_addr = 8'h30 + OrangeGhostY[7:0] + ghost_padding;
					end
					3'b001 : begin //A--> Left
						if(orange_ghost_animation_count >= 7'd0 && orange_ghost_animation_count < 7'd3)
							ghost_addr = 8'h40 + OrangeGhostY[7:0] + ghost_padding;
						else
							ghost_addr = 8'h50 + OrangeGhostY[7:0] + ghost_padding;
					end 
					3'b010 : begin //S--> Down
						if(orange_ghost_animation_count >= 7'd0 && orange_ghost_animation_count < 7'd3)
							ghost_addr = 8'h60 + OrangeGhostY[7:0] + ghost_padding;
						else
							ghost_addr = 8'h70 + OrangeGhostY[7:0] + ghost_padding;
					end
					3'b011 : begin //D--> Right
						if(orange_ghost_animation_count >= 7'd0 && orange_ghost_animation_count < 7'd3)
							ghost_addr = 8'h80 + OrangeGhostY[7:0] + ghost_padding;
						else
							ghost_addr = 8'h90 + OrangeGhostY[7:0] + ghost_padding;
					end
					default : //Shouldn't hit the default case
						ghost_addr = 8'h20 + OrangeGhostY[7:0] + ghost_padding;
				endcase
			end
		end
		else if(is_cyan_ghost) begin
			map_addr = 9'bz;
			sprite_addr = 8'bz;
			death_addr = 8'bz;
			DistX = CyanGhostX;
			DistY = CyanGhostY;
			if(is_cyan_scared) begin
				if(cyan_ghost_animation_count >= 7'd0 && cyan_ghost_animation_count < 7'd3)
					ghost_addr = 8'h00 + CyanGhostY[7:0] + ghost_padding;
				else 
					ghost_addr = 8'h10 + CyanGhostY[7:0] + ghost_padding;
			end
			else begin
				case (cyan_ghost_direction)
					3'b000 : begin //W--> Up
						if(cyan_ghost_animation_count >= 7'd0 && cyan_ghost_animation_count < 7'd3)
							ghost_addr = 8'h20 + CyanGhostY[7:0] + ghost_padding;
						else 
							ghost_addr = 8'h30 + CyanGhostY[7:0] + ghost_padding;
					end
					3'b001 : begin //A--> Left
						if(cyan_ghost_animation_count >= 7'd0 && cyan_ghost_animation_count < 7'd3)
							ghost_addr = 8'h40 + CyanGhostY[7:0] + ghost_padding;
						else
							ghost_addr = 8'h50 + CyanGhostY[7:0] + ghost_padding;
					end 
					3'b010 : begin //S--> Down
						if(cyan_ghost_animation_count >= 7'd0 && cyan_ghost_animation_count < 7'd3)
							ghost_addr = 8'h60 + CyanGhostY[7:0] + ghost_padding;
						else
							ghost_addr = 8'h70 + CyanGhostY[7:0] + ghost_padding;
					end
					3'b011 : begin //D--> Right
						if(cyan_ghost_animation_count >= 7'd0 && cyan_ghost_animation_count < 7'd3)
							ghost_addr = 8'h80 + CyanGhostY[7:0] + ghost_padding;
						else
							ghost_addr = 8'h90 + CyanGhostY[7:0] + ghost_padding;
					end
					default : //Shouldn't hit the default case
						ghost_addr = 8'h20 + CyanGhostY[7:0] + ghost_padding;
				endcase
			end
		end
		else if(is_pink_ghost) begin
			map_addr = 9'bz;
			sprite_addr = 8'bz;
			death_addr = 8'bz;
			DistX = PinkGhostX;
			DistY = PinkGhostY;
			if(is_pink_scared) begin
				if(pink_ghost_animation_count >= 7'd0 && pink_ghost_animation_count < 7'd3)
					ghost_addr = 8'h00 + PinkGhostY[7:0] + ghost_padding;
				else 
					ghost_addr = 8'h10 + PinkGhostY[7:0] + ghost_padding;
			end
			else begin
				case(pink_ghost_direction)
					3'b000 : begin //W--> Up
						if(pink_ghost_animation_count >= 7'd0 && pink_ghost_animation_count < 7'd3)
							ghost_addr = 8'h20 + PinkGhostY[7:0] + ghost_padding;
						else 
							ghost_addr = 8'h30 + PinkGhostY[7:0] + ghost_padding;
					end
					3'b001 : begin //A--> Left
						if(pink_ghost_animation_count >= 7'd0 && pink_ghost_animation_count < 7'd3)
							ghost_addr = 8'h40 + PinkGhostY[7:0] + ghost_padding;
						else
							ghost_addr = 8'h50 + PinkGhostY[7:0] + ghost_padding;
					end 
					3'b010 : begin //S--> Down
						if(pink_ghost_animation_count >= 7'd0 && pink_ghost_animation_count < 7'd3)
							ghost_addr = 8'h60 + PinkGhostY[7:0] + ghost_padding;
						else
							ghost_addr = 8'h70 + PinkGhostY[7:0] + ghost_padding;
					end
					3'b011 : begin //D--> Right
						if(pink_ghost_animation_count >= 7'd0 && pink_ghost_animation_count < 7'd3)
							ghost_addr = 8'h80 + PinkGhostY[7:0] + ghost_padding;
						else
							ghost_addr = 8'h90 + PinkGhostY[7:0] + ghost_padding;
					end
					default : //Shouldn't hit the default case
						ghost_addr = 8'h20 + PinkGhostY[7:0] + ghost_padding;
				endcase
			end
		end
		else if(is_dot) begin
			map_addr = 9'bz;
			sprite_addr = 8'bz;
			death_addr = 8'bz;
			ghost_addr = 8'bz;
			DistX = 10'bz;
			DistY = 10'bz;
		end
		else if(is_Map) begin
			DistX = MapX;
			DistY = MapY;
			sprite_addr = 8'bz;
			death_addr = 8'bz; 
			ghost_addr = 8'bz;
			map_addr = MapY[8:0] + map_padding;
		end
		else begin 
			map_addr = 9'bz;
			sprite_addr = 8'bz;
			death_addr = 8'bz;
			ghost_addr = 8'bz;
			DistX = 10'bz;
			DistY = 10'bz;
		end
	end
endmodule 