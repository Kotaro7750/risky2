`timescale 1ns / 1ps
`include "define.svh"

//irreg_pcを生成する
module irreg_pc_gen(
  input var [31:0]op1,
  input var [31:0]op2,
  input var bit is_branch,
  input var bit br_taken,
  output var [31:0]irreg_pc
);

  //TODO ここop1+4じゃなくて0にしないとだめかな。でも0にジャンプする命令あった
  //らどうしよう
  //assign irreg_pc = (br_taken == `ENABLE) ? op1 + op2 : op1 + 4;
  //assign irreg_pc = (br_taken == `ENABLE) ? op1 + op2 : 31'd0;
  assign irreg_pc = (is_branch == `ENABLE) ? ((br_taken == `ENABLE) ? op1 + op2 : op1 + 4) : 31'd0;
endmodule
