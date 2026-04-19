`include "../../sources_1/imports/new/definitions.v"

module sim_train_fsm();

reg clk_i = 0;

reg tick_i = 0;
reg start_i = 0;
reg [15:0] current_frame_i = 0;
reg [7:0] rng_i = 1;

reg [15:0] slug_x_i = 120;

wire [15:0] train1_top_o;
wire [15:0] train1_height_o; // set to 0 to disable train
wire [15:0] train2_top_o;
wire [15:0] train2_height_o;

wire [2:0] debug_states1_o;
wire [2:0] debug_states2_o;

wire slug_collision_o;

train_fsm #(
	.LEFT_COLUMN     (100),
	.SPAWN           (0),
	.DESPAWN         (480)
) DUT (
	.clk_i(clk_i),
	.tick_i(tick_i),
	.start_i(start_i),
	.current_frame_i(current_frame_i),
	.rng_i(rng_i),
	.slug_x_i(slug_x_i),
	.train1_top_o(train1_top_o),
	.train1_height_o(train1_height_o),
	.train2_top_o(train2_top_o),
	.train2_height_o(train2_height_o),
	.debug_states1_o(debug_states1_o),
	.debug_states2_o(debug_states2_o),
	.slug_collision_o(slug_collision_o)
);

integer count;
initial begin
	count = 0;
	forever begin
		rng_i = rng_i << 1 | (rng_i[0] ^ rng_i[5] ^ rng_i[6] ^ rng_i[7]);
		// every 16 cycles
		if (count[3:0] == 0) begin
			count = 0;

			current_frame_i = current_frame_i + 1;
			tick_i = 1;
		end else begin
			tick_i = 0;
		end
		clk_i = ~clk_i;
		count = count + 1;
		#1;
	end
end

endmodule
