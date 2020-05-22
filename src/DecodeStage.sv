`timescale 1ns / 1ps
`include "define.svh"

import BasicTypes::*;
import PipelineTypes::*;

//Dステージと、WBステージで使用。
module DecodeStage(
  DecodeStageIF.ThisStage port,
  FetchStageIF.NextStage prev,
  RegisterFileIF.DecodeStage registerFile,
  ControllerIF.DataHazard dataHazard,
  ControllerIF.DecodeStage controller,
  DebugIF.DecodeStage debug
);
  
  RegAddr rs1Addr; //rs1アドレス
  RegAddr rs2Addr; //rs2アドレス
  RegAddr rdAddr; //rdアドレス
  BasicData imm; //即値
  OpInfo opInfo;

  ModifiedExecuteStagePipeReg nextStage;
  assign port.nextStage = nextStage;

  assign port.rs1Addr = rs1Addr;
  assign port.rs2Addr = rs2Addr;
  assign port.aluOp1Type = opInfo.aluCtrl.aluOp1Type;
  assign port.aluOp2Type = opInfo.aluCtrl.aluOp2Type;
  assign port.isStore = opInfo.isStore;
  
  assign debug.decodeStage = prev.nextStage;

  Decoder Decoder(
    .inst_b(prev.nextStage.inst),
    .rs1Addr(rs1Addr),
    .rs2Addr(rs2Addr),
    .rdAddr(rdAddr),
    .imm(imm),
    .opInfo(opInfo)
  );

  assign registerFile.rs1Addr = rs1Addr;
  assign registerFile.rs2Addr = rs2Addr;

  always_ff@(negedge port.clk) begin
    if (port.rst == 1'b0 || dataHazard.isDataHazard == `ENABLE || controller.isBranchPredictMiss) begin
      nextStage.pc <= `NOP;
      nextStage.rs1Data <= `NOP;
      nextStage.rs2Data <= `NOP;
      nextStage.rdAddr <= `NOP;
      nextStage.op1BypassCtrl <= BYPASS_NONE;
      nextStage.op2BypassCtrl <= BYPASS_NONE;
      nextStage.imm <= `NOP;
      //nextStage.rdCtrl <= {`DISABLE,`NOP};
      //nextStage.aluCtrl <= {ALU_NONE,OP_TYPE_NONE,OP_TYPE_NONE,`DISABLE};
      nextStage.opInfo <= {$bits(OpInfo){1'b0}};
      nextStage.isBranchTakenPredicted <= `DISABLE;
      nextStage.isNextPcPredicted <= `DISABLE;
      nextStage.predictedNextPC <= `NOP;
    end

    else begin
      nextStage.pc <= prev.nextStage.pc;
      nextStage.rs1Data <= registerFile.rs1Data;
      nextStage.rs2Data <= registerFile.rs2Data;
      nextStage.rdAddr <= rdAddr;
      nextStage.op1BypassCtrl <= controller.op1BypassCtrl;
      nextStage.op2BypassCtrl <= controller.op2BypassCtrl;
      nextStage.imm <= imm;
      nextStage.opInfo <= opInfo;
      nextStage.isBranchTakenPredicted <= prev.nextStage.isBranchTakenPredicted;
      nextStage.isNextPcPredicted <= prev.nextStage.isNextPcPredicted;
      nextStage.predictedNextPC <= prev.nextStage.predictedNextPC;
    end
  end
endmodule
