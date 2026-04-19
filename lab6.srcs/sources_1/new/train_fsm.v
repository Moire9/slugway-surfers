`include "../../sources_1/imports/new/definitions.v"


module train_fsm #(
	parameter LEFT_COLUMN = 0, // for horizontal positioning
	parameter NEXT_TRAIN_SPAWN = 400, // when the bottom of a train reaches this, the next spawns
	parameter [15:0] SPAWN = 0, // see below
	parameter DESPAWN = 0 // variable due to overscan - when train is off screen - equal to (ROWS - BORDER - OVERSCAN, possibly 2x)
) (
	input clk_i,

	input tick_i,
	input start_i,
	input [15:0] current_frame_i,
	input [7:0] rng_i,
	input active_i,
	input reset_i,

	input [15:0] slug_x_i,

	// output [5:0] debug_state,

	output [15:0] train1_top_o,
	output [15:0] train1_height_o, // set to 0 to disable train
	output [15:0] train2_top_o,
	output [15:0] train2_height_o,

	output score_points_o,
	output slug_collision_o
);

// CONSTANTS

localparam TRAIN_WIDTH = 60; // px
localparam MIN_TRAIN_LENGTH = 60; // added by 0~63 rng
// localparam AWARD_POINTS = ;

localparam [15:0] SLUG_W = 16;
localparam [15:0] SLUG_Y = 360;

localparam   RESET = 0;
localparam   DELAY = 1;
localparam DESCEND = 2;

localparam STATES = 3;

// ======== TRAIN 1 ========
// STATES

wire [STATES-1:0] state1_d, state1_q;
// `FF_BUS_I(clk_i, state1_d, state1_q, 0, STATES - 1, 3'b001);
`FCDQI(clk_i, state1_d[0], state1_q[0], 1);
`FCDQ (clk_i, state1_d[1], state1_q[1]);
`FCDQ (clk_i, state1_d[2], state1_q[2]);

// TRANSITIONS

// Signal t2 -> t1 to start
wire spawn_train_1 = train2_height_q + train2_top_q == NEXT_TRAIN_SPAWN;

wire reset_to_delay_1   = state1_q[RESET]   && (start_i || spawn_train_1);
wire delay_to_descend_1 = state1_q[DELAY]   && tick_i && train1_delay_q == 0;
wire descend_to_reset_1 = state1_q[DESCEND] && tick_i && train1_top_q == DESPAWN;

assign state1_d[  RESET] = reset_i ? 1 : state1_q[  RESET] && !reset_to_delay_1   || descend_to_reset_1;
assign state1_d[  DELAY] = reset_i ? 0 : state1_q[  DELAY] && !delay_to_descend_1 || reset_to_delay_1;
assign state1_d[DESCEND] = reset_i ? 0 : state1_q[DESCEND] && !descend_to_reset_1 || delay_to_descend_1;

// FSM VARIABLES

wire [15:0] train1_top_d, train1_top_q;
`FF_BUS(clk_i, train1_top_d, train1_top_q, 0, 15);
assign train1_top_d = reset_i ? 0 : !active_i ? train1_top_q :
		delay_to_descend_1 ? SPAWN - (60 + rng_i[5:0]) : // if we are starting to descent, go to top (including height)
		state1_q[DESCEND] && tick_i ? train1_top_q + 1 : // otherwise move down 1px if descending
		train1_top_q // otherwise maintain
;

assign train1_top_o = train1_top_q;

wire [6:0] train1_delay_d, train1_delay_q;
`FF_BUS(clk_i, train1_delay_d, train1_delay_q, 0, 6);
assign train1_delay_d = !active_i ? train1_delay_q :
		reset_to_delay_1 ? rng_i[6:0] : // initialize if entering delay state
		train1_delay_q == 0 ? train1_delay_q : // if 0, do nothing
		tick_i ? train1_delay_q - 1 : train1_delay_q // else decrement on tick
;

wire [6:0] train1_height_d, train1_height_q;
`FF_BUS(clk_i, train1_height_d, train1_height_q, 0, 6);
assign train1_height_d = reset_i ? 0 : !active_i ? train1_height_q :
		delay_to_descend_1 ? 60 + rng_i[5:0] : // if entering descent, set height
		train1_height_q // otherwise keep
;

assign train1_height_o = train1_height_q;


// ======== TRAIN 2 ========
// STATES

wire [STATES-1:0] state2_d, state2_q;
// `FF_BUS_I(clk_i, state2_d, state2_q, 0, STATES - 1, 3'b001);
`FCDQI(clk_i, state2_d[0], state2_q[0], 1);
`FCDQ (clk_i, state2_d[1], state2_q[1]);
`FCDQ (clk_i, state2_d[2], state2_q[2]);

// TRANSITIONS

// Signal t1 -> t2 to start
wire spawn_train_2 = train1_top_q + train1_height_q == NEXT_TRAIN_SPAWN;

wire reset_to_delay_2   = state2_q[RESET]   && spawn_train_2;
wire delay_to_descend_2 = state2_q[DELAY]   && tick_i && train2_delay_q == 0;
wire descend_to_reset_2 = state2_q[DESCEND] && tick_i && train2_top_q == DESPAWN;

assign state2_d[  RESET] = reset_i ? 1 : state2_q[  RESET] && !reset_to_delay_2   || descend_to_reset_2;
assign state2_d[  DELAY] = reset_i ? 0 : state2_q[  DELAY] && !delay_to_descend_2 || reset_to_delay_2;
assign state2_d[DESCEND] = reset_i ? 0 : state2_q[DESCEND] && !descend_to_reset_2 || delay_to_descend_2;

// FSM VARIABLES

wire [15:0] train2_top_d, train2_top_q;
`FF_BUS(clk_i, train2_top_d, train2_top_q, 0, 15);
assign train2_top_d = reset_i ? 0 : !active_i ? train2_top_q :
		delay_to_descend_2 ? SPAWN - (60 + rng_i[5:0]) : // if we are starting to descent, go to top (including height)
		state2_q[DESCEND] && tick_i ? train2_top_q + 1 : // otherwise move down 1px if descending
		train2_top_q // otherwise maintain
;

assign train2_top_o = train2_top_q;

wire [6:0] train2_delay_d, train2_delay_q;
`FF_BUS(clk_i, train2_delay_d, train2_delay_q, 0, 6);
assign train2_delay_d = !active_i ? train2_delay_q :
		reset_to_delay_2 ? rng_i[6:0] : // initialize if entering delay state
		train2_delay_q == 0 ? train2_delay_q : // if 0, do nothing
		tick_i ? train2_delay_q - 1 : train2_delay_q // else decrement on tick
;

wire [6:0] train2_height_d, train2_height_q;
`FF_BUS(clk_i, train2_height_d, train2_height_q, 0, 6);
assign train2_height_d = reset_i ? 0 : !active_i ? train2_height_q :
		delay_to_descend_2 ? 60 + rng_i[5:0] : // if entering descent, set height
		train2_height_q // otherwise keep
;

assign train2_height_o = train2_height_q;

// To prevent getting 410000 points because the train is on this line for an entire frame
edge_detector score_points_sync(
	.clk_i   (clk_i),
	.button_i(train1_top_q == SLUG_Y + SLUG_W || train2_top_q == SLUG_Y + SLUG_W),
	.edge_o  (score_points_o)
);

assign slug_collision_o = (LEFT_COLUMN - SLUG_W < slug_x_i && slug_x_i <= LEFT_COLUMN + TRAIN_WIDTH) && (
	(train1_top_q - SLUG_W < SLUG_Y && SLUG_Y <= train1_top_q + train1_height_q) ||
	(train2_top_q - SLUG_W < SLUG_Y && SLUG_Y <= train2_top_q + train2_height_q));

// assign debug_state = {state2_q, state1_q};

endmodule
