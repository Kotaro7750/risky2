`timescale 1ns / 1ps
`include "define.svh"

import BasicTypes::*;
import PipelineTypes::*;

module alu(
  input var [5:0]alucode, //演算種別
  input var BasicData op1, //第一オペランド
  input var BasicData op2, //第二オペランド
  output var [31:0]aluResult, //計算結果
  output var bit isBranch,
  output var brTaken, //条件分岐するか
  output var [1:0]memAccessWidth, //メモリアクセス幅
  output var isLoadUnsigned //unsignedでloadするか
);
  logic signed [31:0] op1_signed;
  logic signed [31:0] op2_signed;

  assign op1_signed = $signed(op1);
  assign op2_signed = $signed(op2);

  always_comb begin
    case (alucode)
      ALU_LUI: begin
        aluResult = op2;
        isBranch = `DISABLE;
        brTaken = `DISABLE;
        memAccessWidth = `MEM_NONE;
        isLoadUnsigned = `DISABLE;
      end

      ALU_JAL: begin
        aluResult = op2 + 4;
        isBranch = `ENABLE;
        brTaken = `ENABLE;
        memAccessWidth = `MEM_NONE;
        isLoadUnsigned = `DISABLE;
      end

      ALU_JALR: begin
        aluResult = op2 + 4;
        isBranch = `ENABLE;
        brTaken = `ENABLE;
        memAccessWidth = `MEM_NONE;
        isLoadUnsigned = `DISABLE;
      end

      ALU_BEQ: begin
        aluResult = 0;
        isBranch = `ENABLE;
        brTaken = (op1 == op2) ? `ENABLE : `DISABLE;
        memAccessWidth = `MEM_NONE;
        isLoadUnsigned = `DISABLE;
      end

      ALU_BNE: begin
        aluResult = 0;
        isBranch = `ENABLE;
        brTaken = op1 != op2 ? `ENABLE : `DISABLE;
        memAccessWidth = `MEM_NONE;
        isLoadUnsigned = `DISABLE;
      end

      ALU_BLT: begin
        aluResult = 0;
        isBranch = `ENABLE;
        if ((op1 - op2) & (32'b1 << 31)) begin
          brTaken = `ENABLE;
        end
        else begin
          brTaken = `DISABLE;
        end
        memAccessWidth = `MEM_NONE;
        isLoadUnsigned = `DISABLE;
      end

      ALU_BGE: begin
        aluResult = 0;
        isBranch = `ENABLE;
        if ( ((op2 - op1) & (32'b1 << 31)) || (op1 == op2)) begin
          brTaken = `ENABLE;
        end
        else begin
          brTaken = `DISABLE;
        end
        memAccessWidth = `MEM_NONE;
        isLoadUnsigned = `DISABLE;
      end

      ALU_BLTU: begin
        aluResult = 0;
        isBranch = `ENABLE;
        brTaken = op1 < op2 ? `ENABLE : `DISABLE;
        memAccessWidth = `MEM_NONE;
        isLoadUnsigned = `DISABLE;
      end

      ALU_BGEU: begin
        aluResult = 0;
        isBranch = `ENABLE;
        brTaken = op1 >= op2 ? `ENABLE : `DISABLE;
        memAccessWidth = `MEM_NONE;
        isLoadUnsigned = `DISABLE;
      end

      ALU_LB: begin
        aluResult = op1 + op2;
        isBranch = `DISABLE;
        brTaken = `DISABLE;
        memAccessWidth = `MEM_BYTE;
        isLoadUnsigned = `DISABLE;
      end

      ALU_LH: begin
        aluResult = op1 + op2;
        isBranch = `DISABLE;
        brTaken = `DISABLE;
        memAccessWidth = `MEM_HALF;
        isLoadUnsigned = `DISABLE;
      end

      ALU_LW: begin
        aluResult = op1 + op2;
        isBranch = `DISABLE;
        brTaken = `DISABLE;
        memAccessWidth = `MEM_WORD;
        isLoadUnsigned = `DISABLE;
      end

      ALU_LBU: begin
        aluResult = op1 + op2;
        isBranch = `DISABLE;
        brTaken = `DISABLE;
        memAccessWidth = `MEM_BYTE;
        isLoadUnsigned = `ENABLE;
      end

      ALU_LHU: begin
        aluResult = op1 + op2;
        isBranch = `DISABLE;
        brTaken = `DISABLE;
        memAccessWidth = `MEM_HALF;
        isLoadUnsigned = `ENABLE;
      end

      ALU_SB: begin
        aluResult = op1 + op2;
        isBranch = `DISABLE;
        brTaken = `DISABLE;
        memAccessWidth = `MEM_BYTE;
        isLoadUnsigned = `DISABLE;
      end

      ALU_SH: begin
        aluResult = op1 + op2;
        isBranch = `DISABLE;
        brTaken = `DISABLE;
        memAccessWidth = `MEM_HALF;
        isLoadUnsigned = `DISABLE;
      end

      ALU_SW: begin
        aluResult = op1 + op2;
        isBranch = `DISABLE;
        brTaken = `DISABLE;
        memAccessWidth = `MEM_WORD;
        isLoadUnsigned = `DISABLE;
      end

      ALU_ADD: begin
        aluResult = (op1 + op2) & 32'hffffffff;
        isBranch = `DISABLE;
        brTaken = `DISABLE;
        memAccessWidth = `MEM_NONE;
        isLoadUnsigned = `DISABLE;
      end

      ALU_SUB: begin
        aluResult = op1 - op2;
        isBranch = `DISABLE;
        brTaken = `DISABLE;
        memAccessWidth = `MEM_NONE;
        isLoadUnsigned = `DISABLE;
      end

      ALU_SLT: begin
        if ((op1 - op2) & (32'b1 << 31)) begin
          aluResult = 1;
        end
        else begin
          aluResult = 0;
        end
        isBranch = `DISABLE;
        brTaken = `DISABLE;
        memAccessWidth = `MEM_NONE;
        isLoadUnsigned = `DISABLE;
      end

      ALU_SLTU: begin
        aluResult = op1 < op2 ? 1 : 0;;
        isBranch = `DISABLE;
        brTaken = `DISABLE;
        memAccessWidth = `MEM_NONE;
        isLoadUnsigned = `DISABLE;
      end

      ALU_XOR: begin
        aluResult = op1 ^ op2;
        isBranch = `DISABLE;
        brTaken = `DISABLE;
        memAccessWidth = `MEM_NONE;
        isLoadUnsigned = `DISABLE;
      end

      ALU_OR: begin
        aluResult = op1 | op2;
        isBranch = `DISABLE;
        brTaken = `DISABLE;
        memAccessWidth = `MEM_NONE;
        isLoadUnsigned = `DISABLE;
      end

      ALU_AND: begin
        aluResult = op1 & op2;
        isBranch = `DISABLE;
        brTaken = `DISABLE;
        memAccessWidth = `MEM_NONE;
        isLoadUnsigned = `DISABLE;
      end

      ALU_SLL: begin
        aluResult = op1 << (op2 & 5'b11111);
        isBranch = `DISABLE;
        brTaken = `DISABLE;
        memAccessWidth = `MEM_NONE;
        isLoadUnsigned = `DISABLE;
      end

      ALU_SRL: begin
        aluResult = op1 >> (op2 & 5'b11111);
        isBranch = `DISABLE;
        brTaken = `DISABLE;
        memAccessWidth = `MEM_NONE;
        isLoadUnsigned = `DISABLE;
      end

      ALU_SRA: begin
        aluResult = $signed(op1) >>> ($signed(op2) & 5'b11111);
        isBranch = `DISABLE;
        brTaken = `DISABLE;
        memAccessWidth = `MEM_NONE;
        isLoadUnsigned = `DISABLE;
      end

      ALU_NOP: begin
        aluResult = 32'd0;
        isBranch = `DISABLE;
        brTaken = `DISABLE;
        memAccessWidth = `MEM_NONE;
        isLoadUnsigned = `DISABLE;
      end

      default: begin
        aluResult = 32'd0;
        isBranch = `DISABLE;
        brTaken = `DISABLE;
        memAccessWidth = `MEM_NONE;
        isLoadUnsigned = `DISABLE;
      end
    endcase
    
  end
endmodule
