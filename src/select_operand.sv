`timescale 1ns / 1ps
`include "define.svh"

//実際にレジスタから読み出された値とフォワードされてきた値を、セレクタに従って
//選択して出力する。
module select_operand(
  input var [1:0]rs1_selector,
  input var [31:0]row_rs1_data,
  input var [1:0]rs2_selector,
  input var [31:0]row_rs2_data,
  input var [31:0]E_forward_data,
  input var [31:0]M_forward_data,
  input var [31:0]W_forward_data,
  output var [31:0]rs1_data,
  output var [31:0]rs2_data
);

  assign rs1_data = select(rs1_selector,rs1_data,E_forward_data,M_forward_data,W_forward_data);
  assign rs2_data = select(rs2_selector,rs2_data,E_forward_data,M_forward_data,W_forward_data);

  function [31:0] select;
    input [1:0]selector;
    input [31:0]from_register;
    input [31:0]E_data;
    input [31:0]M_data;
    input [31:0]W_data;
    begin
      case (selector)
        `FWD_NONE: begin
          select = from_register;
        end
        `FWD_E: begin
          select = E_data;
        end
        `FWD_M: begin
          select = M_data;
        end
        `FWD_W: begin
          select = W_data;
        end
        default : begin
          select = from_register;
        end
      endcase
    end
  endfunction

endmodule
