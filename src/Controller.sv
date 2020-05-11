`timescale 1ns / 1ps
`include "define.svh"

import BasicTypes::*;
import PipelineTypes::*;

module Controller(
  ControllerIF.Controller port,
  DecodeStageIF.Controller decode,
  ExecuteStageIF.Controller execute,
  RegisterFileIF.Controller registerFile
);

  //assign port.isDataHazard = isDataHazard(registerFile.rs1Ready,registerFile.rs2Ready,decode.aluOp1Type,decode.aluOp2Type,decode.isStore);
  assign port.isDataHazard = isDataHazard(decode.rs1Addr,decode.rs2Addr,decode.aluOp1Type,decode.aluOp2Type,decode.rdCtrl,execute.rdCtrl,decode.isStore);

  //function bit isDataHazard;
  //  input bit rs1Ready;
  //  input bit rs2Ready;
  //  input [1:0]aluOp1Type;
  //  input [1:0]aluOp2Type;
  //  input bit isStore;

  //  begin
  //    if (isStore == `ENABLE) begin
  //      isDataHazard = ((rs1Ready == `DISABLE && aluOp1Type == OP_TYPE_REG) || (rs2Ready == `DISABLE)) ? `ENABLE : `DISABLE;
  //    end
  //    else begin
  //      isDataHazard = ((rs1Ready == `DISABLE && aluOp1Type == OP_TYPE_REG) || (rs2Ready == `DISABLE && aluOp2Type == OP_TYPE_REG)) ? `ENABLE : `DISABLE; 
  //    end
  //  end
  //endfunction
  
  function bit isDataHazard;
    input RegAddr rs1Addr;
    input RegAddr rs2Addr;
    input ALUOpType aluOp1Type;
    input ALUOpType aluOp2Type;
    input RDCtrl execute;
    input RDCtrl memoryAccess;
    input bit isStore;

    begin
      if (isStore == `ENABLE) begin
        isDataHazard = ((rs1Addr != 5'd0 && rs1Addr == execute.rdAddr && execute.wEnable == `ENABLE && aluOp1Type == OP_TYPE_REG) 
                      || (rs1Addr != 5'd0 && rs1Addr == memoryAccess.rdAddr && memoryAccess.wEnable == `ENABLE && aluOp1Type == OP_TYPE_REG)
                      || (rs2Addr != 5'd0 && rs2Addr == execute.rdAddr && execute.wEnable == `ENABLE)
                      || (rs2Addr != 5'd0 && rs2Addr == memoryAccess.rdAddr && memoryAccess.wEnable == `ENABLE)) ? `ENABLE : `DISABLE;
      end
      else begin
        isDataHazard = ((rs1Addr != 5'd0 && rs1Addr == execute.rdAddr && execute.wEnable == `ENABLE && aluOp1Type == OP_TYPE_REG) 
                      || (rs1Addr != 5'd0 && rs1Addr == memoryAccess.rdAddr && memoryAccess.wEnable == `ENABLE && aluOp1Type == OP_TYPE_REG)
                      || (rs2Addr != 5'd0 && rs2Addr == execute.rdAddr && execute.wEnable == `ENABLE && aluOp2Type == OP_TYPE_REG)
                      || (rs2Addr != 5'd0 && rs2Addr == memoryAccess.rdAddr && memoryAccess.wEnable == `ENABLE && aluOp2Type == OP_TYPE_REG)) ? `ENABLE : `DISABLE;
      end
    end
  endfunction
endmodule
