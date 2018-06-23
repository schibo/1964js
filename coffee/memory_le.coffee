###1964js - JavaScript/HTML5 port of 1964 - N64 emulator
Copyright (C) 2012 Joel Middendorf

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.###

#segments must be at least 64KB in size for lookup table.
`const MEMORY_START_RDRAM = 0x00000000`
`const MEMORY_SIZE_RDRAM = 0x800000` #4MB RDRAM + 4MB Expansion = 8MB
`const MEMORY_START_RAMREGS4 = 0x03F04000`
`const MEMORY_SIZE_RAMREGS4 = 0x10000`
`const MEMORY_START_RAMREGS0 = 0x03F00000`
`const MEMORY_START_RAMREGS8 = 0x03F80000`
`const MEMORY_SIZE_RAMREGS0 = 0x10000`
`const MEMORY_SIZE_RAMREGS8 = 0x10000`
`const MEMORY_START_SPMEM = 0x04000000`
`const MEMORY_START_SPREG_1 = 0x04040000`
`const MEMORY_START_SPREG_2 = 0x04080000`
`const MEMORY_START_DPC = 0x04100000`
`const MEMORY_START_DPS = 0x04200000`
`const MEMORY_START_MI = 0x04300000`
`const MEMORY_START_VI = 0x04400000`
`const MEMORY_START_AI = 0x04500000`
`const MEMORY_START_PI = 0x04600000`
`const MEMORY_START_RI = 0x04700000`
`const MEMORY_START_SI = 0x04800000`
`const MEMORY_START_C2A1 = 0x05000000`
`const MEMORY_START_C1A1 = 0x06000000`
`const MEMORY_START_C2A2 = 0x08000000`
`const MEMORY_START_ROM_IMAGE = 0x10000000`
`const MEMORY_START_GIO = 0x18000000`
`const MEMORY_START_C1A3 = 0x1FD00000`
`const MEMORY_START_DUMMY = 0x1FFF0000`
`const MEMORY_SIZE_SPMEM = 0x10000`
`const MEMORY_SIZE_SPREG_1 = 0x10000`
`const MEMORY_SIZE_SPREG_2 = 0x10000`
`const MEMORY_SIZE_DPC = 0x10000`
`const MEMORY_SIZE_DPS = 0x10000`
`const MEMORY_SIZE_MI = 0x10000`
`const MEMORY_SIZE_VI = 0x10000`
`const MEMORY_SIZE_AI = 0x10000`
`const MEMORY_SIZE_PI = 0x10000`
`const MEMORY_SIZE_RI = 0x10000`
`const MEMORY_SIZE_SI = 0x10000`
`const MEMORY_SIZE_C2A1 = 0x10000`
`const MEMORY_SIZE_C1A1 = 0x10000`
`const MEMORY_SIZE_C2A2 = 0x20000`
`const MEMORY_SIZE_GIO = 0x10000`
`const MEMORY_SIZE_C1A3 = 0x10000`
`const MEMORY_SIZE_DUMMY = 0x10000`
`const MEMORY_START_PIF = 0x1FC00000`
`const MEMORY_START_PIF_RAM = 0x1FC007C0`
`const MEMORY_SIZE_PIF = 0x10000`
`const MEMORY_SIZE_ROM = 0x4000000`

