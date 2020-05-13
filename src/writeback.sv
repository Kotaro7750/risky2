`timescale 1ns / 1ps

module writeback(
  WriteBackStageIF.ThisStage port,
  MemoryAccessStageIF.NextStage prev,
  //output var [31:0]WD_pc,
  RegisterFileIF.WriteBackStage registerFile,
  DebugIF.WriteBackStage debug
);

  logic [31:0]writeback_data;

  always_ff@(posedge port.clk) begin
    if (prev.nextStage.rdCtrl.wEnable) begin
      if (prev.nextStage.is_load) $display("0x%4h: ", prev.nextStage.pc,"x%02d",prev.nextStage.rdCtrl.rdAddr," = ","0x%08h",writeback_data," 0x%08h",writeback_data," <- ","mem[0x%08h]",prev.nextStage.alu_result);
      else $display("0x%4h: ", prev.nextStage.pc,"x%02d",prev.nextStage.rdCtrl.rdAddr," = ","0x%08h",writeback_data);
    end 
  end

  //assign  WD_pc = prev.nextStage.pc;
  assign  registerFile.pc = prev.nextStage.pc;
  assign  registerFile.wData = writeback_data;
  assign registerFile.rdCtrl = prev.nextStage.rdCtrl;

  assign debug.writeBackStage = prev.nextStage;

  writeback_gen writeback_gen(
    .is_load(prev.nextStage.is_load),
    .mem_r_data(prev.nextStage.r_data),
    .alu_result(prev.nextStage.alu_result),
    .writeback_data(writeback_data)
  );
endmodule
