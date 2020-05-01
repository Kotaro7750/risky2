`timescale 1ns / 1ps

module risky2_tb;
  reg clk;
  reg rstd;

  risky2 risky2(clk,rstd);

  initial begin
    rstd <= 1;
    clk <= 0;
    #50;
    rstd <= 0;
    #20;
    rstd <= 1;

    #410265408 $finish;
    
  end

	always #10 clk = ~clk;

endmodule
