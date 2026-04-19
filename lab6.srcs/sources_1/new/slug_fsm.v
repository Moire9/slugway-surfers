`include "../../sources_1/imports/new/definitions.v"

module slug_fsm(
	input clk_i,
	
	input try_move_left_i,
	input try_move_right_i,
	input try_hover_i,

	input active_i,
	input reset_i,
	input frame_start_i,
	input [15:0] current_frame_i,

	// output [7:0] state_debug,

	output hovering_o,
	output [15:0] slug_x_o,
	output [7:0] energy_o // [0, 192]
);

localparam [15:0] CENTER_POSITION = 340; // px
localparam SIDE_DISTANCE = 60 + 10; // width of a train plus gap
localparam MOVEMENT_SPEED = 2; // px/frame


// Declare states

localparam STATES = 8;

localparam   CENTER = 0;
localparam    RIGHT = 1;
localparam     LEFT = 2;
localparam    HOVER = 3;
localparam RC_TRANS = 4;
localparam CR_TRANS = 5;
localparam LC_TRANS = 6;
localparam CL_TRANS = 7;


// Current state and non-state states

// Need to seperately check energy
wire hover_allowed = try_hover_i && (state_q[CENTER] || state_q[HOVER]) && active_i;

wire [STATES-1:0] state_d, state_q;
// FDRE #(.INIT(8'b00000010)) state [STATES-1:0] (.C(clk_i), .R(1'b0), .CE(1'b1), .D(state_d), .Q(state_q));
`FCDQI (clk_i, state_d[0], state_q[0], 1'b1);
`FF_BUS(clk_i, state_d, state_q, 1, 7);


wire [7:0] energy_d, energy_q;
FDRE #(.INIT(1)) energy [7:0] (.C(clk_i), .R(1'b0), .CE(1'b1), .D(energy_d), .Q(energy_q));


assign energy_d = frame_start_i ? // only change energy between frames
		energy_q == 0 ? (hover_allowed ? 0 : 1) : // if no energy left, then only begin regenerating if not trying to hover_allowed
			hover_allowed ? energy_q - 1 : // if hovering, decrement energy
				energy_q >= 192 ? 192 : energy_q + 1 // else increment if not at max
	: energy_q;

assign energy_o = energy_q;


// wire [15:0] frames_d, frames_q;
// FDRE frames [15:0] (.C(clk_i), .R(16'b0), .CE(~(16'b0)), .D(frames_d), .Q(frames_q));
// assign frames_d = frames_q + 1;

wire [15:0] slug_x_d, slug_x_q;
`FF_BUS_I(clk_i, slug_x_d, slug_x_q, 0, 15, CENTER_POSITION);
// `FF_BUS(clk_i, slug_x_d, slug_x_q, 0, 7);
// `FCDQI (clk_i, slug_x_d[8], slug_x_q[8], 1'b1);
// `FF_BUS(clk_i, slug_x_d, slug_x_q, 9, 15);
assign slug_x_d = frame_start_i && active_i ? // only change between frames and when active
		(state_q[RC_TRANS] || state_q[CL_TRANS]) ? slug_x_q - MOVEMENT_SPEED :
		(state_q[LC_TRANS] || state_q[CR_TRANS]) ? slug_x_q + MOVEMENT_SPEED :
		slug_x_q
	: reset_i ? CENTER_POSITION : slug_x_q;

assign slug_x_o = slug_x_q;

// State transitions

wire begin_cr_trans = state_q[CENTER] && active_i && try_move_right_i;
wire begin_cl_trans = state_q[CENTER] && active_i && try_move_left_i;
wire begin_rc_trans = state_q[RIGHT]  && active_i && try_move_left_i;
wire begin_lc_trans = state_q[LEFT]   && active_i && try_move_right_i;

wire end_cr_trans = state_q[CR_TRANS] && active_i && slug_x_q >= CENTER_POSITION + SIDE_DISTANCE;
wire end_cl_trans = state_q[CL_TRANS] && active_i && slug_x_q <= CENTER_POSITION - SIDE_DISTANCE;
wire end_rc_trans = state_q[RC_TRANS] && active_i && slug_x_q == CENTER_POSITION;
wire end_lc_trans = state_q[LC_TRANS] && active_i && slug_x_q == CENTER_POSITION;

wire center_to_hover = state_q[CENTER]&& active_i  && (hover_allowed && energy_q > 0);
wire hover_to_center = state_q[HOVER] && active_i && !(hover_allowed && energy_q > 0);

// State transition impl

assign state_d[   RIGHT] = reset_i ? 0 : state_q[   RIGHT] && !begin_rc_trans || end_cr_trans;
assign state_d[  CENTER] = reset_i ? 1 : state_q[  CENTER] && !(begin_cr_trans || begin_cl_trans || center_to_hover)
	|| end_lc_trans || end_rc_trans || hover_to_center;
assign state_d[    LEFT] = reset_i ? 0 : state_q[    LEFT] && !begin_lc_trans || end_cl_trans;
assign state_d[   HOVER] = reset_i ? 0 : state_q[   HOVER] && !hover_to_center || center_to_hover;

assign state_d[RC_TRANS] = reset_i ? 0 : state_q[RC_TRANS] && !end_rc_trans || begin_rc_trans;
assign state_d[CR_TRANS] = reset_i ? 0 : state_q[CR_TRANS] && !end_cr_trans || begin_cr_trans;
assign state_d[LC_TRANS] = reset_i ? 0 : state_q[LC_TRANS] && !end_lc_trans || begin_lc_trans;
assign state_d[CL_TRANS] = reset_i ? 0 : state_q[CL_TRANS] && !end_cl_trans || begin_cl_trans;

// Some outputs

assign hovering_o = state_q[HOVER];
// assign state_debug = state_q;

endmodule
