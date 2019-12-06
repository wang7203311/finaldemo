module datapath(
					input logic LD_PC, LD_MAR,LD_MDR,LD_IR,Clk, Reset,GatePC, GateMDR, GateALU, GateMARMUX,
					input logic[1:0] PCMUX,
					input logic[15:0] Data_to_CPU,
					output logic[15:0] MAR, MDR, IR, PC
);
logic[15:0] IR_input, MAR_input,bus_output ;


bus b(.GatePC,.GateMDR,.GateALU,.GateMARMUX,.PC_OUT(PC),.MDR_OUT(MDR),.bus_output);
Program_Counter pc(.Clk,.Reset,.LD_PC,.PCMUX,.PC_out(PC));
IR_chip ir(.Clk,.Reset,.LD_IR,.data_in(bus_output),.data_out(IR));
MAR_chip mar(.Clk,.Reset,.LD_MAR,.data_in(bus_output),.data_out(MAR));
MDR_chip mdr(.Clk,.Reset,.LD_MDR,.data_in(Data_to_CPU),.data_out(MDR));

endmodule

