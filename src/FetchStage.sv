`timescale 1ns / 1ps
`include "define.svh"

import BasicTypes::*;
import PipelineTypes::*;

//クロックエッジでinst_memからinstに命令取り込み、クロックエッジでパイプライン
//レジスタ、ストールフラグを更新する。
//現在フェッチした命令が分岐系ならその命令を次ステージに送った上で
//branch_hazardにする。この状態では、irreg_pcがwritebackステージのクロックエッ
//ジでセットされるまではNOPを送る。
//前の命令がデコードステージで真の依存を引き起こしたなら、data_hazardとなる。
//このとき前の命令を送り、pcは更新しない。
module FetchStage(
  FetchStageIF.ThisStage port,
  ControllerIF.DataHazard dataHazard,
  ControllerIF.FetchStage controller,
  ExecuteStageIF.IrregularPC irregularPC,
  BranchPredictorIF.FetchStage branchPredictor
);

  logic is_branch_hazard;
  PC pc;
  Instruction raw_inst;

  Instruction inst;

  DecodeStagePipeReg nextStage;
  assign port.nextStage = nextStage;

  //読み込みのみで、クロック同期なしで繋がっている。
  inst_mem inst_mem(
    .pc(pc),
    .inst(raw_inst)
  );

  //always_ff@(posedge port.clk) begin
  //  if (port.rst != 1'b0) begin
  //    //ストールしてないなら、普通にフェッチする
  //    if (!is_branch_hazard) begin
  //      inst <= raw_inst;
  //    end

  //    //ストールしているなら、前回の命令を滞留させる。ストール明けに使えるようにするため。
  //    else begin
  //      inst <= inst;
  //    end
  //  end
  //end
  assign inst = raw_inst;

  always_ff@(negedge port.clk) begin
    if (port.rst == 1'b0) begin
      pc <= 32'd0;
      is_branch_hazard <= 1'b0;
    end
    else 

    begin
      if (controller.isBranchPredictMiss == `ENABLE) begin
          nextStage.pc <= `NOP;
          nextStage.inst <= `NOP;
          nextStage.isBranchTakenPredicted <= `DISABLE;
          pc <= irregularPC.irregPc;
          is_branch_hazard <= `DISABLE;
      end

      //真の依存由来のハザードなら、ストールした上でpc、次の命令を滞留。NOPにし
      //ていないのは、デコーダが毎クロック命令を要求するから。
      else if (dataHazard.isDataHazard == `ENABLE) begin
        nextStage.pc <= nextStage.pc;
        nextStage.inst <= nextStage.inst;
        nextStage.isBranchTakenPredicted <= nextStage.isBranchTakenPredicted;
        pc <= pc;
      end
      //ストール中
      else if (is_branch_hazard) begin
        //wbから送られてくるirreg_pcが何らかの値ならストール終了。ストール終了時
        //にもNOPは出すことに注意。
        if (irregularPC.irregPc != 31'd0) begin
          nextStage.pc <= `NOP;
          nextStage.inst <= `NOP;
          nextStage.isBranchTakenPredicted <= `DISABLE;
          pc <= irregularPC.irregPc;
          is_branch_hazard <= `DISABLE;
        end
        //そうでないなら引き続きストールし、NOPを流す。便宜的にストール中は分岐
        //命令がフェッチされ続けるが、ストール解除後に上書きされるはず
        else begin
          nextStage.pc <= `NOP;
          nextStage.inst <= `NOP;
          nextStage.isBranchTakenPredicted <= `DISABLE;
          pc <= pc;
        end
      end

      else if (is_branch(raw_inst) == `ENABLE) begin
        if (branchPredictor.isBranchTakenPredicted == `ENABLE) begin
          nextStage.pc <= pc;
          nextStage.inst <= inst;
          nextStage.isBranchTakenPredicted <= branchPredictor.isBranchTakenPredicted;
          is_branch_hazard <= `ENABLE;
        end
        else begin
          nextStage.pc <= pc;
          nextStage.inst <= inst;
          nextStage.isBranchTakenPredicted <= branchPredictor.isBranchTakenPredicted;
          is_branch_hazard <= `DISABLE;
          pc <= pc + 4;
        end
      end
      //通常時に通常命令が来たら、pcをインクリメントし、次の命令を送り込む。
      else begin
        nextStage.pc <= pc;
        nextStage.inst <= inst;
        nextStage.isBranchTakenPredicted <= `DISABLE;
        pc <= pc + 4;
      end
    end
  end

  //ここで分岐命令かチェックする。
  //分岐命令はJAL,JALR,Beq,Bne,Blt,Bge,Bltu,Bgeuで、これらはすべて7bit目が1
  function automatic [0:0] is_branch(input Instruction inst);
    begin
      //0始まり
      if (inst[6] == 1'b0) begin
        is_branch = `DISABLE;
      end
      else begin
        is_branch = `ENABLE;
      end
    end
  endfunction
endmodule
