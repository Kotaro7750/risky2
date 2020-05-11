`timescale 1ns / 1ps

import BasicTypes::*;
import PipelineTypes::*;

module execute(
  ExecuteStageIF.ThisStage port,
  DecodeStageIF.NextStage prev
);

  logic [31:0]alu_op1;
  logic [31:0]alu_op2;
  logic [31:0]npc_op1;
  logic [31:0]npc_op2;
  logic [31:0]alu_result;
  logic [1:0]mem_access_width;
  logic [31:0]irreg_pc;
  logic is_branch;
  logic br_taken;

  MemoryAccessStagePipeReg nextStage;
  assign port.nextStage = nextStage;

  always_ff@(negedge port.clk) begin
    if (port.rst == 1'b0) begin
      nextStage.pc <= 32'd0;
      nextStage.alu_result <= 32'd0;
      nextStage.w_data <= 32'd0;
      nextStage.mem_access_width <= 2'd0;
      nextStage.rd_addr <= 5'd0;
      nextStage.w_enable <= `DISABLE;
      nextStage.is_store <= `DISABLE;
      nextStage.is_load <= `DISABLE;
      nextStage.is_load_unsigned <= `DISABLE;
      port.irregPc <= 32'd0;
    end
    else begin
      nextStage.pc <= prev.nextStage.pc;
      nextStage.alu_result <= alu_result;
      nextStage.w_data <= prev.nextStage.rs2_data;
      nextStage.mem_access_width <= mem_access_width;
      nextStage.rd_addr <= prev.nextStage.rd_addr;
      nextStage.w_enable <= prev.nextStage.w_enable;
      nextStage.is_store <= prev.nextStage.is_store;
      nextStage.is_load <= prev.nextStage.is_load;
      nextStage.is_load_unsigned <= is_load_unsigned;
      port.irregPc <= irreg_pc;
    end
  end

  exec_switcher exec_switcher(
    .pc(prev.nextStage.pc),
    .rs1(prev.nextStage.rs1_data),
    .rs2(prev.nextStage.rs2_data),
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
    .alu_result(alu_result),
    .is_branch(is_branch),
    .br_taken(br_taken),
    .mem_access_width(mem_access_width),
    .is_load_unsigned(is_load_unsigned)
  );

  irreg_pc_gen irreg_pc_gen(
    .op1(npc_op1),
    .op2(npc_op2),
    .br_taken(br_taken),
    .is_branch(is_branch),
    .irreg_pc(irreg_pc)
  );

endmodule
