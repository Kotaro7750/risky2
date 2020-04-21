`timescale 1ns / 1ps

module memory_access2(
  input var [31:0]pc,
  input var bit clk,
  input var bit rstd,
  input var [31:0]irreg_pc,
  input var bit w_enable,
  input var [4:0]rd_addr,
  input var bit is_load,
  input var bit is_load_unsigned,
  input var [31:0]line,
  input var [1:0]offset,
  input var [3:0]w_enable,
  input var [31:0] shifted_w_data,
  input var [31:0]alu_result,
  input var [1:0]mem_access_width,
  input var [31:0]w_data,
  output var [31:0]MW_pc,
  output var [31:0]MW_irreg_pc,
  output var [31:0]MW_r_data,
  output var [31:0]MW_alu_result,
  output var logic MW_is_load,
  output var logic MW_w_eneble,
  output var [4:0]MW_rd_addr,
);

  logic [31:0]row_r_data;
  logic [31:0]r_data;
  assign r_data = r_data_gen(row_r_data,mem_access_width,is_load_unsigned,offset);

  function [31:0] r_data_gen;
    input [31:0] row_r_data;
    input [1:0] mem_access_width;
    input is_load_unsigned;
    input [1:0] offset;

    begin
      case (mem_access_width)
        `MEM_BYTE: begin
          r_data_gen = is_load_unsigned 
            ? ({32{1'b0}}) | ((row_r_data >> (offset * 8)) & 8'hff)
            : ({32{row_r_data[(offset+1) * 8 - 1]}} << 8) | ((row_r_data >> (offset * 8)) & 8'hff)
            ;
        end
        `MEM_HALF: begin
          r_data_gen = is_load_unsigned 
            ? ({32{1'b0}}) | ((row_r_data >> (offset * 8)) & 16'hffff)
            : ({32{row_r_data[(offset + 2) * 8  -1]}} << 16) | ((row_r_data >> (offset * 8)) & 16'hffff)
            ;
        end
        `MEM_WORD: begin
          r_data_gen = row_r_data;
        end
        default: begin
          r_data_gen = row_r_data;
        end
      endcase
    end
  endfunction


  ram ram(pc,clk, mem_w_enable, line, row_r_data, line, shifted_w_data);

  always@(negedge clk) begin
    MW_pc <= pc;
    MW_irreg_pc <= irreg_pc;
    MW_r_data <= r_data;
    MW_alu_result <= alu_result;
    MW_is_load <= is_load;
    MW_w_eneble <= w_enable;
    MW_rd_addr <= rd_addr;
  end

endmodule
