package PipelineTypes;

import BasicTypes::*;

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
  BypassCtrl op1BypassCtrl;
  BypassCtrl op2BypassCtrl;
  BasicData imm;
  RDCtrl rdCtrl;
  ALUCtrl aluCtrl;
  logic isBranchTakenPredicted;
  logic isNextPcPredicted;
  PC predictedNextPC;
  logic isStore;
  logic isLoad;
  logic isHalt;
} ExecuteStagePipeReg ;

typedef struct packed {
  PC pc;
  BasicData aluResult;
  BasicData wData;
  logic [1:0] memAccessWidth;
  RDCtrl rdCtrl;
  logic isBranch;
  logic branchTaken;
  logic isBranchTakenPredicted;
  logic isNextPcPredicted;
  PC predictedNextPC;
  PC irregPc;
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
