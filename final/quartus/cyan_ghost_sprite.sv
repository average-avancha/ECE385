module cyan_ghost_sprite   (input          		Clk,                // 50 MHz clock
                                                Reset,              // Active-high reset signal
                                                frame_clk,          // The clock indicating a new frame (~60Hz)
                                                reload, hold,
                            input  		  [9:0] DrawX, DrawY, PacX, PacY,  // Current pixel coordinates
                            input         [2:0] direction_out,             //Pacman's current direction
                            input               is_cyan_killer,      
                            output logic  [9:0] CyanGhostX, CyanGhostY,	   // How deep into the sprite the current pixel is
                            output logic   		is_cyan_ghost,              // Whether current pixel belongs to Pac or background
                            output logic  [2:0] cyan_ghost_direction_out,
                            output logic  [6:0] cyan_ghost_animation_count,
                            output logic  [9:0] CyanGhostX_Monitor, CyanGhostY_Monitor);

    parameter [9:0] CyanGhost_X_Start = 10'd298 + CyanGhost_X_Min; //(X,Y) starting position of Cyan Ghost upon reset
    parameter [9:0] CyanGhost_Y_Start = 10'd157 + CyanGhost_Y_Min; 
    parameter [9:0] CyanGhost_X_Min = 10'd64;      // Leftmost point on the X axis
    parameter [9:0] CyanGhost_X_Max = 10'd576;     // Rightmost point on the X axis
    parameter [9:0] CyanGhost_Y_Min = 10'd48;      // Topmost point on the Y axis
    parameter [9:0] CyanGhost_Y_Max = 10'd432;     // Bottommost point on the Y axis
    parameter [9:0] CyanGhost_X_Step = 10'd1;      // Step size on the X axis
    parameter [9:0] CyanGhost_Y_Step = 10'd1;      // Step size on the Y axis
    
    logic [9:0] CyanGhost_X_Pos, CyanGhost_X_Motion, CyanGhost_Y_Pos, CyanGhost_Y_Motion;
    logic [9:0] CyanGhost_X_Pos_in, CyanGhost_X_Motion_in, CyanGhost_Y_Pos_in, CyanGhost_Y_Motion_in;
    logic [2:0] direction, next_direction, prev_direction, next_prev_direction, alignment_direction, next_alignment_direction;
    logic [6:0] animation, next_animation; //registers used for animation sprites
    logic [9:0]     CyanGhost_ui_x, CyanGhost_ui_y, //Inner Wall check for Cyan Ghost
                    CyanGhost_li_x, CyanGhost_li_y,
                    CyanGhost_di_x, CyanGhost_di_y,
                    CyanGhost_ri_x, CyanGhost_ri_y,

                    CyanGhost_lu_x, CyanGhost_lu_y, //Regular Wall Check
                    CyanGhost_l4_x, CyanGhost_l4_y,
                    CyanGhost_lc_x, CyanGhost_lc_y,
                    CyanGhost_l11_x, CyanGhost_l11_y,
                    CyanGhost_ld_x, CyanGhost_ld_y, 
                    CyanGhost_dl_x, CyanGhost_dl_y,
                    CyanGhost_d4_x, CyanGhost_d4_y,
                    CyanGhost_dc_x, CyanGhost_dc_y,
                    CyanGhost_d11_x, CyanGhost_d11_y,
                    CyanGhost_dr_x, CyanGhost_dr_y, 
                    CyanGhost_rd_x, CyanGhost_rd_y,
                    CyanGhost_r11_x, CyanGhost_r11_y, 
                    CyanGhost_rc_x, CyanGhost_rc_y, 
                    CyanGhost_r4_x, CyanGhost_r4_y, 
                    CyanGhost_ru_x, CyanGhost_ru_y, 
                    CyanGhost_ur_x, CyanGhost_ur_y,
                    CyanGhost_u11_x, CyanGhost_u11_y,
                    CyanGhost_uc_x, CyanGhost_uc_y,
                    CyanGhost_u4_x, CyanGhost_u4_y,
                    CyanGhost_ul_x, CyanGhost_ul_y;

    logic       ui_isWall, li_isWall, di_isWall, ri_isWall, //Inner Wall Check Output for Cyan Ghost
                lu_isWall, l4_isWall, lc_isWall, l11_isWall, ld_isWall, //Regular Wall Check 
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
            CyanGhost_X_Pos <= CyanGhost_X_Start;
            CyanGhost_Y_Pos <= CyanGhost_Y_Start;
            CyanGhost_X_Motion <= 10'd0;
            CyanGhost_Y_Motion <= 10'd0;
			direction <= 3'b111;
        end
        else if(hold) begin
			CyanGhost_X_Pos <= CyanGhost_X_Pos;
            CyanGhost_Y_Pos <= CyanGhost_Y_Pos;
            CyanGhost_X_Motion <= 10'd0;
            CyanGhost_Y_Motion <= 10'd0;
			direction <= 3'b111;
		end
        else begin
            CyanGhost_X_Pos <= CyanGhost_X_Pos_in;
            CyanGhost_Y_Pos <= CyanGhost_Y_Pos_in;
            CyanGhost_X_Motion <= CyanGhost_X_Motion_in;
            CyanGhost_Y_Motion <= CyanGhost_Y_Motion_in;
				direction <= next_direction;
        end
    end
	
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
		next_prev_direction = cyan_ghost_direction_out;
		if(cyan_ghost_direction_out == 3'b111)
			next_prev_direction = prev_direction;
	end
	
    //killer countdown
    logic [2:0] countdown, next_countdown;
	//delay a change in alignment
	always_ff @ (posedge Clk) begin
		if(Reset || reload)
			countdown <= 3'b011;
		else
			countdown <= next_countdown;
	end

    //random movement countdown
	logic [2:0] dumb_countdown, next_dumb_countdown;
	//delay a change in alignment
	always_ff @ (posedge Clk) begin
		if(Reset || reload)
			dumb_countdown <= 3'b111;
		else
			dumb_countdown <= next_dumb_countdown;
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
    wallChecker LU (.x(CyanGhost_lu_x), .y(CyanGhost_lu_y), .is_wall(lu_isWall));
    wallChecker L4 (.x(CyanGhost_l4_x), .y(CyanGhost_l4_y), .is_wall(l4_isWall));
    wallChecker LC (.x(CyanGhost_lc_x), .y(CyanGhost_lc_y), .is_wall(lc_isWall));
    wallChecker L11 (.x(CyanGhost_l11_x), .y(CyanGhost_l11_y), .is_wall(l11_isWall));
    wallChecker LD (.x(CyanGhost_ld_x), .y(CyanGhost_ld_y), .is_wall(ld_isWall));

    wallChecker DL (.x(CyanGhost_dl_x), .y(CyanGhost_dl_y), .is_wall(dl_isWall));
    wallChecker D4 (.x(CyanGhost_d4_x), .y(CyanGhost_d4_y), .is_wall(d4_isWall));
    wallChecker DC (.x(CyanGhost_dc_x), .y(CyanGhost_dc_y), .is_wall(dc_isWall));
    wallChecker D11 (.x(CyanGhost_d11_x), .y(CyanGhost_d11_y), .is_wall(d11_isWall));    
    wallChecker DR (.x(CyanGhost_dr_x), .y(CyanGhost_dr_y), .is_wall(dr_isWall));

    wallChecker RD (.x(CyanGhost_rd_x), .y(CyanGhost_rd_y), .is_wall(rd_isWall));
    wallChecker R11 (.x(CyanGhost_r11_x), .y(CyanGhost_r11_y), .is_wall(r11_isWall));
    wallChecker RC (.x(CyanGhost_rc_x), .y(CyanGhost_rc_y), .is_wall(rc_isWall));
    wallChecker R4 (.x(CyanGhost_r4_x), .y(CyanGhost_r4_y), .is_wall(r4_isWall));
    wallChecker RU (.x(CyanGhost_ru_x), .y(CyanGhost_ru_y), .is_wall(ru_isWall));

    wallChecker UR (.x(CyanGhost_ur_x), .y(CyanGhost_ur_y), .is_wall(ur_isWall));
    wallChecker U11 (.x(CyanGhost_u11_x), .y(CyanGhost_u11_y), .is_wall(u11_isWall));
    wallChecker UC (.x(CyanGhost_uc_x), .y(CyanGhost_uc_y), .is_wall(uc_isWall));
    wallChecker U4 (.x(CyanGhost_u4_x), .y(CyanGhost_u4_y), .is_wall(u4_isWall));
    wallChecker UL (.x(CyanGhost_ul_x), .y(CyanGhost_ul_y), .is_wall(ul_isWall));
    
    innerwallChecker UI (.x(CyanGhost_ui_x), .y(CyanGhost_ui_y), .is_killer(is_cyan_killer), .is_inner_wall(ui_isWall));
    innerwallChecker LI (.x(CyanGhost_li_x), .y(CyanGhost_li_y), .is_killer(is_cyan_killer), .is_inner_wall(li_isWall));
    innerwallChecker DI (.x(CyanGhost_di_x), .y(CyanGhost_di_y), .is_killer(is_cyan_killer), .is_inner_wall(di_isWall));
    innerwallChecker RI (.x(CyanGhost_ri_x), .y(CyanGhost_ri_y), .is_killer(is_cyan_killer), .is_inner_wall(ri_isWall));

	assign CyanGhostX_Monitor = CyanGhost_X_Pos;
	assign CyanGhostY_Monitor = CyanGhost_Y_Pos;
	 //animation register combinational logic
	assign cyan_ghost_direction_out = direction;
	assign cyan_ghost_animation_count = animation;
	
    logic [9:0] U_X, U_Y, L_X, L_Y, R_X, R_Y, D_X, D_Y, C_X, C_Y; //blocks in relation to a ghost sprite used in minimizing path distance
	int U_DistX, U_DistY, L_DistX, L_DistY, D_DistX, D_DistY, R_DistX, R_DistY, C_DistX, C_DistY, U_Dist, L_Dist, D_Dist, R_Dist, C_Dist; 
	int PacCenterX, PacCenterY, CyanGhostCenterX, CyanGhostCenterY;
	
    //Killer Always Comb
	always_comb begin
	 //position re-assignment from logic to int
		PacCenterX = PacX;
		PacCenterY = PacY;
		CyanGhostCenterX = CyanGhost_X_Pos;
		CyanGhostCenterY = CyanGhost_Y_Pos;
		
		U_X = CyanGhost_X_Pos;
		U_Y = CyanGhost_Y_Pos - 10'd1;
		
		L_X = CyanGhost_X_Pos - 10'd1;
		L_Y = CyanGhost_Y_Pos; 
		
		D_X = CyanGhost_X_Pos; 
		D_Y = CyanGhost_Y_Pos + 10'd1;
		
		R_X = CyanGhost_X_Pos + 10'd1;
		R_Y = CyanGhost_Y_Pos;
		
		C_X = CyanGhost_X_Pos;
		C_Y = CyanGhost_Y_Pos;
		
		U_DistX = PacX - U_X;
		U_DistY = PacY - U_Y;

		L_DistX = PacX - L_X;
		L_DistY = PacY - L_Y;
		
		D_DistX = PacX - D_X;
		D_DistY = PacY - D_Y;

		R_DistX = PacX - R_X;
		R_DistY = PacY - R_Y;
		
		C_DistX = PacX - C_X;
		C_DistY = PacY - C_Y;
		
		U_Dist = (U_DistX*U_DistX) + (U_DistY*U_DistY);
		L_Dist = (L_DistX*L_DistX) + (L_DistY*L_DistY);
		D_Dist = (D_DistX*D_DistX) + (D_DistY*D_DistY);
		R_Dist = (R_DistX*R_DistX) + (R_DistY*R_DistY);
		C_Dist = (C_DistX*C_DistX) + (C_DistY*C_DistY);		 
	end

    logic can_go_up, can_go_left, can_go_down, can_go_right;
    always_comb begin
        can_go_up    = ul_isWall == 1'b0 && u4_isWall == 1'b0 && uc_isWall == 1'b0 && u11_isWall == 1'b0 && ur_isWall == 1'b0 && ui_isWall == 1'b0;
        can_go_left  = lu_isWall == 1'b0 && l4_isWall == 1'b0 && lc_isWall == 1'b0 && l11_isWall == 1'b0 && ld_isWall == 1'b0 && li_isWall == 1'b0;
        can_go_down  = dl_isWall == 1'b0 && d4_isWall == 1'b0 && dc_isWall == 1'b0 && d11_isWall == 1'b0 && dr_isWall == 1'b0 && di_isWall == 1'b0;
        can_go_right = ru_isWall == 1'b0 && r4_isWall == 1'b0 && rc_isWall == 1'b0 && r11_isWall == 1'b0 && rd_isWall == 1'b0 && ri_isWall == 1'b0;
    end

	always_comb begin
        //by default, position/motion of CyanGhostman remains unchanged, but CyanGhostman is always being animated (except for when he colides or is still
        CyanGhost_X_Pos_in = CyanGhost_X_Pos;
        CyanGhost_Y_Pos_in = CyanGhost_Y_Pos;
        CyanGhost_X_Motion_in = CyanGhost_X_Motion;
        CyanGhost_Y_Motion_in = CyanGhost_Y_Motion;
        next_direction = direction;
        next_animation = animation;
		next_alignment_direction = alignment_direction;
		next_flag = flag;
		next_dumb_countdown = dumb_countdown;
        next_timer = timer;
		next_deciding = deciding;
		next_countdown = countdown;
        if(is_cyan_killer == 1'b0) begin
            //update boundary checking pixel coordinates of the CyanGhostman sprite 
            CyanGhost_ui_x = CyanGhost_X_Pos  + 10'd0 - 10'd64;
            CyanGhost_ui_y = CyanGhost_Y_Pos  + 10'd0 - 10'd9 - 10'd48 - 10'd1;
            CyanGhost_ri_x = CyanGhost_X_Pos  - 10'd0 + 10'd8 - 10'd64 + 10'd1;
            CyanGhost_ri_y = CyanGhost_Y_Pos  + 10'd0 - 10'd48;
            CyanGhost_di_x = CyanGhost_X_Pos  + 10'd0 - 10'd64;
            CyanGhost_di_y = CyanGhost_Y_Pos  - 10'd0 + 10'd8 - 10'd48 + 10'd1;
            CyanGhost_li_x = CyanGhost_X_Pos  + 10'd0 - 10'd9 - 10'd64 - 10'd1;
            CyanGhost_li_y = CyanGhost_Y_Pos  + 10'd0 - 10'd48;
            
            CyanGhost_ul_x = CyanGhost_X_Pos  + 10'd0 - 10'd8 - 10'd64;
            CyanGhost_ul_y = CyanGhost_Y_Pos  + 10'd0 - 10'd9 - 10'd48 - 10'd1;
            CyanGhost_u4_x = CyanGhost_X_Pos  + 10'd0 - 10'd4 - 10'd64;
            CyanGhost_u4_y = CyanGhost_Y_Pos  + 10'd0 - 10'd9 - 10'd48 - 10'd1;
            CyanGhost_uc_x = CyanGhost_X_Pos  + 10'd0 - 10'd64;
            CyanGhost_uc_y = CyanGhost_Y_Pos  + 10'd0 - 10'd9 - 10'd48 - 10'd1;
            CyanGhost_u11_x = CyanGhost_X_Pos - 10'd0 + 10'd3 - 10'd64;
            CyanGhost_u11_y = CyanGhost_Y_Pos + 10'd0 - 10'd9 - 10'd48 - 10'd1;
            CyanGhost_ur_x = CyanGhost_X_Pos  - 10'd0 + 10'd7 - 10'd64;
            CyanGhost_ur_y = CyanGhost_Y_Pos  + 10'd0 - 10'd9 - 10'd48 - 10'd1;

            CyanGhost_ru_x = CyanGhost_X_Pos  - 10'd0 + 10'd8 - 10'd64 + 10'd1;
            CyanGhost_ru_y = CyanGhost_Y_Pos  + 10'd0 - 10'd8 - 10'd48;
            CyanGhost_r4_x = CyanGhost_X_Pos  - 10'd0 + 10'd8 - 10'd64 + 10'd1;
            CyanGhost_r4_y = CyanGhost_Y_Pos  + 10'd0 - 10'd4 - 10'd48;
            CyanGhost_rc_x = CyanGhost_X_Pos  - 10'd0 + 10'd8 - 10'd64 + 10'd1;
            CyanGhost_rc_y = CyanGhost_Y_Pos  + 10'd0 - 10'd48;
            CyanGhost_r11_x = CyanGhost_X_Pos - 10'd0 + 10'd8 - 10'd64 + 10'd1;
            CyanGhost_r11_y = CyanGhost_Y_Pos - 10'd0 + 10'd3 - 10'd48;
            CyanGhost_rd_x = CyanGhost_X_Pos  - 10'd0 + 10'd8 - 10'd64 + 10'd1;
            CyanGhost_rd_y = CyanGhost_Y_Pos  - 10'd0 + 10'd7 - 10'd48;

            CyanGhost_dr_x = CyanGhost_X_Pos  - 10'd0 + 10'd7 - 10'd64;
            CyanGhost_dr_y = CyanGhost_Y_Pos  - 10'd0 + 10'd8 - 10'd48 + 10'd1;
            CyanGhost_d11_x = CyanGhost_X_Pos - 10'd0 + 10'd3 - 10'd64;
            CyanGhost_d11_y = CyanGhost_Y_Pos - 10'd0 + 10'd8 - 10'd48 + 10'd1;
            CyanGhost_dc_x = CyanGhost_X_Pos  + 10'd0 - 10'd64;
            CyanGhost_dc_y = CyanGhost_Y_Pos  - 10'd0 + 10'd8 - 10'd48 + 10'd1;
            CyanGhost_d4_x = CyanGhost_X_Pos  + 10'd0 - 10'd4 - 10'd64;
            CyanGhost_d4_y = CyanGhost_Y_Pos  - 10'd0 + 10'd8 - 10'd48 + 10'd1;
            CyanGhost_dl_x = CyanGhost_X_Pos  + 10'd0 - 10'd8 - 10'd64;
            CyanGhost_dl_y = CyanGhost_Y_Pos  - 10'd0 + 10'd8 - 10'd48 + 10'd1;

            CyanGhost_ld_x = CyanGhost_X_Pos  + 10'd0 - 10'd9 - 10'd64 - 10'd1;
            CyanGhost_ld_y = CyanGhost_Y_Pos  - 10'd0 + 10'd7 - 10'd48;
            CyanGhost_l11_x = CyanGhost_X_Pos + 10'd0 - 10'd9 - 10'd64 - 10'd1;
            CyanGhost_l11_y = CyanGhost_Y_Pos - 10'd0 + 10'd3 - 10'd48;
            CyanGhost_lc_x = CyanGhost_X_Pos  + 10'd0 - 10'd9 - 10'd64 - 10'd1;
            CyanGhost_lc_y = CyanGhost_Y_Pos  + 10'd0 - 10'd48;
            CyanGhost_l4_x = CyanGhost_X_Pos  + 10'd0 - 10'd9 - 10'd64 - 10'd1;
            CyanGhost_l4_y = CyanGhost_Y_Pos  + 10'd0 - 10'd4 - 10'd48;
            CyanGhost_lu_x = CyanGhost_X_Pos  + 10'd0 - 10'd9 - 10'd64 - 10'd1; // (Center_coord - sprite_wall_check_offset - gradient_border_offset - 2pixel's_ahead_offset)
            CyanGhost_lu_y = CyanGhost_Y_Pos  + 10'd0 - 10'd8 - 10'd48;
        end
        else begin
                //update boundary checking pixel coordinates of the CyanGhostman sprite 
            CyanGhost_ui_x = CyanGhost_X_Pos  + 10'd0 - 10'd64;
            CyanGhost_ui_y = CyanGhost_Y_Pos  + 10'd0 - 10'd9 - 10'd48 - 10'd1;
            CyanGhost_ri_x = CyanGhost_X_Pos  - 10'd0 + 10'd8 - 10'd64 + 10'd1;
            CyanGhost_ri_y = CyanGhost_Y_Pos  + 10'd0 - 10'd48;
            CyanGhost_di_x = CyanGhost_X_Pos  + 10'd0 - 10'd64;
            CyanGhost_di_y = CyanGhost_Y_Pos  - 10'd0 + 10'd8 - 10'd48 + 10'd1;
            CyanGhost_li_x = CyanGhost_X_Pos  + 10'd0 - 10'd9 - 10'd64 - 10'd1;
            CyanGhost_li_y = CyanGhost_Y_Pos  + 10'd0 - 10'd48;
            
            CyanGhost_ul_x = CyanGhost_X_Pos  + 10'd1 - 10'd8 - 10'd64;
            CyanGhost_ul_y = CyanGhost_Y_Pos  + 10'd1 - 10'd9 - 10'd48 - 10'd1;
            CyanGhost_u4_x = CyanGhost_X_Pos  + 10'd1 - 10'd4 - 10'd64;
            CyanGhost_u4_y = CyanGhost_Y_Pos  + 10'd1 - 10'd9 - 10'd48 - 10'd1;
            CyanGhost_uc_x = CyanGhost_X_Pos  + 10'd0 - 10'd64;
            CyanGhost_uc_y = CyanGhost_Y_Pos  + 10'd1 - 10'd9 - 10'd48 - 10'd1;
            CyanGhost_u11_x = CyanGhost_X_Pos - 10'd1 + 10'd3 - 10'd64;
            CyanGhost_u11_y = CyanGhost_Y_Pos + 10'd1 - 10'd9 - 10'd48 - 10'd1;
            CyanGhost_ur_x = CyanGhost_X_Pos  - 10'd1 + 10'd7 - 10'd64;
            CyanGhost_ur_y = CyanGhost_Y_Pos  + 10'd1 - 10'd9 - 10'd48 - 10'd1;

            CyanGhost_ru_x = CyanGhost_X_Pos  - 10'd1 + 10'd8 - 10'd64 + 10'd1;
            CyanGhost_ru_y = CyanGhost_Y_Pos  + 10'd1 - 10'd8 - 10'd48;
            CyanGhost_r4_x = CyanGhost_X_Pos  - 10'd1 + 10'd8 - 10'd64 + 10'd1;
            CyanGhost_r4_y = CyanGhost_Y_Pos  + 10'd1 - 10'd4 - 10'd48;
            CyanGhost_rc_x = CyanGhost_X_Pos  - 10'd1 + 10'd8 - 10'd64 + 10'd1;
            CyanGhost_rc_y = CyanGhost_Y_Pos  + 10'd0 - 10'd48;
            CyanGhost_r11_x = CyanGhost_X_Pos - 10'd1 + 10'd8 - 10'd64 + 10'd1;
            CyanGhost_r11_y = CyanGhost_Y_Pos - 10'd1 + 10'd3 - 10'd48;
            CyanGhost_rd_x = CyanGhost_X_Pos  - 10'd1 + 10'd8 - 10'd64 + 10'd1;
            CyanGhost_rd_y = CyanGhost_Y_Pos  - 10'd1 + 10'd7 - 10'd48;

            CyanGhost_dr_x = CyanGhost_X_Pos  - 10'd1 + 10'd7 - 10'd64;
            CyanGhost_dr_y = CyanGhost_Y_Pos  - 10'd1 + 10'd8 - 10'd48 + 10'd1;
            CyanGhost_d11_x = CyanGhost_X_Pos - 10'd1 + 10'd3 - 10'd64;
            CyanGhost_d11_y = CyanGhost_Y_Pos - 10'd1 + 10'd8 - 10'd48 + 10'd1;
            CyanGhost_dc_x = CyanGhost_X_Pos  + 10'd0 - 10'd64;
            CyanGhost_dc_y = CyanGhost_Y_Pos  - 10'd1 + 10'd8 - 10'd48 + 10'd1;
            CyanGhost_d4_x = CyanGhost_X_Pos  + 10'd1 - 10'd4 - 10'd64;
            CyanGhost_d4_y = CyanGhost_Y_Pos  - 10'd1 + 10'd8 - 10'd48 + 10'd1;
            CyanGhost_dl_x = CyanGhost_X_Pos  + 10'd1 - 10'd8 - 10'd64;
            CyanGhost_dl_y = CyanGhost_Y_Pos  - 10'd1 + 10'd8 - 10'd48 + 10'd1;

            CyanGhost_ld_x = CyanGhost_X_Pos  + 10'd1 - 10'd9 - 10'd64 - 10'd1;
            CyanGhost_ld_y = CyanGhost_Y_Pos  - 10'd1 + 10'd7 - 10'd48;
            CyanGhost_l11_x = CyanGhost_X_Pos + 10'd1 - 10'd9 - 10'd64 - 10'd1;
            CyanGhost_l11_y = CyanGhost_Y_Pos - 10'd1 + 10'd3 - 10'd48;
            CyanGhost_lc_x = CyanGhost_X_Pos  + 10'd1 - 10'd9 - 10'd64 - 10'd1;
            CyanGhost_lc_y = CyanGhost_Y_Pos  + 10'd0 - 10'd48;
            CyanGhost_l4_x = CyanGhost_X_Pos  + 10'd1 - 10'd9 - 10'd64 - 10'd1;
            CyanGhost_l4_y = CyanGhost_Y_Pos  + 10'd1 - 10'd4 - 10'd48;
            CyanGhost_lu_x = CyanGhost_X_Pos  + 10'd1 - 10'd9 - 10'd64 - 10'd1; // (Center_coord - sprite_wall_check_offset - gradient_border_offset - 2pixel's_ahead_offset)
            CyanGhost_lu_y = CyanGhost_Y_Pos  + 10'd1 - 10'd8 - 10'd48;
        end
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
                if(ul_isWall == 1'b1 || u4_isWall == 1'b1 || uc_isWall == 1'b1 || u11_isWall == 1'b1 || ur_isWall == 1'b1 || ui_isWall == 1'b1) begin
                    CyanGhost_X_Motion_in = 10'd0;
                    CyanGhost_Y_Motion_in = 10'd0;
                    next_direction = 3'b111;
						next_animation = animation;
                end
            end
            else if (direction == 3'b001) begin
                if(lu_isWall == 1'b1 || l4_isWall == 1'b1 || lc_isWall == 1'b1 || l11_isWall == 1'b1 || ld_isWall == 1'b1 || li_isWall == 1'b1) begin
                    CyanGhost_X_Motion_in = 10'd0;
                    CyanGhost_Y_Motion_in = 10'd0;
                    next_direction = 3'b111;
						next_animation = animation;						  
                end
            end
            else if (direction == 3'b010) begin
                if(dl_isWall == 1'b1 || d4_isWall == 1'b1 || dc_isWall == 1'b1 || d11_isWall == 1'b1 || dr_isWall == 1'b1 || di_isWall == 1'b1) begin
                    CyanGhost_X_Motion_in = 10'd0;
                    CyanGhost_Y_Motion_in = 10'd0;
                    next_direction = 3'b111;
					next_animation = animation;						  
                end            
            end
            else if (direction == 3'b011) begin
                if(ru_isWall == 1'b1 || r4_isWall == 1'b1 || rc_isWall == 1'b1 || r11_isWall == 1'b1 || rd_isWall == 1'b1 || ri_isWall == 1'b1) begin
                    CyanGhost_X_Motion_in = 10'd0;
                    CyanGhost_Y_Motion_in = 10'd0;
                    next_direction = 3'b111;
					next_animation = animation;						  
                end           
            end
//////////////////////////////////////////////////// RANDOM MOVEMENT //////////////////////////////////////////////////////////////////
            if(is_cyan_killer == 1'b0) begin
                if(dumb_countdown == 3'b000) begin
                    next_dumb_countdown = 3'b111; 
                    next_deciding = 1'b0; 
                end
                else if(dumb_countdown != 3'b111) 
                    next_dumb_countdown = dumb_countdown - 3'd1;
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
                if(deciding == 1'b1 && dumb_countdown == 3'b111) begin
                    case(timer)
                        3'b000: begin
                            //is up visitable and we were not going down before
                            if(can_go_up == 1'b1 && prev_direction != 3'b010) begin
                                next_dumb_countdown = dumb_countdown - 3'd1;
                                next_direction = 3'b000;
                                CyanGhost_X_Motion_in = 10'd0;
                                CyanGhost_Y_Motion_in = (~(CyanGhost_Y_Step) + 1'b1);
                            end
                            //is left visitable and we were not going left before
                            else if(can_go_left == 1'b1 && prev_direction != 3'b011) begin
                                next_dumb_countdown = dumb_countdown - 3'd1;
                                next_direction = 3'b001;
                                CyanGhost_X_Motion_in = (~(CyanGhost_X_Step) + 1'b1);
                                CyanGhost_Y_Motion_in = 10'd0;
                            end
                            //is down visitable and we were not going down before
                            else if(can_go_down == 1'b1 && prev_direction != 3'b000) begin
                                next_dumb_countdown = dumb_countdown - 3'd1;
                                next_direction = 3'b010;
                                CyanGhost_X_Motion_in = 10'd0;
                                CyanGhost_Y_Motion_in = CyanGhost_Y_Step;
                            end
                            //is right visitable and we were not going right before
                            else if(can_go_right == 1'b1 && prev_direction != 3'b001) begin
                                next_dumb_countdown = dumb_countdown - 3'd1;
                                next_direction = 3'b011;
                                CyanGhost_X_Motion_in = CyanGhost_X_Step;
                                CyanGhost_Y_Motion_in = 10'd0;
                            end
                        end
                        3'b001: begin
                            //is left visitable and we were not going left before
                            if(can_go_left == 1'b1 && prev_direction != 3'b011) begin
                                next_dumb_countdown = dumb_countdown - 3'd1;
                                next_direction = 3'b001;
                                CyanGhost_X_Motion_in = (~(CyanGhost_X_Step) + 1'b1);
                                CyanGhost_Y_Motion_in = 10'd0;
                            end
                            //is down visitable and we were not going down before
                            else if(can_go_down == 1'b1 && prev_direction != 3'b000) begin
                                next_dumb_countdown = dumb_countdown - 3'd1;
                                next_direction = 3'b010;
                                CyanGhost_X_Motion_in = 10'd0;
                                CyanGhost_Y_Motion_in = CyanGhost_Y_Step;
                            end
                            //is up visitable and we were not going down before
                            else if(can_go_up == 1'b1 && prev_direction != 3'b010) begin
                                next_dumb_countdown = dumb_countdown - 3'd1;
                                next_direction = 3'b000;
                                CyanGhost_X_Motion_in = 10'd0;
                                CyanGhost_Y_Motion_in = (~(CyanGhost_Y_Step) + 1'b1);
                            end
                            //is right visitable and we were not going right before
                            else if(can_go_right == 1'b1 && prev_direction != 3'b001) begin
                                next_dumb_countdown = dumb_countdown - 3'd1;
                                next_direction = 3'b011;
                                CyanGhost_X_Motion_in = CyanGhost_X_Step;
                                CyanGhost_Y_Motion_in = 10'd0;
                            end
                        end
                        3'b010: begin
                            //is down visitable and we were not going down before
                            if(can_go_down == 1'b1 && prev_direction != 3'b000) begin
                                next_dumb_countdown = dumb_countdown - 3'd1;
                                next_direction = 3'b010;
                                CyanGhost_X_Motion_in = 10'd0;
                                CyanGhost_Y_Motion_in = CyanGhost_Y_Step;
                            end
                            //is left visitable and we were not going left before
                            else if(can_go_left == 1'b1 && prev_direction != 3'b011) begin
                                next_dumb_countdown = dumb_countdown - 3'd1;
                                next_direction = 3'b001;
                                CyanGhost_X_Motion_in = (~(CyanGhost_X_Step) + 1'b1);
                                CyanGhost_Y_Motion_in = 10'd0;
                            end
                            //is right visitable and we were not going right before
                            else if(can_go_right == 1'b1 && prev_direction != 3'b001) begin
                                next_dumb_countdown = dumb_countdown - 3'd1;
                                next_direction = 3'b011;
                                CyanGhost_X_Motion_in = CyanGhost_X_Step;
                                CyanGhost_Y_Motion_in = 10'd0;
                            end
                            //is up visitable and we were not going down before
                            else if(can_go_up == 1'b1 && prev_direction != 3'b010) begin
                                next_dumb_countdown = dumb_countdown - 3'd1;
                                next_direction = 3'b000;
                                CyanGhost_X_Motion_in = 10'd0;
                                CyanGhost_Y_Motion_in = (~(CyanGhost_Y_Step) + 1'b1);
                            end
                        end
                        3'b011: begin
                            //is right visitable and we were not going right before
                            if(can_go_right == 1'b1 && prev_direction != 3'b001) begin
                                next_dumb_countdown = dumb_countdown - 3'd1;
                                next_direction = 3'b011;
                                CyanGhost_X_Motion_in = CyanGhost_X_Step;
                                CyanGhost_Y_Motion_in = 10'd0;
                            end
                            //is up visitable and we were not going down before
                            else if(can_go_up == 1'b1 && prev_direction != 3'b010) begin
                                next_dumb_countdown = dumb_countdown - 3'd1;
                                next_direction = 3'b000;
                                CyanGhost_X_Motion_in = 10'd0;
                                CyanGhost_Y_Motion_in = (~(CyanGhost_Y_Step) + 1'b1);
                            end
                            //is down visitable and we were not going down before
                            else if(can_go_down == 1'b1 && prev_direction != 3'b000) begin
                                next_dumb_countdown = dumb_countdown - 3'd1;
                                next_direction = 3'b010;
                                CyanGhost_X_Motion_in = 10'd0;
                                CyanGhost_Y_Motion_in = CyanGhost_Y_Step;
                            end
                            //is left visitable and we were not going left before
                            else if(can_go_left == 1'b1 && prev_direction != 3'b011) begin
                                next_dumb_countdown = dumb_countdown - 3'd1;
                                next_direction = 3'b001;
                                CyanGhost_X_Motion_in = (~(CyanGhost_X_Step) + 1'b1);
                                CyanGhost_Y_Motion_in = 10'd0;
                            end
                        end
                    endcase
                end
            end
            ////////////////////////////////////////////////////KILLER PATHFINDING-ISH //////////////////////////////////////////////////////////////////
            else begin
                if(countdown == 3'b000) begin
                    next_countdown = 3'b011; 
                    next_alignment_direction = 3'b111; 
                end
                if (alignment_direction != 3'b111) begin
                    case(alignment_direction)
                        3'b000: begin
                            //previously aligned and wanted to go up, so when the next available up movement is allowed, go up
                            if(ul_isWall == 1'b0 && u4_isWall == 1'b0 && uc_isWall == 1'b0 && u11_isWall == 1'b0 && ur_isWall == 1'b0) begin
                                //next_alignment_direction = 3'b111;
                                next_countdown = countdown - 3'd1; 
                                next_direction = 3'b000;
                                CyanGhost_X_Motion_in = 10'd0;
                                CyanGhost_Y_Motion_in = (~(CyanGhost_Y_Step) + 1'b1);
                            end
                            //can't move up
                            else begin
                                //try to move left
                                if(lu_isWall == 1'b0 && l4_isWall == 1'b0 && lc_isWall == 1'b0 && l11_isWall == 1'b0 && ld_isWall == 1'b0) begin
                                    next_direction = 3'b001;
                                    CyanGhost_X_Motion_in = (~(CyanGhost_X_Step) + 1'b1);
                                    CyanGhost_Y_Motion_in = 10'd0;
                                end
                                //can't move left --> check right
                                else if(ru_isWall == 1'b0 && r4_isWall == 1'b0 && rc_isWall == 1'b0 && r11_isWall == 1'b0 && rd_isWall == 1'b0) begin
                                    next_direction = 3'b011;
                                    CyanGhost_X_Motion_in = CyanGhost_X_Step;
                                    CyanGhost_Y_Motion_in = 10'd0;
                                end
                            end
                        end
                        3'b001: begin
                            //previously aligned and wanted to go left, so when the next available left movement is allowed, go left
                            if(lu_isWall == 1'b0 && l4_isWall == 1'b0 && lc_isWall == 1'b0 && l11_isWall == 1'b0 && ld_isWall == 1'b0) begin
                                //next_alignment_direction = 3'b111;
                                next_countdown = countdown - 3'd1; 							
                                next_direction = 3'b001;
                                CyanGhost_X_Motion_in = (~(CyanGhost_X_Step) + 1'b1);
                                CyanGhost_Y_Motion_in = 10'd0;
                            end
                            //can't move left
                            else begin
                                //try to move up
                                if(ul_isWall == 1'b0 && u4_isWall == 1'b0 && uc_isWall == 1'b0 && u11_isWall == 1'b0 && ur_isWall == 1'b0) begin
                                    next_direction = 3'b000;
                                    CyanGhost_X_Motion_in = 10'd0;
                                    CyanGhost_Y_Motion_in = (~(CyanGhost_Y_Step) + 1'b1);
                                end
                                //can't move up --> check down
                                else if(dl_isWall == 1'b0 && d4_isWall == 1'b0 && dc_isWall == 1'b0 && d11_isWall == 1'b0 && dr_isWall == 1'b0) begin
                                    next_direction = 3'b010;
                                    CyanGhost_X_Motion_in = 10'd0;
                                    CyanGhost_Y_Motion_in = CyanGhost_Y_Step;
                                end
                            end
                        end
                        3'b010: begin
                            //previously aligned and wanted to go down, so when the next available down movement is allowed, go down
                            if(dl_isWall == 1'b0 && d4_isWall == 1'b0 && dc_isWall == 1'b0 && d11_isWall == 1'b0 && dr_isWall == 1'b0) begin
                                //next_alignment_direction = 3'b111;
                                next_countdown = countdown - 3'd1; 							
                                next_direction = 3'b010;
                                CyanGhost_X_Motion_in = 10'd0;
                                CyanGhost_Y_Motion_in = CyanGhost_Y_Step;
                            end
                            //can't move down
                            else begin
                                //try to move right
                                if(ru_isWall == 1'b0 && r4_isWall == 1'b0 && rc_isWall == 1'b0 && r11_isWall == 1'b0 && rd_isWall == 1'b0) begin
                                    next_direction = 3'b011;
                                    CyanGhost_X_Motion_in = CyanGhost_X_Step;
                                    CyanGhost_Y_Motion_in = 10'd0;
                                end
                                //can't move right --> check left
                                else if(lu_isWall == 1'b0 && l4_isWall == 1'b0 && lc_isWall == 1'b0 && l11_isWall == 1'b0 && ld_isWall == 1'b0) begin
                                    next_direction = 3'b001;
                                    CyanGhost_X_Motion_in = (~(CyanGhost_X_Step) + 1'b1);
                                    CyanGhost_Y_Motion_in = 10'd0;
                                end
                            end
                        end
                        3'b011: begin
                            //previously aligned and wanted to go right, so when the next available right movement is allowed, go right
                            if(ru_isWall == 1'b0 && r4_isWall == 1'b0 && rc_isWall == 1'b0 && r11_isWall == 1'b0 && rd_isWall == 1'b0) begin
                                //next_alignment_direction = 3'b111;
                                next_countdown = countdown - 3'd1; 							
                                next_direction = 3'b011;
                                CyanGhost_X_Motion_in = CyanGhost_X_Step;
                                CyanGhost_Y_Motion_in = 10'd0;
                            end
                            //can't move right
                            else begin
                                //try to move down
                                if(dl_isWall == 1'b0 && d4_isWall == 1'b0 && dc_isWall == 1'b0 && d11_isWall == 1'b0 && dr_isWall == 1'b0) begin
                                    next_direction = 3'b010;
                                    CyanGhost_X_Motion_in = 10'd0;
                                    CyanGhost_Y_Motion_in = CyanGhost_Y_Step;
                                end
                                //can't move down --> check up
                                else if(ul_isWall == 1'b0 && u4_isWall == 1'b0 && uc_isWall == 1'b0 && u11_isWall == 1'b0 && ur_isWall == 1'b0) begin
                                    next_direction = 3'b000;
                                    CyanGhost_X_Motion_in = 10'd0;
                                    CyanGhost_Y_Motion_in = (~(CyanGhost_Y_Step) + 1'b1);
                                end
                            end
                        end
                        default: ;
                    endcase
                end
                else begin
                    if(C_Dist < 16) begin
                        next_direction = 3'b111;
                        CyanGhost_X_Motion_in = 10'd0;
                        CyanGhost_Y_Motion_in = 10'd0;
                    end
                    else if((PacCenterY - CyanGhostCenterY <= 1) && (PacCenterY - CyanGhostCenterY >= -1)) begin
                        //Check Horizonal Movement -> left is ideal?
                        if(L_Dist < R_Dist) begin
                            //check left
                            if(lu_isWall == 1'b0 && l4_isWall == 1'b0 && lc_isWall == 1'b0 && l11_isWall == 1'b0 && ld_isWall == 1'b0) begin
                                next_direction = 3'b001;
                                CyanGhost_X_Motion_in = (~(CyanGhost_X_Step) + 1'b1);
                                CyanGhost_Y_Motion_in = 10'd0;
                            end
                            //cant move left -> check right
                            else if(ru_isWall == 1'b0 && r4_isWall == 1'b0 && rc_isWall == 1'b0 && r11_isWall == 1'b0 && rd_isWall == 1'b0) begin
                                next_direction = 3'b011;
                                CyanGhost_X_Motion_in = CyanGhost_X_Step;
                                CyanGhost_Y_Motion_in = 10'd0;
                                //set flag = left
                                next_alignment_direction = 3'b001;
                            end
                            else begin
                                //set flag = left
                                next_alignment_direction = 3'b001;
                            end
                        end
                        //right is ideal
                        else begin
                            if(ru_isWall == 1'b0 && r4_isWall == 1'b0 && rc_isWall == 1'b0 && r11_isWall == 1'b0 && rd_isWall == 1'b0) begin
                                next_direction = 3'b011;
                                CyanGhost_X_Motion_in = CyanGhost_X_Step;
                                CyanGhost_Y_Motion_in = 10'd0;
                            end
                            else if(lu_isWall == 1'b0 && l4_isWall == 1'b0 && lc_isWall == 1'b0 && l11_isWall == 1'b0 && ld_isWall == 1'b0) begin
                                next_direction = 3'b001;
                                CyanGhost_X_Motion_in = (~(CyanGhost_X_Step) + 1'b1);
                                CyanGhost_Y_Motion_in = 10'd0;
                                //set flag = right
                                next_alignment_direction = 3'b011;
                            end
                            else begin
                                //set flag = right
                                next_alignment_direction = 3'b011;
                            end
                        end
                    end
                    else if((PacCenterX - CyanGhostCenterX <= 1) && (PacCenterX - CyanGhostCenterX >= -1)) begin
                        //Check Vertical Movement --> check if up is ideal
                        if(U_Dist < D_Dist) begin
                            //check up
                            if(ul_isWall == 1'b0 && u4_isWall == 1'b0 && uc_isWall == 1'b0 && u11_isWall == 1'b0 && ur_isWall == 1'b0) begin
                                next_direction = 3'b000;
                                CyanGhost_X_Motion_in = 10'd0;
                                CyanGhost_Y_Motion_in = (~(CyanGhost_Y_Step) + 1'b1);
                            end
                            //can't go up so check down
                            else if(dl_isWall == 1'b0 && d4_isWall == 1'b0 && dc_isWall == 1'b0 && d11_isWall == 1'b0 && dr_isWall == 1'b0) begin
                                next_direction = 3'b010;
                                CyanGhost_X_Motion_in = 10'd0;
                                CyanGhost_Y_Motion_in = CyanGhost_Y_Step;
                                //set flag = up
                                next_alignment_direction = 3'b000;
                            end
                            else begin
                                //set flag = up
                                next_alignment_direction = 3'b000;
                            end
                        end
                        //down is ideal
                        else begin
                            //check down
                            if(dl_isWall == 1'b0 && d4_isWall == 1'b0 && dc_isWall == 1'b0 && d11_isWall == 1'b0 && dr_isWall == 1'b0) begin
                                next_direction = 3'b010;
                                CyanGhost_X_Motion_in = 10'd0;
                                CyanGhost_Y_Motion_in = CyanGhost_Y_Step;
                            end
                            //can't go down so check up
                            else if(ul_isWall == 1'b0 && u4_isWall == 1'b0 && uc_isWall == 1'b0 && u11_isWall == 1'b0 && ur_isWall == 1'b0) begin
                                next_direction = 3'b000;
                                CyanGhost_X_Motion_in = 10'd0;
                                CyanGhost_Y_Motion_in = (~(CyanGhost_Y_Step) + 1'b1);
                                //set flag = down
                                next_alignment_direction = 3'b010;
                            end
                            else begin
                                //set flag = down
                                next_alignment_direction = 3'b010;
                            end
                        end
                    end
                    else if(U_Dist < D_Dist) begin //moving up is best
                        //check to see if we can move up
                        if(ul_isWall == 1'b0 && u4_isWall == 1'b0 && uc_isWall == 1'b0 && u11_isWall == 1'b0 && ur_isWall == 1'b0) begin
                            next_direction = 3'b000;
                            CyanGhost_X_Motion_in = 10'd0;
                            CyanGhost_Y_Motion_in = (~(CyanGhost_Y_Step) + 1'b1);
                        end
                        //prioritize horizontal over the down option
                        else begin
                            //left is ideal
                            if(L_Dist < R_Dist) begin
                                //check left
                                if(lu_isWall == 1'b0 && l4_isWall == 1'b0 && lc_isWall == 1'b0 && l11_isWall == 1'b0 && ld_isWall == 1'b0) begin
                                    next_direction = 3'b001;
                                    CyanGhost_X_Motion_in = (~(CyanGhost_X_Step) + 1'b1);
                                    CyanGhost_Y_Motion_in = 10'd0;
                                end
                                //can't go up or left
                                else begin
                                    //check right
                                    if(ru_isWall == 1'b0 && r4_isWall == 1'b0 && rc_isWall == 1'b0 && r11_isWall == 1'b0 && rd_isWall == 1'b0) begin //go right
                                        next_direction = 3'b011;
                                        CyanGhost_X_Motion_in = CyanGhost_X_Step;
                                        CyanGhost_Y_Motion_in = 10'd0;
                                    end
                                    //can't go up or left or right so go down
                                    else if(dl_isWall == 1'b0 && d4_isWall == 1'b0 && dc_isWall == 1'b0 && d11_isWall == 1'b0 && dr_isWall == 1'b0) begin
                                        next_direction = 3'b010;
                                        CyanGhost_X_Motion_in = 10'd0;
                                        CyanGhost_Y_Motion_in = CyanGhost_Y_Step;
                                    end
                                end
                            end
                            //right is ideal or just as good as left
                            else begin
                                //check right
                                if(ru_isWall == 1'b0 && r4_isWall == 1'b0 && rc_isWall == 1'b0 && r11_isWall == 1'b0 && rd_isWall == 1'b0) begin
                                    next_direction = 3'b011;
                                    CyanGhost_X_Motion_in = CyanGhost_X_Step;
                                    CyanGhost_Y_Motion_in = 10'd0;
                                end
                                //can't go up or right
                                else begin
                                    //check left
                                    if(lu_isWall == 1'b0 && l4_isWall == 1'b0 && lc_isWall == 1'b0 && l11_isWall == 1'b0 && ld_isWall == 1'b0) begin //go left
                                        next_direction = 3'b001;
                                        CyanGhost_X_Motion_in = (~(CyanGhost_X_Step) + 1'b1);
                                        CyanGhost_Y_Motion_in = 10'd0;
                                    end
                                    //can't go up or right or left so go down
                                    else if(dl_isWall == 1'b0 && d4_isWall == 1'b0 && dc_isWall == 1'b0 && d11_isWall == 1'b0 && dr_isWall == 1'b0) begin
                                        next_direction = 3'b010;
                                        CyanGhost_X_Motion_in = 10'd0;
                                        CyanGhost_Y_Motion_in = CyanGhost_Y_Step;
                                    end
                                end
                            end
                        end						
                    end
                    else begin //moving down is best ---> (D_Dist <= U_Dist)
                        //check down
                        if(dl_isWall == 1'b0 && d4_isWall == 1'b0 && dc_isWall == 1'b0 && d11_isWall == 1'b0 && dr_isWall == 1'b0) begin
                            next_direction = 3'b010;
                            CyanGhost_X_Motion_in = 10'd0;
                            CyanGhost_Y_Motion_in = CyanGhost_Y_Step;
                        end
                        //can't go down so prioritize horizontal over down
                        else begin
                            //left is ideal
                            if(L_Dist < R_Dist) begin
                                //check left
                                if(lu_isWall == 1'b0 && l4_isWall == 1'b0 && lc_isWall == 1'b0 && l11_isWall == 1'b0 && ld_isWall == 1'b0) begin
                                    next_direction = 3'b001;
                                    CyanGhost_X_Motion_in = (~(CyanGhost_X_Step) + 1'b1);
                                    CyanGhost_Y_Motion_in = 10'd0;
                                end
                                //can't go down or left
                                else begin
                                    //check right
                                    if(ru_isWall == 1'b0 && r4_isWall == 1'b0 && rc_isWall == 1'b0 && r11_isWall == 1'b0 && rd_isWall == 1'b0) begin //go right
                                        next_direction = 3'b011;
                                        CyanGhost_X_Motion_in = CyanGhost_X_Step;
                                        CyanGhost_Y_Motion_in = 10'd0;
                                    end
                                    //can't go down or left or right so go up
                                    else if(ul_isWall == 1'b0 && u4_isWall == 1'b0 && uc_isWall == 1'b0 && u11_isWall == 1'b0 && ur_isWall == 1'b0) begin
                                        next_direction = 3'b010;
                                        CyanGhost_X_Motion_in = 10'd0;
                                        CyanGhost_Y_Motion_in = (~(CyanGhost_Y_Step) + 1'b1);
                                    end
                                end
                            end
                            //right is ideal or just as good as left
                            else begin
                                //check right
                                if(ru_isWall == 1'b0 && r4_isWall == 1'b0 && rc_isWall == 1'b0 && r11_isWall == 1'b0 && rd_isWall == 1'b0) begin
                                    next_direction = 3'b011;
                                    CyanGhost_X_Motion_in = CyanGhost_X_Step;
                                    CyanGhost_Y_Motion_in = 10'd0;
                                end
                                //can't go down or right
                                else begin
                                    //check left
                                    if(lu_isWall == 1'b0 && l4_isWall == 1'b0 && lc_isWall == 1'b0 && l11_isWall == 1'b0 && ld_isWall == 1'b0) begin //go left
                                        next_direction = 3'b001;
                                        CyanGhost_X_Motion_in = (~(CyanGhost_X_Step) + 1'b1);
                                        CyanGhost_Y_Motion_in = 10'd0;
                                    end
                                    //can't go down or right or left so go up
                                    else if(ul_isWall == 1'b0 && u4_isWall == 1'b0 && uc_isWall == 1'b0 && u11_isWall == 1'b0 && ur_isWall == 1'b0) begin
                                        next_direction = 3'b010;
                                        CyanGhost_X_Motion_in = 10'd0;
                                        CyanGhost_Y_Motion_in = (~(CyanGhost_Y_Step) + 1'b1);
                                    end
                                end
                            end
                        end
                    end				
                end	
            end
            if((CyanGhost_Y_Pos >= CyanGhost_Y_Max) || (CyanGhost_Y_Pos <= CyanGhost_Y_Min)) begin
                if(CyanGhost_Y_Pos >= CyanGhost_Y_Max)
                    CyanGhost_Y_Pos_in = CyanGhost_Y_Min + 10'd1 + CyanGhost_Y_Motion_in;
                else
                    CyanGhost_Y_Pos_in = CyanGhost_Y_Max - 10'd1 + CyanGhost_Y_Motion_in;
            end
            else if((CyanGhost_X_Pos >= CyanGhost_X_Max) || (CyanGhost_X_Pos <= CyanGhost_X_Min)) begin
                if(CyanGhost_X_Pos >= CyanGhost_X_Max) begin //going right
                    CyanGhost_X_Pos_in = CyanGhost_X_Min + 10'd1 + CyanGhost_X_Motion_in;
                end
                else begin //going left
                    CyanGhost_X_Pos_in = CyanGhost_X_Max - 10'd1 + CyanGhost_X_Motion_in;
                end
            end            
            else begin
                CyanGhost_X_Pos_in = CyanGhost_X_Pos + CyanGhost_X_Motion;
                CyanGhost_Y_Pos_in = CyanGhost_Y_Pos + CyanGhost_Y_Motion;                
            end
        end
    end
	 //determine whether the DrawX and DrawY a CyanGhostman coordinate 
    assign CyanGhostX = DrawX - CyanGhost_X_Pos + 10'd8;
    assign CyanGhostY = DrawY - CyanGhost_Y_Pos + 10'd8;    
    always_comb begin
        if (CyanGhostX >= 10'd1 && CyanGhostX < 10'd14 && CyanGhostY >= 10'd1 && CyanGhostY < 10'd14 && hold == 1'b0) 
            is_cyan_ghost = 1'b1;
        else
            is_cyan_ghost = 1'b0;
    end
endmodule 