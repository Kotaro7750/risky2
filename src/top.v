module top(sysclk,cpu_resetn,uart_tx);
  input sysclk;
  input cpu_resetn;
  output uart_tx;
  risky2 risky2(sysclk,cpu_resetn,uart_tx);
endmodule
