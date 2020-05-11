import BasicTypes::*;
import PipelineTypes::*;

interface ControllerIF(
  input var logic clk,
  input var logic rst
);

  logic isDataHazard;

  modport Controller(
    input clk,
    input rst,
    output isDataHazard
  );

  modport DataHazard(
    input isDataHazard
  );

endinterface : ControllerIF
