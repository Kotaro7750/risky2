`timescale 1ns / 1ps
`include "define.svh"

module bram(pc,clk, w_enable, r_addr, r_data, w_addr, w_data,row_addr);
  input [31:0]pc;
  input clk;
  input  [3:0] w_enable; // 書き込むバイトは1, 書き込まないでそのままにするバイトは0を指定
  input  [31:0] r_addr, w_addr;
  input  [31:0] w_data;
  input  [31:0] row_addr;
  output logic [31:0] r_data;

  //TODO もっと大きく
  reg [31:0] mem [0:32767];

  always_ff @(posedge clk) begin
      if (w_enable) $display("0x%4h: ", pc,"mem[0x%08h]",row_addr," <- ","0x%h",w_data);
      if(w_enable[0]) mem[w_addr][ 7: 0] <= w_data[ 7: 0];
      if(w_enable[1]) mem[w_addr][15: 8] <= w_data[15: 8];
      if(w_enable[2]) mem[w_addr][23:16] <= w_data[23:16];
      if(w_enable[3]) mem[w_addr][31:24] <= w_data[31:24];
      //r_addr_reg <= r_addr;
      //r_data <= mem[r_addr % 32678];
      r_data <= mem[r_addr];
  end

  //assign r_data = mem[r_addr_reg];
  //assign r_data = mem[r_addr % 32678];

  //initial $readmemh("/home/denjo/lecture/3A/experiment/processor/b3exp/benchmarks/Coremark_for_Synthesis/data.hex",mem);
  initial $readmemh("/home/koutarou/develop/risky2/benchmarks/Coremark_for_Synthesis/data.hex",mem);
  //initial $readmemh("/home/koutarou/develop/risky2/benchmarks/Coremark/data.hex",mem);
  //initial $readmemh("/home/denjo/lecture/3A/experiment/processor/b3exp/risky/risky/risky.srcs/sources_1/new/test.hex",mem);
endmodule
