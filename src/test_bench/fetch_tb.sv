//
// fetch_tb
//
`define assert(name, signal, value) \
        if (signal !== value) begin \
            $display("ASSERTION FAILED in %s : signal is '%d' but expected '%d'", name, signal, value); \
            $finish; \
        end else begin \
            $display("\t%m: signal == value"); \
        end

`define test(name,  ex_FD_inst) \
        $display("%s:", name); \
        `assert("FD_inst", FD_inst, ex_FD_inst) \
        $display("%s test ...ok\n", name); \

`include "../define.svh"

module fetch_tb;
  logic clk;
  logic rstd;
  logic is_data_hazard;
  logic [31:0]irreg_pc;
  logic [31:0]raw_inst;
  logic [31:0]FD_inst;

  fetch fetch(
    .clk(clk),
    .rstd(rstd),
    .is_data_hazard(is_data_hazard),
    .irreg_pc(irreg_pc),
    .FD_inst(FD_inst)
  );

  initial begin
    clk = 1'b0;
    rstd = 1'b0;
    is_data_hazard = 1'b0;
    irreg_pc = 32'd0;
    raw_inst = `NOP;

    #50 
    rstd = 1'b1;
    // 32'hb50633 ADD [10, 11] [12] 0
    //ir = 32'hb50633; #10;
    //`test("ADD", ir, 10, 11, 12, 0, `ALU_ADD, `OP_TYPE_REG, `OP_TYPE_REG, `ENABLE, `DISABLE, `DISABLE, `DISABLE)

    #50
    raw_inst = `NON_BRANCH_A;

    #30
    raw_inst = `BRANCH_A;
    #20
    raw_inst = `NON_BRANCH_A;

    #40
    irreg_pc = 32'd1;

    $display("all decoder-tests passed!");
  end
  always #10 clk = ~clk;

endmodule
