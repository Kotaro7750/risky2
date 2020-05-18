import PipelineTypes::*;

interface MemoryAccessStageIF(
  input var logic clk,
  input var logic rst
);
  
  RDCtrl rdCtrl;

  PC pc;
  PC irregPc;
  PC predictedNextPC;
  logic isBranch;
  logic branchTaken;
  logic isBranchTakenPredicted;
  logic isNextPcPredicted;
  WriteBackStagePipeReg nextStage;

  modport ThisStage(
    input clk,
    input rst,
    output rdCtrl,
    output nextStage,
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

  //modport Controller(
  //  input rdCtrl
  //);

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

endinterface : MemoryAccessStageIF

