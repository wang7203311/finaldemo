module testbench();

timeunit 10ns;
timeprecision 1ns;

logic [15:0] S;
logic Clk, Reset, Run, Continue;
logic [11:0] LED;
logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7;
logic CE, UB, LB, OE, WE;
logic [19:0] ADDR;
wire [15:0] Data;


	
lab6_toplevel lab6(.*);


// Toggle the clock
// #1 means wait for a delay of 1 timeunit
always begin : CLOCK_GENERATION
#1 Clk = ~Clk;
end

initial begin: CLOCK_INITIALIZATION
    Clk = 0;
end 


logic [15:0] PC;
logic [15:0] R1;
logic [15:0] IR;
logic [2:0] up_logic, nzp, down_logic;
logic BEN, LD_CC;
//logic [5:0] State, Next_state;
always_ff @ (posedge Clk)
 
begin:INITERAL_SIG_MONITOR
 
PC <= lab6.my_slc.PC;
R1 <= lab6.my_slc.d0.R_unit.regf.R1.data_out;
IR <= lab6.my_slc.IR;
BEN <= lab6.my_slc.BEN;
up_logic <= lab6.my_slc.d0.ben.temp_bit;
nzp <= lab6.my_slc.d0.ben.nzp.data_out;
down_logic <= lab6.my_slc.d0.ben.down_logic;
LD_CC <= lab6.my_slc.LD_CC;
//State <= lab6.my_slc.state_controller.State;
//Next_state <= lab6.state_controller.Next_state;
end


initial begin: TEST_VECTORS

Reset = 1;		// Toggle Rest
Run = 1;
Continue = 1;

#2
Reset = 0;

#2
Reset = 1;
S = 16'h0003;
#2
Run = 0;

#5 Run = 1;

#2 Continue = 1;
#10 Continue = 0;

#10 Continue = 1;

#10 Continue = 0;
#10 Continue = 1;

#10 Continue = 0;
#10 Continue = 1;
#10 Continue = 0;
#10 Continue = 1;
#10 Continue = 0;
#10 Continue = 1;
#10 Continue = 0;
#10 Continue = 1;
#10 Continue = 0;

end
endmodule