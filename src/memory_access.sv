`timescale 1ns / 1ps

module memory_access(
  input var [31:0]pc,
  input var bit clk,
  input var bit rstd,
  input var [31:0]irreg_pc,
  input var bit w_enable,
  input var [4:0]rd_addr,
  input var bit is_store,
  input var bit is_load,
  input var bit is_load_unsigned,
  input var [31:0]alu_result,
  input var [1:0]mem_access_width,
  input var [31:0]w_data,
  output var [31:0]MW_pc,
  output var [31:0]MW_irreg_pc,
  output var [31:0]MW_r_data,
  output var [31:0]MW_alu_result,
  output var logic MW_is_load,
  output var logic MW_w_enable,
  output var [4:0]MW_rd_addr,
  output var [7:0]uart,
  output var logic uart_we
);

  logic [31:0]line;
  logic [1:0]offset;
  logic [3:0]mem_w_enable;
  logic [31:0]shifted_w_data;

  logic [31:0]row_r_data;
  logic [31:0]r_data;
  logic hc_access;

  assign hc_access = (alu_result == `HARDWARE_COUNTER_ADDR && is_load) ? `ENABLE : `DISABLE;
  assign r_data = r_data_gen(row_r_data,mem_access_width,is_load_unsigned,offset,hc_access,hc_OUT_data);

  bram bram(
    .pc(pc),
    .clk(clk),
    .w_enable(mem_w_enable),
    .r_addr(line),
    .w_addr(line),
    .w_data(shifted_w_data),
    .row_addr(alu_result),
    .r_data(row_r_data)
  );

  always_ff@(negedge clk) begin
    MW_pc <= pc;
    MW_irreg_pc <= irreg_pc;
    MW_r_data <= r_data;
    MW_alu_result <= alu_result;
    MW_is_load <= is_load;
    MW_w_enable <= w_enable;
    MW_rd_addr <= rd_addr;
  end

  memory_ctl memory_ctl(
    .pc(pc),
    .clk(clk),
    .is_store(is_store),
    .is_load_unsigned(is_load_unsigned),
    .addr(alu_result),
    .mem_access_width(mem_access_width),
    .w_data(w_data),
    .w_enable(mem_w_enable),
    .line(line),
    .offset(offset),
    .shifted_w_data(shifted_w_data),
    .uart(uart),
    .uart_we(uart_we)
  );

  //ハードウェアカウンタ
  logic [31:0]hc_OUT_data;

  hardware_counter hardware_counter(
      .CLK_IP(clk),
      .RSTN_IP(rstd),
      .COUNTER_OP(hc_OUT_data)
  );


  function automatic [31:0] r_data_gen;
    input [31:0] row_r_data;
    input [1:0] mem_access_width;
    input is_load_unsigned;
    input [1:0] offset;
    input bit hc_access;
    input [31:0] hc_OUT_data;

    begin
      if (hc_access == `ENABLE && is_load) begin
        r_data_gen = hc_OUT_data;
      end
      else begin
        case (mem_access_width)
          `MEM_BYTE: begin
            r_data_gen = is_load_unsigned 
              ? ({32{1'b0}}) | ((row_r_data >> (offset * 8)) & 8'hff)
              : ({32{row_r_data[(offset+1) * 8 - 1]}} << 8) | ((row_r_data >> (offset * 8)) & 8'hff)
              ;
          end
          `MEM_HALF: begin
            r_data_gen = is_load_unsigned 
              ? ({32{1'b0}}) | ((row_r_data >> (offset * 8)) & 16'hffff)
              : ({32{row_r_data[(offset + 2) * 8  -1]}} << 16) | ((row_r_data >> (offset * 8)) & 16'hffff)
              ;
          end
          `MEM_WORD: begin
            r_data_gen = row_r_data;
          end
          default: begin
            r_data_gen = row_r_data;
          end
        endcase
      end
    end
  endfunction
endmodule
