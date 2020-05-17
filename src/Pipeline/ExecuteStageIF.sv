import BasicTypes::*;
import PipelineTypes::*;

interface ExecuteStageIF(
  input var logic clk,
  input var logic rst
);

  PC pc;
  PC irregPc;
  PC predictedNextPC;
  logic isBranch;
  logic branchTaken;
  logic isBranchTakenPredicted;
  logic isNextPcPredicted;
  MemoryAccessStagePipeReg nextStage;

  RDCtrl rdCtrl;

  modport ThisStage(
    input clk,
    input rst,
    output nextStage,
    output rdCtrl,
    output isBranch,
    output branchTaken,
    output predictedNextPC,
    output isBranchTakenPredicted,
    output isNextPcPredicted,
    output pc,
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
    input predictedNextPC,
    input isBranchTakenPredicted,
    input isNextPcPredicted,
    input rdCtrl,
    input irregPc
  );

  modport BranchPredictor(
    input isBranch,
    input branchTaken
  );

  modport BTB(
    input pc,
    input isBranch,
    input branchTaken,
    input irregPc
  );

endinterface : ExecuteStageIF

