import BasicTypes::*;
import PipelineTypes::*;

interface RegisterFileIF(
  input var logic clk,
  input var logic rst
);

  BasicData wData;
  RegAddr rdAddr;
  logic wEnable;

  modport RegisterFile(
    input clk,
    input rst
  );

  modport DecodeStage(
    input wData,
    input rdAddr,
    input wEnable
  );
  
  modport WriteBackStage(
    output wData,
    output rdAddr,
    output wEnable
  );

endinterface : RegisterFileIF

