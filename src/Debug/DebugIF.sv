import BasicTypes::*;
import PipelineTypes::*;

interface DebugIF(
  input var logic clk,
  input var logic rst
);

  PC fetchStage;
  DecodeStagePipeReg decodeStage;
  ExecuteStagePipeReg executeStage;
  MemoryAccessStagePipeReg memoryAccessStage;
  WriteBackStagePipeReg writeBackStage;

  modport Debug(
    input clk,
    input rst,
    input fetchStage,
    input decodeStage,
    input executeStage,
    input memoryAccessStage,
    input writeBackStage
  );

  modport FetchStage(
    output fetchStage
  );

  modport DecodeStage(
    output decodeStage
  );

  modport ExecuteStage(
    output executeStage
  );

  modport MemoryAccessStage(
    output memoryAccessStage
  );

  modport WriteBackStage(
    output writeBackStage
  );

endinterface : DebugIF

