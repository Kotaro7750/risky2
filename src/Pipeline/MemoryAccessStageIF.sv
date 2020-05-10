import PipelineTypes::*;

interface MemoryAccessStageIF(
  input var logic clk,
  input var logic rst
);
  
  WriteBackStagePipeReg nextStage;

  modport ThisStage(
    input clk,
    input rst,
    output nextStage
  );

  modport NextStage(
    input nextStage
  );

endinterface : MemoryAccessStageIF

