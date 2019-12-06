//-------------------------------------------------------------------------
//      lab8.sv                                                          --
//      Christine Chen                                                   --
//      Fall 2014                                                        --
//                                                                       --
//      Modified by Po-Han Huang                                         --
//      10/06/2017                                                       --
//                                                                       --
//      Fall 2017 Distribution                                           --
//                                                                       --
//      For use with ECE 385 Lab 8                                       --
//      UIUC ECE Department                                              --
//-------------------------------------------------------------------------


module lab8( input               CLOCK_50,
             input        [3:0]  KEY,          //bit 0 is set up as Reset
             output logic [6:0]  HEX0, HEX1,HEX2,HEX3,
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
                                 DRAM_CLK,      //SDRAM Clock
             output logic[19:0]  SRAM_ADDR,
				 inout wire[15:0]    SRAM_DQ,
				 output logic SRAM_UB_N,SRAM_LB_N,SRAM_CE_N,SRAM_OE_N,SRAM_WE_N,
				 
				 
				  // audio part
				 input  AUD_BCLK,
				 input  AUD_ADCDAT,
				 output AUD_DACDAT,
				 input  AUD_DACLRCK, 
				 input  AUD_ADCLRCK,
				 output I2C_SDAT,
				 output I2C_SCLK,
				 output AUD_XCK
						  );
	 always_comb
	 begin
	 SRAM_UB_N = 1'b0;
	 SRAM_LB_N = 1'b0;
	 SRAM_CE_N = 1'b0;
	 SRAM_OE_N = 1'b0;
	 SRAM_WE_N = 1'b1;
	 end
    
    logic Reset_h, Clk;
    logic [31:0] keycode;
    
    assign Clk = CLOCK_50;
    always_ff @ (posedge Clk) begin
        Reset_h <= ~(KEY[0]);        // The push buttons are active low
    end
    
    logic [1:0] hpi_addr;
    logic [15:0] hpi_data_in, hpi_data_out;
    logic hpi_r, hpi_w, hpi_cs, hpi_reset;
    
    // Interface between NIOS II and EZ-OTG chip
    hpi_io_intf hpi_io_inst(
                            .Clk(Clk),
                            .Reset(Reset_h),
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
                            .OTG_RST_N(OTG_RST_N)
    );
     
     // You need to make sure that the port names here match the ports in Qsys-generated codes.
     nios_system nios_system(
                             .clk_clk(Clk),         
                             .reset_reset_n(1'b1),    // Never reset NIOS
                             .sdram_wire_addr(DRAM_ADDR), 
                             .sdram_wire_ba(DRAM_BA),   
                             .sdram_wire_cas_n(DRAM_CAS_N),
                             .sdram_wire_cke(DRAM_CKE),  
                             .sdram_wire_cs_n(DRAM_CS_N), 
                             .sdram_wire_dq(DRAM_DQ),   
                             .sdram_wire_dqm(DRAM_DQM),  
                             .sdram_wire_ras_n(DRAM_RAS_N),
                             .sdram_wire_we_n(DRAM_WE_N), 
                             .sdram_clk_clk(DRAM_CLK),
                             .keycode_export(keycode),  
                             .otg_hpi_address_export(hpi_addr),
                             .otg_hpi_data_in_port(hpi_data_in),
                             .otg_hpi_data_out_port(hpi_data_out),
                             .otg_hpi_cs_export(hpi_cs),
                             .otg_hpi_r_export(hpi_r),
                             .otg_hpi_w_export(hpi_w),
                             .otg_hpi_reset_export(hpi_reset)
    );
    
    // Use PLL to generate the 25MHZ VGA_CLK.
    // You will have to generate it on your own in simulation.
    vga_clk vga_clk_instance(.inclk0(Clk), .c0(VGA_CLK));
    
    // TODO: Fill in the connections for the rest of the modules 
	 logic [9:0] DrawX,DrawY;
    VGA_controller vga_controller_instance(.Clk,.Reset(Reset_h),.VGA_HS,.VGA_VS,
	 .VGA_CLK,.VGA_BLANK_N,.VGA_SYNC_N,.DrawX,.DrawY);
    
    // Which signal should be frame_clk?
	 logic is_ball;
	 logic [15:0]addr;
	 logic [15:0]plane_addr;
	 logic [15:0]enemy_addr,rz_addr;
	 logic [15:0]missle_x, missle_y;
//	 logic [15:0]missle_addr;
	 logic is_plane;
	 logic is_missle;
	 logic launch;
	 logic [15:0]missle_addr;
	 logic[9:0] char_pos;
	 logic[9:0] start_x;
	 logic[9:0] start_y;
	 logic[9:0] char_pos_y;
	 logic[15:0] bg_position;
	 logic shot1,shot2,shot3;
	 logic explored;
	 logic alive;
	 logic shot;
	 logic enemy1_alive;
	 logic is_enemy1,is_rz;
	 logic[5:0]key_status;
	 logic enter_on;
	 logic bullet1,bullet2, bullet3;
	 logic is_bullet1,is_bullet2,is_bullet3;
	 logic[15:0] bullet1_x,bullet1_y,bullet2_x,bullet2_y,bullet3_x,bullet3_y;
	 logic[1:0] bu_dir1,bu_dir2,bu_dir3;
	 logic[9:0] flag;
	 logic hide, hit,detect,save_suc;
	 logic char_alive;
    ball ball_instance(.alive,.Clk,.Reset(game_start),.frame_clk(VGA_VS),.is_ball, // character
	 .DrawX,.DrawY,.key_status,.addr,.char_pos,.bg_position,.shot1,.shot2,.shot3,.enemy1_alive,.missle_x,.missle_y,.explored,
	 .bullet1,.bullet2,.bullet3,.bu_dir1,.bu_dir2,.bu_dir3,.flag,.char_pos_y,.hide,.hit,.save_suc,.char_alive,
	 .detect,.lastp_alive,.p2_alive,.last_miss_x,.last_miss_y,.p2_miss_x,.p2_miss_y,.p2_exp,.last_miss_exp);
    
    color_mapper color_instance(.is_missle,.is_ball,.DrawX,.DrawY,.VGA_R,.VGA_G,.VGA_B, //draw 
	 .addr,.is_plane,.plane_addr,.missle_addr,.SRAM_ADDR,.SRAM_DQ,.bg_position,.enemy_addr,.is_enemy1,
	 .is_bullet1,.is_bullet2,.is_bullet3,.is_rz,.rz_addr,
	 .is_plane_last1,.last_plane_addr,.is_p2,.p2_addr,
	 .is_missle_last,.last_missle_addr,.is_p2_miss,.p2_miss_addr,
	 .start_pic,.win_end,.dead_end);
    
	 plane plane_instance(.alive,.explored,.launch,.Clk,.Reset(game_start),
	 .frame_clk(VGA_VS),.is_plane,.DrawX,.DrawY,.char_pos,.addr(plane_addr),.start_x,.start_y,
	 .bullet1_x,.bullet1_y,.bullet2_x,.bullet2_y,.bullet3_x,.bullet3_y); // plane
    
	 //missle
	 missle missle_instance(.alive,.explored,.launch,.Clk,.Reset(game_start),.frame_clk(VGA_VS),.is_missle,
	 .DrawX,.DrawY,.start_x,.start_y,.addr(missle_addr),.missle_x,.missle_y);
	 // Display keycode on hex display
	 //enemy1
	 enemy1 em1_instance(.Clk,.Reset(game_start),.frame_clk(VGA_VS),.DrawX,.DrawY,
	 .is_enemy1,.enemy_addr,.bg_position,.shot,.enemy1_alive,.flag,.hit,.camo(hide),.char_pos,.detect);
	 
	 //bullet
	 bullet bullet_instane1(.launch(shot1),.is_bullet(is_bullet1),.Clk,.frame_clk(VGA_VS),.DrawX,.DrawY,.start_x(char_pos),
	 .start_y(char_pos_y),.bullet_state(bullet1),.bullet_x(bullet1_x),.bullet_y(bullet1_y),.dir(bu_dir1));
	 
	 bullet bullet_instane2(.launch(shot2),.is_bullet(is_bullet2),.Clk,.frame_clk(VGA_VS),.DrawX,.DrawY,.start_x(char_pos),
	 .start_y(char_pos_y),.bullet_state(bullet2),.bullet_x(bullet2_x),.bullet_y(bullet2_y),.dir(bu_dir2));
	 
	 bullet bullet_instane3(.launch(shot3),.is_bullet(is_bullet3),.Clk,.frame_clk(VGA_VS),.DrawX,.DrawY,.start_x(char_pos),
	 .start_y(char_pos_y),.bullet_state(bullet3),.bullet_x(bullet3_x),.bullet_y(bullet3_y),.dir(bu_dir3));
	 
	 
	 rz rz_ins(.Clk,.Reset(game_start),.frame_clk(VGA_VS),.DrawX,.DrawY,.is_rz,.rz_addr,.detect,.bg_position,.flag,.save_suc,.char_pos);
	 
	 logic lastp_alive, last_missle_exp, last_launch, p2_alive,p2_exp,p2_launch;
	 logic[15:0] last_plane_addr, p2_addr;
	 logic[9:0] last_start_x, last_start_y;
	 logic[15:0]last_missle_addr;
	 logic[9:0] p2_x,p2_y;
//	 logic[15:0] p2_addr;
	 logic[15:0] last_miss_x,last_miss_y, p2_miss_x,p2_miss_y, p2_miss_addr;
	 logic is_p2, is_p2_miss,is_plane_last1,is_missle_last;
	 
	 plane_last_1 lastplane_ins(.alive(lastp_alive),.explored(last_miss_exp),.launch(last_launch),.Clk,.Reset(game_start),
	 .frame_clk(VGA_VS),.is_plane_last1,.DrawX,.DrawY,.char_pos,.addr(last_plane_addr),.start_x(last_start_x),.start_y(last_start_y),
	 .bullet1_x,.bullet1_y,.bullet2_x,.bullet2_y,.bullet3_x,.bullet3_y,.bg_position);
	 
	 p2 plane2(.alive(p2_alive),.explored(p2_exp),.launch(p2_launch),.Clk,.Reset(game_start),
	 .frame_clk(VGA_VS),.is_plane(is_p2),.DrawX,.DrawY,.char_pos,.addr(p2_addr),.start_x(p2_x),.start_y(p2_y),
	 .bullet1_x,.bullet1_y,.bullet2_x,.bullet2_y,.bullet3_x,.bullet3_y,.bg_position);
	 
	 
	 missle_last mis_last_ins(.alive(lastp_alive),.explored(last_miss_exp),.launch(last_launch),.Clk,.Reset(game_start),.frame_clk(VGA_VS),
	 .is_missle_last,.DrawX,.DrawY,.start_x(last_start_x),.start_y(last_start_y),.addr(last_missle_addr),
	 .missle_x(last_miss_x),.missle_y(last_miss_y)); //for plane1
	 
	 
	 missle_last p2_miss_ins(.alive(p2_alive),.explored(p2_exp),.launch(p2_launch),.Clk,.Reset(game_start),.frame_clk(VGA_VS),
	 .is_missle_last(is_p2_miss),.DrawX,.DrawY,.start_x(p2_x),.start_y(p2_y),.addr(p2_miss_addr),
	 .missle_x(p2_miss_x),.missle_y(p2_miss_y)); //for plane2
	 
	 
	 
	 read_key key_instance(.keycode,.key_status,.enter_on);
	 HexDriver hex_inst_0 (result[3:0], HEX0);
    HexDriver hex_inst_1 (result[7:4], HEX1);
	 
	 HexDriver hex_inst_2 (result[11:8], HEX2);
    HexDriver hex_inst_3 (result[15:12], HEX3);
    

	 
	 logic Init, Init_Finish, data_over;
	 logic [15:0] Ldata, Rdata;
	 
	 audio_controller audio_controller_module( 
														.Clk(CLOCK_50),
														.Reset(Reset_h), 
														.data_over(data_over),
														.LDATA(Ldata), 
														.RDATA(Rdata),
														.Init(Init),
														.Init_Finish(Init_Finish)
														);  
	 audio_interface audio( 
								.LDATA(Ldata), 
								.RDATA(Rdata),          //IN std_logic_vector(15 downto 0); -- parallel external data inputs
								.clk(CLOCK_50), 
								.Reset(Reset_h), 
								.INIT(Init),        //IN std_logic; 
								.INIT_FINISH(Init_Finish),      //OUT std_logic;
								.adc_full(),       //OUT std_logic;
								.data_over(data_over),            //OUT std_logic; -- sample sync pulse
								.AUD_MCLK(AUD_XCK),               //OUT std_logic; -- Codec master clock OUTPUT
								.AUD_BCLK(AUD_BCLK),               //IN std_logic; -- Digital Audio bit clock
								.AUD_ADCDAT(AUD_ADCDAT),      //IN std_logic;
								.AUD_DACDAT(AUD_DACDAT),             //OUT std_logic; -- DAC data line
								.AUD_DACLRCK(AUD_DACLRCK), 
								.AUD_ADCLRCK(AUD_ADCLRCK),           //IN std_logic; -- DAC data left/right select
								.I2C_SDAT(I2C_SDAT),    //OUT std_logic; -- serial interface data line
								.I2C_SCLK(I2C_SCLK),    //OUT std_logic;  -- serial interface clock
								.ADCDATA(   )     //OUT std_logic_vector(31 downto 0)
								);
	 
	 logic[15:0] result;
//	 logic p1_die,p2_die;
	 logic win_end,start_pic,dead_end,game_start;
	 score score_ins(.alive,.save_suc,.enemy1_alive,.result,.lastp_alive,.p2_alive,.game_start,.Clk,.bg_position);
	 control_unit game_ctl(.reset(Reset_h),.Clk,.enter_on,.char_alive,.p1_die(~lastp_alive),.p2_die(~p2_alive),.win_end,
	 .start_pic,.dead_end,.game_start,.bg_position);
	 
    /**************************************************************************************
        ATTENTION! Please answer the following quesiton in your lab report! Points will be allocated for the answers!
        Hidden Question #1/2:
        What are the advantages and/or disadvantages of using a USB interface over PS/2 interface to
             connect to the keyboard? List any two.  Give an answer in your Post-Lab.
    **************************************************************************************/
endmodule
