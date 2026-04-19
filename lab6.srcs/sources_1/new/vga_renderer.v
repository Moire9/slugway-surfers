`include "../../sources_1/imports/new/definitions.v"

module vga_renderer #(
	parameter [15:0] OVERSCAN_X = 0,
	parameter [15:0] OVERSCAN_Y = 0,
	parameter [15:0] TRAIN_L_LEFT = 0,
	parameter [15:0] TRAIN_C_LEFT = 0,
	parameter [15:0] TRAIN_R_LEFT = 0,
	parameter [15:0] TRAIN_WIDTH = 60
) (
	input clk_i,
	input [15:0] pixel_x_i,
	input [15:0] pixel_y_i,
	input [15:0] frame_i,

	input [7:0] energy_i,
	input [15:0] slug_x_i,
	input hovering_i,
	input slug_flashing_i,

	// input [8:0] debug_i,
	
	input [15:0] trainL1_top_i,
	input [15:0] trainL1_height_i,
	input [15:0] trainL2_top_i,
	input [15:0] trainL2_height_i,
	input [15:0] trainC1_top_i,
	input [15:0] trainC1_height_i,
	input [15:0] trainC2_top_i,
	input [15:0] trainC2_height_i,
	input [15:0] trainR1_top_i,
	input [15:0] trainR1_height_i,
	input [15:0] trainR2_top_i,
	input [15:0] trainR2_height_i,

	output [3:0] r_o,
	output [3:0] g_o,
	output [3:0] b_o
);

// for my TV
// localparam [15:0] OVERSCAN_X = 35;
// localparam [15:0] OVERSCAN_Y = 22;

localparam [15:0] H = 640 - OVERSCAN_X - OVERSCAN_X;
localparam [15:0] V = 480 - OVERSCAN_Y - OVERSCAN_Y;

localparam [15:0] SLUG_W = 16;
localparam [15:0] SLUG_Y = 360;

localparam SLUG_FLASH_INTERVAL = 5; // 2 ** SLUG_FLASH_INTERVAL frames

localparam RAIL_OFF = 10;
localparam RAIL_WIDTH = 5;
localparam RAIL_SPACING = 30;

// 10 + 5 + 30 + 5 + 10

// localparam [15:0] TRAIN_L_LEFT = 160;
// localparam [15:0] TRAIN_C_LEFT = 230;
// localparam [15:0] TRAIN_R_LEFT = 310;
// localparam [15:0] TRAIN_WIDTH = 60;

wire [15:0] x = pixel_x_i - OVERSCAN_X;
wire [15:0] y = pixel_y_i - OVERSCAN_Y;

// Border - 8px wide white on edge of screen
wire [3:0] disp_border = {4{(8 > x || x >= H - 8 || 8 > y || y >= V - 8)}};
localparam [3:0] BORDER_R = 'b1111;
localparam [3:0] BORDER_G = 'b1111;
localparam [3:0] BORDER_B = 'b1111;

wire disp_slug = !(slug_flashing_i && frame_i[SLUG_FLASH_INTERVAL]) &&
	(slug_x_i < x && x <= slug_x_i + SLUG_W && 359 < y && y <= 359 + SLUG_W);

wire [3:0] disp_slug_grounded = {4{!hovering_i && disp_slug}};
localparam [3:0] SLUG_GROUNDED_R = 'b1111;
localparam [3:0] SLUG_GROUNDED_G = 'b1111;
localparam [3:0] SLUG_GROUNDED_B = 'b0000;

wire [3:0] disp_slug_hovering_a = {4{hovering_i && disp_slug && frame_i[6]}};
localparam [3:0] SLUG_HOVERING_A_R = 'b1111;
localparam [3:0] SLUG_HOVERING_A_G = 'b0000;
localparam [3:0] SLUG_HOVERING_A_B = 'b1111;

wire [3:0] disp_slug_hovering_b = {4{hovering_i && disp_slug && !frame_i[6]}};
localparam [3:0] SLUG_HOVERING_B_R = 'b0000;
localparam [3:0] SLUG_HOVERING_B_G = 'b1111;
localparam [3:0] SLUG_HOVERING_B_B = 'b1111;

wire [3:0] disp_trainL1 = {4{
	TRAIN_L_LEFT < x && x <= TRAIN_L_LEFT + TRAIN_WIDTH && 
	(trainL1_top_i < y && y <= trainL1_top_i + trainL1_height_i
	|| trainL1_top_i > H && y <= trainL1_top_i + trainL1_height_i)}};
wire [3:0] disp_trainL2 = {4{
	TRAIN_L_LEFT < x && x <= TRAIN_L_LEFT + TRAIN_WIDTH && 
	(trainL2_top_i < y && y <= trainL2_top_i + trainL2_height_i
	|| trainL2_top_i > H && y <= trainL2_top_i + trainL2_height_i)}};
wire [3:0] disp_trainC1 = {4{
	TRAIN_C_LEFT < x && x <= TRAIN_C_LEFT + TRAIN_WIDTH && 
	(trainC1_top_i < y && y <= trainC1_top_i + trainC1_height_i
	|| trainC1_top_i > H && y <= trainC1_top_i + trainC1_height_i)}};
wire [3:0] disp_trainC2 = {4{
	TRAIN_C_LEFT < x && x <= TRAIN_C_LEFT + TRAIN_WIDTH && 
	(trainC2_top_i < y && y <= trainC2_top_i + trainC2_height_i
	|| trainC2_top_i > H && y <= trainC2_top_i + trainC2_height_i)}};
wire [3:0] disp_trainR1 = {4{
	TRAIN_R_LEFT < x && x <= TRAIN_R_LEFT + TRAIN_WIDTH && 
	(trainR1_top_i < y && y <= trainR1_top_i + trainR1_height_i
	|| trainR1_top_i > H && y <= trainR1_top_i + trainR1_height_i)}};
wire [3:0] disp_trainR2 = {4{
	TRAIN_R_LEFT < x && x <= TRAIN_R_LEFT + TRAIN_WIDTH && 
	(trainR2_top_i < y && y <= trainR2_top_i + trainR2_height_i
	|| trainR2_top_i > H && y <= trainR2_top_i + trainR2_height_i)}};
localparam [3:0] TRAIN_B = 'b1111;

wire [3:0] disp_train = disp_trainL1 | disp_trainL2 | disp_trainC1 | disp_trainC2 | disp_trainR1 | disp_trainR2;

wire [3:0] disp_rail = {4{
	TRAIN_L_LEFT + RAIL_OFF < x && x <= TRAIN_L_LEFT + RAIL_OFF + RAIL_WIDTH ||
	TRAIN_L_LEFT + RAIL_OFF + RAIL_SPACING + RAIL_WIDTH < x && x <= TRAIN_L_LEFT + RAIL_OFF + RAIL_WIDTH + RAIL_SPACING + RAIL_WIDTH ||
	TRAIN_C_LEFT + RAIL_OFF < x && x <= TRAIN_C_LEFT + RAIL_OFF + RAIL_WIDTH ||
	TRAIN_C_LEFT + RAIL_OFF + RAIL_SPACING + RAIL_WIDTH < x && x <= TRAIN_C_LEFT + RAIL_OFF + RAIL_WIDTH + RAIL_SPACING + RAIL_WIDTH ||
	TRAIN_R_LEFT + RAIL_OFF < x && x <= TRAIN_R_LEFT + RAIL_OFF + RAIL_WIDTH ||
	TRAIN_R_LEFT + RAIL_OFF + RAIL_SPACING + RAIL_WIDTH < x && x <= TRAIN_R_LEFT + RAIL_OFF + RAIL_WIDTH + RAIL_SPACING + RAIL_WIDTH
}};
localparam [3:0] RAIL_R = 'b0011;
localparam [3:0] RAIL_G = 'b0011;
localparam [3:0] RAIL_B = 'b0011;

wire [3:0] disp_tie = {4{
	(
		TRAIN_L_LEFT < x && x <= TRAIN_L_LEFT + TRAIN_WIDTH || 
		TRAIN_C_LEFT < x && x <= TRAIN_C_LEFT + TRAIN_WIDTH || 
		TRAIN_R_LEFT < x && x <= TRAIN_R_LEFT + TRAIN_WIDTH
	) && y[3:1] == 0
}};
localparam [3:0] TIE_R = 'b1101;
localparam [3:0] TIE_G = 'b0100;
localparam [3:0] TIE_B = 'b0100;

// wire [3:0] ball = {4{debug_i[5] & (x > 0 && x <= H - 0 && y > 0 && y <= V - 0)}};

// Energy bar - 20px wide green on top left of screen, 16px offset.
// Each pixel in height represents one unit of energy. Grows upwards.
// Max size = 192 px.
wire [3:0] disp_energy_bar = {4{16 <= x && x < 36 && 16 + (192 - energy_i) < y && y < 16 + 192}};
localparam [3:0] ENERGY_BAR_G = 'b1111;

assign r_o = 
	disp_border & BORDER_R |
	disp_slug_grounded & SLUG_GROUNDED_R |
	disp_slug_hovering_a & SLUG_HOVERING_A_R |
	disp_slug_hovering_b & SLUG_HOVERING_B_R |
	disp_rail & RAIL_R & ~disp_train |
	disp_tie & TIE_R & ~disp_train
;

assign g_o =
	disp_border & BORDER_G |
	disp_slug_grounded & SLUG_GROUNDED_G |
	disp_slug_hovering_a & SLUG_HOVERING_A_G |
	disp_slug_hovering_b & SLUG_HOVERING_B_G |
	disp_energy_bar & ENERGY_BAR_G |
	disp_rail & RAIL_G & ~disp_train |
	disp_tie & TIE_G & ~disp_train
;

	// {4{pixel_x_i[debug_i[3:0]]}}; // debug lines

assign b_o =
	disp_border & BORDER_B |
	disp_slug_grounded & SLUG_GROUNDED_B |
	disp_slug_hovering_a & SLUG_HOVERING_A_B |
	disp_slug_hovering_b & SLUG_HOVERING_B_B |
	disp_train & TRAIN_B |
	disp_rail & RAIL_B & ~disp_train |
	disp_tie & TIE_B & ~disp_train
;


	// {4{ // blue squares
	// 	128 <= x && x < 128 + 64 && 128 <= y && y < 128 + 64 ||
	// 	128 + 64 <= x && x < 128 + 64 + 16 && 128 + 64 <= y && y < 128 + 64 + 16 ||
	// 	128 + 64 + 16 <= x && x < 128 + 64 + 16 + 8 && 128 + 64 + 16 <= y && y < 128 + 64 + 16 + 8
	// }};

endmodule
