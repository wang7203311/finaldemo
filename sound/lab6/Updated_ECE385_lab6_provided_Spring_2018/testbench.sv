module testbench();

timeunit 10ns;

timeprecision 1ns;

logic [15:0] S;
logic Clk, Reset, Run, Continue;
logic [11:0] LED;
logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7;
logic CE, UB, LB, OE, WE;
logic [19:0] ADDR;
wire [15:0] Data; //tristate buffers need to be of type wire);


always begin : CLOCK_GENERATION
	#1 Clk = ~Clk;
end


initial begin : CLOCK_INITIALIZATION

	Clk = 0;
	
end



lab6_toplevel lab6(.*);


//logic a;
logic [3:0] State, Next_state;
logic LD_PC;
 
always_ff @ (posedge Clk)
 
begin:INITERAL_SIG_MONITOR

LD_PC <= lab6.my_slc.LD_PC;
State <= lab6.my_slc.state_controller.State;
// Next_state <= lc3.state_controller.Next_state;
//b <= mt.RB.data_out;

end



initial begin : TEST_VECTORS
Reset = 0;
//clearA_loadB = 1;
Run = 1;
Continue = 1;
#10 Reset = 1;

//#2 clearA_loadB = 0;
	S = 16'b0000000000000001;
	
//#2 clearA_loadB = 1;
//	S = 8'b00000111;
#2 Run = 0;
#2 Run = 1;
#2 Continue = 0;
#2 Continue = 1;
#2 Continue = 0;
#2 Continue = 1;
#2 Continue = 0;
#2 Continue = 1;
#2 Continue = 0;
#2 Continue = 1;
#2 Continue = 0;
#2 Continue = 1;

#22;

end


endmodule

