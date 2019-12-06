//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  10-06-2017                               --
//                                                                       --
//    Fall 2017 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 8                                         --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------

// color_mapper: Decide which color to be output to VGA for each pixel.
module  color_mapper ( input              is_ball,            // Whether current pixel belongs to ball 
                                                              //   or background (computed in ball.sv)
                       input        [9:0] DrawX, DrawY,       // Current pixel coordinates
                       output logic [7:0] VGA_R, VGA_G, VGA_B, // VGA RGB output
								input Clk,
								input is_plane,
								input logic[15:0] addr,
								input logic[15:0] plane_addr,
								input is_missle,
								input logic[15:0] missle_addr,
								output logic[19:0] SRAM_ADDR,
								inout wire[15:0] SRAM_DQ,
								input logic[15:0] bg_position,
								input logic[15:0] enemy_addr,rz_addr,
								input logic is_enemy1,is_rz,
								input logic is_bullet1,is_bullet2,is_bullet3,
								input logic is_plane_last1,is_p2,is_missle_last,is_p2_miss,
								input logic[15:0] last_plane_addr,p2_addr,last_missle_addr,p2_miss_addr,
								input logic start_pic,win_end,dead_end				
							);
    
    logic [7:0] Red, Green, Blue;
    logic in_range;
    // Output colors to VGA
    assign VGA_R = Red;
    assign VGA_G = Green;
    assign VGA_B = Blue;
    
	 logic[23:0] data_out;
	 
//	 assign addr = DrawX + DrawY * 10'd20;
//	 always_comb
//	 begin
//	 if(DrawX < 10'd20 && DrawY < 10'd20)
//		 in_range = 1;
//	 else
//	    in_range = 0;
//	 end
	 frameROM rom(.addr,.data_out,.in_range(is_ball),.DrawX,.DrawY,.is_plane,.plane_addr,.missle_addr,
	 .is_missle,.SRAM_ADDR,.SRAM_DQ,.bg_position,.enemy_addr,.is_enemy1,.is_bullet1,.is_bullet2,.is_bullet3,
	 .is_rz,.rz_addr,
	 .is_plane_last1,.last_plane_addr,.is_p2,.p2_addr,
	 .is_missle_last,.last_missle_addr,.is_p2_miss,.p2_miss_addr,
	 .start_pic,.win_end,.dead_end);
    // Assign color based on is_ball signal
    always_comb
    begin
            Red = data_out[23:16];//8'hff;
            Green = data_out[15:8];//8'hff;
            Blue = data_out[7:0];//8'hff;
    end 
    
endmodule
