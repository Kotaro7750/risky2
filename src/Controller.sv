`timescale 1ns / 1ps
`include "define.svh"

import BasicTypes::*;
import PipelineTypes::*;

module Controller(
  ControllerIF.Controller port,
  DecodeStageIF.Controller decode,
  RegisterFileIF.Controller registerFile
);

  assign port.isDataHazard = isDataHazard(registerFile.rs1Ready,registerFile.rs2Ready,decode.aluOp1Type,decode.aluOp2Type,decode.isStore);

  function bit isDataHazard;
    input bit rs1Ready;
    input bit rs2Ready;
    input [1:0]aluOp1Type;
    input [1:0]aluOp2Type;
    input bit isStore;

    begin
      if (isStore == `ENABLE) begin
        isDataHazard = ((rs1Ready == `DISABLE && aluOp1Type == OP_TYPE_REG) || (rs2Ready == `DISABLE)) ? `ENABLE : `DISABLE;
      end
      else begin
        isDataHazard = ((rs1Ready == `DISABLE && aluOp1Type == OP_TYPE_REG) || (rs2Ready == `DISABLE && aluOp2Type == OP_TYPE_REG)) ? `ENABLE : `DISABLE; 
      end
    end
  endfunction
endmodule
