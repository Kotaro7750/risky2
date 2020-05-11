import BasicTypes::*;
import PipelineTypes::*;

interface ExecuteStageIF(
  input var logic clk,
  input var logic rst
);

  PC irregPc;
  MemoryAccessStagePipeReg nextStage;

  RDCtrl rdCtrl;
  assign rdCtrl = nextStage.rdCtrl;

  modport ThisStage(
    input clk,
    input rst,
    output nextStage,
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

