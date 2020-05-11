package PipelineTypes;

import BasicTypes::*;

typedef struct packed {
 PC pc;
 Instruction inst;
} DecodeStagePipeReg ;

typedef struct packed {
  PC pc;
  BasicData rs1_data;
  BasicData rs2_data;
  BasicData imm;
  RegAddr rd_addr;
  ALUCtrl aluCtrl;
  logic w_enable;
  logic is_store;
  logic is_load;
  logic is_halt;
} ExecuteStagePipeReg ;

typedef struct packed {
  PC pc;
  PC irreg_pc;
  BasicData alu_result;
  BasicData w_data;
  logic [1:0] mem_access_width;
  logic [4:0] rd_addr;
  logic w_enable;
  logic is_store;
  logic is_load;
  logic is_load_unsigned;
} MemoryAccessStagePipeReg ;

typedef struct packed {
  PC pc;
  PC irreg_pc;
  BasicData r_data;
  BasicData alu_result;
  logic is_load;
  logic w_enable;
  RegAddr rd_addr;
} WriteBackStagePipeReg ;

endpackage
