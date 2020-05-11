`timescale 1ns / 1ps
`include "define.svh"

//irreg_pcを生成する
module irreg_pc_gen(
  input var [31:0]op1,
  input var [31:0]op2,
  input var bit isBranch,
  input var bit brTaken,
  output var [31:0]irregPc
);

  assign irregPc = (isBranch == `ENABLE) ? ((brTaken == `ENABLE) ? op1 + op2 : op1 + 4) : 31'd0;
endmodule
