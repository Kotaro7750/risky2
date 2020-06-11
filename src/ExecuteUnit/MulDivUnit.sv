`timescale 1ns / 1ps
`include "./define.svh"

import BasicTypes::*;
import PipelineTypes::*;

module MulDivUnit(
  input var MulDivCode mulDivCode,
  input var BasicData op1,
  input var BasicData op2,
  output var BasicData result
);

  logic [63:0] result64;

  always_comb begin
    unique case (mulDivCode)
      MULDIV_MUL: begin
        result64 = op1 * op2;
        result = result64[31:0];
      end
      MULDIV_MULH: begin
        result64 = $signed(op1) * $signed(op2);
        result = result64[63:32];
      end
      MULDIV_MULHSU: begin
        //言語仕様上、オペランドの片方が符号なしだと結果も符号なしになってしまうので無理やり符号付きにする
        result64 = $signed(op1) * $signed({1'b0, op2});
        result = result64[63:32];
      end
      MULDIV_MULHU: begin
        result64 = $unsigned(op1) * $unsigned(op2);
        result = result64[63:32];
      end
      MULDIV_DIV: begin
        if (op2 == 32'd0) begin
          result = 32'hffffffff;
        end
        else if (op1 == 32'h80000000 && op2 == 32'hffffffff) begin
          result = 32'h80000000;
        end
        else begin
          result = $signed(op1) / $signed(op2);
        end
      end
      MULDIV_DIVU: begin
        if (op2 == 32'd0) begin
          result = 32'hffffffff;
        end
        else begin
          result = op1 / op2;
        end
      end
      MULDIV_REM: begin
        if (op2 == 32'd0) begin
          result = op1;
        end
        else if (op1 == 32'h80000000 && op2 == 32'hffffffff) begin
          result = 32'd0;
        end
        else begin
          result = $signed(op1) / $signed(op2);
        end
      end
      MULDIV_REMU: begin
        if (op2 == 32'd0) begin
          result = op1;
        end
        else begin
          result = op1 % op2;
        end
      end
      default : begin
        result = 32'd0;
      end
    endcase
  end
endmodule
