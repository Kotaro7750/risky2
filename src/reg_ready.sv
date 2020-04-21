`timescale 1ns / 1ps
`include "define.svh"

//特定のレジスタがソースオペランドとして真の依存なしに読み出せるかを記録する。
//execステージに送る命令のrdを確保し、ライトバックしたrdを解放する。
//かぶった場合は今から確保する方を優先する。
module reg_ready(
  input var bit clk,
  input var bit rstd,
  input var [4:0]rs1_addr,
  input var [4:0]rs2_addr,
  input var [4:0]w_addr_D,
  input var [4:0]w_addr_WB,
  input var [0:0]w_enable_D,
  input var [0:0]w_enable_WB,
  output var [0:0]rs1_ready,
  output var [0:0]rs2_ready
);
  
  //i番目のbitがENABLEなら、レジスタiはソースとして使用可能、そうでないなら、
  //書き込み待ちのため使用不可。
  logic  [31:0]register_ready;

  assign rs1_ready = rs1_addr == 5'd0 ? `ENABLE :register_ready[rs1_addr];
  assign rs2_ready = rs2_addr == 5'd0 ? `ENABLE :register_ready[rs2_addr];

  always_ff @(negedge rstd or posedge clk) begin
    if (rstd == 0) begin
      for (integer i = 0; i < 32; i = i+1) begin
        register_ready[i] <= `ENABLE;
      end
    end

    else 
    if (w_addr_D == w_addr_WB) begin
      //リソースを開放したと同時に書き込もうとする命令をデコードした場合、デコ
      //ードした方を優先する。
      if (w_enable_D) begin
        register_ready[w_addr_D] <= `DISABLE;
      end
      else 
      begin
        if (w_enable_WB) begin
          register_ready[w_addr_WB] <= `ENABLE;
        end
      end
    end
    else 
    //書き込む対象が別々なら、フラグに応じて書き込ませる。
    begin
      //デコーダからの書き込み命令はこれから使用することを意味する。
      if (w_enable_D) begin
        register_ready[w_addr_D] <= `DISABLE;
      end
      //ライトバックからの書き込み命令は使用済みであることを意味する。
      if (w_enable_WB) begin
        register_ready[w_addr_WB] <= `ENABLE;
      end
    end
  end
endmodule
