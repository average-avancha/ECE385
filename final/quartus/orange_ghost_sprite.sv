module orange_ghost_sprite (input          		Clk,                // 50 MHz clock
												Reset,              // Active-high reset signal
												frame_clk,          // The clock indicating a new frame (~60Hz)
                                                reload, hold,
                            input  		  [9:0] DrawX, DrawY, PacX, PacY,  // Current pixel coordinates
                            input         [2:0] direction_out,             //Pacman's current direction
                            output logic  [9:0] OrangeGhostX, OrangeGhostY,	   // How deep into the sprite the current pixel is
                            output logic   		is_orange_ghost,              // Whether current pixel belongs to Pac or background
                            output logic  [2:0] orange_ghost_direction_out,
                            output logic  [6:0] orange_ghost_animation_count,
                            output logic  [9:0] OrangeGhostX_Monitor, OrangeGhostY_Monitor);

    parameter [9:0] OrangeGhost_X_Start = 10'd270 + OrangeGhost_X_Min; //(X,Y) starting position of Orange Ghost upon reset
    parameter [9:0] OrangeGhost_Y_Start = 10'd157 + OrangeGhost_Y_Min; 
    parameter [9:0] OrangeGhost_X_Min = 10'd64;      // Leftmost point on the X axis
    parameter [9:0] OrangeGhost_X_Max = 10'd576;     // Rightmost point on the X axis
    parameter [9:0] OrangeGhost_Y_Min = 10'd48;      // Topmost point on the Y axis
    parameter [9:0] OrangeGhost_Y_Max = 10'd432;     // Bottommost point on the Y axis
    parameter [9:0] OrangeGhost_X_Step = 10'd1;      // Step size on the X axis
    parameter [9:0] OrangeGhost_Y_Step = 10'd1;      // Step size on the Y axis
    
    logic [9:0] OrangeGhost_X_Pos, OrangeGhost_X_Motion, OrangeGhost_Y_Pos, OrangeGhost_Y_Motion;
    logic [9:0] OrangeGhost_X_Pos_in, OrangeGhost_X_Motion_in, OrangeGhost_Y_Pos_in, OrangeGhost_Y_Motion_in;
    logic [2:0] direction, next_direction, prev_direction, next_prev_direction, alignment_direction, next_alignment_direction;
    logic [6:0] animation, next_animation; //registers used for animation sprites
    logic [9:0]     OrangeGhost_lu_x, OrangeGhost_lu_y, 
                    OrangeGhost_l4_x, OrangeGhost_l4_y,
                    OrangeGhost_lc_x, OrangeGhost_lc_y,
                    OrangeGhost_l11_x, OrangeGhost_l11_y,
                    OrangeGhost_ld_x, OrangeGhost_ld_y, 
                    OrangeGhost_dl_x, OrangeGhost_dl_y,
                    OrangeGhost_d4_x, OrangeGhost_d4_y,
                    OrangeGhost_dc_x, OrangeGhost_dc_y,
                    OrangeGhost_d11_x, OrangeGhost_d11_y,
                    OrangeGhost_dr_x, OrangeGhost_dr_y, 
                    OrangeGhost_rd_x, OrangeGhost_rd_y,
                    OrangeGhost_r11_x, OrangeGhost_r11_y, 
                    OrangeGhost_rc_x, OrangeGhost_rc_y, 
                    OrangeGhost_r4_x, OrangeGhost_r4_y, 
                    OrangeGhost_ru_x, OrangeGhost_ru_y, 
                    OrangeGhost_ur_x, OrangeGhost_ur_y,
                    OrangeGhost_u11_x, OrangeGhost_u11_y,
                    OrangeGhost_uc_x, OrangeGhost_uc_y,
                    OrangeGhost_u4_x, OrangeGhost_u4_y,
                    OrangeGhost_ul_x, OrangeGhost_ul_y;

    logic       lu_isWall, l4_isWall, lc_isWall, l11_isWall, ld_isWall, 
                dl_isWall, d4_isWall, dc_isWall, d11_isWall, dr_isWall, 
                rd_isWall, r4_isWall, rc_isWall, r11_isWall, ru_isWall, 
                ur_isWall, u4_isWall, uc_isWall, u11_isWall, ul_isWall;

	 //////// Do not modify the always_ff blocks. ////////
    // Detect rising edge of frame_clk
    logic frame_clk_delayed, frame_clk_rising_edge;
    always_ff @ (posedge Clk) begin
        frame_clk_delayed <= frame_clk;
        frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
    end
	 // Update registers
    always_ff @ (posedge Clk)
    begin
        if (Reset || reload)
        begin
            OrangeGhost_X_Pos <= OrangeGhost_X_Start;
            OrangeGhost_Y_Pos <= OrangeGhost_Y_Start;
            OrangeGhost_X_Motion <= 10'd0;
            OrangeGhost_Y_Motion <= 10'd0;
			direction <= 3'b111;
        end
        else if(hold) begin
			OrangeGhost_X_Pos <= OrangeGhost_X_Pos;
            OrangeGhost_Y_Pos <= OrangeGhost_Y_Pos;
            OrangeGhost_X_Motion <= 10'd0;
            OrangeGhost_Y_Motion <= 10'd0;
			direction <= 3'b111;
		end
        else begin
            OrangeGhost_X_Pos <= OrangeGhost_X_Pos_in;
            OrangeGhost_Y_Pos <= OrangeGhost_Y_Pos_in;
            OrangeGhost_X_Motion <= OrangeGhost_X_Motion_in;
            OrangeGhost_Y_Motion <= OrangeGhost_Y_Motion_in;
			direction <= next_direction;
        end
    end
	//killer ghost allignment register
    always_ff @ (posedge Clk) begin
		if (Reset || reload)
			alignment_direction <= 3'b111;
		else
			alignment_direction <= next_alignment_direction;
	end
	
	 //Animation Registers
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
	
	//Prev Direction Register
	always_ff @ (posedge Clk) begin
		if(Reset || reload)
			prev_direction <= 3'b000;
		else
			prev_direction <= next_prev_direction;
	end
	always_comb begin
		next_prev_direction = orange_ghost_direction_out;
		if(orange_ghost_direction_out == 3'b111)
			next_prev_direction = prev_direction;
	end
	
	logic [2:0] countdown, next_countdown;
	//delay a change in alignment
	always_ff @ (posedge Clk) begin
		if(Reset || reload)
			countdown <= 3'b111;
		else
			countdown <= next_countdown;
	end
    
    logic deciding, next_deciding; 
    always_ff @ (posedge Clk) begin
        if(Reset || reload)
            deciding <= 1'b1;
        else 
            deciding <= next_deciding;
    end

    logic [2:0] timer, next_timer;
    always_ff @ (posedge Clk) begin
        if(Reset || reload)
            timer <= 3'b000;
        else 
            timer <= next_timer;
    end
    wallChecker LU (.x(OrangeGhost_lu_x), .y(OrangeGhost_lu_y), .is_wall(lu_isWall));
    wallChecker L4 (.x(OrangeGhost_l4_x), .y(OrangeGhost_l4_y), .is_wall(l4_isWall));
    wallChecker LC (.x(OrangeGhost_lc_x), .y(OrangeGhost_lc_y), .is_wall(lc_isWall));
    wallChecker L11 (.x(OrangeGhost_l11_x), .y(OrangeGhost_l11_y), .is_wall(l11_isWall));
    wallChecker LD (.x(OrangeGhost_ld_x), .y(OrangeGhost_ld_y), .is_wall(ld_isWall));

    wallChecker DL (.x(OrangeGhost_dl_x), .y(OrangeGhost_dl_y), .is_wall(dl_isWall));
    wallChecker D4 (.x(OrangeGhost_d4_x), .y(OrangeGhost_d4_y), .is_wall(d4_isWall));
    wallChecker DC (.x(OrangeGhost_dc_x), .y(OrangeGhost_dc_y), .is_wall(dc_isWall));
    wallChecker D11 (.x(OrangeGhost_d11_x), .y(OrangeGhost_d11_y), .is_wall(d11_isWall));    
    wallChecker DR (.x(OrangeGhost_dr_x), .y(OrangeGhost_dr_y), .is_wall(dr_isWall));

    wallChecker RD (.x(OrangeGhost_rd_x), .y(OrangeGhost_rd_y), .is_wall(rd_isWall));
    wallChecker R11 (.x(OrangeGhost_r11_x), .y(OrangeGhost_r11_y), .is_wall(r11_isWall));
    wallChecker RC (.x(OrangeGhost_rc_x), .y(OrangeGhost_rc_y), .is_wall(rc_isWall));
    wallChecker R4 (.x(OrangeGhost_r4_x), .y(OrangeGhost_r4_y), .is_wall(r4_isWall));
    wallChecker RU (.x(OrangeGhost_ru_x), .y(OrangeGhost_ru_y), .is_wall(ru_isWall));

    wallChecker UR (.x(OrangeGhost_ur_x), .y(OrangeGhost_ur_y), .is_wall(ur_isWall));
    wallChecker U11 (.x(OrangeGhost_u11_x), .y(OrangeGhost_u11_y), .is_wall(u11_isWall));
    wallChecker UC (.x(OrangeGhost_uc_x), .y(OrangeGhost_uc_y), .is_wall(uc_isWall));
    wallChecker U4 (.x(OrangeGhost_u4_x), .y(OrangeGhost_u4_y), .is_wall(u4_isWall));
    wallChecker UL (.x(OrangeGhost_ul_x), .y(OrangeGhost_ul_y), .is_wall(ul_isWall));
    
	assign OrangeGhostX_Monitor = OrangeGhost_X_Pos;
	assign OrangeGhostY_Monitor = OrangeGhost_Y_Pos;
	 //animation register combinational logic
	assign orange_ghost_direction_out = direction;
	assign orange_ghost_animation_count = animation;
	
    logic can_go_up, can_go_left, can_go_down, can_go_right;
    always_comb begin
        can_go_up    = ul_isWall == 1'b0 && u4_isWall == 1'b0 && uc_isWall == 1'b0 && u11_isWall == 1'b0 && ur_isWall == 1'b0;
        can_go_left  = lu_isWall == 1'b0 && l4_isWall == 1'b0 && lc_isWall == 1'b0 && l11_isWall == 1'b0 && ld_isWall == 1'b0;
        can_go_down  = dl_isWall == 1'b0 && d4_isWall == 1'b0 && dc_isWall == 1'b0 && d11_isWall == 1'b0 && dr_isWall == 1'b0;
        can_go_right = ru_isWall == 1'b0 && r4_isWall == 1'b0 && rc_isWall == 1'b0 && r11_isWall == 1'b0 && rd_isWall == 1'b0;
    end


	always_comb begin
        //by default, position/motion of OrangeGhostman remains unchanged, but OrangeGhostman is always being animated (except for when he colides or is still
        OrangeGhost_X_Pos_in = OrangeGhost_X_Pos;
        OrangeGhost_Y_Pos_in = OrangeGhost_Y_Pos;
        OrangeGhost_X_Motion_in = OrangeGhost_X_Motion;
        OrangeGhost_Y_Motion_in = OrangeGhost_Y_Motion;
        next_direction = direction;
        next_animation = animation;
		next_alignment_direction = alignment_direction;
		next_flag = flag;
		next_countdown = countdown;
        next_timer = timer;
		  next_deciding = deciding;
        //update boundary checking pixel coordinates of the OrangeGhostman sprite 
        OrangeGhost_ul_x = OrangeGhost_X_Pos  + 10'd0 - 10'd8 - 10'd64;
        OrangeGhost_ul_y = OrangeGhost_Y_Pos  + 10'd0 - 10'd9 - 10'd48 - 10'd1;
        OrangeGhost_u4_x = OrangeGhost_X_Pos  + 10'd0 - 10'd4 - 10'd64;
        OrangeGhost_u4_y = OrangeGhost_Y_Pos  + 10'd0 - 10'd9 - 10'd48 - 10'd1;
        OrangeGhost_uc_x = OrangeGhost_X_Pos  + 10'd0 - 10'd64;
        OrangeGhost_uc_y = OrangeGhost_Y_Pos  + 10'd0 - 10'd9 - 10'd48 - 10'd1;
        OrangeGhost_u11_x = OrangeGhost_X_Pos - 10'd0 + 10'd3 - 10'd64;
        OrangeGhost_u11_y = OrangeGhost_Y_Pos + 10'd0 - 10'd9 - 10'd48 - 10'd1;
        OrangeGhost_ur_x = OrangeGhost_X_Pos  - 10'd0 + 10'd7 - 10'd64;
        OrangeGhost_ur_y = OrangeGhost_Y_Pos  + 10'd0 - 10'd9 - 10'd48 - 10'd1;

        OrangeGhost_ru_x = OrangeGhost_X_Pos  - 10'd0 + 10'd8 - 10'd64 + 10'd1;
        OrangeGhost_ru_y = OrangeGhost_Y_Pos  + 10'd0 - 10'd8 - 10'd48;
        OrangeGhost_r4_x = OrangeGhost_X_Pos  - 10'd0 + 10'd8 - 10'd64 + 10'd1;
        OrangeGhost_r4_y = OrangeGhost_Y_Pos  + 10'd0 - 10'd4 - 10'd48;
        OrangeGhost_rc_x = OrangeGhost_X_Pos  - 10'd0 + 10'd8 - 10'd64 + 10'd1;
        OrangeGhost_rc_y = OrangeGhost_Y_Pos  + 10'd0 - 10'd48;
        OrangeGhost_r11_x = OrangeGhost_X_Pos - 10'd0 + 10'd8 - 10'd64 + 10'd1;
        OrangeGhost_r11_y = OrangeGhost_Y_Pos - 10'd0 + 10'd3 - 10'd48;
        OrangeGhost_rd_x = OrangeGhost_X_Pos  - 10'd0 + 10'd8 - 10'd64 + 10'd1;
        OrangeGhost_rd_y = OrangeGhost_Y_Pos  - 10'd0 + 10'd7 - 10'd48;

        OrangeGhost_dr_x = OrangeGhost_X_Pos  - 10'd0 + 10'd7 - 10'd64;
        OrangeGhost_dr_y = OrangeGhost_Y_Pos  - 10'd0 + 10'd8 - 10'd48 + 10'd1;
        OrangeGhost_d11_x = OrangeGhost_X_Pos - 10'd0 + 10'd3 - 10'd64;
        OrangeGhost_d11_y = OrangeGhost_Y_Pos - 10'd0 + 10'd8 - 10'd48 + 10'd1;
        OrangeGhost_dc_x = OrangeGhost_X_Pos  + 10'd0 - 10'd64;
        OrangeGhost_dc_y = OrangeGhost_Y_Pos  - 10'd0 + 10'd8 - 10'd48 + 10'd1;
        OrangeGhost_d4_x = OrangeGhost_X_Pos  + 10'd0 - 10'd4 - 10'd64;
        OrangeGhost_d4_y = OrangeGhost_Y_Pos  - 10'd0 + 10'd8 - 10'd48 + 10'd1;
        OrangeGhost_dl_x = OrangeGhost_X_Pos  + 10'd0 - 10'd8 - 10'd64;
        OrangeGhost_dl_y = OrangeGhost_Y_Pos  - 10'd0 + 10'd8 - 10'd48 + 10'd1;

        OrangeGhost_ld_x = OrangeGhost_X_Pos  + 10'd0 - 10'd9 - 10'd64 - 10'd1;
        OrangeGhost_ld_y = OrangeGhost_Y_Pos  - 10'd0 + 10'd7 - 10'd48;
        OrangeGhost_l11_x = OrangeGhost_X_Pos + 10'd0 - 10'd9 - 10'd64 - 10'd1;
        OrangeGhost_l11_y = OrangeGhost_Y_Pos - 10'd0 + 10'd3 - 10'd48;
        OrangeGhost_lc_x = OrangeGhost_X_Pos  + 10'd0 - 10'd9 - 10'd64 - 10'd1;
        OrangeGhost_lc_y = OrangeGhost_Y_Pos  + 10'd0 - 10'd48;
        OrangeGhost_l4_x = OrangeGhost_X_Pos  + 10'd0 - 10'd9 - 10'd64 - 10'd1;
        OrangeGhost_l4_y = OrangeGhost_Y_Pos  + 10'd0 - 10'd4 - 10'd48;
        OrangeGhost_lu_x = OrangeGhost_X_Pos  + 10'd0 - 10'd9 - 10'd64 - 10'd1; // (Center_coord - sprite_wall_check_offset - gradient_border_offset - 2pixel's_ahead_offset)
        OrangeGhost_lu_y = OrangeGhost_Y_Pos  + 10'd0 - 10'd8 - 10'd48;
        //update position and motion only at rising edge of frame clock 
        if(frame_clk_rising_edge) begin
            //direction timer
            if(timer == 3'b011)
                next_timer = 3'b000;
            else 
                next_timer = timer + 3'b001;
            
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
                    OrangeGhost_X_Motion_in = 10'd0;
                    OrangeGhost_Y_Motion_in = 10'd0;
                    next_direction = 3'b111;
						next_animation = animation;
                end
            end
            else if (direction == 3'b001) begin
                if(lu_isWall == 1'b1 || l4_isWall == 1'b1 || lc_isWall == 1'b1 || l11_isWall == 1'b1 || ld_isWall == 1'b1) begin
                    OrangeGhost_X_Motion_in = 10'd0;
                    OrangeGhost_Y_Motion_in = 10'd0;
                    next_direction = 3'b111;
						next_animation = animation;						  
                end
            end
            else if (direction == 3'b010) begin
                if(dl_isWall == 1'b1 || d4_isWall == 1'b1 || dc_isWall == 1'b1 || d11_isWall == 1'b1 || dr_isWall == 1'b1) begin
                    OrangeGhost_X_Motion_in = 10'd0;
                    OrangeGhost_Y_Motion_in = 10'd0;
                    next_direction = 3'b111;
					next_animation = animation;						  
                end            
            end
            else if (direction == 3'b011) begin
                if(ru_isWall == 1'b1 || r4_isWall == 1'b1 || rc_isWall == 1'b1 || r11_isWall == 1'b1 || rd_isWall == 1'b1) begin
                    OrangeGhost_X_Motion_in = 10'd0;
                    OrangeGhost_Y_Motion_in = 10'd0;
                    next_direction = 3'b111;
					next_animation = animation;						  
                end           
            end

//////////////////////////////////////////////////// RANDOM MOVEMENT //////////////////////////////////////////////////////////////////
                // if(is_vistiable(timer % 4))
                //     direction = timer % 4;
                // else if(is_vistiable((timer + 1) % 4))
                // else if(is_vistiable((timer + 2) % 4))
                // else if(is_vistiable((timer + 3) % 4))
            if(countdown == 3'b000) begin
				next_countdown = 3'b111; 
				next_deciding = 1'b0; 
			end
            else if(countdown != 3'b111) 
                next_countdown = countdown - 3'd1;
            
            if(deciding == 1'b0) begin
                case (prev_direction)
                    3'b000:
                        next_deciding = (can_go_left == 1'b1 || can_go_right == 1'b1) ? 1'b1 : 1'b0; //|| can_go_up == 1'b1
                    3'b010:
                        next_deciding = (can_go_left == 1'b1 || can_go_right == 1'b1) ? 1'b1 : 1'b0; //|| can_go_down == 1'b1 
                    3'b001: 
                        next_deciding = (can_go_up == 1'b1 || can_go_down == 1'b1) ? 1'b1 : 1'b0; //|| can_go_left == 1'b1 
                    3'b011:
                        next_deciding = (can_go_up == 1'b1 || can_go_down == 1'b1) ? 1'b1 : 1'b0; //|| can_go_right == 1'b1
                    default: ;
                endcase
            end
            if(deciding == 1'b1 && countdown == 3'b111) begin
                case(timer)
                    3'b000: begin
                        //is up visitable and we were not going down before
                        if(can_go_up == 1'b1 && prev_direction != 3'b010) begin
                            next_countdown = countdown - 3'd1;
                            next_direction = 3'b000;
							OrangeGhost_X_Motion_in = 10'd0;
							OrangeGhost_Y_Motion_in = (~(OrangeGhost_Y_Step) + 1'b1);
                        end
                        //is left visitable and we were not going left before
                        else if(can_go_left == 1'b1 && prev_direction != 3'b011) begin
                            next_countdown = countdown - 3'd1;
                            next_direction = 3'b001;
                            OrangeGhost_X_Motion_in = (~(OrangeGhost_X_Step) + 1'b1);
                            OrangeGhost_Y_Motion_in = 10'd0;
                        end
                        //is down visitable and we were not going down before
                        else if(can_go_down == 1'b1 && prev_direction != 3'b000) begin
                            next_countdown = countdown - 3'd1;
                            next_direction = 3'b010;
                            OrangeGhost_X_Motion_in = 10'd0;
                            OrangeGhost_Y_Motion_in = OrangeGhost_Y_Step;
                        end
                        //is right visitable and we were not going right before
                        else if(can_go_right == 1'b1 && prev_direction != 3'b001) begin
                            next_countdown = countdown - 3'd1;
                            next_direction = 3'b011;
                            OrangeGhost_X_Motion_in = OrangeGhost_X_Step;
                            OrangeGhost_Y_Motion_in = 10'd0;
                        end
                    end
                    3'b001: begin
                        //is left visitable and we were not going left before
                        if(can_go_left == 1'b1 && prev_direction != 3'b011) begin
                            next_countdown = countdown - 3'd1;
                            next_direction = 3'b001;
                            OrangeGhost_X_Motion_in = (~(OrangeGhost_X_Step) + 1'b1);
                            OrangeGhost_Y_Motion_in = 10'd0;
                        end
                        //is down visitable and we were not going down before
                        else if(can_go_down == 1'b1 && prev_direction != 3'b000) begin
                            next_countdown = countdown - 3'd1;
                            next_direction = 3'b010;
                            OrangeGhost_X_Motion_in = 10'd0;
                            OrangeGhost_Y_Motion_in = OrangeGhost_Y_Step;
                        end
                        //is up visitable and we were not going down before
                        else if(can_go_up == 1'b1 && prev_direction != 3'b010) begin
                            next_countdown = countdown - 3'd1;
                            next_direction = 3'b000;
							OrangeGhost_X_Motion_in = 10'd0;
							OrangeGhost_Y_Motion_in = (~(OrangeGhost_Y_Step) + 1'b1);
                        end
                        //is right visitable and we were not going right before
                        else if(can_go_right == 1'b1 && prev_direction != 3'b001) begin
                            next_countdown = countdown - 3'd1;
                            next_direction = 3'b011;
                            OrangeGhost_X_Motion_in = OrangeGhost_X_Step;
                            OrangeGhost_Y_Motion_in = 10'd0;
                        end
                    end
                    3'b010: begin
                        //is down visitable and we were not going down before
                        if(can_go_down == 1'b1 && prev_direction != 3'b000) begin
                            next_countdown = countdown - 3'd1;
                            next_direction = 3'b010;
                            OrangeGhost_X_Motion_in = 10'd0;
                            OrangeGhost_Y_Motion_in = OrangeGhost_Y_Step;
                        end
                         //is left visitable and we were not going left before
                        else if(can_go_left == 1'b1 && prev_direction != 3'b011) begin
                            next_countdown = countdown - 3'd1;
                            next_direction = 3'b001;
                            OrangeGhost_X_Motion_in = (~(OrangeGhost_X_Step) + 1'b1);
                            OrangeGhost_Y_Motion_in = 10'd0;
                        end
                        //is right visitable and we were not going right before
                        else if(can_go_right == 1'b1 && prev_direction != 3'b001) begin
                            next_countdown = countdown - 3'd1;
                            next_direction = 3'b011;
                            OrangeGhost_X_Motion_in = OrangeGhost_X_Step;
                            OrangeGhost_Y_Motion_in = 10'd0;
                        end
                        //is up visitable and we were not going down before
                        else if(can_go_up == 1'b1 && prev_direction != 3'b010) begin
                            next_countdown = countdown - 3'd1;
                            next_direction = 3'b000;
							OrangeGhost_X_Motion_in = 10'd0;
							OrangeGhost_Y_Motion_in = (~(OrangeGhost_Y_Step) + 1'b1);
                        end
                    end
                    3'b011: begin
                        //is right visitable and we were not going right before
                        if(can_go_right == 1'b1 && prev_direction != 3'b001) begin
                            next_countdown = countdown - 3'd1;
                            next_direction = 3'b011;
                            OrangeGhost_X_Motion_in = OrangeGhost_X_Step;
                            OrangeGhost_Y_Motion_in = 10'd0;
                        end
                        //is up visitable and we were not going down before
                        else if(can_go_up == 1'b1 && prev_direction != 3'b010) begin
                            next_countdown = countdown - 3'd1;
                            next_direction = 3'b000;
							OrangeGhost_X_Motion_in = 10'd0;
							OrangeGhost_Y_Motion_in = (~(OrangeGhost_Y_Step) + 1'b1);
                        end
                        //is down visitable and we were not going down before
                        else if(can_go_down == 1'b1 && prev_direction != 3'b000) begin
                            next_countdown = countdown - 3'd1;
                            next_direction = 3'b010;
                            OrangeGhost_X_Motion_in = 10'd0;
                            OrangeGhost_Y_Motion_in = OrangeGhost_Y_Step;
                        end
                        //is left visitable and we were not going left before
                        else if(can_go_left == 1'b1 && prev_direction != 3'b011) begin
                            next_countdown = countdown - 3'd1;
                            next_direction = 3'b001;
                            OrangeGhost_X_Motion_in = (~(OrangeGhost_X_Step) + 1'b1);
                            OrangeGhost_Y_Motion_in = 10'd0;
                        end
                    end
                endcase
            end
            if((OrangeGhost_Y_Pos >= OrangeGhost_Y_Max) || (OrangeGhost_Y_Pos <= OrangeGhost_Y_Min)) begin
                if(OrangeGhost_Y_Pos >= OrangeGhost_Y_Max)
                    OrangeGhost_Y_Pos_in = OrangeGhost_Y_Min + 10'd1 + OrangeGhost_Y_Motion_in;
                else
                    OrangeGhost_Y_Pos_in = OrangeGhost_Y_Max - 10'd1 + OrangeGhost_Y_Motion_in;
            end
            else if((OrangeGhost_X_Pos >= OrangeGhost_X_Max) || (OrangeGhost_X_Pos <= OrangeGhost_X_Min)) begin
                if(OrangeGhost_X_Pos >= OrangeGhost_X_Max) begin //going right
                    OrangeGhost_X_Pos_in = OrangeGhost_X_Min + 10'd1 + OrangeGhost_X_Motion_in;
                end
                else begin //going left
                    OrangeGhost_X_Pos_in = OrangeGhost_X_Max - 10'd1 + OrangeGhost_X_Motion_in;
                end
            end	              
            else begin
                OrangeGhost_X_Pos_in = OrangeGhost_X_Pos + OrangeGhost_X_Motion;
                OrangeGhost_Y_Pos_in = OrangeGhost_Y_Pos + OrangeGhost_Y_Motion;                
            end
        end
    end
    
	 //determine whether the DrawX and DrawY a OrangeGhostman coordinate 
    assign OrangeGhostX = DrawX - OrangeGhost_X_Pos + 10'd8;
    assign OrangeGhostY = DrawY - OrangeGhost_Y_Pos + 10'd8;    
    
    always_comb begin
        if (OrangeGhostX >= 10'd1 && OrangeGhostX < 10'd14 && OrangeGhostY >= 10'd1 && OrangeGhostY < 10'd14 && hold == 1'b0) 
            is_orange_ghost = 1'b1;
        else
            is_orange_ghost = 1'b0;
    end
endmodule 