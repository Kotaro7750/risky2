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
  
  RegAddr rs1_addr; //rs1アドレス
  RegAddr rs2_addr; //rs2アドレス
  RegAddr rd_addr; //rdアドレス
  BasicData imm; //即値
  ALUCtrl aluCtrl;
  logic reg_w_enable; //書き込みの有無
  logic is_load; //ロード命令かどうか
  logic is_store; //ストア命令かどうか
  logic is_halt; //haltかどうか

  ExecuteStagePipeReg nextStage;
  assign port.nextStage = nextStage;

  assign port.aluOp1Type = aluCtrl.aluOp1Type;
  assign port.aluOp2Type = aluCtrl.aluOp2Type;
  assign port.isStore = is_store;
  

  //クロック同期ではなく、入力によってデコード結果を垂れ流すだけ。意味付けは
  //decodeで行う。
  decoder decoder(
    //input
    .inst_b(prev.nextStage.inst), //命令ビット列
    //output
    .src1_reg(rs1_addr), //rs1のアドレス
    .src2_reg(rs2_addr), //rs2のアドレス
    .dst_reg(rd_addr), //rdのアドレス
    .imm(imm), //即値
    .aluCtrl(aluCtrl),
    .reg_w_enable(reg_w_enable), //書き込みの有無
    .is_load(is_load), //ロード命令かどうか
    .is_store(is_store), //ストア命令かどうか
    .is_halt(is_halt) //haltかどうか
  );

  assign registerFile.rs1Addr = rs1_addr;
  assign registerFile.rs2Addr = rs2_addr;
  assign registerFile.prevRdAddr = nextStage.rdCtrl.rdAddr;
  assign registerFile.prevWEnable = nextStage.rdCtrl.wEnable;

  always_ff@(negedge port.clk) begin
    if (port.rst == 1'b0 || dataHazard.isDataHazard == `ENABLE) begin
      nextStage.pc <= `NOP;
      nextStage.rs1_data <= `NOP;
      nextStage.rs2_data <= `NOP;
      nextStage.imm <= `NOP;
      nextStage.rdCtrl <= {`DISABLE,`NOP};
      nextStage.aluCtrl <= {ALU_NOP,OP_TYPE_NONE,OP_TYPE_NONE};
      nextStage.is_store <= `DISABLE;
      nextStage.is_load <= `DISABLE;
      nextStage.is_halt <= `DISABLE;
    end

    else begin
      nextStage.pc <= prev.nextStage.pc;
      nextStage.rs1_data <= registerFile.rs1Data;
      nextStage.rs2_data <= registerFile.rs2Data;
      nextStage.imm <= imm;
      nextStage.rdCtrl <= {reg_w_enable,rd_addr};
      nextStage.aluCtrl <= aluCtrl;
      nextStage.is_store <= is_store;
      nextStage.is_load <= is_load;
      nextStage.is_halt <= is_halt;
    end
  end
endmodule
