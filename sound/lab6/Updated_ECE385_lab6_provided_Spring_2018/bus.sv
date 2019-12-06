module bus(
			input logic       GatePC,
									GateMDR,
									GateALU,
									GateMARMUX,
			input logic[15:0] PC_OUT,MDR_OUT,//,MAR_OUT,ALU
			output logic[15:0] bus_output
);

	logic[1:0] gate_val;
	assign gate_val = {GatePC, GateMDR}; // need change
			always_comb
			begin
			case(gate_val)
				2'b01: bus_output = MDR_OUT;
				2'b10: bus_output = PC_OUT;
				default: bus_output = 2'b00;
			endcase
			end

endmodule
