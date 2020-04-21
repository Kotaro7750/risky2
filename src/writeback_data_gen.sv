`timescale 1ns / 1ps

//writebackするデータを選択する。
module writeback_gen(
  input var bit is_load,
  input var [31:0]mem_r_data,
  input var [31:0]alu_result,
  output var [31:0]writeback_data
);

  assign writeback_data = is_load ? mem_r_data : alu_result;
endmodule
