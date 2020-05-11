import PipelineTypes::*;

interface MemoryAccessStageIF(
  input var logic clk,
  input var logic rst
);
  
  RDCtrl rdCtrl;

  WriteBackStagePipeReg nextStage;

  modport ThisStage(
    input clk,
    input rst,
    output rdCtrl,
    output nextStage
  );

  modport NextStage(
    input nextStage
  );

  modport Controller(
    input rdCtrl
  );

endinterface : MemoryAccessStageIF

