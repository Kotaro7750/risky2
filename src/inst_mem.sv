`timescale 1ns / 1ps

module inst_mem(
  input var logic clk,
  input var [31:0]pc,
  output var [31:0]inst
);
  logic [31:0] instRAM [0:32767];             //32bitレジスタ*32

  //always_ff@(posedge clk) begin
  //  inst <= instRAM[pc >> 2];
  //end

  assign inst = instRAM[pc >> 2];
  //initial $readmemh("/home/koutarou/develop/risky2/benchmarks/tests/IntRegReg/code.hex",instRAM);
  //initial $readmemh("/home/koutarou/develop/risky2/benchmarks/tests/IntRegImm/code.hex",instRAM);
  //initial $readmemh("/home/koutarou/develop/risky2/benchmarks/tests/ZeroRegister/code.hex",instRAM);
  //initial $readmemh("/home/koutarou/develop/risky2/benchmarks/tests/ControlTransfer/code.hex",instRAM);
  //initial $readmemh("/home/koutarou/develop/risky2/benchmarks/tests/LoadAndStore/code.hex",instRAM);
  //initial $readmemh("/home/koutarou/develop/risky2/benchmarks/tests/Uart/code.hex",instRAM);
  //initial $readmemh("/home/koutarou/develop/risky2/benchmarks/tests/HardwareCounter/code.hex",instRAM);
  initial $readmemh("/home/koutarou/develop/risky2/benchmarks/Coremark_for_Synthesis/prog.hex",instRAM);
  //initial $readmemh("/home/koutarou/develop/risky2/benchmarks/Coremark_for_Synthesis_for_debug/prog.hex",instRAM);
  //initial $readmemh("/home/koutarou/develop/risky2/benchmarks/template/code.hex",instRAM);
  //initial $readmemh("/home/koutarou/develop/risky2/benchmarks/Coremark/prog.hex",instRAM);
endmodule
