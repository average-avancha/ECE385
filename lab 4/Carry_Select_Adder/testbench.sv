 module testbench();

 timeunit 10ns;

 timeprecision 1ns;

 logic           Clk;        // 50MHz clock is only used to get timing estimate data
 logic           Reset;      // From push-button 0.  Remember the button is active low (0 when pressed)
 logic           LoadB;      // From push-button 1
 logic           Run;        // From push-button 3.
 logic[15:0]     SW;         // From slider switches

 // all outputs are registered
 logic           CO;         // Carry-out.  Goes to the green LED to the left of the hex displays.
 logic[15:0]     Sum;        // Goes to the red LEDs.  You need to press "Run" before the sum shows up here.
 logic[6:0]      Ahex0;      // Hex drivers display both inputs to the adder.
 logic[6:0]      Ahex1;
 logic[6:0]      Ahex2;
 logic[6:0]      Ahex3;
 logic[6:0]      Bhex0;
 logic[6:0]      Bhex1;
 logic[6:0]      Bhex2;
 logic[6:0]      Bhex3;

 always begin: CLOCK_GEN
 	#1 Clk = ~Clk; //non synth
 end

 initial begin: CLOCK_INIT
 	Clk = 0;
 end

 lab4_adders_toplevel tp(.*);

 initial begin: TEST_VECTORS

 	Reset = 0;
 	LoadB = 1;
 	Run   = 1;
	
 	//test case1
 	#2 Reset = 1;
	
 	#2 LoadB = 0;
 		SW = 16'h1234; // = 16'b0000000000000001
		
 	#2 LoadB = 1;
 		SW = 16'h1234; 
		
 	#2 	Run = 0;
	
 	#20;
 end
 endmodule

//`timescale 1ns/1ns
//
//module testbench();
//
//	timeunit 10ns;
//	timeprecision 1ns;
//
//	logic           Clk;        // 50MHz clock is only used to get timing estimate data
//	logic           Reset;      // From push-button 0.  Remember the button is active low (0 when pressed)
//	logic           LoadA;
//	logic           LoadB;      // From push-button 1
//	logic           Run;        // From push-button 3.
//	logic[15:0]     SW;         // From slider switches
//
//	// all outputs are registered
//	logic           CO;         // Carry-out.  Goes to the green LED to the left of the hex displays.
//	logic[15:0]     Sum;        // Goes to the red LEDs.  You need to press "Run" before the sum shows up here.
//	logic[6:0]      Ahex0;      // Hex drivers display both inputs to the adder.
//	logic[6:0]      Ahex1;
//	logic[6:0]      Ahex2;
//	logic[6:0]      Ahex3;
//	logic[6:0]      Bhex0;
//	logic[6:0]      Bhex1;
//	logic[6:0]      Bhex2;
//	logic[6:0]      Bhex3;
//		
//	//input   logic[15:0]     A,
//	//input   logic[15:0]     B,
//	//output  logic[15:0]     Sum,
//	//output  logic           CO
//	
//	carry_select_adder dut(
//		.A(LoadA), 
//		.B(LoadB),
//		.Sum(Sum),
//		.CO(CO)
//	);
//	
//	always 
//		begin
//			Clk <= 1; #5;
//			Clk <= 0; #5; //10ns period
//		end
////	initial begin: CLOCK_INIT
////		Clk = 0;
////	end
//	
////	initial
////		begin
////			LoadA <= 16'h0001; #10;
////			LoadB <= 16'h0001; #10;
////		end
//
//	lab4_adders_toplevel tp(.*);
//
//	logic expectedsum;
//	logic [31:0] i;
//	logic[47:0] testVector[1000:0];
//	
//	initial
//		begin
//			$readmemb("TestbenchVector.txt", testVector);
//		end
//	always @(posedge Clk)
//		begin
//			{LoadA, LoadB, expectedsum} = testVector[i]; #10;
//		end
//	always @(negedge Clk)
//		begin
//			Reset = 0;
//			LoadA = 0;
//			LoadB = 0;
//			Run = 1;
//			if(expectedsum !== Sum)	begin
//				$display("Wrong output for inputs %b, %b!=%b", {LoadA, LoadB}, expectedsum, Sum);
//			end
//			i = i + 1;
//		end
//	
////	initial begin: TEST_VECTORS
////
////		Reset = 0;
////		LoadB = 1;
////		Run   = 1;
////		
////		//test case1
////		#2 Reset = 1;
////		
////		#2 LoadB = 0;
////			SW = 16'h0001; // = 16'b0000000000000001
////			
////		#2 LoadB = 1;
////			SW = 16'h0002; 
////			
////		#2 	Run = 0;
////		
////		#20;
////	end
//endmodule

