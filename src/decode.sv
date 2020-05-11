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
  input var [31:0]pc_WB
);
  
  RegAddr rs1Addr; //rs1アドレス
  RegAddr rs2Addr; //rs2アドレス
  RegAddr rdAddr; //rdアドレス
  BasicData imm; //即値
  ALUCtrl aluCtrl;
  logic reg_w_enable; //書き込みの有無
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
    .isLoad(isLoad), //ロード命令かどうか
    .isStore(isStore), //ストア命令かどうか
    .isHalt(isHalt) //haltかどうか
  );

  assign registerFile.rs1Addr = rs1Addr;
  assign registerFile.rs2Addr = rs2Addr;

  always_ff@(negedge port.clk) begin
    if (port.rst == 1'b0 || dataHazard.isDataHazard == `ENABLE) begin
      nextStage.pc <= `NOP;
      nextStage.rs1Data <= `NOP;
      nextStage.rs2Data <= `NOP;
      nextStage.imm <= `NOP;
      nextStage.rdCtrl <= {`DISABLE,`NOP};
      nextStage.aluCtrl <= {ALU_NOP,OP_TYPE_NONE,OP_TYPE_NONE};
      nextStage.isStore <= `DISABLE;
      nextStage.isLoad <= `DISABLE;
      nextStage.isHalt <= `DISABLE;
    end

    else begin
      nextStage.pc <= prev.nextStage.pc;
      nextStage.rs1Data <= registerFile.rs1Data;
      nextStage.rs2Data <= registerFile.rs2Data;
      nextStage.imm <= imm;
      nextStage.rdCtrl <= {reg_w_enable,rdAddr};
      nextStage.aluCtrl <= aluCtrl;
      nextStage.isStore <= isStore;
      nextStage.isLoad <= isLoad;
      nextStage.isHalt <= isHalt;
    end
  end
endmodule
