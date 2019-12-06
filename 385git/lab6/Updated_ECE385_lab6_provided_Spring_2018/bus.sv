module bus(
			input logic       GatePC,
									GateMDR,
									GateALU,
									GateMARMUX,
			input logic[15:0] PC_OUT,MDR_OUT,MAR_OUT,ALU,MAR_out,
			output logic[15:0] bus_output
);

	logic[3:0] gate_val;
	assign gate_val = {{GatePC}, {GateMDR},{GateALU},{GateMARMUX}}; // need change
			always_comb
			begin
			case(gate_val)
				4'b0001: bus_output = MAR_out;
				4'b0010: bus_output = ALU;
				4'b0100: bus_output = MDR_OUT;
				4'b1000: bus_output = PC_OUT;
				default: bus_output = 4'b0000;
			endcase
			end

endmodule
