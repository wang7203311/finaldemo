module score(
input logic alive,save_suc,enemy1_alive,lastp_alive,p2_alive,game_start,Clk,
input logic[15:0] bg_position,
output logic[15:0] result
);

//logic[4:0] temp;
//assign temp = {alive,enemy1_alive,save_suc,lastp_alive,p2_alive} ;
//always_comb
//begin
//
//if(alive == 1'b0)
//result = 16'h10;
//if(game_start)
//result = 16'd0;
//else if(lastp_alive == 1'b0 && p2_alive == 1'b0 && bg_position > 16'd1300)
//result = 16'h80;
//else if(lastp_alive == 1'b0 && bg_position > 16'd1300)
//result = 16'd50;
//else if(p2_alive == 1'b0 && bg_position > 16'd1300)
//result = 16'd50;
//else if(save_suc == 1'b1 && alive == 1'b0 && enemy1_alive == 1'b0 && bg_position > 16'd648)
//result = 16'h40;
//else if(alive == 1'b0 && save_suc == 1'b1 && bg_position > 16'd648)
//result = 16'h30;
//else if(alive == 1'b0 && enemy1_alive == 1'b0 && bg_position > 16'd648 )
//result = 16'h20;
//else if(alive == 1'b0)
//result = 16'h10;
//else
//result = 16'h0;
//end
always_ff @(posedge Clk)
begin
	if(game_start)
		result <= 16'h0000;
	else if(lastp_alive == 1'b0 && p2_alive == 1'b0 && bg_position > 16'd1298)
		result <= 16'h0080;
	else if(lastp_alive == 1'b0 && bg_position > 16'd1298)
		result <= 16'd0050;
	else if(p2_alive == 1'b0 && bg_position > 16'd1298)
		result <= 16'd0050;
	else if(save_suc == 1'b1 && alive == 1'b0 && enemy1_alive == 1'b0 && bg_position > 16'd648)
		result <= 16'h0040;
	else if(alive == 1'b0 && save_suc == 1'b1 && bg_position > 16'd648)
		result <= 16'h0030;
	else if(alive == 1'b0 && enemy1_alive == 1'b0 && bg_position > 16'd648)
		result <= 16'h0020;
	else if(alive == 1'b0)
		result <= 16'h0010;
	else
		result <= 16'h0000;
end
endmodule
