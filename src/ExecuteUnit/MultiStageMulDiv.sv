//`timescale 1ns / 1ps
`include "../define.svh"

import BasicTypes::*;
import PipelineTypes::*;

module MultiStageMulDiv(
  input var clk,
  input var rst,
`ifdef BRANCH_M
  input var isBranchPredictMiss,
`endif
  input var isMulDiv,
  input var MulDivCode mulDivCode,
  input var BasicData op1,
  input var BasicData op2,
  output var logic isStructureStall,
  output var BasicData result
);

  BasicData mulDivResult;
  logic [3:0] state;
  MulDivCode mulDivCodeFF;
  BasicData op1FF;
  BasicData op2FF;

  MulDivUnit MulDivUnit(
    .clk(clk),
    .mulDivCode(mulDivCodeFF),
    .op1(op1FF),
    .op2(op2FF),
    .result(mulDivResult)
  );

  always_ff@(posedge clk) begin
  `ifndef BRANCH_M
    if (rst == 1'b0 || !isMulDiv) begin
  `else
    if (rst == 1'b0 || !isMulDiv || isBranchPredictMiss) begin
  `endif
      isStructureStall <= `DISABLE;
      state <= 4'd0;
    end
    else if (isMulDiv && state == 4'd0) begin
      isStructureStall <= `ENABLE;
      state <= 4'd1;
      mulDivCodeFF <= mulDivCode;
      op1FF <= op1;
      op2FF <= op2;
    end
    else if (state == 4'd7) begin
      state <= 4'd0;
      isStructureStall <= `DISABLE;
      result <= mulDivResult;
    end
    else begin
      isStructureStall <= `ENABLE;
      state <= state + 1;
    end
  end
endmodule
