module rz(
input         Clk,                // 50 MHz clock
                             Reset,              // Active-high reset signal
                             frame_clk,          // The clock indicating a new frame (~60Hz)
               input [9:0]   DrawX, DrawY,       // Current pixel coordinates
               output logic  is_rz,            // Whether current pixel belongs to rz or background
//					input logic[9:0] char_pos,
					output logic[15:0] rz_addr,
					input logic[15:0]  bg_position,
					input logic detect,
//					output logic rz_alive,
					input logic[9:0]flag,
					input logic[9:0]char_pos,
					output logic save_suc
//					output logic[15:0] rz_addr
);

	 parameter [9:0] rz_X_Center = 10'd550;  // Center position on the X axis
    parameter [9:0] rz_Y_Center = 10'd380;  // Center position on the Y axis
    parameter [9:0] rz_X_Min = 10'd500;       // Leftmost point on the X axis
    parameter [9:0] rz_X_Max = 10'd639;     // Rightmost point on the X axis
    parameter [9:0] rz_Y_Min = 10'd0;       // Topmost point on the Y axis
    parameter [9:0] rz_Y_Max = 10'd469;     // Bottommost point on the Y axis
    parameter [9:0] rz_X_Step = 10'd1;      // Step size on the X axis
    parameter [9:0] rz_Y_Step = 10'd1;      // Step size on the Y axis
    parameter [9:0] rz_Size_X = 10'd25;        // rz size
	 parameter [9:0] rz_Size_Y = 10'd29;

	  logic [9:0] rz_X_Pos, rz_X_Motion, rz_Y_Pos, rz_Y_Motion;
    logic [9:0] rz_X_Pos_in, rz_X_Motion_in, rz_Y_Pos_in, rz_Y_Motion_in;
	 
	 
	 
	 logic frame_clk_delayed, frame_clk_rising_edge,state,state_in,save,save_in;
    always_ff @ (posedge Clk) begin
        frame_clk_delayed <= frame_clk;
        frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
    end
	
	  always_ff @ (posedge Clk)
    begin
        if (bg_position == 16'd650 && flag == 10'd0)
        begin
            rz_X_Pos <= rz_X_Center;
            rz_Y_Pos <= rz_Y_Center;
				state <= 1'b1;
				save <= 1'b0;
        end
        else
        begin
            rz_X_Pos <= rz_X_Pos_in;
            rz_Y_Pos <= rz_Y_Pos_in;
				state <= state_in;
				save <= save_in;
        end
    end
	 
	 
	 
	 always_comb
    begin
        // By default, keep motion and position unchanged
        rz_X_Pos_in = rz_X_Pos;
        rz_Y_Pos_in = rz_Y_Pos;
        state_in = state;
		  save_in = save;
        // Update position and motion only at rising edge of frame clock
        if (frame_clk_rising_edge)
        begin
		  
			if(detect)
				begin
				state_in = 1'b0;
				end
			
			if(char_pos > rz_X_Pos && char_pos < (rz_X_Pos + 16'd60) && state == 1'b1)
					save_in = 1'b1;
			else if((char_pos + 16'd54)> rz_X_Pos && (char_pos+16'd54) < (rz_X_Pos + 16'd60) && state == 1'b1)
				begin
					save_in = 1'b1;
				end
			 rz_X_Pos_in = rz_X_Pos;
          rz_Y_Pos_in = rz_Y_Pos;
		end
	end
	
	 
	 
	 
	 

	 
		int DistX, DistY, Size;
    assign DistX = DrawX - rz_X_Pos + 10'd25;
    assign DistY = DrawY - rz_Y_Pos + 10'd29;
//    assign Size = rz_Size;
    always_comb begin
//        if ( ( DistX*DistX + DistY*DistY) <= (Size*Size) ) 
			if(DistX < 10'd50 && DistX > 10'd0 && DistY < 10'd58 && DistY > 10'd0 && bg_position > 16'd650 && state == 10'd1 && save == 1'b0)
            is_rz = 1'b1;
        else
            is_rz = 1'b0;
        /* The rz's (pixelated) circle is generated using the standard circle formula.  Note that while 
           the single line is quite powerful descriptively, it causes the synthesis tool to use up three
           of the 12 available multipliers on the chip! */
    end
//	assign rz_alive = state;
	assign rz_addr = DistX + DistY*16'd50 + 16'd25104;
	
	assign save_suc = save;
endmodule
