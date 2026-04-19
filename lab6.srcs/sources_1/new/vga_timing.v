`include "../../sources_1/imports/new/definitions.v"

// `define SIM 1

module vga_timing(
	input clk_i,

	output [15:0] x_o,
	output [15:0] y_o,
	output [15:0] frame_o,
	output active_o,

// Clock synced & active low:
	output hsync_o,
	output vsync_o
);

localparam HSIZE = 800;
localparam HBLANK = 640;
localparam HSYNC_BEGIN = 655; // incl
localparam HSYNC_DURATION = 96;

localparam VSIZE = 525;
localparam VBLANK = 480;
localparam VSYNC_BEGIN = 489; // incl
localparam VSYNC_DURATION = 2;

`ifdef SIM

wire [3:0] slow_d, slow_q;
FDRE slow [3:0](.C(clk_i), .R(1'b0), .CE(1'b1), .D(slow_d), .Q(slow_q));
assign slow_d = slow_q + 1;

assign x_o = slow_q;
assign y_o = slow_q;

wire [15:0] frames_d, frames_q;
FDRE frames [15:0](.C(clk_i), .R(1'b0), .CE(1'b1), .D(frames_d), .Q(frames_q));
assign frames_d = frames_q + (slow_q == 0);

assign frame_o = frames_q;


`else
// Scanline

wire [15:0] col_d, col_q;
FDRE col [15:0](.C(clk_i), .R(16'b0), .CE(~(16'b0)), .D(col_d), .Q(col_q));

wire col_wrap = col_q == (HSIZE - 1);
assign col_d = col_wrap ? 0 : (col_q + 1);

assign x_o = col_q;

FDRE hsync (.C(clk_i), .R(0), .CE(1), .D(
	!(HSYNC_BEGIN <= col_q && col_q < HSYNC_BEGIN + HSYNC_DURATION)
), .Q(hsync_o));

// Frame

wire [15:0] row_d, row_q;
FDRE row [15:0](.C(clk_i), .R(16'b0), .CE(~(16'b0)), .D(row_d), .Q(row_q));

wire row_wrap = row_q + col_wrap == VSIZE;
assign row_d = row_wrap ? 0 : row_q + col_wrap;

assign y_o = row_d;

FDRE vsync (.C(clk_i), .R(0), .CE(1), .D(
	!(VSYNC_BEGIN <= row_q && row_q < VSYNC_BEGIN + VSYNC_DURATION)
), .Q(vsync_o));

// FDRE active (.C(clk_i), .R(0), .CE(1), .D(
assign active_o = col_q < HBLANK && row_q < VBLANK;
// ), .Q(active_o));

// Video
wire [15:0] frames_d, frames_q;
FDRE frames [15:0](.C(clk_i), .R(16'b0), .CE(~(16'b0)), .D(frames_d), .Q(frames_q));
assign frames_d = frames_q + (row_q == VSIZE - 1 && col_q == HSIZE - 1);

assign frame_o = frames_q;
`endif
endmodule
