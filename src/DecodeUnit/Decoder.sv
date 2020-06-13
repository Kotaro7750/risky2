`timescale 1ns / 1ps
`include "../define.svh"

import BasicTypes::*;
import PipelineTypes::*;
import OpTypes::*;
import DecoderFunc::*;

module Decoder(
  input var Instruction inst_b,
  output var RegAddr rs1Addr,
  output var RegAddr rs2Addr,
  output var RegAddr rdAddr,
  output var BasicData imm,
  output var OpInfo opInfo
);

  //OpCode opCode;
  logic [6:0] opCode;
  Funct3 funct3;
  Funct7 funct7;

  assign opCode = inst_b[6:0];
  assign funct3 = inst_b[14:12];
  assign funct7 = inst_b[31:25];

  //これ以降はreg用
  always_comb begin
    unique case (opCode)
      //ADDi ~ SRAi
      RISCV_OP_IMM: begin
        rs1Addr = inst_b[19:15];
        rs2Addr = 0;
        rdAddr = inst_b[11:7];

        DecodeI(opInfo,imm,inst_b,rdAddr,funct3,funct7);
      end

      //ADD ~ AND
      RISCV_OP: begin
        rs1Addr = inst_b[19:15];
        rs2Addr = inst_b[24:20];
        rdAddr = inst_b[11:7];

        DecodeR(opInfo,imm,rdAddr,funct3,funct7);
      end

    //LUi
    RISCV_LUI,RISCV_AUIPC: begin
        rs1Addr = 0;
        rs2Addr = 0;
        rdAddr = inst_b[11:7];

        DecodeU(opInfo,imm,inst_b,rdAddr,opCode);
    end

    //JAL
    RISCV_JAL: begin
        rs1Addr = 0;
        rs2Addr = 0;
        rdAddr = inst_b[11:7];

        DecodeJ(opInfo,imm,inst_b,rdAddr);
    end

    //JALR
    RISCV_JALR: begin
        rs1Addr = inst_b[19:15];
        rs2Addr = 0;
        rdAddr = inst_b[11:7];

        DecodeJALR(opInfo,imm,inst_b,rdAddr);
    end

    //Beq ~ Bgeu
    RISCV_BR:begin
        rs1Addr = inst_b[19:15];
        rs2Addr = inst_b[24:20];
        rdAddr = `REG_NONE;

        DecodeB(opInfo,imm,inst_b,funct3);
    end

    //Sb ~ Sw
    RISCV_ST: begin
        rs1Addr = inst_b[19:15];
        rs2Addr = inst_b[24:20];
        rdAddr = `REG_NONE;

        DecodeST(opInfo,imm,inst_b,funct3);
    end

    //Lb ~ Lhu
    RISCV_LD: begin
        rs1Addr = inst_b[19:15];
        rs2Addr = 0;
        rdAddr = inst_b[11:7];

        DecodeLD(opInfo,imm,inst_b,rdAddr,funct3);
    end

    default: begin
      rs1Addr = `REG_NONE;
      rs2Addr = `REG_NONE;
      rdAddr = `REG_NONE;
      imm = 32'd0;
      opInfo.aluCtrl.aluCode = ALU_NONE;
      opInfo.aluCtrl.aluOp1Type = OP_TYPE_NONE;
      opInfo.aluCtrl.aluOp2Type = OP_TYPE_NONE;
      opInfo.isMulDiv = `DISABLE;
      opInfo.mulDivCode = MULDIV_MUL;
      opInfo.brCtrl = BR_NONE;
      opInfo.wEnable = `DISABLE;
      opInfo.isForwardable = `DISABLE;
      opInfo.memAccessWidth = MEM_NONE;
      opInfo.isBranch = `DISABLE;
      opInfo.isLoad = `DISABLE;
      opInfo.isStore = `DISABLE;
      opInfo.isBubble = `ENABLE;
    end
    endcase
  end
endmodule