class C1964jsMemoryLE extends C1964jsMemory

  constructor: (core) ->
    super(core)

    @romUint16Array = `undefined`
    @romUint32Array = `undefined`
    ###*
     * @const
    ###
    @u16 = new Uint16Array(@ramArrayBuffer)
    ###*
     * @const
    ###
    @u32 = new Uint32Array(@ramArrayBuffer)

    ###*
     * @const
    ###
    @spMemUint16Array = new Uint16Array(@spMemUint8ArrayBuffer)

    ###*
     * @const
    ###
    @spReg1Uint16Array = new Uint16Array(@spReg1Uint8ArrayBuffer)

    ###*
     * @const
    ###
    @spReg2Uint16Array = new Uint16Array(@spReg2Uint8ArrayBuffer)

    ###*
     * @const
    ###
    @dpcUint16Array = new Uint16Array(@dpcUint8ArrayBuffer)

    ###*
     * @const
    ###
    @dpsUint16Array = new Uint16Array(@dpsUint8ArrayBuffer)

    ###*
     * @const
    ###
    @miUint16Array = new Uint16Array(@miUint8ArrayBuffer)

    ###*
     * @const
    ###
    @viUint16Array = new Uint16Array(@viUint8ArrayBuffer)

    ###*
     * @const
    ###
    @aiUint16Array = new Uint16Array(@aiUint8ArrayBuffer)

    ###*
     * @const
    ###
    @piUint16Array = new Uint16Array(@piUint8ArrayBuffer)

    ###*
     * @const
    ###
    @siUint16Array = new Uint16Array(@siUint8ArrayBuffer)

    ###*
     * @const
    ###
    @c2a1Uint16Array = new Uint16Array(@c2a1Uint8ArrayBuffer)

    ###*
     * @const
    ###
    @c1a1Uint16Array = new Uint16Array(@c1a1Uint8ArrayBuffer)

    ###*
     * @const
    ###
    @c2a2Uint16Array = new Uint16Array(@c2a2Uint8ArrayBuffer)

    ###*
     * @const
    ###
    @c1a3Uint16Array = new Uint16Array(@c1a3Uint8ArrayBuffer)

    ###*
     * @const
    ###
    @riUint16Array = new Uint16Array(@riUint8ArrayBuffer)

    ###*
     * @const
    ###
    @pifUint16Array = new Uint16Array(@pifUint8ArrayBuffer)

    ###*
     * @const
    ###
    @gioUint16Array = new Uint16Array(@gioUint8ArrayBuffer)

    ###*
     * @const
    ###
    @ramRegs0Uint16Array = new Uint16Array(@ramRegs0Uint8ArrayBuffer)

    ###*
     * @const
    ###
    @ramRegs4Uint16Array = new Uint16Array(@ramRegs4Uint8ArrayBuffer)

    ###*
     * @const
    ###
    @ramRegs8Uint16Array = new Uint16Array(@ramRegs8Uint8ArrayBuffer)

    ###*
     * @const
    ###
    @dummyReadWriteUint16Array = new Uint16Array(@dummyReadWriteUint8ArrayBuffer)


    ###*
     * @const
    ###
    @spMemUint32Array = new Uint32Array(@spMemUint8ArrayBuffer)

    ###*
     * @const
    ###
    @spReg1Uint32Array = new Uint32Array(@spReg1Uint8ArrayBuffer)

    ###*
     * @const
    ###
    @spReg2Uint32Array = new Uint32Array(@spReg2Uint8ArrayBuffer)

    ###*
     * @const
    ###
    @dpcUint32Array = new Uint32Array(@dpcUint8ArrayBuffer)

    ###*
     * @const
    ###
    @dpsUint32Array = new Uint32Array(@dpsUint8ArrayBuffer)

    ###*
     * @const
    ###
    @miUint32Array = new Uint32Array(@miUint8ArrayBuffer)

    ###*
     * @const
    ###
    @viUint32Array = new Uint32Array(@viUint8ArrayBuffer)

    ###*
     * @const
    ###
    @aiUint32Array = new Uint32Array(@aiUint8ArrayBuffer)

    ###*
     * @const
    ###
    @piUint32Array = new Uint32Array(@piUint8ArrayBuffer)

    ###*
     * @const
    ###
    @siUint32Array = new Uint32Array(@siUint8ArrayBuffer)

    ###*
     * @const
    ###
    @c2a1Uint32Array = new Uint32Array(@c2a1Uint8ArrayBuffer)

    ###*
     * @const
    ###
    @c1a1Uint32Array = new Uint32Array(@c1a1Uint8ArrayBuffer)

    ###*
     * @const
    ###
    @c2a2Uint32Array = new Uint32Array(@c2a2Uint8ArrayBuffer)

    ###*
     * @const
    ###
    @c1a3Uint32Array = new Uint32Array(@c1a3Uint8ArrayBuffer)

    ###*
     * @const
    ###
    @riUint32Array = new Uint32Array(@riUint8ArrayBuffer)

    ###*
     * @const
    ###
    @pifUint32Array = new Uint32Array(@pifUint8ArrayBuffer)

    ###*
     * @const
    ###
    @gioUint32Array = new Uint32Array(@gioUint8ArrayBuffer)

    ###*
     * @const
    ###
    @ramRegs0Uint32Array = new Uint32Array(@ramRegs0Uint8ArrayBuffer)

    ###*
     * @const
    ###
    @ramRegs4Uint32Array = new Uint32Array(@ramRegs4Uint8ArrayBuffer)

    ###*
     * @const
    ###
    @ramRegs8Uint32Array = new Uint32Array(@ramRegs8Uint8ArrayBuffer)

    ###*
     * @const
    ###
    @dummyReadWriteUint32Array = new Uint32Array(@dummyReadWriteUint8ArrayBuffer)

    @readDummy8 = (a) =>
      `const off_ = a & 0xFFFC`
      @dummyReadWriteUint8Array[off_^3]

    @readDummy16 = (a) =>
      `const off_ = a & 0xFFFC`
      @dummyReadWriteUint16Array[(off_>>>1)^1]

    @readDummy32 = (a) =>
      `const off_ = a & 0xFFFC`
      @dummyReadWriteUint32Array[off_>>>2]

    @readRdram8 = (a) =>
      @u8[a^3]

    @readRdram16 = (a) => @u16[(a>>>1)^1];


    @readRdram32 = (a) =>
      @u32[a>>>2]

    @readRamRegs0_8 = (a) =>
      `const off_ = a - MEMORY_START_RAMREGS0`
      @ramRegs0Uint8Array[off_^3]

    @readRamRegs0_16 = (a) =>
      `const off_ = (a-MEMORY_START_RAMREGS0)`
      @ramRegs0Uint16Array[(off_>>>1)^1]

    @readRamRegs0_32 = (a) =>
      `const off_ = (a-MEMORY_START_RAMREGS0)`
      @ramRegs0Uint32Array[off_>>>2]

    @readRamRegs4_8 = (a) =>
      `const off_ = a - MEMORY_START_RAMREGS4`
      @ramRegs4Uint8Array[off_^3]

    @readRamRegs4_16 = (a) =>
      `const off_ = (a-MEMORY_START_RAMREGS4)`
      @ramRegs4Uint16Array[(off_>>>1)^1]

    @readRamRegs4_32 = (a) =>
      `const off_ = (a-MEMORY_START_RAMREGS4)`
      @ramRegs4Uint32Array[off_>>>2]

    @readRamRegs8_8 = (a) =>
      `const off_ = a - MEMORY_START_RAMREGS8`
      @ramRegs8Uint8Array[off_^3]

    @readRamRegs8_16 = (a) =>
      `const off_ = (a-MEMORY_START_RAMREGS8)`
      @ramRegs8Uint16Array[(off_>>>1)^1]

    @readRamRegs8_32 = (a) =>
      `const off_ = (a-MEMORY_START_RAMREGS8)`
      @ramRegs8Uint32Array[off_>>>2]

    @readSpMem8 = (a) =>
      `const off_ = a - MEMORY_START_SPMEM`
      @spMemUint8Array[off_^3]

    @readSpMem16 = (a) =>
      `const off_ = (a-MEMORY_START_SPMEM)`
      @spMemUint16Array[(off_>>>1)^1]

    @readSpMem32 = (a) =>
      `const off_ = (a-MEMORY_START_SPMEM)`
      @spMemUint32Array[off_>>>2]

    @readSpReg1_8 = (a) =>
      `const off_ = a - MEMORY_START_SPREG_1`
      @core.interrupts.readSPReg1 off_

    @readSpReg1_16 = (a) =>
      `const off_ = a - MEMORY_START_SPREG_1`
      @core.interrupts.readSPReg1 off_

    @readSpReg1_32 = (a) =>
      `const off_ = a - MEMORY_START_SPREG_1`
      @core.interrupts.readSPReg1 off_

    @readSpReg2_8 = (a) =>
      `const off_ = a - MEMORY_START_SPREG_2`
      @spReg2Uint8Array[off_^3]

    @readSpReg2_16 = (a) =>
      `const off_ = (a-MEMORY_START_SPREG_2)`
      @spReg2Uint16Array[(off_>>>1)^1]

    @readSpReg2_32 = (a) =>
      `const off_ = (a-MEMORY_START_SPREG_2)`
      @spReg2Uint32Array[off_>>>2]

    @readDpc8 = (a) =>
      `const off_ = a - MEMORY_START_DPC`
      @dpcUint8Array[off_^3]

    @readDpc16 = (a) =>
      `const off_ = (a-MEMORY_START_DPC)`
      @dpcUint16Array[(off_>>>1)^1]

    @readDpc32 = (a) =>
      `const off_ = (a-MEMORY_START_DPC)`
      @dpcUint32Array[off_>>>2]

    @readDps8 = (a) =>
      `const off_ = a - MEMORY_START_DPS`
      @dpsUint8Array[off_^3]

    @readDps16 = (a) =>
      `const off_ = (a-MEMORY_START_DPS)`
      @dpsUint16Array[(off_>>>1)^1]

    @readDps32 = (a) =>
      `const off_ = (a-MEMORY_START_DPS)`
      @dpsUint32Array[off_>>>2]

    @readMi8 = (a) =>
      `const off_ = a - MEMORY_START_MI`
      @miUint8Array[off_^3]

    @readMi16 = (a) =>
      `const off_ = (a-MEMORY_START_MI)`
      @miUint16Array[(off_>>>1)^1]

    @readMi32 = (a) =>
      `const off_ = (a-MEMORY_START_MI)`
      @miUint32Array[off_>>>2]

    @readVi8 = (a) =>
      `const off_ = a - MEMORY_START_VI`
      @core.interrupts.readVI off_

    @readVi16 = (a) =>
      `const off_ = a - MEMORY_START_VI`
      @core.interrupts.readVI off_

    @readVi32 = (a) =>
      `const off_ = a - MEMORY_START_VI`
      @core.interrupts.readVI off_

    @readAi8 = (a) =>
      `const off_ = a - MEMORY_START_AI`
      @core.interrupts.readAI off_

    @readAi16 = (a) =>
      `const off_ = a - MEMORY_START_AI`
      @core.interrupts.readAI off_

    @readAi32 = (a) =>
      `const off_ = a - MEMORY_START_AI`
      @core.interrupts.readAI off_

    @readPi8 = (a) =>
      `const off_ = a - MEMORY_START_PI`
      @piUint8Array[off_^3]

    @readPi16 = (a) =>
      `const off_ = (a-MEMORY_START_PI)`
      @piUint16Array[(off_>>>1)^1]

    @readPi32 = (a) =>
      `const off_ = (a-MEMORY_START_PI)`
      @piUint32Array[off_>>>2]

    @readSi8 = (a) =>
      `const off_ = a - MEMORY_START_SI`
      @core.interrupts.readSI off_

    @readSi16 = (a) =>
      `const off_ = a - MEMORY_START_SI`
      @core.interrupts.readSI off_

    @readSi32 = (a) =>
      `const off_ = a - MEMORY_START_SI`
      @core.interrupts.readSI off_

    @readC2A1_8 = (a) =>
      `const off_ = a - MEMORY_START_C2A1`
      @c2a1Uint8Array[off_^3]

    @readC2A1_16 = (a) =>
      `const off_ = (a-MEMORY_START_C2A1)`
      @c2a1Uint16Array[(off_>>>1)^1]

    @readC2A1_32 = (a) =>
      `const off_ = (a-MEMORY_START_C2A1)`
      @c2a1Uint32Array[off_>>>2]

    @readC1A1_8 = (a) =>
      `const off_ = a - MEMORY_START_C1A1`
      @c1a1Uint8Array[off_^3]

    @readC1A1_16 = (a) =>
      `const off_ = (a-MEMORY_START_C1A1)`
      @c1a1Uint16Array[(off_>>>1)^1]

    @readC1A1_32 = (a) =>
      `const off_ = (a-MEMORY_START_C1A1)`
      @c1a1Uint32Array[off_>>>2]

    @readC2A2_8 = (a) =>
      `const off_ = a - MEMORY_START_C2A2`
      @c2a2Uint8Array[off_^3]

    @readC2A2_16 = (a) =>
      `const off_ = (a-MEMORY_START_C2A2)`
      @c2a2Uint16Array[(off_>>>1)^1]

    @readC2A2_32 = (a) =>
      `const off_ = (a-MEMORY_START_C2A2)`
      @c2a2Uint32Array[off_>>>2]

    @readRom8 = (a) =>
      `const off_ = a - MEMORY_START_ROM_IMAGE`
      @romUint8Array[off_^3]

    @readRom16 = (a) =>
      `const off_ = (a-MEMORY_START_ROM_IMAGE)`
      @romUint16Array[(off_>>>1)^1]

    @readRom32 = (a) =>
      `const off_ = (a-MEMORY_START_ROM_IMAGE)`
      @romUint32Array[off_>>>2]

    @readC1A3_8 = (a) =>
      `const off_ = a - MEMORY_START_C1A3`
      @c1a3Uint8Array[off_^3]

    @readC1A3_16 = (a) =>
      `const off_ = (a-MEMORY_START_C1A3)`
      @c1a3Uint16Array[(off_>>>1)^1]

    @readC1A3_32 = (a) =>
      `const off_ = (a-MEMORY_START_C1A3)`
      @c1a3Uint32Array[off_>>>2]

    @readRi8 = (a) =>
      `const off_ = a - MEMORY_START_RI`
      @riUint8Array[off_^3]

    @readRi16 = (a) =>
      `const off_ = (a-MEMORY_START_RI)`
      @riUint16Array[(off_>>>1)^1]

    @readRi32 = (a) =>
      `const off_ = (a-MEMORY_START_RI)`
      @riUint32Array[off_>>>2]

    @readPif8 = (a) =>
      `const off_ = a - MEMORY_START_PIF`
      @pifUint8Array[off_^3]

    @readPif16 = (a) =>
      `const off_ = (a-MEMORY_START_PIF)`
      @pifUint16Array[(off_>>>1)^1]

    @readPif32 = (a) =>
      `const off_ = (a-MEMORY_START_PIF)`
      @pifUint32Array[off_>>>2]

    @readGio8 = (a) =>
      `const off_ = a - MEMORY_START_GIO`
      @gioUint8Array[off_^3]

    @readGio16 = (a) =>
      `const off_ = (a-MEMORY_START_GIO)`
      @gioUint16Array[(off_>>>1)^1]

    @readGio32 = (a) =>
      `const off_ = (a-MEMORY_START_GIO)`
      @gioUint32Array[off_>>>2]

    @writeRdram8 = (val, a) =>
      @u8[a^3] = val
      return

    @writeRdram16 = (val, a) =>
      @u16[(a>>>1)^1] = val
      return

    @writeRdram32 = (val, a) =>
      @u32[a>>>2] = val
      return

    @writeSpMem8 = (val, a) =>
      `const off_ = a - MEMORY_START_SPMEM`
      @spMemUint8Array[off_^3] = val
      return

    @writeSpMem16 = (val, a) =>
      `const off_ = a - MEMORY_START_SPMEM`
      @spMemUint16Array[(off_>>>1)^1] = val
      return

    @writeSpMem32 = (val, a) =>
      `const off_ = a - MEMORY_START_SPMEM`
      @spMemUint32Array[off_>>>2] = val
      return

    @writeRi8 = (val, a) =>
      `const off_ = a - MEMORY_START_RI`
      @riUint8Array[off_^3] = val
      return

    @writeRi16 = (val, a) =>
      `const off_ = a - MEMORY_START_RI`
      @riUint16Array[(off_>>>1)^1] = val
      return

    @writeRi32 = (val, a) =>
      `const off_ = a - MEMORY_START_RI`
      @riUint32Array[off_>>>2] = val
      return

    @writeMi8 = (val, a, pc, isDelaySlot) =>
      `const off_ = a - MEMORY_START_MI`
      @core.interrupts.writeMI off_, val, pc, isDelaySlot
      return

    @writeMi16 = (val, a, pc, isDelaySlot) =>
      `const off_ = a - MEMORY_START_MI`
      @core.interrupts.writeMI off_, val, pc, isDelaySlot
      return

    @writeMi32 = (val, a, pc, isDelaySlot) =>
      `const off_ = a - MEMORY_START_MI`
      @core.interrupts.writeMI off_, val, pc, isDelaySlot
      return

    @writeRamRegs8_8 = (val, a) =>
      `const off_ = a - MEMORY_START_RAMREGS8`
      @ramRegs8Uint8Array[off_^3] = val
      return

    @writeRamRegs8_16 = (val, a) =>
      `const off_ = a - MEMORY_START_RAMREGS8`
      @ramRegs8Uint16Array[(off_>>>1)^1] = val
      return

    @writeRamRegs8_32 = (val, a) =>
      `const off_ = a - MEMORY_START_RAMREGS8`
      @ramRegs8Uint32Array[off_>>>2] = val
      return

    @writeRamRegs4_8 = (val, a) =>
      `const off_ = a - MEMORY_START_RAMREGS4`
      @ramRegs4Uint8Array[off_^3] = val
      return

    @writeRamRegs4_16 = (val, a) =>
      `const off_ = a - MEMORY_START_RAMREGS4`
      @ramRegs4Uint16Array[(off_>>>1)^1] = val
      return

    @writeRamRegs4_32 = (val, a) =>
      `const off_ = a - MEMORY_START_RAMREGS4`
      @ramRegs4Uint32Array[off_>>>2] = val
      return

    @writeRamRegs0_8 = (val, a) =>
      `const off_ = a - MEMORY_START_RAMREGS0`
      @ramRegs0Uint8Array[off_^3] = val
      return

    @writeRamRegs0_16 = (val, a) =>
      `const off_ = a - MEMORY_START_RAMREGS0`
      @ramRegs0Uint16Array[(off_>>>1)^1] = val
      return

    @writeRamRegs0_32 = (val, a) =>
      `const off_ = a - MEMORY_START_RAMREGS0`
      @ramRegs0Uint32Array[off_>>>2] = val
      return

    @writeSpReg1_8 = (val, a, pc, isDelaySlot) =>
      `const off_ = a - MEMORY_START_SPREG_1`
      @core.interrupts.writeSPReg1 off_, val, pc, isDelaySlot
      return

    @writeSpReg1_16 = (val, a, pc, isDelaySlot) =>
      `const off_ = a - MEMORY_START_SPREG_1`
      @core.interrupts.writeSPReg1 off_, val, pc, isDelaySlot
      return

    @writeSpReg1_32 = (val, a, pc, isDelaySlot) =>
      `const off_ = a - MEMORY_START_SPREG_1`
      @core.interrupts.writeSPReg1 off_, val, pc, isDelaySlot
      return

    @writePi8 = (val, a, pc, isDelaySlot) =>
      `const off_ = a - MEMORY_START_PI`
      @core.interrupts.writePI off_, val, pc, isDelaySlot
      return

    @writePi16 = (val, a, pc, isDelaySlot) =>
      `const off_ = a - MEMORY_START_PI`
      @core.interrupts.writePI off_, val, pc, isDelaySlot
      return

    @writePi32 = (val, a, pc, isDelaySlot) =>
      `const off_ = a - MEMORY_START_PI`
      @core.interrupts.writePI off_, val, pc, isDelaySlot
      return

    @writeSi8 = (val, a, pc, isDelaySlot) =>
      `const off_ = a - MEMORY_START_SI`
      @core.interrupts.writeSI off_, val, pc, isDelaySlot
      return

    @writeSi16 = (val, a, pc, isDelaySlot) =>
      `const off_ = a - MEMORY_START_SI`
      @core.interrupts.writeSI off_, val, pc, isDelaySlot
      return

    @writeSi32 = (val, a, pc, isDelaySlot) =>
      `const off_ = a - MEMORY_START_SI`
      @core.interrupts.writeSI off_, val, pc, isDelaySlot
      return

    @writeAi8 = (val, a, pc, isDelaySlot) =>
      `const off_ = a - MEMORY_START_AI`
      @core.interrupts.writeAI off_, val, pc, isDelaySlot
      return

    @writeAi16 = (val, a, pc, isDelaySlot) =>
      `const off_ = a - MEMORY_START_AI`
      @core.interrupts.writeAI off_, val, pc, isDelaySlot
      return

    @writeAi32 = (val, a, pc, isDelaySlot) =>
      `const off_ = a - MEMORY_START_AI`
      @core.interrupts.writeAI off_, val, pc, isDelaySlot
      return

    @writeVi8 = (val, a, pc, isDelaySlot) =>
      `const off_ = a - MEMORY_START_VI`
      @core.interrupts.writeVI off_, val, pc, isDelaySlot
      return

    @writeVi16 = (val, a, pc, isDelaySlot) =>
      `const off_ = a - MEMORY_START_VI`
      @core.interrupts.writeVI off_, val, pc, isDelaySlot
      return

    @writeVi32 = (val, a, pc, isDelaySlot) =>
      `const off_ = a - MEMORY_START_VI`
      @core.interrupts.writeVI off_, val, pc, isDelaySlot
      return

    @writeSpReg2_8 = (val, a, pc, isDelaySlot) =>
      `const off_ = a - MEMORY_START_SPREG_2`
      @core.interrupts.writeSPReg2 off_, val, pc, isDelaySlot
      return

    @writeSpReg2_16 = (val, a, pc, isDelaySlot) =>
      `const off_ = a - MEMORY_START_SPREG_2`
      @core.interrupts.writeSPReg2 off_, val, pc, isDelaySlot
      return

    @writeSpReg2_32 = (val, a, pc, isDelaySlot) =>
      `const off_ = a - MEMORY_START_SPREG_2`
      @core.interrupts.writeSPReg2 off_, val, pc, isDelaySlot
      return

    @writeDpc8 = (val, a, pc, isDelaySlot) =>
      `const off_ = a - MEMORY_START_DPC`
      @core.interrupts.writeDPC off_, val, pc, isDelaySlot
      return

    @writeDpc16 = (val, a, pc, isDelaySlot) =>
      `const off_ = a - MEMORY_START_DPC`
      @core.interrupts.writeDPC off_, val, pc, isDelaySlot
      return

    @writeDpc32 = (val, a, pc, isDelaySlot) =>
      `const off_ = a - MEMORY_START_DPC`
      @core.interrupts.writeDPC off_, val, pc, isDelaySlot
      return

    @writeDps8 = (val, a) =>
      `const off_ = a - MEMORY_START_DPS`
      @dpsUint8Array[off_^3] = val
      return

    @writeDps16 = (val, a) =>
      `const off_ = a - MEMORY_START_DPS`
      @dpsUint16Array[(off_>>>1)^1] = val
      return

    @writeDps32 = (val, a) =>
      `const off_ = a - MEMORY_START_DPS`
      @dpsUint32Array[off_>>>2] = val
      return

    @writeC2A1_8 = (val, a) =>
      `const off_ = a - MEMORY_START_C2A1`
      @c2a1Uint8Array[off_^3] = val
      return

    @writeC2A1_16 = (val, a) =>
      `const off_ = a - MEMORY_START_C2A1`
      @c2a1Uint16Array[(off_>>>1)^1] = val
      return

    @writeC2A1_32 = (val, a) =>
      `const off_ = a - MEMORY_START_C2A1`
      @c2a1Uint32Array[off_>>>2] = val
      return

    @writeC1A1_8 = (val, a) =>
      `const off_ = a - MEMORY_START_C1A1`
      @c1a1Uint8Array[off_^3] = val
      return

    @writeC1A1_16 = (val, a) =>
      `const off_ = a - MEMORY_START_C1A1`
      @c1a1Uint16Array[(off_>>>1)^1] = val
      return

    @writeC1A1_32 = (val, a) =>
      `const off_ = a - MEMORY_START_C1A1`
      @c1a1Uint32Array[off_>>>2] = val
      return

    @writeC2A2_8 = (val, a) =>
      `const off_ = a - MEMORY_START_C2A2`
      @c2a2Uint8Array[off_^3] = val
      return

    @writeC2A2_16 = (val, a) =>
      `const off_ = a - MEMORY_START_C2A2`
      @c2a2Uint16Array[(off_>>>1)^1] = val
      return

    @writeC2A2_32 = (val, a) =>
      `const off_ = a - MEMORY_START_C2A2`
      @c2a2Uint32Array[off_>>>2] = val
      return

    @writeRom8 = (val, a) =>
      alert "attempt to overwrite rom!"
      `const off_ = a - MEMORY_START_ROM_IMAGE`
      @romUint8Array[off_^3] = val
      return

    @writeRom16 = (val, a) =>
      `const off_ = a - MEMORY_START_ROM_IMAGE`
      @romUint16Array[(off_>>>1)^1] = val
      return

    @writeRom32 = (val, a) =>
      `const off_ = a - MEMORY_START_ROM_IMAGE`
      @romUint32Array[off_>>>2] = val
      return

    @writeC1A3_8 = (val, a) =>
      `const off_ = a - MEMORY_START_C1A3`
      @c1a3Uint8Array[off_^3] = val
      return

    @writeC1A3_16 = (val, a) =>
      `const off_ = a - MEMORY_START_C1A3`
      @c1a3Uint16Array[(off_>>>1)^1] = val
      return

    @writeC1A3_32 = (val, a) =>
      `const off_ = a - MEMORY_START_C1A3`
      @c1a3Uint32Array[off_>>>2] = val
      return

    @writePif8 = (val, a) =>
      `const off_ = a - MEMORY_START_PIF`
      @pifUint8Array[off_^3] = val
      return

    @writePif16 = (val, a) =>
      `const off_ = a - MEMORY_START_PIF`
      @pifUint16Array[(off_>>>1)^1] = val
      return

    @writePif32 = (val, a) =>
      `const off_ = a - MEMORY_START_PIF`
      @pifUint32Array[off_>>>2] = val
      return

    @writeGio8 = (val, a) =>
      `const off_ = a - MEMORY_START_GIO`
      @gioUint8Array[off_^3] = val
      return

    @writeGio16 = (val, a) =>
      `const off_ = a - MEMORY_START_GIO`
      @gioUint16Array[(off_>>>1)^1] = val
      return

    @writeGio32 = (val, a) =>
      `const off_ = a - MEMORY_START_GIO`
      @gioUint32Array[off_>>>2] = val
      return

    @writeDummy8 = (val, a) =>
      #log "writing to invalid memory at " + dec2hex(a)
      `const off_ = a & 0x0000fffc`
      @dummyReadWriteUint8Array[off_^3] = val
      return

    @writeDummy16 = (val, a) =>
      `const off_ = a & 0x0000fffc`
      @dummyReadWriteUint16Array[(off_>>>1)^1] = val
      return

    @writeDummy32 = (val, a) =>
      `const off_ = a & 0x0000fffc`
      @dummyReadWriteUint32Array[off_>>>2] = val
      return
    
    return #constructor

  #getInt32 and getUint32 are identical. they both return signed.
  getInt32: (uregion, off_, u32region) ->
    u32region[off_ >>>2]

  getUint32: (uregion, off_) ->
    uregion[off_ + 3] << 24 | uregion[off_ + 2] << 16 | uregion[off_ + 1] << 8 | uregion[off_]

  setInt32: (uregion, off_, val, u32region) ->
    u32region[off_>>>2] = val
    return

  setUint32: (uregion, off_, val) ->
    uregion[off_ + 3] = val >> 24
    uregion[off_ + 2] = val >> 16
    uregion[off_ + 1] = val >> 8
    uregion[off_] = val
    return


#hack global space until we export classes properly
#node.js uses exports; browser uses this (window)
root = exports ? self
root.C1964jsMemoryLE = C1964jsMemoryLE
