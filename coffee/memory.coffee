#
#1964js - JavaScript/HTML5 port of 1964 - N64 emulator
#Copyright (C) 2012 Joel Middendorf
#
#This program is free software; you can redistribute it and/or
#modify it under the terms of the GNU General Public License
#as published by the Free Software Foundation; either version 2
#of the License, or (at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program; if not, write to the Free Software
#Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
C1964jsMemory = (core) ->
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
  
  #getInt32 and getUint32 are identical. they both return signed.
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
    throw Error "todo: mirrored load address"  if (addr & 0xff000000) is 0x84000000
    a = addr & 0x1FFFFFFF
    if a >= consts.MEMORY_START_RDRAM and a < consts.MEMORY_START_RDRAM + consts.MEMORY_SIZE_RDRAM
      off_ = a - consts.MEMORY_START_RDRAM
      @rdramUint8Array[off_]
    else if a >= consts.MEMORY_START_RAMREGS4 and a < consts.MEMORY_START_RAMREGS4 + consts.MEMORY_SIZE_RAMREGS4
      off_ = a - consts.MEMORY_START_RAMREGS4
      @ramRegs4Uint8Array[off_]
    else if a >= consts.MEMORY_START_SPMEM and a < consts.MEMORY_START_SPMEM + consts.MEMORY_SIZE_SPMEM
      off_ = a - consts.MEMORY_START_SPMEM
      @spMemUint8Array[off_]
    else if a >= consts.MEMORY_START_SPREG_1 and a < consts.MEMORY_START_SPREG_1 + consts.MEMORY_SIZE_SPREG_1
      off_ = a - consts.MEMORY_START_SPREG_1
      core.interrupts.readSPReg1 off_
    else if a >= consts.MEMORY_START_SPREG_2 and a < consts.MEMORY_START_SPREG_2 + consts.MEMORY_SIZE_SPREG_2
      off_ = a - consts.MEMORY_START_SPREG_2
      @spReg2Uint8Array[off_]
    else if a >= consts.MEMORY_START_DPC and a < consts.MEMORY_START_DPC + consts.MEMORY_SIZE_DPC
      off_ = a - consts.MEMORY_START_DPC
      @dpcUint8Array[off_]
    else if a >= consts.MEMORY_START_DPS and a < consts.MEMORY_START_DPS + consts.MEMORY_SIZE_DPS
      off_ = a - consts.MEMORY_START_DPS
      @dpsUint8Array[off_]
    else if a >= consts.MEMORY_START_MI and a < consts.MEMORY_START_MI + consts.MEMORY_SIZE_MI
      
      #alert('load mi:' + dec2hex(addr));
      off_ = a - consts.MEMORY_START_MI
      @miUint8Array[off_]
    else if a >= consts.MEMORY_START_VI and a < consts.MEMORY_START_VI + consts.MEMORY_SIZE_VI
      off_ = a - consts.MEMORY_START_VI
      core.interrupts.readVI off_
    else if a >= consts.MEMORY_START_AI and a < consts.MEMORY_START_AI + consts.MEMORY_SIZE_AI
      
      #alert('load ai:' + dec2hex(addr));
      off_ = a - consts.MEMORY_START_AI
      core.interrupts.readAI off_
    else if a >= consts.MEMORY_START_PI and a < consts.MEMORY_START_PI + consts.MEMORY_SIZE_PI
      
      # alert('load pi:' + dec2hex(addr));
      off_ = a - consts.MEMORY_START_PI
      @piUint8Array[off_]
    else if a >= consts.MEMORY_START_SI and a < consts.MEMORY_START_SI + consts.MEMORY_SIZE_SI
      
      # alert('load si');
      off_ = a - consts.MEMORY_START_SI
      core.interrupts.readSI off_
    else if a >= consts.MEMORY_START_C2A1 and a < consts.MEMORY_START_C2A1 + consts.MEMORY_SIZE_C2A1
      off_ = a - consts.MEMORY_START_C2A1
      @c2a1Uint8Array[off_]
    else if a >= consts.MEMORY_START_C1A1 and a < consts.MEMORY_START_C1A1 + consts.MEMORY_SIZE_C1A1
      off_ = a - consts.MEMORY_START_C1A1
      @c1a1Uint8Array[off_]
    else if a >= consts.MEMORY_START_C2A2 and a < consts.MEMORY_START_C2A2 + consts.MEMORY_SIZE_C2A2
      off_ = a - consts.MEMORY_START_C2A2
      @c2a2Uint8Array[off_]
    else if a >= consts.MEMORY_START_ROM_IMAGE and a < consts.MEMORY_START_ROM_IMAGE + romLength #todo: could be a problem to use romLength
      #  alert('load rom');
      off_ = a - consts.MEMORY_START_ROM_IMAGE
      @romUint8Array[off_]
    else if a >= consts.MEMORY_START_C1A3 and a < consts.MEMORY_START_C1A3 + consts.MEMORY_SIZE_C1A3
      off_ = a - consts.MEMORY_START_C1A3
      @c1a3Uint8Array[off_]
    else if a >= consts.MEMORY_START_RI and a < consts.MEMORY_START_RI + consts.MEMORY_SIZE_RI
      off_ = a - consts.MEMORY_START_RI
      @riUint8Array[off_]
    else if a >= consts.MEMORY_START_PIF and a < consts.MEMORY_START_PIF + consts.MEMORY_SIZE_PIF
      off_ = a - consts.MEMORY_START_PIF
      @pifUint8Array[off_]
    else if a >= consts.MEMORY_START_GIO and a < consts.MEMORY_START_GIO + consts.MEMORY_SIZE_GIO_REG
      off_ = a - consts.MEMORY_START_GIO
      @gioUint8Array[off_]
    else if a >= consts.MEMORY_START_RAMREGS0 and a < consts.MEMORY_START_RAMREGS0 + consts.MEMORY_SIZE_RAMREGS0
      off_ = a - consts.MEMORY_START_RAMREGS0
      @ramRegs0Uint8Array[off_]
    else if a >= consts.MEMORY_START_RAMREGS8 and a < consts.MEMORY_START_RAMREGS8 + consts.MEMORY_SIZE_RAMREGS8
      off_ = a - consts.MEMORY_START_RAMREGS8
      @ramRegs8Uint8Array[off_]
    else
      log "reading from invalid memory at " + dec2hex(addr)
      #stopEmulator();
      off_ = a & 0x0000fffc
      @dummyReadWriteUint8Array[off_]

  @loadHalf = (addr) ->
    throw Error "todo: mirrored load address"  if (addr & 0xff000000) is 0x84000000
    a = addr & 0x1FFFFFFF
    if a >= consts.MEMORY_START_RDRAM and a < consts.MEMORY_START_RDRAM + consts.MEMORY_SIZE_RDRAM
      off_ = a - consts.MEMORY_START_RDRAM
      @rdramUint8Array[off_] << 8 | @rdramUint8Array[off_ + 1]
    else if a >= consts.MEMORY_START_RAMREGS4 and a < consts.MEMORY_START_RAMREGS4 + consts.MEMORY_SIZE_RAMREGS4
      off_ = a - consts.MEMORY_START_RAMREGS4
      @ramRegs4Uint8Array[off_] << 8 | @ramRegs4Uint8Array[off_ + 1]
    else if a >= consts.MEMORY_START_SPMEM and a < consts.MEMORY_START_SPMEM + consts.MEMORY_SIZE_SPMEM
      off_ = a - consts.MEMORY_START_SPMEM
      @spMemUint8Array[off_] << 8 | @spMemUint8Array[off_ + 1]
    else if a >= consts.MEMORY_START_SPREG_1 and a < consts.MEMORY_START_SPREG_1 + consts.MEMORY_SIZE_SPREG_1
      off_ = a - consts.MEMORY_START_SPREG_1
      core.interrupts.readSPReg1 off_
    else if a >= consts.MEMORY_START_SPREG_2 and a < consts.MEMORY_START_SPREG_2 + consts.MEMORY_SIZE_SPREG_2
      off_ = a - consts.MEMORY_START_SPREG_2
      @spReg2Uint8Array[off_] << 8 | @spReg2Uint8Array[off_ + 1]
    else if a >= consts.MEMORY_START_DPC and a < consts.MEMORY_START_DPC + consts.MEMORY_SIZE_DPC
      off_ = a - consts.MEMORY_START_DPC
      @dpcUint8Array[off_] << 8 | @dpcUint8Array[off_ + 1]
    else if a >= consts.MEMORY_START_DPS and a < consts.MEMORY_START_DPS + consts.MEMORY_SIZE_DPS
      off_ = a - consts.MEMORY_START_DPS
      @dpsUint8Array[off_] << 8 | @dpsUint8Array[off_ + 1]
    else if a >= consts.MEMORY_START_MI and a < consts.MEMORY_START_MI + consts.MEMORY_SIZE_MI
      #alert('load mi:' + dec2hex(addr));
      off_ = a - consts.MEMORY_START_MI
      @miUint8Array[off_] << 8 | @miUint8Array[off_ + 1]
    else if a >= consts.MEMORY_START_VI and a < consts.MEMORY_START_VI + consts.MEMORY_SIZE_VI
      off_ = a - consts.MEMORY_START_VI
      core.interrupts.readVI off_
    else if a >= consts.MEMORY_START_AI and a < consts.MEMORY_START_AI + consts.MEMORY_SIZE_AI
      #alert('load ai:' + dec2hex(addr));
      off_ = a - consts.MEMORY_START_AI
      core.interrupts.readAI off_
    else if a >= consts.MEMORY_START_PI and a < consts.MEMORY_START_PI + consts.MEMORY_SIZE_PI
      # alert('load pi:' + dec2hex(addr));
      off_ = a - consts.MEMORY_START_PI
      @piUint8Array[off_] << 8 | @piUint8Array[off_ + 1]
    else if a >= consts.MEMORY_START_SI and a < consts.MEMORY_START_SI + consts.MEMORY_SIZE_SI
      # alert('load si');
      off_ = a - consts.MEMORY_START_SI
      core.interrupts.readSI off_
    else if a >= consts.MEMORY_START_C2A1 and a < consts.MEMORY_START_C2A1 + consts.MEMORY_SIZE_C2A1
      off_ = a - consts.MEMORY_START_C2A1
      @c2a1Uint8Array[off_] << 8 | @c2a1Uint8Array[off_ + 1]
    else if a >= consts.MEMORY_START_C1A1 and a < consts.MEMORY_START_C1A1 + consts.MEMORY_SIZE_C1A1
      off_ = a - consts.MEMORY_START_C1A1
      @c1a1Uint8Array[off_] << 8 | @c1a1Uint8Array[off_ + 1]
    else if a >= consts.MEMORY_START_C2A2 and a < consts.MEMORY_START_C2A2 + consts.MEMORY_SIZE_C2A2
      off_ = a - consts.MEMORY_START_C2A2
      @c2a2Uint8Array[off_] << 8 | @c2a2Uint8Array[off_ + 1]
    else if a >= consts.MEMORY_START_ROM_IMAGE and a < consts.MEMORY_START_ROM_IMAGE + romLength
      #alert('load rom');
      off_ = a - consts.MEMORY_START_ROM_IMAGE
      @romUint8Array[off_] << 8 | @romUint8Array[off_ + 1]
    else if a >= consts.MEMORY_START_C1A3 and a < consts.MEMORY_START_C1A3 + consts.MEMORY_SIZE_C1A3
      off_ = a - consts.MEMORY_START_C1A3
      @c1a3Uint8Array[off_] << 8 | @c1a3Uint8Array[off_ + 1]
    else if a >= consts.MEMORY_START_RI and a < consts.MEMORY_START_RI + consts.MEMORY_SIZE_RI
      off_ = a - consts.MEMORY_START_RI
      @riUint8Array[off_] << 8 | @riUint8Array[off_ + 1]
    else if a >= consts.MEMORY_START_PIF and a < consts.MEMORY_START_PIF + consts.MEMORY_SIZE_PIF
      off_ = a - consts.MEMORY_START_PIF
      @pifUint8Array[off_] << 8 | @pifUint8Array[off_ + 1]
    else if a >= consts.MEMORY_START_GIO and a < consts.MEMORY_START_GIO + consts.MEMORY_SIZE_GIO_REG
      off_ = a - consts.MEMORY_START_GIO
      @gioUint8Array[off_] << 8 | @gioUint8Array[off_ + 1]
    else if a >= consts.MEMORY_START_RAMREGS0 and a < consts.MEMORY_START_RAMREGS0 + consts.MEMORY_SIZE_RAMREGS0
      off_ = a - consts.MEMORY_START_RAMREGS0
      @ramRegs0Uint8Array[off_] << 8 | @ramRegs0Uint8Array[off_ + 1]
    else if a >= consts.MEMORY_START_RAMREGS8 and a < consts.MEMORY_START_RAMREGS8 + consts.MEMORY_SIZE_RAMREGS8
      off_ = a - consts.MEMORY_START_RAMREGS8
      @ramRegs8Uint8Array[off_] << 8 | @ramRegs8Uint8Array[off_ + 1]
    else
      log "reading from invalid memory at " + dec2hex(addr)
      #stopEmulator();
      off_ = a & 0x0000fffc
      @dummyReadWriteUint8Array[off_] << 8 | @dummyReadWriteUint8Array[off_ + 1]

  @loadWord = (addr) ->
    throw Error "todo: mirrored load address"  if (addr & 0xff000000) is 0x84000000
    a = addr & 0x1FFFFFFF
    if a >= consts.MEMORY_START_RDRAM and a < consts.MEMORY_START_RDRAM + consts.MEMORY_SIZE_RDRAM
      off_ = a - consts.MEMORY_START_RDRAM
      @rdramUint8Array[off_] << 24 | @rdramUint8Array[off_ + 1] << 16 | @rdramUint8Array[off_ + 2] << 8 | @rdramUint8Array[off_ + 3]
    #return getInt32(rdramUint8Array, rdramUint8Array, a-consts.MEMORY_START_RDRAM);
    else if a >= consts.MEMORY_START_RAMREGS4 and a < consts.MEMORY_START_RAMREGS4 + consts.MEMORY_SIZE_RAMREGS4
      off_ = a - consts.MEMORY_START_RAMREGS4
      @ramRegs4Uint8Array[off_] << 24 | @ramRegs4Uint8Array[off_ + 1] << 16 | @ramRegs4Uint8Array[off_ + 2] << 8 | @ramRegs4Uint8Array[off_ + 3]
    else if a >= consts.MEMORY_START_SPMEM and a < consts.MEMORY_START_SPMEM + consts.MEMORY_SIZE_SPMEM
      off_ = a - consts.MEMORY_START_SPMEM
      @spMemUint8Array[off_] << 24 | @spMemUint8Array[off_ + 1] << 16 | @spMemUint8Array[off_ + 2] << 8 | @spMemUint8Array[off_ + 3]
    else if a >= consts.MEMORY_START_SPREG_1 and a < consts.MEMORY_START_SPREG_1 + consts.MEMORY_SIZE_SPREG_1
      off_ = a - consts.MEMORY_START_SPREG_1
      core.interrupts.readSPReg1 off_
    else if a >= consts.MEMORY_START_SPREG_2 and a < consts.MEMORY_START_SPREG_2 + consts.MEMORY_SIZE_SPREG_2
      off_ = a - consts.MEMORY_START_SPREG_2
      @spReg2Uint8Array[off_] << 24 | @spReg2Uint8Array[off_ + 1] << 16 | @spReg2Uint8Array[off_ + 2] << 8 | @spReg2Uint8Array[off_ + 3]
    else if a >= consts.MEMORY_START_DPC and a < consts.MEMORY_START_DPC + consts.MEMORY_SIZE_DPC
      off_ = a - consts.MEMORY_START_DPC
      @dpcUint8Array[off_] << 24 | @dpcUint8Array[off_ + 1] << 16 | @dpcUint8Array[off_ + 2] << 8 | @dpcUint8Array[off_ + 3]
    else if a >= consts.MEMORY_START_DPS and a < consts.MEMORY_START_DPS + consts.MEMORY_SIZE_DPS
      off_ = a - consts.MEMORY_START_DPS
      @dpsUint8Array[off_] << 24 | @dpsUint8Array[off_ + 1] << 16 | @dpsUint8Array[off_ + 2] << 8 | @dpsUint8Array[off_ + 3]
    else if a >= consts.MEMORY_START_MI and a < consts.MEMORY_START_MI + consts.MEMORY_SIZE_MI
      #alert('load mi:' + dec2hex(addr));
      off_ = a - consts.MEMORY_START_MI
      #if (off === 8) //hack for read-only mi_intr_reg
      #  return -1;
      @miUint8Array[off_] << 24 | @miUint8Array[off_ + 1] << 16 | @miUint8Array[off_ + 2] << 8 | @miUint8Array[off_ + 3]
    else if a >= consts.MEMORY_START_VI and a < consts.MEMORY_START_VI + consts.MEMORY_SIZE_VI
      off_ = a - consts.MEMORY_START_VI
      core.interrupts.readVI off_
    else if a >= consts.MEMORY_START_AI and a < consts.MEMORY_START_AI + consts.MEMORY_SIZE_AI
      #alert('load ai:' + dec2hex(addr));
      off_ = a - consts.MEMORY_START_AI
      core.interrupts.readAI off_
    else if a >= consts.MEMORY_START_PI and a < consts.MEMORY_START_PI + consts.MEMORY_SIZE_PI
      # alert('load pi:' + dec2hex(addr));
      off_ = a - consts.MEMORY_START_PI
      @piUint8Array[off_] << 24 | @piUint8Array[off_ + 1] << 16 | @piUint8Array[off_ + 2] << 8 | @piUint8Array[off_ + 3]
    else if a >= consts.MEMORY_START_SI and a < consts.MEMORY_START_SI + consts.MEMORY_SIZE_SI
      # alert('load si');
      off_ = a - consts.MEMORY_START_SI
      core.interrupts.readSI off_
    else if a >= consts.MEMORY_START_C2A1 and a < consts.MEMORY_START_C2A1 + consts.MEMORY_SIZE_C2A1
      off_ = a - consts.MEMORY_START_C2A1
      @c2a1Uint8Array[off_] << 24 | @c2a1Uint8Array[off_ + 1] << 16 | @c2a1Uint8Array[off_ + 2] << 8 | @c2a1Uint8Array[off_ + 3]
    else if a >= consts.MEMORY_START_C1A1 and a < consts.MEMORY_START_C1A1 + consts.MEMORY_SIZE_C1A1
      off_ = a - consts.MEMORY_START_C1A1
      @c1a1Uint8Array[off_] << 24 | @c1a1Uint8Array[off_ + 1] << 16 | @c1a1Uint8Array[off_ + 2] << 8 | @c1a1Uint8Array[off_ + 3]
    else if a >= consts.MEMORY_START_C2A2 and a < consts.MEMORY_START_C2A2 + consts.MEMORY_SIZE_C2A2
      off_ = a - consts.MEMORY_START_C2A2
      @c2a2Uint8Array[off_] << 24 | @c2a2Uint8Array[off_ + 1] << 16 | @c2a2Uint8Array[off_ + 2] << 8 | @c2a2Uint8Array[off_ + 3]
    else if a >= consts.MEMORY_START_ROM_IMAGE and a < consts.MEMORY_START_ROM_IMAGE + romLength
      #alert('load rom');
      off_ = a - consts.MEMORY_START_ROM_IMAGE
      @romUint8Array[off_] << 24 | @romUint8Array[off_ + 1] << 16 | @romUint8Array[off_ + 2] << 8 | @romUint8Array[off_ + 3]
    else if a >= consts.MEMORY_START_C1A3 and a < consts.MEMORY_START_C1A3 + consts.MEMORY_SIZE_C1A3
      off_ = a - consts.MEMORY_START_C1A3
      @c1a3Uint8Array[off_] << 24 | @c1a3Uint8Array[off_ + 1] << 16 | @c1a3Uint8Array[off_ + 2] << 8 | @c1a3Uint8Array[off_ + 3]
    else if a >= consts.MEMORY_START_RI and a < consts.MEMORY_START_RI + consts.MEMORY_SIZE_RI
      off_ = a - consts.MEMORY_START_RI
      @riUint8Array[off_] << 24 | @riUint8Array[off_ + 1] << 16 | @riUint8Array[off_ + 2] << 8 | @riUint8Array[off_ + 3]
    else if a >= consts.MEMORY_START_PIF and a < consts.MEMORY_START_PIF + consts.MEMORY_SIZE_PIF
      off_ = a - consts.MEMORY_START_PIF
      @pifUint8Array[off_] << 24 | @pifUint8Array[off_ + 1] << 16 | @pifUint8Array[off_ + 2] << 8 | @pifUint8Array[off_ + 3]
    else if a >= consts.MEMORY_START_GIO and a < consts.MEMORY_START_GIO + consts.MEMORY_SIZE_GIO_REG
      off_ = a - consts.MEMORY_START_GIO
      @gioUint8Array[off_] << 24 | @gioUint8Array[off_ + 1] << 16 | @gioUint8Array[off_ + 2] << 8 | @gioUint8Array[off_ + 3]
    else if a >= consts.MEMORY_START_RAMREGS0 and a < consts.MEMORY_START_RAMREGS0 + consts.MEMORY_SIZE_RAMREGS0
      off_ = a - consts.MEMORY_START_RAMREGS0
      @ramRegs0Uint8Array[off_] << 24 | @ramRegs0Uint8Array[off_ + 1] << 16 | @ramRegs0Uint8Array[off_ + 2] << 8 | @ramRegs0Uint8Array[off_ + 3]
    else if a >= consts.MEMORY_START_RAMREGS8 and a < consts.MEMORY_START_RAMREGS8 + consts.MEMORY_SIZE_RAMREGS8
      off_ = a - consts.MEMORY_START_RAMREGS8
      @ramRegs8Uint8Array[off_] << 24 | @ramRegs8Uint8Array[off_ + 1] << 16 | @ramRegs8Uint8Array[off_ + 2] << 8 | @ramRegs8Uint8Array[off_ + 3]
    else
      log "reading from invalid memory at " + dec2hex(addr)
      #stopEmulator();
      off_ = a & 0x0000fffc
      @dummyReadWriteUint8Array[off_] << 24 | @dummyReadWriteUint8Array[off_ + 1] << 16 | @dummyReadWriteUint8Array[off_ + 2] << 8 | @dummyReadWriteUint8Array[off_ + 3]

  @storeWord = (val, addr, pc, isDelaySlot) ->
    a = addr & 0x1FFFFFFF
    if a >= consts.MEMORY_START_RDRAM and a < consts.MEMORY_START_RDRAM + consts.MEMORY_SIZE_RDRAM
      off_ = a - consts.MEMORY_START_RDRAM
      @rdramUint8Array[off_] = val >> 24
      @rdramUint8Array[off_ + 1] = val >> 16
      @rdramUint8Array[off_ + 2] = val >> 8
      @rdramUint8Array[off_ + 3] = val
      return
    else if a >= consts.MEMORY_START_SPMEM and a < consts.MEMORY_START_SPMEM + consts.MEMORY_SIZE_SPMEM
      off_ = a - consts.MEMORY_START_SPMEM
      @spMemUint8Array[off_] = val >> 24
      @spMemUint8Array[off_ + 1] = val >> 16
      @spMemUint8Array[off_ + 2] = val >> 8
      @spMemUint8Array[off_ + 3] = val
      return
    else if a >= consts.MEMORY_START_RI and a < consts.MEMORY_START_RI + consts.MEMORY_SIZE_RI
      off_ = a - consts.MEMORY_START_RI
      @riUint8Array[off_] = val >> 24
      @riUint8Array[off_ + 1] = val >> 16
      @riUint8Array[off_ + 2] = val >> 8
      @riUint8Array[off_ + 3] = val
      return
    else if a >= consts.MEMORY_START_MI and a < consts.MEMORY_START_MI + consts.MEMORY_SIZE_MI
      off_ = a - consts.MEMORY_START_MI
      core.interrupts.writeMI off_, val, pc, isDelaySlot
      return
    else if a >= consts.MEMORY_START_RAMREGS8 and a < consts.MEMORY_START_RAMREGS8 + consts.MEMORY_SIZE_RAMREGS8
      off_ = a - consts.MEMORY_START_RAMREGS8
      @ramRegs8Uint8Array[off_] = val >> 24
      @ramRegs8Uint8Array[off_ + 1] = val >> 16
      @ramRegs8Uint8Array[off_ + 2] = val >> 8
      @ramRegs8Uint8Array[off_ + 3] = val
      return
    else if a >= consts.MEMORY_START_RAMREGS4 and a < consts.MEMORY_START_RAMREGS4 + consts.MEMORY_SIZE_RAMREGS4
      off_ = a - consts.MEMORY_START_RAMREGS4
      @ramRegs4Uint8Array[off_] = val >> 24
      @ramRegs4Uint8Array[off_ + 1] = val >> 16
      @ramRegs4Uint8Array[off_ + 2] = val >> 8
      @ramRegs4Uint8Array[off_ + 3] = val
      return
    else if a >= consts.MEMORY_START_RAMREGS0 and a < consts.MEMORY_START_RAMREGS0 + consts.MEMORY_SIZE_RAMREGS0
      off_ = a - consts.MEMORY_START_RAMREGS0
      @ramRegs0Uint8Array[off_] = val >> 24
      @ramRegs0Uint8Array[off_ + 1] = val >> 16
      @ramRegs0Uint8Array[off_ + 2] = val >> 8
      @ramRegs0Uint8Array[off_ + 3] = val
      return
    else if a >= consts.MEMORY_START_SPREG_1 and a < consts.MEMORY_START_SPREG_1 + consts.MEMORY_SIZE_SPREG_1
      off_ = a - consts.MEMORY_START_SPREG_1
      core.interrupts.writeSPReg1 off_, val, pc, isDelaySlot
      return
    else if a >= consts.MEMORY_START_PI and a < consts.MEMORY_START_PI + consts.MEMORY_SIZE_PI
      off_ = a - consts.MEMORY_START_PI
      core.interrupts.writePI off_, val, pc, isDelaySlot
      return
    else if a >= consts.MEMORY_START_SI and a < consts.MEMORY_START_SI + consts.MEMORY_SIZE_SI
      off_ = a - consts.MEMORY_START_SI
      core.interrupts.writeSI off_, val, pc, isDelaySlot
      return
    else if a >= consts.MEMORY_START_AI and a < consts.MEMORY_START_AI + consts.MEMORY_SIZE_AI
      off_ = a - consts.MEMORY_START_AI
      core.interrupts.writeAI off_, val, pc, isDelaySlot
      return
    else if a >= consts.MEMORY_START_VI and a < consts.MEMORY_START_VI + consts.MEMORY_SIZE_VI
      off_ = a - consts.MEMORY_START_VI
      core.interrupts.writeVI off_, val, pc, isDelaySlot
      return
    else if a >= consts.MEMORY_START_SPREG_2 and a < consts.MEMORY_START_SPREG_2 + consts.MEMORY_SIZE_SPREG_2
      off_ = a - consts.MEMORY_START_SPREG_2
      core.interrupts.writeSPReg2 off_, val, pc, isDelaySlot
      return
    else if a >= consts.MEMORY_START_DPC and a < consts.MEMORY_START_DPC + consts.MEMORY_SIZE_DPC
      off_ = a - consts.MEMORY_START_DPC
      core.interrupts.writeDPC off_, val, pc, isDelaySlot
      return
    else if a >= consts.MEMORY_START_DPS and a < consts.MEMORY_START_DPS + consts.MEMORY_SIZE_DPS
      off_ = a - consts.MEMORY_START_DPS
      @dpsUint8Array[off_] = val >> 24
      @dpsUint8Array[off_ + 1] = val >> 16
      @dpsUint8Array[off_ + 2] = val >> 8
      @dpsUint8Array[off_ + 3] = val
      return
    else if a >= consts.MEMORY_START_C2A1 and a < consts.MEMORY_START_C2A1 + consts.MEMORY_SIZE_C2A1
      off_ = a - consts.MEMORY_START_C2A1
      @c2a1Uint8Array[off_] = val >> 24
      @c2a1Uint8Array[off_ + 1] = val >> 16
      @c2a1Uint8Array[off_ + 2] = val >> 8
      @c2a1Uint8Array[off_ + 3] = val
      return
    else if a >= consts.MEMORY_START_C1A1 and a < consts.MEMORY_START_C1A1 + consts.MEMORY_SIZE_C1A1
      off_ = a - consts.MEMORY_START_C1A1
      @c1a1Uint8Array[off_] = val >> 24
      @c1a1Uint8Array[off_ + 1] = val >> 16
      @c1a1Uint8Array[off_ + 2] = val >> 8
      @c1a1Uint8Array[off_ + 3] = val
      return
    else if a >= consts.MEMORY_START_C2A2 and a < consts.MEMORY_START_C2A2 + consts.MEMORY_SIZE_C2A2
      off_ = a - consts.MEMORY_START_C2A2
      @c2a2Uint8Array[off_] = val >> 24
      @c2a2Uint8Array[off_ + 1] = val >> 16
      @c2a2Uint8Array[off_ + 2] = val >> 8
      @c2a2Uint8Array[off_ + 3] = val
      return
    else if a >= consts.MEMORY_START_ROM_IMAGE and a < consts.MEMORY_START_ROM_IMAGE + romLength
      alert "attempt to overwrite rom!"
      off_ = a - consts.MEMORY_START_ROM_IMAGE
      @romUint8Array[off_] = val >> 24
      @romUint8Array[off_ + 1] = val >> 16
      @romUint8Array[off_ + 2] = val >> 8
      @romUint8Array[off_ + 3] = val
      return
    else if a >= consts.MEMORY_START_C1A3 and a < consts.MEMORY_START_C1A3 + consts.MEMORY_SIZE_C1A3
      off_ = a - consts.MEMORY_START_C1A3
      @c1a3Uint8Array[off_] = val >> 24
      @c1a3Uint8Array[off_ + 1] = val >> 16
      @c1a3Uint8Array[off_ + 2] = val >> 8
      @c1a3Uint8Array[off_ + 3] = val
      return
    else if a >= consts.MEMORY_START_PIF and a < consts.MEMORY_START_PIF + consts.MEMORY_SIZE_PIF
      off_ = a - consts.MEMORY_START_PIF
      @pifUint8Array[off_] = val >> 24
      @pifUint8Array[off_ + 1] = val >> 16
      @pifUint8Array[off_ + 2] = val >> 8
      @pifUint8Array[off_ + 3] = val
      return
    else if a >= consts.MEMORY_START_GIO and a < consts.MEMORY_START_GIO + consts.MEMORY_SIZE_GIO_REG
      off_ = a - consts.MEMORY_START_GIO
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
    if a >= consts.MEMORY_START_RDRAM and a < consts.MEMORY_START_RDRAM + consts.MEMORY_SIZE_RDRAM
      off_ = a - consts.MEMORY_START_RDRAM
      @rdramUint8Array[off_] = val
      return
    else if a >= consts.MEMORY_START_SPMEM and a < consts.MEMORY_START_SPMEM + consts.MEMORY_SIZE_SPMEM
      off_ = a - consts.MEMORY_START_SPMEM
      @spMemUint8Array[off_] = val
      return
    else if a >= consts.MEMORY_START_RI and a < consts.MEMORY_START_RI + consts.MEMORY_SIZE_RI
      off_ = a - consts.MEMORY_START_RI
      @riUint8Array[off_] = val
      return
    else if a >= consts.MEMORY_START_MI and a < consts.MEMORY_START_MI + consts.MEMORY_SIZE_MI
      off_ = a - consts.MEMORY_START_MI
      core.interrupts.writeMI off_, val, pc, isDelaySlot
      return
    else if a >= consts.MEMORY_START_RAMREGS8 and a < consts.MEMORY_START_RAMREGS8 + consts.MEMORY_SIZE_RAMREGS8
      off_ = a - consts.MEMORY_START_RAMREGS8
      @ramRegs8Uint8Array[off_] = val
      return
    else if a >= consts.MEMORY_START_RAMREGS4 and a < consts.MEMORY_START_RAMREGS4 + consts.MEMORY_SIZE_RAMREGS4
      off_ = a - consts.MEMORY_START_RAMREGS4
      @ramRegs4Uint8Array[off_] = val
      return
    else if a >= consts.MEMORY_START_RAMREGS0 and a < consts.MEMORY_START_RAMREGS0 + consts.MEMORY_SIZE_RAMREGS0
      off_ = a - consts.MEMORY_START_RAMREGS0
      @ramRegs0Uint8Array[off_] = val
      return
    else if a >= consts.MEMORY_START_SPREG_1 and a < consts.MEMORY_START_SPREG_1 + consts.MEMORY_SIZE_SPREG_1
      off_ = a - consts.MEMORY_START_SPREG_1
      core.interrupts.writeSPReg1 off_, val, pc, isDelaySlot
      return
    else if a >= consts.MEMORY_START_PI and a < consts.MEMORY_START_PI + consts.MEMORY_SIZE_PI
      off_ = a - consts.MEMORY_START_PI
      core.interrupts.writePI off_, val, pc, isDelaySlot
      return
    else if a >= consts.MEMORY_START_SI and a < consts.MEMORY_START_SI + consts.MEMORY_SIZE_SI
      off_ = a - consts.MEMORY_START_SI
      core.interrupts.writeSI off_, val, pc, isDelaySlot
      return
    else if a >= consts.MEMORY_START_AI and a < consts.MEMORY_START_AI + consts.MEMORY_SIZE_AI
      off_ = a - consts.MEMORY_START_AI
      core.interrupts.writeAI off_, val, pc, isDelaySlot
      return
    else if a >= consts.MEMORY_START_VI and a < consts.MEMORY_START_VI + consts.MEMORY_SIZE_VI
      off_ = a - consts.MEMORY_START_VI
      core.interrupts.writeVI off_, val, pc, isDelaySlot
      return
    else if a >= consts.MEMORY_START_SPREG_2 and a < consts.MEMORY_START_SPREG_2 + consts.MEMORY_SIZE_SPREG_2
      off_ = a - consts.MEMORY_START_SPREG_2
      core.interrupts.writeSPReg2 off_, val, pc, isDelaySlot
      return
    else if a >= consts.MEMORY_START_DPC and a < consts.MEMORY_START_DPC + consts.MEMORY_SIZE_DPC
      off_ = a - consts.MEMORY_START_DPC
      core.interrupts.writeDPC off_, val, pc, isDelaySlot
      return
    else if a >= consts.MEMORY_START_DPS and a < consts.MEMORY_START_DPS + consts.MEMORY_SIZE_DPS
      off_ = a - consts.MEMORY_START_DPS
      @dpsUint8Array[off_] = val
      return
    else if a >= consts.MEMORY_START_C2A1 and a < consts.MEMORY_START_C2A1 + consts.MEMORY_SIZE_C2A1
      off_ = a - consts.MEMORY_START_C2A1
      @c2a1Uint8Array[off_] = val
      return
    else if a >= consts.MEMORY_START_C1A1 and a < consts.MEMORY_START_C1A1 + consts.MEMORY_SIZE_C1A1
      off_ = a - consts.MEMORY_START_C1A1
      @c1a1Uint8Array[off_] = val
      return
    else if a >= consts.MEMORY_START_C2A2 and a < consts.MEMORY_START_C2A2 + consts.MEMORY_SIZE_C2A2
      off_ = a - consts.MEMORY_START_C2A2
      @c2a2Uint8Array[off_] = val
      return
    else if a >= consts.MEMORY_START_ROM_IMAGE and a < consts.MEMORY_START_ROM_IMAGE + romLength
      alert "attempt to overwrite rom!"
      off_ = a - consts.MEMORY_START_ROM_IMAGE
      @romUint8Array[off_] = val
      return
    else if a >= consts.MEMORY_START_C1A3 and a < consts.MEMORY_START_C1A3 + consts.MEMORY_SIZE_C1A3
      off_ = a - consts.MEMORY_START_C1A3
      @c1a3Uint8Array[off_] = val
      return
    else if a >= consts.MEMORY_START_PIF and a < consts.MEMORY_START_PIF + consts.MEMORY_SIZE_PIF
      off_ = a - consts.MEMORY_START_PIF
      @pifUint8Array[off_] = val
      return
    else if a >= consts.MEMORY_START_GIO and a < consts.MEMORY_START_GIO + consts.MEMORY_SIZE_GIO_REG
      off_ = a - consts.MEMORY_START_GIO
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
    if a >= consts.MEMORY_START_RDRAM and a < consts.MEMORY_START_RDRAM + consts.MEMORY_SIZE_RDRAM
      off_ = a - consts.MEMORY_START_RDRAM
      @rdramUint8Array[off_] = val >> 8
      @rdramUint8Array[off_ + 1] = val
      return
    else if a >= consts.MEMORY_START_SPMEM and a < consts.MEMORY_START_SPMEM + consts.MEMORY_SIZE_SPMEM
      off_ = a - consts.MEMORY_START_SPMEM
      @spMemUint8Array[off_] = val >> 8
      @spMemUint8Array[off_ + 1] = val
      return
    else if a >= consts.MEMORY_START_RI and a < consts.MEMORY_START_RI + consts.MEMORY_SIZE_RI
      off_ = a - consts.MEMORY_START_RI
      @riUint8Array[off_] = val >> 8
      @riUint8Array[off_ + 1] = val
      return
    else if a >= consts.MEMORY_START_MI and a < consts.MEMORY_START_MI + consts.MEMORY_SIZE_MI
      off_ = a - consts.MEMORY_START_MI
      core.interrupts.writeMI off_, val, pc, isDelaySlot
      return
    else if a >= consts.MEMORY_START_RAMREGS8 and a < consts.MEMORY_START_RAMREGS8 + consts.MEMORY_SIZE_RAMREGS8
      off_ = a - consts.MEMORY_START_RAMREGS8
      @ramRegs8Uint8Array[off_] = val >> 8
      @ramRegs8Uint8Array[off_ + 1] = val
      return
    else if a >= consts.MEMORY_START_RAMREGS4 and a < consts.MEMORY_START_RAMREGS4 + consts.MEMORY_SIZE_RAMREGS4
      off_ = a - consts.MEMORY_START_RAMREGS4
      @ramRegs4Uint8Array[off_] = val >> 8
      @ramRegs4Uint8Array[off_ + 1] = val
      return
    else if a >= consts.MEMORY_START_RAMREGS0 and a < consts.MEMORY_START_RAMREGS0 + consts.MEMORY_SIZE_RAMREGS0
      off_ = a - consts.MEMORY_START_RAMREGS0
      @ramRegs0Uint8Array[off_] = val >> 8
      @ramRegs0Uint8Array[off_ + 1] = val
      return
    else if a >= consts.MEMORY_START_SPREG_1 and a < consts.MEMORY_START_SPREG_1 + consts.MEMORY_SIZE_SPREG_1
      off_ = a - consts.MEMORY_START_SPREG_1
      core.interrupts.writeSPReg1 off_, val, pc, isDelaySlot
      return
    else if a >= consts.MEMORY_START_PI and a < consts.MEMORY_START_PI + consts.MEMORY_SIZE_PI
      off_ = a - consts.MEMORY_START_PI
      core.interrupts.writePI off_, val, pc, isDelaySlot
      return
    else if a >= consts.MEMORY_START_SI and a < consts.MEMORY_START_SI + consts.MEMORY_SIZE_SI
      off_ = a - consts.MEMORY_START_SI
      core.interrupts.writeSI off_, val, pc, isDelaySlot
      return
    else if a >= consts.MEMORY_START_AI and a < consts.MEMORY_START_AI + consts.MEMORY_SIZE_AI
      off_ = a - consts.MEMORY_START_AI
      core.interrupts.writeAI off_, val, pc, isDelaySlot
      return
    else if a >= consts.MEMORY_START_VI and a < consts.MEMORY_START_VI + consts.MEMORY_SIZE_VI
      off_ = a - consts.MEMORY_START_VI
      core.interrupts.writeVI off_, val, pc, isDelaySlot
      return
    else if a >= consts.MEMORY_START_SPREG_2 and a < consts.MEMORY_START_SPREG_2 + consts.MEMORY_SIZE_SPREG_2
      off_ = a - consts.MEMORY_START_SPREG_2
      core.interrupts.writeSPReg2 off_, val, pc, isDelaySlot
      return
    else if a >= consts.MEMORY_START_DPC and a < consts.MEMORY_START_DPC + consts.MEMORY_SIZE_DPC
      off_ = a - consts.MEMORY_START_DPC
      core.interrupts.writeDPC off_, val, pc, isDelaySlot
      return
    else if a >= consts.MEMORY_START_DPS and a < consts.MEMORY_START_DPS + consts.MEMORY_SIZE_DPS
      off_ = a - consts.MEMORY_START_DPS
      @dpsUint8Array[off_] = val >> 8
      @dpsUint8Array[off_ + 1] = val
      return
    else if a >= consts.MEMORY_START_C2A1 and a < consts.MEMORY_START_C2A1 + consts.MEMORY_SIZE_C2A1
      off_ = a - consts.MEMORY_START_C2A1
      @c2a1Uint8Array[off_] = val >> 8
      @c2a1Uint8Array[off_ + 1] = val
      return
    else if a >= consts.MEMORY_START_C1A1 and a < consts.MEMORY_START_C1A1 + consts.MEMORY_SIZE_C1A1
      off_ = a - consts.MEMORY_START_C1A1
      @c1a1Uint8Array[off_] = val >> 8
      @c1a1Uint8Array[off_ + 1] = val
      return
    else if a >= consts.MEMORY_START_C2A2 and a < consts.MEMORY_START_C2A2 + consts.MEMORY_SIZE_C2A2
      off_ = a - consts.MEMORY_START_C2A2
      @c2a2Uint8Array[off_] = val >> 8
      @c2a2Uint8Array[off_ + 1] = val
      return
    else if a >= consts.MEMORY_START_ROM_IMAGE and a < consts.MEMORY_START_ROM_IMAGE + romLength
      alert "attempt to overwrite rom!"
      off_ = a - consts.MEMORY_START_ROM_IMAGE
      @romUint8Array[off_] = val >> 8
      @romUint8Array[off_ + 1] = val
      return
    else if a >= consts.MEMORY_START_C1A3 and a < consts.MEMORY_START_C1A3 + consts.MEMORY_SIZE_C1A3
      off_ = a - consts.MEMORY_START_C1A3
      @c1a3Uint8Array[off_] = val >> 8
      @c1a3Uint8Array[off_ + 1] = val
      return
    else if a >= consts.MEMORY_START_PIF and a < consts.MEMORY_START_PIF + consts.MEMORY_SIZE_PIF
      off_ = a - consts.MEMORY_START_PIF
      @pifUint8Array[off_] = val >> 8
      @pifUint8Array[off_ + 1] = val
      return
    else if a >= consts.MEMORY_START_GIO and a < consts.MEMORY_START_GIO + consts.MEMORY_SIZE_GIO_REG
      off_ = a - consts.MEMORY_START_GIO
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
