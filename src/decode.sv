`timescale 1ns / 1ps
`include "define.svh"

import BasicTypes::*;
import PipelineTypes::*;

//Dステージと、WBステージで使用。
module decode(
  DecodeStageIF.ThisStage port,
  FetchStageIF.NextStage prev,
  RegisterFileIF.DecodeStage writeBack,
  input var [31:0]pc_WB
);
  
  RegAddr rs1_addr; //rs1アドレス
  RegAddr rs2_addr; //rs2アドレス
  RegAddr rd_addr; //rdアドレス
  BasicData imm; //即値
  logic [5:0]alu_code; //aluコード
  logic [1:0]alu_op1_type; //オペランド1タイプ
  logic [1:0]alu_op2_type; //オペランド2タイプ
  logic reg_w_enable; //書き込みの有無
  logic is_load; //ロード命令かどうか
  logic is_store; //ストア命令かどうか
  logic is_halt; //haltかどうか
  logic rs1_ready; //rs1が使用可能か
  logic rs2_ready; //rs2が使用可能か

  BasicData rs1_data; //rs1のデータ
  BasicData rs2_data; //rs2のデータ

  ExecuteStagePipeReg nextStage;
  assign port.nextStage = nextStage;

  //rs1またはrs2について、命令がレジスタを使用し、かつreadyがdisableならハザー
  //ド
  assign port.isDataHazard = is_data_hazard_gen(rs1_ready,rs2_ready,alu_op1_type,alu_op2_type,is_store);

  function bit is_data_hazard_gen;
    input bit rs1_ready;
    input bit rs2_ready;
    input [1:0]alu_op1_type;
    input [1:0]alu_op2_type;
    input bit is_store;
  begin
    if (is_store == `ENABLE) begin
      is_data_hazard_gen = ((rs1_ready == `DISABLE && alu_op1_type == `OP_TYPE_REG) || (rs2_ready == `DISABLE)) ? `ENABLE : `DISABLE;
    end
    else begin
      is_data_hazard_gen = ((rs1_ready == `DISABLE && alu_op1_type == `OP_TYPE_REG) || (rs2_ready == `DISABLE && alu_op2_type == `OP_TYPE_REG)) ? `ENABLE : `DISABLE; 
    end
  end
endfunction
  

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
    .alu_code(alu_code), //aluコード
    .alu_op1_type(alu_op1_type), //オペランド1のタイプ
    .alu_op2_type(alu_op2_type), //オペランド2のタイプ
    .reg_w_enable(reg_w_enable), //書き込みの有無
    .is_load(is_load), //ロード命令かどうか
    .is_store(is_store), //ストア命令かどうか
    .is_halt(is_halt) //haltかどうか
  );

  register register(
    //input
    .pc_WB(pc_WB),
    .clk(port.clk),
    .rstd(port.rst),
    .rs1_addr(rs1_addr),
    .rs2_addr(rs2_addr),
    //.wb_enable(w_enable_WB),
    //.wb_addr(w_addr_WB),
    //.wb_data(w_data_WB),
    .wb_enable(writeBack.wEnable),
    .wb_addr(writeBack.rdAddr),
    .wb_data(writeBack.wData),
    .prev_w_enable(nextStage.w_enable),
    .prev_rd_addr(nextStage.rd_addr),
    //output
    .rs1_data(rs1_data),
    .rs2_data(rs2_data),
    .rs1_ready(rs1_ready),
    .rs2_ready(rs2_ready)
  );

  always_ff@(negedge port.clk) begin
    if (port.rst == 1'b0) begin
      nextStage.pc <= `NOP;
      nextStage.rs1_data <= `NOP;
      nextStage.rs2_data <= `NOP;
      nextStage.imm <= `NOP;
      nextStage.rd_addr <= `NOP;
      nextStage.alu_code <= `ALU_NOP;
      nextStage.alu_op1_type <= `OP_TYPE_NONE;
      nextStage.alu_op2_type <= `OP_TYPE_NONE;
      nextStage.w_enable <= `DISABLE;
      nextStage.is_store <= `DISABLE;
      nextStage.is_load <= `DISABLE;
      nextStage.is_halt <= `DISABLE;
    end

    if (port.isDataHazard == `ENABLE) begin
      nextStage.pc <= `NOP;
      nextStage.rs1_data <= `NOP;
      nextStage.rs2_data <= `NOP;
      nextStage.imm <= `NOP;
      nextStage.rd_addr <= `NOP;
      nextStage.alu_code <= `ALU_NOP;
      nextStage.alu_op1_type <= `OP_TYPE_NONE;
      nextStage.alu_op2_type <= `OP_TYPE_NONE;
      nextStage.w_enable <= `DISABLE;
      nextStage.is_store <= `DISABLE;
      nextStage.is_load <= `DISABLE;
      nextStage.is_halt <= `DISABLE;
    end

    else begin
      nextStage.pc <= prev.nextStage.pc;
      nextStage.rs1_data <= rs1_data;
      nextStage.rs2_data <= rs2_data;
      nextStage.imm <= imm;
      nextStage.rd_addr <= rd_addr;
      nextStage.alu_code <= alu_code;
      nextStage.alu_op1_type <= alu_op1_type;
      nextStage.alu_op2_type <= alu_op2_type;
      nextStage.w_enable <= reg_w_enable;
      nextStage.is_store <= is_store;
      nextStage.is_load <= is_load;
      nextStage.is_halt <= is_halt;
    end
  end
endmodule
