module enemy1(
input         Clk,                // 50 MHz clock
                             Reset,              // Active-high reset signal
                             frame_clk,          // The clock indicating a new frame (~60Hz)
               input [9:0]   DrawX, DrawY,       // Current pixel coordinates
               output logic  is_enemy1,            // Whether current pixel belongs to enemy1 or background
//					input logic[9:0] char_pos,
					output logic[15:0]enemy_addr,
					input logic[15:0]bg_position,
					input logic shot,
					output logic enemy1_alive,
					input logic[9:0]flag,
//					input logic[15:0] bullet1_x,bullet1_y,bullet2_x,bullet2_y,bullet3_x,bullet3_y,
					input logic hit,
					input logic[9:0] char_pos,
					input logic camo,
					output logic detect
);
	 parameter [9:0] enemy1_X_Center = 10'd550;  // Center position on the X axis
    parameter [9:0] enemy1_Y_Center = 10'd385;  // Center position on the Y axis
    parameter [9:0] enemy1_X_Min = 10'd350;       // Leftmost point on the X axis
    parameter [9:0] enemy1_X_Max = 10'd639;     // Rightmost point on the X axis
    parameter [9:0] enemy1_Y_Min = 10'd0;       // Topmost point on the Y axis
    parameter [9:0] enemy1_Y_Max = 10'd469;     // Bottommost point on the Y axis
    parameter [9:0] enemy1_X_Step = 10'd1;      // Step size on the X axis
    parameter [9:0] enemy1_Y_Step = 10'd1;      // Step size on the Y axis
    parameter [9:0] enemy1_Size_X = 10'd30;        // enemy1 size
	 parameter [9:0] enemy1_Size_Y = 10'd27;



	 logic [9:0] enemy1_X_Pos, enemy1_X_Motion, enemy1_Y_Pos, enemy1_Y_Motion;
    logic [9:0] enemy1_X_Pos_in, enemy1_X_Motion_in, enemy1_Y_Pos_in, enemy1_Y_Motion_in,state,state_in;
	 logic[15:0]  move_counter, move_counter_in,off_set;
	 logic dir, dir_in;
	 logic d,d_in;
	 
	 
	 logic frame_clk_delayed, frame_clk_rising_edge;
    always_ff @ (posedge Clk) begin
        frame_clk_delayed <= frame_clk;
        frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
    end
	 always_ff @ (posedge Clk)
    begin
        if (bg_position == 16'd650 && flag == 10'd0)
        begin
            enemy1_X_Pos <= enemy1_X_Center;
            enemy1_Y_Pos <= enemy1_Y_Center;
            enemy1_X_Motion <= 10'd1;
            enemy1_Y_Motion <= 10'd0;
				state <= 1'b1;
				dir <= 1'b1; //right
				d <= 1'b0;
//				move_counter <= 16'd0;
        end
        else
        begin
            enemy1_X_Pos <= enemy1_X_Pos_in;
            enemy1_Y_Pos <= enemy1_Y_Pos_in;
            enemy1_X_Motion <= enemy1_X_Motion_in;
            enemy1_Y_Motion <= enemy1_Y_Motion_in;
				state <= state_in;
				dir <= dir_in;
				d <= d_in;
//				move_counter <= move_counter_in;
        end
    end
