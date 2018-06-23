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

class C1964jsMemory



  constructor: (@core) ->
    ###*
     * @const
    ###
    @romUint8Array = `undefined` # set after rom is loaded.

    ###*
     * @const
    ###
    @rom = `undefined` # set after rom is loaded.

    ###*
     * @const
    ###
    @ramArrayBuffer = new ArrayBuffer(0x800000)
    ###*
     * @const
    ###
    @u8 = new Uint8Array(@ramArrayBuffer) # RDRAM

    ###*
     * @const
    ###
    @spMemUint8ArrayBuffer = new ArrayBuffer(0x10000)
    ###*
     * @const
    ###
    @spMemUint8Array = new Uint8Array(@spMemUint8ArrayBuffer)

    ###*
     * @const
    ###
    @spReg1Uint8ArrayBuffer = new ArrayBuffer(0x10000)
    ###*
     * @const
    ###
    @spReg1Uint8Array = new Uint8Array(@spReg1Uint8ArrayBuffer)

    ###*
     * @const
    ###
    @spReg2Uint8ArrayBuffer = new ArrayBuffer(0x10000)
    ###*
     * @const
    ###
    @spReg2Uint8Array = new Uint8Array(@spReg2Uint8ArrayBuffer)
    
    ###*
     * @const
    ###
    @dpcUint8ArrayBuffer = new ArrayBuffer(0x10000)
    ###*
     * @const
    ###
    @dpcUint8Array = new Uint8Array(@dpcUint8ArrayBuffer)
    
    ###*
     * @const
    ###
    @dpsUint8ArrayBuffer = new ArrayBuffer(0x10000)
    ###*
     * @const
    ###
    @dpsUint8Array = new Uint8Array(@dpsUint8ArrayBuffer)
    
    ###*
     * @const
    ###
    @miUint8ArrayBuffer = new ArrayBuffer(0x10000)
    ###*
     * @const
    ###
    @miUint8Array = new Uint8Array(@miUint8ArrayBuffer)
    
    ###*
     * @const
    ###
    @viUint8ArrayBuffer = new ArrayBuffer(0x10000)
    ###*
     * @const
    ###
    @viUint8Array = new Uint8Array(@viUint8ArrayBuffer)
    
    ###*
     * @const
    ###
    @aiUint8ArrayBuffer = new ArrayBuffer(0x10000)
    ###*
     * @const
    ###
    @aiUint8Array = new Uint8Array(@aiUint8ArrayBuffer)
    
    ###*
     * @const
    ###
    @piUint8ArrayBuffer = new ArrayBuffer(0x10000)
    ###*
     * @const
    ###
    @piUint8Array = new Uint8Array(@piUint8ArrayBuffer)
    
    ###*
     * @const
    ###
    @siUint8ArrayBuffer = new ArrayBuffer(0x10000)
    ###*
     * @const
    ###
    @siUint8Array = new Uint8Array(@siUint8ArrayBuffer)
    
    ###*
     * @const
    ###
    @c2a1Uint8ArrayBuffer = new ArrayBuffer(0x10000)
    ###*
     * @const
    ###
    @c2a1Uint8Array = new Uint8Array(@c2a1Uint8ArrayBuffer)
    
    ###*
     * @const
    ###
    @c1a1Uint8ArrayBuffer = new ArrayBuffer(0x10000)
    ###*
     * @const
    ###
    @c1a1Uint8Array = new Uint8Array(@c1a1Uint8ArrayBuffer)
    
    ###*
     * @const
    ###
    @c2a2Uint8ArrayBuffer = new ArrayBuffer(0x10000)
    ###*
     * @const
    ###
    @c2a2Uint8Array = new Uint8Array(@c2a2Uint8ArrayBuffer)
    
    ###*
     * @const
    ###
    @c1a3Uint8ArrayBuffer = new ArrayBuffer(0x10000)
    ###*
     * @const
    ###
    @c1a3Uint8Array = new Uint8Array(@c1a3Uint8ArrayBuffer)
    
    ###*
     * @const
    ###
    @riUint8ArrayBuffer = new ArrayBuffer(0x10000)
    ###*
     * @const
    ###
    @riUint8Array = new Uint8Array(@riUint8ArrayBuffer)
    
    ###*
     * @const
    ###
    @pifUint8ArrayBuffer = new ArrayBuffer(0x10000)
    ###*
     * @const
    ###
    @pifUint8Array = new Uint8Array(@pifUint8ArrayBuffer)
    
    ###*
     * @const
    ###
    @gioUint8ArrayBuffer = new ArrayBuffer(0x10000)
    ###*
     * @const
    ###
    @gioUint8Array = new Uint8Array(@gioUint8ArrayBuffer)
    
    ###*
     * @const
    ###
    @ramRegs0Uint8ArrayBuffer = new ArrayBuffer(0x10000)
    ###*
     * @const
    ###
    @ramRegs0Uint8Array = new Uint8Array(@ramRegs0Uint8ArrayBuffer)
    
    ###*
     * @const
    ###
    @ramRegs4Uint8ArrayBuffer = new ArrayBuffer(0x10000)
    ###*
     * @const
    ###
    @ramRegs4Uint8Array = new Uint8Array(@ramRegs4Uint8ArrayBuffer)
    
    ###*
     * @const
    ###
    @ramRegs8Uint8ArrayBuffer = new ArrayBuffer(0x10000)
    ###*
     * @const
    ###
    @ramRegs8Uint8Array = new Uint8Array(@ramRegs8Uint8ArrayBuffer)
    
    ###*
     * @const
    ###
    @dummyReadWriteUint8ArrayBuffer = new ArrayBuffer(0x10000)
    ###*
     * @const
    ###
    @dummyReadWriteUint8Array = new Uint8Array(@dummyReadWriteUint8ArrayBuffer)
    
    @lengthy = 50325

    ###*
     * Load Byte
     * @type {!Array<!function(!C1964jsMemory, number): number>}
     * @const
    ###
    @LB = Array.apply(@readDummy8, Array(@lengthy))

    ###*
     * Load Half
     * @type {!Array<!function(!C1964jsMemory, number): number>}
     * @const
    ###
    @LH = Array.apply(@readDummy16, Array(@lengthy))

    ###*
     * Load Word
     * @type {!Array<!function(!C1964jsMemory, number): number>}
     * @const
    ###    
    @LW = Array.apply(@readDummy32, Array(@lengthy))

    ###*
     * Store byte
     * @type {!Array<!function(!C1964jsMemory, number, number)>}
     * @const
    ###    
    @SB = Array.apply(@writeDummy8, Array(@lengthy))

    ###*
     * Store Half
     * @type {!Array<!function(!C1964jsMemory, number, number)>}
     * @const
    ###    
    @SH = Array.apply(@writeDummy16, Array(@lengthy))

    ###*
     * Store Word
     * @type {!Array<!function(!C1964jsMemory, number, number)>}
     * @const
    ###    
    @SW = Array.apply(@writeDummy32, Array(@lengthy))

    #todo: fix overlapping ramregs now that we are 0xffff in lut size instead of 0xfffc in lut size

    @t = undefined
    console.log "lengthy0 = " + @lengthy

    @readDummy8 = (a) =>
      `const off_ = a & 0xFFFC`
      this.dummyReadWriteUint8Array[off_]

    @readDummy16 = (a) =>
      `const off_ = a & 0xFFFC`
      this.dummyReadWriteUint8Array[off_] << 8 | this.dummyReadWriteUint8Array[off_ + 1]

    @readDummy32 = (a) =>
      `const off_ = a & 0xFFFC`
      this.dummyReadWriteUint8Array[off_] << 24 | this.dummyReadWriteUint8Array[off_ + 1] << 16 | this.dummyReadWriteUint8Array[off_ + 2] << 8 | this.dummyReadWriteUint8Array[off_ + 3]

    @readRdram8 = (a) =>
      this.u8[a]

    @readRdram16 = (a) =>
      `const ram = this.u8`
      ram[a] << 8 | ram[a + 1]

    @readRdram32 = (a) =>
      `const ram = this.u8`
      ram[a] << 24 | ram[a + 1] << 16 | ram[a + 2] << 8 | ram[a + 3]

    @readRamRegs0_8 = (a) =>
      `const off_ = a - MEMORY_START_RAMREGS0`
      this.ramRegs0Uint8Array[off_]

    @readRamRegs0_16 = (a) =>
      `const off_ = (a-MEMORY_START_RAMREGS0)`
      this.ramRegs0Uint8Array[off_] << 8 | this.ramRegs0Uint8Array[off_ + 1]

    @readRamRegs0_32 = (a) =>
      `const off_ = (a-MEMORY_START_RAMREGS0)`
      this.ramRegs0Uint8Array[off_] << 24 | this.ramRegs0Uint8Array[off_ + 1] << 16 | this.ramRegs0Uint8Array[off_ + 2] << 8 | this.ramRegs0Uint8Array[off_ + 3]

    @readRamRegs4_8 = (a) =>
      `const off_ = a - MEMORY_START_RAMREGS4`
      this.ramRegs4Uint8Array[off_]

    @readRamRegs4_16 = (a) =>
      `const off_ = (a-MEMORY_START_RAMREGS4)`
      this.ramRegs4Uint8Array[off_] << 8 | this.ramRegs4Uint8Array[off_ + 1]

    @readRamRegs4_32 = (a) =>
      `const off_ = (a-MEMORY_START_RAMREGS4)`
      this.ramRegs4Uint8Array[off_] << 24 | this.ramRegs4Uint8Array[off_ + 1] << 16 | this.ramRegs4Uint8Array[off_ + 2] << 8 | this.ramRegs4Uint8Array[off_ + 3]

    @readRamRegs8_8 = (a) =>
      `const off_ = a - MEMORY_START_RAMREGS8`
      this.ramRegs8Uint8Array[off_]

    @readRamRegs8_16 = (a) =>
      `const off_ = (a-MEMORY_START_RAMREGS8)`
      this.ramRegs8Uint8Array[off_] << 8 | this.ramRegs8Uint8Array[off_ + 1]

    @readRamRegs8_32 = (a) =>
      `const off_ = (a-MEMORY_START_RAMREGS8)`
      this.ramRegs8Uint8Array[off_] << 24 | this.ramRegs8Uint8Array[off_ + 1] << 16 | this.ramRegs8Uint8Array[off_ + 2] << 8 | this.ramRegs8Uint8Array[off_ + 3]

    @readSpMem8 = (a) =>
      `const off_ = a - MEMORY_START_SPMEM`
      this.spMemUint8Array[off_]

    @readSpMem16 = (a) =>
      `const off_ = (a-MEMORY_START_SPMEM)`
      this.spMemUint8Array[off_] << 8 | this.spMemUint8Array[off_ + 1]

    @readSpMem32 = (a) =>
      `const off_ = (a-MEMORY_START_SPMEM)`
      this.spMemUint8Array[off_] << 24 | this.spMemUint8Array[off_ + 1] << 16 | this.spMemUint8Array[off_ + 2] << 8 | this.spMemUint8Array[off_ + 3]

    @readSpReg1_8 = (a) =>
      `const off_ = a - MEMORY_START_SPREG_1`
      this.core.interrupts.readSPReg1 off_

    @readSpReg1_16 = (a) =>
      `const off_ = a - MEMORY_START_SPREG_1`
      this.core.interrupts.readSPReg1 off_

    @readSpReg1_32 = (a) =>
      `const off_ = a - MEMORY_START_SPREG_1`
      this.core.interrupts.readSPReg1 off_

    @readSpReg2_8 = (a) =>
      `const off_ = a - MEMORY_START_SPREG_2`
      this.spReg2Uint8Array[off_]

    @readSpReg2_16 = (a) =>
      `const off_ = (a-MEMORY_START_SPREG_2)`
      this.spReg2Uint8Array[off_] << 8 | this.spReg2Uint8Array[off_ + 1]

    @readSpReg2_32 = (a) =>
      `const off_ = (a-MEMORY_START_SPREG_2)`
      this.spReg2Uint8Array[off_] << 24 | this.spReg2Uint8Array[off_ + 1] << 16 | this.spReg2Uint8Array[off_ + 2] << 8 | this.spReg2Uint8Array[off_ + 3]

    @readDpc8 = (a) =>
      `const off_ = a - MEMORY_START_DPC`
      this.dpcUint8Array[off_]

    @readDpc16 = (a) =>
      `const off_ = (a-MEMORY_START_DPC)`
      this.dpcUint8Array[off_] << 8 | this.dpcUint8Array[off_ + 1]

    @readDpc32 = (a) =>
      `const off_ = (a-MEMORY_START_DPC)`
      this.dpcUint8Array[off_] << 24 | this.dpcUint8Array[off_ + 1] << 16 | this.dpcUint8Array[off_ + 2] << 8 | this.dpcUint8Array[off_ + 3]

    @readDps8 = (a) =>
      `const off_ = a - MEMORY_START_DPS`
      this.dpsUint8Array[off_]

    @readDps16 = (a) =>
      `const off_ = (a-MEMORY_START_DPS)`
      this.dpsUint8Array[off_] << 8 | this.dpsUint8Array[off_ + 1]

    @readDps32 = (a) =>
      `const off_ = (a-MEMORY_START_DPS)`
      this.dpsUint8Array[off_] << 24 | this.dpsUint8Array[off_ + 1] << 16 | this.dpsUint8Array[off_ + 2] << 8 | this.dpsUint8Array[off_ + 3]

    @readMi8 = (a) =>
      `const off_ = a - MEMORY_START_MI`
      this.miUint8Array[off_]

    @readMi16 = (a) =>
      `const off_ = (a-MEMORY_START_MI)`
      this.miUint8Array[off_] << 8 | this.miUint8Array[off_ + 1]

    @readMi32 = (a) =>
      `const off_ = (a-MEMORY_START_MI)`
      this.miUint8Array[off_] << 24 | this.miUint8Array[off_ + 1] << 16 | this.miUint8Array[off_ + 2] << 8 | this.miUint8Array[off_ + 3]

    @readVi8 = (a) =>
      `const off_ = a - MEMORY_START_VI`
      this.core.interrupts.readVI off_

    @readVi16 = (a) =>
      `const off_ = a - MEMORY_START_VI`
      this.core.interrupts.readVI off_

    @readVi32 = (a) =>
      `const off_ = a - MEMORY_START_VI`
      this.core.interrupts.readVI off_

    @readAi8 = (a) =>
      `const off_ = a - MEMORY_START_AI`
      this.core.interrupts.readAI off_

    @readAi16 = (a) =>
      `const off_ = a - MEMORY_START_AI`
      this.core.interrupts.readAI off_

    @readAi32 = (a) =>
      `const off_ = a - MEMORY_START_AI`
      this.core.interrupts.readAI off_

    @readPi8 = (a) =>
      `const off_ = a - MEMORY_START_PI`
      this.piUint8Array[off_]

    @readPi16 = (a) =>
      `const off_ = (a-MEMORY_START_PI)`
      this.piUint8Array[off_] << 8 | this.piUint8Array[off_ + 1]

    @readPi32 = (a) =>
      `const off_ = (a-MEMORY_START_PI)`
      this.piUint8Array[off_] << 24 | this.piUint8Array[off_ + 1] << 16 | this.piUint8Array[off_ + 2] << 8 | this.piUint8Array[off_ + 3]

    @readSi8 = (a) =>
      `const off_ = a - MEMORY_START_SI`
      this.core.interrupts.readSI off_

    @readSi16 = (a) =>
      `const off_ = a - MEMORY_START_SI`
      this.core.interrupts.readSI off_

    @readSi32 = (a) =>
      `const off_ = a - MEMORY_START_SI`
      this.core.interrupts.readSI off_

    @readC2A1_8 = (a) =>
      `const off_ = a - MEMORY_START_C2A1`
      this.c2a1Uint8Array[off_]

    @readC2A1_16 = (a) =>
      `const off_ = (a-MEMORY_START_C2A1)`
      this.c2a1Uint8Array[off_] << 8 | this.c2a1Uint8Array[off_ + 1]

    @readC2A1_32 = (a) =>
      `const off_ = (a-MEMORY_START_C2A1)`
      this.c2a1Uint8Array[off_] << 24 | this.c2a1Uint8Array[off_ + 1] << 16 | this.c2a1Uint8Array[off_ + 2] << 8 | this.c2a1Uint8Array[off_ + 3]

    @readC1A1_8 = (a) =>
      `const off_ = a - MEMORY_START_C1A1`
      this.c1a1Uint8Array[off_]

    @readC1A1_16 = (a) =>
      `const off_ = (a-MEMORY_START_C1A1)`
      this.c1a1Uint8Array[off_] << 8 | this.c1a1Uint8Array[off_ + 1]

    @readC1A1_32 = (a) =>
      `const off_ = (a-MEMORY_START_C1A1)`
      this.c1a1Uint8Array[off_] << 24 | this.c1a1Uint8Array[off_ + 1] << 16 | this.c1a1Uint8Array[off_ + 2] << 8 | this.c1a1Uint8Array[off_ + 3]

    @readC2A2_8 = (a) =>
      `const off_ = a - MEMORY_START_C2A2`
      this.c2a2Uint8Array[off_]

    @readC2A2_16 = (a) =>
      `const off_ = (a-MEMORY_START_C2A2)`
      this.c2a2Uint8Array[off_] << 8 | this.c2a2Uint8Array[off_ + 1]

    @readC2A2_32 = (a) =>
      `const off_ = (a-MEMORY_START_C2A2)`
      this.c2a2Uint8Array[off_] << 24 | this.c2a2Uint8Array[off_ + 1] << 16 | this.c2a2Uint8Array[off_ + 2] << 8 | this.c2a2Uint8Array[off_ + 3]

    @readRom8 = (a) =>
      `const off_ = a - MEMORY_START_ROM_IMAGE`
      this.romUint8Array[off_]

    @readRom16 = (a) =>
      `const off_ = (a-MEMORY_START_ROM_IMAGE)`
      this.romUint8Array[off_] << 8 | this.romUint8Array[off_ + 1]

    @readRom32 = (a) =>
      `const off_ = (a-MEMORY_START_ROM_IMAGE)`
      this.romUint8Array[off_] << 24 | this.romUint8Array[off_ + 1] << 16 | this.romUint8Array[off_ + 2] << 8 | this.romUint8Array[off_ + 3]

    @readC1A3_8 = (a) =>
      `const off_ = a - MEMORY_START_C1A3`
      this.c1a3Uint8Array[off_]

    @readC1A3_16 = (a) =>
      `const off_ = (a-MEMORY_START_C1A3)`
      this.c1a3Uint8Array[off_] << 8 | this.c1a3Uint8Array[off_ + 1]

    @readC1A3_32 = (a) =>
      `const off_ = (a-MEMORY_START_C1A3)`
      this.c1a3Uint8Array[off_] << 24 | this.c1a3Uint8Array[off_ + 1] << 16 | this.c1a3Uint8Array[off_ + 2] << 8 | this.c1a3Uint8Array[off_ + 3]

    @readRi8 = (a) =>
      `const off_ = a - MEMORY_START_RI`
      this.riUint8Array[off_]

    @readRi16 = (a) =>
      `const off_ = (a-MEMORY_START_RI)`
      this.riUint8Array[off_] << 8 | this.riUint8Array[off_ + 1]

    @readRi32 = (a) =>
      `const off_ = (a-MEMORY_START_RI)`
      this.riUint8Array[off_] << 24 | this.riUint8Array[off_ + 1] << 16 | this.riUint8Array[off_ + 2] << 8 | this.riUint8Array[off_ + 3]

    @readPif8 = (a) =>
      `const off_ = a - MEMORY_START_PIF`
      this.pifUint8Array[off_]

    @readPif16 = (a) =>
      `const off_ = (a-MEMORY_START_PIF)`
      this.pifUint8Array[off_] << 8 | this.pifUint8Array[off_ + 1]

    @readPif32 = (a) =>
      `const off_ = (a-MEMORY_START_PIF)`
      this.pifUint8Array[off_] << 24 | this.pifUint8Array[off_ + 1] << 16 | this.pifUint8Array[off_ + 2] << 8 | this.pifUint8Array[off_ + 3]

    @readGio8 = (a) =>
      `const off_ = a - MEMORY_START_GIO`
      this.gioUint8Array[off_]

    @readGio16 = (a) =>
      `const off_ = (a-MEMORY_START_GIO)`
      this.gioUint8Array[off_] << 8 | this.gioUint8Array[off_ + 1]

    @readGio32 = (a) =>
      `const off_ = (a-MEMORY_START_GIO)`
      this.gioUint8Array[off_] << 24 | this.gioUint8Array[off_ + 1] << 16 | this.gioUint8Array[off_ + 2] << 8 | this.gioUint8Array[off_ + 3]

    @writeRdram8 = (val, a) =>
      this.u8[a] = val
      return

    @writeRdram16 = (val, a) =>
      `const ram = this.u8`
      ram[a] = val >> 8
      ram[a + 1] = val
      return

    @writeRdram32 = (val, a) =>
      `const ram = this.u8`
      ram[a] = val >> 24
      ram[a + 1] = val >> 16
      ram[a + 2] = val >> 8
      ram[a + 3] = val
      return

    @writeSpMem8 = (val, a) =>
      `const off_ = a - MEMORY_START_SPMEM`
      this.spMemUint8Array[off_] = val
      return

    @writeSpMem16 = (val, a) =>
      `const off_ = a - MEMORY_START_SPMEM`
      this.spMemUint8Array[off_] = val >> 8
      this.spMemUint8Array[off_ + 1] = val
      return

    @writeSpMem32 = (val, a) =>
      `const off_ = a - MEMORY_START_SPMEM`
      `const mem = this.spMemUint8Array`
      mem[off_] = val >> 24
      mem[off_ + 1] = val >> 16
      mem[off_ + 2] = val >> 8
      mem[off_ + 3] = val
      return

    @writeRi8 = (val, a) =>
      `const off_ = a - MEMORY_START_RI`
      this.riUint8Array[off_] = val
      return

    @writeRi16 = (val, a) =>
      `const off_ = a - MEMORY_START_RI`
      this.riUint8Array[off_] = val >> 8
      this.riUint8Array[off_ + 1] = val
      return

    @writeRi32 = (val, a) =>
      `const off_ = a - MEMORY_START_RI`
      this.riUint8Array[off_] = val >> 24
      this.riUint8Array[off_ + 1] = val >> 16
      this.riUint8Array[off_ + 2] = val >> 8
      this.riUint8Array[off_ + 3] = val
      return

    @writeMi8 = (val, a, pc, isDelaySlot) =>
      `const off_ = a - MEMORY_START_MI`
      this.core.interrupts.writeMI off_, val, pc, isDelaySlot
      return

    @writeMi16 = (val, a, pc, isDelaySlot) =>
      `const off_ = a - MEMORY_START_MI`
      this.core.interrupts.writeMI off_, val, pc, isDelaySlot
      return

    @writeMi32 = (val, a, pc, isDelaySlot) =>
      `const off_ = a - MEMORY_START_MI`
      this.core.interrupts.writeMI off_, val, pc, isDelaySlot
      return

    @writeRamRegs8_8 = (val, a) =>
      `const off_ = a - MEMORY_START_RAMREGS8`
      this.ramRegs8Uint8Array[off_] = val
      return

    @writeRamRegs8_16 = (val, a) =>
      `const off_ = a - MEMORY_START_RAMREGS8`
      this.ramRegs8Uint8Array[off_] = val >> 8
      this.ramRegs8Uint8Array[off_ + 1] = val
      return

    @writeRamRegs8_32 = (val, a) =>
      `const off_ = a - MEMORY_START_RAMREGS8`
      this.ramRegs8Uint8Array[off_] = val >> 24
      this.ramRegs8Uint8Array[off_ + 1] = val >> 16
      this.ramRegs8Uint8Array[off_ + 2] = val >> 8
      this.ramRegs8Uint8Array[off_ + 3] = val
      return

    @writeRamRegs4_8 = (val, a) =>
      `const off_ = a - MEMORY_START_RAMREGS4`
      this.ramRegs4Uint8Array[off_] = val
      return

    @writeRamRegs4_16 = (val, a) =>
      `const off_ = a - MEMORY_START_RAMREGS4`
      this.ramRegs4Uint8Array[off_] = val >> 8
      this.ramRegs4Uint8Array[off_ + 1] = val
      return

    @writeRamRegs4_32 = (val, a) =>
      `const off_ = a - MEMORY_START_RAMREGS4`
      this.ramRegs4Uint8Array[off_] = val >> 24
      this.ramRegs4Uint8Array[off_ + 1] = val >> 16
      this.ramRegs4Uint8Array[off_ + 2] = val >> 8
      this.ramRegs4Uint8Array[off_ + 3] = val
      return

    @writeRamRegs0_8 = (val, a) =>
      `const off_ = a - MEMORY_START_RAMREGS0`
      this.ramRegs0Uint8Array[off_] = val
      return

    @writeRamRegs0_16 = (val, a) =>
      `const off_ = a - MEMORY_START_RAMREGS0`
      this.ramRegs0Uint8Array[off_] = val >> 8
      this.ramRegs0Uint8Array[off_ + 1] = val
      return

    @writeRamRegs0_32 = (val, a) =>
      `const off_ = a - MEMORY_START_RAMREGS0`
      this.ramRegs0Uint8Array[off_] = val >> 24
      this.ramRegs0Uint8Array[off_ + 1] = val >> 16
      this.ramRegs0Uint8Array[off_ + 2] = val >> 8
      this.ramRegs0Uint8Array[off_ + 3] = val
      return

    @writeSpReg1_8 = (val, a, pc, isDelaySlot) =>
      `const off_ = a - MEMORY_START_SPREG_1`
      this.core.interrupts.writeSPReg1 off_, val, pc, isDelaySlot
      return

    @writeSpReg1_16 = (val, a, pc, isDelaySlot) =>
      `const off_ = a - MEMORY_START_SPREG_1`
      this.core.interrupts.writeSPReg1 off_, val, pc, isDelaySlot
      return

    @writeSpReg1_32 = (val, a, pc, isDelaySlot) =>
      `const off_ = a - MEMORY_START_SPREG_1`
      this.core.interrupts.writeSPReg1 off_, val, pc, isDelaySlot
      return

    @writePi8 = (val, a, pc, isDelaySlot) =>
      `const off_ = a - MEMORY_START_PI`
      this.core.interrupts.writePI off_, val, pc, isDelaySlot
      return

    @writePi16 = (val, a, pc, isDelaySlot) =>
      `const off_ = a - MEMORY_START_PI`
      this.core.interrupts.writePI off_, val, pc, isDelaySlot
      return

    @writePi32 = (val, a, pc, isDelaySlot) =>
      `const off_ = a - MEMORY_START_PI`
      this.core.interrupts.writePI off_, val, pc, isDelaySlot
      return

    @writeSi8 = (val, a, pc, isDelaySlot) =>
      `const off_ = a - MEMORY_START_SI`
      this.core.interrupts.writeSI off_, val, pc, isDelaySlot
      return

    @writeSi16 = (val, a, pc, isDelaySlot) =>
      `const off_ = a - MEMORY_START_SI`
      this.core.interrupts.writeSI off_, val, pc, isDelaySlot
      return

    @writeSi32 = (val, a, pc, isDelaySlot) =>
      `const off_ = a - MEMORY_START_SI`
      this.core.interrupts.writeSI off_, val, pc, isDelaySlot
      return

    @writeAi8 = (val, a, pc, isDelaySlot) =>
      `const off_ = a - MEMORY_START_AI`
      this.core.interrupts.writeAI off_, val, pc, isDelaySlot
      return

    @writeAi16 = (val, a, pc, isDelaySlot) =>
      `const off_ = a - MEMORY_START_AI`
      this.core.interrupts.writeAI off_, val, pc, isDelaySlot
      return

    @writeAi32 = (val, a, pc, isDelaySlot) =>
      `const off_ = a - MEMORY_START_AI`
      this.core.interrupts.writeAI off_, val, pc, isDelaySlot
      return

    @writeVi8 = (val, a, pc, isDelaySlot) =>
      `const off_ = a - MEMORY_START_VI`
      this.core.interrupts.writeVI off_, val, pc, isDelaySlot
      return

    @writeVi16 = (val, a, pc, isDelaySlot) =>
      `const off_ = a - MEMORY_START_VI`
      this.core.interrupts.writeVI off_, val, pc, isDelaySlot
      return

    @writeVi32 = (val, a, pc, isDelaySlot) =>
      `const off_ = a - MEMORY_START_VI`
      this.core.interrupts.writeVI off_, val, pc, isDelaySlot
      return

    @writeSpReg2_8 = (val, a, pc, isDelaySlot) =>
      `const off_ = a - MEMORY_START_SPREG_2`
      this.core.interrupts.writeSPReg2 off_, val, pc, isDelaySlot
      return

    @writeSpReg2_16 = (val, a, pc, isDelaySlot) =>
      `const off_ = a - MEMORY_START_SPREG_2`
      this.core.interrupts.writeSPReg2 off_, val, pc, isDelaySlot
      return

    @writeSpReg2_32 = (val, a, pc, isDelaySlot) =>
      `const off_ = a - MEMORY_START_SPREG_2`
      this.core.interrupts.writeSPReg2 off_, val, pc, isDelaySlot
      return

    @writeDpc8 = (val, a, pc, isDelaySlot) =>
      `const off_ = a - MEMORY_START_DPC`
      this.core.interrupts.writeDPC off_, val, pc, isDelaySlot
      return

    @writeDpc16 = (val, a, pc, isDelaySlot) =>
      `const off_ = a - MEMORY_START_DPC`
      this.core.interrupts.writeDPC off_, val, pc, isDelaySlot
      return

    @writeDpc32 = (val, a, pc, isDelaySlot) =>
      `const off_ = a - MEMORY_START_DPC`
      this.core.interrupts.writeDPC off_, val, pc, isDelaySlot
      return

    @writeDps8 = (val, a) =>
      `const off_ = a - MEMORY_START_DPS`
      this.dpsUint8Array[off_] = val
      return

    @writeDps16 = (val, a) =>
      `const off_ = a - MEMORY_START_DPS`
      this.dpsUint8Array[off_] = val >> 8
      this.dpsUint8Array[off_ + 1] = val
      return

    @writeDps32 = (val, a) =>
      `const off_ = a - MEMORY_START_DPS`
      this.dpsUint8Array[off_] = val >> 24
      this.dpsUint8Array[off_ + 1] = val >> 16
      this.dpsUint8Array[off_ + 2] = val >> 8
      this.dpsUint8Array[off_ + 3] = val
      return

    @writeC2A1_8 = (val, a) =>
      `const off_ = a - MEMORY_START_C2A1`
      this.c2a1Uint8Array[off_] = val
      return

    @writeC2A1_16 = (val, a) =>
      `const off_ = a - MEMORY_START_C2A1`
      this.c2a1Uint8Array[off_] = val >> 8
      this.c2a1Uint8Array[off_ + 1] = val
      return

    @writeC2A1_32 = (val, a) =>
      `const off_ = a - MEMORY_START_C2A1`
      this.c2a1Uint8Array[off_] = val >> 24
      this.c2a1Uint8Array[off_ + 1] = val >> 16
      this.c2a1Uint8Array[off_ + 2] = val >> 8
      this.c2a1Uint8Array[off_ + 3] = val
      return

    @writeC1A1_8 = (val, a) =>
      `const off_ = a - MEMORY_START_C1A1`
      this.c1a1Uint8Array[off_] = val
      return

    @writeC1A1_16 = (val, a) =>
      `const off_ = a - MEMORY_START_C1A1`
      this.c1a1Uint8Array[off_] = val >> 8
      this.c1a1Uint8Array[off_ + 1] = val
      return

    @writeC1A1_32 = (val, a) =>
      `const off_ = a - MEMORY_START_C1A1`
      this.c1a1Uint8Array[off_] = val >> 24
      this.c1a1Uint8Array[off_ + 1] = val >> 16
      this.c1a1Uint8Array[off_ + 2] = val >> 8
      this.c1a1Uint8Array[off_ + 3] = val
      return

    @writeC2A2_8 = (val, a) =>
      `const off_ = a - MEMORY_START_C2A2`
      this.c2a2Uint8Array[off_] = val
      return

    @writeC2A2_16 = (val, a) =>
      `const off_ = a - MEMORY_START_C2A2`
      this.c2a2Uint8Array[off_] = val >> 8
      this.c2a2Uint8Array[off_ + 1] = val
      return

    @writeC2A2_32 = (val, a) =>
      `const off_ = a - MEMORY_START_C2A2`
      this.c2a2Uint8Array[off_] = val >> 24
      this.c2a2Uint8Array[off_ + 1] = val >> 16
      this.c2a2Uint8Array[off_ + 2] = val >> 8
      this.c2a2Uint8Array[off_ + 3] = val
      return

    @writeRom8 = (val, a) =>
      alert "attempt to overwrite rom!"
      `const off_ = a - MEMORY_START_ROM_IMAGE`
      this.romUint8Array[off_] = val
      return

    @writeRom16 = (val, a) =>
      `const off_ = a - MEMORY_START_ROM_IMAGE`
      this.romUint8Array[off_] = val >> 8
      this.romUint8Array[off_ + 1] = val
      return

    @writeRom32 = (val, a) =>
      `const off_ = a - MEMORY_START_ROM_IMAGE`
      this.romUint8Array[off_] = val >> 24
      this.romUint8Array[off_ + 1] = val >> 16
      this.romUint8Array[off_ + 2] = val >> 8
      this.romUint8Array[off_ + 3] = val
      return

    @writeC1A3_8 = (val, a) =>
      `const off_ = a - MEMORY_START_C1A3`
      this.c1a3Uint8Array[off_] = val
      return

    @writeC1A3_16 = (val, a) =>
      `const off_ = a - MEMORY_START_C1A3`
      this.c1a3Uint8Array[off_] = val >> 8
      this.c1a3Uint8Array[off_ + 1] = val
      return

    @writeC1A3_32 = (val, a) =>
      `const off_ = a - MEMORY_START_C1A3`
      this.c1a3Uint8Array[off_] = val >> 24
      this.c1a3Uint8Array[off_ + 1] = val >> 16
      this.c1a3Uint8Array[off_ + 2] = val >> 8
      this.c1a3Uint8Array[off_ + 3] = val
      return

    @writePif8 = (val, a) =>
      `const off_ = a - MEMORY_START_PIF`
      this.pifUint8Array[off_] = val
      return

    @writePif16 = (val, a) =>
      `const off_ = a - MEMORY_START_PIF`
      this.pifUint8Array[off_] = val >> 8
      this.pifUint8Array[off_ + 1] = val
      return

    @writePif32 = (val, a) =>
      `const off_ = a - MEMORY_START_PIF`
      this.pifUint8Array[off_] = val >> 24
      this.pifUint8Array[off_ + 1] = val >> 16
      this.pifUint8Array[off_ + 2] = val >> 8
      this.pifUint8Array[off_ + 3] = val
      return

    @writeGio8 = (val, a) =>
      `const off_ = a - MEMORY_START_GIO`
      this.gioUint8Array[off_] = val
      return

    @writeGio16 = (val, a) =>
      `const off_ = a - MEMORY_START_GIO`
      this.gioUint8Array[off_] = val >> 8
      this.gioUint8Array[off_ + 1] = val
      return

    @writeGio32 = (val, a) =>
      `const off_ = a - MEMORY_START_GIO`
      this.gioUint8Array[off_] = val >> 24
      this.gioUint8Array[off_ + 1] = val >> 16
      this.gioUint8Array[off_ + 2] = val >> 8
      this.gioUint8Array[off_ + 3] = val
      return

    @writeDummy8 = (val, a) =>
      #log "writing to invalid memory at " + dec2hex(a)
      `const off_ = a & 0x0000fffc`
      this.dummyReadWriteUint8Array[off_] = val
      return

    @writeDummy16 = (val, a) =>
      `const off_ = a & 0x0000fffc`
      this.dummyReadWriteUint8Array[off_] = val >> 8
      this.dummyReadWriteUint8Array[off_ + 1] = val
      return

    @writeDummy32 = (val, a) =>
      `const off_ = a & 0x0000fffc`
      this.dummyReadWriteUint8Array[off_] = val >> 24
      this.dummyReadWriteUint8Array[off_ + 1] = val >> 16
      this.dummyReadWriteUint8Array[off_ + 2] = val >> 8
      this.dummyReadWriteUint8Array[off_ + 3] = val
      return

    @virtualToPhysical = (a) =>
      #uncomment to see where we're loading/storing
      #if ((((a & 0xF0000000)>>>0) isnt 0x80000000) and (((a & 0xF0000000)>>>0) isnt 0xA0000000))
      #  alert(dec2hex(a))

      #uncomment to verify non-tlb lookup.
      #if dec2hex(a) != dec2hex(((t[a>>>12]<<16) | a&0x0000ffff))
      #  alert dec2hex(a) + ' ' + dec2hex(((t[a>>>12]<<16) | a&0x0000ffff))
      return ((@t[a>>>12]<<16) | (a&0x0000ffff))

    @readTLB8 = (b) =>
      `const a = this.virtualToPhysical(b)`

      region = this.LB[a>>>16]

      if region is this.readTLB8
        region = this.readDummy8

      region(a)

    @writeTLB8 = (val, b, pc, isDelaySlot) =>
      `const a = this.virtualToPhysical(b)`

      region = this.SB[a>>>16]

      if region is this.writeTLB8
        region = this.writeDummy8

      region(val, a, pc, isDelaySlot)
      return

    @readTLB16 = (b) =>
      `const a = this.virtualToPhysical(b)`

      region = this.LH[a>>>16]

      if region is this.readTLB16
        region = this.readDummy16

      region(a)

    @writeTLB16 = (val, b, pc, isDelaySlot) =>
      `const a = this.virtualToPhysical(b)`

      region = this.SH[a>>>16]

      if region is this.writeTLB16
        region = this.writeDummy16

      region(val, a, pc, isDelaySlot)
      return

    @readTLB32 = (b) =>
      `const a = this.virtualToPhysical(b)`

      region = this.LW[a>>>16]

      if region is this.readTLB32
        region = this.readDummy32

      region(a)

    @writeTLB32 = (val, b, pc, isDelaySlot) =>
      `const a = this.virtualToPhysical(b)`

      region = this.SW[a>>>16]

      if region is this.writeTLB32
        region = this.writeDummy32

      region(val, a, pc, isDelaySlot)
      return

    return

  initRegions: () ->
    @initRegion 0, 0x80000000, @readTLB8, @writeTLB8, @readTLB16, @writeTLB16, @readTLB32, @writeTLB32
    @initRegion 0x80000000, 0x40000000, @readDummy8, @writeDummy8, @readDummy16, @writeDummy16, @readDummy32, @writeDummy32
    @initRegion 0xC0000000, 0x40000000, @readTLB8, @writeTLB8, @readTLB16, @writeTLB16, @readTLB32, @writeTLB32
    @initRegion MEMORY_START_RDRAM, MEMORY_SIZE_RDRAM, @readRdram8, @writeRdram8, @readRdram16, @writeRdram16, @readRdram32, @writeRdram32
    @initRegion MEMORY_START_RAMREGS4, MEMORY_SIZE_RAMREGS4, @readRamRegs4_8, @writeRamRegs4_8, @readRamRegs4_16, @writeRamRegs4_16, @readRamRegs4_32, @writeRamRegs4_32
    @initRegion MEMORY_START_SPMEM, MEMORY_SIZE_SPMEM, @readSpMem8, @writeSpMem8, @readSpMem16, @writeSpMem16, @readSpMem32, @writeSpMem32
    @initRegion MEMORY_START_SPREG_1, MEMORY_SIZE_SPREG_1, @readSpReg1_8, @writeSpReg1_8, @readSpReg1_16, @writeSpReg1_16, @readSpReg1_32, @writeSpReg1_32
    @initRegion MEMORY_START_SPREG_2, MEMORY_SIZE_SPREG_2, @readSpReg2_8, @writeSpReg2_8, @readSpReg2_16, @writeSpReg2_16, @readSpReg2_32, @writeSpReg2_32
    @initRegion MEMORY_START_DPC, MEMORY_SIZE_DPC, @readDpc8, @writeDpc8, @readDpc16, @writeDpc16, @readDpc32, @writeDpc32
    @initRegion MEMORY_START_DPS, MEMORY_SIZE_DPS, @readDps8, @writeDps8, @readDps16, @writeDps16, @readDps32, @writeDps32
    @initRegion MEMORY_START_MI, MEMORY_SIZE_MI, @readMi8, @writeMi8, @readMi16, @writeMi16, @readMi32, @writeMi32
    @initRegion MEMORY_START_VI, MEMORY_SIZE_VI, @readVi8, @writeVi8, @readVi16, @writeVi16, @readVi32, @writeVi32
    @initRegion MEMORY_START_AI, MEMORY_SIZE_AI, @readAi8, @writeAi8, @readAi16, @writeAi16, @readAi32, @writeAi32
    @initRegion MEMORY_START_PI, MEMORY_SIZE_PI, @readPi8, @writePi8, @readPi16, @writePi16, @readPi32, @writePi32
    @initRegion MEMORY_START_SI, MEMORY_SIZE_SI, @readSi8, @writeSi8, @readSi16, @writeSi16, @readSi32, @writeSi32
    @initRegion MEMORY_START_C2A1, MEMORY_SIZE_C2A1, @readC2A1_8, @writeC2A1_8, @readC2A1_16, @writeC2A1_16, @readC2A1_32, @writeC2A1_32
    @initRegion MEMORY_START_C1A1, MEMORY_SIZE_C1A1, @readC1A1_8, @writeC1A1_8, @readC1A1_16, @writeC1A1_16, @readC1A1_32, @writeC1A1_32
    @initRegion MEMORY_START_C2A2, MEMORY_SIZE_C2A2, @readC2A2_8, @writeC2A2_8, @readC2A2_16, @writeC2A2_16, @readC2A2_32, @writeC2A2_32
    @initRegion MEMORY_START_ROM_IMAGE, MEMORY_SIZE_ROM, @readRom8, @writeRom8, @readRom16, @writeRom16, @readRom32, @writeRom32 #todo: could be a problem to use romLength
    @initRegion MEMORY_START_C1A3, MEMORY_SIZE_C1A3, @readC1A3_8, @writeC1A3_8, @readC1A3_16, @writeC1A3_16, @readC1A3_32, @writeC1A3_32
    @initRegion MEMORY_START_RI, MEMORY_SIZE_RI, @readRi8, @writeRi8, @readRi16, @writeRi16, @readRi32, @writeRi32
    @initRegion MEMORY_START_PIF, MEMORY_SIZE_PIF, @readPif8, @writePif8, @readPif16, @writePif16, @readPif32, @writePif32
    @initRegion MEMORY_START_GIO, MEMORY_SIZE_GIO, @readGio8, @writeGio8, @readGio16, @writeGio16, @readGio32, @writeGio32
    @initRegion MEMORY_START_RAMREGS0, MEMORY_SIZE_RAMREGS0, @readRamRegs0_8, @writeRamRegs0_8, @readRamRegs0_16, @writeRamRegs0_16, @readRamRegs0_32, @writeRamRegs0_32
    @initRegion MEMORY_START_RAMREGS8, MEMORY_SIZE_RAMREGS8, @readRamRegs8_8, @writeRamRegs8_8, @readRamRegs8_16, @writeRamRegs8_16, @readRamRegs8_32, @writeRamRegs8_32


  initRegion: (start, size, LB, SB, readLH, SH, readLW, SW) ->
    end = (start + size) >>> 16
    start >>>= 16

    while start < end
      @LB[start] = LB
      @LH[start] = readLH
      @LW[start] = readLW
      @SB[start] = SB
      @SH[start] = SH
      @SW[start] = SW
      start++
      #@lengthy++
    return


  initts: ->
    #Initialize the TLB Lookup Table
    @t = new Int16Array(0x100000)
    i = 0
    #todo: replace with call to buildTLBHelper clear
    while i < 0x100000
      @t[i] = (i & 0x1ffff) >>> 4
      i++
    return

  #getInt32 and getUint32 are identical. they both return signed.
  getInt32: (uregion, off_) ->
    uregion[off_] << 24 | uregion[off_ + 1] << 16 | uregion[off_ + 2] << 8 | uregion[off_ + 3]

  getUint32: (uregion, off_) ->
    uregion[off_] << 24 | uregion[off_ + 1] << 16 | uregion[off_ + 2] << 8 | uregion[off_ + 3]

  setInt32: (uregion, off_, val) ->
    uregion[off_] = val >> 24
    uregion[off_ + 1] = val >> 16
    uregion[off_ + 2] = val >> 8
    uregion[off_ + 3] = val
    return

  setUint32: (uregion, off_, val) ->
    uregion[off_] = val >> 24
    uregion[off_ + 1] = val >> 16
    uregion[off_ + 2] = val >> 8
    uregion[off_ + 3] = val
    return

  lb: (addr) ->
    #throw Error "todo: mirrored load address"  if (addr & 0xff000000) is 0x84000000
    `const a = this.virtualToPhysical(addr)`
    @LB[a>>>16](a)

  lh: (addr) ->
    #throw Error "todo: mirrored load address"  if (addr & 0xff000000) is 0x84000000
    `const a = this.virtualToPhysical(addr)`
    @LH[a>>>16](a)

  lw: (addr) ->
    #throw Error "todo: mirrored load address"  if (addr & 0xff000000) is 0x84000000
    `const a = this.virtualToPhysical(addr)`
    @LW[a>>>16](a)

  sw: (val, addr, pc, isDelaySlot) ->
    `const a = this.virtualToPhysical(addr)`
    @SW[a>>>16](val, a, pc, isDelaySlot)
    return

  #Same routine as storeWord, but store a byte
  sb: (val, addr, pc, isDelaySlot) ->
    `const a = this.virtualToPhysical(addr)`
    @SB[a>>>16](val, a, pc, isDelaySlot)
    return

  sh: (val, addr, pc, isDelaySlot) ->
    `const a = this.virtualToPhysical(addr)`
    @SH[a>>>16](val, a, pc, isDelaySlot)
    return

#hack global space until we export classes properly
#node.js uses exports; browser uses this (window)
root = exports ? self
root.C1964jsMemory = C1964jsMemory
