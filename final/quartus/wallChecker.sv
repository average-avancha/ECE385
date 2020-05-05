// module wallChecker (input [9:0] x, y,
//                     output      is_wall);
//     always_comb begin
//         //Section of Walls
//         //section 1
//         if(x <= 10'd24)
//             is_wall = 1'b1;
//         else if (y <= 10'd10 && x <= 10'd118)
//             is_wall = 1'b1;
//         else if (x >= 10'd64 && x <= 10'd118 && y <= 10'd57 && y >= 10'd49)
//             is_wall = 1'b1;
//         else if (y >= 10'd372 && x <= 10'd118)
//             is_wall = 1'b1;
//         else if (x >= 10'd64 && x <= 10'd118 && y >= 10'd327 && y <= 10'd333)
//             is_wall = 1'b1;
//         //section 2
//         else if (x >= 10'd41 && x <= 10'd47 && y >= 10'd27 && y <= 10'd91)
//             is_wall = 1'b1;
//         else if (x >= 10'd47 && x <= 10'd118 && y >= 10'd27 && y <= 10'd32)
//             is_wall = 1'b1;
//         //between section 2 and 11
//         else if (x >= 10'd41 && x <= 10'd47 && y >= 10'd108 && y <= 10'd148)
//             is_wall = 1'b1;
//         else if (x >= 10'd41 && x <= 10'd47 && y >= 10'd165 && y <= 10'd218)
//             is_wall = 1'b1;
//         else if (x >= 10'd41 && x <= 10'd47 && y >= 10'd235 && y <= 10'd275)
//             is_wall = 1'b1;
//         //section 3
//         //3 left handle
//         else if(x >= 10'd64 && x <= 10'd186 && y >= 10'd74 && y <= 10'd91)
//             is_wall = 1'b1; 
//         //3 left block
//         else if (x >= 10'd203 && x <= 10'd225 && y >= 10'd74 && y <= 10'd148)
//             is_wall = 1'b1;
//         //3 right block
//         else if (x >= 10'd287 && x <= 10'd309 && y >= 10'd74 && y <= 10'd148)
//             is_wall = 1'b1;
//         //3 right handle
//         else if (x >= 10'd326 && x <= 10'd448 && y >= 10'd74 && y <= 10'd91)
//             is_wall = 1'b1; 
//         //section 4
//         else if (x >= 10'd64 && x <= 10'd118 && y >= 10'd108 && y <= 10'd148)
//             is_wall = 1'b1; 
//         //section 5
//         else if (x >= 10'd135 && x <= 10'd186 && y >= 10'd108 && y <= 10'd148)
//             is_wall = 1'b1; 
//         //section 6/7 (labelled differently on diagram on accident but is the same block)
//         else if (x >= 10'd64 && x <= 10'd186 && y >= 10'd165 && y <= 10'd218)
//             is_wall = 1'b1;
//         //section 8
//         else if (x >= 10'd64 && x <= 10'd118 && y >= 10'd235 && y <= 10'd275)
//             is_wall = 1'b1; 
//         //section 9
//         else if (x >= 10'd135 && x <= 10'd186 && y >= 10'd235 && y <= 10'd275)
//             is_wall = 1'b1; 
//         //section 10
//         //10 left handle
//         else if(x >= 10'd64 && x <= 10'd186 && y >= 10'd292 && y <= 10'd309)
//             is_wall = 1'b1; 
//         //10 center left
//         else if (x >= 10'd203 && x <= 10'd225 && y >= 10'd235 && y <= 10'd309)
//             is_wall = 1'b1;
//         //10 center right
//         else if (x >= 10'd287 && x <= 10'd309 && y >= 10'd235 && y <= 10'd309)
//             is_wall = 1'b1;
//         //10 right handle
//         else if (x >= 10'd326 && x <= 10'd448 && y >= 10'd292 && y <= 10'd309)
//             is_wall = 1'b1;
//         //section 11
//         else if (x >= 10'd41 && x <= 10'd47 && y >= 10'd292 && y <= 10'd355)
//             is_wall = 1'b1;
//         else if (x >= 10'd47 && x <= 10'd118 && y >= 10'd350 && y <= 10'd355)
//             is_wall = 1'b1;      
//         //section 12
//         else if (x >= 10'd135 && x <= 10'd377 && y >= 10'd326)
//             is_wall = 1'b1; 
//         //new section 13
//         else if (x >= 10'd242 && x <= 10'd270 && y >= 10'd235 && y <= 10'd309)
//             is_wall = 1'b1; 
//         //section 14
//         else if (x >= 10'd203 && x <= 10'd309 && y >= 10'd165 && y <= 10'd218)
//             is_wall = 1'b1; 
//         //new section 15 
//         else if (x >= 10'd242 && x <= 10'd270 && y >= 10'd74 && y <= 10'd148)
//             is_wall = 1'b1; 
//         //section 16
//         else if (x >= 10'd135 && x <= 10'd377 && y <= 10'd57)
//             is_wall = 1'b1;
//         //section 17 (mirrors 5)
//         else if (x >= 10'd326 && x <= 10'd377 && y >= 10'd108 && y <= 10'd148)
//             is_wall = 1'b1; 
//         //section 18 (mirrors 4)
//         else if (x >= 10'd394 && x <= 10'd448 && y >= 10'd108 && y <= 10'd148)
//             is_wall = 1'b1;      
//         //section 19 (mirrors 6/7)
//         else if (x >= 10'd326 && x <= 10'd448 && y >= 10'd165 && y <= 10'd218)
//             is_wall = 1'b1;
//         //section 20 (mirrors 9)
//         else if (x >= 10'd326 && x <= 10'd377 && y >= 10'd235 && y <= 10'd275)
//             is_wall = 1'b1;        
//         //section 21 (mirrors 8) 
//         else if (x >= 10'd394 && x <= 10'd448 && y >= 10'd235 && y <= 10'd275)
//             is_wall = 1'b1;         
//         //section 22 (mirrors 1)
//         else if(x >= 10'd488)
//             is_wall = 1'b1;
//         else if (y <= 10'd10 && x >= 10'd394)
//             is_wall = 1'b1;
//         else if (x <= 10'd448 && x >= 10'd394 && y <= 10'd57 && y >= 10'd49)
//             is_wall = 1'b1;
//         else if (y >= 10'd372 && x >= 10'd394)
//             is_wall = 1'b1;
//         else if (x <= 10'd448 && x >= 10'd394 && y >= 10'd327 && y <= 10'd333)
//             is_wall = 1'b1;
//         //section 23 (mirrors 2)
//         else if (x >= 10'd465 && x <= 10'd471 && y >= 10'd27 && y <= 10'd91)
//             is_wall = 1'b1;
//         else if (x >= 10'd394 && x <= 10'd465 && y >= 10'd27 && y <= 10'd32)
//             is_wall = 1'b1;
//         //sections between 23 and 24 (mirrors section between 2 and 11)
//         else if (x <= 10'd471 && x >= 10'd465 && y >= 10'd108 && y <= 10'd148) 
//             is_wall = 1'b1;
//         else if (x <= 10'd471 && x >= 10'd465 && y >= 10'd165 && y <= 10'd218)
//             is_wall = 1'b1;
//         else if (x <= 10'd471 && x >= 10'd465 && y >= 10'd235 && y <= 10'd275)
//             is_wall = 1'b1;
//         //section 24 (mirrors 11)
//         else if (x >= 10'd465 && x <= 10'd471 && y >= 10'd292 && y <= 10'd355)
//             is_wall = 1'b1;
//         else if (x >= 10'd394 && x <= 10'd465 && y >= 10'd350 && y <= 10'd355)
//             is_wall = 1'b1;
//         else
//             is_wall = 1'b0; //if it's not a wall, then it must be a path
//     end
// endmodule 

