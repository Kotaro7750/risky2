//`timescale 1ns / 1ps
`include "define.svh"

import BasicTypes::*;
import PipelineTypes::*;

module ExecuteStage(
  ExecuteStageIF.ThisStage port,
  DecodeStageIF.NextStage prev,
  BypassNetworkIF.ExecuteStage bypassNetwork,
  ControllerIF.ExecuteStage controller,
  DebugIF.ExecuteStage debug
);

  logic [31:0]alu_op1;
  logic [31:0]alu_op2;
  logic [31:0]npc_op1;
  logic [31:0]npc_op2;
  logic [31:0]aluResult;
  logic [31:0]mulDivResult;
  logic [31:0]irregPc;
  logic brTaken;

  assign port.rdCtrl = {prev.nextStage.opInfo.wEnable,prev.nextStage.rdAddr,prev.nextStage.opInfo.isForwardable};
  assign bypassNetwork.ExwData = nextStage.aluResult;

  MemoryAccessStagePipeReg nextStage;
  assign port.nextStage = nextStage;

  assign debug.executeStage = prev.nextStage;

  BasicData bypassedRs1;
  BasicData bypassedRs2;
  always_comb begin
    case (prev.nextStage.op1BypassCtrl)
      BYPASS_NONE: begin
        bypassedRs1 = prev.nextStage.rs1Data;
      end
      BYPASS_EXEC: begin
        bypassedRs1 = bypassNetwork.BypassExData;
      end
      BYPASS_MEM: begin
        bypassedRs1 = bypassNetwork.BypassMemData;
      end
    endcase

    case (prev.nextStage.op2BypassCtrl)
      BYPASS_NONE: begin
        bypassedRs2 = prev.nextStage.rs2Data;
      end
      BYPASS_EXEC: begin
        bypassedRs2 = bypassNetwork.BypassExData;
      end
      BYPASS_MEM: begin
        bypassedRs2 = bypassNetwork.BypassMemData;
      end
    endcase

    if (port.rst == 1'b0) begin
      port.isBranch = `DISABLE;
      port.branchTaken = `DISABLE;
      port.isBranchTakenPredicted = `DISABLE;
      port.isNextPcPredicted = `DISABLE;
      port.predictedNextPC = 32'd0;
      port.irregPc = 32'd0;
      port.pc = 32'd0;
    end
    else begin
      port.isBranch = prev.nextStage.opInfo.isBranch;
      port.branchTaken = brTaken;
      port.isBranchTakenPredicted = prev.nextStage.isBranchTakenPredicted;
      port.isNextPcPredicted = prev.nextStage.isNextPcPredicted;
      port.predictedNextPC = prev.nextStage.predictedNextPC;
      port.irregPc = irregPc;
      port.pc = prev.nextStage.pc;
    end
  end

  always_ff@(negedge port.clk) begin
    `ifndef BRANCH_M
    if (port.rst == 1'b0 || controller.isStructureStall) begin
    `else
    if (port.rst == 1'b0 || controller.isStructureStall || controller.isBranchPredictMiss) begin
    `endif
      nextStage.pc <= 32'd0;
      nextStage.aluResult <= 32'd0;
      nextStage.wData <= 32'd0;
      nextStage.memAccessWidth <= 2'd0;
      nextStage.rdCtrl <= {`DISABLE,5'd0,`DISABLE};
    `ifdef BRANCH_M
      nextStage.isBranch <= `DISABLE;
      nextStage.branchTaken <= `DISABLE;
      nextStage.isBranchTakenPredicted <= `DISABLE;
      nextStage.isNextPcPredicted <= `DISABLE;
      nextStage.predictedNextPC <= 32'd0;
      nextStage.irregPc <= 32'd0;
    `endif
      nextStage.isStore <= `DISABLE;
      nextStage.isLoad <= `DISABLE;
      nextStage.isLoadUnsigned <= `DISABLE;
    end
    else begin
      nextStage.pc <= prev.nextStage.pc;
      nextStage.aluResult <= prev.nextStage.opInfo.isMulDiv ? mulDivResult : aluResult;
      nextStage.wData <= bypassedRs2;
      nextStage.memAccessWidth <= prev.nextStage.opInfo.memAccessWidth;
      nextStage.rdCtrl <= {prev.nextStage.opInfo.wEnable,prev.nextStage.rdAddr,prev.nextStage.opInfo.isForwardable};
    `ifdef BRANCH_M
      nextStage.isBranch <= prev.nextStage.opInfo.isBranch;
      nextStage.branchTaken <= brTaken;
      nextStage.isBranchTakenPredicted <= prev.nextStage.isBranchTakenPredicted;
      nextStage.isNextPcPredicted <= prev.nextStage.isBranchTakenPredicted;
      nextStage.predictedNextPC <= prev.nextStage.predictedNextPC;
      nextStage.irregPc <= irregPc;
    `endif
      nextStage.isStore <= prev.nextStage.opInfo.isStore;
      nextStage.isLoad <= prev.nextStage.opInfo.isLoad;
      nextStage.isLoadUnsigned <= prev.nextStage.opInfo.isLoadUnsigned;
    end
  end

  execSwitcher execSwitcher(
    .pc(prev.nextStage.pc),
    .rs1(bypassedRs1),
    .rs2(bypassedRs2),
    .imm(prev.nextStage.imm),
    .aluCtrl(prev.nextStage.opInfo.aluCtrl),
    .opType(prev.nextStage.opInfo.opType),
    .alu_op1(alu_op1),
    .alu_op2(alu_op2),
    .npc_op1(npc_op1),
    .npc_op2(npc_op2)
  );

  IntALU IntALU(
    .alucode(prev.nextStage.opInfo.aluCtrl.aluCode),
    .op1(alu_op1),
    .op2(alu_op2),
    .aluResult(aluResult)
  );

  MultiStageMulDiv MultiStageMulDiv(
    .clk(port.clk),
    .rst(port.rst),
  `ifdef BRANCH_M
    .isBranchPredictMiss(controller.isBranchPredictMiss),
  `endif
    .isMulDiv(prev.nextStage.opInfo.isMulDiv),
    .mulDivCode(prev.nextStage.opInfo.mulDivCode),
    .op1(alu_op1),
    .op2(alu_op2),
    .isStructureStall(controller.isStructureStall),
    .result(mulDivResult)
  );

  BranchResolver BranchResolver(
    .pc(prev.nextStage.pc),
    .isBranch(prev.nextStage.opInfo.isBranch),
    .brCtrl(prev.nextStage.opInfo.brCtrl),
    .imm(prev.nextStage.imm),
    //.rs1Data(bypassedRs1),
    //.rs2Data(bypassedRs2),
    .rs1Data(alu_op1),
    .rs2Data(alu_op2),
    .npcOp1(npc_op1),
    .npcOp2(npc_op2),
    .irregPc(irregPc),
    .isBranchTaken(brTaken)
  );

endmodule
