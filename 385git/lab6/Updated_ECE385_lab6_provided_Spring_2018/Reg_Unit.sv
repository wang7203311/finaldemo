module Reg_Unit(input logic Clk,Reset,LD_REG,
					input logic[2:0]SR2,
					input logic[15:0] bus_val,
					output logic[15:0] SR1_out,SR2_out,
					input logic[2:0] ir_11_9, ir_8_6,
					input logic SR1MUX,DRMUX
);

logic[2:0] SR1,DR;
sr_mux mux1(.ir_11_9,.ir_8_6,.SR1MUX,.SR1);
dr_mux mux2(.ir_11_9,.DRMUX,.DR);
Regfile regf(.*);

endmodule


module Regfile(input logic Clk,Reset,LD_REG,
					input logic[2:0]DR,SR1,SR2,
					input logic[15:0] bus_val,
					output logic[15:0] SR1_out,SR2_out
					
);

logic[15:0] R0_val,R1_val,R2_val,R3_val,R4_val,R5_val,R6_val,R7_val;
logic load_0,load_1,load_2,load_3,load_4,load_5,load_6,load_7;

always_comb
			begin
			load_0 = 1'b0;
			load_1 = 1'b0;
			load_2 = 1'b0;
			load_3 = 1'b0;
			load_4 = 1'b0;
			load_5 = 1'b0;
			load_6 = 1'b0;
			load_7 = 1'b0;
			case(DR)
				3'b 000: load_0 = LD_REG;
				3'b 001: load_1 = LD_REG;
				3'b 010: load_2 = LD_REG;
				3'b 011: load_3 = LD_REG;
				3'b 100: load_4 = LD_REG;
				3'b 101: load_5 = LD_REG;
				3'b 110: load_6 = LD_REG;
				3'b 111: load_7 = LD_REG;
//				3'b001: SR1_out = R1_val;
			endcase
			end
register R0(.Clk,.Reset,.load(load_0),.data_in(bus_val),.data_out(R0_val));
register R1(.Clk,.Reset,.load(load_1),.data_in(bus_val),.data_out(R1_val));
register R2(.Clk,.Reset,.load(load_2),.data_in(bus_val),.data_out(R2_val));
register R3(.Clk,.Reset,.load(load_3),.data_in(bus_val),.data_out(R3_val));
register R4(.Clk,.Reset,.load(load_4),.data_in(bus_val),.data_out(R4_val));
register R5(.Clk,.Reset,.load(load_5),.data_in(bus_val),.data_out(R5_val));
register R6(.Clk,.Reset,.load(load_6),.data_in(bus_val),.data_out(R6_val));
register R7(.Clk,.Reset,.load(load_7),.data_in(bus_val),.data_out(R7_val));
			always_comb
			begin
			case(SR1)
				3'b000: SR1_out = R0_val;
				3'b001: SR1_out = R1_val;
				3'b010: SR1_out = R2_val;
				3'b011: SR1_out = R3_val;
				3'b100: SR1_out = R4_val;
				3'b101: SR1_out = R5_val;
				3'b110: SR1_out = R6_val;
				3'b111: SR1_out = R7_val;
//				3'b001: SR1_out = R1_val;
				default: SR1_out = 16'h0000;
			endcase
			end

			
			always_comb
			begin
			case(SR2)
				3'b000: SR2_out = R0_val;
				3'b001: SR2_out = R1_val;
				3'b010: SR2_out = R2_val;
				3'b011: SR2_out = R3_val;
				3'b100: SR2_out = R4_val;
				3'b101: SR2_out = R5_val;
				3'b110: SR2_out = R6_val;
				3'b111: SR2_out = R7_val;
//				3'b001: SR1_out = R1_val;
				default: SR2_out = 16'h0000;
			endcase
			end
			
endmodule



module register(
				input logic Clk,Reset,load,
				input logic[15:0] data_in,
				output logic[15:0] data_out
);

always_ff @(posedge Clk)
begin
	if(Reset)
		data_out <= 16'h0000;
	else if(load)
		data_out <= data_in;
end
endmodule


module sr_mux(
				input logic[2:0] ir_11_9, ir_8_6,
				input logic SR1MUX,
				output logic[2:0] SR1			
);

			always_comb
			begin
			case(SR1MUX)
				1'b0: SR1 = ir_11_9;
				1'b1: SR1 = ir_8_6;
				default: SR1 = 3'b000;
			endcase
			end				

endmodule


module dr_mux(input logic[2:0] ir_11_9,
					input logic DRMUX,
					output logic[2:0] DR
);
			always_comb
			begin
			case(DRMUX)
				1'b0: DR = ir_11_9;
				1'b1: DR = 3'b111;
				default: DR = 3'b000;
			endcase
			end	
endmodule
