module dot_handler (input 			        Clk, Reset, frame_clk_rising_edge,
                                            reset_dots, reload,
					input  		 [9:0]      DrawX, DrawY,
					input  		 [9:0]	    PacX_Monitor, PacY_Monitor,
					output logic 		    is_dot, increment_score_dot, increment_score_powdot,
					output logic [7:0]      dot_count);
	
	parameter [7:0] number_of_dots = 8'd25;
	parameter [9:0] MapX_Zero = 10'd64 + 10'd1; 
	parameter [9:0] MapY_Zero = 10'd48 + 10'd1;
	parameter [9:0] Radius = 10'd2;
	parameter [9:0] PowDotRadius = 10'd4;

	logic [7:0] next_dot_count;
	logic [255:0] eaten_status, next_eaten_status;
	
	//register to keep track of any change in dots
	always_ff @ (posedge Clk) begin
		if (Reset || reset_dots) begin
			eaten_status <= 256'd0;
			dot_count <= number_of_dots;
		end
		else begin
			eaten_status <= next_eaten_status;
			dot_count <= next_dot_count;
        end
	end

	logic [3:0] powdot_eaten_status, next_powdot_eaten_status;
	//register to keep track of any change in pow_dots
	always_ff @ (posedge Clk) begin
		if (Reset || reset_dots)
			powdot_eaten_status <= 4'd0;
		else
			powdot_eaten_status <= next_powdot_eaten_status;
	end

	logic [4:0] blink, next_blink;
	always_ff @ (posedge Clk) begin
		if(Reset || reset_dots || reload)
			blink <= 5'd0;
		else
			blink <= next_blink;
	end
	
	//if any change in dot status, increment score
	always_comb begin
		//draw dot pixel
		is_dot = ((is_dot_ != 256'd0) || ((is_powdot_ != 4'd0) && (blink <= 5'd15))) ? 1'b1 : 1'b0;
		
		next_blink = blink;
		//blinking combinational logic
		if(frame_clk_rising_edge) begin
			if(blink == 5'd30)
				next_blink = 5'd0;
			else
				next_blink = blink + 5'd1;
		end
		//score combinational logic
		if(next_eaten_status != eaten_status) begin
			increment_score_dot = 1'b1;
			increment_score_powdot = 1'b0;
			next_dot_count = dot_count - 8'd1;
		end
		else if(next_powdot_eaten_status != powdot_eaten_status) begin
			increment_score_dot = 1'b0;
			increment_score_powdot = 1'b1;
			next_dot_count = dot_count - 8'b1;
		end
		else begin
			increment_score_dot = 1'b0;
			increment_score_powdot = 1'b0;
			next_dot_count = dot_count;
		end	
	end
	
	logic [255:0] is_eaten, is_dot_;
	logic [3:0]   is_powdot_eaten, is_powdot_;
	
	//Pow Dots
	dot 			#(.DotX_Center(10'd54  + MapX_Zero), .DotY_Center(10'd39 + MapY_Zero), .Dot_Radius(PowDotRadius)) 
		Pow_dot_UL  (.Clk, .Reset, .reset_dots, .DrawX, .DrawY, .PacX_Monitor, .PacY_Monitor, .is_dot(is_powdot_[0]), .is_eaten(next_powdot_eaten_status[0]));
	dot 			#(.DotX_Center(10'd458  + MapX_Zero), .DotY_Center(10'd39 + MapY_Zero), .Dot_Radius(PowDotRadius)) 
		Pow_dot_UR  (.Clk, .Reset, .reset_dots, .DrawX, .DrawY, .PacX_Monitor, .PacY_Monitor, .is_dot(is_powdot_[1]), .is_eaten(next_powdot_eaten_status[1]));
	dot 			#(.DotX_Center(10'd54  + MapX_Zero), .DotY_Center(10'd339 + MapY_Zero), .Dot_Radius(PowDotRadius)) 
		Pow_dot_DL  (.Clk, .Reset, .reset_dots, .DrawX, .DrawY, .PacX_Monitor, .PacY_Monitor, .is_dot(is_powdot_[2]), .is_eaten(next_powdot_eaten_status[2]));
	dot 			#(.DotX_Center(10'd458  + MapX_Zero), .DotY_Center(10'd339 + MapY_Zero), .Dot_Radius(PowDotRadius)) 
		Pow_dot_DR  (.Clk, .Reset, .reset_dots, .DrawX, .DrawY, .PacX_Monitor, .PacY_Monitor, .is_dot(is_powdot_[3]), .is_eaten(next_powdot_eaten_status[3]));
	//Path 1
//	dot 			#(.DotX_Center(10'd31  + MapX_Zero), .DotY_Center(10'd16 + MapY_Zero), .Dot_Radius(Radius)) 
//		dot_31_16  (.Clk, .Reset, .reset_dots, .DrawX, .DrawY, .PacX_Monitor, .PacY_Monitor, .is_dot(is_dot_[0]), .is_eaten(next_eaten_status[0]));
//	dot 			#(.DotX_Center(10'd31  + MapX_Zero), .DotY_Center(10'd39 + MapY_Zero), .Dot_Radius(Radius)) 
//		dot_31_39  (.Clk, .Reset, .reset_dots, .DrawX, .DrawY, .PacX_Monitor, .PacY_Monitor, .is_dot(is_dot_[1]), .is_eaten(next_eaten_status[1]));
//	dot 			#(.DotX_Center(10'd31  + MapX_Zero), .DotY_Center(10'd64 + MapY_Zero), .Dot_Radius(Radius)) 
//		dot_31_64  (.Clk, .Reset, .reset_dots, .DrawX, .DrawY, .PacX_Monitor, .PacY_Monitor, .is_dot(is_dot_[2]), .is_eaten(next_eaten_status[2]));
//	dot 			#(.DotX_Center(10'd31  + MapX_Zero), .DotY_Center(10'd89 + MapY_Zero), .Dot_Radius(Radius)) 
//		dot_31_89  (.Clk, .Reset, .reset_dots, .DrawX, .DrawY, .PacX_Monitor, .PacY_Monitor, .is_dot(is_dot_[3]), .is_eaten(next_eaten_status[3]));
//	dot 			#(.DotX_Center(10'd31  + MapX_Zero), .DotY_Center(10'd114 + MapY_Zero), .Dot_Radius(Radius)) 
//		dot_31_114  (.Clk, .Reset, .reset_dots, .DrawX, .DrawY, .PacX_Monitor, .PacY_Monitor, .is_dot(is_dot_[4]), .is_eaten(next_eaten_status[4]));
//	dot 			#(.DotX_Center(10'd31  + MapX_Zero), .DotY_Center(10'd139 + MapY_Zero), .Dot_Radius(Radius)) 
//		dot_31_139  (.Clk, .Reset, .reset_dots, .DrawX, .DrawY, .PacX_Monitor, .PacY_Monitor, .is_dot(is_dot_[5]), .is_eaten(next_eaten_status[5]));
//	dot 			#(.DotX_Center(10'd31  + MapX_Zero), .DotY_Center(10'd164 + MapY_Zero), .Dot_Radius(Radius)) 
//		dot_31_164  (.Clk, .Reset, .reset_dots, .DrawX, .DrawY, .PacX_Monitor, .PacY_Monitor, .is_dot(is_dot_[6]), .is_eaten(next_eaten_status[6]));
//	dot 			#(.DotX_Center(10'd31  + MapX_Zero), .DotY_Center(10'd189 + MapY_Zero), .Dot_Radius(Radius)) 
//		dot_31_189  (.Clk, .Reset, .reset_dots, .DrawX, .DrawY, .PacX_Monitor, .PacY_Monitor, .is_dot(is_dot_[7]), .is_eaten(next_eaten_status[7]));
//	dot 			#(.DotX_Center(10'd31  + MapX_Zero), .DotY_Center(10'd214 + MapY_Zero), .Dot_Radius(Radius)) 
//		dot_31_214  (.Clk, .Reset, .reset_dots, .DrawX, .DrawY, .PacX_Monitor, .PacY_Monitor, .is_dot(is_dot_[8]), .is_eaten(next_eaten_status[8]));
//	dot 			#(.DotX_Center(10'd31  + MapX_Zero), .DotY_Center(10'd239 + MapY_Zero), .Dot_Radius(Radius)) 
//		dot_31_239  (.Clk, .Reset, .reset_dots, .DrawX, .DrawY, .PacX_Monitor, .PacY_Monitor, .is_dot(is_dot_[9]), .is_eaten(next_eaten_status[9]));
//	dot 			#(.DotX_Center(10'd31  + MapX_Zero), .DotY_Center(10'd264 + MapY_Zero), .Dot_Radius(Radius)) 
//		dot_31_264  (.Clk, .Reset, .reset_dots, .DrawX, .DrawY, .PacX_Monitor, .PacY_Monitor, .is_dot(is_dot_[10]), .is_eaten(next_eaten_status[10]));
//	dot 			#(.DotX_Center(10'd31  + MapX_Zero), .DotY_Center(10'd289 + MapY_Zero), .Dot_Radius(Radius)) 
//		dot_31_289  (.Clk, .Reset, .reset_dots, .DrawX, .DrawY, .PacX_Monitor, .PacY_Monitor, .is_dot(is_dot_[11]), .is_eaten(next_eaten_status[11]));
//	dot 			#(.DotX_Center(10'd31  + MapX_Zero), .DotY_Center(10'd314 + MapY_Zero), .Dot_Radius(Radius)) 
//		dot_31_314  (.Clk, .Reset, .reset_dots, .DrawX, .DrawY, .PacX_Monitor, .PacY_Monitor, .is_dot(is_dot_[12]), .is_eaten(next_eaten_status[12]));
//	dot 			#(.DotX_Center(10'd31  + MapX_Zero), .DotY_Center(10'd339 + MapY_Zero), .Dot_Radius(Radius)) 
//		dot_31_339  (.Clk, .Reset, .reset_dots, .DrawX, .DrawY, .PacX_Monitor, .PacY_Monitor, .is_dot(is_dot_[13]), .is_eaten(next_eaten_status[13]));
//	dot 			#(.DotX_Center(10'd31  + MapX_Zero), .DotY_Center(10'd362 + MapY_Zero), .Dot_Radius(Radius)) 
//		dot_31_362  (.Clk, .Reset, .reset_dots, .DrawX, .DrawY, .PacX_Monitor, .PacY_Monitor, .is_dot(is_dot_[14]), .is_eaten(next_eaten_status[14]));
	//Path 2
	// dot 			#(.DotX_Center(10'd54  + MapX_Zero), .DotY_Center(10'd39 + MapY_Zero), .Dot_Radius(Radius)) 
	// 	dot_54_39  (.Clk, .Reset, .reset_dots, .DrawX, .DrawY, .PacX_Monitor, .PacY_Monitor, .is_dot(is_dot_[15]), .is_eaten(next_eaten_status[15]));
	dot 			#(.DotX_Center(10'd54  + MapX_Zero), .DotY_Center(10'd64 + MapY_Zero), .Dot_Radius(Radius)) 
		dot_54_64  (.Clk, .Reset, .reset_dots, .DrawX, .DrawY, .PacX_Monitor, .PacY_Monitor, .is_dot(is_dot_[16]), .is_eaten(next_eaten_status[16]));
	dot 			#(.DotX_Center(10'd54  + MapX_Zero), .DotY_Center(10'd89 + MapY_Zero), .Dot_Radius(Radius)) 
		dot_54_89  (.Clk, .Reset, .reset_dots, .DrawX, .DrawY, .PacX_Monitor, .PacY_Monitor, .is_dot(is_dot_[17]), .is_eaten(next_eaten_status[17]));
	dot 			#(.DotX_Center(10'd54  + MapX_Zero), .DotY_Center(10'd114 + MapY_Zero), .Dot_Radius(Radius)) 
		dot_54_114  (.Clk, .Reset, .reset_dots, .DrawX, .DrawY, .PacX_Monitor, .PacY_Monitor, .is_dot(is_dot_[18]), .is_eaten(next_eaten_status[18]));
	dot 			#(.DotX_Center(10'd54  + MapX_Zero), .DotY_Center(10'd139 + MapY_Zero), .Dot_Radius(Radius)) 
		dot_54_139  (.Clk, .Reset, .reset_dots, .DrawX, .DrawY, .PacX_Monitor, .PacY_Monitor, .is_dot(is_dot_[19]), .is_eaten(next_eaten_status[19]));
	dot 			#(.DotX_Center(10'd54  + MapX_Zero), .DotY_Center(10'd164 + MapY_Zero), .Dot_Radius(Radius)) 
		dot_54_164  (.Clk, .Reset, .reset_dots, .DrawX, .DrawY, .PacX_Monitor, .PacY_Monitor, .is_dot(is_dot_[20]), .is_eaten(next_eaten_status[20]));
	dot 			#(.DotX_Center(10'd54  + MapX_Zero), .DotY_Center(10'd189 + MapY_Zero), .Dot_Radius(Radius)) 
		dot_54_189  (.Clk, .Reset, .reset_dots, .DrawX, .DrawY, .PacX_Monitor, .PacY_Monitor, .is_dot(is_dot_[21]), .is_eaten(next_eaten_status[21]));
	dot 			#(.DotX_Center(10'd54  + MapX_Zero), .DotY_Center(10'd214 + MapY_Zero), .Dot_Radius(Radius)) 
		dot_54_214  (.Clk, .Reset, .reset_dots, .DrawX, .DrawY, .PacX_Monitor, .PacY_Monitor, .is_dot(is_dot_[22]), .is_eaten(next_eaten_status[22]));
	dot 			#(.DotX_Center(10'd54  + MapX_Zero), .DotY_Center(10'd239 + MapY_Zero), .Dot_Radius(Radius)) 
		dot_54_239  (.Clk, .Reset, .reset_dots, .DrawX, .DrawY, .PacX_Monitor, .PacY_Monitor, .is_dot(is_dot_[23]), .is_eaten(next_eaten_status[23]));
	dot 			#(.DotX_Center(10'd54  + MapX_Zero), .DotY_Center(10'd264 + MapY_Zero), .Dot_Radius(Radius)) 
		dot_54_264  (.Clk, .Reset, .reset_dots, .DrawX, .DrawY, .PacX_Monitor, .PacY_Monitor, .is_dot(is_dot_[24]), .is_eaten(next_eaten_status[24]));
	dot 			#(.DotX_Center(10'd54  + MapX_Zero), .DotY_Center(10'd289 + MapY_Zero), .Dot_Radius(Radius)) 
		dot_54_289  (.Clk, .Reset, .reset_dots, .DrawX, .DrawY, .PacX_Monitor, .PacY_Monitor, .is_dot(is_dot_[25]), .is_eaten(next_eaten_status[25]));
	dot 			#(.DotX_Center(10'd54  + MapX_Zero), .DotY_Center(10'd314 + MapY_Zero), .Dot_Radius(Radius)) 
		dot_54_314  (.Clk, .Reset, .reset_dots, .DrawX, .DrawY, .PacX_Monitor, .PacY_Monitor, .is_dot(is_dot_[26]), .is_eaten(next_eaten_status[26]));
//	dot 			#(.DotX_Center(10'd54  + MapX_Zero), .DotY_Center(10'd339 + MapY_Zero), .Dot_Radius(Radius)) 
//		dot_54_339  (.Clk, .Reset, .reset_dots, .DrawX, .DrawY, .PacX_Monitor, .PacY_Monitor, .is_dot(is_dot_[27]), .is_eaten(next_eaten_status[27]));
	//Path 3
//	dot 			#(.DotX_Center(10'd54  + MapX_Zero), .DotY_Center(10'd16 + MapY_Zero), .Dot_Radius(Radius)) 
//		dot_54_16  (.Clk, .Reset, .reset_dots, .DrawX, .DrawY, .PacX_Monitor, .PacY_Monitor, .is_dot(is_dot_[28]), .is_eaten(next_eaten_status[28]));
//	dot 			#(.DotX_Center(10'd81  + MapX_Zero), .DotY_Center(10'd16 + MapY_Zero), .Dot_Radius(Radius)) 
//		dot_81_16  (.Clk, .Reset, .reset_dots, .DrawX, .DrawY, .PacX_Monitor, .PacY_Monitor, .is_dot(is_dot_[29]), .is_eaten(next_eaten_status[29]));
//	dot 			#(.DotX_Center(10'd106  + MapX_Zero), .DotY_Center(10'd16 + MapY_Zero), .Dot_Radius(Radius)) 
//		dot_106_16  (.Clk, .Reset, .reset_dots, .DrawX, .DrawY, .PacX_Monitor, .PacY_Monitor, .is_dot(is_dot_[30]), .is_eaten(next_eaten_status[30]));
	//Between Path 3 & 4
//	dot 			#(.DotX_Center(10'd125  + MapX_Zero), .DotY_Center(10'd28 + MapY_Zero), .Dot_Radius(Radius)) 
//		dot_125_28  (.Clk, .Reset, .reset_dots, .DrawX, .DrawY, .PacX_Monitor, .PacY_Monitor, .is_dot(is_dot_[31]), .is_eaten(next_eaten_status[31]));
	//Path 4
	dot 			#(.DotX_Center(10'd81  + MapX_Zero), .DotY_Center(10'd39 + MapY_Zero), .Dot_Radius(Radius)) 
		dot_81_39  (.Clk, .Reset, .reset_dots, .DrawX, .DrawY, .PacX_Monitor, .PacY_Monitor, .is_dot(is_dot_[32]), .is_eaten(next_eaten_status[32]));
	dot 			#(.DotX_Center(10'd106  + MapX_Zero), .DotY_Center(10'd39 + MapY_Zero), .Dot_Radius(Radius)) 
		dot_106_39  (.Clk, .Reset, .reset_dots, .DrawX, .DrawY, .PacX_Monitor, .PacY_Monitor, .is_dot(is_dot_[33]), .is_eaten(next_eaten_status[33]));
	//Path 5
	dot 			#(.DotX_Center(10'd81  + MapX_Zero), .DotY_Center(10'd64 + MapY_Zero), .Dot_Radius(Radius)) 
		dot_81_64  (.Clk, .Reset, .reset_dots, .DrawX, .DrawY, .PacX_Monitor, .PacY_Monitor, .is_dot(is_dot_[34]), .is_eaten(next_eaten_status[34]));
	dot 			#(.DotX_Center(10'd106  + MapX_Zero), .DotY_Center(10'd64 + MapY_Zero), .Dot_Radius(Radius)) 
		dot_106_64  (.Clk, .Reset, .reset_dots, .DrawX, .DrawY, .PacX_Monitor, .PacY_Monitor, .is_dot(is_dot_[35]), .is_eaten(next_eaten_status[35]));
	dot 			#(.DotX_Center(10'd131  + MapX_Zero), .DotY_Center(10'd64 + MapY_Zero), .Dot_Radius(Radius)) 
		dot_131_64  (.Clk, .Reset, .reset_dots, .DrawX, .DrawY, .PacX_Monitor, .PacY_Monitor, .is_dot(is_dot_[36]), .is_eaten(next_eaten_status[36]));
	dot 			#(.DotX_Center(10'd156  + MapX_Zero), .DotY_Center(10'd64 + MapY_Zero), .Dot_Radius(Radius)) 
		dot_156_64  (.Clk, .Reset, .reset_dots, .DrawX, .DrawY, .PacX_Monitor, .PacY_Monitor, .is_dot(is_dot_[37]), .is_eaten(next_eaten_status[37]));
	dot 			#(.DotX_Center(10'd181  + MapX_Zero), .DotY_Center(10'd64 + MapY_Zero), .Dot_Radius(Radius)) 
		dot_181_64  (.Clk, .Reset, .reset_dots, .DrawX, .DrawY, .PacX_Monitor, .PacY_Monitor, .is_dot(is_dot_[38]), .is_eaten(next_eaten_status[38]));
	dot 			#(.DotX_Center(10'd206  + MapX_Zero), .DotY_Center(10'd64 + MapY_Zero), .Dot_Radius(Radius)) 
		dot_206_64  (.Clk, .Reset, .reset_dots, .DrawX, .DrawY, .PacX_Monitor, .PacY_Monitor, .is_dot(is_dot_[39]), .is_eaten(next_eaten_status[39]));
	dot 			#(.DotX_Center(10'd231  + MapX_Zero), .DotY_Center(10'd64 + MapY_Zero), .Dot_Radius(Radius)) 
		dot_231_64  (.Clk, .Reset, .reset_dots, .DrawX, .DrawY, .PacX_Monitor, .PacY_Monitor, .is_dot(is_dot_[40]), .is_eaten(next_eaten_status[40]));
	dot 			#(.DotX_Center(10'd255  + MapX_Zero), .DotY_Center(10'd64 + MapY_Zero), .Dot_Radius(Radius)) 
		dot_255_64  (.Clk, .Reset, .reset_dots, .DrawX, .DrawY, .PacX_Monitor, .PacY_Monitor, .is_dot(is_dot_[41]), .is_eaten(next_eaten_status[41]));

//TEST DOTS
//	dot 			#(.DotX_Center(10'd97  + MapX_Zero), .DotY_Center(10'd226 + MapY_Zero), .Dot_Radius(10'd3)) 
//		 dot_97_226 (.Clk, .Reset, .DrawX, .DrawY, .PacX_Monitor, .PacY_Monitor, .is_dot(is_dot_[0]), .is_eaten(next_eaten_status[0]));
//	dot 			#(.DotX_Center(10'd203 + MapX_Zero), .DotY_Center(10'd226 + MapY_Zero), .Dot_Radius(10'd3)) 
//		 dot_203_226 (.Clk, .Reset, .DrawX, .DrawY, .PacX_Monitor, .PacY_Monitor, .is_dot(is_dot_[1]), .is_eaten(next_eaten_status[1]));
//	dot 			#(.DotX_Center(10'd309 + MapX_Zero), .DotY_Center(10'd226 + MapY_Zero), .Dot_Radius(10'd3)) 
//		 dot_309_226 (.Clk, .Reset, .DrawX, .DrawY, .PacX_Monitor, .PacY_Monitor, .is_dot(is_dot_[2]), .is_eaten(next_eaten_status[2]));
//	dot 			#(.DotX_Center(10'd415 + MapX_Zero), .DotY_Center(10'd226 + MapY_Zero), .Dot_Radius(10'd3)) 
//		 dot_415_226 (.Clk, .Reset, .DrawX, .DrawY, .PacX_Monitor, .PacY_Monitor, .is_dot(is_dot_[3]), .is_eaten(next_eaten_status[3]));
	
endmodule 

//Seperate by half the width of Pacman
module dot #([9:0] DotX_Center, [9:0] DotY_Center, [9:0] Dot_Radius)
			  (input 		 Clk, Reset, reset_dots,
				input  [9:0] DrawX, DrawY,
				input  [9:0] PacX_Monitor, PacY_Monitor,
				output logic is_dot,
				output logic is_eaten);
	
	logic 			 next_is_eaten;
//	logic		 [9:0] distX, distY;
	parameter [9:0] eaten_distance = 10'd8;
	
	//Dot is_eaten register
	always_ff @ (posedge Clk) begin
		if (Reset || reset_dots)
			is_eaten <= 1'b0;
		else 
			is_eaten <= next_is_eaten;
	end
	//Dot is_eaten combinational logic
	int PacX_to_dot, PacY_to_dot, eaten_radius;
	assign PacX_to_dot = PacX_Monitor - DotX_Center;
	assign PacY_to_dot = PacY_Monitor - DotY_Center;
	assign eaten_radius = eaten_distance;
	always_comb begin 
		next_is_eaten = is_eaten;
		if((PacX_to_dot*PacX_to_dot + PacY_to_dot*PacY_to_dot) <= (eaten_radius*eaten_radius)) begin //Distance between dot and Pacman is less than 8 pixels
			next_is_eaten = 1'b1;
		end
	end

	int DistX, DistY, radius; 
	assign DistX = DrawX - DotX_Center;
	assign DistY = DrawY - DotY_Center; 
	assign radius = Dot_Radius; 
	//Draw dot combinationl logic
	always_comb begin
		if((DistX*DistX + DistY*DistY) <= (radius*radius) && (is_eaten == 1'b0))
			is_dot = 1'b1;
		else 
			is_dot = 1'b0;
	end
endmodule 