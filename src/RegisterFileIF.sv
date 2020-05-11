import BasicTypes::*;
import PipelineTypes::*;

interface RegisterFileIF(
  input var logic clk,
  input var logic rst
);

  RegAddr rs1Addr;
  RegAddr rs2Addr;
  BasicData rs1Data;
  BasicData rs2Data;
  logic rs1Ready;
  logic rs2Ready;

  BasicData wData;
  RDCtrl rdCtrl;

  RegAddr prevRdAddr;
  logic prevWEnable;

  modport RegisterFile(
    input clk,
    input rst,
    input rs1Addr,
    input rs2Addr,
    input rdCtrl,
    input wData,
    input prevWEnable,
    input prevRdAddr,
    output rs1Data,
    output rs2Data,
    output rs1Ready,
    output rs2Ready
  );

  modport DecodeStage(
    output rs1Addr,
    output rs2Addr,
    output prevRdAddr,
    output prevWEnable,
    input rs1Data,
    input rs2Data
  );
  
  modport WriteBackStage(
    output wData,
    output rdCtrl
  );

  modport Controller(
    input rs1Ready,
    input rs2Ready
  );

endinterface : RegisterFileIF
