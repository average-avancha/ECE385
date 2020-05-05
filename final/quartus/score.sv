module score   (input Clk, Reset,
				input increment_score_dot, increment_score_ghost, increment_score_powdot, reset_score, game_ended,
				output [19:0] current_score, current_highscore);

	logic [19:0] next_score;
	//current score register
	always_ff @ (posedge Clk) begin
		if(Reset || reset_score) 
			current_score <= 20'd0;
		else
			current_score <= next_score;
	end

	//highscore register
	always_ff @ (posedge Clk) begin
		if(Reset) 
			current_highscore <= 20'd0;
		else if(current_score > current_highscore && game_ended == 1'b1)
			current_highscore <= current_score;
	end

	always_comb begin
		next_score = current_score; 
		if(increment_score_dot)
			next_score = current_score + 20'd10;
		if(increment_score_powdot)
			next_score = current_score + 20'd50;
		if(increment_score_ghost)
			next_score = current_score + 20'd200;
	end
endmodule 

// int score = current_score;
// int highscore = current_highscore;

// 123456789
// 9 --> 123456789/1 %10
// 8 --> 123456789/10 %10
// 7 --> 123456789/100 %10
// 6 --> 123456789/1000 %10