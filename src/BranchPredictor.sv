`timescale 1ns / 1ps
`include "define.svh"

import BasicTypes::*;
import PipelineTypes::*;

module BranchPredictor(
  BranchPredictorIF.BranchPredictor port
);

  always_ff@(posedge port.clk) begin
    //とりあえず必ずnot taken
    port.isBranchTakenPredicted <= `DISABLE;
  end
endmodule
