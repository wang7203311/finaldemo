module MAR_chip(
				input logic Clk,Reset,LD_MAR,
				input logic[15:0] data_in,
				output logic[15:0] data_out
);

always_ff @(posedge Clk)
begin
	if(Reset)
		data_out <= 16'h0000;
	else if(LD_MAR)
		data_out <= data_in;
end
endmodule
