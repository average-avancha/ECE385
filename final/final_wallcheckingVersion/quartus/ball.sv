//-------------------------------------------------------------------------
//    Pac.sv                                                            --
//    Viral Mehta                                                        --
//    Spring 2005                                                        --
//                                                                       --
//    Modified by Stephen Kempf 03-01-2006                               --
//                              03-12-2007                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  12-08-2017                               --
//    Spring 2018 Distribution                                           --
//                                                                       --
//    For use with ECE 385 Lab 8                                         --
//    UIUC ECE Department                                                --
//-------------------------------------------------------------------------


module  Pac ( input         Clk,                // 50 MHz clock
                             Reset,              // Active-high reset signal
                             frame_clk,          // The clock indicating a new frame (~60Hz)
					input [7:0]	  keycode, 				 // WASD codes
               input [9:0]   DrawX, DrawY,       // Current pixel coordinates
               output logic  is_Pac             // Whether current pixel belongs to Pac or background
              );
    
    parameter [9:0] Pac_X_Center = 10'd320;  // Center position on the X axis
    parameter [9:0] Pac_Y_Center = 10'd240;  // Center position on the Y axis
    parameter [9:0] Pac_X_Min = 10'd64;      // Leftmost point on the X axis
    parameter [9:0] Pac_X_Max = 10'd576;     // Rightmost point on the X axis
    parameter [9:0] Pac_Y_Min = 10'd48;       // Topmost point on the Y axis
    parameter [9:0] Pac_Y_Max = 10'd288;     // Bottommost point on the Y axis
    parameter [9:0] Pac_X_Step = 10'd1;      // Step size on the X axis
    parameter [9:0] Pac_Y_Step = 10'd1;      // Step size on the Y axis
    
    logic [9:0] Pac_X_Pos, Pac_X_Motion, Pac_Y_Pos, Pac_Y_Motion;
    logic [9:0] Pac_X_Pos_in, Pac_X_Motion_in, Pac_Y_Pos_in, Pac_Y_Motion_in;
    
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
        end
        else
        begin
            Pac_X_Pos <= Pac_X_Pos_in;
            Pac_Y_Pos <= Pac_Y_Pos_in;
            Pac_X_Motion <= Pac_X_Motion_in;
            Pac_Y_Motion <= Pac_Y_Motion_in;
        end
    end
    //////// Do not modify the always_ff blocks. ////////
    
    // You need to modify always_comb block.
    always_comb
    begin
        // By default, keep motion and position unchanged
        Pac_X_Pos_in = Pac_X_Pos;
        Pac_Y_Pos_in = Pac_Y_Pos;
        Pac_X_Motion_in = Pac_X_Motion;
        Pac_Y_Motion_in = Pac_Y_Motion;
        
        // Update position and motion only at rising edge of frame clock
        if (frame_clk_rising_edge)
        begin
            // Be careful when using comparators with "logic" datatype because compiler treats 
            //   both sides of the operator as UNSIGNED numbers.
            // e.g. Pac_Y_Pos - Pac_Size <= Pac_Y_Min 
            // If Pac_Y_Pos is 0, then Pac_Y_Pos - Pac_Size will not be -4, but rather a large positive number.
            if( Pac_Y_Pos + Pac_Size >= Pac_Y_Max )  // Pac is at the bottom edge, BOUNCE!
                Pac_Y_Motion_in = (~(Pac_Y_Step) + 1'b1);  // 2's complement.  
            else if ( Pac_Y_Pos <= Pac_Y_Min + Pac_Size )  // Pac is at the top edge, BOUNCE!
                Pac_Y_Motion_in = Pac_Y_Step;
				else if (Pac_X_Pos + Pac_Size >= Pac_X_Max)//right
					 Pac_X_Motion_in = (~(Pac_X_Step) + 1'b1); 
			   else if (Pac_X_Pos <= Pac_X_Min + Pac_Size)//left
					 Pac_X_Motion_in = Pac_X_Step;
				
				//'W' is pressed, Pac should go up
				if(keycode == 8'h1A) begin
					Pac_X_Motion_in = 10'd0;
					Pac_Y_Motion_in = (~(Pac_Y_Step) + 1'b1);
					if ( Pac_Y_Pos <= Pac_Y_Min + Pac_Size )  // Pac is at the top edge, BOUNCE!
						Pac_Y_Motion_in = Pac_Y_Step;
				end
				
				//'A' is pressed, Pac should go left
				else if(keycode == 8'h04) begin
					Pac_Y_Motion_in = 10'd0;
					Pac_X_Motion_in = (~(Pac_X_Step) + 1'b1);
					if (Pac_X_Pos <= Pac_X_Min + Pac_Size)//left
						Pac_X_Motion_in = Pac_X_Step;
				end
				
				//'S' is pressed, Pac should go down
				else if(keycode == 8'h16) begin
					Pac_X_Motion_in = 10'd0;
					Pac_Y_Motion_in = Pac_Y_Step;
					if( Pac_Y_Pos + Pac_Size >= Pac_Y_Max )  // Pac is at the bottom edge, BOUNCE!
						Pac_Y_Motion_in = (~(Pac_Y_Step) + 1'b1);  // 2's complement. 					
				end
				
				//'D' is pressed, Pac should go right
				else if (keycode == 8'h07) begin
					Pac_Y_Motion_in = 10'd0;
					Pac_X_Motion_in = Pac_X_Step;
					if (Pac_X_Pos + Pac_Size >= Pac_X_Max)//right
						Pac_X_Motion_in = (~(Pac_X_Step) + 1'b1);
				end
				
            // Update the Pac's position with its motion
            Pac_X_Pos_in = Pac_X_Pos + Pac_X_Motion;
            Pac_Y_Pos_in = Pac_Y_Pos + Pac_Y_Motion;
        end
    end
	 
    int DistX, DistY, Size;
    assign DistX = DrawX - Pac_X_Pos;
    assign DistY = DrawY - Pac_Y_Pos;
    assign Size = Pac_Size;
    always_comb begin
        if () 
            is_Pac = 1'b1;
        else
            is_Pac = 1'b0;
    end
    
endmodule
