//`timescale 1ns / 1ps
`include "define.svh"

module memory_ctl(
  input var [31:0]pc,
  input var bit clk,
  input var bit is_store,
  input var bit is_load_unsigned,
  input var [31:0]addr,
  input var [1:0]mem_access_width,
  input var [31:0]w_data,
  output var [31:0]line,
  output var [1:0]offset,
  output var [31:0]shifted_w_data,
  output var [3:0]w_enable,
  output var [7:0]uart,
  output var logic uart_we
);

  assign line = addr >> 2;
  assign offset = addr - ((addr >> 2)<<2);

  assign shifted_w_data = shifted_w_data_gen(is_store,mem_access_width,shifted_w_data_b,shifted_w_data_h,shifted_w_data_w,shifted_w_data_none);
  assign w_enable = w_enable_gen(is_store,mem_access_width,offset);

  logic [31:0] shifted_w_data_b;
  logic [31:0] shifted_w_data_h;
  logic [31:0] shifted_w_data_w;
  logic [31:0] shifted_w_data_none;

  assign shifted_w_data_b = (w_data & 8'hff) << (offset*8);
  assign shifted_w_data_h = (w_data & 16'hffff) << (offset*8);
  assign shifted_w_data_w = w_data;
  assign shifted_w_data_none = 32'd0;

  assign uart = shifted_w_data_b & 8'hff;
  assign uart_we = ((addr == `UART_ADDR) && (is_store == `ENABLE)) ? 1'b1 : 1'b0;

  function automatic [31:0] shifted_w_data_gen;
    input bit is_store;
    input [1:0] mem_access_width;
    input [31:0] shifted_w_data_b;
    input [31:0] shifted_w_data_h;
    input [31:0] shifted_w_data_w;
    input [31:0] shifted_w_data_none;

    begin
      if(is_store) begin
        case (mem_access_width)
          `MEM_BYTE: begin
            shifted_w_data_gen = shifted_w_data_b;
          end
          `MEM_HALF: begin
            shifted_w_data_gen = shifted_w_data_h;
          end
          `MEM_WORD: begin
            shifted_w_data_gen = shifted_w_data_w;
          end
          default: begin
            shifted_w_data_gen = shifted_w_data_none;
          end
        endcase
      end
      else begin
        shifted_w_data_gen = shifted_w_data_none;
      end
    end
  endfunction

  
  function automatic [3:0] w_enable_gen;
    input bit is_store;
    input [1:0] mem_access_width;
    input [1:0] offset;
    begin
      if(is_store) begin
        case (mem_access_width)
          `MEM_BYTE: begin
            w_enable_gen = 4'b0001 << offset;
          end
          `MEM_HALF: begin
            w_enable_gen = 4'b0011 << offset;
          end
          `MEM_WORD: begin
            w_enable_gen = 4'b1111;
          end
          default: begin
            w_enable_gen = 4'b0000;
          end
        endcase
      end
      else begin
        w_enable_gen = 4'b0000;
      end
    end
  endfunction
endmodule
