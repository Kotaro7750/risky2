`include "../define.svh"
package PipelineTypes;

import BasicTypes::*;
import OpTypes::*;

typedef struct packed {
  PC pc;
  Instruction inst;
  logic isBranchTakenPredicted;
  logic isNextPcPredicted;
  PC predictedNextPC;
} DecodeStagePipeReg ;

typedef struct packed {
  PC pc;
  BasicData rs1Data;
  BasicData rs2Data;
  RegAddr rdAddr;
  BypassCtrl op1BypassCtrl;
  BypassCtrl op2BypassCtrl;
  BasicData imm;
  OpInfo opInfo;
  logic isBranchTakenPredicted;
  logic isNextPcPredicted;
  PC predictedNextPC;
} ExecuteStagePipeReg ;

typedef struct packed {
  PC pc;
  BasicData aluResult;
  BasicData wData;
  logic [1:0] memAccessWidth;
  RDCtrl rdCtrl;
`ifdef BRANCH_M
  logic isBranch;
  logic branchTaken;
  logic isBranchTakenPredicted;
  logic isNextPcPredicted;
  PC predictedNextPC;
  PC irregPc;
`endif
  logic isStore;
  logic isLoad;
  logic isLoadUnsigned;
} MemoryAccessStagePipeReg ;

typedef struct packed {
  PC pc;
  BasicData r_data;
  BasicData alu_result;
  logic is_load;
  RDCtrl rdCtrl;
} WriteBackStagePipeReg ;

endpackage
