`timescale 1ns / 1ps

import BasicTypes::*;
import PipelineTypes::*;

module memory_access(
  MemoryAccessStageIF.ThisStage port,
  ExecuteStageIF.NextStage prev,
  BypassNetworkIF.MemoryAccessStage bypassNetwork,
  DebugIF.MemoryAccessStage debug,
  output var [7:0]uart,
  output var logic uart_we
);

  logic [31:0]line;
  logic [1:0]offset;
  logic [3:0]mem_w_enable;
  logic [31:0]shifted_w_data;

  logic [31:0]row_r_data;
  logic [31:0]r_data;
  logic hc_access;

  assign port.rdCtrl = prev.nextStage.rdCtrl;
  assign bypassNetwork.MemwData = nextStage.alu_result;

  WriteBackStagePipeReg nextStage;
  assign port.nextStage = nextStage;

  assign debug.memoryAccessStage = prev.nextStage;

  assign hc_access = (prev.nextStage.aluResult == `HARDWARE_COUNTER_ADDR && prev.nextStage.isLoad) ? `ENABLE : `DISABLE;
  assign r_data = r_data_gen(row_r_data,prev.nextStage.memAccessWidth,prev.nextStage.isLoadUnsigned,offset,hc_access,hc_OUT_data);

  bram bram(
    .pc(prev.nextStage.pc),
    .clk(port.clk),
    .w_enable(mem_w_enable),
    .r_addr(line),
    .w_addr(line),
    .w_data(shifted_w_data),
    .row_addr(prev.nextStage.aluResult),
    .r_data(row_r_data)
  );

  always_comb begin
    if (port.rst == 1'b0) begin
      port.isBranch = `DISABLE;
      port.branchTaken = `DISABLE;
      port.isBranchTakenPredicted = `DISABLE;
      port.isNextPcPredicted = `DISABLE;
      port.predictedNextPC = 32'd0;
      port.irregPc = 32'd0;
      port.pc = 32'd0;
    end
    else begin
      port.isBranch = prev.nextStage.isBranch;
      port.branchTaken = prev.nextStage.branchTaken;
      port.isBranchTakenPredicted = prev.nextStage.isBranchTakenPredicted;
      port.isNextPcPredicted = prev.nextStage.isNextPcPredicted;
      port.predictedNextPC = prev.nextStage.predictedNextPC;
      port.irregPc = prev.nextStage.irregPc;
      port.pc = prev.nextStage.pc;
    end
  end

  always_ff@(negedge port.clk) begin
    nextStage.pc <= prev.nextStage.pc;
    nextStage.r_data <= r_data;
    nextStage.alu_result <= prev.nextStage.aluResult;
    nextStage.is_load <= prev.nextStage.isLoad;
    nextStage.rdCtrl <= prev.nextStage.rdCtrl;
  end

  memory_ctl memory_ctl(
    .pc(prev.nextStage.pc),
    .clk(port.clk),
    .is_store(prev.nextStage.isStore),
    .is_load_unsigned(prev.nextStage.isLoadUnsigned),
    .addr(prev.nextStage.aluResult),
    .mem_access_width(prev.nextStage.memAccessWidth),
    .w_data(prev.nextStage.wData),
    .w_enable(mem_w_enable),
    .line(line),
    .offset(offset),
    .shifted_w_data(shifted_w_data),
    .uart(uart),
    .uart_we(uart_we)
  );

  //ハードウェアカウンタ
  logic [31:0]hc_OUT_data;

  hardware_counter hardware_counter(
      .CLK_IP(port.clk),
      .RSTN_IP(port.rst),
      .COUNTER_OP(hc_OUT_data)
  );


  function automatic [31:0] r_data_gen;
    input [31:0] row_r_data;
    input [1:0] mem_access_width;
    input is_load_unsigned;
    input [1:0] offset;
    input bit hc_access;
    input [31:0] hc_OUT_data;

    begin
      if (hc_access == `ENABLE && prev.nextStage.isLoad) begin
        r_data_gen = hc_OUT_data;
      end
      else begin
        case (mem_access_width)
          `MEM_BYTE: begin
            r_data_gen = is_load_unsigned 
              ? ({32{1'b0}}) | ((row_r_data >> (offset * 8)) & 8'hff)
              : ({32{row_r_data[(offset+1) * 8 - 1]}} << 8) | ((row_r_data >> (offset * 8)) & 8'hff)
              ;
          end
          `MEM_HALF: begin
            r_data_gen = is_load_unsigned 
              ? ({32{1'b0}}) | ((row_r_data >> (offset * 8)) & 16'hffff)
              : ({32{row_r_data[(offset + 2) * 8  -1]}} << 16) | ((row_r_data >> (offset * 8)) & 16'hffff)
              ;
          end
          `MEM_WORD: begin
            r_data_gen = row_r_data;
          end
          default: begin
            r_data_gen = row_r_data;
          end
        endcase
      end
    end
  endfunction
endmodule
