module sim_slug_fsm();

reg clk_i = 0;

reg try_move_left_i = 0;
reg try_move_right_i = 0;
reg try_hover_i = 0;

reg frame_start_i = 0;
reg [15:0] current_frame_i = 0;

wire [7:0] state_debug;

wire [15:0] slug_x_o;
wire [7:0] energy_o; // [0, 192]

slug_fsm DUT(
	.clk_i(clk_i),
	.try_move_left_i(try_move_left_i),
	.try_move_right_i(try_move_right_i),
	.try_hover_i(try_hover_i),
	.frame_start_i(frame_start_i),
	.current_frame_i(current_frame_i),
	.state_debug(state_debug),
	.slug_x_o(slug_x_o),
	.energy_o(energy_o)
);

initial begin
	forever begin
		#1;
		clk_i = ~clk_i;
	end
end

initial begin
	forever begin
		#10;
		@(negedge clk_i);
		frame_start_i = 1;
		#1;
		@(negedge clk_i);
		frame_start_i = 0;

	end
end

endmodule
