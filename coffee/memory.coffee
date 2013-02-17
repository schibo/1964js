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

class C1964jsMemory
  constructor: (@core) ->
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
    @writeRegion = []
    @initRegion 0, 0x80000000, @readTLB, @writeTLB
    @initRegion 0x80000000, 0x40000000, @readDummy, @writeDummy
    @initRegion 0xC0000000, 0x40000000, @readTLB, @writeTLB
    @initRegion MEMORY_START_RDRAM, MEMORY_SIZE_RDRAM, @readRdram, @writeRdram
    @initRegion MEMORY_START_RAMREGS4, MEMORY_START_RAMREGS4, @readRamRegs4, @writeRamRegs4
    @initRegion MEMORY_START_SPMEM, MEMORY_SIZE_SPMEM, @readSpMem, @writeSpMem
    @initRegion MEMORY_START_SPREG_1, MEMORY_SIZE_SPREG_1, @readSpReg1, @writeSpReg1
    @initRegion MEMORY_START_SPREG_2, MEMORY_SIZE_SPREG_2, @readSpReg2, @writeSpReg2
    @initRegion MEMORY_START_DPC, MEMORY_SIZE_DPC, @readDpc, @writeDpc
    @initRegion MEMORY_START_DPS, MEMORY_SIZE_DPS, @readDps, @writeDps
    @initRegion MEMORY_START_MI, MEMORY_SIZE_MI, @readMi, @writeMi
    @initRegion MEMORY_START_VI, MEMORY_SIZE_VI, @readVi, @writeVi
    @initRegion MEMORY_START_AI, MEMORY_SIZE_AI, @readAi, @writeAi
    @initRegion MEMORY_START_PI, MEMORY_SIZE_PI, @readPi, @writePi
    @initRegion MEMORY_START_SI, MEMORY_SIZE_SI, @readSi, @writeSi
    @initRegion MEMORY_START_C2A1, MEMORY_SIZE_C2A1, @readC2A1, @writeC2A1
    @initRegion MEMORY_START_C1A1, MEMORY_SIZE_C1A1, @readC1A1, @writeC1A1
    @initRegion MEMORY_START_C2A2, MEMORY_SIZE_C2A2, @readC2A2, @writeC2A2
    @initRegion MEMORY_START_ROM_IMAGE, MEMORY_SIZE_ROM, @readRom, @writeRom #todo: could be a problem to use romLength
    @initRegion MEMORY_START_C1A3, MEMORY_SIZE_C1A3, @readC1A3, @writeC1A3
    @initRegion MEMORY_START_RI, MEMORY_SIZE_RI, @readRi, @writeRi
    @initRegion MEMORY_START_PIF, MEMORY_SIZE_PIF, @readPif, @writePif
    @initRegion MEMORY_START_GIO, MEMORY_SIZE_GIO, @readGio, @writeGio
    @initRegion MEMORY_START_RAMREGS0, MEMORY_SIZE_RAMREGS0, @readRamRegs0, @writeRamRegs0
    @initRegion MEMORY_START_RAMREGS8, MEMORY_SIZE_RAMREGS8, @readRamRegs8, @writeRamRegs8
    @physRegion = undefined

  initRegion: (start, size, region, writeRegion) ->
    end = (start + size) >>> 14
    start >>>= 14

    while start < end
      @region[start] = region
      @writeRegion[start++] = writeRegion
    return

  readDummy: (that, a, getFn) ->
    off_ = a & 0x0000FFFC
    getFn that.dummyReadWriteUint8Array, off_

  readRdram: (that, a, getFn) ->
    off_ = a-MEMORY_START_RDRAM
    getFn that.rdramUint8Array, off_

  readRamRegs0: (that, a, getFn) ->
    off_ = a - MEMORY_START_RAMREGS0
    getFn that.ramRegs0Uint8Array, off_

  readRamRegs4: (that, a, getFn) ->
    off_ = a - MEMORY_START_RAMREGS4
    getFn that.ramRegs4Uint8Array, off_

  readRamRegs8: (that, a, getFn) ->
    off_ = a - MEMORY_START_RAMREGS8
    getFn that.ramRegs8Uint8Array, off_

  readSpMem: (that, a, getFn) ->
    off_ = a - MEMORY_START_SPMEM
    getFn that.spMemUint8Array, off_

  readSpReg1: (that, a) ->
    off_ = a - MEMORY_START_SPREG_1
    that.core.interrupts.readSPReg1 off_

  readSpReg2: (that, a, getFn) ->
    off_ = a - MEMORY_START_SPREG_2
    getFn that.spReg2Uint8Array, off_

  readDpc: (that, a, getFn) ->
    off_ = a - MEMORY_START_DPC
    getFn that.dpcUint8Array, off_

  readDps: (that, a, getFn) ->
    off_ = a - MEMORY_START_DPS
    getFn that.dpsUint8Array, off_

  readMi: (that, a, getFn) ->
    off_ = a - MEMORY_START_MI
    getFn that.miUint8Array, off_

  readVi: (that, a) ->
    off_ = a - MEMORY_START_VI
    that.core.interrupts.readVI off_

  readAi: (that, a) ->
    off_ = a - MEMORY_START_AI
    that.core.interrupts.readAI off_
  
  readPi: (that, a, getFn) ->
    off_ = a - MEMORY_START_PI
    getFn that.piUint8Array, off_
  
  readSi: (that, a) ->
    off_ = a - MEMORY_START_SI
    that.core.interrupts.readSI off_

  readC2A1: (that, a, getFn) ->
    off_ = a - MEMORY_START_C2A1
    getFn that.c2a1Uint8Array, off_

  readC1A1: (that, a, getFn) ->
    off_ = a - MEMORY_START_C1A1
    getFn that.c1a1Uint8Array, off_

  readC2A2: (that, a, getFn) ->
    off_ = a - MEMORY_START_C2A2
    getFn that.c2a2Uint8Array, off_

  readRom: (that, a, getFn) ->
    off_ = a - MEMORY_START_ROM_IMAGE
    getFn that.romUint8Array, off_

  readC1A3: (that, a, getFn) ->
    off_ = a - MEMORY_START_C1A3
    getFn that.c1a3Uint8Array, off_

  readRi: (that, a, getFn) ->
    off_ = a - MEMORY_START_RI
    getFn that.riUint8Array, off_

  readPif: (that, a, getFn) ->
    off_ = a - MEMORY_START_PIF
    getFn that.pifUint8Array, off_

  readGio: (that, a, getFn) ->
    off_ = a - MEMORY_START_GIO
    getFn that.gioUint8Array, off_

  writeRdram: (that, setFn, val, a) ->
    off_ = a - MEMORY_START_RDRAM
    setFn that.rdramUint8Array, off_, val
    return

  writeSpMem: (that, setFn, val, a) ->
    off_ = a - MEMORY_START_SPMEM
    setFn that.spMemUint8Array, off_, val
    return

  writeRi: (that, setFn, val, a) ->
    off_ = a - MEMORY_START_RI
    setFn that.riUint8Array, off_, val
    return

  writeMi: (that, setFn, val, a, pc, isDelaySlot) ->
    off_ = a - MEMORY_START_MI
    that.core.interrupts.writeMI off_, val, pc, isDelaySlot
    return

  writeRamRegs8: (that, setFn, val, a) ->
    off_ = a - MEMORY_START_RAMREGS8
    setFn that.ramRegs8Uint8Array, off_, val
    return

  writeRamRegs4: (that, setFn, val, a) ->
    off_ = a - MEMORY_START_RAMREGS4
    setFn that.ramRegs4Uint8Array, off_, val
    return

  writeRamRegs0: (that, setFn, val, a) ->
    off_ = a - MEMORY_START_RAMREGS0
    setFn that.ramRegs0Uint8Array, off_, val
    return

  writeSpReg1: (that, setFn, val, a, pc, isDelaySlot) ->
    off_ = a - MEMORY_START_SPREG_1
    that.core.interrupts.writeSPReg1 off_, val, pc, isDelaySlot
    return

  writePi: (that, setFn, val, a, pc, isDelaySlot) ->
    off_ = a - MEMORY_START_PI
    that.core.interrupts.writePI off_, val, pc, isDelaySlot
    return

  writeSi: (that, setFn, val, a, pc, isDelaySlot) ->
    off_ = a - MEMORY_START_SI
    that.core.interrupts.writeSI off_, val, pc, isDelaySlot
    return

  writeAi: (that, setFn, val, a, pc, isDelaySlot) ->
    off_ = a - MEMORY_START_AI
    that.core.interrupts.writeAI off_, val, pc, isDelaySlot
    return

  writeVi: (that, setFn, val, a, pc, isDelaySlot) ->
    off_ = a - MEMORY_START_VI
    that.core.interrupts.writeVI off_, val, pc, isDelaySlot
    return

  writeSpReg2: (that, setFn, val, a, pc, isDelaySlot) ->
    off_ = a - MEMORY_START_SPREG_2
    that.core.interrupts.writeSPReg2 off_, val, pc, isDelaySlot
    return

  writeDpc: (that, setFn, val, a, pc, isDelaySlot) ->
    off_ = a - MEMORY_START_DPC
    that.core.interrupts.writeDPC off_, val, pc, isDelaySlot
    return

  writeDps: (that, setFn, val, a) ->
    off_ = a - MEMORY_START_DPS
    setFn that.dpsUint8Array, off_, val
    return

  writeC2A1: (that, setFn, val, a) ->
    off_ = a - MEMORY_START_C2A1
    setFn that.c2a1Uint8Array, off_, val
    return

  writeC1A1: (that, setFn, val, a) ->
    off_ = a - MEMORY_START_C1A1
    setFn that.c1a1Uint8Array, off_, val
    return

  writeC2A2: (that, setFn, val, a) ->
    off_ = a - MEMORY_START_C2A2
    setFn that.c2a2Uint8Array, off_, val
    return

  writeRom: (that, setFn, val, a) ->
    alert "attempt to overwrite rom!"
    off_ = a - MEMORY_START_ROM_IMAGE
    setFn that.romUint8Array, off_, val
    return

  writeC1A3: (that, setFn, val, a) ->
    off_ = a - MEMORY_START_C1A3
    setFn that.c1a3Uint8Array, off_, val
    return

  writePif: (that, setFn, val, a) ->
    off_ = a - MEMORY_START_PIF
    setFn that.pifUint8Array, off_, val
    return

  writeGio: (that, setFn, val, a) ->
    off_ = a - MEMORY_START_GIO
    setFn that.gioUint8Array, off_, val
    return

  writeDummy: (that, setFn, val, a) ->
    log "writing to invalid memory at " + dec2hex(a)
    off_ = a & 0x0000fffc
    setFn that.dummyReadWriteUint8Array, off_, val
    return

  virtualToPhysical: (a) ->
    #uncomment to see where we're loading/storing
    #if ((((a & 0xF0000000)>>>0) isnt 0x80000000) and (((a & 0xF0000000)>>>0) isnt 0xA0000000))
    #  alert(dec2hex(a))
    
    #uncomment to verify non-tlb lookup.
    #if dec2hex(a) != dec2hex(((physRegion[a>>>12]<<16) | a&0x0000ffff))
    #  alert dec2hex(a) + ' ' + dec2hex(((physRegion[a>>>12]<<16) | a&0x0000ffff))
    return ((@physRegion[a>>>12]<<16) | (a&0x0000ffff))

  readTLB: (that, a, getFn) ->
    a = that.virtualToPhysical(a)

    region = that.region[a>>>14]

    if region is that.readTLB
      region = that.readDummy

    region(that, a, getFn)

  writeTLB: (that, setFn, val, a, pc, isDelaySlot) ->
    a = that.virtualToPhysical(a)

    region = that.writeRegion[a>>>14]

    if region is that.writeTLB
      region = that.writeDummy

    region(that, setFn, val, a, pc, isDelaySlot)
    return

  initPhysRegions: ->
    #Initialize the TLB Lookup Table
    @physRegion = new Int16Array(0x100000)
    i = 0
    #todo: replace with call to buildTLBHelper clear
    while i < 0x100000
      @physRegion[i] = (i & 0x1ffff) >>> 4
      i++
    return

  #getInt32 and getUint32 are identical. they both return signed.
  getInt8: (region, off_) ->
    region[off_]

  getInt16: (region, off_) ->
    region[off_] << 8 | region[off_ + 1]

  getInt32: (sregion, uregion, off_) ->
    uregion[off_] << 24 | uregion[off_ + 1] << 16 | uregion[off_ + 2] << 8 | uregion[off_ + 3]

  getUint32: (uregion, off_) ->
    uregion[off_] << 24 | uregion[off_ + 1] << 16 | uregion[off_ + 2] << 8 | uregion[off_ + 3]

  setInt8: (uregion, off_, val) ->
    uregion[off_] = val
    return

  setInt32: (uregion, off_, val) ->
    uregion[off_] = val >> 24
    uregion[off_ + 1] = val >> 16
    uregion[off_ + 2] = val >> 8
    uregion[off_ + 3] = val
    return

  setInt16: (uregion, off_, val) ->
    uregion[off_] = val >> 8
    uregion[off_ + 1] = val
    return

  lb: (addr) ->
    #throw Error "todo: mirrored load address"  if (addr & 0xff000000) is 0x84000000
    a = @virtualToPhysical(addr)
    @region[a>>>14](this, a, @getInt8)

  lh: (addr) ->
    #throw Error "todo: mirrored load address"  if (addr & 0xff000000) is 0x84000000
    a = @virtualToPhysical(addr)
    @region[a>>>14](this, a, @getInt16)

  lw: (addr) ->
    #throw Error "todo: mirrored load address"  if (addr & 0xff000000) is 0x84000000
    a = @virtualToPhysical(addr)
    @region[a>>>14](this, a, @getUint32)

  sw: (val, addr, pc, isDelaySlot) ->
    a = @virtualToPhysical(addr)
    @writeRegion[a>>>14](this, @setInt32, val, a, pc, isDelaySlot)
    return

  #Same routine as storeWord, but store a byte
  sb: (val, addr, pc, isDelaySlot) ->
    a = @virtualToPhysical(addr)
    @writeRegion[a>>>14](this, @setInt8, val, a, pc, isDelaySlot)
    return

  sh: (val, addr, pc, isDelaySlot) ->
    a = @virtualToPhysical(addr)
    @writeRegion[a>>>14](this, @setInt16, val, a, pc, isDelaySlot)
    return

#hack global space until we export classes properly
#node.js uses exports; browser uses this (window)
root = exports ? this
root.C1964jsMemory = C1964jsMemory
