module ALU_Unit(input logic[1:0]ALUK,
					input logic[4:0] imm5,
					input logic SR2MUX,
					input logic[15:0] SR1_out, SR2_out,
					output logic[15:0] ALU_output
);
logic[15:0] B;
ALU_MUX a_mux(.*);

ALU alu(.ALUK,.A(SR1_out),.B,.data_out(ALU_output));

endmodule


module ALU(
				input logic[1:0]ALUK,
				input logic[15:0] A, B,
				output logic[15:0] data_out
);

always_comb
			begin
			case(ALUK)
				2'b00: data_out = A + B;
				2'b01: data_out = A & B;
				2'b10: data_out = ~ A;
				2'b11: data_out = A;
				default: data_out = 16'h0000;
			endcase
			end			
endmodule


module ALU_MUX(
				input logic[4:0] imm5,
				input logic[15:0] SR2_out,
				input logic SR2MUX,
				output logic[15:0] B
);

logic[15:0] sext_imm5;
assign sext_imm5 = {{11{imm5[4]}},imm5[4:0]};
always_comb
			begin
			case(SR2MUX)
			1'b 0: B = SR2_out;
			1'b 1: B = sext_imm5;
			default: B = 16'h0000;
			endcase
			end
endmodule
