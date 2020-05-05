module wallChecker (input [9:0] x, y,
                    output      is_wall);
    always_comb begin
        //Section of Walls
        //section 1
        if(x <= 10'd24)
            is_wall = 1'b1;
        else if (y <= 10'd10 && x <= 10'd141)
            is_wall = 1'b1;
        else if (x >= 10'd135 && x <= 10'd141 && y <= 10'd57)
            is_wall = 1'b1;
        else if (x >= 10'd64 && x <= 10'd135 && y <= 10'd57 && y >= 10'd49)
            is_wall = 1'b1;
        else if (y >= 10'd372 && x <= 10'd141)
            is_wall = 1'b1;
        else if (x >= 10'd135 && x <= 10'd141 && y >= 10'd327)
            is_wall = 1'b1;
        else if (x >= 10'd64 && x <= 10'd135 && y >= 10'd327 && y <= 10'd383)
            is_wall = 1'b1;
        //section 2
        else if (x >= 10'd41 && x <= 10'd47 && y >= 10'd27 && y <= 10'd183)
            is_wall = 1'b1;
        else if (x >= 10'd47 && x <= 10'd118 && y >= 10'd27 && y <= 10'd32)
            is_wall = 1'b1;
        //section 3
        else if(x >= 10'd64 && x <= 10'd225 && y >= 10'd74 && y <= 10'd91)
            is_wall = 1'b1; 
        else if (x >= 10'd203 && x <= 10'd225 && y >= 10'd91 && y <= 10'd148)
            is_wall = 1'b1;
        else if (x >= 10'd225 && x <= 10'd287 && y >= 10'd124 && y <= 10'd148)
            is_wall = 1'b1; 
        else if (x >= 10'd287 && x <= 10'd309 && y >= 10'd91 && y <= 10'd148)
            is_wall = 1'b1;
        else if (x >= 10'd287 && x <= 10'd448 && y >= 10'd74 && y <= 10'd91)
            is_wall = 1'b1; 
        //section 4
        else if (x >= 10'd64 && x <= 10'd118 && y >= 10'd108 && y <= 10'd148)
            is_wall = 1'b1; 
        //section 5
        else if (x >= 10'd135 && x <= 10'd186 && y >= 10'd108 && y <= 10'd148)
            is_wall = 1'b1; 
        //section 6/7 (labelled differently on diagram on accident but is the same block)
        else if (x >= 10'd64 && x <= 10'd186 && y >= 10'd165 && y <= 10'd218)
            is_wall = 1'b1;
        //section 8
        else if (x >= 10'd64 && x <= 10'd118 && y >= 10'd235 && y <= 10'd275)
            is_wall = 1'b1; 
        //section 9
        else if (x >= 10'd135 && x <= 10'd186 && y >= 10'd235 && y <= 10'd275)
            is_wall = 1'b1; 
        //section 10
        else if(x >= 10'd64 && x <= 10'd225 && y >= 10'd292 && y <= 10'd310)
            is_wall = 1'b1; 
        else if (x >= 10'd203 && x <= 10'd225 && y >= 10'd235 && y <= 10'd292)
            is_wall = 1'b1;
        else if (x >= 10'd225 && x <= 10'd287 && y >= 10'd235 && y <= 10'd260)
            is_wall = 1'b1; 
        else if (x >= 10'd287 && x <= 10'd309 && y >= 10'd235 && y <= 10'd292)
            is_wall = 1'b1;
        else if (x >= 10'd287 && x <= 10'd448 && y >= 10'd292 && y <= 10'd310)
            is_wall = 1'b1;
        //section 11
        else if (x >= 10'd41 && x <= 10'd47 && y >= 10'd200 && y <= 10'd355)
            is_wall = 1'b1;
        else if (x >= 10'd47 && x <= 10'd118 && y >= 10'd350 && y <= 10'd355)
            is_wall = 1'b1;      
        //section 12
        else if (x >= 10'd158 && x <= 10'd354 && y >= 10'd327 && y <= 10'd383)
            is_wall = 1'b1; 
        //section 13 
        else if (x >= 10'd242 && x <= 10'd270 && y >= 10'd277 && y <= 10'd310)
            is_wall = 1'b1;
        //section 14
        else if (x >= 10'd203 && x <= 10'd309 && y >= 10'd165 && y <= 10'd218)
            is_wall = 1'b1; 
        //section 15 
        else if (x >= 10'd242 && x <= 10'd270 && y >= 10'd74 && y < 10'd107)
            is_wall = 1'b1; 
        //section 16
        else if (x >= 10'd158 && x <= 10'd354 && y <= 10'd57)
            is_wall = 1'b1;
        //section 17 (mirrors 5)
        else if (x >= 10'd326 && x <= 10'd377 && y >= 10'd108 && y <= 10'd148)
            is_wall = 1'b1; 
        //section 18 (mirrors 4)
        else if (x >= 10'd394 && x <= 10'd448 && y >= 10'd108 && y <= 10'd148)
            is_wall = 1'b1;      
        //section 19 (mirrors 6/7)
        else if (x >= 10'd326 && x <= 10'd448 && y >= 10'd165 && y <= 10'd218)
            is_wall = 1'b1;
        //section 20 (mirrors 9)
        else if (x >= 10'd326 && x <= 10'd377 && y >= 10'd235 && y <= 10'd275)
            is_wall = 1'b1;        
        //section 21 (mirrors 8) 
        else if (x >= 10'd394 && x <= 10'd448 && y >= 10'd235 && y <= 10'd275)
            is_wall = 1'b1;         
        //section 22 (mirrors 1)
        else if (x >= 10'd502)
            is_wall = 1'b1;
        else if (y <= 10'd10 && x >= 10'd371)
            is_wall = 1'b1;
        else if (x >= 10'd371 && x <= 10'd377 && y <= 10'd57)
            is_wall = 1'b1;
        else if (x >= 10'd377 && x <= 10'd448 && y <= 10'd57 && y >= 10'd49)
            is_wall = 1'b1;
        else if (y >= 10'd372 && x >= 10'd371)
            is_wall = 1'b1;
        else if (x >= 10'd371 && x <= 10'd377 && y >= 10'd327)
            is_wall = 1'b1;
        else if (x >= 10'd377 && x <= 10'd448 && y >= 10'd327 && y <= 10'd383)
            is_wall = 1'b1;
        //section 23 (mirrors 2)
        else if (x >= 10'd465 && x <= 10'd471 && y >= 10'd27 && y <= 10'd183)
            is_wall = 1'b1;
        else if (x >= 10'd394 && x <= 10'd465 && y >= 10'd27 && y <= 10'd32)
            is_wall = 1'b1;
        //section 24 (mirrors 11)
        else if (x >= 10'd465 && x <= 10'd471 && y >= 10'd200 && y <= 10'd355)
            is_wall = 1'b1;
        else if (x >= 10'd394 && x <= 10'd465 && y >= 10'd350 && y <= 10'd355)
            is_wall = 1'b1;
        else
            is_wall = 1'b0; //if it's not a wall, then it must be a path
    end
endmodule 