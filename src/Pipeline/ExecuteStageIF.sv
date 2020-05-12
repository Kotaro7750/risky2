import BasicTypes::*;
import PipelineTypes::*;

interface ExecuteStageIF(
  input var logic clk,
  input var logic rst
);

  PC irregPc;
  logic branchTaken;
  logic isBranchTakenPredicted;
  MemoryAccessStagePipeReg nextStage;

  RDCtrl rdCtrl;

  modport ThisStage(
    input clk,
    input rst,
    output nextStage,
    output rdCtrl,
    output branchTaken,
    output isBranchTakenPredicted,
    output irregPc
  );

  modport NextStage(
    input nextStage
  );

  modport IrregularPC(
    input irregPc
  );

  modport Controller(
    input branchTaken,
    input isBranchTakenPredicted,
    input rdCtrl
  );

endinterface : ExecuteStageIF

