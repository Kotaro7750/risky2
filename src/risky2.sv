`timescale 1ns / 1ps

`include "define.svh"
module risky2(input var logic sysclk,input var logic cpu_resetn,output var logic uart_tx);
  logic clk;

  assign clk = sysclk;

  logic rst;

  assign rst = cpu_resetn;

  FetchStageIF fetchStageIF(clk,rst);

  DecodeStageIF decodeStageIF(clk,rst);

  ExecuteStageIF executeStageIF(clk,rst);

  MemoryAccessStageIF memoryAccessStageIF(clk,rst);

  WriteBackStageIF writeBackStageIF(clk,rst);

  RegisterFileIF registerFileIF(clk,rst);

  ControllerIF controllerIF(clk,rst);

  //WD
  logic [31:0]WD_pc;
  logic [31:0]WD_irreg_pc;

  //pc関係
  logic [31:0] pc;
  logic [31:0] npc;

  //uart
  logic [7:0] uart_IN_data;
  logic uart_we;
  logic uart_OUT_data;

  assign uart_tx = uart_OUT_data;

  uart uart0(
      .uart_tx(uart_OUT_data),
      .uart_wr_i(uart_we),
      .uart_dat_i(uart_IN_data),
      .sys_clk_i(clk),
      .sys_rstn_i(rst)
  );

  RegisterFile RegisterFile(
    .port(registerFileIF),
    .pc(WD_pc)
  );

  Controller Controller(
    .port(controllerIF),
    .decode(decodeStageIF),
    .execute(executeStageIF)
  );


  fetch fetch(
    .port(fetchStageIF),
    .dataHazard(controllerIF),
    .irregularPC(executeStageIF)
  );
  
  decode decode(
    .port(decodeStageIF),
    .prev(fetchStageIF),
    .registerFile(registerFileIF),
    .dataHazard(controllerIF),
    .pc_WB(WD_pc)
  );

  execute execute(
    .port(executeStageIF),
    .prev(decodeStageIF)
  );

  memory_access memory_access(
    .port(memoryAccessStageIF),
    .prev(executeStageIF),
    .uart(uart_IN_data),
    .uart_we(uart_we)
  );

  writeback writeback(
    .port(writeBackStageIF),
    .prev(memoryAccessStageIF),
    .WD_pc(WD_pc),
    .WD_irreg_pc(WD_irreg_pc),
    .registerFile(registerFileIF)
  );
endmodule
