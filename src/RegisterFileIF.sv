import BasicTypes::*;
import PipelineTypes::*;

interface RegisterFileIF(
  input var logic clk,
  input var logic rst
);

  PC pc;

  RegAddr rs1Addr;
  RegAddr rs2Addr;
  BasicData rs1Data;
  BasicData rs2Data;

  BasicData wData;
  RDCtrl rdCtrl;

  modport RegisterFile(
    input clk,
    input rst,
    input pc,
    input rs1Addr,
    input rs2Addr,
    input rdCtrl,
    input wData,
    output rs1Data,
    output rs2Data
  );

  modport DecodeStage(
    output rs1Addr,
    output rs2Addr,
    input rs1Data,
    input rs2Data
  );
  
  modport WriteBackStage(
    output pc,
    output wData,
    output rdCtrl
  );

endinterface : RegisterFileIF

