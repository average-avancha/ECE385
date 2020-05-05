module controls_game   (input               Clk, frame_clk_rising_edge,
                        input               Reset,
                                            increment_score_powdot,
                        input        [7:0]  keycode,
                        input        [7:0]  dot_count,
                        input        [9:0]  PacX_Monitor, PacY_Monitor, RedGhostX_Monitor, RedGhostY_Monitor, OrangeGhostX_Monitor, OrangeGhostY_Monitor, CyanGhostX_Monitor, CyanGhostY_Monitor, PinkGhostX_Monitor, PinkGhostY_Monitor,
                        output logic        is_cyan_killer, is_pink_killer, is_powered_up, 
                                            is_cyan_scared, is_orange_scared, is_pink_scared, is_red_scared,
                                            increment_score_ghost,
                                            reset_score, reset_dots, 
                                            reload, reload_cyan, reload_orange, reload_pink, reload_red,
                                            hold, dying, game_ended, losing_power, RELOAD_state,
                        output logic [1:0]  life_count,
                        output logic [2:0]  enum_state,
                        output logic [3:0]  scared,
                        output logic [6:0]  death_time,
                        output logic [8:0]  timer_powered_up, map_flash_timer,
						output logic	    collision_state
                        );
	assign collision_state = collided_flag;
	assign enum_state = state; 
	enum logic [2:0] {START, WAIT, PLAY, INIT_POWERED_UP, POWERED_UP, DEATH_ANIM, RELOAD, END} state, next_state;
	always_ff @ (posedge Clk) begin
		if(Reset)
			state <= START;
		else
			state <= next_state;
	end

	always_comb begin
        next_state = state;
        next_scared = scared;
        next_death_time = death_time;  
        next_life_count = life_count;
        next_collided_flag = collided_flag;
        next_map_flash_timer = map_flash_timer;
        next_timer_powered_up = timer_powered_up;
		unique case (state)
            START : 
                next_state = WAIT;
            WAIT : begin
                if(keycode == 8'h1A || keycode == 8'h04 || keycode == 8'h16 || keycode == 8'h07)
                    next_state = PLAY;
            end
            PLAY : begin
                if((collided_flag == 1'b1) && (increment_score_powdot == 1'b0))
                    next_state = DEATH_ANIM;
                else if(increment_score_powdot == 1'b1)
                    next_state = INIT_POWERED_UP;
                else if(dot_count == 8'd0)
                    next_state = RELOAD;
            end
            INIT_POWERED_UP : begin
                next_state = POWERED_UP;
            end
            POWERED_UP : begin
				//change #1: made this all else if chains with the order I think is important
                if(collided_flag == 1'b1)
                    next_state = DEATH_ANIM;
                else if(increment_score_powdot == 1'b1)
                    next_state = INIT_POWERED_UP;                
					else if(timer_powered_up == 9'd0)
                    next_state = PLAY;                                
					else if(dot_count == 8'd0)
                    next_state = RELOAD;
            end
            DEATH_ANIM : begin
                if((death_time == 7'd0) && (life_count == 2'd0))
                    next_state = END;
                else if(death_time == 7'd0)
                    next_state = WAIT;
				end
            RELOAD : 
                if(map_flash_timer == 9'd0)
                    next_state = WAIT;
            END : begin
                if(keycode != 8'h00)
                    next_state = START;
            end
		endcase
        //default control signals
        reset_life = 1'b0;
        reset_score = 1'b0;
        reset_dots = 1'b0;
        reset_scared = 1'b0;
        reset_powered_up = 1'b0;
        reset_collided_flag = 1'b0;
        reset_death_time = 1'b0;
        reset_map_flash_timer = 1'b0;
        reload = 1'b0;
        reload_cyan = 1'b0;
        reload_orange = 1'b0;
        reload_pink = 1'b0;
        reload_red = 1'b0;
        RELOAD_state = 1'b0;
        
        hold = 1'b0;
        dying = 1'b0;
        game_ended = 1'b0;
        set_scared = 1'b0;
        losing_power = 1'b0;
        increment_score_ghost = 1'b0;
        
        is_cyan_killer = 1'b0;
        is_pink_killer = 1'b0;
        is_powered_up = 1'b0;
        
        is_cyan_scared   = scared[0];
        is_orange_scared = scared[1];
        is_pink_scared   = scared[2];
        is_red_scared    = scared[3];

        case(state)
            START: begin
                reset_life  = 1'b1;
                reset_score = 1'b1;
                reset_dots  = 1'b1;
            end
            WAIT: begin
                reload = 1'b1;
                reload_cyan = 1'b1;
                reload_orange = 1'b1;
                reload_pink = 1'b1;
                reload_red = 1'b1;
            end
            PLAY: begin
                if(dot_count < 8'd5)
                    is_cyan_killer = 1'b1;
                if(dot_count < 8'd10)
                    is_pink_killer = 1'b1;
                if(dot_count == 8'd0)
                    reset_map_flash_timer = 1'b1;
                if(frame_clk_rising_edge) begin
                    //initialize the death sequence since collision happened
                    if((Dist_Cyan_Pac < collision_distance_int) || (Dist_Orange_Pac < collision_distance_int) || (Dist_Pink_Pac < collision_distance_int) || (Dist_Red_Pac < collision_distance_int) && (collided_flag == 1'b0)) begin
                        next_collided_flag = 1'b1;
                        reset_death_time = 1'b1;
                    end
                end
            end
            INIT_POWERED_UP : begin
                set_scared = 1'b1;
                reset_powered_up = 1'b1;
            end
            POWERED_UP: begin
                is_powered_up = 1'b1;
                if(dot_count == 8'd0)
                    reset_map_flash_timer = 1'b1;
                if(timer_powered_up == 9'd0) begin //change #2: added a missing being/end here (won't be needed if we keep reset_powered_up commented out, but it was an issue before)
                    reset_powered_up = 1'b1; //change #3: removed reset_powered_up timer since it will be reset in the next init_powered up cycle
                    reset_scared = 1'b1;
				end
                if(timer_powered_up <= 9'd150)
                    losing_power = 1'b1;
                if(frame_clk_rising_edge) begin
                    next_timer_powered_up = timer_powered_up - 9'd1;
                    if(((Dist_Cyan_Pac < collision_distance_int) && (scared[0] == 1'b0)) || ((Dist_Orange_Pac < collision_distance_int) && (scared[1] == 1'b0)) || ((Dist_Pink_Pac < collision_distance_int) && (scared[2] == 1'b0)) || ((Dist_Red_Pac < collision_distance_int) && (scared[3] == 1'b0)) && (collided_flag == 1'b0)) begin
                        next_collided_flag = 1'b1; //since ghost isn't scared and collision happened, flag collision for death animation
                        reset_death_time = 1'b1;
                    end
                    if(Dist_Cyan_Pac < collision_distance_int && scared[0] == 1'b1) begin
                        increment_score_ghost = 1'b1;
                        reload_cyan = 1'b1;
                        next_scared[0] = 1'b0;
                    end
                    if(Dist_Orange_Pac < collision_distance_int && scared[1] == 1'b1) begin
                        increment_score_ghost = 1'b1;
                        reload_orange = 1'b1;
                        next_scared[1] = 1'b0;
                    end
                    if(Dist_Pink_Pac < collision_distance_int && scared[2] == 1'b1) begin
                        increment_score_ghost = 1'b1;
                        reload_pink = 1'b1;
                        next_scared[2] = 1'b0;
                    end
                    if(Dist_Red_Pac < collision_distance_int && scared[3] == 1'b1) begin
                        increment_score_ghost = 1'b1;
                        reload_red = 1'b1;
                        next_scared[3] = 1'b0;
                    end
                end
            end
            DEATH_ANIM : begin
                hold = 1'b1;
                dying = 1'b1;
				//death animation is done, so reset the flag and the counter 
                if(death_time == 7'd0) begin
                    reset_collided_flag = 1'b1;
                    next_life_count = life_count - 2'd1;
                    reset_scared = 1'b1; //change #4: once a death animation is done, we should make all ghosts not scared in the case we died in powered up state
                end
                //since a collision happend, we start counting down 
                else if(frame_clk_rising_edge) begin
                    next_death_time = death_time - 7'd1;
                end
            end
            RELOAD: begin
                hold = 1'b1;
                RELOAD_state = 1'b1;
                if(map_flash_timer == 9'd0)
                    reset_dots = 1'b1;
                    reset_map_flash_timer = 1'b1;
                if(frame_clk_rising_edge)
                    next_map_flash_timer = map_flash_timer - 9'd1;
            end
            END: begin
                game_ended = 1'b1;
                hold = 1'b1;
                dying = 1'b1;
            end
            default: ;
        endcase
	end

    //life count register
    logic [1:0] next_life_count; 
    logic reset_life;
    always_ff @ (posedge Clk) begin
        if(Reset || reset_life)
            life_count <= 2'd3;
        else
            life_count <= next_life_count;
    end

    //death animation timer
    logic [6:0] next_death_time;
    logic reset_death_time;
    always_ff @ (posedge Clk) begin
        if(Reset || reset_death_time)
            death_time <= 7'd100;
        else
            death_time <= next_death_time;
    end
    
    //powered up timer
    logic [8:0] next_timer_powered_up;
    logic reset_powered_up;
    always_ff @ (posedge Clk) begin
        if(Reset || reset_powered_up || hold)
            timer_powered_up <= 9'd511;
        else
            timer_powered_up <= next_timer_powered_up;
    end
    
    //scared register
    logic [3:0] next_scared;
    logic reset_scared, set_scared;
    always_ff @ (posedge Clk) begin
        if(Reset || reset_scared || hold || game_ended)
            scared <= 4'b0000;
        else if(set_scared)
            scared <= 4'b1111;
        else 
            scared <= next_scared;
    end
    
    //map flash timer
    logic [8:0] next_map_flash_timer;
    logic reset_map_flash_timer;
    always_ff @ (posedge Clk) begin
        if(Reset || reset_map_flash_timer)
            map_flash_timer <= 9'd150;
        else
            map_flash_timer <= next_map_flash_timer;
    end

    //collison flag register
    logic collided_flag, next_collided_flag;
    logic reset_collided_flag;
    always_ff @ (posedge Clk) begin
        if(Reset || reset_collided_flag)
            collided_flag <= 1'b0;
        else
            collided_flag <= next_collided_flag;
    end
    int DistX_Cyan_Pac, DistX_Orange_Pac, DistX_Pink_Pac, DistX_Red_Pac,
        DistY_Cyan_Pac, DistY_Orange_Pac, DistY_Pink_Pac, DistY_Red_Pac,
        Dist_Cyan_Pac, Dist_Orange_Pac, Dist_Pink_Pac, Dist_Red_Pac,
        PacX, PacY,
        CyanX, CyanY,
        OrangeX, OrangeY,
        PinkX, PinkY,
        RedX, RedY,
        collision_distance_int;
    
    parameter [7:0] collision_distance = 8'd64; 
    always_comb begin
        collision_distance_int = collision_distance;

        PacX    = PacX_Monitor;
        PacY    = PacY_Monitor;
        CyanX   = CyanGhostX_Monitor;
        CyanY   = CyanGhostY_Monitor;
        OrangeX = OrangeGhostX_Monitor;
        OrangeY = OrangeGhostY_Monitor;
        PinkX   = PinkGhostX_Monitor;
        PinkY   = PinkGhostY_Monitor;
        RedX    = RedGhostX_Monitor;
        RedY    = RedGhostY_Monitor;
        
        DistX_Cyan_Pac   = PacX - CyanX;
        DistX_Orange_Pac = PacX - OrangeX;
        DistX_Pink_Pac   = PacX - PinkX;
        DistX_Red_Pac    = PacX - RedX;

        DistY_Cyan_Pac   = PacY - CyanY;
        DistY_Orange_Pac = PacY - OrangeY;
        DistY_Pink_Pac   = PacY - PinkY;
        DistY_Red_Pac    = PacY - RedY;

        Dist_Cyan_Pac   = (DistX_Cyan_Pac*DistX_Cyan_Pac) + (DistY_Cyan_Pac*DistY_Cyan_Pac);
        Dist_Orange_Pac = (DistX_Orange_Pac*DistX_Orange_Pac) + (DistY_Orange_Pac*DistY_Orange_Pac);
        Dist_Pink_Pac   = (DistX_Pink_Pac*DistX_Pink_Pac) + (DistY_Pink_Pac*DistY_Pink_Pac);
        Dist_Red_Pac    = (DistX_Red_Pac*DistX_Red_Pac) + (DistY_Red_Pac*DistY_Red_Pac);
    end
endmodule 