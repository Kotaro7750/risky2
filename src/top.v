`timescale 1ns / 1ps

`include "define.svh"
module top(sysclk,cpu_resetn,uart_tx);
input sysclk;
input cpu_resetn;
output uart_tx;
risky2 risky2(sysclk,cpu_resetn,uart_tx);
endmodule
