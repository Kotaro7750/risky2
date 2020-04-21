`timescale 1ns / 1ps
`include "define.svh"

module mem_ctl(
  input var [31:0]pc,
  input var bit clk,
  input var bit is_store,
  input var bit is_load_unsigned,
  input var [31:0]addr,
  input var [1:0]mem_access_width,
  input var [31:0]w_data,
  output var [31:0]r_data,
  output var [7:0]uart,
  output var logic uart_we
);

  //lineはmemの何個目なのか
  wire [31:0] line;
  //offsetは4バイトのうちの何個目か
  wire [1:0] offset;

  assign line = addr >> 2;
  assign offset = addr - ((addr >> 2)<<2);

  //reg [31:0] shifted_w_data;
  //reg [3:0] w_enable;
  logic [31:0] shifted_w_data;
  logic [3:0] w_enable;

  wire [31:0] row_r_data;

  wire [31:0] shifted_w_data_b;
  wire [31:0] shifted_w_data_h;
  wire [31:0] shifted_w_data_w;
  wire [31:0] shifted_w_data_none;

  assign shifted_w_data_b = (w_data & 8'hff) << (offset*8);
  assign shifted_w_data_h = (w_data & 16'hffff) << (offset*8);
  assign shifted_w_data_w = w_data;
  assign shifted_w_data_none = 32'd0;

  assign uart = shifted_w_data_b & 8'hff;
  assign uart_we = ((addr == `UART_ADDR) && (is_store == `ENABLE)) ? 1'b1 : 1'b0;
  //assign uart_we = addr == `UART_ADDR ? 1'b1 : 1'b0;


  ram ram(pc,clk, w_enable, line, row_r_data, line, shifted_w_data);

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

  always_comb @(is_store,addr,w_data) begin
  //always @(negedge clk) begin
      if(is_store) begin
        case (mem_access_width)
          `MEM_BYTE: begin
            shifted_w_data <= shifted_w_data_b;
            w_enable <= 4'b0001 << offset;
          end
          `MEM_HALF: begin
            shifted_w_data <= shifted_w_data_h;
            w_enable <= 4'b0011 << offset;
          end
          `MEM_WORD: begin
            shifted_w_data <= shifted_w_data_w;
            w_enable <= 4'b1111;
          end
          default: begin
            shifted_w_data <= shifted_w_data_none;
            w_enable <= 4'b0000;
          end
        endcase
      end
      else begin
        shifted_w_data <= shifted_w_data_none;
        w_enable <= 4'b0000;
      end
  end

  assign r_data = r_data_gen(row_r_data,mem_access_width,is_load_unsigned,offset);
endmodule
