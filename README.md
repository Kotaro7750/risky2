# RISC-V32IM準拠 パイプラインプロセッサ risky2
## ステージ
Fetch,Decode,Execute,MemoryAccess,WriteBackの五段構成

## ベンチマーク
FPGAボード DIGILENT社製NEXYS VIDEOでの90MHz動作時

CoreMark

```
2K performance run parameters for coremark.
CoreMark Size    : 666
Total ticks      : 1557789755
Total time (secs): 17
Iterations/Sec   : 176
Iterations       : 3000
Compiler version : GCC9.2.0
Compiler flags   :
Memory location  : STACK
seedcrc          : 0xe9f5
[0]crclist       : 0xe714
[0]crcmatrix     : 0x1fd7
[0]crcstate      : 0x8e3a
[0]crcfinal      : 0xcc42
Correct operation validated. See readme.txt for run and reporting rules.
```
