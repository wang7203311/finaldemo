

//-------------------------------------------------------------------------
//    Ball.sv                                                            --
//    Viral Mehta                                                        --
//    Spring 2005                                                        --
//                                                                       --
//    Modified by Stephen Kempf 03-01-2006                               --
//                              03-12-2007                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  12-08-2017                               --
//    Spring 2018 Distribution                                           --
//                                                                       --
//    For use with ECE 385 Lab 8                                         --
//    UIUC ECE Department                                                --
//-------------------------------------------------------------------------


module  ball ( input         Clk,                // 50 MHz clock
                             Reset,              // Active-high reset signal
                             frame_clk,          // The clock indicating a new frame (~60Hz)
               input [9:0]   DrawX, DrawY,       // Current pixel coordinates
               output logic  is_ball,            // Whether current pixel belongs to ball or background
					input logic[5:0] key_status,
					output logic[15:0]addr,
					output logic[9:0] char_pos,
					output logic[15:0] bg_position,
					output logic shot1,shot2,shot3,
					input logic alive,
					input logic enemy1_alive, explored,
					input logic[15:0] missle_x, missle_y,
					output logic[9:0] char_pos_y,
					input logic bullet1,bullet2,bullet3,
					output logic[1:0] bu_dir1,bu_dir2,bu_dir3,
//					output logic shot, //debug use----------------------------------
					output logic[9:0] flag,
					output logic hit, hide,	
					input logic save_suc,
					output logic char_alive,
					input logic detect,
					input logic lastp_alive,p2_alive,p2_exp,last_miss_exp,
					input logic[15:0] last_miss_x, last_miss_y,p2_miss_x,p2_miss_y
				  );
    
    parameter [9:0] Ball_X_Center = 10'd60;  // Center position on the X axis
    parameter [9:0] Ball_Y_Center = 10'd380;  // Center position on the Y axis
    parameter [9:0] Ball_X_Min = 10'd0;       // Leftmost point on the X axis
    parameter [9:0] Ball_X_Max = 10'd639;     // Rightmost point on the X axis
    parameter [9:0] Ball_Y_Min = 10'd0;       // Topmost point on the Y axis
    parameter [9:0] Ball_Y_Max = 10'd429;     // Bottommost point on the Y axis
    parameter [9:0] Ball_X_Step = 10'd2;      // Step size on the X axis
    parameter [9:0] Ball_Y_Step = 10'd1;      // Step size on the Y axis
    parameter [9:0] Ball_Size_X = 10'd27;        // Ball size
	 parameter [9:0] Ball_Size_Y = 10'd38;
    
    logic [9:0] Ball_X_Pos, Ball_X_Motion, Ball_Y_Pos, Ball_Y_Motion;
    logic [9:0] Ball_X_Pos_in, Ball_X_Motion_in, Ball_Y_Pos_in, Ball_Y_Motion_in;
    logic [15:0] bg_position_in, bg_motion, bg_motion_in, move_counter, move_counter_in, off_set;
	 logic[1:0] dir, dir_in;
	 logic state, state_in; // 1 for right 0 for left
	 logic move,up_enable;
	 logic[1:0] bullet_remain, bullet_remain_in;
	 logic [9:0] enemy_count, enemy_count_in;
	 logic camo,camo_in;
    //////// Do not modify the always_ff blocks. ////////
    // Detect rising edge of frame_clk
    logic frame_clk_delayed, frame_clk_rising_edge;
    always_ff @ (posedge Clk) begin
        frame_clk_delayed <= frame_clk;
        frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
    end
    // Update registers
    always_ff @ (posedge Clk)
    begin
        if (Reset)
        begin
            Ball_X_Pos <= Ball_X_Center;
            Ball_Y_Pos <= Ball_Y_Center;
            Ball_X_Motion <= 10'd1;
            Ball_Y_Motion <= 10'd0;
				bg_position <= 16'd0;
				bg_motion <= 16'd0;
				dir <= 2'b1;
				move_counter <= 16'd0;
				state <= 1'b1; //alive
				bullet_remain <= 2'd3;
				enemy_count <= 10'd0;
				camo <= 1'b0;
        end
        else
        begin
            Ball_X_Pos <= Ball_X_Pos_in;
            Ball_Y_Pos <= Ball_Y_Pos_in;
            Ball_X_Motion <= Ball_X_Motion_in;
            Ball_Y_Motion <= Ball_Y_Motion_in;
				bg_position <= bg_position_in;
				bg_motion <= bg_motion_in;
				dir <= dir_in;
				move_counter <= move_counter_in;
				state <= state_in;
				bullet_remain <= bullet_remain_in;
				enemy_count <= enemy_count_in;
				camo <= camo_in;
        end
    end
    //////// Do not modify the always_ff blocks. ////////
    
    // You need to modify always_comb block.
    always_comb
    begin
        // By default, keep motion and position unchanged
        Ball_X_Pos_in = Ball_X_Pos;
        Ball_Y_Pos_in = Ball_Y_Pos;
		  Ball_X_Motion_in = Ball_X_Motion;
		  Ball_Y_Motion_in = Ball_Y_Motion;
        bg_position_in = bg_position;
		  bg_motion_in = bg_motion;
		  move = 1'b1;
		  up_enable = 1'b0;
		  if(move_counter != 16'd40)
				move_counter_in = move_counter;
		  else
				move_counter_in = 16'd0;
		  dir_in = dir;
		  shot1 = 1'b0;
		  shot2 = 1'b0;
		  shot3 = 1'b0;
//		  shot = 1'b0;
		  bu_dir1 = dir;
		  bu_dir2 = dir;
		  hit = 1'b0;
		  camo_in = camo;
		  bu_dir3 = dir;
        // Update position and motion only at rising edge of frame clock
        if (frame_clk_rising_edge)
        begin
            // Be careful when using comparators with "logic" datatype because compiler treats 
            //   both sides of the operator as UNSIGNED numbers.
            // e.g. Ball_Y_Pos - Ball_Size <= Ball_Y_Min 
            // If Ball_Y_Pos is 0, then Ball_Y_Pos - Ball_Size will not be -4, but rather a large positive number.
            if( Ball_Y_Pos + Ball_Size_Y >= Ball_Y_Max )  // Ball is at the bottom edge, BOUNCE!
                Ball_Y_Motion_in = (~(Ball_Y_Step) + 1'b1);  // 2's complement.
//					 Ball_X_Motion_in = 10'd0;
            else if ( Ball_Y_Pos <= Ball_Y_Min + Ball_Size_Y )  // Ball is at the top edge, BOUNCE!
                Ball_Y_Motion_in = Ball_Y_Step;
//					 Ball_X_Motion_in = 10'd0;
            // TODO: Add other boundary detections and handle keypress here.
				else if(Ball_X_Pos + Ball_Size_X >= Ball_X_Max) //right edge
					  Ball_X_Motion_in = ((~(Ball_X_Step) + 1'b1));
//					  Ball_Y_Motion_in = 10'd0;
				else if(Ball_X_Pos <= Ball_X_Min + Ball_Size_X)
						Ball_X_Motion_in = Ball_X_Step;
//						Ball_Y_Motion_in = 10'd0;
		  
				//w a s d space h
//				//shot
				if(key_status[1] == 1'b1 && bg_position > 16'd650 && enemy1_alive == 1'b1)
						camo_in = 1'b1;
				if(key_status[0] == 1'b1)
						begin
						camo_in = 1'b0;
						if(bg_position > 16'd650 && enemy1_alive == 1'b1)
						hit = 1'b1;
						else
						begin
						bg_motion_in = 16'd0;
						Ball_X_Motion_in = 10'd0;
						Ball_Y_Motion_in = 10'd0;
//						shot = 1'b1;
						move_counter_in = 16'd0;
						move = 1'b0;
						if(bullet1 == 1'b0)
						begin
						shot1 = 1'b1;
//						shot = 1'b1;
						end
						else if(bullet2 == 1'b0)
						begin
						shot2 = 1'b1;
//						shot = 1'b1;
						end
						else if(bullet3 == 1'b0)
						begin
						shot3 = 1'b1;
//						shot = 1'b1;
						end
						end
						
						end
				//up //w
//				6'b100000:
				if(key_status[5] == 1'b1)
						begin
						camo_in = 1'b0;
						up_enable = 1'b1;
						Ball_X_Motion_in = 10'd0;
						Ball_Y_Motion_in = 10'd0;
						move_counter_in = 16'd0;
						move = 1'b0;
						bg_motion_in = 16'd0;
						dir_in = 2'b10;
//						shot = 1'b1;
						end
				//left//a
//				6'b010000:
				else if(key_status[4] == 1'b1)
						begin
						camo_in = 1'b0;
						move_counter_in = move_counter + 16'b1;
						Ball_Y_Motion_in = 0;
						bg_motion_in = 0;
						dir_in = 2'b0;
						if( Ball_Y_Pos <= Ball_Y_Min + Ball_Size_Y) //top bound
						begin
						Ball_Y_Motion_in = Ball_Y_Step;
						Ball_X_Motion_in = 0;
						end
		
						else if(Ball_Y_Pos + Ball_Size_Y >= Ball_Y_Max ) //bot bound
						begin
						Ball_Y_Motion_in = ((~(Ball_Y_Step) + 1'b1));
						Ball_X_Motion_in = 0;
						end
						
						else if(Ball_X_Pos + Ball_Size_X >= Ball_X_Max) //right bound
						begin
						Ball_Y_Motion_in = 0;
						Ball_X_Motion_in = ((~(Ball_X_Step) + 1'b1));
						end
						
						else if(Ball_X_Pos <= Ball_Y_Min + Ball_Size_X)//left bound
						begin
						Ball_Y_Motion_in = 0;
						Ball_X_Motion_in = Ball_X_Step;
						end
						
						else if(bg_position_in > 16'd4 && bg_position < 16'd648)
						begin
						Ball_Y_Motion_in = 0;
						Ball_X_Motion_in = 0;
						bg_motion_in = ((~(Ball_X_Step) + 1'b1));
						end
						
						else if(bg_position_in > 16'd4 && (enemy1_alive == 1'b0 && save_suc == 1'b0))
						begin
						Ball_Y_Motion_in = 0;
						Ball_X_Motion_in = 0;
						bg_motion_in = ((~(Ball_X_Step) + 1'b1));
						end
						
						else
						begin
						Ball_Y_Motion_in = 0;
						Ball_X_Motion_in = ((~(Ball_X_Step) + 1'b1));
						end
						
						end
				//right//d
//				6'b000100:
				else if(key_status[2] == 1'b1)
					begin
						camo_in = 1'b0;
						Ball_Y_Motion_in = 0;
						bg_motion_in = 0;
						dir_in = 2'b1;
						move_counter_in = move_counter + 16'b1;
						if( Ball_Y_Pos <= Ball_Y_Min + Ball_Size_Y) //top bound
						begin
						Ball_Y_Motion_in = Ball_Y_Step;
						Ball_X_Motion_in = 0;
						end
		
						else if(Ball_Y_Pos + Ball_Size_Y >= Ball_Y_Max ) //bot bound
						begin
						Ball_Y_Motion_in = ((~(Ball_Y_Step) + 1'b1));
						Ball_X_Motion_in = 0;
						end
						
						else if(Ball_X_Pos + Ball_Size_X >= Ball_X_Max) //right bound
						begin
						Ball_Y_Motion_in = 0;
						Ball_X_Motion_in = ((~(Ball_X_Step) + 1'b1));
						end
						
						else if(Ball_X_Pos <= Ball_Y_Min + Ball_Size_X)//left bound
						begin
						Ball_Y_Motion_in = 0;
						Ball_X_Motion_in = Ball_X_Step;
						end
						
						
						
						
						else if(Ball_X_Pos > 10'd200 && alive == 1'b0 && bg_position < 16'd652)
						begin
						
						if(Ball_X_Pos > 10'd250)
						begin
						Ball_Y_Motion_in = 0;
						Ball_X_Motion_in = ((~(10'd1) + 1'b1));
						bg_motion_in = 10'd2;
						end
						else
						begin
						Ball_Y_Motion_in = 0;
						Ball_X_Motion_in = 0;
						bg_motion_in = 10'd2;
						end
						end
						
						
						else if(Ball_X_Pos > 10'd200 && alive == 1'b0 && (enemy1_alive == 1'b0 && save_suc == 1'b1) && bg_position < 16'd1304)
						begin
						if(Ball_X_Pos > 10'd250)
						begin
						Ball_Y_Motion_in = 0;
						Ball_X_Motion_in = ((~(Ball_X_Step) + 1'b1));
						bg_motion_in = 10'd2;
						end
						else
						begin
						Ball_Y_Motion_in = 0;
						Ball_X_Motion_in = 0;
						bg_motion_in = 10'd2;
						end
						end
						
						
						
						
						
						else
						begin
						Ball_Y_Motion_in = 0;
						Ball_X_Motion_in = Ball_X_Step;
						end
						
						end
					else
						begin
//						camo_in = 1'b0;
						Ball_X_Motion_in = 10'd0;
						Ball_Y_Motion_in = 10'd0;
						bg_motion_in = 10'd0;
						move_counter_in = 0;
						move = 1'b1;
						end
		  
            // Update the ball's position with its motion
            Ball_X_Pos_in = Ball_X_Pos + Ball_X_Motion;
            Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion;
				bg_position_in = bg_position + bg_motion;
        end
        
        /**************************************************************************************
            ATTENTION! Please answer the following quesiton in your lab report! Points will be allocated for the answers!
            Hidden Question #2/2:
               Notice that Ball_Y_Pos is updated using Ball_Y_Motion. 
              Will the new value of Ball_Y_Motion be used when Ball_Y_Pos is updated, or the old? 
              What is the difference between writing
                "Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion;" and 
                "Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion_in;"?
              How will this impact behavior of the ball during a bounce, and how might that interact with a response to a keypress?
              Give an answer in your Post-Lab.
        **************************************************************************************/
    end
	 
	 always_comb
	 begin
	 if(move_counter < 16'd10)
	 begin
		
		if(key_status[0] == 1'b1)
		off_set = 16'd16416;
		else
		off_set = 16'd0;
	 end
	 else if(move_counter > 16'd9 && move_counter < 16'd20)
		off_set = 16'd4104;
	 else if(move_counter > 16'd19 && move_counter < 16'd30)
	   off_set = 16'd8208;
	 else
		begin
		
		if(key_status[0] == 1'b1)
		off_set = 16'd16416;
		else
		off_set = 16'd12312;
		end
	 end
	 
    
    // Compute whether the pixel corresponds to ball or background
    /* Since the multiplicants are required to be signed, we have to first cast them
       from logic to int (signed by default) before they are multiplied. */
    int DistX, DistY, Size;
    assign DistX = DrawX - Ball_X_Pos + 10'd27;
    assign DistY = DrawY - Ball_Y_Pos + 10'd38;
//    assign Size = Ball_Size;
    always_comb begin
//        if ( ( DistX*DistX + DistY*DistY) <= (Size*Size) ) 
			if(DistX < 10'd54 && DistX > 10'd0 && DistY < 10'd76 && DistY > 10'd0 && state == 1'b1 && camo == 1'b0)
            is_ball = 1'b1;
        else
            is_ball = 1'b0;
        /* The ball's (pixelated) circle is generated using the standard circle formula.  Note that while 
           the single line is quite powerful descriptively, it causes the synthesis tool to use up three
           of the 12 available multipliers on the chip! */
    end
		always_comb
		begin
		if(key_status[4] == 1'b1 || key_status[2] == 1'b1)
		begin
		if(dir == 1'b1) // right
		begin
			addr = DistY*16'd54 + DistX + off_set;
		end
		else // left
		begin
			addr = DistY*16'd54 + 16'd54 - DistX + off_set;
		end
		end
		else if(key_status[5] == 1'b1)
		begin
			addr = DistY*16'd54 + DistX + 16'd20520;
		end
		else
			begin
			if(dir == 1'b1) // right
			addr = DistY*16'd54 + DistX + 16'd16416;
			else // left
			addr = DistY*16'd54 + 16'd54 - DistX + 16'd16416;
			end
		end
	
	always_comb
	begin
	state_in = state;
	if((missle_y + 16'd40) > Ball_Y_Pos && explored == 1'b0 && alive == 1'b1 && bg_position == 16'd0)
	begin
		if(missle_x > Ball_X_Pos && missle_x < (Ball_X_Pos + 16'd54))
			state_in = 1'b0;
		else if((missle_x + 16'd12)> Ball_X_Pos && (missle_x+16'd12) < (Ball_X_Pos + 16'd54))
			state_in = 1'b0;
	end
	
	else if((last_miss_y + 16'd40) > Ball_Y_Pos && lastp_alive == 1'b1 && bg_position > 16'd1300 && last_miss_exp== 1'b0)
	begin
		if(last_miss_x > Ball_X_Pos && last_miss_x < (Ball_X_Pos + 16'd54))
			state_in = 1'b0;
		else if((last_miss_x + 16'd12)> Ball_X_Pos && (last_miss_x+16'd12) < (Ball_X_Pos + 16'd54))
			state_in = 1'b0;
	end
	
	else if((p2_miss_y + 16'd40) > Ball_Y_Pos && p2_alive == 1'b1 && bg_position > 16'd1300 && p2_exp == 1'b0)
	begin
		if(p2_miss_x > Ball_X_Pos && p2_miss_x < (Ball_X_Pos + 16'd54))
			state_in = 1'b0;
		else if((p2_miss_x + 16'd12)> Ball_X_Pos && (p2_miss_x+16'd12) < (Ball_X_Pos + 16'd54))
			state_in = 1'b0;
	end
	
	else if(detect == 1'b1 && bg_position > 16'd650)
		state_in = 1'b0;
	
	end
	
	
//	always_comb
//	begin
////	shot = 1'b0;
//	shot1 = 1'b0;
//	shot2 = 1'b0;
//	shot3 = 1'b0;
//	
//	
//	end
		

		always_comb
		begin
		if(bg_position > 16'd650 && bg_position < 16'd654)
		enemy_count_in = enemy_count + 10'd1;
		else
		enemy_count_in = enemy_count;
		end
		
		assign char_pos = Ball_X_Pos;
		assign char_pos_y = Ball_Y_Pos;
		assign flag = enemy_count;
		assign hide = camo;
		assign char_alive = state;
endmodule
