`timescale 1ns / 1ps
`include "../define.svh"

import BasicTypes::*;
import PipelineTypes::*;

module MultiStageMulDiv(
  input var clk,
  input var rst,
  input var isMulDiv,
  input var MulDivCode mulDivCode,
  input var BasicData op1,
  input var BasicData op2,
  output var logic isStructureStall,
  output var BasicData result
);

  BasicData mulDivResult;
  logic [5:0] state;
  MulDivCode mulDivCodeFF;
  BasicData op1FF;
  BasicData op2FF;

  MulDivUnit2 MulDivUnit2(
    .clk(clk),
    .mulDivCode(mulDivCodeFF),
    .op1(op1FF),
    .op2(op2FF),
    .result(mulDivResult)
  );

  always_ff@(posedge clk) begin
    if (rst == 1'b0 || !isMulDiv) begin
      isStructureStall <= `DISABLE;
      state <= 6'd0;
    end
    else if (isMulDiv && state == 6'd0) begin
      isStructureStall <= `ENABLE;
      state <= 6'd1;
      mulDivCodeFF <= mulDivCode;
      op1FF <= op1;
      op2FF <= op2;
    end
    else if (state == 6'd15) begin
      state <= 6'd0;
      isStructureStall <= `DISABLE;
      result <= mulDivResult;
    end
    else begin
      isStructureStall <= `ENABLE;
      state <= state + 1;
    end
  end
endmodule
