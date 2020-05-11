`timescale 1ns / 1ps
`include "define.svh"

//reg_readyとreg_fileをまとめる。
module register(
  input var [31:0] pc_WB,
  RegisterFileIF.RegisterFile port
);
  //クロックの立ち上がりで書き込む。reg_readyのWBと配線は同じにすることで、書
  //き込み先を同一にすることを保証する。
  //読みは垂れ流しなので、decodeで適切にさばく。
  reg_file reg_file(
    //input
    .pc(pc_WB),
    .clk(port.clk),
    .rstd(port.rst),
    .rs1_addr(port.rs1Addr), //rs1のアドレス
    .rs2_addr(port.rs2Addr), //rs2のアドレス
    .w_enable(port.wEnable), //命令の結果を書き込むかどうか
    .w_addr(port.rdAddr), //書き込むアドレス
    .w_data(port.wData), //命令の結果
    //output
    .rs1_data(port.rs1Data), //読み出したrs1のデータ
    .rs2_data(port.rs2Data) //読み出したrs2のデータ
  );

  //クロックの立ち上がりで、前のクロックでデコードした命令のrdと、このクロック
  //でレジスタに書き込む命令のrdのready情報を更新する。
  reg_ready reg_ready(
    //input
    .clk(port.clk),
    .rstd(port.rst),
    .rs1_addr(port.rs1Addr), //rs1のアドレス
    .rs2_addr(port.rs2Addr), //rs2のアドレス
    .w_addr_D(port.prevRdAddr), //前回のクロックでデコードした命令のrdアドレス
    .w_addr_WB(port.rdAddr), //WBで書き込むアドレス
    .w_enable_D(port.prevWEnable), //前回のクロックでデコードした命令の書き込みの有無
    .w_enable_WB(port.wEnable), //WBでの書き込みの有無
    //output
    .rs1_ready(port.rs1Ready), //rs1が使用可能か
    .rs2_ready(port.rs2Ready) //rs2が使用可能か
  );

endmodule
