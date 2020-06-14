`timescale 1ns / 1ps
`include "../define.svh"

import BasicTypes::*;
import PipelineTypes::*;
import MulDivTypes::*;

module Multiplier(
  input var BasicData op1,
  input var BasicData op2,
  output var logic [63:0] product
);

  assign product = op1 * op2;

endmodule

module SignExtender (
    input BasicData in, 
    input logic sign,
    output SignExtendedBasicData out
);
    always_comb begin
        if (sign) begin
            out = {in[31], in};
        end
        else begin
            out = {1'b0, in};
        end
    end    
endmodule

module PipelinedMultiplier (
  input var logic clk,
  input var logic signOp1,
  input var BasicData op1,
  input var logic signOp2,
  input var BasicData op2,
  output var MulDivResult product
);
  SignExtendedBasicData exOp1;
  SignExtendedBasicData exOp2;

  SignExtendedBasicData exOp1Reg;
  SignExtendedBasicData exOp2Reg;

  SignExtender signExtenderOp1 (
    .in(op1),
    .sign(signOp1),
    .out(exOp1)
  );

  SignExtender signExtenderOp2 (
    .in(op2),
    .sign(signOp2),
    .out(exOp2)
  );

  MulDivResult mulResult;

  always_comb begin
    (* use_dsp48 = "yes" *)
    mulResult = exOp1Reg * exOp2Reg;   // synthesis syn_dspstyle = "dsp48"
  end

  MulDivResult productInt [MULDIV_PIPELINE_DEPTH - 1 : 0];
  logic [2:0] i;

  assign product = productInt [MULDIV_PIPELINE_DEPTH - 1];

  always@(posedge clk) begin
    exOp1Reg <= exOp1;
    exOp2Reg <= exOp2;

    productInt[0] <= mulResult;

    for(i =1; i < MULDIV_PIPELINE_DEPTH; i++) begin
      productInt [i] <= productInt [i-1];
    end
  end
endmodule

