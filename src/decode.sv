`timescale 1ns / 1ps
`include "define.svh"

import BasicTypes::*;
import PipelineTypes::*;

//Dステージと、WBステージで使用。
module decode(
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
  ALUCtrl aluCtrl;
  logic reg_w_enable; //書き込みの有無
  logic isForwardable;
  logic isLoad; //ロード命令かどうか
  logic isStore; //ストア命令かどうか
  logic isHalt; //haltかどうか

  ExecuteStagePipeReg nextStage;
  assign port.nextStage = nextStage;

  assign port.rs1Addr = rs1Addr;
  assign port.rs2Addr = rs2Addr;
  assign port.aluOp1Type = aluCtrl.aluOp1Type;
  assign port.aluOp2Type = aluCtrl.aluOp2Type;
  assign port.isStore = isStore;
  
  assign debug.decodeStage = prev.nextStage;

  //クロック同期ではなく、入力によってデコード結果を垂れ流すだけ。意味付けは
  //decodeで行う。
  decoder decoder(
    //input
    .inst_b(prev.nextStage.inst), //命令ビット列
    //output
    .rs1Addr(rs1Addr), //rs1のアドレス
    .rs2Addr(rs2Addr), //rs2のアドレス
    .rdAddr(rdAddr), //rdのアドレス
    .imm(imm), //即値
    .aluCtrl(aluCtrl),
    .wEnable(reg_w_enable), //書き込みの有無
    .isForwardable(isForwardable),
    .isLoad(isLoad), //ロード命令かどうか
    .isStore(isStore), //ストア命令かどうか
    .isHalt(isHalt) //haltかどうか
  );

  assign registerFile.rs1Addr = rs1Addr;
  assign registerFile.rs2Addr = rs2Addr;

  always_ff@(negedge port.clk) begin
    if (port.rst == 1'b0 || dataHazard.isDataHazard == `ENABLE || controller.isBranchPredictMiss) begin
      nextStage.pc <= `NOP;
      nextStage.rs1Data <= `NOP;
      nextStage.rs2Data <= `NOP;
      nextStage.op1BypassCtrl <= BYPASS_NONE;
      nextStage.op2BypassCtrl <= BYPASS_NONE;
      nextStage.imm <= `NOP;
      nextStage.rdCtrl <= {`DISABLE,`NOP};
      nextStage.aluCtrl <= {ALU_NOP,OP_TYPE_NONE,OP_TYPE_NONE,`DISABLE};
      nextStage.isBranchTakenPredicted <= `DISABLE;
      nextStage.isStore <= `DISABLE;
      nextStage.isLoad <= `DISABLE;
      nextStage.isHalt <= `DISABLE;
    end

    else begin
      nextStage.pc <= prev.nextStage.pc;
      nextStage.rs1Data <= registerFile.rs1Data;
      nextStage.rs2Data <= registerFile.rs2Data;
      nextStage.op1BypassCtrl <= controller.op1BypassCtrl;
      nextStage.op2BypassCtrl <= controller.op2BypassCtrl;
      nextStage.imm <= imm;
      nextStage.rdCtrl <= {reg_w_enable,rdAddr,isForwardable};
      nextStage.aluCtrl <= aluCtrl;
      nextStage.isBranchTakenPredicted <= prev.nextStage.isBranchTakenPredicted;
      nextStage.isStore <= isStore;
      nextStage.isLoad <= isLoad;
      nextStage.isHalt <= isHalt;
    end
  end
endmodule
