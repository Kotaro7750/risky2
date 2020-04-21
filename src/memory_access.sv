`timescale 1ns / 1ps

module memory_access(
  input var [31:0]pc,
  input var bit clk,
  input var bit rstd,
  input var [31:0]irreg_pc,
  input var bit w_enable,
  input var [4:0]rd_addr,
  input var bit is_store,
  input var bit is_load,
  input var bit is_load_unsigned,
  input var [31:0]alu_result,
  input var [1:0]mem_access_width,
  input var [31:0]w_data,
  output var [31:0]MW_pc,
  output var [31:0]MW_irreg_pc,
  output var [31:0]MW_r_data,
  output var [31:0]MW_alu_result,
  output var logic MW_is_load,
  output var logic MW_w_eneble,
  output var [4:0]MW_rd_addr,
  output [7:0]uart,
  output var logic uart_we,
  output var logic hc_access
);

  logic [31:0]r_data;

  assign hc_access = alu_result == `HARDWARE_COUNTER_ADDR ? `ENABLE:`DISABLE;

  always@(negedge clk) begin
    MW_pc <= pc;
    MW_irreg_pc <= irreg_pc;
    MW_r_data <= r_data;
    MW_alu_result <= alu_result;
    MW_is_load <= is_load;
    MW_w_eneble <= w_enable;
    MW_rd_addr <= rd_addr;
  end

  mem_ctl mem_ctl2(
    .pc(pc),
    .clk(clk),
    .is_store(is_store),
    .is_load_unsigned(is_load_unsigned),
    .addr(alu_result),
    .mem_access_width(mem_access_width),
    .w_data(w_data),
    .r_data(r_data),
    .uart(uart),
    .uart_we(uart_we)
  );

endmodule
