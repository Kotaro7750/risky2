`timescale 1ns / 1ps

//クロックエッジで書き込み、読み込みは同期なしのレジスタファイル
module RegisterFile(
  input var [31:0] pc,
  RegisterFileIF.RegisterFile port
);

  logic  [31:0] registerFile[0:31];

  assign port.rs1Data = port.rs1Addr == 5'd0 ? 32'd0 : registerFile[port.rs1Addr];
  assign port.rs2Data = port.rs2Addr == 5'd0 ? 32'd0 : registerFile[port.rs2Addr];

  always_ff @(negedge port.rst or posedge port.clk) begin
    if (port.rst == 0) begin
      for (integer i = 0; i < 32; i = i+1) begin
        registerFile[i] <= 32'h00000000;
      end
    end
    else if (port.rdCtrl.wEnable == 1) begin
      registerFile[port.rdCtrl.rdAddr] <= port.wData;
    end
  end
endmodule
