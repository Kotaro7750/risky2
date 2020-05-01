`timescale 1ns / 1ps

module execute(
  input var bit clk,
  input var bit rstd,
  input var [31:0]pc, //現在処理している命令のpc
  input var [31:0]src1_data, //第一オペランドデータ
  input var [31:0]src2_data, //第二オペランドデータ
  input var [4:0]rd_addr,
  input var bit w_enable,
  input var [31:0]imm, //即値
  input var [5:0]alu_code, //演算種別
  input var [1:0]alu_op1_type, //第一オペランド種別
  input var [1:0]alu_op2_type, //第二オペランド種別
  input var bit is_load,
  input var bit is_store,
  output var [31:0]EM_pc, //デバッグ用
  output var [31:0]EM_alu_result, //演算結果
  output var [31:0]EM_w_data, //load書き込みデータ
  output var [1:0]EM_mem_access_width, //メモリアクセス幅
  output var [4:0]EM_rd_addr,
  output var logic EM_w_enable,
  output var logic EM_is_store,
  output var logic EM_is_load,
  output var logic EM_is_load_unsigned,
  output var [31:0]EM_irreg_pc
);

  logic [31:0]alu_op1;
  logic [31:0]alu_op2;
  logic [31:0]npc_op1;
  logic [31:0]npc_op2;
  logic [31:0]alu_result;
  logic [1:0]mem_access_width;
  logic [31:0]irreg_pc;
  logic is_branch;
  logic br_taken;

  always_ff@(negedge clk) begin
    if (rstd == 1'b0) begin
      EM_pc <= 32'd0;
      EM_alu_result <= 32'd0;
      EM_w_data <= 32'd0;
      EM_mem_access_width <= 2'd0;
      EM_rd_addr <= 5'd0;
      EM_w_enable <= `DISABLE;
      EM_is_store <= `DISABLE;
      EM_is_load <= `DISABLE;
      EM_is_load_unsigned <= `DISABLE;
      EM_irreg_pc <= 32'd0;
    end
    else begin
      EM_pc <= pc;
      EM_alu_result <= alu_result;
      EM_w_data <= src2_data;
      EM_mem_access_width <= mem_access_width;
      EM_rd_addr <= rd_addr;
      EM_w_enable <= w_enable;
      EM_is_store <= is_store;
      EM_is_load <= is_load;
      EM_is_load_unsigned <= is_load_unsigned;
      EM_irreg_pc <= irreg_pc;
    end
  end

  exec_switcher exec_switcher(
    .pc(pc),
    .rs1(src1_data),
    .rs2(src2_data),
    .imm(imm),
    .alu_code(alu_code),
    .alu_op1_type(alu_op1_type),
    .alu_op2_type(alu_op2_type),
    .alu_op1(alu_op1),
    .alu_op2(alu_op2),
    .npc_op1(npc_op1),
    .npc_op2(npc_op2)
  );

  alu alu(
    .alucode(alu_code),
    .op1(alu_op1),
    .op2(alu_op2),
    .alu_result(alu_result),
    .is_branch(is_branch),
    .br_taken(br_taken),
    .mem_access_width(mem_access_width),
    .is_load_unsigned(is_load_unsigned)
  );

  irreg_pc_gen irreg_pc_gen(
    .op1(npc_op1),
    .op2(npc_op2),
    .br_taken(br_taken),
    .is_branch(is_branch),
    .irreg_pc(irreg_pc)
  );

endmodule
