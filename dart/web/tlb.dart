library tlb;

import 'dart:html';

class TLB {
  bool valid;
  Int32Array entryHi;
  Int32Array entryLo1;
  Int32Array entryLo0;
  Int32Array pageMask;
  Int32Array loCompare;
  Int32Array myHiMask;

  TLB() :
    valid = false,
    entryHi = new Int32Array(1),
    entryLo1 = new Int32Array(1),
    entryLo0 = new Int32Array(1),
    pageMask = new Int32Array(1),
    loCompare = new Int32Array(1),
    myHiMask = new Int32Array(1)
  {
  }
}
