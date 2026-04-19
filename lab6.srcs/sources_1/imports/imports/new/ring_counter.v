`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/20/2025 07:43:54 PM
// Design Name: 
// Module Name: ring_counter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ring_counter(
    input clk_i,
    input advance_i,
    output [3:0] ring_o
);

	wire [3:0] ff_D;
	
	FDRE #(.INIT(1)) ff0(.C(clk_i), .R(0), .CE(1), .D(ff_D[0]), .Q(ring_o[0]));
	FDRE #(.INIT(0)) ff1(.C(clk_i), .R(0), .CE(1), .D(ff_D[1]), .Q(ring_o[1]));
	FDRE #(.INIT(0)) ff2(.C(clk_i), .R(0), .CE(1), .D(ff_D[2]), .Q(ring_o[2]));
	FDRE #(.INIT(0)) ff3(.C(clk_i), .R(0), .CE(1), .D(ff_D[3]), .Q(ring_o[3]));

	wire [3:0] rotated;
	ror ror(.i(ring_o), .o(rotated));
	
	assign ff_D = {4{ advance_i}} & rotated |
	              {4{~advance_i}} & ring_o;

endmodule

module ror(
	input  [3:0] i,
	output [3:0] o
);
	assign o[3] = i[0];
	assign o[2:0] = i[3:1];
endmodule
