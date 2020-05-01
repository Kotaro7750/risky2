`timescale 1ns / 1ps
`include "define.svh"

//E,M,Wステージから、書き込みの有無・算術論理命令かどうか・ディスティネーショ
//ンアドレス・結果を受け取り、ディスティネーションアドレスをデコードステージに
//送る。デコードステージはこの情報からハザードを起こすか、次に進めるとしたらレ
//ジスタの値かフォワードされた値のどちらを使うかの制御をEに進める。Eはその制御
//線をもとに渡されるデータを使用する。
module forward(
  input var logic clk,
  input var logic rstd,
  input var logic E_is_arismetic_logic,
  input var logic E_w_enable,
  input var [4:0]E_rd_addr,
  input var [31:0]E_result,
  input var logic M_is_arismetic_logic,
  input var logic M_w_enable,
  input var [4:0]M_rd_addr,
  input var [31:0]M_result,
  input var logic W_is_arismetic_logic,
  input var logic W_w_enable,
  input var [4:0]W_rd_addr,
  input var [31:0]W_result,
  output var E_forwardable_addr,
  output var M_forwardable_addr,
  output var W_forwardable_addr,
  output var [31:0]DE_E_forward_data,
  output var [31:0]DE_M_forward_data,
  output var [31:0]DE_W_forward_data
);

  //ゼロレジスタへの書き込みまたは、フォワードできない命令なら、デコードに伝え
  //るアドレスはゼロレジスタ
  assign E_forwardable_addr = (E_is_arismetic_logic && E_w_enable) ? E_rd_addr : 5'd0;
  assign M_forwardable_addr = (M_is_arismetic_logic && M_w_enable) ? M_rd_addr : 5'd0;
  assign W_forwardable_addr = (W_is_arismetic_logic && W_w_enable) ? W_rd_addr : 5'd0;

  //使う可能性のある値は全てEに渡す。選択はEでやれば良い。
  always_ff@(negedge clk) begin
    DE_E_forward_data <= E_result;
    DE_M_forward_data <= M_result;
    DE_W_forward_data <= W_result;
  end
endmodule
