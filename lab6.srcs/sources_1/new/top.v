`include "../../sources_1/imports/new/definitions.v"

module top(
	input  board_clk_i,

	input  [15:0] sw_i,
	input btnC_async_i,
	input btnU_async_i,
	input btnD_async_i,
	input btnL_async_i,
	input btnR_async_i,

	output [3:0]   an_o,
	output [6:0]  seg_o,
	output         dp_o,
	output [15:0] led_o,

	output [3:0]   hdmi_red_o,
	output [3:0] hdmi_green_o,
	output [3:0]  hdmi_blue_o,
	output         hdmi_clk_o,
	output       hdmi_hsync_o,
	output       hdmi_vsync_o,
	output      hdmi_dispen_o
);

localparam [15:0] OVERSCAN_X = 0; //35;
localparam [15:0] OVERSCAN_Y = 0; //22;

localparam [15:0] TRACK_C = 318;
localparam [15:0] TRACK_OFF = 60 + 10;

// CLOCKS & TIMING

wire clk_i;
wire digsel;
wire frame_start;

labVGA_clks labVGA_clks(
	.clkin (board_clk_i),
	.greset(btnD_async_i),
	.clk   (clk_i),
	.digsel(digsel)
);

assign hdmi_clk_o = clk_i;

wire [15:0] pixel_x, pixel_y, frame;
wire active;
assign frame_start = pixel_x == 0 && pixel_y == 0;
vga_timing vga_timing(
	.clk_i   (clk_i),
	.x_o     (pixel_x),
	.y_o     (pixel_y),
	.frame_o (frame),
	.active_o(active),
	.hsync_o (hdmi_hsync_o),
	.vsync_o (hdmi_vsync_o)
);

// INPUT

wire btnC;
edge_detector btnC_sync(
	.clk_i   (clk_i),
	.button_i(btnC_async_i),
	.edge_o  (btnC)
);
wire btnU;
edge_detector #(.STROBE(0)) btnU_sync(
	.clk_i   (clk_i),
	.button_i(btnU_async_i),
	.edge_o  (btnU)
);
wire btnL;
edge_detector btnL_sync(
	.clk_i   (clk_i),
	.button_i(btnL_async_i),
	.edge_o  (btnL)
);
wire btnR;
edge_detector btnR_sync(
	.clk_i   (clk_i),
	.button_i(btnR_async_i),
	.edge_o  (btnR)
);

// STATE

wire [3:0] lives;
wire game_active, reset_game, start_track_L, start_track_C, start_track_R, slug_flashing;
game_fsm game_fsm(
	.clk_i            (clk_i),
	.request_start_i  (btnC),
	.frame_count_i    (frame),
	.train_collision_i(collision),
	.inc_lives_i      (btnL),

	// .state_debug      (led_o[6:0]),

	.game_active_o    (game_active),
	.reset_game_o     (reset_game),
	.start_track_L_o  (start_track_L),
	.start_track_C_o  (start_track_C),
	.start_track_R_o  (start_track_R),
	.slug_flashing_o  (slug_flashing),
	.lives_o          (lives)
);

wire [7:0] rng;
lfsr lfsr(
	.clk_i(clk_i),
	.q_o  (rng)
);

wire trainL_score, trainC_score, trainR_score;
wire [7:0] score_d, score_q;
FDRE score [7:0] (.C(clk_i), .R(1'b0), .CE(1'b1), .D(score_d), .Q(score_q));
assign score_d = reset_game ? 0 : score_q + trainL_score + trainC_score + trainR_score;

wire [7:0] energy;
wire [15:0] slug_x;
wire currently_hovering;
slug_fsm slug_fsm(
	.clk_i           (clk_i),
	.try_move_left_i (btnL),
	.try_move_right_i(btnR),
	.try_hover_i     (btnU),
	.active_i        (game_active),
	.reset_i         (reset_game),
	.frame_start_i   (frame_start),
	.current_frame_i (frame),

	// .state_debug     (led_o[7:0]),

	.hovering_o      (currently_hovering),
	.slug_x_o        (slug_x),
	.energy_o        (energy)
);

wire [15:0] trainL1_top, trainL1_height, trainL2_top, trainL2_height;
wire trainL_collision;
train_fsm #(
	.LEFT_COLUMN(TRACK_C - TRACK_OFF),
	// .SPAWN(22),
	.DESPAWN(480 - 8 - OVERSCAN_Y)
) train_L (
	.clk_i           (clk_i),
	
	.tick_i          (frame_start),
	.start_i         (start_track_L),
	.current_frame_i (frame),
	.rng_i           (rng),
	.active_i        (game_active),
	.reset_i         (reset_game),
	
	.slug_x_i        (slug_x),

	// .debug_state     (led_o[12:7]),
	
	.train1_top_o    (trainL1_top),
	.train1_height_o (trainL1_height),
	.train2_top_o    (trainL2_top),
	.train2_height_o (trainL2_height),

	.score_points_o  (trainL_score),
	.slug_collision_o(trainL_collision)
);

wire [15:0] trainC1_top, trainC1_height, trainC2_top, trainC2_height;
wire trainC_collision;
train_fsm #(
	.LEFT_COLUMN(TRACK_C),
	.NEXT_TRAIN_SPAWN(440),
	// .SPAWN(22),
	.DESPAWN(480 - 8 - OVERSCAN_Y)
) train_C (
	.clk_i           (clk_i),
	
	.tick_i          (frame_start),
	.start_i         (start_track_C),
	.current_frame_i (frame),
	.rng_i           (rng),
	.active_i        (game_active),
	.reset_i         (reset_game),
	
	.slug_x_i        (slug_x),
	
	.train1_top_o    (trainC1_top),
	.train1_height_o (trainC1_height),
	.train2_top_o    (trainC2_top),
	.train2_height_o (trainC2_height),

	.score_points_o  (trainC_score),
	.slug_collision_o(trainC_collision)
);

wire [15:0] trainR1_top, trainR1_height, trainR2_top, trainR2_height;
wire trainR_collision;
train_fsm #(
	.LEFT_COLUMN(TRACK_C + TRACK_OFF),
	// .SPAWN(22),
	.DESPAWN(480 - 8 - OVERSCAN_Y)
) train_R (
	.clk_i           (clk_i),
	
	.tick_i          (frame_start),
	.start_i         (start_track_R),
	.current_frame_i (frame),
	.rng_i           (rng),
	.active_i        (game_active),
	.reset_i         (reset_game),
	
	.slug_x_i        (slug_x),
	
	.train1_top_o    (trainR1_top),
	.train1_height_o (trainR1_height),
	.train2_top_o    (trainR2_top),
	.train2_height_o (trainR2_height),

	.score_points_o  (trainR_score),
	.slug_collision_o(trainR_collision)
);

wire collision = !sw_i[3] && (trainL_collision || trainR_collision || trainC_collision && !currently_hovering);

// DISPLAY OUT

wire [3:0] red, green, blue;
vga_renderer #(
	.OVERSCAN_X(OVERSCAN_X),
	.OVERSCAN_Y(OVERSCAN_Y),
	.TRAIN_L_LEFT(TRACK_C - TRACK_OFF),
	.TRAIN_C_LEFT(TRACK_C),
	.TRAIN_R_LEFT(TRACK_C + TRACK_OFF),
	.TRAIN_WIDTH(60)
) vga_renderer (
	.clk_i     (clk_i),
	.pixel_x_i (pixel_x),
	.pixel_y_i (pixel_y),
	.frame_i   (frame),

	.energy_i  (energy),
	.slug_x_i  (slug_x),
	.hovering_i(currently_hovering),
	.slug_flashing_i (slug_flashing),

	// .debug_i   (sw_i[7:0]),

	.trainL1_top_i   (trainL1_top),
	.trainL1_height_i(trainL1_height),
	.trainL2_top_i   (trainL2_top),
	.trainL2_height_i(trainL2_height),
	.trainC1_top_i   (trainC1_top),
	.trainC1_height_i(trainC1_height),
	.trainC2_top_i   (trainC2_top),
	.trainC2_height_i(trainC2_height),
	.trainR1_top_i   (trainR1_top),
	.trainR1_height_i(trainR1_height),
	.trainR2_top_i   (trainR2_top),
	.trainR2_height_i(trainR2_height),

	.r_o       (red),
	.g_o       (green),
	.b_o       (blue)
);

FDRE hdmi_red_sync   [3:0] (.C(clk_i), .R(4'b0), .CE(~(4'b0)), .D(red   & {4{active}}), .Q(hdmi_red_o));
FDRE hdmi_green_sync [3:0] (.C(clk_i), .R(4'b0), .CE(~(4'b0)), .D(green & {4{active}}), .Q(hdmi_green_o));
FDRE hdmi_blue_sync  [3:0] (.C(clk_i), .R(4'b0), .CE(~(4'b0)), .D(blue  & {4{active}}), .Q(hdmi_blue_o));
FDRE hdmi_dispen_sync (.C(clk_i), .R(0), .CE(1), .D(active), .Q(hdmi_dispen_o));

// 7SEG OUT

wire [3:0] hex_digit_index;
ring_counter ring_counter(
	.clk_i    (clk_i),
	.advance_i(digsel),
	.ring_o   (hex_digit_index)
);
assign an_o = {
	~hex_digit_index[3],
	~hex_digit_index[2],
	~hex_digit_index[1],
	~hex_digit_index[0]
};

wire [3:0] current_hex_digit =
	// {4{hex_digit_index[3]}} & trainL1_top[15:12] |
	// {4{hex_digit_index[2]}} & trainL1_top[11:8] |
	// {4{hex_digit_index[1]}} & trainL1_top[7:4] |
	// {4{hex_digit_index[0]}} & trainL1_top[3:0];
	{4{hex_digit_index[3]}} &   lives[3:0] |
	// {4{hex_digit_index[2]}} & 0 |
	{4{hex_digit_index[1]}} & score_q[7:4] |
	{4{hex_digit_index[0]}} & score_q[3:0];

wire [6:0] encoded_digit;
hex7seg hex7seg(
	.N_i  (current_hex_digit),
	.Seg_o(encoded_digit)
);
assign seg_o = encoded_digit;
assign dp_o = 1;//hex_digit_index != 4'b0100;

// LED OUT

// assign led_o[15] = frame[0]; // heartbeat
// assign led_o[14] = collision;
// assign led_o[13] = game_active;

endmodule