module wallChecker (input [9:0] x, y,
                    output      is_wall);
    always_comb begin
        //Section of Walls
        //section 1
        // if(x <= 10'd24)
        //     is_wall = 1'b1;
        // else if (y <= 10'd10 && x <= 10'd118)
        //     is_wall = 1'b1;
        if (x >= 10'd64 && x <= 10'd118 && y <= 10'd57 && y >= 10'd49)
            is_wall = 1'b1;
        // else if (y >= 10'd372 && x <= 10'd118)
        //     is_wall = 1'b1;
        else if (x >= 10'd64 && x <= 10'd118 && y >= 10'd327 && y <= 10'd333)
            is_wall = 1'b1;
        //section 2 --->changed
        else if ((x <= 10'd47 && y <= 10'd91) || (x <= 10'd118 && y <= 10'd32))
            is_wall = 1'b1;
        // else if (x >= 10'd41 && x <= 10'd47 && y >= 10'd27 && y <= 10'd91)
        //     is_wall = 1'b1;
        // else if (x >= 10'd47 && x <= 10'd118 && y >= 10'd27 && y <= 10'd32)
        //     is_wall = 1'b1;
        //between section 2 and 11 --> changed
        else if (x <= 10'd47 && y >= 10'd108 && y <= 10'd275)
            is_wall = 1'b1;
        // else if (x >= 10'd41 && x <= 10'd47 && y >= 10'd165 && y <= 10'd218)
        //     is_wall = 1'b1;
        // else if (x >= 10'd41 && x <= 10'd47 && y >= 10'd235 && y <= 10'd275)
        //     is_wall = 1'b1;
        //section 3
        //3 left handle
        else if(x >= 10'd64 && x <= 10'd186 && y >= 10'd74 && y <= 10'd91)
            is_wall = 1'b1; 
        //3 left block
        else if (x >= 10'd203 && x <= 10'd225 && y >= 10'd74 && y <= 10'd148)
            is_wall = 1'b1;
        //3 right block
        else if (x >= 10'd287 && x <= 10'd309 && y >= 10'd74 && y <= 10'd148)
            is_wall = 1'b1;
        //3 right handle
        else if (x >= 10'd326 && x <= 10'd448 && y >= 10'd74 && y <= 10'd91)
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
        //10 left handle
        else if(x >= 10'd64 && x <= 10'd186 && y >= 10'd292 && y <= 10'd309)
            is_wall = 1'b1; 
        //10 center left
        else if (x >= 10'd203 && x <= 10'd225 && y >= 10'd235 && y <= 10'd309)
            is_wall = 1'b1;
        //10 center right
        else if (x >= 10'd287 && x <= 10'd309 && y >= 10'd235 && y <= 10'd309)
            is_wall = 1'b1;
        //10 right handle
        else if (x >= 10'd326 && x <= 10'd448 && y >= 10'd292 && y <= 10'd309)
            is_wall = 1'b1;
        //section 11 ---> changed
        else if ((x <= 10'd47 && y >= 10'd292) || (x <= 10'd118 && y >= 10'd350))
            is_wall = 1'b1; 
        // else if (x >= 10'd41 && x <= 10'd47 && y >= 10'd292 && y <= 10'd355)
        //     is_wall = 1'b1;
        // else if (x >= 10'd47 && x <= 10'd118 && y >= 10'd350 && y <= 10'd355)
        //     is_wall = 1'b1;      
        //section 12
        else if (x >= 10'd135 && x <= 10'd377 && y >= 10'd326)
            is_wall = 1'b1; 
        //new section 13
        else if (x >= 10'd242 && x <= 10'd270 && y >= 10'd235 && y <= 10'd309)
            is_wall = 1'b1; 
        //section 14
        else if (x >= 10'd203 && x <= 10'd309 && y >= 10'd165 && y <= 10'd218)
            is_wall = 1'b1; 
        //new section 15 
        else if (x >= 10'd242 && x <= 10'd270 && y >= 10'd74 && y <= 10'd148)
            is_wall = 1'b1; 
        //section 16
        else if (x >= 10'd135 && x <= 10'd377 && y <= 10'd57)
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
        // else if(x >= 10'd488)
        //     is_wall = 1'b1;
        // else if (y <= 10'd10 && x >= 10'd394)
        //     is_wall = 1'b1;
        else if (x <= 10'd448 && x >= 10'd394 && y <= 10'd57 && y >= 10'd49)
            is_wall = 1'b1;
        // else if (y >= 10'd372 && x >= 10'd394)
        //     is_wall = 1'b1;
        else if (x <= 10'd448 && x >= 10'd394 && y >= 10'd327 && y <= 10'd333)
            is_wall = 1'b1;
        //section 23 (mirrors 2) --> changed
        else if ((x >= 10'd465 && y <= 10'd91) || (x >= 10'd394 && y <= 10'd32))
            is_wall = 1'b1;        
        // else if (x >= 10'd465 && x <= 10'd471 && y >= 10'd27 && y <= 10'd91)
        //     is_wall = 1'b1;
        // else if (x >= 10'd394 && x <= 10'd465 && y >= 10'd27 && y <= 10'd32)
        //     is_wall = 1'b1;
        //sections between 23 and 24 (mirrors section between 2 and 11) --> changed
        else if (x >= 10'd465 && y >= 10'd108 && y <= 10'd275)
            is_wall = 1'b1;        
        // else if (x <= 10'd471 && x >= 10'd465 && y >= 10'd108 && y <= 10'd148) 
        //     is_wall = 1'b1;
        // else if (x <= 10'd471 && x >= 10'd465 && y >= 10'd165 && y <= 10'd218)
        //     is_wall = 1'b1;
        // else if (x <= 10'd471 && x >= 10'd465 && y >= 10'd235 && y <= 10'd275)
        //     is_wall = 1'b1;
        //section 24 (mirrors 11) ---> changed
        else if ((x >= 10'd465 && y >= 10'd292) || (x >= 10'd394 && y >= 10'd350))
            is_wall = 1'b1;         
        // else if (x >= 10'd465 && x <= 10'd471 && y >= 10'd292 && y <= 10'd355)
        //     is_wall = 1'b1;
        // else if (x >= 10'd394 && x <= 10'd465 && y >= 10'd350 && y <= 10'd355)
        //     is_wall = 1'b1;
        else
            is_wall = 1'b0; //if it's not a wall, then it must be a path
    end
endmodule 