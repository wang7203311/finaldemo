module MUX_UNIT(
						input logic[15:0] IR,
						input logic[1:0] ADDR2MUX,
						input logic ADDR1MUX,
						input logic[15:0] from_pc,SR1_out,
						output logic[15:0] MAR_out, to_PC

);
logic[15:0] add2_out, add1_out, addr_sum;
addr2 a2(.IR,.ADDR2MUX,.add2_out);
addr1 a1(.SR1_out,.from_pc,.ADDR1MUX,.add1_out);
//assign addr_sum = add2_out + add1_out;
always_comb
begin
	addr_sum = add2_out + add1_out;
	to_PC = addr_sum;
	MAR_out = addr_sum;
end

endmodule

module addr2(
					input logic[15:0] IR,
					input logic[1:0] ADDR2MUX,
					output logic [15:0] add2_out
		
);
logic[15:0] sext_5,sext_8,sext_10;
assign sext_5 = {{10{IR[5]}},IR[5:0]};
assign sext_8 = {{7{IR[8]}},IR[8:0]};
assign sext_10 = {{5{IR[10]}},IR[10:0]};

always_comb
//			sext_5 = {{10{IR[5]}},IR[5:0]};
//			sext_8 = {{7{IR[8]}},IR[8:0]};
//			sext_10 = {{5{IR[10]}},IR[10:0]};
			begin
			case(ADDR2MUX)
			2'b 00: add2_out = 16'h0000;
			2'b 01: add2_out = sext_5;
			2'b 10: add2_out = sext_8;
			2'b 11: add2_out = sext_10;
			default: add2_out = 16'h0000;
			endcase
			end

endmodule


module addr1(
					input logic[15:0] SR1_out,
					input logic[15:0] from_pc,
					input logic ADDR1MUX,
					output logic[15:0] add1_out
);
always_comb
			begin
			case(ADDR1MUX)
			1'b 0: add1_out = from_pc;
			1'b 1: add1_out = SR1_out;
			default: add1_out = 16'h0000;
			endcase
			end

endmodule
