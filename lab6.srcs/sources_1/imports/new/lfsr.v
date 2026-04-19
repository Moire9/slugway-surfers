`include "../../../sources_1/imports/new/definitions.v"

module lfsr(
	input clk_i,
	output [7:0] q_o
);

wire q0 = (q_o[0] ^ q_o[5]) ^ (q_o[6] ^ q_o[7]);

`FCDQI(clk_i, q0,     q_o[0], 1'b1);
`FCDQ (clk_i, q_o[0], q_o[1]);
`FCDQ (clk_i, q_o[1], q_o[2]);
`FCDQ (clk_i, q_o[2], q_o[3]);
`FCDQ (clk_i, q_o[3], q_o[4]);
`FCDQ (clk_i, q_o[4], q_o[5]);
`FCDQ (clk_i, q_o[5], q_o[6]);
`FCDQ (clk_i, q_o[6], q_o[7]);

endmodule
