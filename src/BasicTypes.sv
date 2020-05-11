package BasicTypes;
  typedef logic [31:0] PC;
  typedef logic [31:0] BasicData;
  typedef logic [31:0] Instruction;
  typedef logic [4:0] RegAddr;
  typedef logic [31:0] MemAddr;

  typedef enum logic [5:0] {
    ALU_LUI  = 6'd0,
    ALU_JAL  = 6'd1,
    ALU_JALR = 6'd2,
    ALU_BEQ  = 6'd3,
    ALU_BNE  = 6'd4,
    ALU_BLT  = 6'd5,
    ALU_BGE  = 6'd6,
    ALU_BLTU = 6'd7,
    ALU_BGEU = 6'd8,
    ALU_LB   = 6'd9,
    ALU_LH   = 6'd10,
    ALU_LW   = 6'd11,
    ALU_LBU  = 6'd12,
    ALU_LHU  = 6'd13,
    ALU_SB   = 6'd14,
    ALU_SH   = 6'd15,
    ALU_SW   = 6'd16,
    ALU_ADD  = 6'd17,
    ALU_SUB  = 6'd18,
    ALU_SLT  = 6'd19,
    ALU_SLTU = 6'd20,
    ALU_XOR  = 6'd21,
    ALU_OR   = 6'd22,
    ALU_AND  = 6'd23,
    ALU_SLL  = 6'd24,
    ALU_SRL  = 6'd25,
    ALU_SRA  = 6'd26,
    ALU_NOP  = 6'd63
  } ALUCode;

  typedef enum logic [1:0] {
    OP_TYPE_NONE = 2'd0,
    OP_TYPE_REG  = 2'd1,
    OP_TYPE_IMM  = 2'd2,
    OP_TYPE_PC   = 2'd3
  } ALUOpType;

  typedef struct packed {
    ALUCode aluCode;
    ALUOpType aluOp1Type;
    ALUOpType aluOp2Type;
  } ALUCtrl;
endpackage
