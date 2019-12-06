module Program_Counter(
							input logic Clk, Reset, LD_PC,
							input logic[1:0] PCMUX,
							output logic[15:0] PC_out
							);
logic[15:0]  data_in;

PC_MUX p_mux(.PCMUX,.oldpc(PC_out),.data_out(data_in));
PC_chip chip(.Clk,.Reset,.LD_PC,.data_in,.data_out(PC_out));
			
endmodule




module PC_chip(
				input logic Clk, Reset, LD_PC,
				
				input logic[15:0] data_in,
				//inout wire[15:0] Data //do not need for week1
				output logic[15:0] data_out
);

logic[15:0] data_next;
always_ff @(posedge Clk)
begin
		data_out <= data_next;
end
always_comb
begin
data_next = data_out;
if(Reset)
		data_next = 16'h0000;
else if(LD_PC)
		data_next = data_in;
end
		
endmodule


module PC_MUX(
				input logic[1:0] PCMUX,
				input logic[15:0] oldpc,
				output logic[15:0] data_out
);
		always_comb
		begin
		case(PCMUX)
			2'b00: data_out = oldpc+1;
			default: data_out = 16'h0000;
		endcase
		end
endmodule
