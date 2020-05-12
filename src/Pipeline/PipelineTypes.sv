package PipelineTypes;

import BasicTypes::*;

typedef struct packed {
  PC pc;
  Instruction inst;
  logic isBranchTakenPredicted;
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
  logic isStore;
  logic isLoad;
  logic isHalt;
} ExecuteStagePipeReg ;

typedef struct packed {
  PC pc;
  PC irregPc;
  BasicData aluResult;
  BasicData wData;
  logic [1:0] memAccessWidth;
  RDCtrl rdCtrl;
  logic isStore;
  logic isLoad;
  logic isLoadUnsigned;
} MemoryAccessStagePipeReg ;

typedef struct packed {
  PC pc;
  PC irreg_pc;
  BasicData r_data;
  BasicData alu_result;
  logic is_load;
  RDCtrl rdCtrl;
} WriteBackStagePipeReg ;

endpackage
