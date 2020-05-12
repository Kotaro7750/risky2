import BasicTypes::*;
import PipelineTypes::*;

interface ControllerIF(
  input var logic clk,
  input var logic rst
);

  BypassCtrl op1BypassCtrl;
  BypassCtrl op2BypassCtrl;
  logic isDataHazard;
  logic isBranchPredictMiss;

  modport Controller(
    input clk,
    input rst,
    output isDataHazard,
    output isBranchPredictMiss,
    output op1BypassCtrl,
    output op2BypassCtrl
  );

  modport DataHazard(
    input isDataHazard
  );

  modport FetchStage(
    input isBranchPredictMiss
  );

  modport DecodeStage(
    input op1BypassCtrl,
    input op2BypassCtrl,
    input isBranchPredictMiss
  );

  modport ExecuteStage(
    input isBranchPredictMiss
  );

endinterface : ControllerIF
