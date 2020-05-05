module addRoundKey (input logic  [127:0] state, 
                    input logic  [127:0] roundKey,
                    output logic [127:0] out);
    assign out = state ^ roundKey;
endmodule 