module innerwallChecker  (input [9:0] x, y,
                          input 		  is_killer,
                          output      is_inner_wall);
    always_comb begin
      if(is_killer == 1'b1) //if in killer mode, ignore these walls
        is_inner_wall = 1'b0;
      else if(x <= 10'd118 || x >= 10'd394 || y <= 10'd91 || y >= 10'd292)
				is_inner_wall = 1'b1;
      else
        is_inner_wall = 1'b0; //if it's not a wall, then it must be a path
    end
endmodule 