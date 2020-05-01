`timescale 1ns / 1ps

module pre_memory_access(
  input var [31:0]pc,
  input var bit clk,
  //input var bit rstd,
  input var [31:0]irreg_pc,
  input var bit w_enable,
  input var [4:0]rd_addr,
  input var bit is_store,
  input var bit is_load,
  input var bit is_load_unsigned,
  input var [31:0]alu_result,
  input var [1:0]mem_access_width,
  input var [31:0]w_data,
  output var [31:0]PM_pc,
  output var [31:0]PM_irreg_pc,
  output var [31:0]PM_alu_result,
  output var logic PM_is_load,
  output var logic PM_w_enable,
  output var [4:0]PM_rd_addr,
  output var [31:0]PM_line,
  output var [1:0]PM_offset,
  output var [31:0]PM_shifted_w_data,
  output var [3:0] PM_mem_w_enable,
  output var [1:0]PM_mem_access_width,
  output var bit PM_is_load_unsigned,
  output var [7:0]uart,
  output var logic uart_we,
  output var logic PM_hc_access
);

  logic [31:0]line;
  logic [1:0]offset;
  logic [3:0]mem_w_enable;
  logic [31:0]shifted_w_data;

  //assign hc_access = alu_result == `HARDWARE_COUNTER_ADDR ? `ENABLE:`DISABLE;

  always_ff@(negedge clk) begin
    PM_pc <= pc;
    PM_irreg_pc <= irreg_pc;
    PM_alu_result <= alu_result;
    PM_is_load <= is_load;
    PM_w_enable <= w_enable;
    PM_rd_addr <= rd_addr;
    PM_line <= line;
    PM_offset <= offset;
    PM_shifted_w_data <= shifted_w_data;
    PM_mem_w_enable <= mem_w_enable;
    PM_mem_access_width <= mem_access_width;
    PM_is_load_unsigned <= is_load_unsigned;
    if (alu_result == `HARDWARE_COUNTER_ADDR && is_load) PM_hc_access <= `ENABLE;
    else PM_hc_access <= `DISABLE;
  end

  pre_mem_ctl pre_mem_ctl(
    .pc(pc),
    .clk(clk),
    .is_store(is_store),
    .is_load_unsigned(is_load_unsigned),
    .addr(alu_result),
    .mem_access_width(mem_access_width),
    .w_data(w_data),
    .w_enable(mem_w_enable),
    .line(line),
    .offset(offset),
    .shifted_w_data(shifted_w_data),
    .uart(uart),
    .uart_we(uart_we)
  );
endmodule
