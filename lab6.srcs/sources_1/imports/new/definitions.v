// `include "../../sources_1/imports/new/definitions.v"

`ifndef __DEFINITIONS_V
`define __DEFINITIONS_V

`timescale 1ns / 1ps

// "You will be typing FDRE until your fingers fall off" -Raphael
`define FCREDQI(clock, reset, enable, data, qata, init) \
	FDRE #(.INIT(init)) FF_`__LINE__ (.C(clock), .R(reset), .CE(enable), .D(data), .Q(qata))
`define FCDQ(clock, data, qata) `FCREDQI(clock, 1'b0, 1'b1, data, qata, 1'b0)
`define FCDQI(clock, data, qata, init) `FCREDQI(clock, 1'b0, 1'b1, data, qata, init)
`define FF_BUS(clock, data, qata, startbit, endbit) \
	generate for (genvar GV_`__LINE__ = (startbit); GV_`__LINE__ <= (endbit); GV_`__LINE__ = GV_`__LINE__ + 1) begin `FCDQ(clk_i, data[GV_`__LINE__], qata[GV_`__LINE__]); end endgenerate
`define FF_BUS_E(clock, enable, data, qata, startbit, endbit) \
	generate for (genvar GV_`__LINE__ = (startbit); GV_`__LINE__ <= (endbit); GV_`__LINE__ = GV_`__LINE__ + 1) begin `FCREDQI(clk_i, 1'b0, (enable), data[GV_`__LINE__], qata[GV_`__LINE__], 1'b0); end endgenerate
`define FF_BUS_R(clock, reset, data, qata, startbit, endbit) \
	generate for (genvar GV_`__LINE__ = (startbit); GV_`__LINE__ <= (endbit); GV_`__LINE__ = GV_`__LINE__ + 1) begin `FCREDQI(clk_i, (reset), 1'b1, data[GV_`__LINE__], qata[GV_`__LINE__], 1'b0); end endgenerate


// it's backwards and I don't know why
`define FF_BUS_I(clock, data, qata, startbit, endbit, init) \
	generate parameter [endbit:startbit] GVINT`__LINE__ = init; for (genvar GVIDX`__LINE__ = startbit; GVIDX`__LINE__ <= endbit; GVIDX`__LINE__ = GVIDX`__LINE__ + 1) begin `FCDQI(clk_i, data[GVIDX`__LINE__], qata[GVIDX`__LINE__], GVINT`__LINE__[GVIDX`__LINE__]); end endgenerate

`define IF(width, argument, truecase, falsecase) ({width{argument}} & (truecase) | {width{~(argument)}} & (falsecase))
`define IF1(argument, truecase, falsecase) IF(1, argument, truecase, falsecase)

`endif
