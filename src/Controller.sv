`timescale 1ns / 1ps
`include "define.svh"

import BasicTypes::*;
import PipelineTypes::*;

module Controller(
  ControllerIF.Controller port,
  DecodeStageIF.Controller decode,
  ExecuteStageIF.Controller execute,
  MemoryAccessStageIF.Controller memoryAccess
);

  logic isRs1DataHazard;
  logic isRs2DataHazard;
  assign port.isDataHazard = (isRs1DataHazard == `ENABLE || isRs2DataHazard == `ENABLE) ? `ENABLE : `DISABLE;

  always_comb begin
    //rs1
    if (decode.aluOp1Type != OP_TYPE_REG) begin
      isRs1DataHazard = `DISABLE;
      port.op1BypassCtrl = BYPASS_NONE;
    end

    else if (decode.rs1Addr == 5'd0) begin
      isRs1DataHazard = `DISABLE;
      port.op1BypassCtrl = BYPASS_NONE;
    end

    else if (decode.rs1Addr == execute.rdCtrl.rdAddr && execute.rdCtrl.wEnable == `ENABLE) begin
      if (execute.rdCtrl.isForwardable == `ENABLE) begin
        isRs1DataHazard = `DISABLE;
        port.op1BypassCtrl = BYPASS_EXEC;
      end
      else begin
        isRs1DataHazard = `ENABLE;
        port.op1BypassCtrl = BYPASS_NONE;
      end
    end

    else if (decode.rs1Addr == memoryAccess.rdCtrl.rdAddr && memoryAccess.rdCtrl.wEnable == `ENABLE) begin
      if (memoryAccess.rdCtrl.isForwardable == `ENABLE) begin
        isRs1DataHazard = `DISABLE;
        port.op1BypassCtrl = BYPASS_MEM;
      end
      else begin
        isRs1DataHazard = `ENABLE;
        port.op1BypassCtrl = BYPASS_NONE;
      end
    end

    else begin
      isRs1DataHazard = `DISABLE;
      port.op1BypassCtrl = BYPASS_NONE;
    end

    //rs2
    if (decode.aluOp2Type != OP_TYPE_REG && decode.isStore != `ENABLE) begin
      isRs2DataHazard = `DISABLE;
      port.op2BypassCtrl = BYPASS_NONE;
    end

    else if (decode.rs2Addr == 5'd0) begin
      isRs2DataHazard = `DISABLE;
      port.op2BypassCtrl = BYPASS_NONE;
    end

    else if (decode.rs2Addr == execute.rdCtrl.rdAddr && execute.rdCtrl.wEnable == `ENABLE) begin
      if (execute.rdCtrl.isForwardable == `ENABLE) begin
        isRs2DataHazard = `DISABLE;
        port.op2BypassCtrl = BYPASS_EXEC;
      end
      else begin
        isRs2DataHazard = `ENABLE;
        port.op2BypassCtrl = BYPASS_NONE;
      end
    end

    else if (decode.rs2Addr == memoryAccess.rdCtrl.rdAddr && memoryAccess.rdCtrl.wEnable == `ENABLE) begin
      if (memoryAccess.rdCtrl.isForwardable == `ENABLE) begin
        isRs2DataHazard = `DISABLE;
        port.op2BypassCtrl = BYPASS_MEM;
      end
      else begin
        isRs2DataHazard = `ENABLE;
        port.op2BypassCtrl = BYPASS_NONE;
      end
    end

    else begin
      isRs2DataHazard = `DISABLE;
      port.op2BypassCtrl = BYPASS_NONE;
    end
  end

  always_comb begin
    if (execute.branchTaken != execute.isBranchTakenPredicted) begin
      port.isBranchPredictMiss = `ENABLE;
    end
    else begin
      port.isBranchPredictMiss = `DISABLE;
    end
  end

endmodule
