import PipelineTypes::*;
import BasicTypes::*;

interface DecodeStageIF(
  input var logic clk,
  input var logic rst
);

  RegAddr rs1Addr;
  RegAddr rs2Addr;
  ALUOpType aluOp1Type;
  ALUOpType aluOp2Type;
  logic isStore;

  ExecuteStagePipeReg nextStage;

  modport ThisStage(
    input clk,
    input rst,
    output aluOp1Type,
    output aluOp2Type,
    output rs1Addr,
    output rs2Addr,
    output isStore,
    output nextStage
  );

  modport NextStage(
    input nextStage
  );
  
  modport Controller(
    input aluOp1Type,
    input aluOp2Type,
    input rs1Addr,
    input rs2Addr,
    input isStore
  );

endinterface : DecodeStageIF

