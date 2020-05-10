import PipelineTypes::*;

interface FetchStageIF(
  input var logic clk,
  input var logic rst
);

  DecodeStagePipeReg nextStage;

  modport ThisStage(
    input clk,
    input rst,
    output nextStage
  );

  modport NextStage(
    input nextStage
  );

endinterface : FetchStageIF

