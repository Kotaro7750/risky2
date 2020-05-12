import BasicTypes::*;
import PipelineTypes::*;

interface BypassNetworkIF(
  input var logic clk,
  input var logic rst
);

  BasicData ExwData;
  BasicData MemwData;

  BasicData BypassExData;
  BasicData BypassMemData;
  assign BypassExData = ExwData;
  assign BypassMemData = MemwData;

  modport ExecuteStage(
    input BypassExData,
    input BypassMemData,
    output ExwData
  );

  modport MemoryAccessStage(
    output MemwData
  );

endinterface : BypassNetworkIF

