package BasicTypes;
  typedef logic [31:0] PC;
  typedef logic [31:0] BasicData;
  typedef logic [31:0] Instruction;
  typedef logic [4:0] RegAddr;
  typedef logic [31:0] MemAddr;

  typedef enum logic [3:0] {
    ALU_ADD,
    ALU_SUB,
    ALU_SLT,
    ALU_SLTU,
    ALU_XOR,
    ALU_OR,
    ALU_AND,
    ALU_SLL,
    ALU_SRL,
    ALU_SRA,
    ALU_JUMP,
    ALU_NONE
  } ALUCode;

  typedef enum logic [1:0] {
    OP_TYPE_NONE = 2'd0,
    OP_TYPE_REG  = 2'd1,
    OP_TYPE_IMM  = 2'd2,
    OP_TYPE_PC   = 2'd3
  } ALUOpType;

  typedef enum logic [2:0] {
    MULDIV_MUL,
    MULDIV_MULH,
    MULDIV_MULHSU,
    MULDIV_MULHU,
    MULDIV_DIV,
    MULDIV_DIVU,
    MULDIV_REM,
    MULDIV_REMU
  } MulDivCode;
  
  typedef struct packed {
    ALUCode aluCode;
    ALUOpType aluOp1Type;
    ALUOpType aluOp2Type;
  } ALUCtrl;

  typedef struct packed {
    logic wEnable;
    RegAddr rdAddr;
    logic isForwardable;
  } RDCtrl ;

  typedef enum logic [1:0]{
    BYPASS_NONE = 2'd0,
    BYPASS_EXEC = 2'd1,
    BYPASS_MEM = 2'd2
  } BypassCtrl;

  typedef enum logic [1:0] {
    MEM_NONE = 2'd0,
    MEM_BYTE = 2'd1,
    MEM_HALF = 2'd2,
    MEM_WORD = 2'd3
  } MemoryAccessWidth;
endpackage
