
module control_unit(
input logic reset,Clk,enter_on,char_alive,p1_die,p2_die,
output win_end,start_pic,dead_end,game_start,begin_sig,
input logic [15:0]bg_position
);

enum logic[4:0]{Wait,hold,hold2,Done,in_process,win} state, next_state;

always_ff @ (posedge Clk)
	begin
		if (reset)
			begin
			state <= Wait;
//			state_count <= 6'b0;
			end
		else 
			begin
			state <= next_state;
//			state_reg <= next_state_reg;
//			state_count <= next_state_count;
			end
	end

	
always_comb
begin
//next_state_count = state_count;
win_end = 1'b0;
start_pic = 1'b0;
dead_end = 1'b0;
game_start = 1'b0;
begin_sig = 1'b0;
unique case(state)
Wait:
	if(enter_on == 1'b1)
	next_state = hold;
	else
	next_state = Wait;
hold:
	next_state = hold2;
hold2:
	next_state = in_process;
Done:
	next_state = Done;
in_process:
	if(char_alive == 1'b0)
	next_state = Done;
	else if(p1_die == 1'b1 && p2_die == 1'b1 && bg_position > 16'd1300)
	next_state = win;
	else
	next_state = in_process;
win:
	next_state = win;
endcase
//
case(state)
Wait:begin
		start_pic = 1'b1;
//		next_state_count = 6'd0;
		end
Done:
	begin
	dead_end = 1'b1;
//	next_state_count = 6'd0;
	end
in_process:
	begin
//	explored = 1'b0;
	begin_sig = 1'b1;
//	next_state_count = state_count + 6'b0001;
	end
hold:
	game_start = 1'b1;
win:
	win_end = 1'b1;
default:;
endcase
end
endmodule