//	 always_comb
//	 begin
//	 end
	 
	  always_comb
    begin
        // By default, keep motion and position unchanged
        enemy1_X_Pos_in = enemy1_X_Pos;
        enemy1_Y_Pos_in = enemy1_Y_Pos;
		  enemy1_X_Motion_in = enemy1_X_Motion;
		  enemy1_Y_Motion_in = enemy1_Y_Motion;
        state_in = state;
		  dir_in = dir;
		  d_in = d;
		  
		  if(move_counter != 16'd20)
				move_counter_in = move_counter;
		  else
				move_counter_in = 16'd0;
		  
        // Update position and motion only at rising edge of frame clock
        if (frame_clk_rising_edge)
        begin
            // Be careful when using comparators with "logic" datatype because compiler treats 
            //   both sides of the operator as UNSIGNED numbers.
            // e.g. enemy1_Y_Pos - enemy1_Size <= enemy1_Y_Min 
            // If enemy1_Y_Pos is 0, then enemy1_Y_Pos - enemy1_Size will not be -4, but rather a large positive number.
            if( enemy1_Y_Pos + enemy1_Size_Y >= enemy1_Y_Max )  // enemy1 is at the bottom edge, BOUNCE!
					 enemy1_Y_Motion_in = (~(enemy1_Y_Step) + 1'b1);  // 2's complement.
//					 enemy1_X_Motion_in = 10'd0;
            else if ( enemy1_Y_Pos <= enemy1_Y_Min + enemy1_Size_Y )  // enemy1 is at the top edge, BOUNCE!
                enemy1_Y_Motion_in = enemy1_Y_Step;
//					 enemy1_X_Motion_in = 10'd0;
            // TODO: Add other boundary detections and handle keypress here.
				else if(enemy1_X_Pos + enemy1_Size_X >= enemy1_X_Max) //right edge
					  begin
					  dir_in = 1'b0;//left
					  enemy1_X_Motion_in = ((~(enemy1_X_Step) + 1'b1));
					  end
//					  enemy1_Y_Motion_in = 10'd0;
				else if(enemy1_X_Pos <= enemy1_X_Min + enemy1_Size_X)
						begin
						enemy1_X_Motion_in = enemy1_X_Step;
						dir_in = 1'b1;//right
						end
//						enemy1_Y_Motion_in = 10'd0;
//				move_counter_in = move_counter + 16'b1;
		  
				
//				if((bullet1_x > enemy1_X_Pos && bullet1_x < (enemy1_X_Pos + 16'd60)) ||
//					(bullet2_x > enemy1_X_Pos && bullet2_x < (enemy1_X_Pos + 16'd52)) ||
//					(bullet3_x > enemy1_X_Pos && bullet3_x < (enemy1_X_Pos + 16'd52)))
//				state_in = 1'b0;
//				else if(((bullet1_x + 16'd6)> enemy1_X_Pos && (bullet1_x+16'd6) < (enemy1_X_Pos + 16'd52)) ||
//						  ((bullet2_x + 16'd6)> enemy1_X_Pos && (bullet2_x+16'd6) < (enemy1_X_Pos + 16'd52)) ||
//						  ((bullet3_x + 16'd6)> enemy1_X_Pos && (bullet3_x+16'd6) < (enemy1_X_Pos + 16'd52))
//						  )
//				state_in = 1'b0;
//				end
				if(hit == 1'b1)
				begin
				if(char_pos > enemy1_X_Pos && char_pos < (enemy1_X_Pos + 16'd60))
					state_in = 1'b0;
				else if((char_pos + 16'd54)> enemy1_X_Pos && (char_pos+16'd54) < (enemy1_X_Pos + 16'd60))
					state_in = 1'b0;
				end
				
				//detect
				if(dir == 1'b1 && char_pos > enemy1_X_Pos && camo == 1'b0 && state == 1'b1) //right
				d_in = 1'b1;
				else if (dir == 1'b0 && char_pos < enemy1_X_Pos && camo == 1'b0 && state == 1'b1)
				begin
				d_in = 1'b1;
				end
				
			   enemy1_X_Pos_in = enemy1_X_Pos + enemy1_X_Motion;
            enemy1_Y_Pos_in = enemy1_Y_Pos + enemy1_Y_Motion;
        end
		end

		
//		
//		 always_comb
//	 begin
//	 if(move_counter < 16'd10)
//	 begin
//		off_set = 16'd0;
//	 end
//	 else
//		off_set = 16'd3240;
//	 end
//		
		
		
		
		int DistX, DistY, Size;
    assign DistX = DrawX - enemy1_X_Pos + 10'd30;
    assign DistY = DrawY - enemy1_Y_Pos + 10'd27;
//    assign Size = enemy1_Size;
    always_comb begin
//        if ( ( DistX*DistX + DistY*DistY) <= (Size*Size) ) 
			if(DistX < 10'd60 && DistX > 10'd0 && DistY < 10'd54 && DistY > 10'd0 && state_in == 1'b1 && bg_position > 16'd650)
            is_enemy1 = 1'b1;
        else
            is_enemy1 = 1'b0;
        /* The enemy1's (pixelated) circle is generated using the standard circle formula.  Note that while 
           the single line is quite powerful descriptively, it causes the synthesis tool to use up three
           of the 12 available multipliers on the chip! */
    end
	assign enemy1_alive = state;
//	always_comb
//	begin
//	if(dir == 1'b1)
//	 enemy_addr = DistY*16'd60 + 16'd60 - DistX + 16'd34372;
//	else
//	 enemy_addr = DistX + DistY*16'd60 + 16'd34372;
//	end
////	assign enemy_addr = DistX + DistY*16'd60;
	assign detect = d;
endmodule
