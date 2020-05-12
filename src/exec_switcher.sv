`timescale 1ns / 1ps
`include "define.svh"

import BasicTypes::*;
import PipelineTypes::*;

//デコードしたデータをもとにalu,irreg_pc_genに渡す形にする
module exec_switcher(
  input var [31:0]pc,
  input var [31:0]rs1,
  input var [31:0]rs2,
  input var BasicData bypassExData,
  input var BasicData bypassMemData,
  input var BypassCtrl op1BypassCtrl,
  input var BypassCtrl op2BypassCtrl,
  input var [31:0]imm,
  input var ALUCtrl aluCtrl,
  output var [31:0]alu_op1,
  output var [31:0]alu_op2,
  output var [31:0]npc_op1,
  output var [31:0]npc_op2
);

  BasicData bypassedRs1;
  BasicData bypassedRs2;

  always_comb begin
    case (op1BypassCtrl)
      BYPASS_NONE: begin
        bypassedRs1 = rs1;
      end
      BYPASS_EXEC: begin
        bypassedRs1 = bypassExData;
      end
      BYPASS_MEM: begin
        bypassedRs1 = bypassMemData;
      end
    endcase

    case (op2BypassCtrl)
      BYPASS_NONE: begin
        bypassedRs2 = rs2;
      end
      BYPASS_EXEC: begin
        bypassedRs2 = bypassExData;
      end
      BYPASS_MEM: begin
        bypassedRs2 = bypassMemData;
      end
    endcase
  end

  assign alu_op1 = (aluCtrl.aluOp1Type == OP_TYPE_REG) ? bypassedRs1 : (aluCtrl.aluOp1Type == OP_TYPE_IMM) ? imm : (aluCtrl.aluOp1Type == OP_TYPE_PC) ? pc :  32'd0;
  assign alu_op2 = (aluCtrl.aluOp2Type == OP_TYPE_REG) ? bypassedRs2 : (aluCtrl.aluOp2Type == OP_TYPE_IMM) ? imm : (aluCtrl.aluOp2Type == OP_TYPE_PC) ? pc :  32'd0;

  always_comb begin
    case (aluCtrl.aluCode)
      ALU_JAL: begin
        npc_op1 <= pc;
        npc_op2 <= imm;
      end

      ALU_JALR: begin
        npc_op1 <= rs1;
        npc_op2 <= imm;
      end

      ALU_BEQ: begin
        npc_op1 <= pc;
        npc_op2 <= imm;
      end

      ALU_BNE: begin
        npc_op1 <= pc;
        npc_op2 <= imm;
      end

      ALU_BLT: begin
        npc_op1 <= pc;
        npc_op2 <= imm;
      end

      ALU_BGE: begin
        npc_op1 <= pc;
        npc_op2 <= imm;
      end

      ALU_BLTU: begin
        npc_op1 <= pc;
        npc_op2 <= imm;
      end

      ALU_BGEU: begin
        npc_op1 <= pc;
        npc_op2 <= imm;
      end
      
      default : begin
        npc_op1 <= pc;
        npc_op2 <= 32'd4;
      end
    endcase
  end

endmodule
