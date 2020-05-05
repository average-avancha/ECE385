module red_ghost_sprite    (input          		    Clk,                // 50 MHz clock
													Reset,              // Active-high reset signal
													frame_clk,          // The clock indicating a new frame (~60Hz)
                                                    reload, hold,
						    input  		  [9:0]  	DrawX, DrawY, PacX, PacY,  // Current pixel coordinates
						    input         [2:0]     direction_out,             //Pacman's current direction
							output logic  [9:0]  	RedGhostX, RedGhostY,	   // How deep into the sprite the current pixel is
							output logic   			is_red_ghost,              // Whether current pixel belongs to Pac or background
							output logic  [2:0]     red_ghost_direction_out,
							output logic  [6:0] 	red_ghost_animation_count,
							output logic  [9:0]     RedGhostX_Monitor, RedGhostY_Monitor);
	//TEST start:
	//x:200
	//y:227
	parameter [9:0] RedGhost_X_Start = 10'd242 + RedGhost_X_Min; //(X,Y) starting position of RedGhostman upon reset
    parameter [9:0] RedGhost_Y_Start = 10'd157 + RedGhost_Y_Min; 
    parameter [9:0] RedGhost_X_Min = 10'd64;      // Leftmost point on the X axis
    parameter [9:0] RedGhost_X_Max = 10'd576;     // Rightmost point on the X axis
    parameter [9:0] RedGhost_Y_Min = 10'd48;      // Topmost point on the Y axis
    parameter [9:0] RedGhost_Y_Max = 10'd432;     // Bottommost point on the Y axis
    parameter [9:0] RedGhost_X_Step = 10'd1;      // Step size on the X axis
    parameter [9:0] RedGhost_Y_Step = 10'd1;      // Step size on the Y axis
    
    logic [9:0] RedGhost_X_Pos, RedGhost_X_Motion, RedGhost_Y_Pos, RedGhost_Y_Motion;
    logic [9:0] RedGhost_X_Pos_in, RedGhost_X_Motion_in, RedGhost_Y_Pos_in, RedGhost_Y_Motion_in;
    logic [2:0] direction, next_direction, prev_direction, next_prev_direction, alignment_direction, next_alignment_direction;
	logic [6:0] animation, next_animation; //registers used for animation sprites
	logic [9:0]     RedGhost_lu_x, RedGhost_lu_y, 
                    RedGhost_l4_x, RedGhost_l4_y,
                    RedGhost_lc_x, RedGhost_lc_y,
                    RedGhost_l11_x, RedGhost_l11_y,
                    RedGhost_ld_x, RedGhost_ld_y, 
                    RedGhost_dl_x, RedGhost_dl_y,
                    RedGhost_d4_x, RedGhost_d4_y,
                    RedGhost_dc_x, RedGhost_dc_y,
                    RedGhost_d11_x, RedGhost_d11_y,
                    RedGhost_dr_x, RedGhost_dr_y, 
                    RedGhost_rd_x, RedGhost_rd_y,
                    RedGhost_r11_x, RedGhost_r11_y, 
                    RedGhost_rc_x, RedGhost_rc_y, 
                    RedGhost_r4_x, RedGhost_r4_y, 
                    RedGhost_ru_x, RedGhost_ru_y, 
                    RedGhost_ur_x, RedGhost_ur_y,
                    RedGhost_u11_x, RedGhost_u11_y,
                    RedGhost_uc_x, RedGhost_uc_y,
                    RedGhost_u4_x, RedGhost_u4_y,
                    RedGhost_ul_x, RedGhost_ul_y;
	
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
            RedGhost_X_Pos <= RedGhost_X_Start;
            RedGhost_Y_Pos <= RedGhost_Y_Start;
            RedGhost_X_Motion <= 10'd0;
            RedGhost_Y_Motion <= 10'd0;
			direction <= 3'b111;
        end
		else if(hold) begin
			RedGhost_X_Pos <= RedGhost_X_Pos;
            RedGhost_Y_Pos <= RedGhost_Y_Pos;
            RedGhost_X_Motion <= 10'd0;
            RedGhost_Y_Motion <= 10'd0;
			direction <= 3'b111;
		end
        else begin
            RedGhost_X_Pos <= RedGhost_X_Pos_in;
            RedGhost_Y_Pos <= RedGhost_Y_Pos_in;
            RedGhost_X_Motion <= RedGhost_X_Motion_in;
            RedGhost_Y_Motion <= RedGhost_Y_Motion_in;
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
		next_prev_direction = red_ghost_direction_out;
		if(red_ghost_direction_out == 3'b111)
			next_prev_direction = prev_direction;
	end
	
	logic [2:0] countdown, next_countdown;
	//delay a change in alignment
	always_ff @ (posedge Clk) begin
		if(Reset || reload)
			countdown <= 3'b011;
		else
			countdown <= next_countdown;
	end
	
    wallChecker LU (.x(RedGhost_lu_x), .y(RedGhost_lu_y), .is_wall(lu_isWall));
    wallChecker L4 (.x(RedGhost_l4_x), .y(RedGhost_l4_y), .is_wall(l4_isWall));
    wallChecker LC (.x(RedGhost_lc_x), .y(RedGhost_lc_y), .is_wall(lc_isWall));
    wallChecker L11 (.x(RedGhost_l11_x), .y(RedGhost_l11_y), .is_wall(l11_isWall));
    wallChecker LD (.x(RedGhost_ld_x), .y(RedGhost_ld_y), .is_wall(ld_isWall));

    wallChecker DL (.x(RedGhost_dl_x), .y(RedGhost_dl_y), .is_wall(dl_isWall));
    wallChecker D4 (.x(RedGhost_d4_x), .y(RedGhost_d4_y), .is_wall(d4_isWall));
    wallChecker DC (.x(RedGhost_dc_x), .y(RedGhost_dc_y), .is_wall(dc_isWall));
    wallChecker D11 (.x(RedGhost_d11_x), .y(RedGhost_d11_y), .is_wall(d11_isWall));    
    wallChecker DR (.x(RedGhost_dr_x), .y(RedGhost_dr_y), .is_wall(dr_isWall));

    wallChecker RD (.x(RedGhost_rd_x), .y(RedGhost_rd_y), .is_wall(rd_isWall));
    wallChecker R11 (.x(RedGhost_r11_x), .y(RedGhost_r11_y), .is_wall(r11_isWall));
    wallChecker RC (.x(RedGhost_rc_x), .y(RedGhost_rc_y), .is_wall(rc_isWall));
    wallChecker R4 (.x(RedGhost_r4_x), .y(RedGhost_r4_y), .is_wall(r4_isWall));
    wallChecker RU (.x(RedGhost_ru_x), .y(RedGhost_ru_y), .is_wall(ru_isWall));

    wallChecker UR (.x(RedGhost_ur_x), .y(RedGhost_ur_y), .is_wall(ur_isWall));
    wallChecker U11 (.x(RedGhost_u11_x), .y(RedGhost_u11_y), .is_wall(u11_isWall));
    wallChecker UC (.x(RedGhost_uc_x), .y(RedGhost_uc_y), .is_wall(uc_isWall));
    wallChecker U4 (.x(RedGhost_u4_x), .y(RedGhost_u4_y), .is_wall(u4_isWall));
    wallChecker UL (.x(RedGhost_ul_x), .y(RedGhost_ul_y), .is_wall(ul_isWall));
    
	assign RedGhostX_Monitor = RedGhost_X_Pos;
	assign RedGhostY_Monitor = RedGhost_Y_Pos;
	 //animation register combinational logic
	assign red_ghost_direction_out = direction;
	assign red_ghost_animation_count = animation;
    //the blocks used for pathfinding to pacman 
	logic [9:0] U_X, U_Y, L_X, L_Y, R_X, R_Y, D_X, D_Y, C_X, C_Y; //blocks in relation to a ghost sprite used in minimizing path distance
	int U_DistX, U_DistY, L_DistX, L_DistY, D_DistX, D_DistY, R_DistX, R_DistY, C_DistX, C_DistY, U_Dist, L_Dist, D_Dist, R_Dist, C_Dist; 
	int PacCenterX, PacCenterY, RedGhostCenterX, RedGhostCenterY;
	
	always_comb begin
	 //position re-assignment from logic to int
		PacCenterX = PacX;
		PacCenterY = PacY;
		RedGhostCenterX = RedGhost_X_Pos;
		RedGhostCenterY = RedGhost_Y_Pos;
		
		U_X = RedGhost_X_Pos;
		U_Y = RedGhost_Y_Pos - 10'd1;
		
		L_X = RedGhost_X_Pos - 10'd1;
		L_Y = RedGhost_Y_Pos; 
		
		D_X = RedGhost_X_Pos; 
		D_Y = RedGhost_Y_Pos + 10'd1;
		
		R_X = RedGhost_X_Pos + 10'd1;
		R_Y = RedGhost_Y_Pos;
		
		C_X = RedGhost_X_Pos;
		C_Y = RedGhost_Y_Pos;
		
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
	
	always_comb begin
        //by default, position/motion of RedGhostman remains unchanged, but RedGhostman is always being animated (except for when he colides or is still
        RedGhost_X_Pos_in = RedGhost_X_Pos;
        RedGhost_Y_Pos_in = RedGhost_Y_Pos;
        RedGhost_X_Motion_in = RedGhost_X_Motion;
        RedGhost_Y_Motion_in = RedGhost_Y_Motion;
        next_direction = direction;
		next_animation = animation;
		next_alignment_direction = alignment_direction;
		next_flag = flag;
		next_countdown = countdown;
        //update boundary checking pixel coordinates of the RedGhostman sprite 
        RedGhost_ul_x = RedGhost_X_Pos  + 10'd1 - 10'd8 - 10'd64;
        RedGhost_ul_y = RedGhost_Y_Pos  + 10'd1 - 10'd9 - 10'd48 - 10'd1;
        RedGhost_u4_x = RedGhost_X_Pos  + 10'd1 - 10'd4 - 10'd64;
        RedGhost_u4_y = RedGhost_Y_Pos  + 10'd1 - 10'd9 - 10'd48 - 10'd1;
        RedGhost_uc_x = RedGhost_X_Pos  + 10'd0 - 10'd64;
        RedGhost_uc_y = RedGhost_Y_Pos  + 10'd1 - 10'd9 - 10'd48 - 10'd1;
        RedGhost_u11_x = RedGhost_X_Pos - 10'd1 + 10'd3 - 10'd64;
        RedGhost_u11_y = RedGhost_Y_Pos + 10'd1 - 10'd9 - 10'd48 - 10'd1;
        RedGhost_ur_x = RedGhost_X_Pos  - 10'd1 + 10'd7 - 10'd64;
        RedGhost_ur_y = RedGhost_Y_Pos  + 10'd1 - 10'd9 - 10'd48 - 10'd1;

        RedGhost_ru_x = RedGhost_X_Pos  - 10'd1 + 10'd8 - 10'd64 + 10'd1;
        RedGhost_ru_y = RedGhost_Y_Pos  + 10'd1 - 10'd8 - 10'd48;
        RedGhost_r4_x = RedGhost_X_Pos  - 10'd1 + 10'd8 - 10'd64 + 10'd1;
        RedGhost_r4_y = RedGhost_Y_Pos  + 10'd1 - 10'd4 - 10'd48;
        RedGhost_rc_x = RedGhost_X_Pos  - 10'd1 + 10'd8 - 10'd64 + 10'd1;
        RedGhost_rc_y = RedGhost_Y_Pos  + 10'd0 - 10'd48;
        RedGhost_r11_x = RedGhost_X_Pos - 10'd1 + 10'd8 - 10'd64 + 10'd1;
        RedGhost_r11_y = RedGhost_Y_Pos - 10'd1 + 10'd3 - 10'd48;
        RedGhost_rd_x = RedGhost_X_Pos  - 10'd1 + 10'd8 - 10'd64 + 10'd1;
        RedGhost_rd_y = RedGhost_Y_Pos  - 10'd1 + 10'd7 - 10'd48;

        RedGhost_dr_x = RedGhost_X_Pos  - 10'd1 + 10'd7 - 10'd64;
        RedGhost_dr_y = RedGhost_Y_Pos  - 10'd1 + 10'd8 - 10'd48 + 10'd1;
        RedGhost_d11_x = RedGhost_X_Pos - 10'd1 + 10'd3 - 10'd64;
        RedGhost_d11_y = RedGhost_Y_Pos - 10'd1 + 10'd8 - 10'd48 + 10'd1;
        RedGhost_dc_x = RedGhost_X_Pos  + 10'd0 - 10'd64;
        RedGhost_dc_y = RedGhost_Y_Pos  - 10'd1 + 10'd8 - 10'd48 + 10'd1;
        RedGhost_d4_x = RedGhost_X_Pos  + 10'd1 - 10'd4 - 10'd64;
        RedGhost_d4_y = RedGhost_Y_Pos  - 10'd1 + 10'd8 - 10'd48 + 10'd1;
        RedGhost_dl_x = RedGhost_X_Pos  + 10'd1 - 10'd8 - 10'd64;
        RedGhost_dl_y = RedGhost_Y_Pos  - 10'd1 + 10'd8 - 10'd48 + 10'd1;

        RedGhost_ld_x = RedGhost_X_Pos  + 10'd1 - 10'd9 - 10'd64 - 10'd1;
        RedGhost_ld_y = RedGhost_Y_Pos  - 10'd1 + 10'd7 - 10'd48;
        RedGhost_l11_x = RedGhost_X_Pos + 10'd1 - 10'd9 - 10'd64 - 10'd1;
        RedGhost_l11_y = RedGhost_Y_Pos - 10'd1 + 10'd3 - 10'd48;
        RedGhost_lc_x = RedGhost_X_Pos  + 10'd1 - 10'd9 - 10'd64 - 10'd1;
        RedGhost_lc_y = RedGhost_Y_Pos  + 10'd0 - 10'd48;
        RedGhost_l4_x = RedGhost_X_Pos  + 10'd1 - 10'd9 - 10'd64 - 10'd1;
        RedGhost_l4_y = RedGhost_Y_Pos  + 10'd1 - 10'd4 - 10'd48;
        RedGhost_lu_x = RedGhost_X_Pos  + 10'd1 - 10'd9 - 10'd64 - 10'd1; // (Center_coord - sprite_wall_check_offset - gradient_border_offset - 2pixel's_ahead_offset)
        RedGhost_lu_y = RedGhost_Y_Pos  + 10'd1 - 10'd8 - 10'd48;
        
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
                    RedGhost_X_Motion_in = 10'd0;
                    RedGhost_Y_Motion_in = 10'd0;
                    next_direction = 3'b111;
						next_animation = animation;
                end
            end
            else if (direction == 3'b001) begin
                if(lu_isWall == 1'b1 || l4_isWall == 1'b1 || lc_isWall == 1'b1 || l11_isWall == 1'b1 || ld_isWall == 1'b1) begin
                    RedGhost_X_Motion_in = 10'd0;
                    RedGhost_Y_Motion_in = 10'd0;
                    next_direction = 3'b111;
						next_animation = animation;						  
                end
            end
            else if (direction == 3'b010) begin
                if(dl_isWall == 1'b1 || d4_isWall == 1'b1 || dc_isWall == 1'b1 || d11_isWall == 1'b1 || dr_isWall == 1'b1) begin
                    RedGhost_X_Motion_in = 10'd0;
                    RedGhost_Y_Motion_in = 10'd0;
                    next_direction = 3'b111;
					next_animation = animation;						  
                end            
            end
            else if (direction == 3'b011) begin
                if(ru_isWall == 1'b1 || r4_isWall == 1'b1 || rc_isWall == 1'b1 || r11_isWall == 1'b1 || rd_isWall == 1'b1) begin
                    RedGhost_X_Motion_in = 10'd0;
                    RedGhost_Y_Motion_in = 10'd0;
                    next_direction = 3'b111;
					next_animation = animation;						  
                end           
            end



////////////////////////////////////////////////////KILLER PATHFINDING-ISH //////////////////////////////////////////////////////////////////
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
							RedGhost_X_Motion_in = 10'd0;
							RedGhost_Y_Motion_in = (~(RedGhost_Y_Step) + 1'b1);
						end
						//can't move up
						else begin
							//try to move left
							if(lu_isWall == 1'b0 && l4_isWall == 1'b0 && lc_isWall == 1'b0 && l11_isWall == 1'b0 && ld_isWall == 1'b0) begin
								next_direction = 3'b001;
								RedGhost_X_Motion_in = (~(RedGhost_X_Step) + 1'b1);
								RedGhost_Y_Motion_in = 10'd0;
							end
							//can't move left --> check right
							else if(ru_isWall == 1'b0 && r4_isWall == 1'b0 && rc_isWall == 1'b0 && r11_isWall == 1'b0 && rd_isWall == 1'b0) begin
								next_direction = 3'b011;
								RedGhost_X_Motion_in = RedGhost_X_Step;
								RedGhost_Y_Motion_in = 10'd0;
							end
						end
					end
					3'b001: begin
						//previously aligned and wanted to go left, so when the next available left movement is allowed, go left
						if(lu_isWall == 1'b0 && l4_isWall == 1'b0 && lc_isWall == 1'b0 && l11_isWall == 1'b0 && ld_isWall == 1'b0) begin
							//next_alignment_direction = 3'b111;
							next_countdown = countdown - 3'd1; 							
							next_direction = 3'b001;
							RedGhost_X_Motion_in = (~(RedGhost_X_Step) + 1'b1);
							RedGhost_Y_Motion_in = 10'd0;
						end
						//can't move left
						else begin
							//try to move up
							if(ul_isWall == 1'b0 && u4_isWall == 1'b0 && uc_isWall == 1'b0 && u11_isWall == 1'b0 && ur_isWall == 1'b0) begin
								next_direction = 3'b000;
								RedGhost_X_Motion_in = 10'd0;
								RedGhost_Y_Motion_in = (~(RedGhost_Y_Step) + 1'b1);
							end
							//can't move up --> check down
							else if(dl_isWall == 1'b0 && d4_isWall == 1'b0 && dc_isWall == 1'b0 && d11_isWall == 1'b0 && dr_isWall == 1'b0) begin
								next_direction = 3'b010;
								RedGhost_X_Motion_in = 10'd0;
								RedGhost_Y_Motion_in = RedGhost_Y_Step;
							end
						end
					end
					3'b010: begin
						//previously aligned and wanted to go down, so when the next available down movement is allowed, go down
						if(dl_isWall == 1'b0 && d4_isWall == 1'b0 && dc_isWall == 1'b0 && d11_isWall == 1'b0 && dr_isWall == 1'b0) begin
							//next_alignment_direction = 3'b111;
							next_countdown = countdown - 3'd1; 							
							next_direction = 3'b010;
							RedGhost_X_Motion_in = 10'd0;
							RedGhost_Y_Motion_in = RedGhost_Y_Step;
						end
						//can't move down
						else begin
							//try to move right
							if(ru_isWall == 1'b0 && r4_isWall == 1'b0 && rc_isWall == 1'b0 && r11_isWall == 1'b0 && rd_isWall == 1'b0) begin
								next_direction = 3'b011;
								RedGhost_X_Motion_in = RedGhost_X_Step;
								RedGhost_Y_Motion_in = 10'd0;
							end
							//can't move right --> check left
							else if(lu_isWall == 1'b0 && l4_isWall == 1'b0 && lc_isWall == 1'b0 && l11_isWall == 1'b0 && ld_isWall == 1'b0) begin
								next_direction = 3'b001;
								RedGhost_X_Motion_in = (~(RedGhost_X_Step) + 1'b1);
								RedGhost_Y_Motion_in = 10'd0;
							end
						end
					end
					3'b011: begin
						//previously aligned and wanted to go right, so when the next available right movement is allowed, go right
						if(ru_isWall == 1'b0 && r4_isWall == 1'b0 && rc_isWall == 1'b0 && r11_isWall == 1'b0 && rd_isWall == 1'b0) begin
							//next_alignment_direction = 3'b111;
							next_countdown = countdown - 3'd1; 							
							next_direction = 3'b011;
							RedGhost_X_Motion_in = RedGhost_X_Step;
							RedGhost_Y_Motion_in = 10'd0;
						end
						//can't move right
						else begin
							//try to move down
							if(dl_isWall == 1'b0 && d4_isWall == 1'b0 && dc_isWall == 1'b0 && d11_isWall == 1'b0 && dr_isWall == 1'b0) begin
								next_direction = 3'b010;
								RedGhost_X_Motion_in = 10'd0;
								RedGhost_Y_Motion_in = RedGhost_Y_Step;
							end
							//can't move down --> check up
							else if(ul_isWall == 1'b0 && u4_isWall == 1'b0 && uc_isWall == 1'b0 && u11_isWall == 1'b0 && ur_isWall == 1'b0) begin
								next_direction = 3'b000;
								RedGhost_X_Motion_in = 10'd0;
								RedGhost_Y_Motion_in = (~(RedGhost_Y_Step) + 1'b1);
							end
						end
					end
					default: ;
				endcase
			end
			else begin
				if(C_Dist < 16) begin
					next_direction = 3'b111;
					RedGhost_X_Motion_in = 10'd0;
					RedGhost_Y_Motion_in = 10'd0;
				end
				else if((PacCenterY - RedGhostCenterY <= 1) && (PacCenterY - RedGhostCenterY >= -1)) begin
					//Check Horizonal Movement -> left is ideal?
					if(L_Dist < R_Dist) begin
						//check left
						if(lu_isWall == 1'b0 && l4_isWall == 1'b0 && lc_isWall == 1'b0 && l11_isWall == 1'b0 && ld_isWall == 1'b0) begin
							next_direction = 3'b001;
							RedGhost_X_Motion_in = (~(RedGhost_X_Step) + 1'b1);
							RedGhost_Y_Motion_in = 10'd0;
						end
						//cant move left -> check right
						else if(ru_isWall == 1'b0 && r4_isWall == 1'b0 && rc_isWall == 1'b0 && r11_isWall == 1'b0 && rd_isWall == 1'b0) begin
							next_direction = 3'b011;
							RedGhost_X_Motion_in = RedGhost_X_Step;
							RedGhost_Y_Motion_in = 10'd0;
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
							RedGhost_X_Motion_in = RedGhost_X_Step;
							RedGhost_Y_Motion_in = 10'd0;
						end
						else if(lu_isWall == 1'b0 && l4_isWall == 1'b0 && lc_isWall == 1'b0 && l11_isWall == 1'b0 && ld_isWall == 1'b0) begin
							next_direction = 3'b001;
							RedGhost_X_Motion_in = (~(RedGhost_X_Step) + 1'b1);
							RedGhost_Y_Motion_in = 10'd0;
							//set flag = right
							next_alignment_direction = 3'b011;
						end
						else begin
							//set flag = right
							next_alignment_direction = 3'b011;
						end
					end
				end
				else if((PacCenterX - RedGhostCenterX <= 1) && (PacCenterX - RedGhostCenterX >= -1)) begin
					//Check Vertical Movement --> check if up is ideal
					if(U_Dist < D_Dist) begin
						//check up
						if(ul_isWall == 1'b0 && u4_isWall == 1'b0 && uc_isWall == 1'b0 && u11_isWall == 1'b0 && ur_isWall == 1'b0) begin
							next_direction = 3'b000;
							RedGhost_X_Motion_in = 10'd0;
							RedGhost_Y_Motion_in = (~(RedGhost_Y_Step) + 1'b1);
						end
						//can't go up so check down
						else if(dl_isWall == 1'b0 && d4_isWall == 1'b0 && dc_isWall == 1'b0 && d11_isWall == 1'b0 && dr_isWall == 1'b0) begin
							next_direction = 3'b010;
							RedGhost_X_Motion_in = 10'd0;
							RedGhost_Y_Motion_in = RedGhost_Y_Step;
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
							RedGhost_X_Motion_in = 10'd0;
							RedGhost_Y_Motion_in = RedGhost_Y_Step;
						end
						//can't go down so check up
						else if(ul_isWall == 1'b0 && u4_isWall == 1'b0 && uc_isWall == 1'b0 && u11_isWall == 1'b0 && ur_isWall == 1'b0) begin
							next_direction = 3'b000;
							RedGhost_X_Motion_in = 10'd0;
							RedGhost_Y_Motion_in = (~(RedGhost_Y_Step) + 1'b1);
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
						RedGhost_X_Motion_in = 10'd0;
						RedGhost_Y_Motion_in = (~(RedGhost_Y_Step) + 1'b1);
					end
					//prioritize horizontal over the down option
					else begin
						//left is ideal
						if(L_Dist < R_Dist) begin
							//check left
							if(lu_isWall == 1'b0 && l4_isWall == 1'b0 && lc_isWall == 1'b0 && l11_isWall == 1'b0 && ld_isWall == 1'b0) begin
								next_direction = 3'b001;
								RedGhost_X_Motion_in = (~(RedGhost_X_Step) + 1'b1);
								RedGhost_Y_Motion_in = 10'd0;
							end
							//can't go up or left
							else begin
								//check right
								if(ru_isWall == 1'b0 && r4_isWall == 1'b0 && rc_isWall == 1'b0 && r11_isWall == 1'b0 && rd_isWall == 1'b0) begin //go right
									next_direction = 3'b011;
									RedGhost_X_Motion_in = RedGhost_X_Step;
									RedGhost_Y_Motion_in = 10'd0;
								end
								//can't go up or left or right so go down
								else if(dl_isWall == 1'b0 && d4_isWall == 1'b0 && dc_isWall == 1'b0 && d11_isWall == 1'b0 && dr_isWall == 1'b0) begin
									next_direction = 3'b010;
									RedGhost_X_Motion_in = 10'd0;
									RedGhost_Y_Motion_in = RedGhost_Y_Step;
								end
							end
						end
						//right is ideal or just as good as left
						else begin
							//check right
							if(ru_isWall == 1'b0 && r4_isWall == 1'b0 && rc_isWall == 1'b0 && r11_isWall == 1'b0 && rd_isWall == 1'b0) begin
								next_direction = 3'b011;
								RedGhost_X_Motion_in = RedGhost_X_Step;
								RedGhost_Y_Motion_in = 10'd0;
							end
							//can't go up or right
							else begin
								//check left
								if(lu_isWall == 1'b0 && l4_isWall == 1'b0 && lc_isWall == 1'b0 && l11_isWall == 1'b0 && ld_isWall == 1'b0) begin //go left
									next_direction = 3'b001;
									RedGhost_X_Motion_in = (~(RedGhost_X_Step) + 1'b1);
									RedGhost_Y_Motion_in = 10'd0;
								end
								//can't go up or right or left so go down
								else if(dl_isWall == 1'b0 && d4_isWall == 1'b0 && dc_isWall == 1'b0 && d11_isWall == 1'b0 && dr_isWall == 1'b0) begin
									next_direction = 3'b010;
									RedGhost_X_Motion_in = 10'd0;
									RedGhost_Y_Motion_in = RedGhost_Y_Step;
								end
							end
						end
					end						
				end
				else begin //moving down is best ---> (D_Dist <= U_Dist)
					//check down
					if(dl_isWall == 1'b0 && d4_isWall == 1'b0 && dc_isWall == 1'b0 && d11_isWall == 1'b0 && dr_isWall == 1'b0) begin
						next_direction = 3'b010;
						RedGhost_X_Motion_in = 10'd0;
						RedGhost_Y_Motion_in = RedGhost_Y_Step;
					end
					//can't go down so prioritize horizontal over down
					else begin
						//left is ideal
						if(L_Dist < R_Dist) begin
							//check left
							if(lu_isWall == 1'b0 && l4_isWall == 1'b0 && lc_isWall == 1'b0 && l11_isWall == 1'b0 && ld_isWall == 1'b0) begin
								next_direction = 3'b001;
								RedGhost_X_Motion_in = (~(RedGhost_X_Step) + 1'b1);
								RedGhost_Y_Motion_in = 10'd0;
							end
							//can't go down or left
							else begin
								//check right
								if(ru_isWall == 1'b0 && r4_isWall == 1'b0 && rc_isWall == 1'b0 && r11_isWall == 1'b0 && rd_isWall == 1'b0) begin //go right
									next_direction = 3'b011;
									RedGhost_X_Motion_in = RedGhost_X_Step;
									RedGhost_Y_Motion_in = 10'd0;
								end
								//can't go down or left or right so go up
								else if(ul_isWall == 1'b0 && u4_isWall == 1'b0 && uc_isWall == 1'b0 && u11_isWall == 1'b0 && ur_isWall == 1'b0) begin
									next_direction = 3'b010;
									RedGhost_X_Motion_in = 10'd0;
									RedGhost_Y_Motion_in = (~(RedGhost_Y_Step) + 1'b1);
								end
							end
						end
						//right is ideal or just as good as left
						else begin
							//check right
							if(ru_isWall == 1'b0 && r4_isWall == 1'b0 && rc_isWall == 1'b0 && r11_isWall == 1'b0 && rd_isWall == 1'b0) begin
								next_direction = 3'b011;
								RedGhost_X_Motion_in = RedGhost_X_Step;
								RedGhost_Y_Motion_in = 10'd0;
							end
							//can't go down or right
							else begin
								//check left
								if(lu_isWall == 1'b0 && l4_isWall == 1'b0 && lc_isWall == 1'b0 && l11_isWall == 1'b0 && ld_isWall == 1'b0) begin //go left
									next_direction = 3'b001;
									RedGhost_X_Motion_in = (~(RedGhost_X_Step) + 1'b1);
									RedGhost_Y_Motion_in = 10'd0;
								end
								//can't go down or right or left so go up
								else if(ul_isWall == 1'b0 && u4_isWall == 1'b0 && uc_isWall == 1'b0 && u11_isWall == 1'b0 && ur_isWall == 1'b0) begin
									next_direction = 3'b010;
									RedGhost_X_Motion_in = 10'd0;
									RedGhost_Y_Motion_in = (~(RedGhost_Y_Step) + 1'b1);
								end
							end
						end
					end
				end				
			end				
			if((RedGhost_Y_Pos >= RedGhost_Y_Max) || (RedGhost_Y_Pos <= RedGhost_Y_Min)) begin
                if(RedGhost_Y_Pos >= RedGhost_Y_Max)
                    RedGhost_Y_Pos_in = RedGhost_Y_Min + 10'd1 + RedGhost_Y_Motion_in;
                else
                    RedGhost_Y_Pos_in = RedGhost_Y_Max - 10'd1 + RedGhost_Y_Motion_in;
            end
            else if((RedGhost_X_Pos >= RedGhost_X_Max) || (RedGhost_X_Pos <= RedGhost_X_Min)) begin
                if(RedGhost_X_Pos >= RedGhost_X_Max) begin //going right
                    RedGhost_X_Pos_in = RedGhost_X_Min + 10'd1 + RedGhost_X_Motion_in;
                end
                else begin //going left
                    RedGhost_X_Pos_in = RedGhost_X_Max - 10'd1 + RedGhost_X_Motion_in;
                end
            end	 			
            else begin
                RedGhost_X_Pos_in = RedGhost_X_Pos + RedGhost_X_Motion;
                RedGhost_Y_Pos_in = RedGhost_Y_Pos + RedGhost_Y_Motion;    
            end
        end
    end
    
	 //determine whether the DrawX and DrawY a RedGhostman coordinate 
    assign RedGhostX = DrawX - RedGhost_X_Pos + 10'd8;
    assign RedGhostY = DrawY - RedGhost_Y_Pos + 10'd8;    
    
	always_comb begin
        if (RedGhostX >= 10'd1 && RedGhostX < 10'd14 && RedGhostY >= 10'd1 && RedGhostY < 10'd14 && hold == 1'b0) 
            is_red_ghost = 1'b1;
        else
            is_red_ghost = 1'b0;
    end
endmodule 