//op1_ready,op2_readyはただデコードされたレジスタがreadyであるかだけではなく、
//aluオペランドタイプなどを踏まえて、実際に使われるかどうかも含んだもの。
module forward_arbiter(
  input var logic op1_ready,
  input var logic op2_ready,
  input var [4:0]rs1_addr,
  input var [4:0]rs2_addr,
  input var [4:0]FWD_E_addr,
  input var [4:0]FWD_M_addr,
  input var [4:0]FWD_W_addr,
  output var is_data_hazard,
  output var [1:0]rs1_forward_selector,
  output var [1:0]rs2_forward_selector
);
  logic op1_data_hazard;
  logic op2_data_hazard;

  assign is_data_hazard = op1_data_hazard || op2_data_hazard;

  always_comb begin
    if (op1_ready == `DISABLE) begin
      //caseは上の方から優先されるので明示的にEを先頭に。これはより最近の命令
      //の書き込みをフォワードさせてやるからである。
      case (rs1_addr)
        FWD_E_addr: begin
          rs1_forward_selector = `FWD_E;
          op1_data_hazard = `DISABLE;
        end

        FWD_M_addr: begin
          rs1_forward_selector = `FWD_M;
          op1_data_hazard = `DISABLE;
        end

        FWD_W_addr: begin
          rs1_forward_selector = `FWD_W;
          op1_data_hazard = `DISABLE;
        end

        default : begin
          rs1_forward_selector = `FWD_NONE;
          op1_data_hazard = `ENABLE;
        end
      endcase
    end
    else begin
      rs1_forward_selector = `FWD_NONE;
      op1_data_hazard = `DISABLE;
    end

    if (op2_ready == `DISABLE) begin
      //caseは上の方から優先されるので明示的にEを先頭に。これはより最近の命令
      //の書き込みをフォワードさせてやるからである。
      case (rs2_addr)
        FWD_E_addr: begin
          rs2_forward_selector = `FWD_E;
          op2_data_hazard = `DISABLE;
        end

        FWD_M_addr: begin
          rs2_forward_selector = `FWD_M;
          op2_data_hazard = `DISABLE;
        end

        FWD_W_addr: begin
          rs2_forward_selector = `FWD_W;
          op2_data_hazard = `DISABLE;
        end

        default : begin
          rs2_forward_selector = `FWD_NONE;
          op2_data_hazard = `ENABLE;
        end
      endcase
    end

    else begin
      rs2_forward_selector = `FWD_NONE;
      op2_data_hazard = `DISABLE;
    end
  end
endmodule
