`timescale 1ns / 1ps

//クロックエッジで書き込み、読み込みは同期なしのレジスタファイル
module reg_file(
  input var [31:0] pc,
  input var bit clk,
  input var bit rstd,
  input var [4:0]rs1_addr,
  input var [4:0]rs2_addr,
  input var logic w_enable,
  input var [4:0]w_addr,
  input var [31:0]w_data,
  output var [31:0]rs1_data,
  output var [31:0]rs2_data
);

  logic  [31:0] register_file[0:31];

  assign rs1_data = rs1_addr == 5'd0 ? 32'd0 : register_file[rs1_addr];
  assign rs2_data = rs2_addr == 5'd0 ? 32'd0 : register_file[rs2_addr];

  always_ff @(negedge rstd or posedge clk) begin
    if (rstd == 0) begin
      for (integer i = 0; i < 32; i = i+1) begin
        register_file[i] <= 32'h00000000;
      end
    end
    else if (w_enable == 1) begin
      register_file[w_addr] <= w_data;
    end
  end
endmodule
