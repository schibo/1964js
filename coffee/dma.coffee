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
#jslint devel: true
#globals consts, C1964jsEmulator
#console.log(message);

"use strict"
class C1964jsDMA
  constructor: (memory, interrupts, pif) ->
    @startTime = 0
    @memory = memory
    @interrupts = interrupts
    @pif = pif
    @audio = undefined

  copyCartToDram: (pc, isDelaySlot) ->
    end = @memory.getInt32(@memory.piUint8Array, consts.PI_WR_LEN_REG)
    to = @memory.getInt32(@memory.piUint8Array, consts.PI_DRAM_ADDR_REG)
    from = @memory.getInt32(@memory.piUint8Array, consts.PI_CART_ADDR_REG)
    log "pi dma write " + (end + 1) + " bytes from " + dec2hex(from) + " to " + dec2hex(to)
    end &= 0x00ffffff
    to &= 0x00ffffff
    transfer = end
    remaining = -1

    #end+1 is how many bytes will be copied.
    if (from & 0x10000000) isnt 0
      from &= 0x0fffffff

      #the ROM buffer size could be less than the amount requested
      #because the file is not padded with zeros.
      if from + end + 1 > @memory.rom.byteLength
        transfer = @memory.rom.byteLength - from - 1
        remaining = end - transfer
      `const d = this.memory.u8`
      `const r = this.memory.romUint8Array`
      while transfer >= 0
        d[to] = r[from]
        to++
        from++
        --transfer

    #if (remaining !== -1)
    #    alert('doh!' + remaining);
    else
      alert "pi reading from somewhere other than cartridge domain"
      while end-- >= 0
        d[to] = @memory.lb(from)
        from++
        to++

    # clrFlag(spReg1Uint8Array, SP_STATUS_REG, SP_STATUS_HALT);
    @interrupts.clrFlag @memory.piUint8Array, consts.PI_STATUS_REG, consts.PI_STATUS_IO_BUSY | consts.PI_STATUS_DMA_BUSY
    @interrupts.triggerPIInterrupt pc, isDelaySlot
    return

  copySiToDram: (pc, isDelaySlot) ->
    end = 63 #read 64 bytes. Is there an si_wr_len_reg?
    to = @memory.getInt32(@memory.siUint8Array, consts.SI_DRAM_ADDR_REG)
    from = @memory.getInt32(@memory.siUint8Array, consts.SI_PIF_ADDR_RD64B_REG)
    throw Error "Unhandled: SI_DRAM_ADDR_RD64B_REG = " + from  if from isnt 0x1FC007C0
    log "si dma write " + (end + 1) + " bytes from " + dec2hex(from) + " to " + dec2hex(to)
    end &= 0x00ffffff
    to &= 0x0fffffff
    from &= 0x0000ffff
    @pif.processPif()
    while end >= 0
      @memory.u8[to] = @memory.pifUint8Array[from]
      to++
      from++
      --end
    @interrupts.setFlag @memory.siUint8Array, consts.SI_STATUS_REG, consts.SI_STATUS_INTERRUPT
    @interrupts.triggerSIInterrupt pc, isDelaySlot
    return

  copyDramToAi: (pc, isDelaySlot) ->
    length = @memory.getInt32(@memory.aiUint8Array, consts.AI_LEN_REG)
    from = @memory.getInt32(@memory.aiUint8Array, consts.AI_DRAM_ADDR_REG)
    
    #log('ai dma write ' + length + ' bytes from ' + dec2hex(from));
    length &= 0x00ffffff
    from &= 0x0fffffff
    if @audio is `undefined`
      @audio = new C1964jsAudio()

    if @audio.processAudio(@memory, from, length) is false
      @interrupts.clrFlag @memory.aiUint8Array, consts.AI_STATUS_REG, consts.AI_STATUS_FIFO_FULL
 
    @interrupts.setFlag @memory.aiUint8Array, consts.AI_STATUS_REG, consts.AI_STATUS_FIFO_FULL
    #@interrupts.triggerAIInterrupt 0, false
    return

  copyDramToSi: (pc, isDelaySlot) ->
    end = 63 #read 64 bytes. Is there an si_rd_len_reg?
    to = @memory.getInt32(@memory.siUint8Array, consts.SI_PIF_ADDR_WR64B_REG)
    from = @memory.getInt32(@memory.siUint8Array, consts.SI_DRAM_ADDR_REG)
    throw Error "Unhandled: SI_DRAM_ADDR_RD64B_REG = " + from  if to isnt 0x1FC007C0
    log "si dma read " + (end + 1) + " bytes from " + dec2hex(from) + " to " + dec2hex(to)
    end &= 0x00ffffff
    to &= 0x0000ffff
    from &= 0x0fffffff
    while end >= 0
      @memory.pifUint8Array[to] = @memory.u8[from]
      to++
      from++
      --end
    #@pif.processPif()
    @interrupts.setFlag @memory.siUint8Array, consts.SI_STATUS_REG, consts.SI_STATUS_INTERRUPT
    @interrupts.triggerSIInterrupt pc, isDelaySlot
    return

  copySpToDram: (pc, isDelaySlot) ->
    alert "todo: copySpToDram"
    return

  copyDramToSp: (pc, isDelaySlot) ->
    end = @memory.getInt32(@memory.spReg1Uint8Array, consts.SP_RD_LEN_REG)
    to = @memory.getInt32(@memory.spReg1Uint8Array, consts.SP_MEM_ADDR_REG)
    from = @memory.getInt32(@memory.spReg1Uint8Array, consts.SP_DRAM_ADDR_REG)
    log "sp dma read " + (end + 1) + " bytes from " + dec2hex(from) + " to " + dec2hex(to)
    end &= 0x00000FFF
    to &= 0x00001fff
    from &= 0x00ffffff
    while end >= 0
      @memory.spMemUint8Array[to] = @memory.u8[from]
      to++
      from++
      --end
    @memory.setInt32 @memory.spReg1Uint8Array, consts.SP_DMA_BUSY_REG, 0
    alert "hmm..todo: an sp fp status flag is blocking from continuing"  if @memory.getInt32(@memory.spReg1Uint8Array, consts.SP_STATUS_REG) & (consts.SP_STATUS_DMA_BUSY | consts.SP_STATUS_IO_FULL | consts.SP_STATUS_DMA_FULL)
    @interrupts.clrFlag @memory.spReg1Uint8Array, consts.SP_STATUS_REG, consts.SP_STATUS_DMA_BUSY
    @interrupts.setFlag @memory.spReg1Uint8Array, consts.SP_STATUS_REG, consts.SP_STATUS_HALT
    return

#hack for now
#triggerDPInterrupt(0, false);

#hack global space until we export classes properly
#node.js uses exports; browser uses this (window)
root = exports ? self
root.C1964jsDMA = C1964jsDMA
root.log = (message) ->
  "use strict"
  return