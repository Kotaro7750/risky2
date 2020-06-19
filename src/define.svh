`define ENABLE  1'b1
`define DISABLE 1'b0

//条件分岐確定ステージ
`define BRANCH_M 
//BTB使うのか
//`define USE_BTB

//fetchデバッグ用
`define NOP 32'd0
`define NON_BRANCH_A 32'b00000000000000000000000010000000 //1に書き込み
`define NON_BRANCH_B 32'b00000000000000001000000100000000 //rs1がAに依存
`define NON_BRANCH_C 32'b00000000000100000000000110000000 //rs2がAに依存
`define BRANCH_A     32'b00000000000000000000001001000000 //rs1がAに依存
`define BRANCH_B     32'b00000000000000001000001011000000 //rs1がAに依存
`define BRANCH_C     32'b00000000000100000000001101000000 //rs2がAに依存

// 命令形式
`define TYPE_NONE 3'd0
`define TYPE_U    3'd1
`define TYPE_J    3'd2
`define TYPE_I    3'd3
`define TYPE_B    3'd4
`define TYPE_S    3'd5
`define TYPE_R    3'd6

// OPコード
`define LUI    7'b0110111
`define AUIPC  7'b0010111
`define JAL    7'b1101111
`define JALR   7'b1100111
`define BRANCH 7'b1100011
`define LOAD   7'b0000011
`define STORE  7'b0100011
`define OPIMM  7'b0010011
`define OP     7'b0110011

// DSTレジスタの有無
`define REG_NONE 1'd0
`define REG_RD   1'd1

//メモリアクセス幅
`define MEM_NONE 2'd0
`define MEM_BYTE 2'd1
`define MEM_HALF 2'd2
`define MEM_WORD 2'd3

// パイプラインステージ
`define IF_STAGE 3'd0
`define D_STAGE 3'd1
`define EX_STAGE 3'd2
`define MA_STAGE 3'd3
`define RW_STAGE 3'd4

// address for hardware counter
`define HARDWARE_COUNTER_ADDR 32'hffffff00

// address for UART
`define UART_ADDR 32'hf6fff070
