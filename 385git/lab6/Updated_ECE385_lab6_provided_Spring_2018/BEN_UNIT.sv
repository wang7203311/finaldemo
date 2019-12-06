module BEN_UNIT (
			input logic Clk,Reset,LD_BEN,LD_CC,
			input logic[15:0] IR,bus_output,
			output logic BEN
);
logic[2:0] down_logic,data_out_nzp, temp_bit;

logic ben_input;
always_comb
begin
if(bus_output == 16'h0000)
 down_logic = 3'b010;
else if(bus_output[15] == 1'b1)
down_logic = 3'b100;
else
down_logic = 3'b001;
end


register_3bit nzp(.*,.data_out(data_out_nzp),.data_in(down_logic),.load(LD_CC));


always_comb
begin
	temp_bit = IR[11:9];
	ben_input = (data_out_nzp[2] & temp_bit[2]) | (data_out_nzp[1] & temp_bit[1]) | (data_out_nzp[0] & temp_bit[0]);
end


register_1bit ben_reg(.Clk,.Reset,.load(LD_BEN),.data_in(ben_input),.data_out(BEN));


endmodule



module register_3bit(
				input logic Clk,Reset,load,
				input logic[2:0] data_in,
				output logic[2:0] data_out
);

always_ff @(posedge Clk)
begin
	if(Reset)
		data_out <= 3'b000;
	else if(load)
		data_out <= data_in;
end
endmodule



module register_1bit(
				input logic Clk,Reset,load,
				input logic data_in,
				output logic data_out
);

always_ff @(posedge Clk)
begin
	if(Reset)
		data_out <= 1'b0;
	else if(load)
		data_out <= data_in;
end
endmodule
