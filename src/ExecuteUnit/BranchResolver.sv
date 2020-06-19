//`timescale 1ns / 1ps
`include "../define.svh"

import BasicTypes::*;
import PipelineTypes::*;
import OpTypes::*;

module BranchResolver(
  input var PC pc,
  input var logic isBranch,
  input var BranchResolverCtrl brCtrl,
  input var BasicData imm,
  input var BasicData rs1Data,
  input var BasicData rs2Data,
  input var BasicData npcOp1,
  input var BasicData npcOp2,
  output var PC irregPc,
  output var logic isBranchTaken
);

  always_comb begin
    unique case (brCtrl)
      BR_EQ: begin
        isBranchTaken = rs1Data == rs2Data ? `ENABLE : `DISABLE;
      end
      BR_NE: begin
        isBranchTaken = rs1Data != rs2Data ? `ENABLE : `DISABLE;
      end
      BR_LT: begin
        isBranchTaken = ((rs1Data - rs2Data) & (32'b1 << 31)) ? `ENABLE : `DISABLE;
      end
      BR_GE: begin
        isBranchTaken = (((rs2Data - rs1Data) & (32'b1 << 31)) || (rs1Data == rs2Data)) ? `ENABLE : `DISABLE;
      end
      BR_LTU: begin
        isBranchTaken = rs1Data < rs2Data ? `ENABLE : `DISABLE;
      end
      BR_GEU: begin
        isBranchTaken = rs1Data >= rs2Data ? `ENABLE : `DISABLE;
      end
      BR_JUMP: begin
        isBranchTaken = `ENABLE;
      end

      BR_NONE: begin
        isBranchTaken = `DISABLE;
      end
      default : begin
        isBranchTaken = `DISABLE;
      end
    endcase

    irregPc = (isBranch == `ENABLE) ? ((isBranchTaken == `ENABLE) ? npcOp1 + npcOp2 : npcOp1 + 4) : 31'd0;
  end
endmodule
