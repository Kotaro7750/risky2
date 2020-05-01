`timescale 1ns / 1ps

`include "define.svh"
module risky2(input var logic sysclk,input var logic cpu_resetn,output var logic uart_tx);
  logic clk;

  assign clk = sysclk;

  logic rstd;

  assign rstd = cpu_resetn;

  //FD
  logic [31:0]FD_inst;
  logic [31:0]FD_pc;
  logic is_data_hazard;

  //DE
  logic [31:0]DE_pc;
  logic [31:0]DE_rs1_data;
  logic [31:0]DE_rs2_data;
  logic [31:0]DE_imm;
  logic [4:0]DE_rd_addr;
  logic [5:0]DE_alu_code;
  logic [1:0]DE_alu_op1_type;
  logic [1:0]DE_alu_op2_type;
  logic DE_w_enable;
  logic DE_is_store;
  logic DE_is_load;
  logic DE_is_halt;

  //EM
  logic [31:0]EM_pc;
  logic [31:0]EM_alu_result;
  logic [31:0]EM_w_data;
  logic [1:0]EM_mem_access_width;
  logic [4:0]EM_rd_addr;
  logic EM_w_enable;
  logic EM_is_store;
  logic EM_is_load;
  logic EM_is_load_unsigned;
  logic [31:0]EM_irreg_pc;

  //MW
  logic [31:0]MW_pc;
  logic [31:0]MW_irreg_pc;
  logic [31:0]MW_r_data;
  logic [31:0]MW_alu_result;
  logic MW_is_load;
  logic MW_w_enable;
  logic [4:0]MW_rd_addr;

  //PM
  logic [31:0]PM_pc;
  logic [31:0]PM_irreg_pc;
  logic [31:0]PM_alu_result;
  logic PM_is_load;
  logic PM_w_enable;
  logic [4:0]PM_rd_addr;
  logic [31:0]PM_line;
  logic [1:0]PM_offset;
  logic [31:0]PM_shifted_w_data;
  logic [3:0]PM_mem_w_enable;
  logic [1:0]PM_mem_access_width;
  logic PM_is_load_unsigned;

  //WD
  logic [31:0]WD_pc;
  logic [31:0]WD_irreg_pc;
  logic [31:0]WD_writeback_data;
  logic [4:0]WD_rd_addr;
  logic WD_w_enable;

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
      .sys_rstn_i(rstd)
  );


  //ハードウェアカウンタ
  logic [0:0] PM_hc_access;
  //logic [31:0] hc_OUT_data;

  //hardware_counter hardware_counter(
  //    .CLK_IP(clk),
  //    .RSTN_IP(rstd),
  //    .COUNTER_OP(hc_OUT_data)
  //);

  //logic [31:0]r_data_hc;
  //assign r_data_hc = hc_access == `ENABLE ? hc_OUT_data : MW_r_data;
  //assign r_data_hc = hc_access == `ENABLE ? hc_OUT_data : r_data;

  fetch fetch(
    .clk(clk),
    .rstd(rstd),
    .is_data_hazard(is_data_hazard),
    .irreg_pc(EM_irreg_pc),
    //.irreg_pc(WD_irreg_pc),
    .FD_pc(FD_pc),
    .FD_inst(FD_inst)
  );
  
  decode decode(
    .clk(clk),
    .rstd(rstd),
    .inst(FD_inst), //パイプラインレジスタからの配線
    .pc(FD_pc),
    .w_enable_WB(WD_w_enable), //WBで書き込むかどうか
    .w_addr_WB(WD_rd_addr), //WBで書き込むアドレス
    .w_data_WB(WD_writeback_data), //WBで書き込むデータ
    .pc_WB(WD_pc),
    .is_data_hazard(is_data_hazard), //このクロックでデコードした命令がデータハザードを起こすか
    .DE_pc(DE_pc),
    .DE_rs1_data(DE_rs1_data),
    .DE_rs2_data(DE_rs2_data),
    .DE_imm(DE_imm),
    .DE_rd_addr(DE_rd_addr),
    .DE_alu_code(DE_alu_code),
    .DE_alu_op1_type(DE_alu_op1_type),
    .DE_alu_op2_type(DE_alu_op2_type),
    .DE_w_enable(DE_w_enable),
    .DE_is_store(DE_is_store),
    .DE_is_load(DE_is_load),
    .DE_is_halt(DE_is_halt)
  );

  execute execute(
    .clk(clk),
    .rstd(rstd),
    .pc(DE_pc), 
    .src1_data(DE_rs1_data),
    .src2_data(DE_rs2_data),
    .rd_addr(DE_rd_addr),
    .w_enable(DE_w_enable),
    .imm(DE_imm), 
    .alu_code(DE_alu_code),
    .alu_op1_type(DE_alu_op1_type),
    .alu_op2_type(DE_alu_op2_type),
    .is_load(DE_is_load),
    .is_store(DE_is_store),
    .EM_pc(EM_pc),
    .EM_alu_result(EM_alu_result),
    .EM_w_data(EM_w_data),
    .EM_mem_access_width(EM_mem_access_width),
    .EM_rd_addr(EM_rd_addr),
    .EM_w_enable(EM_w_enable),
    .EM_is_store(EM_is_store),
    .EM_is_load(EM_is_load),
    .EM_is_load_unsigned(EM_is_load_unsigned),
    .EM_irreg_pc(EM_irreg_pc)
  );


  //memory_access memory_access(
  //  .pc(EM_pc),
  //  //.rstd(rstd),
  //  .clk(clk),
  //  .irreg_pc(EM_irreg_pc),
  //  .w_enable(EM_w_enable),
  //  .rd_addr(EM_rd_addr),
  //  .is_store(EM_is_store),
  //  .is_load(EM_is_load),
  //  .is_load_unsigned(EM_is_load_unsigned),
  //  .alu_result(EM_alu_result),
  //  .mem_access_width(EM_mem_access_width),
  //  .w_data(EM_w_data),
  //  .MW_pc(MW_pc),
  //  .MW_irreg_pc(MW_irreg_pc),
  //  .MW_r_data(MW_r_data),
  //  .MW_alu_result(MW_alu_result),
  //  .MW_is_load(MW_is_load),
  //  .MW_w_eneble(MW_w_eneble),
  //  .MW_rd_addr(MW_rd_addr),
  //  .uart(uart_IN_data),
  //  .uart_we(uart_we),
  //  .hc_access(hc_access)
  //);

  pre_memory_access pre_memory_access(
    .pc(EM_pc),
    //.rstd(rstd),
    .clk(clk),
    .irreg_pc(EM_irreg_pc),
    .w_enable(EM_w_enable),
    .rd_addr(EM_rd_addr),
    .is_store(EM_is_store),
    .is_load(EM_is_load),
    .is_load_unsigned(EM_is_load_unsigned),
    .alu_result(EM_alu_result),
    .mem_access_width(EM_mem_access_width),
    .w_data(EM_w_data),
    .PM_pc(PM_pc),
    .PM_irreg_pc(PM_irreg_pc),
    .PM_alu_result(PM_alu_result),
    .PM_is_load(PM_is_load),
    .PM_w_enable(PM_w_enable),
    .PM_rd_addr(PM_rd_addr),
    .PM_line(PM_line),
    .PM_offset(PM_offset),
    .PM_shifted_w_data(PM_shifted_w_data),
    .PM_mem_w_enable(PM_mem_w_enable),
    .PM_mem_access_width(PM_mem_access_width),
    .PM_is_load_unsigned(PM_is_load_unsigned),
    .uart(uart_IN_data),
    .uart_we(uart_we),
    .PM_hc_access(PM_hc_access)
  );

  mem_access mem_access(
    .clk(clk),
    .rstd(rstd),
    .pc(PM_pc),
    .irreg_pc(PM_irreg_pc),
    .alu_result(PM_alu_result),
    .is_load(PM_is_load),
    .w_enable(PM_w_enable),
    .rd_addr(PM_rd_addr),
    .line(PM_line),
    .offset(PM_offset),
    .shifted_w_data(PM_shifted_w_data),
    .mem_w_enable(PM_mem_w_enable),
    .mem_access_width(PM_mem_access_width),
    .is_load_unsigned(PM_is_load_unsigned),
    .hc_access(PM_hc_access),
    .MW_pc(MW_pc),
    .MW_irreg_pc(MW_irreg_pc),
    .MW_r_data(MW_r_data),
    .MW_alu_result(MW_alu_result),
    .MW_is_load(MW_is_load),
    .MW_w_enable(MW_w_enable),
    .MW_rd_addr(MW_rd_addr)
  );

  
  writeback writeback(
    .pc(MW_pc),
    //.rstd(rstd),
    .clk(clk),
    .irreg_pc(MW_irreg_pc),
    .w_enable(MW_w_enable),
    .rd_addr(MW_rd_addr),
    .is_load(MW_is_load),
    //.mem_r_data(r_data_hc),
    .mem_r_data(MW_r_data),
    .alu_result(MW_alu_result),
    .WD_pc(WD_pc),
    .WD_irreg_pc(WD_irreg_pc),
    .WD_writeback_data(WD_writeback_data),
    .WD_rd_addr(WD_rd_addr),
    .WD_w_enable(WD_w_enable)
  );
endmodule
