module pacman_sprite(input          	Clk,                // 50 MHz clock
										Reset,              // Active-high reset signal
										frame_clk,          // The clock indicating a new frame (~60Hz)
                    input  		 [7:0]  keycode, 			  // WASD codes
                    input  		 [9:0]  DrawX, DrawY,       // Current pixel coordinates
                    output logic [9:0]  PacX, PacY,			  // How deep into the sprite the current pixel is
                    output logic   		is_Pac              // Whether current pixel belongs to Pac or background
                    );
    
    parameter [9:0] Pac_X_Center = 10'd320;  // Center position on the X axis
    parameter [9:0] Pac_Y_Center = 10'd240;  // Center position on the Y axis
    parameter [9:0] Pac_X_Min = 10'd64;      // Leftmost point on the X axis
    parameter [9:0] Pac_X_Max = 10'd576;     // Rightmost point on the X axis
    parameter [9:0] Pac_Y_Min = 10'd48;      // Topmost point on the Y axis
    parameter [9:0] Pac_Y_Max = 10'd432;     // Bottommost point on the Y axis
    parameter [9:0] Pac_X_Step = 10'd1;      // Step size on the X axis
    parameter [9:0] Pac_Y_Step = 10'd1;      // Step size on the Y axis
    parameter [9:0] Pac_Size = 10'd6;
    
    logic [9:0] Pac_X_Pos, Pac_X_Motion, Pac_Y_Pos, Pac_Y_Motion;
    logic [9:0] Pac_X_Pos_in, Pac_X_Motion_in, Pac_Y_Pos_in, Pac_Y_Motion_in;
    logic [2:0] direction, next_direction; //registers used for determining sprite in animation
    logic [9:0] Pac_ul_x, Pac_ul_y, Pac_ll_x, Pac_ll_y, Pac_ur_x, Pac_ur_y, Pac_lr_x, Pac_lr_y;
    logic       ul_isWall, ll_isWall, ur_isWall, lr_isWall; 

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
        if (Reset)
        begin
            Pac_X_Pos <= Pac_X_Center;
            Pac_Y_Pos <= Pac_Y_Center;
            Pac_X_Motion <= 10'd0;
            Pac_Y_Motion <= 10'd0;
            direction <= 3'b111; 
        end
        else
        begin
            Pac_X_Pos <= Pac_X_Pos_in;
            Pac_Y_Pos <= Pac_Y_Pos_in;
            Pac_X_Motion <= Pac_X_Motion_in;
            Pac_Y_Motion <= Pac_Y_Motion_in;
            direction <= next_direction;
        end
    end
    //////// Do not modify the always_ff blocks. ////////

    //instansiate wallchecking modules to do collision logic 
    wallChecker UL(.x(Pac_ul_x), .y(Pac_ul_y), .is_wall(ul_isWall));
    wallChecker LL(.x(Pac_ll_x), .y(Pac_ll_y), .is_wall(ll_isWall));
    wallChecker UR(.x(Pac_ur_x), .y(Pac_ur_y), .is_wall(ur_isWall));
    wallChecker LR(.x(Pac_lr_x), .y(Pac_lr_y), .is_wall(lr_isWall));
    always_comb begin
        //by default, position/motion of pacman remains unchanged 
        Pac_X_Pos_in = Pac_X_Pos;
        Pac_Y_Pos_in = Pac_Y_Pos;
        Pac_X_Motion_in = Pac_X_Motion;
        Pac_Y_Motion_in = Pac_Y_Motion;
        next_direction = direction;
        //update corner coordinates of the pacman sprite 
        Pac_ul_x = Pac_X_Pos - 10'd8 - 10'd64;
        Pac_ul_y = Pac_Y_Pos - 10'd8 - 10'd48;
        Pac_ll_x = Pac_X_Pos - 10'd8 - 10'd64;
        Pac_ll_y = Pac_Y_pos + 10'd7 - 10'd48;
        Pac_ur_x = Pac_X_Pos + 10'd7 - 10'd64;
        Pac_ur_y = Pac_Y_Pos - 10'd8 - 10'd48;
        Pac_lr_x = Pac_X_Pos + 10'd7 - 10'd64;
        Pac_lr_y = Pac_Y_pos + 10'd7 - 10'd48;
        //update position and motion only at rising edge of frame clock 
        if(frame_clk_rising_edge) begin
            //000 = up, 001 = left, 010 = down, 011 = right, otherwise stay still
            case(direction)
                3'b000: begin
                    if(ul_isWall == 1'b1 || ur_isWall == 1'b1) begin
                        Pac_X_Motion_in = 10'd0;
                        Pac_Y_Motion_in = 10'd0;
                        next_direction = 3'b111;
                    end
                    else begin
                        Pac_X_Motion_in = 10'd0;
                        Pac_Y_Motion_in = (~(Pac_Y_Step) + 1'b1);
                    end
                end
                3'b001: begin
                    if(ul_isWall == 1'b1 || ll_isWall == 1'b1) begin
                        Pac_X_Motion_in = 10'd0;
                        Pac_Y_Motion_in = 10'd0;    
                        next_direction = 3'b111;
                    end
                    else begin
                        Pac_X_Motion_in = ((~Pac_X_Step) + 1'b1);
                        Pac_Y_Motion_in = 10'd0;
                    end
                end
                3'b010: begin
                    if(ll_isWall == 1'b1 || lr_isWall == 1'b1) begin
                        Pac_X_Motion_in = 10'd0;
                        Pac_Y_Motion_in = 10'd0;
                        next_direction = 3'b111;
                    end
                    else begin
                        Pac_X_Motion_in = 10'd0;
                        Pac_Y_Motion_in = Pac_Y_Step;
                    end
                end
                3'b011: begin
                    if(ur_isWall == 1'b1 || lr_isWall == 1'b1) begin
                        Pac_X_Motion_in = 10'd0;
                        Pac_Y_Motion_in = 10'd0;   
                        next_direction = 3'b111;
                    end
                    else begin
                        Pac_X_Motion_in = Pac_X_Step;
                        Pac_Y_Motion_in = 10'd0;
                    end
                end
                default: begin
                    Pac_X_Motion_in = 10'd0;
                    Pac_Y_Motion_in = 10'd0;
                end                              
            endcase
            //handle key presses
            //"W" is pressed, attempt to move up
            if(keycode == 8'h1A) begin 
                if(direction == 3'b001 || direction == 3'b011) begin //currently moving horizontally, check to see if we can move updward
                    if(ur_isWall == 1'b0 && ul_isWall == 1'b0) begin //we can move upward, if we can't then don't update the motion or direction
                        next_direction = 3'b000;
                        Pac_X_Motion_in = 10'd0;
                        Pac_Y_Motion_in = (~(Pac_Y_Step) + 1'b1);
                    end
                end
                else begin //currently moving vertically
                    Pac_X_Motion_in = 10'd0;
                    Pac_Y_Motion_in = (~(Pac_Y_Step) + 1'b1);
                    //if we press "W" and and we hit a wall while moving vertically, then we stop moving, otherwise keep the motion and direction same
                    if(ur_isWall == 1'b1 || ul_isWall == 1'b1) begin
                        next_direction = 3'b111; 
                        Pac_X_Motion_in = 10'd0;
                        Pac_Y_Motion_in = 10'd0;
                    end
                end
            end
            //"A" is pressed, attempt to move left
            else if (keycode == 8'h04) begin
                if(direction == 3'b000 || direction == 3'b010) begin //currently moving vertically, check to see if we can move left
                    if(ul_isWall == 1'b0 && ll_isWall == 1'b0) begin //we can move left, if we can't then don't update the motion or direction
                        next_direction = 3'b001; 
                        Pac_X_Motion_in = (~(Pac_X_Step) + 1'b1);
                        Pac_Y_Motion_in = 10'd0;
                    end
                end
                else begin //currently moving horizontally
                    Pac_X_Motion_in = ((~Pac_X_Step) + 1'b1);
                    Pac_Y_Motion_in = 10'd0;
                    //if we press "A" and we hit a wall while moving horizontally, then we stop moving, otherwise keep the motion and direction same
                    if(ul_isWall == 1'b1 || ll_isWall == 1'b1) begin
                        next_direction = 3'b111;
                        Pac_X_Motion_in = 10'd0;
                        Pac_Y_Motion_in = 10'd0;
                    end
                end
            end
            //"S" is pressed, attempt to move downward
            else if (keycode == 8'h16) begin
                if(direction == 3'b001 || direction == 3'b011) begin //currently moving horizontally, check to see if we can move updward
                    if(lr_isWall == 1'b0 && ll_isWall == 1'b0) begin //we can move downward, if we can't then don't update the motion or direction
                        next_direction = 3'b010;
                        Pac_X_Motion_in = 10'd0;
                        Pac_Y_Motion_in = Pac_Y_Step;
                    end
                end
                else begin //currently moving vertically
                    Pac_X_Motion_in = 10'd0;
                    Pac_Y_Motion_in = Pac_Y_Step;
                    //if we press "S" and and we hit a wall while moving vertically, then we stop moving, otherwise keep the motion and direction same
                    if(lr_isWall == 1'b1 || ll_isWall == 1'b1) begin
                        next_direction = 3'b111; 
                        Pac_X_Motion_in = 10'd0;
                        Pac_Y_Motion_in = 10'd0;
                    end
                end
            end
            //"D" is pressed, attempt to move right
            else if (keycode == 8'h07) begin
                if(direction == 3'b000 || direction == 3'b010) begin //currently moving vertically, check to see if we can move right
                    if(ur_isWall == 1'b0 && lr_isWall == 1'b0) begin //we can move right, if we can't then don't update the motion or direction
                        next_direction = 3'b011; 
                        Pac_X_Motion_in = Pac_X_Step;
                        Pac_Y_Motion_in = 10'd0;
                    end
                end
                else begin //currently moving horizontally
                    Pac_X_Motion_in = Pac_X_Step;
                    Pac_Y_Motion_in = 10'd0;
                    //if we press "D" and we hit a wall while moving horizontally, then we stop moving, otherwise keep the motion and direction same
                    if(ul_isWall == 1'b1 || ll_isWall == 1'b1) begin
                        next_direction = 3'b111;
                        Pac_X_Motion_in = 10'd0;
                        Pac_Y_Motion_in = 10'd0;
                    end
                end
            end
            //Update the Pacman's position with its motion
            Pac_X_Pos_in = Pac_X_Pos + Pac_X_Motion;
            Pac_Y_Pos_in = Pac_Y_Pos + Pac_Y_Motion;
        end
    end
    //determine whether the DrawX and DrawY a pacman coordinate 
    assign PacX = DrawX - Pac_X_Pos + 10'd8;
    assign PacY = DrawY - Pac_Y_Pos + 10'd8;    
    always_comb begin
        if (PacX >= 10'd0 && PacX < 10'd16 && PacY >= 10'd0 && PacY < 10'd16) 
            is_Pac = 1'b1;
        else
            is_Pac = 1'b0;
    end
endmodule
