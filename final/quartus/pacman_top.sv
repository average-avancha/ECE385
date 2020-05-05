module pacman_top(input                CLOCK_50,
                  input        [3:0]   KEY,          //bit 0 is set up as Reset
                  output logic [6:0]   HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7,
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
   //logic element declarations to interface w/ keyboard
	logic hpi_r, hpi_w, hpi_cs, hpi_reset;
	logic [15:0] hpi_data_in, hpi_data_out;
   logic [7:0]  keycode;
	logic [1:0]  hpi_addr;

   //logic element declarations to connect between modules
	logic Reset_h, Clk, frame_clk_rising_edge, increment_score_dot, collision_state,
         is_ball, is_Pac, is_Map, is_dot, 
         is_red_ghost, is_orange_ghost, is_cyan_ghost, is_cyan_killer, is_pink_ghost, is_pink_killer, is_powered_up,
         is_cyan_scared, is_orange_scared, is_pink_scared, is_red_scared,
         reset_score, reset_dots, hold, dying, game_ended, losing_power,
         increment_score_ghost, increment_score_powdot, RELOAD_state,
         reload, reload_cyan, reload_orange, reload_pink, reload_red;
   
   logic [1:0]    life_count;
   logic [2:0]    direction_out, direction, red_ghost_direction_out, orange_ghost_direction_out, cyan_ghost_direction_out, pink_ghost_direction_out, enum_state; 
   logic [3:0]    scared;
   logic [6:0]    animation_count, red_ghost_animation_count, orange_ghost_animation_count, cyan_ghost_animation_count, pink_ghost_animation_count, death_time;
   logic [7:0]    sprite_addr, ghost_addr, death_addr, dot_count;
   logic [8:0]    map_addr, timer_powered_up, map_flash_timer;
   logic [9:0]    DrawX, DrawY, 
                  MapX, MapY, 
                  PacX, PacY, 
                  DistX, DistY, 
                  PacX_Monitor, PacY_Monitor, 
                  RedGhostX, RedGhostY, RedGhostX_Monitor, RedGhostY_Monitor, 
                  OrangeGhostX, OrangeGhostY, OrangeGhostX_Monitor, OrangeGhostY_Monitor, 
                  CyanGhostX, CyanGhostY, CyanGhostX_Monitor, CyanGhostY_Monitor, 
                  PinkGhostX, PinkGhostY, PinkGhostX_Monitor, PinkGhostY_Monitor;
   logic [15:0]   sprite_data, death_data;
   logic [19:0]   current_score, current_highscore;
	logic [63:0]   ghost_data;
	logic [511:0]  map_data;
   
	assign Clk = CLOCK_50;
   always_ff @ (posedge Clk) begin
        Reset_h <= ~(KEY[0]);        // The push buttons are active low
   end

   // Interface between NIOS II and EZ-OTG chip
   hpi_io_intf hpi_io_inst(.Clk(Clk),
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
	lab8_soc nios_system   (.clk_clk(Clk),     
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
   VGA_controller vga_controller_instance(.Clk(Clk),
                                          .Reset(Reset_h),
                                          .VGA_HS(VGA_HS),
                                          .VGA_VS(VGA_VS),
                                          .VGA_CLK(VGA_CLK),
                                          .VGA_BLANK_N(VGA_BLANK_N),
                                          .VGA_SYNC_N(VGA_SYNC_N),
                                          .DrawX(DrawX),
                                          .DrawY(DrawY));
	

   
	HexDriver hex_inst_0 ({3'b0, is_cyan_scared}  , HEX0);
	HexDriver hex_inst_1 ({3'b0, is_orange_scared}, HEX1);
	HexDriver hex_inst_2 ({3'b0, is_pink_scared}  , HEX2);
	HexDriver hex_inst_3 ({3'b0, is_red_scared}   , HEX3);
	HexDriver hex_inst_4 (       death_time[3:0]  , HEX4);
   HexDriver hex_inst_5 ({1'b0, death_time[6:4]} , HEX5);
	HexDriver hex_inst_6 ({3'b0, dying}           , HEX6);
	HexDriver hex_inst_7 ({1'b0, enum_state}      , HEX7);
//    HexDriver hex_inst_0 (dot_count[3:0] , HEX0);
//    HexDriver hex_inst_1 (dot_count[7:4] , HEX1);
//    HexDriver hex_inst_0 ({1'b0, enum_state}, HEX0); 

	// HexDriver hex_inst_2 ({3'b0, collision_state}, HEX2);

   //RELOAD_state control signal when reset_dots
   // assign RELOAD_state = reset_dots;

   //maps colors to VGA screen based on the curren DrawX and DrawY
   color_mapper 	      color_instance		     (.is_Pac, .is_Map, .is_dot, .is_red_ghost, .is_orange_ghost, .is_cyan_ghost, .is_pink_ghost,
                                                .is_cyan_scared, .is_orange_scared, .is_pink_scared, .is_red_scared, .losing_power, .RELOAD_state, .dying,
                                                .timer_powered_up, .map_flash_timer, .DrawX, .DrawY, .DistX, .DistY, .sprite_data, .death_data, .ghost_data, .map_data, 
                                                .VGA_R(VGA_R), .VGA_G(VGA_G), .VGA_B(VGA_B));
   //control module declaration
   controls_game        controls_              (.Clk, .frame_clk_rising_edge, .Reset(Reset_h), .increment_score_powdot, .keycode, .dot_count, 
                                                .PacX_Monitor, .PacY_Monitor, 
                                                .RedGhostX_Monitor, .RedGhostY_Monitor, 
                                                .OrangeGhostX_Monitor, .OrangeGhostY_Monitor, 
                                                .CyanGhostX_Monitor, .CyanGhostY_Monitor, 
                                                .PinkGhostX_Monitor, .PinkGhostY_Monitor, 
                                                .is_cyan_killer, .is_pink_killer, .is_powered_up, 
                                                .is_cyan_scared, .is_orange_scared, .is_pink_scared, .is_red_scared, 
                                                .increment_score_ghost,
                                                .reset_score, .reset_dots, .reload, .reload_cyan, .reload_orange, .reload_pink, .reload_red, 
                                                .hold, .dying, .game_ended, .losing_power, .RELOAD_state,
                                                .life_count, .enum_state, .scared, .death_time, .timer_powered_up, .map_flash_timer, .collision_state);

   //handles all logic concerning the current state of the dots on the game board
	dot_handler		      dot_handler_instance   (.Clk, .Reset(Reset_h), .frame_clk_rising_edge, .reset_dots, .reload, 
                                                .DrawX, .DrawY, .PacX_Monitor, .PacY_Monitor, .is_dot, 
																.increment_score_dot, .increment_score_powdot, .dot_count);

   //ROMs hold all the sprite data
	deathROM 		      deathROM_ 			     (.addr(death_addr), .data(death_data));
   ghostROM			      ghostROM_				  (.addr(ghost_addr),  .data(ghost_data));
	mapROM		         mapROM_				     (.addr(map_addr), 	  .data(map_data));
   spriteROM 		      spriteROM_ 			     (.addr(sprite_addr), .data(sprite_data));
   
   //handles which sprite has priorioty on the screen
   priority_handler     priority_instance	     (.Clk, .Reset(Reset_h), 
                                                .is_Pac, .is_dot, .is_Map, .is_red_ghost, .is_orange_ghost , .is_cyan_ghost, .is_pink_ghost,
                                                .is_cyan_scared, .is_orange_scared, .is_pink_scared, .is_red_scared, .dying,
                                                .death_time, .animation_count, .red_ghost_animation_count, .orange_ghost_animation_count, .cyan_ghost_animation_count, .pink_ghost_animation_count, 
                                                .direction_out, .red_ghost_direction_out, .orange_ghost_direction_out, .cyan_ghost_direction_out, .pink_ghost_direction_out, 
                                                .PacX, .PacY, .RedGhostX, .RedGhostY, .OrangeGhostX, .OrangeGhostY, .CyanGhostX, .CyanGhostY, .PinkGhostX, .PinkGhostY, .MapX, .MapY, 
                                                .direction, .ghost_addr, .sprite_addr, .death_addr, .map_addr, .DistX, .DistY);
   //custom map declaration
   sprite #(.Sprite_X_Center(10'd320), .Sprite_Y_Center(10'd240), .Sprite_Width(10'd512), .Sprite_Height(10'd384)) 
                        map_instance 	        (.Clk, .Reset(Reset_h), .frame_clk(VGA_VS), .DrawX, .DrawY, .MapX, .MapY, .is_sprite(is_Map));
   //keeps track of the current score
	score				      score_instance 		  (.Clk, .Reset(Reset_h), .increment_score_dot, .increment_score_ghost, .increment_score_powdot, .reset_score, .game_ended, .current_score, .current_highscore);
   //Pacman declaration
	pacman_sprite        pacman_instance	     (.Clk, .Reset(Reset_h), .frame_clk(VGA_VS), .reload, .hold, .dying, .keycode, .DrawX, .DrawY, .frame_clk_rising_edge, .PacX, .PacY, .is_Pac, .direction_out, .animation_count, .PacX_Monitor, .PacY_Monitor);
   //Ghost Declarations
   cyan_ghost_sprite    cyanGhost_instance     (.Clk, .Reset(Reset_h), .frame_clk(VGA_VS), .reload(reload_cyan), .hold, .DrawX, .DrawY, .PacX(PacX_Monitor), .PacY(PacY_Monitor), .direction_out, .is_cyan_killer, .CyanGhostX, .CyanGhostY, .is_cyan_ghost, .cyan_ghost_direction_out, .cyan_ghost_animation_count, .CyanGhostX_Monitor, .CyanGhostY_Monitor);
   orange_ghost_sprite  clydeGhost_instance    (.Clk, .Reset(Reset_h), .frame_clk(VGA_VS), .reload(reload_orange), .hold, .DrawX, .DrawY, .PacX(PacX_Monitor), .PacY(PacY_Monitor), .direction_out, .OrangeGhostX, .OrangeGhostY, .is_orange_ghost, .orange_ghost_direction_out, .orange_ghost_animation_count, .OrangeGhostX_Monitor, .OrangeGhostY_Monitor);
   pink_ghost_sprite    pinkGhost_instance     (.Clk, .Reset(Reset_h), .frame_clk(VGA_VS), .reload(reload_pink), .hold, .DrawX, .DrawY, .PacX(PacX_Monitor), .PacY(PacY_Monitor), .direction_out, .is_pink_killer, .PinkGhostX, .PinkGhostY, .is_pink_ghost, .pink_ghost_direction_out, .pink_ghost_animation_count, .PinkGhostX_Monitor, .PinkGhostY_Monitor);
   red_ghost_sprite     redGhost_instance	     (.Clk, .Reset(Reset_h), .frame_clk(VGA_VS), .reload(reload_red), .hold, .DrawX, .DrawY, .PacX(PacX_Monitor), .PacY(PacY_Monitor), .direction_out, .RedGhostX, .RedGhostY, .is_red_ghost, .red_ghost_direction_out, .red_ghost_animation_count, .RedGhostX_Monitor, .RedGhostY_Monitor);
   
endmodule 



//~~~~~~~~~~~~~~MODULE DESCRIPTIONS~~~~~~~~~~~~~~
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