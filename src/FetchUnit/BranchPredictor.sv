//`timescale 1ns / 1ps
`include "../define.svh"

import BasicTypes::*;
import PipelineTypes::*;

module BranchPredictor(
  BranchPredictorIF.BranchPredictor port,
  ControllerIF.BranchPredictor controller,
  ExecuteStageIF.BranchPredictor execute
);

  logic [1:0] State;

  always_ff@(posedge port.clk) begin
    if (port.rst == 1'b0) begin
      State <= 2'b01;
    end
    else if (execute.isBranch == `ENABLE) begin
      case (State)
        2'b00: begin
          if (execute.branchTaken == `ENABLE) begin
            State <= 2'b01;
          end
          else begin
            State <= 2'b00;
          end
        end
        2'b01: begin
          if (execute.branchTaken == `ENABLE) begin
            State <= 2'b11;
          end
          else begin
            State <= 2'b00;
          end
          
        end
        2'b10: begin
          if (execute.branchTaken == `ENABLE) begin
            State <= 2'b11;
          end
          else begin
            State <= 2'b01;
          end
          
        end
        2'b11: begin
          if (execute.branchTaken == `ENABLE) begin
            State <= 2'b11;
          end
          else begin
            State <= 2'b10;
          end
        end
      endcase
    end
  end

  always_comb begin
    //port.isBranchTakenPredicted = `DISABLE;
    case (State)
      2'b00: begin
        port.isBranchTakenPredicted = `DISABLE;
      end
      2'b01: begin
        port.isBranchTakenPredicted = `DISABLE;
      end
      2'b10: begin
        port.isBranchTakenPredicted = `ENABLE;
      end
      2'b11: begin
        port.isBranchTakenPredicted = `ENABLE;
      end
    endcase
  end
endmodule
