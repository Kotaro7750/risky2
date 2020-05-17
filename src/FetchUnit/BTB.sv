`timescale 1ns / 1ps
`include "../define.svh"

import BasicTypes::*;
import PipelineTypes::*;
import FetchUnitTypes::*;

//TODO パラメータ周り定数化
module BTB(
  input var logic clk,
  FetchStageIF.BTB fetch,
  ExecuteStageIF.BTB execute
);
  
  PC pc;
  logic isBranch;
  logic branchTaken;
  PC irregPc;

  logic wEnable;
  BTBEntry wBtbEntry;
  BTBIndex wBtbIndex;
  BTBEntry rBtbEntry;
  BTBIndex rBtbIndex;

  always_ff@(posedge clk) begin
    pc <= execute.pc;
    isBranch <= execute.isBranch;
    branchTaken <= execute.branchTaken;
    irregPc <= execute.irregPc;
  end

  generate
    BlockDualPortRAM #(
      .ENTRY_NUM(BTB_ENTRY_NUM),
      .ENTRY_BIT_SIZE($bits(BTBEntry))
    )
    btbArray(
      .clk(clk),
      .wEnable(wEnable),
      .wAddr(wBtbIndex),
      .wData(wBtbEntry),
      .rAddr(rBtbIndex),
      .rData(rBtbEntry)
    );
  endgenerate

  always_comb begin
    //if (execute.isBranch && execute.branchTaken) begin
    if (isBranch && branchTaken) begin
      wEnable = `ENABLE;
    end
    else begin
      wEnable = `DISABLE;
    end

    if (rBtbEntry.tag == ToBTB_Tag(fetch.pc)) begin
      fetch.btbHit = `ENABLE;
      fetch.btbPredictedPc = ToRawAddrFromBTB_PC(rBtbEntry.content,fetch.pc);
    end
    else begin
      fetch.btbHit = `DISABLE;
    end

    rBtbIndex = ToBTB_Index(fetch.pc);

    //wBtbIndex = ToBTB_Index(execute.pc);
    //wBtbEntry.tag = ToBTB_Tag(execute.pc);
    //wBtbEntry.content = ToBTB_Content(execute.irregPc);
    wBtbIndex = ToBTB_Index(pc);
    wBtbEntry.tag = ToBTB_Tag(pc);
    wBtbEntry.content = ToBTB_Content(irregPc);
  end
endmodule


