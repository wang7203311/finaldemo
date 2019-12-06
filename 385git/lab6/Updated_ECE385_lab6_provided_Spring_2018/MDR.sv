module MDR_chip(
				input logic Clk,Reset,LD_MDR,MIO_EN,
				input logic[15:0] data_in,bus_output,
				output logic[15:0] data_out
);

always_ff @(posedge Clk)
begin
	if(Reset)
		data_out <= 16'h0000;
	else if(LD_MDR && MIO_EN)
		data_out <= data_in;
	else if(LD_MDR && ~MIO_EN)
		data_out <= bus_output;
end
endmodule
//need add mux