`include "../define.svh"
import PipelineTypes::*;

interface MemoryAccessStageIF(
  input var logic clk,
  input var logic rst
);
  
  RDCtrl rdCtrl;

`ifdef BRANCH_M
  PC pc;
  PC irregPc;
  PC predictedNextPC;
  logic isBranch;
  logic branchTaken;
  logic isBranchTakenPredicted;
  logic isNextPcPredicted;
`endif
  WriteBackStagePipeReg nextStage;

  modport ThisStage(
    input clk,
    input rst,
    output rdCtrl,
  `ifdef BRANCH_M
    output isBranch,
    output branchTaken,
    output predictedNextPC,
    output isBranchTakenPredicted,
    output isNextPcPredicted,
    output pc,
    output irregPc,
  `endif
    output nextStage
  );

`ifdef BRANCH_M
  modport IrregularPC(
    input irregPc
  );
`endif

  modport NextStage(
    input nextStage
  );

  modport Controller(
  `ifdef BRANCH_M
    input branchTaken,
    input predictedNextPC,
    input isBranchTakenPredicted,
    input isNextPcPredicted,
    input irregPc,
  `endif
    input rdCtrl
  );

  
`ifdef BRANCH_M
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
`endif

endinterface : MemoryAccessStageIF

