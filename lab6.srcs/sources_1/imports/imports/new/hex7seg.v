`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/08/2025 10:42:09 PM
// Design Name: 
// Module Name: hex7seg
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


module hex7seg(
    input [3:0] N_i,
    output [6:0] Seg_o
);
	
	assign Seg_o[0] = ~N_i[3] & ~N_i[2] & ~N_i[1] &  N_i[0] | ~N_i[3] &  N_i[2] & ~N_i[1] & ~N_i[0] |  N_i[3] & ~N_i[2] &  N_i[1] &  N_i[0] |  N_i[3] &  N_i[2] & ~N_i[1] &  N_i[0];
	assign Seg_o[1] = ~N_i[3] &  N_i[2] & ~N_i[1] &  N_i[0] | ~N_i[3] &  N_i[2] &  N_i[1] & ~N_i[0] |  N_i[3] & ~N_i[2] &  N_i[1] &  N_i[0] |  N_i[3] &  N_i[2] & ~N_i[1] & ~N_i[0] |  N_i[3] &  N_i[2] &  N_i[1] & ~N_i[0] |  N_i[3] &  N_i[2] &  N_i[1] &  N_i[0];
	assign Seg_o[2] = ~N_i[3] & ~N_i[2] &  N_i[1] & ~N_i[0] |  N_i[3] &  N_i[2] & ~N_i[1] & ~N_i[0] |  N_i[3] &  N_i[2] &  N_i[1] & ~N_i[0] |  N_i[3] &  N_i[2] &  N_i[1] &  N_i[0];
	assign Seg_o[3] = ~N_i[3] & ~N_i[2] & ~N_i[1] &  N_i[0] | ~N_i[3] &  N_i[2] & ~N_i[1] & ~N_i[0] | ~N_i[3] &  N_i[2] &  N_i[1] &  N_i[0] |  N_i[3] & ~N_i[2] & ~N_i[1] &  N_i[0] |  N_i[3] & ~N_i[2] &  N_i[1] & ~N_i[0] |  N_i[3] &  N_i[2] &  N_i[1] &  N_i[0];
	assign Seg_o[4] = ~N_i[3] & ~N_i[2] & ~N_i[1] &  N_i[0] | ~N_i[3] & ~N_i[2] &  N_i[1] &  N_i[0] | ~N_i[3] &  N_i[2] & ~N_i[1] & ~N_i[0] | ~N_i[3] &  N_i[2] & ~N_i[1] &  N_i[0] | ~N_i[3] &  N_i[2] &  N_i[1] &  N_i[0] |  N_i[3] & ~N_i[2] & ~N_i[1] &  N_i[0];
	assign Seg_o[5] = ~N_i[3] & ~N_i[2] & ~N_i[1] &  N_i[0] | ~N_i[3] & ~N_i[2] &  N_i[1] & ~N_i[0] | ~N_i[3] & ~N_i[2] &  N_i[1] &  N_i[0] | ~N_i[3] &  N_i[2] &  N_i[1] &  N_i[0] |  N_i[3] &  N_i[2] & ~N_i[1] &  N_i[0];
	assign Seg_o[6] = ~N_i[3] & ~N_i[2] & ~N_i[1] & ~N_i[0] | ~N_i[3] & ~N_i[2] & ~N_i[1] &  N_i[0] | ~N_i[3] &  N_i[2] &  N_i[1] &  N_i[0] |  N_i[3] &  N_i[2] & ~N_i[1] & ~N_i[0];
endmodule
