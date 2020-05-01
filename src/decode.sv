`timescale 1ns / 1ps
`include "define.svh"

//Dステージと、WBステージで使用。
module decode(
  input var [31:0]pc,
  input var clk,
  input var rstd,
  input var [31:0]inst, //パイプラインレジスタからの配線
  input var logic w_enable_WB, //WBで書き込むかどうか
  input var [4:0]w_addr_WB, //WBで書き込むアドレス
  input var [31:0]w_data_WB, //WBで書き込むデータ
  input var [31:0]pc_WB,
  output var bit is_data_hazard, //このクロックでデコードした命令がデータハザードを起こすか
  //output var logic is_data_hazard, //このクロックでデコードした命令がデータハザードを起こすか
  output var [31:0]DE_pc,
  output var [31:0]DE_rs1_data,
  output var [31:0]DE_rs2_data,
  output var [31:0]DE_imm,
  output var [4:0]DE_rd_addr,
  output var [5:0]DE_alu_code,
  output var [1:0]DE_alu_op1_type,
  output var [1:0]DE_alu_op2_type,
  output var logic DE_w_enable,
  output var logic DE_is_store,
  output var logic DE_is_load,
  output var logic DE_is_halt
);
  
  logic [4:0]rs1_addr; //rs1アドレス
  logic [4:0]rs2_addr; //rs2アドレス
  logic [4:0]rd_addr; //rdアドレス
  logic [31:0]imm; //即値
  logic [5:0]alu_code; //aluコード
  logic [1:0]alu_op1_type; //オペランド1タイプ
  logic [1:0]alu_op2_type; //オペランド2タイプ
  logic reg_w_enable; //書き込みの有無
  logic is_load; //ロード命令かどうか
  logic is_store; //ストア命令かどうか
  logic is_halt; //haltかどうか
  logic rs1_ready; //rs1が使用可能か
  logic rs2_ready; //rs2が使用可能か

  logic [31:0]rs1_data; //rs1のデータ
  logic [31:0]rs2_data; //rs2のデータ

  //rs1またはrs2について、命令がレジスタを使用し、かつreadyがdisableならハザー
  //ド
  assign is_data_hazard = is_data_hazard_gen(rs1_ready,rs2_ready,alu_op1_type,alu_op2_type,is_store);

  function bit is_data_hazard_gen;
    input bit rs1_ready;
    input bit rs2_ready;
    input [1:0]alu_op1_type;
    input [1:0]alu_op2_type;
    input bit is_store;
  begin
    if (is_store == `ENABLE) begin
      is_data_hazard_gen = ((rs1_ready == `DISABLE && alu_op1_type == `OP_TYPE_REG) || (rs2_ready == `DISABLE)) ? `ENABLE : `DISABLE;
    end
    else begin
      is_data_hazard_gen = ((rs1_ready == `DISABLE && alu_op1_type == `OP_TYPE_REG) || (rs2_ready == `DISABLE && alu_op2_type == `OP_TYPE_REG)) ? `ENABLE : `DISABLE; 
    end
  end
endfunction
  

  //クロック同期ではなく、入力によってデコード結果を垂れ流すだけ。意味付けは
  //decodeで行う。
  decoder decoder(
    //input
    .inst_b(inst), //命令ビット列
    //output
    .src1_reg(rs1_addr), //rs1のアドレス
    .src2_reg(rs2_addr), //rs2のアドレス
    .dst_reg(rd_addr), //rdのアドレス
    .imm(imm), //即値
    .alu_code(alu_code), //aluコード
    .alu_op1_type(alu_op1_type), //オペランド1のタイプ
    .alu_op2_type(alu_op2_type), //オペランド2のタイプ
    .reg_w_enable(reg_w_enable), //書き込みの有無
    .is_load(is_load), //ロード命令かどうか
    .is_store(is_store), //ストア命令かどうか
    .is_halt(is_halt) //haltかどうか
  );

  register register(
    //input
    .pc_WB(pc_WB),
    .clk(clk),
    .rstd(rstd),
    .rs1_addr(rs1_addr),
    .rs2_addr(rs2_addr),
    .wb_enable(w_enable_WB),
    .wb_addr(w_addr_WB),
    .wb_data(w_data_WB),
    .prev_w_enable(DE_w_enable),
    .prev_rd_addr(DE_rd_addr),
    //output
    .rs1_data(rs1_data),
    .rs2_data(rs2_data),
    .rs1_ready(rs1_ready),
    .rs2_ready(rs2_ready)
  );

  always_ff@(negedge clk) begin
    if (rstd == 1'b0) begin
      DE_pc <= `NOP;
      DE_rs1_data <= `NOP;
      DE_rs2_data <= `NOP;
      DE_imm <= `NOP;
      DE_rd_addr <= `NOP;
      DE_alu_code <= `ALU_NOP;
      DE_alu_op1_type <= `OP_TYPE_NONE;
      DE_alu_op2_type <= `OP_TYPE_NONE;
      DE_w_enable <= `DISABLE;
      DE_is_store <= `DISABLE;
      DE_is_load <= `DISABLE;
      DE_is_halt <= `DISABLE;
    end

    if (is_data_hazard == `ENABLE) begin
      DE_pc <= `NOP;
      DE_rs1_data <= `NOP;
      DE_rs2_data <= `NOP;
      DE_imm <= `NOP;
      DE_rd_addr <= `NOP;
      DE_alu_code <= `ALU_NOP;
      DE_alu_op1_type <= `OP_TYPE_NONE;
      DE_alu_op2_type <= `OP_TYPE_NONE;
      DE_w_enable <= `DISABLE;
      DE_is_store <= `DISABLE;
      DE_is_load <= `DISABLE;
      DE_is_halt <= `DISABLE;
    end

    else begin
      DE_pc <= pc;
      DE_rs1_data <= rs1_data;
      DE_rs2_data <= rs2_data;
      DE_imm <= imm;
      DE_rd_addr <= rd_addr;
      DE_alu_code <= alu_code;
      DE_alu_op1_type <= alu_op1_type;
      DE_alu_op2_type <= alu_op2_type;
      DE_w_enable <= reg_w_enable;
      DE_is_store <= is_store;
      DE_is_load <= is_load;
      DE_is_halt <= is_halt;
    end
  end
endmodule
