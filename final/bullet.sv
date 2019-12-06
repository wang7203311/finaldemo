module bullet(
input launch,
output is_bullet,
input         Clk,                // 50 MHz clock
                                    // Active-high reset signal
                             frame_clk,          // The clock indicating a new frame (~60Hz)
               input [9:0]   DrawX, DrawY,       // Current pixel coordinates
input logic[9:0]start_x,
input logic[9:0]start_y,
output logic explored,
output logic[15:0]bullet_x,bullet_y,
input logic [1:0] dir,//00 = up, 01 == left, 10 == right
output logic bullet_state//0 for done
);
//	 parameter [9:0] bullet_X_Center = start_x;  // Center position on the X axis
//    parameter [9:0] bullet_Y_Center = start_x;  // Center position on the Y axis
    parameter [9:0] bullet_X_Min = 10'd0;       // Leftmost point on the X axis
    parameter [9:0] bullet_X_Max = 10'd639;     // Rightmost point on the X axis
    parameter [9:0] bullet_Y_Min = 10'd0;       // Topmost point on the Y axis
    parameter [9:0] bullet_Y_Max = 10'd469;     // Bottommost point on the Y axis
    parameter [9:0] bullet_X_Step = 10'd5;      // Step size on the X axis
    parameter [9:0] bullet_Y_Step = 10'd5;      // Step size on the Y axis
    parameter [9:0] bullet_Size_X = 10'd3;        // bullet size
	 parameter [9:0] bullet_Size_Y = 10'd3;
	
	 logic [9:0] bullet_X_Pos, bullet_X_Motion, bullet_Y_Pos, bullet_Y_Motion;
    logic [9:0] bullet_X_Pos_in, bullet_X_Motion_in, bullet_Y_Pos_in, bullet_Y_Motion_in;
	 logic state, state_in;
	 logic frame_clk_delayed, frame_clk_rising_edge;
    always_ff @ (posedge Clk) begin
        frame_clk_delayed <= frame_clk;
        frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
    end
	 
	 always_ff @ (posedge Clk)
    begin
        if (launch)
        begin
				case(dir)
				2'b10://up
				begin
            bullet_X_Pos <= start_x+10'd10;
            bullet_Y_Pos <= start_y;
				end
				2'b00://left
				begin
				bullet_X_Pos <= start_x;
            bullet_Y_Pos <= start_y+10'd10;
				end
				2'b01://right
				begin
				bullet_X_Pos <= start_x + 10'd40;
            bullet_Y_Pos <= start_y+10'd10;
				end
				default:
				begin
				bullet_X_Pos <= start_x;
            bullet_Y_Pos <= start_y+10'd10;
				end
				endcase
				
				case(dir)
				2'b10://up
				begin
				bullet_X_Motion <= 10'd0;
            bullet_Y_Motion <= (~(bullet_Y_Step) + 1'b1);
				end
				2'b00://left
				begin
				bullet_X_Motion <= (~(bullet_X_Step) + 1'b1);
            bullet_Y_Motion <= 10'd0;
				end
				2'b01://right
				begin
				bullet_X_Motion <= bullet_X_Step;
            bullet_Y_Motion <= 10'd0;
				end
				default:
				begin
				bullet_X_Motion <= bullet_X_Step;
            bullet_Y_Motion <= 10'd0;
				end
				endcase
				state <= 1'b1;
        end
        else
        begin
            bullet_X_Pos <= bullet_X_Pos_in;
            bullet_Y_Pos <= bullet_Y_Pos_in;
            bullet_X_Motion <= bullet_X_Motion_in;
            bullet_Y_Motion <= bullet_Y_Motion_in;
				state <= state_in;
//				state_count <= next_state_count;
        end
    end
	 
	 
	 always_comb
    begin
        // By default, keep motion and position unchanged
        bullet_X_Pos_in = bullet_X_Pos;
        bullet_Y_Pos_in = bullet_Y_Pos;
		  bullet_X_Motion_in = bullet_X_Motion;
		  bullet_Y_Motion_in = bullet_Y_Motion;
        state_in = state;
        // Update position and motion only at rising edge of frame clock
        if (frame_clk_rising_edge)
        begin
            // Be careful when using comparators with "logic" datatype because compiler treats 
            //   both sides of the operator as UNSIGNED numbers.
            // e.g. bullet_Y_Pos - bullet_Size <= bullet_Y_Min 
            // If bullet_Y_Pos is 0, then bullet_Y_Pos - bullet_Size will not be -4, but rather a large positive number.
            if( bullet_Y_Pos + bullet_Size_Y >= bullet_Y_Max )  // bullet is at the bottom edge, BOUNCE!
                state_in = 1'b0;
            else if ( bullet_Y_Pos <= bullet_Y_Min + bullet_Size_Y )  // bullet is at the top edge, BOUNCE!
                state_in = 1'b0;
            // TODO: Add other boundary detections and handle keypress here.
				if(bullet_X_Pos + bullet_Size_X >= bullet_X_Max) //right edge
					  state_in = 1'b0;
				else if(bullet_X_Pos <= bullet_X_Min + bullet_Size_X)
					begin
					state_in = 1'b0;
					end
			 bullet_X_Pos_in = bullet_X_Pos + bullet_X_Motion;
          bullet_Y_Pos_in = bullet_Y_Pos + bullet_Y_Motion;
		end
	end
	
	int DistX, DistY, Size;
   assign DistX = DrawX - bullet_X_Pos + 10'd3;
   assign DistY = DrawY - bullet_Y_Pos + 10'd3;
//    assign Size = bullet_Size;
   always_comb begin
//        if ( ( DistX*DistX + DistY*DistY) <= (Size*Size) ) 
			if(DistX < 10'd6 && DistX > 10'd0 && DistY < 10'd6 && DistY > 10'd0 && state == 1'b1)
            is_bullet = 1'b1;
        else
            is_bullet = 1'b0;
        /* The bullet's (pixelated) circle is generated using the standard circle formula.  Note that while 
           the single line is quite powerful descriptively, it causes the synthesis tool to use up three
           of the 12 available multipliers on the chip! */
    end
		
//	always_comb
//	begin
//	if(bullet_Y_Pos < 10'd400)
//	explored = 1'b0;
//	else
//	explored = 1'b1;
//	end
always_comb
begin
if(state == 1'b1)
begin
bullet_x = bullet_X_Pos;
bullet_y = bullet_Y_Pos;
end
else
begin
bullet_x = 16'd0;
bullet_y = 16'd450;
end
end

assign bullet_state = state;
endmodule
