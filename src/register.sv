`timescale 1ns / 1ps
`include "define.svh"

//reg_readyとreg_fileをまとめる。
module register(
  input var bit clk,
  input var bit rstd,
  input var [4:0]rs1_addr,
  input var [4:0]rs2_addr,
  input var logic wb_enable,
  input var [4:0]wb_addr,
  input var [31:0]wb_data,
  input var logic prev_w_enable,
  input var [4:0]prev_rd_addr,
  output var [31:0]rs1_data,
  output var [31:0]rs2_data,
  output var logic rs1_ready,
  output var logic rs2_ready
);
  //クロックの立ち上がりで書き込む。reg_readyのWBと配線は同じにすることで、書
  //き込み先を同一にすることを保証する。
  //読みは垂れ流しなので、decodeで適切にさばく。
  reg_file reg_file(
    //input
    .clk(clk),
    .rstd(rstd),
    .rs1_addr(rs1_addr), //rs1のアドレス
    .rs2_addr(rs2_addr), //rs2のアドレス
    .w_enable(wb_enable), //命令の結果を書き込むかどうか
    .w_addr(wb_addr), //書き込むアドレス
    .w_data(wb_data), //命令の結果
    //output
    .rs1_data(rs1_data), //読み出したrs1のデータ
    .rs2_data(rs2_data) //読み出したrs2のデータ
  );

  //クロックの立ち上がりで、前のクロックでデコードした命令のrdと、このクロック
  //でレジスタに書き込む命令のrdのready情報を更新する。
  reg_ready reg_ready(
    //input
    .clk(clk),
    .rstd(rstd),
    .rs1_addr(rs1_addr), //rs1のアドレス
    .rs2_addr(rs2_addr), //rs2のアドレス
    .w_addr_D(prev_rd_addr), //前回のクロックでデコードした命令のrdアドレス
    .w_addr_WB(wb_addr), //WBで書き込むアドレス
    .w_enable_D(prev_w_enable), //前回のクロックでデコードした命令の書き込みの有無
    .w_enable_WB(wb_enable), //WBでの書き込みの有無
    //output
    .rs1_ready(rs1_ready), //rs1が使用可能か
    .rs2_ready(rs2_ready) //rs2が使用可能か
  );

endmodule
