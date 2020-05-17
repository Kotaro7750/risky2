import PipelineTypes::*;

interface FetchStageIF(
  input var logic clk,
  input var logic rst
);

  PC pc;
  PC btbPredictedPc;
  logic btbHit;
  DecodeStagePipeReg nextStage;

  modport ThisStage(
    input clk,
    input rst,
    input btbHit,
    input btbPredictedPc,
    output pc,
    output nextStage
  );

  modport NextStage(
    input nextStage
  );

  modport BTB(
    input pc,
    output btbHit,
    output btbPredictedPc
  );

endinterface : FetchStageIF

