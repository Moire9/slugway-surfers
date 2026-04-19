`timescale 1ns / 1ps

module sim_top();

reg clk = 0;

reg  [15:0] sw_i = 0;
reg btnC_async_i = 0;
reg btnU_async_i = 0;
reg btnD_async_i = 0;
reg btnL_async_i = 0;
reg btnR_async_i = 0;

top DUT(
    .board_clk_i(clk),
    .sw_i(sw_i),
    .btnC_async_i(btnC_async_i),
    .btnU_async_i(btnU_async_i),
    .btnD_async_i(btnD_async_i),
    .btnL_async_i(btnL_async_i),
    .btnR_async_i(btnR_async_i)
);

initial begin
    forever begin
        #1;
        clk = ~clk;
    end
end

endmodule
