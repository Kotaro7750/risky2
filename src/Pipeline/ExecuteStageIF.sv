import BasicTypes::*;
import PipelineTypes::*;

interface ExecuteStageIF(
  input var logic clk,
  input var logic rst
);

  PC irregPc;
  MemoryAccessStagePipeReg nextStage;

  RDCtrl rdCtrl;

  modport ThisStage(
    input clk,
    input rst,
    output nextStage,
    output rdCtrl,
    output irregPc
  );

  modport NextStage(
    input nextStage
  );

  modport IrregularPC(
    input irregPc
  );

  modport Controller(
    input rdCtrl
  );

endinterface : ExecuteStageIF

