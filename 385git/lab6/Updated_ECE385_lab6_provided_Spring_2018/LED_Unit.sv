module LED_Unit(input logic Clk,Reset,
					  input logic LD_LED,
					  input logic[15:0] IR,
					  output logic[11:0] LED
);

register_12it my_led(.*,.load(LD_LED),.data_in(IR[11:0]),.data_out(LED));


endmodule



module register_12it(
				input logic Clk,Reset,load,
				input logic[11:0] data_in,
				output logic[11:0] data_out
);

always_ff @(posedge Clk)
begin
	if(Reset)
		data_out <= 12'h0000;
	else if(load)
		data_out <= data_in;
end
endmodule
