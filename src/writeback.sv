`timescale 1ns / 1ps

module writeback(
  input var [31:0]pc,
  input var bit clk,
  //input var bit rstd,
  input var [31:0]irreg_pc,
  input var bit w_enable,
  input var [4:0]rd_addr,
  input var bit is_load,
  input var [31:0]mem_r_data,
  input var [31:0]alu_result,
  output var [31:0]WD_pc,
  output var [31:0]WD_irreg_pc,
  output var [31:0]WD_writeback_data,
  output var [4:0]WD_rd_addr,
  output var logic WD_w_enable
);

  logic [31:0]writeback_data;

  always_ff@(posedge clk) begin
    if (w_enable) begin
      if (is_load) $display("0x%4h: ", pc,"x%02d",rd_addr," = ","0x%08h",writeback_data," 0x%08h",writeback_data," <- ","mem[0x%08h]",alu_result);
      else $display("0x%4h: ", pc,"x%02d",rd_addr," = ","0x%08h",writeback_data);
    end 
  end

  assign  WD_pc = pc;
  assign  WD_irreg_pc = irreg_pc;
  assign  WD_writeback_data = writeback_data;
  assign  WD_w_enable = w_enable;
  assign  WD_rd_addr = rd_addr;

  writeback_gen writeback_gen(
    .is_load(is_load),
    .mem_r_data(mem_r_data),
    .alu_result(alu_result),
    .writeback_data(writeback_data)
  );
endmodule
