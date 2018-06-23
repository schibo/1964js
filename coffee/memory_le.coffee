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
    return

  readDummy8: (that, a) ->
    `const off_ = a & 0xFFFC`
    that.dummyReadWriteUint8Array[off_^3]

  readDummy16: (that, a) ->
    `const off_ = a & 0xFFFC`
    that.dummyReadWriteUint16Array[(off_>>>1)^1]

  readDummy32: (that, a) ->
    `const off_ = a & 0xFFFC`
    that.dummyReadWriteUint32Array[off_>>>2]

  readRdram8: (that, a) ->
    that.u8[a^3]

  readRdram16: (that, a) ->
    that.u16[(a>>>1)^1]

  readRdram32: (that, a) ->
    that.u32[a>>>2]

  readRamRegs0_8: (that, a) ->
    `const off_ = a - MEMORY_START_RAMREGS0`
    that.ramRegs0Uint8Array[off_^3]

  readRamRegs0_16: (that, a) ->
    `const off_ = (a-MEMORY_START_RAMREGS0)`
    that.ramRegs0Uint16Array[(off_>>>1)^1]

  readRamRegs0_32: (that, a) ->
    `const off_ = (a-MEMORY_START_RAMREGS0)`
    that.ramRegs0Uint32Array[off_>>>2]

  readRamRegs4_8: (that, a) ->
    `const off_ = a - MEMORY_START_RAMREGS4`
    that.ramRegs4Uint8Array[off_^3]

  readRamRegs4_16: (that, a) ->
    `const off_ = (a-MEMORY_START_RAMREGS4)`
    that.ramRegs4Uint16Array[(off_>>>1)^1]

  readRamRegs4_32: (that, a) ->
    `const off_ = (a-MEMORY_START_RAMREGS4)`
    that.ramRegs4Uint32Array[off_>>>2]

  readRamRegs8_8: (that, a) ->
    `const off_ = a - MEMORY_START_RAMREGS8`
    that.ramRegs8Uint8Array[off_^3]

  readRamRegs8_16: (that, a) ->
    `const off_ = (a-MEMORY_START_RAMREGS8)`
    that.ramRegs8Uint16Array[(off_>>>1)^1]

  readRamRegs8_32: (that, a) ->
    `const off_ = (a-MEMORY_START_RAMREGS8)`
    that.ramRegs8Uint32Array[off_>>>2]

  readSpMem8: (that, a) ->
    `const off_ = a - MEMORY_START_SPMEM`
    that.spMemUint8Array[off_^3]

  readSpMem16: (that, a) ->
    `const off_ = (a-MEMORY_START_SPMEM)`
    that.spMemUint16Array[(off_>>>1)^1]

  readSpMem32: (that, a) ->
    `const off_ = (a-MEMORY_START_SPMEM)`
    that.spMemUint32Array[off_>>>2]

  readSpReg1_8: (that, a) ->
    `const off_ = a - MEMORY_START_SPREG_1`
    that.core.interrupts.readSPReg1 off_

  readSpReg1_16: (that, a) ->
    `const off_ = a - MEMORY_START_SPREG_1`
    that.core.interrupts.readSPReg1 off_

  readSpReg1_32: (that, a) ->
    `const off_ = a - MEMORY_START_SPREG_1`
    that.core.interrupts.readSPReg1 off_

  readSpReg2_8: (that, a) ->
    `const off_ = a - MEMORY_START_SPREG_2`
    that.spReg2Uint8Array[off_^3]

  readSpReg2_16: (that, a) ->
    `const off_ = (a-MEMORY_START_SPREG_2)`
    that.spReg2Uint16Array[(off_>>>1)^1]

  readSpReg2_32: (that, a) ->
    `const off_ = (a-MEMORY_START_SPREG_2)`
    that.spReg2Uint32Array[off_>>>2]

  readDpc8: (that, a) ->
    `const off_ = a - MEMORY_START_DPC`
    that.dpcUint8Array[off_^3]

  readDpc16: (that, a) ->
    `const off_ = (a-MEMORY_START_DPC)`
    that.dpcUint16Array[(off_>>>1)^1]

  readDpc32: (that, a) ->
    `const off_ = (a-MEMORY_START_DPC)`
    that.dpcUint32Array[off_>>>2]

  readDps8: (that, a) ->
    `const off_ = a - MEMORY_START_DPS`
    that.dpsUint8Array[off_^3]

  readDps16: (that, a) ->
    `const off_ = (a-MEMORY_START_DPS)`
    that.dpsUint16Array[(off_>>>1)^1]

  readDps32: (that, a) ->
    `const off_ = (a-MEMORY_START_DPS)`
    that.dpsUint32Array[off_>>>2]

  readMi8: (that, a) ->
    `const off_ = a - MEMORY_START_MI`
    that.miUint8Array[off_^3]

  readMi16: (that, a) ->
    `const off_ = (a-MEMORY_START_MI)`
    that.miUint16Array[(off_>>>1)^1]

  readMi32: (that, a) ->
    `const off_ = (a-MEMORY_START_MI)`
    that.miUint32Array[off_>>>2]

  readVi8: (that, a) ->
    `const off_ = a - MEMORY_START_VI`
    that.core.interrupts.readVI off_

  readVi16: (that, a) ->
    `const off_ = a - MEMORY_START_VI`
    that.core.interrupts.readVI off_

  readVi32: (that, a) ->
    `const off_ = a - MEMORY_START_VI`
    that.core.interrupts.readVI off_

  readAi8: (that, a) ->
    `const off_ = a - MEMORY_START_AI`
    that.core.interrupts.readAI off_

  readAi16: (that, a) ->
    `const off_ = a - MEMORY_START_AI`
    that.core.interrupts.readAI off_

  readAi32: (that, a) ->
    `const off_ = a - MEMORY_START_AI`
    that.core.interrupts.readAI off_

  readPi8: (that, a) ->
    `const off_ = a - MEMORY_START_PI`
    that.piUint8Array[off_^3]

  readPi16: (that, a) ->
    `const off_ = (a-MEMORY_START_PI)`
    that.piUint16Array[(off_>>>1)^1]

  readPi32: (that, a) ->
    `const off_ = (a-MEMORY_START_PI)`
    that.piUint32Array[off_>>>2]

  readSi8: (that, a) ->
    `const off_ = a - MEMORY_START_SI`
    that.core.interrupts.readSI off_

  readSi16: (that, a) ->
    `const off_ = a - MEMORY_START_SI`
    that.core.interrupts.readSI off_

  readSi32: (that, a) ->
    `const off_ = a - MEMORY_START_SI`
    that.core.interrupts.readSI off_

  readC2A1_8: (that, a) ->
    `const off_ = a - MEMORY_START_C2A1`
    that.c2a1Uint8Array[off_^3]

  readC2A1_16: (that, a) ->
    `const off_ = (a-MEMORY_START_C2A1)`
    that.c2a1Uint16Array[(off_>>>1)^1]

  readC2A1_32: (that, a) ->
    `const off_ = (a-MEMORY_START_C2A1)`
    that.c2a1Uint32Array[off_>>>2]

  readC1A1_8: (that, a) ->
    `const off_ = a - MEMORY_START_C1A1`
    that.c1a1Uint8Array[off_^3]

  readC1A1_16: (that, a) ->
    `const off_ = (a-MEMORY_START_C1A1)`
    that.c1a1Uint16Array[(off_>>>1)^1]

  readC1A1_32: (that, a) ->
    `const off_ = (a-MEMORY_START_C1A1)`
    that.c1a1Uint32Array[off_>>>2]

  readC2A2_8: (that, a) ->
    `const off_ = a - MEMORY_START_C2A2`
    that.c2a2Uint8Array[off_^3]

  readC2A2_16: (that, a) ->
    `const off_ = (a-MEMORY_START_C2A2)`
    that.c2a2Uint16Array[(off_>>>1)^1]

  readC2A2_32: (that, a) ->
    `const off_ = (a-MEMORY_START_C2A2)`
    that.c2a2Uint32Array[off_>>>2]

  readRom8: (that, a) ->
    `const off_ = a - MEMORY_START_ROM_IMAGE`
    that.romUint8Array[off_^3]

  readRom16: (that, a) ->
    `const off_ = (a-MEMORY_START_ROM_IMAGE)`
    that.romUint16Array[(off_>>>1)^1]

  readRom32: (that, a) ->
    `const off_ = (a-MEMORY_START_ROM_IMAGE)`
    that.romUint32Array[off_>>>2]

  readC1A3_8: (that, a) ->
    `const off_ = a - MEMORY_START_C1A3`
    that.c1a3Uint8Array[off_^3]

  readC1A3_16: (that, a) ->
    `const off_ = (a-MEMORY_START_C1A3)`
    that.c1a3Uint16Array[(off_>>>1)^1]

  readC1A3_32: (that, a) ->
    `const off_ = (a-MEMORY_START_C1A3)`
    that.c1a3Uint32Array[off_>>>2]

  readRi8: (that, a) ->
    `const off_ = a - MEMORY_START_RI`
    that.riUint8Array[off_^3]

  readRi16: (that, a) ->
    `const off_ = (a-MEMORY_START_RI)`
    that.riUint16Array[(off_>>>1)^1]

  readRi32: (that, a) ->
    `const off_ = (a-MEMORY_START_RI)`
    that.riUint32Array[off_>>>2]

  readPif8: (that, a) ->
    `const off_ = a - MEMORY_START_PIF`
    that.pifUint8Array[off_^3]

  readPif16: (that, a) ->
    `const off_ = (a-MEMORY_START_PIF)`
    that.pifUint16Array[(off_>>>1)^1]

  readPif32: (that, a) ->
    `const off_ = (a-MEMORY_START_PIF)`
    that.pifUint32Array[off_>>>2]

  readGio8: (that, a) ->
    `const off_ = a - MEMORY_START_GIO`
    that.gioUint8Array[off_^3]

  readGio16: (that, a) ->
    `const off_ = (a-MEMORY_START_GIO)`
    that.gioUint16Array[(off_>>>1)^1]

  readGio32: (that, a) ->
    `const off_ = (a-MEMORY_START_GIO)`
    that.gioUint32Array[off_>>>2]

  writeRdram8: (that, val, a) ->
    that.u8[a^3] = val
    return

  writeRdram16: (that, val, a) ->
    that.u16[(a>>>1)^1] = val
    return

  writeRdram32: (that, val, a) ->
    that.u32[a>>>2] = val
    return

  writeSpMem8: (that, val, a) ->
    `const off_ = a - MEMORY_START_SPMEM`
    that.spMemUint8Array[off_^3] = val
    return

  writeSpMem16: (that, val, a) ->
    `const off_ = a - MEMORY_START_SPMEM`
    that.spMemUint16Array[(off_>>>1)^1] = val
    return

  writeSpMem32: (that, val, a) ->
    `const off_ = a - MEMORY_START_SPMEM`
    that.spMemUint32Array[off_>>>2] = val
    return

  writeRi8: (that, val, a) ->
    `const off_ = a - MEMORY_START_RI`
    that.riUint8Array[off_^3] = val
    return

  writeRi16: (that, val, a) ->
    `const off_ = a - MEMORY_START_RI`
    that.riUint16Array[(off_>>>1)^1] = val
    return

  writeRi32: (that, val, a) ->
    `const off_ = a - MEMORY_START_RI`
    that.riUint32Array[off_>>>2] = val
    return

  writeMi8: (that, val, a, pc, isDelaySlot) ->
    `const off_ = a - MEMORY_START_MI`
    that.core.interrupts.writeMI off_, val, pc, isDelaySlot
    return

  writeMi16: (that, val, a, pc, isDelaySlot) ->
    `const off_ = a - MEMORY_START_MI`
    that.core.interrupts.writeMI off_, val, pc, isDelaySlot
    return

  writeMi32: (that, val, a, pc, isDelaySlot) ->
    `const off_ = a - MEMORY_START_MI`
    that.core.interrupts.writeMI off_, val, pc, isDelaySlot
    return

  writeRamRegs8_8: (that, val, a) ->
    `const off_ = a - MEMORY_START_RAMREGS8`
    that.ramRegs8Uint8Array[off_^3] = val
    return

  writeRamRegs8_16: (that, val, a) ->
    `const off_ = a - MEMORY_START_RAMREGS8`
    that.ramRegs8Uint16Array[(off_>>>1)^1] = val
    return

  writeRamRegs8_32: (that, val, a) ->
    `const off_ = a - MEMORY_START_RAMREGS8`
    that.ramRegs8Uint32Array[off_>>>2] = val
    return

  writeRamRegs4_8: (that, val, a) ->
    `const off_ = a - MEMORY_START_RAMREGS4`
    that.ramRegs4Uint8Array[off_^3] = val
    return

  writeRamRegs4_16: (that, val, a) ->
    `const off_ = a - MEMORY_START_RAMREGS4`
    that.ramRegs4Uint16Array[(off_>>>1)^1] = val
    return

  writeRamRegs4_32: (that, val, a) ->
    `const off_ = a - MEMORY_START_RAMREGS4`
    that.ramRegs4Uint32Array[off_>>>2] = val
    return

  writeRamRegs0_8: (that, val, a) ->
    `const off_ = a - MEMORY_START_RAMREGS0`
    that.ramRegs0Uint8Array[off_^3] = val
    return

  writeRamRegs0_16: (that, val, a) ->
    `const off_ = a - MEMORY_START_RAMREGS0`
    that.ramRegs0Uint16Array[(off_>>>1)^1] = val
    return

  writeRamRegs0_32: (that, val, a) ->
    `const off_ = a - MEMORY_START_RAMREGS0`
    that.ramRegs0Uint32Array[off_>>>2] = val
    return

  writeSpReg1_8: (that, val, a, pc, isDelaySlot) ->
    `const off_ = a - MEMORY_START_SPREG_1`
    that.core.interrupts.writeSPReg1 off_, val, pc, isDelaySlot
    return

  writeSpReg1_16: (that, val, a, pc, isDelaySlot) ->
    `const off_ = a - MEMORY_START_SPREG_1`
    that.core.interrupts.writeSPReg1 off_, val, pc, isDelaySlot
    return

  writeSpReg1_32: (that, val, a, pc, isDelaySlot) ->
    `const off_ = a - MEMORY_START_SPREG_1`
    that.core.interrupts.writeSPReg1 off_, val, pc, isDelaySlot
    return

  writePi8: (that, val, a, pc, isDelaySlot) ->
    `const off_ = a - MEMORY_START_PI`
    that.core.interrupts.writePI off_, val, pc, isDelaySlot
    return

  writePi16: (that, val, a, pc, isDelaySlot) ->
    `const off_ = a - MEMORY_START_PI`
    that.core.interrupts.writePI off_, val, pc, isDelaySlot
    return

  writePi32: (that, val, a, pc, isDelaySlot) ->
    `const off_ = a - MEMORY_START_PI`
    that.core.interrupts.writePI off_, val, pc, isDelaySlot
    return

  writeSi8: (that, val, a, pc, isDelaySlot) ->
    `const off_ = a - MEMORY_START_SI`
    that.core.interrupts.writeSI off_, val, pc, isDelaySlot
    return

  writeSi16: (that, val, a, pc, isDelaySlot) ->
    `const off_ = a - MEMORY_START_SI`
    that.core.interrupts.writeSI off_, val, pc, isDelaySlot
    return

  writeSi32: (that, val, a, pc, isDelaySlot) ->
    `const off_ = a - MEMORY_START_SI`
    that.core.interrupts.writeSI off_, val, pc, isDelaySlot
    return

  writeAi8: (that, val, a, pc, isDelaySlot) ->
    `const off_ = a - MEMORY_START_AI`
    that.core.interrupts.writeAI off_, val, pc, isDelaySlot
    return

  writeAi16: (that, val, a, pc, isDelaySlot) ->
    `const off_ = a - MEMORY_START_AI`
    that.core.interrupts.writeAI off_, val, pc, isDelaySlot
    return

  writeAi32: (that, val, a, pc, isDelaySlot) ->
    `const off_ = a - MEMORY_START_AI`
    that.core.interrupts.writeAI off_, val, pc, isDelaySlot
    return

  writeVi8: (that, val, a, pc, isDelaySlot) ->
    `const off_ = a - MEMORY_START_VI`
    that.core.interrupts.writeVI off_, val, pc, isDelaySlot
    return

  writeVi16: (that, val, a, pc, isDelaySlot) ->
    `const off_ = a - MEMORY_START_VI`
    that.core.interrupts.writeVI off_, val, pc, isDelaySlot
    return

  writeVi32: (that, val, a, pc, isDelaySlot) ->
    `const off_ = a - MEMORY_START_VI`
    that.core.interrupts.writeVI off_, val, pc, isDelaySlot
    return

  writeSpReg2_8: (that, val, a, pc, isDelaySlot) ->
    `const off_ = a - MEMORY_START_SPREG_2`
    that.core.interrupts.writeSPReg2 off_, val, pc, isDelaySlot
    return

  writeSpReg2_16: (that, val, a, pc, isDelaySlot) ->
    `const off_ = a - MEMORY_START_SPREG_2`
    that.core.interrupts.writeSPReg2 off_, val, pc, isDelaySlot
    return

  writeSpReg2_32: (that, val, a, pc, isDelaySlot) ->
    `const off_ = a - MEMORY_START_SPREG_2`
    that.core.interrupts.writeSPReg2 off_, val, pc, isDelaySlot
    return

  writeDpc8: (that, val, a, pc, isDelaySlot) ->
    `const off_ = a - MEMORY_START_DPC`
    that.core.interrupts.writeDPC off_, val, pc, isDelaySlot
    return

  writeDpc16: (that, val, a, pc, isDelaySlot) ->
    `const off_ = a - MEMORY_START_DPC`
    that.core.interrupts.writeDPC off_, val, pc, isDelaySlot
    return

  writeDpc32: (that, val, a, pc, isDelaySlot) ->
    `const off_ = a - MEMORY_START_DPC`
    that.core.interrupts.writeDPC off_, val, pc, isDelaySlot
    return

  writeDps8: (that, val, a) ->
    `const off_ = a - MEMORY_START_DPS`
    that.dpsUint8Array[off_^3] = val
    return

  writeDps16: (that, val, a) ->
    `const off_ = a - MEMORY_START_DPS`
    that.dpsUint16Array[(off_>>>1)^1] = val
    return

  writeDps32: (that, val, a) ->
    `const off_ = a - MEMORY_START_DPS`
    that.dpsUint32Array[off_>>>2] = val
    return

  writeC2A1_8: (that, val, a) ->
    `const off_ = a - MEMORY_START_C2A1`
    that.c2a1Uint8Array[off_^3] = val
    return

  writeC2A1_16: (that, val, a) ->
    `const off_ = a - MEMORY_START_C2A1`
    that.c2a1Uint16Array[(off_>>>1)^1] = val
    return

  writeC2A1_32: (that, val, a) ->
    `const off_ = a - MEMORY_START_C2A1`
    that.c2a1Uint32Array[off_>>>2] = val
    return

  writeC1A1_8: (that, val, a) ->
    `const off_ = a - MEMORY_START_C1A1`
    that.c1a1Uint8Array[off_^3] = val
    return

  writeC1A1_16: (that, val, a) ->
    `const off_ = a - MEMORY_START_C1A1`
    that.c1a1Uint16Array[(off_>>>1)^1] = val
    return

  writeC1A1_32: (that, val, a) ->
    `const off_ = a - MEMORY_START_C1A1`
    that.c1a1Uint32Array[off_>>>2] = val
    return

  writeC2A2_8: (that, val, a) ->
    `const off_ = a - MEMORY_START_C2A2`
    that.c2a2Uint8Array[off_^3] = val
    return

  writeC2A2_16: (that, val, a) ->
    `const off_ = a - MEMORY_START_C2A2`
    that.c2a2Uint16Array[(off_>>>1)^1] = val
    return

  writeC2A2_32: (that, val, a) ->
    `const off_ = a - MEMORY_START_C2A2`
    that.c2a2Uint32Array[off_>>>2] = val
    return

  writeRom8: (that, val, a) ->
    alert "attempt to overwrite rom!"
    `const off_ = a - MEMORY_START_ROM_IMAGE`
    that.romUint8Array[off_^3] = val
    return

  writeRom16: (that, val, a) ->
    `const off_ = a - MEMORY_START_ROM_IMAGE`
    that.romUint16Array[(off_>>>1)^1] = val
    return

  writeRom32: (that, val, a) ->
    `const off_ = a - MEMORY_START_ROM_IMAGE`
    that.romUint32Array[off_>>>2] = val
    return

  writeC1A3_8: (that, val, a) ->
    `const off_ = a - MEMORY_START_C1A3`
    that.c1a3Uint8Array[off_^3] = val
    return

  writeC1A3_16: (that, val, a) ->
    `const off_ = a - MEMORY_START_C1A3`
    that.c1a3Uint16Array[(off_>>>1)^1] = val
    return

  writeC1A3_32: (that, val, a) ->
    `const off_ = a - MEMORY_START_C1A3`
    that.c1a3Uint32Array[off_>>>2] = val
    return

  writePif8: (that, val, a) ->
    `const off_ = a - MEMORY_START_PIF`
    that.pifUint8Array[off_^3] = val
    return

  writePif16: (that, val, a) ->
    `const off_ = a - MEMORY_START_PIF`
    that.pifUint16Array[(off_>>>1)^1] = val
    return

  writePif32: (that, val, a) ->
    `const off_ = a - MEMORY_START_PIF`
    that.pifUint32Array[off_>>>2] = val
    return

  writeGio8: (that, val, a) ->
    `const off_ = a - MEMORY_START_GIO`
    that.gioUint8Array[off_^3] = val
    return

  writeGio16: (that, val, a) ->
    `const off_ = a - MEMORY_START_GIO`
    that.gioUint16Array[(off_>>>1)^1] = val
    return

  writeGio32: (that, val, a) ->
    `const off_ = a - MEMORY_START_GIO`
    that.gioUint32Array[off_>>>2] = val
    return

  writeDummy8: (that, val, a) ->
    #log "writing to invalid memory at " + dec2hex(a)
    `const off_ = a & 0x0000fffc`
    that.dummyReadWriteUint8Array[off_^3] = val
    return

  writeDummy16: (that, val, a) ->
    `const off_ = a & 0x0000fffc`
    that.dummyReadWriteUint16Array[(off_>>>1)^1] = val
    return

  writeDummy32: (that, val, a) ->
    `const off_ = a & 0x0000fffc`
    that.dummyReadWriteUint32Array[off_>>>2] = val
    return

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
