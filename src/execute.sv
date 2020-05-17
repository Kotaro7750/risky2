`timescale 1ns / 1ps

import BasicTypes::*;
import PipelineTypes::*;

module execute(
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
  logic [1:0]memAccessWidth;
  logic [31:0]irregPc;
  logic isLoadUnsigned;
  logic isBranch;
  logic brTaken;

  assign port.rdCtrl = prev.nextStage.rdCtrl;
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
      port.isBranch = isBranch;
      port.branchTaken = brTaken;
      port.isBranchTakenPredicted = prev.nextStage.isBranchTakenPredicted;
      port.isNextPcPredicted = prev.nextStage.isNextPcPredicted;
      port.predictedNextPC = prev.nextStage.predictedNextPC;
      port.irregPc = irregPc;
      port.pc = prev.nextStage.pc;
    end
  end

  always_ff@(negedge port.clk) begin
    if (port.rst == 1'b0) begin
      nextStage.pc <= 32'd0;
      nextStage.aluResult <= 32'd0;
      nextStage.wData <= 32'd0;
      nextStage.memAccessWidth <= 2'd0;
      nextStage.rdCtrl <= {`DISABLE,5'd0,`DISABLE};
      nextStage.isStore <= `DISABLE;
      nextStage.isLoad <= `DISABLE;
      nextStage.isLoadUnsigned <= `DISABLE;
    end
    else begin
      nextStage.pc <= prev.nextStage.pc;
      nextStage.aluResult <= aluResult;
      nextStage.wData <= bypassedRs2;
      nextStage.memAccessWidth <= memAccessWidth;
      nextStage.rdCtrl <= prev.nextStage.rdCtrl;
      nextStage.isStore <= prev.nextStage.isStore;
      nextStage.isLoad <= prev.nextStage.isLoad;
      nextStage.isLoadUnsigned <= isLoadUnsigned;
    end
  end

  exec_switcher exec_switcher(
    .pc(prev.nextStage.pc),
    .rs1(bypassedRs1),
    .rs2(bypassedRs2),
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
