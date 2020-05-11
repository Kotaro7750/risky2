`timescale 1ns / 1ps

import BasicTypes::*;
import PipelineTypes::*;

module execute(
  ExecuteStageIF.ThisStage port,
  DecodeStageIF.NextStage prev
);

  logic [31:0]alu_op1;
  logic [31:0]alu_op2;
  logic [31:0]npc_op1;
  logic [31:0]npc_op2;
  logic [31:0]aluResult;
  logic [1:0]memAccessWidth;
  logic [31:0]irregPc;
  logic isLoadUnsigned;
  logic isBranch;
  logic brTaken;

  assign port.rdCtrl = prev.nextStage.rdCtrl;

  MemoryAccessStagePipeReg nextStage;
  assign port.nextStage = nextStage;

  always_ff@(negedge port.clk) begin
    if (port.rst == 1'b0) begin
      nextStage.pc <= 32'd0;
      nextStage.aluResult <= 32'd0;
      nextStage.wData <= 32'd0;
      nextStage.memAccessWidth <= 2'd0;
      nextStage.rdCtrl <= {`DISABLE,5'd0};
      nextStage.isStore <= `DISABLE;
      nextStage.isLoad <= `DISABLE;
      nextStage.isLoadUnsigned <= `DISABLE;
      port.irregPc <= 32'd0;
    end
    else begin
      nextStage.pc <= prev.nextStage.pc;
      nextStage.aluResult <= aluResult;
      nextStage.wData <= prev.nextStage.rs2Data;
      nextStage.memAccessWidth <= memAccessWidth;
      nextStage.rdCtrl <= prev.nextStage.rdCtrl;
      nextStage.isStore <= prev.nextStage.isStore;
      nextStage.isLoad <= prev.nextStage.isLoad;
      nextStage.isLoadUnsigned <= isLoadUnsigned;
      port.irregPc <= irregPc;
    end
  end

  exec_switcher exec_switcher(
    .pc(prev.nextStage.pc),
    .rs1(prev.nextStage.rs1Data),
    .rs2(prev.nextStage.rs2Data),
    .imm(prev.nextStage.imm),
    .aluCtrl(prev.nextStage.aluCtrl),
    .alu_op1(alu_op1),
    .alu_op2(alu_op2),
    .npc_op1(npc_op1),
    .npc_op2(npc_op2)
  );

  alu alu(
    .alucode(prev.nextStage.aluCtrl.aluCode),
    .op1(alu_op1),
    .op2(alu_op2),
    .aluResult(aluResult),
    .isBranch(isBranch),
    .brTaken(brTaken),
    .memAccessWidth(memAccessWidth),
    .isLoadUnsigned(isLoadUnsigned)
  );

  irreg_pc_gen irreg_pc_gen(
    .op1(npc_op1),
    .op2(npc_op2),
    .brTaken(brTaken),
    .isBranch(isBranch),
    .irregPc(irregPc)
  );

endmodule
