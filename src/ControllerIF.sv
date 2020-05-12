import BasicTypes::*;
import PipelineTypes::*;

interface ControllerIF(
  input var logic clk,
  input var logic rst
);

  BypassCtrl op1BypassCtrl;
  BypassCtrl op2BypassCtrl;
  logic isDataHazard;

  modport Controller(
    input clk,
    input rst,
    output isDataHazard,
    output op1BypassCtrl,
    output op2BypassCtrl
  );

  modport DataHazard(
    input isDataHazard
  );

  //modport ExecuteStage(
  modport DecodeStage(
    input op1BypassCtrl,
    input op2BypassCtrl
  );

endinterface : ControllerIF
