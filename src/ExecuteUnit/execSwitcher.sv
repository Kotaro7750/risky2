//`timescale 1ns / 1ps
`include "../define.svh"

import BasicTypes::*;
import PipelineTypes::*;

module execSwitcher(
  input var [31:0]pc,
  input var [31:0]rs1,
  input var [31:0]rs2,
  input var [31:0]imm,
  input var ALUCtrl aluCtrl,
  input var OpType opType,
  output var [31:0]alu_op1,
  output var [31:0]alu_op2,
  output var [31:0]npc_op1,
  output var [31:0]npc_op2
);

  assign alu_op1 = (aluCtrl.aluOp1Type == OP_TYPE_REG) ? rs1 : (aluCtrl.aluOp1Type == OP_TYPE_IMM) ? imm : (aluCtrl.aluOp1Type == OP_TYPE_PC) ? pc :  32'd0;
  assign alu_op2 = (aluCtrl.aluOp2Type == OP_TYPE_REG) ? rs2 : (aluCtrl.aluOp2Type == OP_TYPE_IMM) ? imm : (aluCtrl.aluOp2Type == OP_TYPE_PC) ? pc :  32'd0;

  always_comb begin
    unique case (opType)
      TYPE_B,TYPE_J: begin
        npc_op1 = pc;
        npc_op2 = imm;
      end
      TYPE_JALR: begin
        npc_op1 = rs1;
        npc_op2 = imm;
      end
      default : begin
        npc_op1 = pc;
        npc_op2 = 32'd4;
      end
    endcase
  end
endmodule
