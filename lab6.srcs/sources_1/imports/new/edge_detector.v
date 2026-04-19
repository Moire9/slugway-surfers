`include "../../../sources_1/imports/new/definitions.v"

module edge_detector #(
	parameter STROBE = 1
) (
    input clk_i,
    input button_i,
    output edge_o
);
	wire current_Q;
	wire old_Q;
	
	`FCDQ(clk_i, button_i, current_Q);
	`FCDQ(clk_i, current_Q, old_Q);
	
	assign edge_o = `IF(1, STROBE, ~old_Q && current_Q, current_Q);
endmodule
