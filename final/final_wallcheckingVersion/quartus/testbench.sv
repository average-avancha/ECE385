module testbench();

timeunit 10ns;

timeprecision 1ns;

logic CLK;
logic is_sprite;
logic [9:0] DrawX, DrawY;
logic [9:0] DistX, DistY;
logic CE, UB, LB, OE;
logic [19:0] SRAM_ADDR;
logic WAI;

load_sprite #(.X(0), .Y(0)) sheet (.*);

always begin : CLOCK_GENERATION
	#1 CLK = ~CLK;
end

initial begin
	CLK = 0;
end

initial begin : TEST_VECTORS
	is_sprite = 0;
	
	#2 is_sprite = 1;
	for(DrawY = 10'd0; DrawY < 10'd800; DrawY = DrawY + 10'd1)begin
		for(DrawX = 10'd0; DrawX < 10'd525; DrawX = DrawX + 10'd1)begin
			#2 WAI = 0;
		end
	end
end
endmodule 