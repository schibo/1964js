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

C1964jsMemory = (core) ->
  #segments must be at least 64KB in size for lookup table.
  `/** @const */ var MEMORY_START_RDRAM = 0x00000000`
  `/** @const */ var MEMORY_SIZE_RDRAM = 0x800000` #4MB RDRAM + 4MB Expansion = 8MB
  `/** @const */ var MEMORY_START_RAMREGS4 = 0x03F04000`
  `/** @const */ var MEMORY_SIZE_RAMREGS4 = 0x10000`
  `/** @const */ var MEMORY_START_RAMREGS0 = 0x03F00000`
  `/** @const */ var MEMORY_START_RAMREGS8 = 0x03F80000`
  `/** @const */ var MEMORY_SIZE_RAMREGS0 = 0x10000`
  `/** @const */ var MEMORY_SIZE_RAMREGS8 = 0x10000`
  `/** @const */ var MEMORY_START_SPMEM = 0x04000000`
  `/** @const */ var MEMORY_START_SPREG_1 = 0x04040000`
  `/** @const */ var MEMORY_START_SPREG_2 = 0x04080000`
  `/** @const */ var MEMORY_START_DPC = 0x04100000`
  `/** @const */ var MEMORY_START_DPS = 0x04200000`
  `/** @const */ var MEMORY_START_MI = 0x04300000`
  `/** @const */ var MEMORY_START_VI = 0x04400000`
  `/** @const */ var MEMORY_START_AI = 0x04500000`
  `/** @const */ var MEMORY_START_PI = 0x04600000`
  `/** @const */ var MEMORY_START_RI = 0x04700000`
  `/** @const */ var MEMORY_START_SI = 0x04800000`
  `/** @const */ var MEMORY_START_C2A1 = 0x05000000`
  `/** @const */ var MEMORY_START_C1A1 = 0x06000000`
  `/** @const */ var MEMORY_START_C2A2 = 0x08000000`
  `/** @const */ var MEMORY_START_ROM_IMAGE = 0x10000000`
  `/** @const */ var MEMORY_START_GIO = 0x18000000`
  `/** @const */ var MEMORY_START_C1A3 = 0x1FD00000`
  `/** @const */ var MEMORY_START_DUMMY = 0x1FFF0000`
  `/** @const */ var MEMORY_SIZE_SPMEM = 0x10000`
  `/** @const */ var MEMORY_SIZE_SPREG_1 = 0x10000`
  `/** @const */ var MEMORY_SIZE_SPREG_2 = 0x10000`
  `/** @const */ var MEMORY_SIZE_DPC = 0x10000`
  `/** @const */ var MEMORY_SIZE_DPS = 0x10000`
  `/** @const */ var MEMORY_SIZE_MI = 0x10000`
  `/** @const */ var MEMORY_SIZE_VI = 0x10000`
  `/** @const */ var MEMORY_SIZE_AI = 0x10000`
  `/** @const */ var MEMORY_SIZE_PI = 0x10000`
  `/** @const */ var MEMORY_SIZE_RI = 0x10000`
  `/** @const */ var MEMORY_SIZE_SI = 0x10000`
  `/** @const */ var MEMORY_SIZE_C2A1 = 0x10000`
  `/** @const */ var MEMORY_SIZE_C1A1 = 0x10000`
  `/** @const */ var MEMORY_SIZE_C2A2 = 0x20000`
  `/** @const */ var MEMORY_SIZE_GIO = 0x10000`
  `/** @const */ var MEMORY_SIZE_C1A3 = 0x10000`
  `/** @const */ var MEMORY_SIZE_DUMMY = 0x10000`
  `/** @const */ var MEMORY_START_PIF = 0x1FC00000`
  `/** @const */ var MEMORY_START_PIF_RAM = 0x1FC007C0`
  `/** @const */ var MEMORY_SIZE_PIF = 0x10000`
  `/** @const */ var MEMORY_SIZE_ROM = 0x4000000`

  this.core = core
  @romUint8Array = `undefined` # set after rom is loaded.
  @rom = `undefined` # set after rom is loaded.
  @rdramUint8Array = new Uint8Array(0x800000)
  @spMemUint8Array = new Uint8Array(0x10000)
  @spReg1Uint8Array = new Uint8Array(0x10000)
  @spReg2Uint8Array = new Uint8Array(0x10000)
  @dpcUint8Array = new Uint8Array(0x10000)
  @dpsUint8Array = new Uint8Array(0x10000)
  @miUint8Array = new Uint8Array(0x10000)
  @viUint8Array = new Uint8Array(0x10000)
  @aiUint8Array = new Uint8Array(0x10000)
  @piUint8Array = new Uint8Array(0x10000)
  @siUint8Array = new Uint8Array(0x10000)
  @c2a1Uint8Array = new Uint8Array(0x10000)
  @c1a1Uint8Array = new Uint8Array(0x10000)
  @c2a2Uint8Array = new Uint8Array(0x10000)
  @c1a3Uint8Array = new Uint8Array(0x10000)
  @riUint8Array = new Uint8Array(0x10000)
  @pifUint8Array = new Uint8Array(0x10000)
  @gioUint8Array = new Uint8Array(0x10000)
  @ramRegs0Uint8Array = new Uint8Array(0x10000)
  @ramRegs4Uint8Array = new Uint8Array(0x10000)
  @ramRegs8Uint8Array = new Uint8Array(0x10000)
  @dummyReadWriteUint8Array = new Uint8Array(0x10000)

  @region = []

  @initRegion = (start, size, region) ->
    end = (start + size) >>> 14
    start >>>= 14

    while start < end
      @region[start++] = region
    return

  @readDummy = (that, a, getFn) ->
    off_ = a & 0x0000FFFF
    getFn that.dummyReadWriteUint8Array, off_

  @readRdram = (that, a, getFn) ->
    off_ = a-MEMORY_START_RDRAM
    getFn that.rdramUint8Array, off_

  @readRamRegs0 = (that, a, getFn) ->
    off_ = a - MEMORY_START_RAMREGS0
    getFn that.ramRegs0Uint8Array, off_

  @readRamRegs4 = (that, a, getFn) ->
    off_ = a - MEMORY_START_RAMREGS4
    getFn that.ramRegs4Uint8Array, off_

  @readRamRegs8 = (that, a, getFn) ->
    off_ = a - MEMORY_START_RAMREGS8
    getFn that.ramRegs8Uint8Array, off_

  @readSpMem = (that, a, getFn) ->
    off_ = a - MEMORY_START_SPMEM
    getFn that.spMemUint8Array, off_

  @readSpReg1 = (that, a) ->
    off_ = a - MEMORY_START_SPREG_1
    that.core.interrupts.readSPReg1 off_

  @readSpReg2 = (that, a, getFn) ->
    off_ = a - MEMORY_START_SPREG_2
    getFn that.spReg2Uint8Array, off_

  @readDpc = (that, a, getFn) ->
    off_ = a - MEMORY_START_DPC
    getFn that.dpcUint8Array, off_

  @readDps = (that, a, getFn) ->
    off_ = a - MEMORY_START_DPS
    getFn that.dpsUint8Array, off_

  @readMi = (that, a, getFn) ->
    off_ = a - MEMORY_START_MI
    getFn that.miUint8Array, off_

  @readVi = (that, a) ->
    off_ = a - MEMORY_START_VI
    that.core.interrupts.readVI off_

  @readAi = (that, a) ->
    off_ = a - MEMORY_START_AI
    that.core.interrupts.readAI off_
  
  @readPi = (that, a, getFn) ->
    off_ = a - MEMORY_START_PI
    getFn that.piUint8Array, off_
  
  @readSi = (that, a) ->
    off_ = a - MEMORY_START_SI
    that.core.interrupts.readSI off_

  @readC2A1 = (that, a, getFn) ->
    off_ = a - MEMORY_START_C2A1
    getFn that.c2a1Uint8Array, off_

  @readC1A1 = (that, a, getFn) ->
    off_ = a - MEMORY_START_C1A1
    getFn that.c1a1Uint8Array, off_

  @readC2A2 = (that, a, getFn) ->
    off_ = a - MEMORY_START_C2A2
    getFn that.c2a2Uint8Array, off_

  @readRom = (that, a, getFn) ->
    off_ = a - MEMORY_START_ROM_IMAGE
    getFn that.romUint8Array, off_

  @readC1A3 = (that, a, getFn) ->
    off_ = a - MEMORY_START_C1A3
    getFn that.c1a3Uint8Array, off_

  @readRi = (that, a, getFn) ->
    off_ = a - MEMORY_START_RI
    getFn that.riUint8Array, off_

  @readPif = (that, a, getFn) ->
    off_ = a - MEMORY_START_PIF
    getFn that.pifUint8Array, off_

  @readGio = (that, a, getFn) ->
    off_ = a - MEMORY_START_GIO
    getFn that.gioUint8Array, off_

  @initRegion 0, 0x20000000, @readDummy
  @initRegion MEMORY_START_RDRAM, MEMORY_SIZE_RDRAM, @readRdram
  @initRegion MEMORY_START_RAMREGS4, MEMORY_START_RAMREGS4, @readRamRegs4
  @initRegion MEMORY_START_SPMEM, MEMORY_SIZE_SPMEM, @readSpMem
  @initRegion MEMORY_START_SPREG_1, MEMORY_SIZE_SPREG_1, @readSpReg1
  @initRegion MEMORY_START_SPREG_2, MEMORY_SIZE_SPREG_2, @readSpReg2
  @initRegion MEMORY_START_DPC, MEMORY_SIZE_DPC, @readDpc
  @initRegion MEMORY_START_DPS, MEMORY_SIZE_DPS, @readDps
  @initRegion MEMORY_START_MI, MEMORY_SIZE_MI, @readMi
  @initRegion MEMORY_START_VI, MEMORY_SIZE_VI, @readVi
  @initRegion MEMORY_START_AI, MEMORY_SIZE_AI, @readAi
  @initRegion MEMORY_START_PI, MEMORY_SIZE_PI, @readPi
  @initRegion MEMORY_START_SI, MEMORY_SIZE_SI, @readSi
  @initRegion MEMORY_START_C2A1, MEMORY_SIZE_C2A1, @readC2A1
  @initRegion MEMORY_START_C1A1, MEMORY_SIZE_C1A1, @readC1A1
  @initRegion MEMORY_START_C2A2, MEMORY_SIZE_C2A2, @readC2A2
  @initRegion MEMORY_START_ROM_IMAGE, MEMORY_SIZE_ROM, @readRom #todo: could be a problem to use romLength
  @initRegion MEMORY_START_C1A3, MEMORY_SIZE_C1A3, @readC1A3
  @initRegion MEMORY_START_RI, MEMORY_SIZE_RI, @readRi
  @initRegion MEMORY_START_PIF, MEMORY_SIZE_PIF, @readPif
  @initRegion MEMORY_START_GIO, MEMORY_SIZE_GIO, @readGio
  @initRegion MEMORY_START_RAMREGS0, MEMORY_SIZE_RAMREGS0, @readRamRegs0
  @initRegion MEMORY_START_RAMREGS8, MEMORY_SIZE_RAMREGS8, @readRamRegs8

  #getInt32 and getUint32 are identical. they both return signed.
  @getInt8 = (region, off_) ->
    region[off_]

  @getInt16 = (region, off_) ->
    region[off_] << 8 | region[off_ + 1]

  @getInt32 = (sregion, uregion, off_) ->
    uregion[off_] << 24 | uregion[off_ + 1] << 16 | uregion[off_ + 2] << 8 | uregion[off_ + 3]

  @getUint32 = (uregion, off_) ->
    uregion[off_] << 24 | uregion[off_ + 1] << 16 | uregion[off_ + 2] << 8 | uregion[off_ + 3]

  @setInt32 = (uregion, off_, val) ->
    uregion[off_] = val >> 24
    uregion[off_ + 1] = val >> 16
    uregion[off_ + 2] = val >> 8
    uregion[off_ + 3] = val
    return

  @loadByte = (addr) ->
    #throw Error "todo: mirrored load address"  if (addr & 0xff000000) is 0x84000000
    a = addr & 0x1FFFFFFF
    @region[a>>>14](this, a, @getInt8)

  @loadHalf = (addr) ->
    #throw Error "todo: mirrored load address"  if (addr & 0xff000000) is 0x84000000
    a = addr & 0x1FFFFFFF
    @region[a>>>14](this, a, @getInt16)

  @loadWord = (addr) ->
    #throw Error "todo: mirrored load address"  if (addr & 0xff000000) is 0x84000000
    a = addr & 0x1FFFFFFF
    @region[a>>>14](this, a, @getUint32)

  @storeWord = (val, addr, pc, isDelaySlot) ->
    a = addr & 0x1FFFFFFF
    if a >= MEMORY_START_RDRAM and a < MEMORY_START_RDRAM + MEMORY_SIZE_RDRAM
      off_ = a - MEMORY_START_RDRAM
      @rdramUint8Array[off_] = val >> 24
      @rdramUint8Array[off_ + 1] = val >> 16
      @rdramUint8Array[off_ + 2] = val >> 8
      @rdramUint8Array[off_ + 3] = val
      return
    else if a >= MEMORY_START_SPMEM and a < MEMORY_START_SPMEM + MEMORY_SIZE_SPMEM
      off_ = a - MEMORY_START_SPMEM
      @spMemUint8Array[off_] = val >> 24
      @spMemUint8Array[off_ + 1] = val >> 16
      @spMemUint8Array[off_ + 2] = val >> 8
      @spMemUint8Array[off_ + 3] = val
      return
    else if a >= MEMORY_START_RI and a < MEMORY_START_RI + MEMORY_SIZE_RI
      off_ = a - MEMORY_START_RI
      @riUint8Array[off_] = val >> 24
      @riUint8Array[off_ + 1] = val >> 16
      @riUint8Array[off_ + 2] = val >> 8
      @riUint8Array[off_ + 3] = val
      return
    else if a >= MEMORY_START_MI and a < MEMORY_START_MI + MEMORY_SIZE_MI
      off_ = a - MEMORY_START_MI
      core.interrupts.writeMI off_, val, pc, isDelaySlot
      return
    else if a >= MEMORY_START_RAMREGS8 and a < MEMORY_START_RAMREGS8 + MEMORY_SIZE_RAMREGS8
      off_ = a - MEMORY_START_RAMREGS8
      @ramRegs8Uint8Array[off_] = val >> 24
      @ramRegs8Uint8Array[off_ + 1] = val >> 16
      @ramRegs8Uint8Array[off_ + 2] = val >> 8
      @ramRegs8Uint8Array[off_ + 3] = val
      return
    else if a >= MEMORY_START_RAMREGS4 and a < MEMORY_START_RAMREGS4 + MEMORY_SIZE_RAMREGS4
      off_ = a - MEMORY_START_RAMREGS4
      @ramRegs4Uint8Array[off_] = val >> 24
      @ramRegs4Uint8Array[off_ + 1] = val >> 16
      @ramRegs4Uint8Array[off_ + 2] = val >> 8
      @ramRegs4Uint8Array[off_ + 3] = val
      return
    else if a >= MEMORY_START_RAMREGS0 and a < MEMORY_START_RAMREGS0 + MEMORY_SIZE_RAMREGS0
      off_ = a - MEMORY_START_RAMREGS0
      @ramRegs0Uint8Array[off_] = val >> 24
      @ramRegs0Uint8Array[off_ + 1] = val >> 16
      @ramRegs0Uint8Array[off_ + 2] = val >> 8
      @ramRegs0Uint8Array[off_ + 3] = val
      return
    else if a >= MEMORY_START_SPREG_1 and a < MEMORY_START_SPREG_1 + MEMORY_SIZE_SPREG_1
      off_ = a - MEMORY_START_SPREG_1
      core.interrupts.writeSPReg1 off_, val, pc, isDelaySlot
      return
    else if a >= MEMORY_START_PI and a < MEMORY_START_PI + MEMORY_SIZE_PI
      off_ = a - MEMORY_START_PI
      core.interrupts.writePI off_, val, pc, isDelaySlot
      return
    else if a >= MEMORY_START_SI and a < MEMORY_START_SI + MEMORY_SIZE_SI
      off_ = a - MEMORY_START_SI
      core.interrupts.writeSI off_, val, pc, isDelaySlot
      return
    else if a >= MEMORY_START_AI and a < MEMORY_START_AI + MEMORY_SIZE_AI
      off_ = a - MEMORY_START_AI
      core.interrupts.writeAI off_, val, pc, isDelaySlot
      return
    else if a >= MEMORY_START_VI and a < MEMORY_START_VI + MEMORY_SIZE_VI
      off_ = a - MEMORY_START_VI
      core.interrupts.writeVI off_, val, pc, isDelaySlot
      return
    else if a >= MEMORY_START_SPREG_2 and a < MEMORY_START_SPREG_2 + MEMORY_SIZE_SPREG_2
      off_ = a - MEMORY_START_SPREG_2
      core.interrupts.writeSPReg2 off_, val, pc, isDelaySlot
      return
    else if a >= MEMORY_START_DPC and a < MEMORY_START_DPC + MEMORY_SIZE_DPC
      off_ = a - MEMORY_START_DPC
      core.interrupts.writeDPC off_, val, pc, isDelaySlot
      return
    else if a >= MEMORY_START_DPS and a < MEMORY_START_DPS + MEMORY_SIZE_DPS
      off_ = a - MEMORY_START_DPS
      @dpsUint8Array[off_] = val >> 24
      @dpsUint8Array[off_ + 1] = val >> 16
      @dpsUint8Array[off_ + 2] = val >> 8
      @dpsUint8Array[off_ + 3] = val
      return
    else if a >= MEMORY_START_C2A1 and a < MEMORY_START_C2A1 + MEMORY_SIZE_C2A1
      off_ = a - MEMORY_START_C2A1
      @c2a1Uint8Array[off_] = val >> 24
      @c2a1Uint8Array[off_ + 1] = val >> 16
      @c2a1Uint8Array[off_ + 2] = val >> 8
      @c2a1Uint8Array[off_ + 3] = val
      return
    else if a >= MEMORY_START_C1A1 and a < MEMORY_START_C1A1 + MEMORY_SIZE_C1A1
      off_ = a - MEMORY_START_C1A1
      @c1a1Uint8Array[off_] = val >> 24
      @c1a1Uint8Array[off_ + 1] = val >> 16
      @c1a1Uint8Array[off_ + 2] = val >> 8
      @c1a1Uint8Array[off_ + 3] = val
      return
    else if a >= MEMORY_START_C2A2 and a < MEMORY_START_C2A2 + MEMORY_SIZE_C2A2
      off_ = a - MEMORY_START_C2A2
      @c2a2Uint8Array[off_] = val >> 24
      @c2a2Uint8Array[off_ + 1] = val >> 16
      @c2a2Uint8Array[off_ + 2] = val >> 8
      @c2a2Uint8Array[off_ + 3] = val
      return
    else if a >= MEMORY_START_ROM_IMAGE and a < MEMORY_START_ROM_IMAGE + romLength
      alert "attempt to overwrite rom!"
      off_ = a - MEMORY_START_ROM_IMAGE
      @romUint8Array[off_] = val >> 24
      @romUint8Array[off_ + 1] = val >> 16
      @romUint8Array[off_ + 2] = val >> 8
      @romUint8Array[off_ + 3] = val
      return
    else if a >= MEMORY_START_C1A3 and a < MEMORY_START_C1A3 + MEMORY_SIZE_C1A3
      off_ = a - MEMORY_START_C1A3
      @c1a3Uint8Array[off_] = val >> 24
      @c1a3Uint8Array[off_ + 1] = val >> 16
      @c1a3Uint8Array[off_ + 2] = val >> 8
      @c1a3Uint8Array[off_ + 3] = val
      return
    else if a >= MEMORY_START_PIF and a < MEMORY_START_PIF + MEMORY_SIZE_PIF
      off_ = a - MEMORY_START_PIF
      @pifUint8Array[off_] = val >> 24
      @pifUint8Array[off_ + 1] = val >> 16
      @pifUint8Array[off_ + 2] = val >> 8
      @pifUint8Array[off_ + 3] = val
      return
    else if a >= MEMORY_START_GIO and a < MEMORY_START_GIO + MEMORY_SIZE_GIO_REG
      off_ = a - MEMORY_START_GIO
      @gioUint8Array[off_] = val >> 24
      @gioUint8Array[off_ + 1] = val >> 16
      @gioUint8Array[off_ + 2] = val >> 8
      @gioUint8Array[off_ + 3] = val
      return
    else
      log "writing to invalid memory at " + dec2hex(addr)
      #stopEmulator();
      off_ = a & 0x0000fffc
      @rdramUint8Array[off_] = val >> 24
      @rdramUint8Array[off_ + 1] = val >> 16
      @rdramUint8Array[off_ + 2] = val >> 8
      @rdramUint8Array[off_ + 3] = val
      return

  #Same routine as storeWord, but store a byte
  @storeByte = (val, addr, pc, isDelaySlot) ->
    a = addr & 0x1FFFFFFF
    if a >= MEMORY_START_RDRAM and a < MEMORY_START_RDRAM + MEMORY_SIZE_RDRAM
      off_ = a - MEMORY_START_RDRAM
      @rdramUint8Array[off_] = val
      return
    else if a >= MEMORY_START_SPMEM and a < MEMORY_START_SPMEM + MEMORY_SIZE_SPMEM
      off_ = a - MEMORY_START_SPMEM
      @spMemUint8Array[off_] = val
      return
    else if a >= MEMORY_START_RI and a < MEMORY_START_RI + MEMORY_SIZE_RI
      off_ = a - MEMORY_START_RI
      @riUint8Array[off_] = val
      return
    else if a >= MEMORY_START_MI and a < MEMORY_START_MI + MEMORY_SIZE_MI
      off_ = a - MEMORY_START_MI
      core.interrupts.writeMI off_, val, pc, isDelaySlot
      return
    else if a >= MEMORY_START_RAMREGS8 and a < MEMORY_START_RAMREGS8 + MEMORY_SIZE_RAMREGS8
      off_ = a - MEMORY_START_RAMREGS8
      @ramRegs8Uint8Array[off_] = val
      return
    else if a >= MEMORY_START_RAMREGS4 and a < MEMORY_START_RAMREGS4 + MEMORY_SIZE_RAMREGS4
      off_ = a - MEMORY_START_RAMREGS4
      @ramRegs4Uint8Array[off_] = val
      return
    else if a >= MEMORY_START_RAMREGS0 and a < MEMORY_START_RAMREGS0 + MEMORY_SIZE_RAMREGS0
      off_ = a - MEMORY_START_RAMREGS0
      @ramRegs0Uint8Array[off_] = val
      return
    else if a >= MEMORY_START_SPREG_1 and a < MEMORY_START_SPREG_1 + MEMORY_SIZE_SPREG_1
      off_ = a - MEMORY_START_SPREG_1
      core.interrupts.writeSPReg1 off_, val, pc, isDelaySlot
      return
    else if a >= MEMORY_START_PI and a < MEMORY_START_PI + MEMORY_SIZE_PI
      off_ = a - MEMORY_START_PI
      core.interrupts.writePI off_, val, pc, isDelaySlot
      return
    else if a >= MEMORY_START_SI and a < MEMORY_START_SI + MEMORY_SIZE_SI
      off_ = a - MEMORY_START_SI
      core.interrupts.writeSI off_, val, pc, isDelaySlot
      return
    else if a >= MEMORY_START_AI and a < MEMORY_START_AI + MEMORY_SIZE_AI
      off_ = a - MEMORY_START_AI
      core.interrupts.writeAI off_, val, pc, isDelaySlot
      return
    else if a >= MEMORY_START_VI and a < MEMORY_START_VI + MEMORY_SIZE_VI
      off_ = a - MEMORY_START_VI
      core.interrupts.writeVI off_, val, pc, isDelaySlot
      return
    else if a >= MEMORY_START_SPREG_2 and a < MEMORY_START_SPREG_2 + MEMORY_SIZE_SPREG_2
      off_ = a - MEMORY_START_SPREG_2
      core.interrupts.writeSPReg2 off_, val, pc, isDelaySlot
      return
    else if a >= MEMORY_START_DPC and a < MEMORY_START_DPC + MEMORY_SIZE_DPC
      off_ = a - MEMORY_START_DPC
      core.interrupts.writeDPC off_, val, pc, isDelaySlot
      return
    else if a >= MEMORY_START_DPS and a < MEMORY_START_DPS + MEMORY_SIZE_DPS
      off_ = a - MEMORY_START_DPS
      @dpsUint8Array[off_] = val
      return
    else if a >= MEMORY_START_C2A1 and a < MEMORY_START_C2A1 + MEMORY_SIZE_C2A1
      off_ = a - MEMORY_START_C2A1
      @c2a1Uint8Array[off_] = val
      return
    else if a >= MEMORY_START_C1A1 and a < MEMORY_START_C1A1 + MEMORY_SIZE_C1A1
      off_ = a - MEMORY_START_C1A1
      @c1a1Uint8Array[off_] = val
      return
    else if a >= MEMORY_START_C2A2 and a < MEMORY_START_C2A2 + MEMORY_SIZE_C2A2
      off_ = a - MEMORY_START_C2A2
      @c2a2Uint8Array[off_] = val
      return
    else if a >= MEMORY_START_ROM_IMAGE and a < MEMORY_START_ROM_IMAGE + romLength
      alert "attempt to overwrite rom!"
      off_ = a - MEMORY_START_ROM_IMAGE
      @romUint8Array[off_] = val
      return
    else if a >= MEMORY_START_C1A3 and a < MEMORY_START_C1A3 + MEMORY_SIZE_C1A3
      off_ = a - MEMORY_START_C1A3
      @c1a3Uint8Array[off_] = val
      return
    else if a >= MEMORY_START_PIF and a < MEMORY_START_PIF + MEMORY_SIZE_PIF
      off_ = a - MEMORY_START_PIF
      @pifUint8Array[off_] = val
      return
    else if a >= MEMORY_START_GIO and a < MEMORY_START_GIO + MEMORY_SIZE_GIO_REG
      off_ = a - MEMORY_START_GIO
      @gioUint8Array[off_] = val
      return
    else
      log "writing to invalid memory at " + dec2hex(addr)
      #stopEmulator();
      off_ = a & 0x0000fffc
      @rdramUint8Array[off_] = val
      return

  @storeHalf = (val, addr, pc, isDelaySlot) ->
    a = addr & 0x1FFFFFFF
    if a >= MEMORY_START_RDRAM and a < MEMORY_START_RDRAM + MEMORY_SIZE_RDRAM
      off_ = a - MEMORY_START_RDRAM
      @rdramUint8Array[off_] = val >> 8
      @rdramUint8Array[off_ + 1] = val
      return
    else if a >= MEMORY_START_SPMEM and a < MEMORY_START_SPMEM + MEMORY_SIZE_SPMEM
      off_ = a - MEMORY_START_SPMEM
      @spMemUint8Array[off_] = val >> 8
      @spMemUint8Array[off_ + 1] = val
      return
    else if a >= MEMORY_START_RI and a < MEMORY_START_RI + MEMORY_SIZE_RI
      off_ = a - MEMORY_START_RI
      @riUint8Array[off_] = val >> 8
      @riUint8Array[off_ + 1] = val
      return
    else if a >= MEMORY_START_MI and a < MEMORY_START_MI + MEMORY_SIZE_MI
      off_ = a - MEMORY_START_MI
      core.interrupts.writeMI off_, val, pc, isDelaySlot
      return
    else if a >= MEMORY_START_RAMREGS8 and a < MEMORY_START_RAMREGS8 + MEMORY_SIZE_RAMREGS8
      off_ = a - MEMORY_START_RAMREGS8
      @ramRegs8Uint8Array[off_] = val >> 8
      @ramRegs8Uint8Array[off_ + 1] = val
      return
    else if a >= MEMORY_START_RAMREGS4 and a < MEMORY_START_RAMREGS4 + MEMORY_SIZE_RAMREGS4
      off_ = a - MEMORY_START_RAMREGS4
      @ramRegs4Uint8Array[off_] = val >> 8
      @ramRegs4Uint8Array[off_ + 1] = val
      return
    else if a >= MEMORY_START_RAMREGS0 and a < MEMORY_START_RAMREGS0 + MEMORY_SIZE_RAMREGS0
      off_ = a - MEMORY_START_RAMREGS0
      @ramRegs0Uint8Array[off_] = val >> 8
      @ramRegs0Uint8Array[off_ + 1] = val
      return
    else if a >= MEMORY_START_SPREG_1 and a < MEMORY_START_SPREG_1 + MEMORY_SIZE_SPREG_1
      off_ = a - MEMORY_START_SPREG_1
      core.interrupts.writeSPReg1 off_, val, pc, isDelaySlot
      return
    else if a >= MEMORY_START_PI and a < MEMORY_START_PI + MEMORY_SIZE_PI
      off_ = a - MEMORY_START_PI
      core.interrupts.writePI off_, val, pc, isDelaySlot
      return
    else if a >= MEMORY_START_SI and a < MEMORY_START_SI + MEMORY_SIZE_SI
      off_ = a - MEMORY_START_SI
      core.interrupts.writeSI off_, val, pc, isDelaySlot
      return
    else if a >= MEMORY_START_AI and a < MEMORY_START_AI + MEMORY_SIZE_AI
      off_ = a - MEMORY_START_AI
      core.interrupts.writeAI off_, val, pc, isDelaySlot
      return
    else if a >= MEMORY_START_VI and a < MEMORY_START_VI + MEMORY_SIZE_VI
      off_ = a - MEMORY_START_VI
      core.interrupts.writeVI off_, val, pc, isDelaySlot
      return
    else if a >= MEMORY_START_SPREG_2 and a < MEMORY_START_SPREG_2 + MEMORY_SIZE_SPREG_2
      off_ = a - MEMORY_START_SPREG_2
      core.interrupts.writeSPReg2 off_, val, pc, isDelaySlot
      return
    else if a >= MEMORY_START_DPC and a < MEMORY_START_DPC + MEMORY_SIZE_DPC
      off_ = a - MEMORY_START_DPC
      core.interrupts.writeDPC off_, val, pc, isDelaySlot
      return
    else if a >= MEMORY_START_DPS and a < MEMORY_START_DPS + MEMORY_SIZE_DPS
      off_ = a - MEMORY_START_DPS
      @dpsUint8Array[off_] = val >> 8
      @dpsUint8Array[off_ + 1] = val
      return
    else if a >= MEMORY_START_C2A1 and a < MEMORY_START_C2A1 + MEMORY_SIZE_C2A1
      off_ = a - MEMORY_START_C2A1
      @c2a1Uint8Array[off_] = val >> 8
      @c2a1Uint8Array[off_ + 1] = val
      return
    else if a >= MEMORY_START_C1A1 and a < MEMORY_START_C1A1 + MEMORY_SIZE_C1A1
      off_ = a - MEMORY_START_C1A1
      @c1a1Uint8Array[off_] = val >> 8
      @c1a1Uint8Array[off_ + 1] = val
      return
    else if a >= MEMORY_START_C2A2 and a < MEMORY_START_C2A2 + MEMORY_SIZE_C2A2
      off_ = a - MEMORY_START_C2A2
      @c2a2Uint8Array[off_] = val >> 8
      @c2a2Uint8Array[off_ + 1] = val
      return
    else if a >= MEMORY_START_ROM_IMAGE and a < MEMORY_START_ROM_IMAGE + romLength
      alert "attempt to overwrite rom!"
      off_ = a - MEMORY_START_ROM_IMAGE
      @romUint8Array[off_] = val >> 8
      @romUint8Array[off_ + 1] = val
      return
    else if a >= MEMORY_START_C1A3 and a < MEMORY_START_C1A3 + MEMORY_SIZE_C1A3
      off_ = a - MEMORY_START_C1A3
      @c1a3Uint8Array[off_] = val >> 8
      @c1a3Uint8Array[off_ + 1] = val
      return
    else if a >= MEMORY_START_PIF and a < MEMORY_START_PIF + MEMORY_SIZE_PIF
      off_ = a - MEMORY_START_PIF
      @pifUint8Array[off_] = val >> 8
      @pifUint8Array[off_ + 1] = val
      return
    else if a >= MEMORY_START_GIO and a < MEMORY_START_GIO + MEMORY_SIZE_GIO_REG
      off_ = a - MEMORY_START_GIO
      @gioUint8Array[off_] = val >> 8
      @gioUint8Array[off_ + 1] = val
      return
    else
      log "writing to invalid memory at " + dec2hex(addr)
      #stopEmulator();
      off_ = a & 0x0000fffc
      @rdramUint8Array[off_] = val >> 8
      @rdramUint8Array[off_ + 1] = val
      return
  return this
#hack global space until we export classes properly
#node.js uses exports; browser uses this (window)
root = exports ? this
root.C1964jsMemory = C1964jsMemory
