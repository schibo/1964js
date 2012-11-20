library memory;

import 'dart:html';

class Memory {
  Uint8Array romUint8Array; // set after rom is loaded.
  Uint8Array rom; //set after rom is loaded.
  Uint8Array rdramUint8Array;
  Uint8Array spMemUint8Array;
  Uint8Array spReg1Uint8Array;
  Uint8Array spReg2Uint8Array;
  Uint8Array dpcUint8Array;
  Uint8Array dpsUint8Array;
  Uint8Array miUint8Array;
  Uint8Array viUint8Array;
  Uint8Array aiUint8Array;
  Uint8Array piUint8Array;
  Uint8Array siUint8Array;
  Uint8Array c2a1Uint8Array;
  Uint8Array c1a1Uint8Array;
  Uint8Array c2a2Uint8Array;
  Uint8Array c1a3Uint8Array;
  Uint8Array riUint8Array;
  Uint8Array pifUint8Array;
  Uint8Array gioUint8Array;
  Uint8Array ramRegs0Uint8Array;
  Uint8Array ramRegs4Uint8Array;
  Uint8Array ramRegs8Uint8Array;
  Uint8Array dummyReadWriteUint8Array;

  Memory(core) :
    rdramUint8Array = new Uint8Array(0x800000),
    spMemUint8Array = new Uint8Array(0x10000),
    spReg1Uint8Array = new Uint8Array(0x10000),
    spReg2Uint8Array = new Uint8Array(0x10000),
    dpcUint8Array = new Uint8Array(0x10000),
    dpsUint8Array = new Uint8Array(0x10000),
    miUint8Array = new Uint8Array(0x10000),
    viUint8Array = new Uint8Array(0x10000),
    aiUint8Array = new Uint8Array(0x10000),
    piUint8Array = new Uint8Array(0x10000),
    siUint8Array = new Uint8Array(0x10000),
    c2a1Uint8Array = new Uint8Array(0x10000),
    c1a1Uint8Array = new Uint8Array(0x10000),
    c2a2Uint8Array = new Uint8Array(0x10000),
    c1a3Uint8Array = new Uint8Array(0x10000),
    riUint8Array = new Uint8Array(0x10000),
    pifUint8Array = new Uint8Array(0x10000),
    gioUint8Array = new Uint8Array(0x10000),
    ramRegs0Uint8Array = new Uint8Array(0x10000),
    ramRegs4Uint8Array = new Uint8Array(0x10000),
    ramRegs8Uint8Array = new Uint8Array(0x10000),
    dummyReadWriteUint8Array = new Uint8Array(0x10000)
  {

  }

  static int getUint32(uregion, off_) {
    return uregion[off_] << 24 | uregion[off_ + 1] << 16 | uregion[off_ + 2] << 8 | uregion[off_ + 3];
  }

}
