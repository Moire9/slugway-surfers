`include "../../sources_1/imports/new/definitions.v"

module game_fsm(
	input clk_i,

	input      request_start_i,
	input [15:0] frame_count_i,
	input    train_collision_i,
	input          inc_lives_i, // only works in WAITING

	// output [7:0] state_debug,

	output   game_active_o,
	output    reset_game_o,
	output start_track_L_o,
	output start_track_C_o,
	output start_track_R_o,
	output slug_flashing_o,
	output [3:0]   lives_o
);

// CONSTANTS
localparam ONE_TRACK_DURATION = 2 * 60; // frames
localparam TWO_TRACK_DURATION = 6 * 60; // frames

// STATE DEFINITION

localparam   WAITING = 0; // before game starts
localparam ONE_TRACK = 1; // two seconds of gameplay before R opens, not long enough to die
localparam TWO_TRACK = 2; // six seconds of gameplay before C opens
localparam   PLAYING = 3; // normal gameplay
localparam   STUNNED = 4; // hit train, lost life, flashing
localparam      DEAD = 5; // no lives remaining
localparam    RESET1 = 6; // intermediate state to allow resetting the game state before starting again
localparam    RESET2 = 7; // please excuse my terrible coding

localparam STATES = RESET2 + 1;

wire [STATES - 1:0] state_d, state_q;
`FCDQI (clk_i, state_d[0], state_q[0], 1);
`FF_BUS(clk_i, state_d, state_q, 1, STATES - 1);

// assign state_debug = state_q;

// TRANSITIONS

wire waiting_to_one_track   = state_q[WAITING] && request_start_i;
wire one_track_to_two_track = state_q[ONE_TRACK] && start_frame_q + ONE_TRACK_DURATION == frame_count_i;
wire two_track_to_playing   = state_q[TWO_TRACK] && start_frame_q + ONE_TRACK_DURATION + TWO_TRACK_DURATION == frame_count_i;

wire two_track_to_stunned   = state_q[TWO_TRACK] && train_collision_i && lives_q != 0;
wire two_track_to_dead      = state_q[TWO_TRACK] && train_collision_i && lives_q == 0;
wire playing_to_stunned     = state_q[PLAYING]   && train_collision_i && lives_q != 0;
wire playing_to_dead        = state_q[PLAYING]   && train_collision_i && lives_q == 0;

wire stunned_to_reset1      = state_q[STUNNED] && request_start_i;
wire reset1_to_reset2       = state_q[RESET1];
wire reset2_to_one_track    = state_q[RESET2];

assign state_d[  WAITING] = state_q[  WAITING] && !waiting_to_one_track;
assign state_d[ONE_TRACK] = state_q[ONE_TRACK] && !one_track_to_two_track
	|| waiting_to_one_track || reset2_to_one_track;
assign state_d[TWO_TRACK] = state_q[TWO_TRACK] && !(two_track_to_playing || two_track_to_stunned || two_track_to_dead)
	|| one_track_to_two_track;
assign state_d[  PLAYING] = state_q[  PLAYING] && !(playing_to_stunned || playing_to_dead)
	|| two_track_to_playing;
assign state_d[  STUNNED] = state_q[  STUNNED] && !stunned_to_reset1
	|| two_track_to_stunned || playing_to_stunned;
assign state_d[     DEAD] = state_q[     DEAD]
	|| two_track_to_dead || playing_to_dead;
assign state_d[   RESET1] = state_q[   RESET1] && !reset1_to_reset2
	|| stunned_to_reset1;
assign state_d[   RESET2] = state_q[   RESET2] && !reset2_to_one_track
	|| reset1_to_reset2;

wire [3:0] lives_d, lives_q;
`FF_BUS_I(clk_i, lives_d, lives_q, 0, 3, 0);
assign lives_d =
	(two_track_to_stunned || playing_to_stunned) ? lives_q - 1 : // decrement when hitting a train
	(state_q[WAITING] && inc_lives_i) ? lives_q + 1 : // before game starts, press L to add more lives
	lives_q;

wire [15:0] start_frame_q, start_frame_d;
`FF_BUS(clk_i, start_frame_d, start_frame_q, 0, 15);
assign start_frame_d = (waiting_to_one_track || reset2_to_one_track) ? frame_count_i :
	start_frame_q; // if (re)starting game, save current frame as reference, else keep

assign game_active_o = state_q[ONE_TRACK] || state_q[TWO_TRACK] || state_q[PLAYING] || state_q[RESET1] || state_q[RESET2];
assign reset_game_o = state_q[RESET1];
assign start_track_L_o = waiting_to_one_track || reset2_to_one_track;
assign start_track_R_o = one_track_to_two_track;
assign start_track_C_o = two_track_to_playing;
assign slug_flashing_o = state_q[STUNNED] || state_q[DEAD];
assign lives_o = lives_q;


endmodule
