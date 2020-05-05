module pacman_sprite(input          		Clk,                // 50 MHz clock
                                            Reset,              // Active-high reset signal
                                            frame_clk,          // The clock indicating a new frame (~60Hz)
                                            reload, hold, dying,
                    input  		 [7:0]  	keycode, 			  // WASD codes
                    input  		 [9:0]  	DrawX, DrawY,       // Current pixel coordinates
                    output                  frame_clk_rising_edge,
                    output logic  [9:0]  	PacX, PacY,			  // How deep into the sprite the current pixel is
                    output logic   			is_Pac,              // Whether current pixel belongs to Pac or background
                    output logic  [2:0]     direction_out,
                    output logic  [6:0] 	animation_count,
                    output logic  [9:0]     PacX_Monitor, PacY_Monitor);
    //256
	//227
	parameter [9:0] Pac_X_Start = 10'd256 + Pac_X_Min; //(X,Y) starting position of pacman upon reset
    parameter [9:0] Pac_Y_Start = 10'd318 + Pac_Y_Min; 
    parameter [9:0] Pac_X_Min = 10'd64;      // Leftmost point on the X axis
    parameter [9:0] Pac_X_Max = 10'd576;     // Rightmost point on the X axis
    parameter [9:0] Pac_Y_Min = 10'd48;      // Topmost point on the Y axis
    parameter [9:0] Pac_Y_Max = 10'd432;     // Bottommost point on the Y axis
    parameter [9:0] Pac_X_Step = 10'd1;      // Step size on the X axis
    parameter [9:0] Pac_Y_Step = 10'd1;      // Step size on the Y axis
    
    logic [9:0] Pac_X_Pos, Pac_X_Motion, Pac_Y_Pos, Pac_Y_Motion;
    logic [9:0] Pac_X_Pos_in, Pac_X_Motion_in, Pac_Y_Pos_in, Pac_Y_Motion_in;
    logic [2:0] direction, next_direction;
	logic [6:0] animation, next_animation; //registers used for animation sprites
    logic [9:0]     Pac_lu_x, Pac_lu_y, 
                    Pac_l4_x, Pac_l4_y,
                    Pac_lc_x, Pac_lc_y,
                    Pac_l11_x, Pac_l11_y,
                    Pac_ld_x, Pac_ld_y, 
                    Pac_dl_x, Pac_dl_y,
                    Pac_d4_x, Pac_d4_y,
                    Pac_dc_x, Pac_dc_y,
                    Pac_d11_x, Pac_d11_y,
                    Pac_dr_x, Pac_dr_y, 
                    Pac_rd_x, Pac_rd_y,
                    Pac_r11_x, Pac_r11_y, 
                    Pac_rc_x, Pac_rc_y, 
                    Pac_r4_x, Pac_r4_y, 
                    Pac_ru_x, Pac_ru_y, 
                    Pac_ur_x, Pac_ur_y,
                    Pac_u11_x, Pac_u11_y,
                    Pac_uc_x, Pac_uc_y,
                    Pac_u4_x, Pac_u4_y,
                    Pac_ul_x, Pac_ul_y;
	
    logic       lu_isWall, l4_isWall, lc_isWall, l11_isWall, ld_isWall, 
                dl_isWall, d4_isWall, dc_isWall, d11_isWall, dr_isWall, 
                rd_isWall, r4_isWall, rc_isWall, r11_isWall, ru_isWall, 
                ur_isWall, u4_isWall, uc_isWall, u11_isWall, ul_isWall;

	assign PacX_Monitor = Pac_X_Pos;
	assign PacY_Monitor = Pac_Y_Pos;
    assign direction_out = direction;
	assign animation_count = animation;
	 //////// Do not modify the always_ff blocks. ////////
    // Detect rising edge of frame_clk
    logic frame_clk_delayed;
    always_ff @ (posedge Clk) begin
        frame_clk_delayed <= frame_clk;
        frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
    end
    // Update registers
    always_ff @ (posedge Clk)
    begin
        if (Reset || reload)
        begin
            Pac_X_Pos <= Pac_X_Start;
            Pac_Y_Pos <= Pac_Y_Start;
            Pac_X_Motion <= 10'd0;
            Pac_Y_Motion <= 10'd0;
				direction <= 3'b111;
        end
        else if(hold) begin
            Pac_X_Pos <= Pac_X_Pos;
            Pac_Y_Pos <= Pac_Y_Pos;
            Pac_X_Motion <= 10'd0;
            Pac_Y_Motion <= 10'd0;
			direction <= 3'b111;
        end
        else begin
            Pac_X_Pos <= Pac_X_Pos_in;
            Pac_Y_Pos <= Pac_Y_Pos_in;
            Pac_X_Motion <= Pac_X_Motion_in;
            Pac_Y_Motion <= Pac_Y_Motion_in;
			direction <= next_direction;
        end
    end
    //////// Do not modify the always_ff blocks. ////////

    always_ff @ (posedge Clk) begin
		if(Reset || reload)
			animation <= 7'd0;
		else
			animation <= next_animation;
    end
    
    logic flag, next_flag;
    always_ff @ (posedge Clk) begin
		if(Reset || reload)
			flag <= 1'b0;
		else 
			flag <= next_flag;
    end
    //instansiate wallchecking modules to do collision logic 
    wallChecker LU (.x(Pac_lu_x), .y(Pac_lu_y), .is_wall(lu_isWall));
    wallChecker L4 (.x(Pac_l4_x), .y(Pac_l4_y), .is_wall(l4_isWall));
    wallChecker LC (.x(Pac_lc_x), .y(Pac_lc_y), .is_wall(lc_isWall));
    wallChecker L11 (.x(Pac_l11_x), .y(Pac_l11_y), .is_wall(l11_isWall));
    wallChecker LD (.x(Pac_ld_x), .y(Pac_ld_y), .is_wall(ld_isWall));

    wallChecker DL (.x(Pac_dl_x), .y(Pac_dl_y), .is_wall(dl_isWall));
    wallChecker D4 (.x(Pac_d4_x), .y(Pac_d4_y), .is_wall(d4_isWall));
    wallChecker DC (.x(Pac_dc_x), .y(Pac_dc_y), .is_wall(dc_isWall));
    wallChecker D11 (.x(Pac_d11_x), .y(Pac_d11_y), .is_wall(d11_isWall));    
    wallChecker DR (.x(Pac_dr_x), .y(Pac_dr_y), .is_wall(dr_isWall));

    wallChecker RD (.x(Pac_rd_x), .y(Pac_rd_y), .is_wall(rd_isWall));
    wallChecker R11 (.x(Pac_r11_x), .y(Pac_r11_y), .is_wall(r11_isWall));
    wallChecker RC (.x(Pac_rc_x), .y(Pac_rc_y), .is_wall(rc_isWall));
    wallChecker R4 (.x(Pac_r4_x), .y(Pac_r4_y), .is_wall(r4_isWall));
    wallChecker RU (.x(Pac_ru_x), .y(Pac_ru_y), .is_wall(ru_isWall));

    wallChecker UR (.x(Pac_ur_x), .y(Pac_ur_y), .is_wall(ur_isWall));
    wallChecker U11 (.x(Pac_u11_x), .y(Pac_u11_y), .is_wall(u11_isWall));
    wallChecker UC (.x(Pac_uc_x), .y(Pac_uc_y), .is_wall(uc_isWall));
    wallChecker U4 (.x(Pac_u4_x), .y(Pac_u4_y), .is_wall(u4_isWall));
    wallChecker UL (.x(Pac_ul_x), .y(Pac_ul_y), .is_wall(ul_isWall));
    
    always_comb begin
        //by default, position/motion of pacman remains unchanged, but pacman is always being animated (except for when he colides or is still
        Pac_X_Pos_in = Pac_X_Pos;
        Pac_Y_Pos_in = Pac_Y_Pos;
        Pac_X_Motion_in = Pac_X_Motion;
        Pac_Y_Motion_in = Pac_Y_Motion;
        next_direction = direction;
        next_animation = animation;
        next_flag = flag;
        //update boundary checking pixel coordinates of the pacman sprite 
        Pac_ul_x = Pac_X_Pos  + 10'd1 - 10'd8 - 10'd64;
        Pac_ul_y = Pac_Y_Pos  + 10'd1 - 10'd9 - 10'd48 - 10'd1;
        Pac_u4_x = Pac_X_Pos  + 10'd1 - 10'd4 - 10'd64;
        Pac_u4_y = Pac_Y_Pos  + 10'd1 - 10'd9 - 10'd48 - 10'd1;
        Pac_uc_x = Pac_X_Pos  + 10'd0 - 10'd64;
        Pac_uc_y = Pac_Y_Pos  + 10'd1 - 10'd9 - 10'd48 - 10'd1;
        Pac_u11_x = Pac_X_Pos - 10'd1 + 10'd3 - 10'd64;
        Pac_u11_y = Pac_Y_Pos + 10'd1 - 10'd9 - 10'd48 - 10'd1;
        Pac_ur_x = Pac_X_Pos  - 10'd1 + 10'd7 - 10'd64;
        Pac_ur_y = Pac_Y_Pos  + 10'd1 - 10'd9 - 10'd48 - 10'd1;

        Pac_ru_x = Pac_X_Pos  - 10'd1 + 10'd8 - 10'd64 + 10'd1;
        Pac_ru_y = Pac_Y_Pos  + 10'd1 - 10'd8 - 10'd48;
        Pac_r4_x = Pac_X_Pos  - 10'd1 + 10'd8 - 10'd64 + 10'd1;
        Pac_r4_y = Pac_Y_Pos  + 10'd1 - 10'd4 - 10'd48;
        Pac_rc_x = Pac_X_Pos  - 10'd1 + 10'd8 - 10'd64 + 10'd1;
        Pac_rc_y = Pac_Y_Pos  + 10'd0 - 10'd48;
        Pac_r11_x = Pac_X_Pos - 10'd1 + 10'd8 - 10'd64 + 10'd1;
        Pac_r11_y = Pac_Y_Pos - 10'd1 + 10'd3 - 10'd48;
        Pac_rd_x = Pac_X_Pos  - 10'd1 + 10'd8 - 10'd64 + 10'd1;
        Pac_rd_y = Pac_Y_Pos  - 10'd1 + 10'd7 - 10'd48;

        Pac_dr_x = Pac_X_Pos  - 10'd1 + 10'd7 - 10'd64;
        Pac_dr_y = Pac_Y_Pos  - 10'd1 + 10'd8 - 10'd48 + 10'd1;
        Pac_d11_x = Pac_X_Pos - 10'd1 + 10'd3 - 10'd64;
        Pac_d11_y = Pac_Y_Pos - 10'd1 + 10'd8 - 10'd48 + 10'd1;
        Pac_dc_x = Pac_X_Pos  + 10'd0 - 10'd64;
        Pac_dc_y = Pac_Y_Pos  - 10'd1 + 10'd8 - 10'd48 + 10'd1;
        Pac_d4_x = Pac_X_Pos  + 10'd1 - 10'd4 - 10'd64;
        Pac_d4_y = Pac_Y_Pos  - 10'd1 + 10'd8 - 10'd48 + 10'd1;
        Pac_dl_x = Pac_X_Pos  + 10'd1 - 10'd8 - 10'd64;
        Pac_dl_y = Pac_Y_Pos  - 10'd1 + 10'd8 - 10'd48 + 10'd1;

        Pac_ld_x = Pac_X_Pos  + 10'd1 - 10'd9 - 10'd64 - 10'd1;
        Pac_ld_y = Pac_Y_Pos  - 10'd1 + 10'd7 - 10'd48;
        Pac_l11_x = Pac_X_Pos + 10'd1 - 10'd9 - 10'd64 - 10'd1;
        Pac_l11_y = Pac_Y_Pos - 10'd1 + 10'd3 - 10'd48;
        Pac_lc_x = Pac_X_Pos  + 10'd1 - 10'd9 - 10'd64 - 10'd1;
        Pac_lc_y = Pac_Y_Pos  + 10'd0 - 10'd48;
        Pac_l4_x = Pac_X_Pos  + 10'd1 - 10'd9 - 10'd64 - 10'd1;
        Pac_l4_y = Pac_Y_Pos  + 10'd1 - 10'd4 - 10'd48;
        Pac_lu_x = Pac_X_Pos  + 10'd1 - 10'd9 - 10'd64 - 10'd1; // (Center_coord - sprite_wall_check_offset - gradient_border_offset - 2pixel's_ahead_offset)
        Pac_lu_y = Pac_Y_Pos  + 10'd1 - 10'd8 - 10'd48;
        //update position and motion only at rising edge of frame clock 
        if(frame_clk_rising_edge) begin
				//animation counting logic
				if(direction != 3'b111) begin
					if(animation == 7'd6) begin
						next_flag = 1'b1;
						next_animation = animation - 7'd1;
					end
					else if(animation == 7'd0) begin
						next_flag = 1'b0;
						next_animation = animation + 7'd1;
					end
					else if(animation != 7'd0 && animation != 7'd6 && flag == 1'b1)
						next_animation = animation - 7'd1;
					else if (animation != 7'd0 && animation != 7'd6 && flag == 1'b0)
						next_animation = animation + 7'd1;				
				end
            
				if(direction == 3'b000) begin
                if(ul_isWall == 1'b1 || u4_isWall == 1'b1 || uc_isWall == 1'b1 || u11_isWall == 1'b1 || ur_isWall == 1'b1) begin
                    Pac_X_Motion_in = 10'd0;
                    Pac_Y_Motion_in = 10'd0;
                    next_direction = 3'b111;
                    next_animation = animation;
                end
            end
            else if (direction == 3'b001) begin
                if(lu_isWall == 1'b1 || l4_isWall == 1'b1 || lc_isWall == 1'b1 || l11_isWall == 1'b1 || ld_isWall == 1'b1) begin
                    Pac_X_Motion_in = 10'd0;
                    Pac_Y_Motion_in = 10'd0;
                    next_direction = 3'b111;
                    next_animation = animation;						  
                end
            end
            else if (direction == 3'b010) begin
                if(dl_isWall == 1'b1 || d4_isWall == 1'b1 || dc_isWall == 1'b1 || d11_isWall == 1'b1 || dr_isWall == 1'b1) begin
                    Pac_X_Motion_in = 10'd0;
                    Pac_Y_Motion_in = 10'd0;
                    next_direction = 3'b111;
                    next_animation = animation;						  
                end            
            end
            else if (direction == 3'b011) begin
                if(ru_isWall == 1'b1 || r4_isWall == 1'b1 || rc_isWall == 1'b1 || r11_isWall == 1'b1 || rd_isWall == 1'b1) begin
                    Pac_X_Motion_in = 10'd0;
                    Pac_Y_Motion_in = 10'd0;
                    next_direction = 3'b111;
                    next_animation = animation;						  
                end           
            end
            //handle key presses
            //"W" is pressed, attempt to move up
            if(keycode == 8'h1A) begin 
                if(direction == 3'b001 || direction == 3'b011 || direction == 3'b111) begin //currently moving horizontally, check to see if we can move upward
                    if(ul_isWall == 1'b0 && u4_isWall == 1'b0 && uc_isWall == 1'b0 && u11_isWall == 1'b0 && ur_isWall == 1'b0) begin //we can move upward, if we can't then don't update the motion or direction
                        next_direction = 3'b000;
                        Pac_X_Motion_in = 10'd0;
                        Pac_Y_Motion_in = (~(Pac_Y_Step) + 1'b1);
                    end
                    else begin
						next_animation = animation;
                    end
                end
                else begin //currently moving vertically
                    next_direction = 3'b000;
                    Pac_X_Motion_in = 10'd0;
                    Pac_Y_Motion_in = (~(Pac_Y_Step) + 1'b1);
						  //if we press "W" and and we hit a wall while moving vertically, then we stop moving, otherwise keep the motion and direction same
                    if(ul_isWall == 1'b1 || u4_isWall == 1'b1 || uc_isWall == 1'b1 || u11_isWall == 1'b1 || ur_isWall == 1'b1) begin
                        next_direction = 3'b111; 
                        Pac_X_Motion_in = 10'd0;
                        Pac_Y_Motion_in = 10'd0;
						next_animation = animation;
                    end
                end
            end
            //"A" is pressed, attempt to move left
            else if (keycode == 8'h04) begin
                if(direction == 3'b000 || direction == 3'b010 || direction == 3'b111) begin //currently moving vertically, check to see if we can move left
                    if(lu_isWall == 1'b0 && l4_isWall == 1'b0 && lc_isWall == 1'b0 && l11_isWall == 1'b0 && ld_isWall == 1'b0) begin //we can move left, if we can't then don't update the motion or direction
                        next_direction = 3'b001; 
                        Pac_X_Motion_in = (~(Pac_X_Step) + 1'b1);
                        Pac_Y_Motion_in = 10'd0;
                    end
                    else begin
                        next_animation = animation;
                    end
                end
                else begin //currently moving horizontally
                    next_direction = 3'b001;
                    Pac_X_Motion_in = ((~Pac_X_Step) + 1'b1);
                    Pac_Y_Motion_in = 10'd0;
                    //if we press "A" and we hit a wall while moving horizontally, then we stop moving, otherwise keep the motion and direction same
                    if(lu_isWall == 1'b1 || l4_isWall == 1'b1 || lc_isWall == 1'b1 || l11_isWall == 1'b1 || ld_isWall == 1'b1) begin
                        next_direction = 3'b111;
                        Pac_X_Motion_in = 10'd0;
                        Pac_Y_Motion_in = 10'd0;
						next_animation = animation;
                    end
                end
            end
            //"S" is pressed, attempt to move downward
            else if (keycode == 8'h16) begin
                if(direction == 3'b001 || direction == 3'b011 || direction == 3'b111) begin //currently moving horizontally, check to see if we can move downward
                    if(dl_isWall == 1'b0 && d4_isWall == 1'b0 && dc_isWall == 1'b0 && d11_isWall == 1'b0 && dr_isWall == 1'b0) begin //we can move downward, if we can't then don't update the motion or direction
                        next_direction = 3'b010;
                        Pac_X_Motion_in = 10'd0;
                        Pac_Y_Motion_in = Pac_Y_Step;
                    end
                    else begin
                        next_animation = animation;
                    end
                end
                else begin //currently moving vertically
                    next_direction = 3'b010;
                    Pac_X_Motion_in = 10'd0;
                    Pac_Y_Motion_in = Pac_Y_Step;
                    //if we press "S" and and we hit a wall while moving vertically, then we stop moving, otherwise keep the motion and direction same
                    if(dl_isWall == 1'b1 || d4_isWall == 1'b1 || dc_isWall == 1'b1 || d11_isWall == 1'b1 || dr_isWall == 1'b1) begin
                        next_direction = 3'b111; 
                        Pac_X_Motion_in = 10'd0;
                        Pac_Y_Motion_in = 10'd0;
						next_animation = animation;
                    end
                end
            end
            //"D" is pressed, attempt to move right
            else if (keycode == 8'h07) begin
                if(direction == 3'b000 || direction == 3'b010 || direction == 3'b111) begin //currently moving vertically, check to see if we can move right
                    if(ru_isWall == 1'b0 && r4_isWall == 1'b0 && rc_isWall == 1'b0 && r11_isWall == 1'b0 && rd_isWall == 1'b0) begin //we can move right, if we can't then don't update the motion or direction
                        next_direction = 3'b011; 
                        Pac_X_Motion_in = Pac_X_Step;
                        Pac_Y_Motion_in = 10'd0;
                    end
                    else begin
						next_animation = animation;
                    end
                end
                else begin //currently moving horizontally
                    next_direction = 3'b011;
					Pac_X_Motion_in = Pac_X_Step;
                    Pac_Y_Motion_in = 10'd0;
                    //if we press "D" and we hit a wall while moving horizontally, then we stop moving, otherwise keep the motion and direction same
                    if(ru_isWall == 1'b1 || r4_isWall == 1'b1 || rc_isWall == 1'b1 || r11_isWall == 1'b1 || rd_isWall == 1'b1) begin
                        next_direction = 3'b111;
                        Pac_X_Motion_in = 10'd0;
                        Pac_Y_Motion_in = 10'd0;
						next_animation = animation;
                    end
                end
            end
            if((Pac_Y_Pos >= Pac_Y_Max) || (Pac_Y_Pos <= Pac_Y_Min)) begin 
                if(Pac_Y_Pos >= Pac_Y_Max) //going down
                    Pac_Y_Pos_in = Pac_Y_Min + 10'd1 + Pac_Y_Motion_in; 
                else //going up
                    Pac_Y_Pos_in = Pac_Y_Max - 10'd1 + Pac_Y_Motion_in; 
            end
            else if((Pac_X_Pos >= Pac_X_Max) || (Pac_X_Pos <= Pac_X_Min)) begin
                if(Pac_X_Pos >= Pac_X_Max) begin //going right
                    Pac_X_Pos_in = Pac_X_Min + 10'd1 + Pac_X_Motion_in;
                end
                else begin //going left
                    Pac_X_Pos_in = Pac_X_Max - 10'd1 + Pac_X_Motion_in;
                end
            end	            
            else begin
                Pac_X_Pos_in = Pac_X_Pos + Pac_X_Motion;
                Pac_Y_Pos_in = Pac_Y_Pos + Pac_Y_Motion;  
            end
        end
    end
    //determine whether the DrawX and DrawY a pacman coordinate 
    assign PacX = DrawX - Pac_X_Pos + 10'd8;
    assign PacY = DrawY - Pac_Y_Pos + 10'd8;    
    always_comb begin
        if(dying) begin
            if (PacX >= 10'd0 && PacX < 10'd16 && PacY >= 10'd0 && PacY < 10'd16) 
                is_Pac = 1'b1;
            else
                is_Pac = 1'b0;
        end
        else begin
            if (PacX >= 10'd1 && PacX < 10'd14 && PacY >= 10'd1 && PacY < 10'd14) 
                is_Pac = 1'b1;
            else
                is_Pac = 1'b0;
        end
    end
endmodule
