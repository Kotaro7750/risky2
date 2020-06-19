`timescale 1ns / 1ps

module risky2_tb;
  reg clk;
  reg rstd;
  //reg [63:0] product;

  risky2 risky2(clk,rstd);
  //design_1_wrapper  design_1_wrapper(
  //  .sysclk(clk),
  //  .cpu_resetn(rstd)
  //);
//Multiplier Multiplier(
//  .signOp1(1'b0),
//  .op1(32'h29a),
//  .signOp2(1'b0),
//  .op2(32'h1),
//  .product(product)
//);

  initial begin
    rstd <= 1;
    clk <= 0;
    #50;
    rstd <= 0;
    #20;
    rstd <= 1;

    #1000000000 $finish;
    
  end

	always #5 clk = ~clk;

endmodule
