import PipelineTypes::*;

interface DecodeStageIF(
  input var logic clk,
  input var logic rst
);

  logic isDataHazard;
  ExecuteStagePipeReg nextStage;

  modport ThisStage(
    input clk,
    input rst,
    output isDataHazard,
    output nextStage
  );

  modport NextStage(
    input nextStage
  );
  
  modport DataHazard(
    input isDataHazard
  );

endinterface : DecodeStageIF

