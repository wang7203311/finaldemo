module datapath(
					input logic LD_MAR, LD_MDR, LD_IR, LD_BEN, LD_CC, LD_REG, LD_PC, LD_LED,
					input logic Clk, Reset,GatePC, GateMDR, GateALU, GateMARMUX,
					input logic MIO_EN,
					input logic[1:0] PCMUX,ADDR2MUX,ALUK,
					input logic ADDR1MUX,SR2MUX,SR1MUX,DRMUX,
					input logic[15:0] Data_to_CPU,
					output logic[15:0] MAR, MDR, IR, PC,
					output logic[11:0] LED,
					output logic BEN
);
logic[15:0] IR_input, MAR_input,bus_output,to_PC,SR1_out,MAR_out,ALU_output,SR2_out;

bus b(.GatePC,.GateMDR,.GateALU,.GateMARMUX,.PC_OUT(PC),.MDR_OUT(MDR),
.bus_output,.ALU(ALU_output),.MAR_out);
Program_Counter pc(.Clk,.Reset,.LD_PC,.PCMUX,.PC_out(PC),.from_bus(bus_output),.from_mux(to_PC));
IR_chip ir(.Clk,.Reset,.LD_IR,.data_in(bus_output),.data_out(IR));
MAR_chip mar(.Clk,.Reset,.LD_MAR,.data_in(bus_output),.data_out(MAR));
MDR_chip mdr(.Clk,.Reset,.LD_MDR,.data_in(Data_to_CPU),.bus_output,.data_out(MDR),.MIO_EN);


// week2
MUX_UNIT m_unit(.IR,.ADDR2MUX,.ADDR1MUX,.from_pc(PC),.SR1_out,.MAR_out,.to_PC);
ALU_Unit A_unit(.ALUK,.imm5(IR[4:0]),.SR2MUX,.SR1_out,.SR2_out,.ALU_output);
Reg_Unit R_unit(.Clk,.Reset,.LD_REG,.SR2(IR[2:0]),.bus_val(bus_output),.SR1_out,.SR2_out,
.ir_11_9(IR[11:9]),.ir_8_6(IR[8:6]),.SR1MUX,.DRMUX);

BEN_UNIT ben(.*);

endmodule

