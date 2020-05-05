module pacman_top(input                CLOCK_50,
                  input        [3:0]   KEY,          //bit 0 is set up as Reset
                  output logic [6:0]   HEX0, HEX1,
						 // VGA Interface 
						 output logic [7:0]  VGA_R,        //VGA Red
													VGA_G,        //VGA Green
													VGA_B,        //VGA Blue
						 output logic        VGA_CLK,      //VGA Clock
													VGA_SYNC_N,   //VGA Sync signal
													VGA_BLANK_N,  //VGA Blank signal
													VGA_VS,       //VGA virtical sync signal
													VGA_HS,       //VGA horizontal sync signal
						 // CY7C67200 Interface
						 inout  wire  [15:0] OTG_DATA,     //CY7C67200 Data bus 16 Bits
						 output logic [1:0]  OTG_ADDR,     //CY7C67200 Address 2 Bits
						 output logic        OTG_CS_N,     //CY7C67200 Chip Select
													OTG_RD_N,     //CY7C67200 Write
													OTG_WR_N,     //CY7C67200 Read
													OTG_RST_N,    //CY7C67200 Reset
						 input               OTG_INT,      //CY7C67200 Interrupt
						 // SDRAM Interface for Nios II Software
						 output logic [12:0] DRAM_ADDR,    //SDRAM Address 13 Bits
						 inout  wire  [31:0] DRAM_DQ,      //SDRAM Data 32 Bits
						 output logic [1:0]  DRAM_BA,      //SDRAM Bank Address 2 Bits
						 output logic [3:0]  DRAM_DQM,     //SDRAM Data Mast 4 Bits
						 output logic        DRAM_RAS_N,   //SDRAM Row Address Strobe
													DRAM_CAS_N,   //SDRAM Column Address Strobe
													DRAM_CKE,     //SDRAM Clock Enable
													DRAM_WE_N,    //SDRAM Write Enable
													DRAM_CS_N,    //SDRAM Chip Select
													DRAM_CLK      //SDRAM Clock
											);
   logic Reset_h, Clk, is_ball, is_Pac, is_Map;
	logic hpi_r, hpi_w, hpi_cs, hpi_reset;
	logic [15:0] hpi_data_in, hpi_data_out;
   logic [7:0]  keycode;
	logic [1:0]  hpi_addr;

   logic [9:0]  DrawX, DrawY, MapX, MapY, PacX, PacY, DistX, DistY;
   logic [5:0] sprite_addr;
   logic [15:0] sprite_data;

   assign Clk = CLOCK_50;
   always_ff @ (posedge Clk) begin
        Reset_h <= ~(KEY[0]);        // The push buttons are active low
   end

   // Interface between NIOS II and EZ-OTG chip
   hpi_io_intf hpi_io_inst(
                           .Clk(Clk),
                           .Reset(1'b0), //
                           // signals connected to NIOS II
                           .from_sw_address(hpi_addr),
                           .from_sw_data_in(hpi_data_in),
                           .from_sw_data_out(hpi_data_out),
                           .from_sw_r(hpi_r),
                           .from_sw_w(hpi_w),
                           .from_sw_cs(hpi_cs),
                           .from_sw_reset(hpi_reset),
                           // signals connected to EZ-OTG chip
                           .OTG_DATA(OTG_DATA),    
                           .OTG_ADDR(OTG_ADDR),    
                           .OTG_RD_N(OTG_RD_N),    
                           .OTG_WR_N(OTG_WR_N),    
                           .OTG_CS_N(OTG_CS_N),
                           .OTG_RST_N(OTG_RST_N)); 
	lab8_soc nios_system    (
                           .clk_clk(Clk),     
                           .keycode_export(keycode),
                           .otg_hpi_address_export(hpi_addr),
                           .otg_hpi_cs_export(hpi_cs),
                           .otg_hpi_data_in_port(hpi_data_in),
                           .otg_hpi_data_out_port(hpi_data_out),
                           .otg_hpi_r_export(hpi_r),
                           .otg_hpi_reset_export(hpi_reset),
                           .otg_hpi_w_export(hpi_w),
                           .reset_reset_n(1'b1),    // Never reset NIOS
                           .sdram_clk_clk(DRAM_CLK), 
                           .sdram_wire_addr(DRAM_ADDR), 
                           .sdram_wire_ba(DRAM_BA),   
                           .sdram_wire_cas_n(DRAM_CAS_N),
                           .sdram_wire_cke(DRAM_CKE),  
                           .sdram_wire_cs_n(DRAM_CS_N), 
                           .sdram_wire_dq(DRAM_DQ),   
                           .sdram_wire_dqm(DRAM_DQM),  
                           .sdram_wire_ras_n(DRAM_RAS_N),
                           .sdram_wire_we_n(DRAM_WE_N));
                           
    // Use PLL to generate the 25MHZ VGA_CLK.
    // You will have to generate it on your own in simulation.
   vga_clk vga_clk_instance(.inclk0(Clk), .c0(VGA_CLK));
   VGA_controller vga_controller_instance(
                                          .Clk(Clk),
                                          .Reset(Reset_h),
                                          .VGA_HS(VGA_HS),
                                          .VGA_VS(VGA_VS),
                                          .VGA_CLK(VGA_CLK),
                                          .VGA_BLANK_N(VGA_BLANK_N),
                                          .VGA_SYNC_N(VGA_SYNC_N),
                                          .DrawX(DrawX),
                                          .DrawY(DrawY));
	
//    HexDriver hex_inst_0 ({2'b0, Pac_Animation[1:0]}, HEX0);
//    HexDriver hex_inst_1 (Data[7:4], HEX1);

   color_mapper 	color_instance		     (.is_Pac, .is_Map, .DrawX, .DrawY, .DistX, .DistY, .sprite_data, .VGA_R(VGA_R), .VGA_G(VGA_G), .VGA_B(VGA_B));
	spriteROM 		spriteROM_ 			     (.addr(sprite_addr), .data(sprite_data));
	pacman_sprite  pacman_instance	     (.Clk, .Reset(Reset_h), .frame_clk(VGA_VS), .keycode, .DrawX, .DrawY, .PacX, .PacY, .is_Pac);
   sprite #(.Sprite_X_Center(10'd320), .Sprite_Y_Center(10'd240), .Sprite_Width(10'd512), .Sprite_Height(10'd384)) 
						map_instance 	        (.Clk, .Reset(Reset_h), .frame_clk(VGA_VS), .DrawX, .DrawY, .MapX, .MapY, .is_sprite(is_Map));
	
	 //Sprite Priority Handler
   always_comb begin
		if(is_Pac) begin
			DistX = PacX;
			DistY = PacY; 
			sprite_addr = DistY[5:0] + 6'd48;
		end
		else if(is_Map) begin
			DistX = MapX;
			DistY = MapY;
			sprite_addr = 11'bz;
		end
		else begin 
         sprite_addr = 11'bz;
			DistX = 10'bz;
			DistY = 10'bz;
		end
   end
endmodule 

module sprite #([9:0] Sprite_X_Center, [9:0] Sprite_Y_Center, [9:0] Sprite_Width, [9:0] Sprite_Height) (
				input           		Clk, Reset, frame_clk,
            input [9:0]     		DrawX, DrawY,
            output logic[9:0]    MapX, MapY,
            output logic		   is_sprite);

   logic frame_clk_delayed, frame_clk_rising_edge;
   always_ff @ (posedge Clk) begin
      frame_clk_delayed <= frame_clk;
      frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
   end

   assign MapX = DrawX - Sprite_X_Center + (Sprite_Width >> 1);
   assign MapY = DrawY - Sprite_Y_Center + (Sprite_Height >> 1);
   always_comb begin
      if ((MapX < Sprite_Width) && (MapX >= 0) && (MapY < Sprite_Height) && (MapY >= 0)) 
         is_sprite = 1'b1;
      else
         is_sprite = 1'b0;
   end
endmodule
