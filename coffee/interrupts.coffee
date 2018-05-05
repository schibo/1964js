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
#1964cpp treats consts.MI_INTR_MASK_REG_R as a separate memory location. Not sure that's right.
#jslint bitwise: true, devel: true, todo: true
#globals consts, log, C1964jsVideoHLE

    #SP_STATUS_REG read flags
`/** @const */ SP_STATUS_HALT = 0x0001`
`/** @const */ SP_STATUS_BROKE = 0x0002`
`/** @const */ SP_STATUS_DMA_BUSY = 0x0004`
`/** @const */ SP_STATUS_DMA_FULL = 0x0008`
`/** @const */ SP_STATUS_IO_FULL = 0x0010`
`/** @const */ SP_STATUS_SSTEP = 0x0020`
`/** @const */ SP_STATUS_INTR_BREAK = 0x0040`
`/** @const */ SP_STATUS_YIELD = 0x0080`
`/** @const */ SP_STATUS_YIELDED = 0x0100`
`/** @const */ SP_STATUS_TASKDONE = 0x0200`
`/** @const */ SP_STATUS_SIG3 = 0x0400`
`/** @const */ SP_STATUS_SIG4 = 0x0800`
`/** @const */ SP_STATUS_SIG5 = 0x1000`
`/** @const */ SP_STATUS_SIG6 = 0x2000`
`/** @const */ SP_STATUS_SIG7 = 0x4000`

#SP_STATUS_REG write flags
`/** @const */ SP_CLR_HALT = 0x0000001`
`/** @const */ SP_SET_HALT = 0x0000002`
`/** @const */ SP_CLR_BROKE = 0x0000004`
`/** @const */ SP_CLR_INTR = 0x0000008`
`/** @const */ SP_SET_INTR = 0x0000010`
`/** @const */ SP_CLR_SSTEP = 0x0000020`
`/** @const */ SP_SET_SSTEP = 0x0000040`
`/** @const */ SP_CLR_INTR_BREAK = 0x0000080`
`/** @const */ SP_SET_INTR_BREAK = 0x0000100`
`/** @const */ SP_CLR_YIELD = 0x0000200`
`/** @const */ SP_SET_YIELD = 0x0000400`
`/** @const */ SP_CLR_YIELDED = 0x0000800`
`/** @const */ SP_SET_YIELDED = 0x0001000`
`/** @const */ SP_CLR_TASKDONE = 0x0002000`
`/** @const */ SP_SET_TASKDONE = 0x0004000`
`/** @const */ SP_CLR_SIG3 = 0x0008000`
`/** @const */ SP_SET_SIG3 = 0x0010000`
`/** @const */ SP_CLR_SIG4 = 0x0020000`
`/** @const */ SP_SET_SIG4 = 0x0040000`
`/** @const */ SP_CLR_SIG5 = 0x0080000`
`/** @const */ SP_SET_SIG5 = 0x0100000`
`/** @const */ SP_CLR_SIG6 = 0x0200000`
`/** @const */ SP_SET_SIG6 = 0x0400000`
`/** @const */ SP_CLR_SIG7 = 0x0800000`
`/** @const */ SP_SET_SIG7 = 0x1000000`

currentHack = 0
C1964jsInterrupts = (core, cp0) ->
  "use strict"

  @delayNextInterrupt = false

  @setException = (exception, causeFlag, pc, isFromDelaySlot) ->
    #log('set exception');
    cp0[consts.CAUSE] |= exception
    cp0[consts.CAUSE] |= causeFlag
    return

  @processException = (pc, isFromDelaySlot) ->

    # we don't want to process interrupts immediately
    if @delayNextInterrupt is true
      core.m[0] = -156250
      @delayNextInterrupt = false
      return

    return false  if (cp0[consts.STATUS] & consts.IE) is 0
    if (cp0[consts.STATUS] & consts.EXL) isnt 0
      #log "nested exception"
      return false
    cp0[consts.CAUSE] &= 0xFFFFFF83 #Clear exception code flags
    cp0[consts.STATUS] |= consts.EXL
    if isFromDelaySlot is true
      #log "Exception happens in CPU delay slot, pc=" + pc
      cp0[consts.CAUSE] |= consts.BD
      cp0[consts.EPC] = pc - 4

    # throw 'interrupt';
    else
      cp0[consts.CAUSE] &= ~consts.BD
      cp0[consts.EPC] = pc

    #throw 'interrupt';
    core.flushDynaCache()  if core.doOnce is 0
    core.doOnce = 1
    core.p[0] = 0x80000180
    true

  @triggerCompareInterrupt = (pc, isFromDelaySlot) ->
    @setException consts.EXC_INT, consts.CAUSE_IP8, pc, isFromDelaySlot
    #if core.interval is 3 #don't process immediately
    #core.m[0] = -156250
    return

  @triggerPIInterrupt = (pc, isFromDelaySlot) ->
    @setFlag core.memory.miUint8Array, consts.MI_INTR_REG, consts.MI_INTR_PI
    value = core.memory.miUint8Array[consts.MI_INTR_MASK_REG] << 24 | core.memory.miUint8Array[consts.MI_INTR_MASK_REG + 1] << 16 | core.memory.miUint8Array[consts.MI_INTR_MASK_REG + 2] << 8 | core.memory.miUint8Array[consts.MI_INTR_MASK_REG + 3]
    @setException consts.EXC_INT, consts.CAUSE_IP3, pc, isFromDelaySlot  if (value & consts.MI_INTR_MASK_PI) isnt 0
    return

  @triggerSPInterrupt = (pc, isFromDelaySlot) ->
    @setFlag core.memory.miUint8Array, consts.MI_INTR_REG, consts.MI_INTR_SP
    value = core.memory.miUint8Array[consts.MI_INTR_MASK_REG] << 24 | core.memory.miUint8Array[consts.MI_INTR_MASK_REG + 1] << 16 | core.memory.miUint8Array[consts.MI_INTR_MASK_REG + 2] << 8 | core.memory.miUint8Array[consts.MI_INTR_MASK_REG + 3]
    @setException consts.EXC_INT, consts.CAUSE_IP3, pc, isFromDelaySlot  if (value & consts.MI_INTR_MASK_SP) isnt 0
    return

  @triggerVIInterrupt = (pc, isFromDelaySlot) ->
    @setFlag core.memory.miUint8Array, consts.MI_INTR_REG, consts.MI_INTR_VI
    value = core.memory.miUint8Array[consts.MI_INTR_MASK_REG] << 24 | core.memory.miUint8Array[consts.MI_INTR_MASK_REG + 1] << 16 | core.memory.miUint8Array[consts.MI_INTR_MASK_REG + 2] << 8 | core.memory.miUint8Array[consts.MI_INTR_MASK_REG + 3]
    @setException consts.EXC_INT, consts.CAUSE_IP3, pc, isFromDelaySlot  if (value & consts.MI_INTR_MASK_VI) isnt 0
    return

  @triggerSIInterrupt = (pc, isFromDelaySlot) ->
    @setFlag core.memory.miUint8Array, consts.MI_INTR_REG, consts.MI_INTR_SI
    value = core.memory.miUint8Array[consts.MI_INTR_MASK_REG] << 24 | core.memory.miUint8Array[consts.MI_INTR_MASK_REG + 1] << 16 | core.memory.miUint8Array[consts.MI_INTR_MASK_REG + 2] << 8 | core.memory.miUint8Array[consts.MI_INTR_MASK_REG + 3]
    @setException consts.EXC_INT, consts.CAUSE_IP3, pc, isFromDelaySlot  if (value & consts.MI_INTR_MASK_SI) isnt 0
    return

  @triggerAIInterrupt = (pc, isFromDelaySlot) ->
    @setFlag core.memory.miUint8Array, consts.MI_INTR_REG, consts.MI_INTR_AI
    value = core.memory.miUint8Array[consts.MI_INTR_MASK_REG] << 24 | core.memory.miUint8Array[consts.MI_INTR_MASK_REG + 1] << 16 | core.memory.miUint8Array[consts.MI_INTR_MASK_REG + 2] << 8 | core.memory.miUint8Array[consts.MI_INTR_MASK_REG + 3]
    @setException consts.EXC_INT, consts.CAUSE_IP3, pc, isFromDelaySlot  if (value & consts.MI_INTR_MASK_AI) isnt 0
    return

  @triggerDPInterrupt = (pc, isFromDelaySlot) ->
    @setFlag core.memory.miUint8Array, consts.MI_INTR_REG, consts.MI_INTR_DP
    value = core.memory.miUint8Array[consts.MI_INTR_MASK_REG] << 24 | core.memory.miUint8Array[consts.MI_INTR_MASK_REG + 1] << 16 | core.memory.miUint8Array[consts.MI_INTR_MASK_REG + 2] << 8 | core.memory.miUint8Array[consts.MI_INTR_MASK_REG + 3]
    @setException consts.EXC_INT, consts.CAUSE_IP3, pc, isFromDelaySlot  if (value & consts.MI_INTR_MASK_DP) isnt 0
    return

  @triggerRspBreak = ->
    @setFlag core.memory.spReg1Uint8Array, consts.SP_STATUS_REG, consts.SP_STATUS_TASKDONE | consts.SP_STATUS_BROKE | consts.SP_STATUS_HALT
    value = core.memory.spReg1Uint8Array[consts.SP_STATUS_REG] << 24 | core.memory.spReg1Uint8Array[consts.SP_STATUS_REG + 1] << 16 | core.memory.spReg1Uint8Array[consts.SP_STATUS_REG + 2] << 8 | core.memory.spReg1Uint8Array[consts.SP_STATUS_REG + 3]
    @triggerSPInterrupt 0, false  if (value & consts.SP_STATUS_INTR_BREAK) isnt 0
    return

  @clearMIInterrupt = (flag) ->
    @clrFlag core.memory.miUint8Array, consts.MI_INTR_REG, flag
    miIntrMaskReg = core.memory.miUint8Array[consts.MI_INTR_MASK_REG] << 24 | core.memory.miUint8Array[consts.MI_INTR_MASK_REG + 1] << 16 | core.memory.miUint8Array[consts.MI_INTR_MASK_REG + 2] << 8 | core.memory.miUint8Array[consts.MI_INTR_MASK_REG + 3]
    cp0[consts.CAUSE] &= ~consts.CAUSE_IP3  if (miIntrMaskReg & (core.memory.getUint32(core.memory.miUint8Array, consts.MI_INTR_REG))) is 0
    return

  #if((cp0[CAUSE] & cp0[STATUS] & SR_IMASK) == 0)
  #    CPUNeedToCheckInterrupt = FALSE;
  @readVI = (offset) ->
    switch offset
      when consts.VI_CURRENT_REG

        #hack for berney demo
        currentHack = 0  if (currentHack += 1) is 625

        #  triggerVIInterrupt(pc, isFromDelaySlot);
        #warning: need to refactor. triggerVIInterrupt
        #can service an interrupt immediately without setting rt[i]

        #return currentHack;
        #return ((core.memory.getInt32(core.memory.viUint8Array, offset) & 0xfffffffe) + currentHack) | 0
        return (((core.memory.viUint8Array[offset] << 24 | core.memory.viUint8Array[offset + 1] << 16 | core.memory.viUint8Array[offset + 2] << 8 | core.memory.viUint8Array[offset + 3]) & 0xfffffffe) + currentHack) | 0
      else
        #log "unhandled video interface for vi offset: " + offset
        #return core.memory.getInt32 core.memory.viUint8Array, offset
        return (core.memory.viUint8Array[offset] << 24 | core.memory.viUint8Array[offset + 1] << 16 | core.memory.viUint8Array[offset + 2] << 8 | core.memory.viUint8Array[offset + 3])

  @writeVI = (offset, value, pc, isFromDelaySlot) ->
    switch offset
      when consts.VI_ORIGIN_REG
        core.memory.setInt32 core.memory.viUint8Array, offset, value
      #var c = document.getElementById("Canvas");
      #var ctx = c.getContext("2d");
      #repaint(ctx,ImDat,value & 0x00FFFFFF);
      #alert('origin changed' + dec2hex(value));
      when consts.VI_CURRENT_REG
        @clearMIInterrupt consts.MI_INTR_VI
        core.memory.setInt32 core.memory.viUint8Array, offset, value
      when consts.VI_INTR_REG
        core.memory.setInt32 core.memory.viUint8Array, offset, value
      else
        core.memory.setInt32 core.memory.viUint8Array, offset, value
    return

  #log('unhandled vi write: ' + offset);
  @writePI = (offset, value, pc, isFromDelaySlot) ->
    switch offset
      when consts.PI_WR_LEN_REG
        core.memory.setInt32 core.memory.piUint8Array, offset, value
        core.dma.copyCartToDram pc, isFromDelaySlot
      when consts.PI_RD_LEN_REG
        core.memory.setInt32 core.memory.piUint8Array, offset, value
        alert "write to PI_RD_LEN_REG"
        core.dma.copyDramToCart pc, isFromDelaySlot
      when consts.PI_DRAM_ADDR_REG
        core.memory.setInt32 core.memory.piUint8Array, offset, value
      when consts.PI_CART_ADDR_REG
        core.memory.setInt32 core.memory.piUint8Array, offset, value
      when consts.PI_STATUS_REG
        @writePIStatusReg value, pc, isFromDelaySlot
      else
        core.memory.setInt32 core.memory.piUint8Array, offset, value
        #log "unhandled pi write: " + offset
    return

  @writeSI = (offset, value, pc, isFromDelaySlot) ->
    switch offset
      when consts.SI_DRAM_ADDR_REG
        core.memory.setInt32 core.memory.siUint8Array, offset, value
      when consts.SI_STATUS_REG
        @writeSIStatusReg value, pc, isFromDelaySlot
      when consts.SI_PIF_ADDR_RD64B_REG
        core.memory.setInt32 core.memory.siUint8Array, offset, value
        core.dma.copySiToDram pc, isFromDelaySlot
      when consts.SI_PIF_ADDR_WR64B_REG
        core.memory.setInt32 core.memory.siUint8Array, offset, value
        core.dma.copyDramToSi pc, isFromDelaySlot
      else
        core.memory.setInt32 core.memory.siUint8Array, offset, value
        #log "unhandled si write: " + offset
    return

  @readSI = (offset) ->
    switch offset
      when consts.SI_STATUS_REG
        @readSIStatusReg()
        return core.memory.getInt32 core.memory.siUint8Array, offset
      else
        #log "unhandled si read: " + offset
        return core.memory.getInt32 core.memory.siUint8Array, offset
    return

  @readSIStatusReg = ->
    if (core.memory.getUint32(core.memory.miUint8Array, consts.MI_INTR_REG) & consts.MI_INTR_SI) isnt 0
      @setFlag core.memory.siUint8Array, consts.SI_STATUS_REG, consts.SI_STATUS_INTERRUPT
    else
      @clrFlag core.memory.siUint8Array, consts.SI_STATUS_REG, consts.SI_STATUS_INTERRUPT
    return

  @readAI = (offset) ->
    switch offset
      when consts.AI_LEN_REG
        #todo: implement AI_LEN_REG -- how many bytes unconsumed..
        core.kfi -= 1
        if core.kfi is 0
          core.kfi = 512 #todo: this comes from viewport?
          @clrFlag core.memory.aiUint8Array, consts.AI_STATUS_REG, consts.AI_STATUS_FIFO_FULL
          #@triggerAIInterrupt 0, false
          #checkInterrupts();
          return 0
        return 0
      #return kfi;
      #return getInt32(aiUint8Array, offset);
      when consts.AI_STATUS_REG
        return core.memory.getInt32 core.memory.aiUint8Array, offset
      else
        #log "unhandled read ai reg " + offset
        return core.memory.getInt32 core.memory.aiUint8Array, offset
    return

  @writeAI = (offset, value, pc, isFromDelaySlot) ->
    switch offset
      when consts.AI_DRAM_ADDR_REG
        core.memory.setInt32 core.memory.aiUint8Array, offset, value
      when consts.AI_LEN_REG
        core.memory.setInt32 core.memory.aiUint8Array, offset, value
        core.dma.copyDramToAi pc, isFromDelaySlot
      when consts.AI_STATUS_REG
        @clearMIInterrupt consts.MI_INTR_AI
      when consts.AI_DACRATE_REG
        # log("todo: write AI_DACRATE_REG");
        core.memory.setInt32 core.memory.aiUint8Array, offset, value
      when consts.AI_CONTROL_REG
        core.memory.setInt32 core.memory.aiUint8Array, offset, value & 1
      else
        #log('unhandled write ai reg ' + offset);
        core.memory.setInt32 core.memory.aiUint8Array, offset, value
    return

  @writeMI = (offset, value, pc, isFromDelaySlot) ->
    switch offset
      when consts.MI_INIT_MODE_REG
        @writeMIModeReg value
      when consts.MI_INTR_MASK_REG
        @writeMIIntrMaskReg value, pc, isFromDelaySlot
      when consts.MI_VERSION_REG, consts.MI_INTR_REG

      #do nothing. read-only
      else
        core.memory.setInt32 core.memory.miUint8Array, offset, value
        #log "unhandled mips interface for mi offset: " + offset
    return

  @readSPReg1 = (offset) ->
    switch offset
      when consts.SP_STATUS_REG
        return core.memory.getInt32 core.memory.spReg1Uint8Array, offset
      when consts.SP_SEMAPHORE_REG
        temp = core.memory.getInt32(core.memory.aiUint8Array, offset)
        core.memory.setInt32 core.memory.spReg1Uint8Array, offset, 1
        return temp
      else
        #log "unhandled read sp reg1 " + offset
        return core.memory.getInt32 core.memory.spReg1Uint8Array, offset
    return

  @writeSPReg1 = (offset, value, pc, isFromDelaySlot) ->
    switch offset
      when consts.SP_STATUS_REG
        @writeSPStatusReg value, pc, isFromDelaySlot
      when consts.SP_SEMAPHORE_REG
        core.memory.setInt32 core.memory.spReg1Uint8Array, offset, 0
      when consts.SP_WR_LEN_REG
        core.memory.setInt32 core.memory.spReg1Uint8Array, offset, value
        core.dma.copySpToDram pc, isFromDelaySlot
      when consts.SP_RD_LEN_REG
        core.memory.setInt32 core.memory.spReg1Uint8Array, offset, value
        core.dma.copyDramToSp pc, isFromDelaySlot
      else
        core.memory.setInt32 core.memory.spReg1Uint8Array, offset, value
        #log "unhandled sp reg1 write: " + offset
    return

  @writeSPReg2 = (offset, value, pc, isFromDelaySlot) ->
    switch offset
      when consts.SP_PC_REG
        #log "writing sp pc: " + value
        core.memory.setInt32 core.memory.spReg2Uint8Array, offset, value & 0x00000FFC
      else
        core.memory.setInt32 core.memory.spReg2Uint8Array, offset, value
        #log "unhandled sp reg2 write: " + offset
    return

  #Set flag for memory register
  @setFlag = (where, offset, flag) ->
    value = core.memory.getUint32(where, offset)
    value |= flag
    core.memory.setInt32 where, offset, value
    return

  #Clear flag for memory register
  @clrFlag = (where, offset, flag) ->
    value = core.memory.getUint32(where, offset)
    value &= ~flag
    core.memory.setInt32 where, offset, value
    return

  @writeMIModeReg = (value) ->
    if value & consts.MI_SET_RDRAM
      @setFlag core.memory.miUint8Array, consts.MI_INIT_MODE_REG, consts.MI_MODE_RDRAM
    else @clrFlag core.memory.miUint8Array, consts.MI_INIT_MODE_REG, consts.MI_MODE_RDRAM  if value & consts.MI_CLR_RDRAM
    if value & consts.MI_SET_INIT
      @setFlag core.memory.miUint8Array, consts.MI_INIT_MODE_REG, consts.MI_MODE_INIT
    else @clrFlag core.memory.miUint8Array, consts.MI_INIT_MODE_REG, consts.MI_MODE_INIT  if value & consts.MI_CLR_INIT
    if value & consts.MI_SET_EBUS
      @setFlag core.memory.miUint8Array, consts.MI_INIT_MODE_REG, consts.MI_MODE_EBUS
    else @clrFlag core.memory.miUint8Array, consts.MI_INIT_MODE_REG, consts.MI_MODE_EBUS  if value & consts.MI_CLR_EBUS

    #this.clrFlag(miUint8Array, consts.MI_INTR_REG, consts.MI_INTR_DP);
    #setInt32(miUint8Array, MI_INIT_MODE_REG, core.memory.getUint32(miUint8Array, MI_INIT_MODE_REG)|(value&0x7f));
    @clearMIInterrupt consts.MI_INTR_DP  if value & consts.MI_CLR_DP_INTR
    return

  @writeMIIntrMaskReg = (value, pc, isFromDelaySlot) ->
    if value & consts.MI_INTR_MASK_SP_SET
      @setFlag core.memory.miUint8Array, consts.MI_INTR_MASK_REG, consts.MI_INTR_SP
    else @clrFlag core.memory.miUint8Array, consts.MI_INTR_MASK_REG, consts.MI_INTR_SP  if value & consts.MI_INTR_MASK_SP_CLR
    if value & consts.MI_INTR_MASK_SI_SET
      @setFlag core.memory.miUint8Array, consts.MI_INTR_MASK_REG, consts.MI_INTR_SI
    else @clrFlag core.memory.miUint8Array, consts.MI_INTR_MASK_REG, consts.MI_INTR_SI  if value & consts.MI_INTR_MASK_SI_CLR
    if value & consts.MI_INTR_MASK_AI_SET
      @setFlag core.memory.miUint8Array, consts.MI_INTR_MASK_REG, consts.MI_INTR_AI
    else @clrFlag core.memory.miUint8Array, consts.MI_INTR_MASK_REG, consts.MI_INTR_AI  if value & consts.MI_INTR_MASK_AI_CLR
    if value & consts.MI_INTR_MASK_VI_SET
      @setFlag core.memory.miUint8Array, consts.MI_INTR_MASK_REG, consts.MI_INTR_VI
    else @clrFlag core.memory.miUint8Array, consts.MI_INTR_MASK_REG, consts.MI_INTR_VI  if value & consts.MI_INTR_MASK_VI_CLR
    if value & consts.MI_INTR_MASK_PI_SET
      @setFlag core.memory.miUint8Array, consts.MI_INTR_MASK_REG, consts.MI_INTR_PI
    else @clrFlag core.memory.miUint8Array, consts.MI_INTR_MASK_REG, consts.MI_INTR_PI  if value & consts.MI_INTR_MASK_PI_CLR
    if value & consts.MI_INTR_MASK_DP_SET
      @setFlag core.memory.miUint8Array, consts.MI_INTR_MASK_REG, consts.MI_INTR_DP
    else @clrFlag core.memory.miUint8Array, consts.MI_INTR_MASK_REG, consts.MI_INTR_DP  if value & consts.MI_INTR_MASK_DP_CLR

    #Check MI interrupt again. This is important, otherwise we will lose interrupts.

    #Trigger an MI interrupt since we don't know what it is.
    @setException consts.EXC_INT, consts.CAUSE_IP3, pc, isFromDelaySlot  if (core.memory.getUint32(core.memory.miUint8Array, consts.MI_INTR_MASK_REG) & 0x0000003F & core.memory.getUint32(core.memory.miUint8Array, consts.MI_INTR_REG)) isnt 0
    return

  @writeSIStatusReg = (value, pc, isFromDelaySlot) ->
    #Clear SI interrupt unconditionally
    @clearMIInterrupt(consts.MI_INTR_SI); #wrong!
    @clrFlag core.memory.siUint8Array, consts.SI_STATUS_REG, consts.SI_STATUS_INTERRUPT
    return

  @writeSPStatusReg = (value, pc, isFromDelaySlot) ->
    tempSr = core.memory.getUint32(core.memory.spReg1Uint8Array, consts.SP_STATUS_REG)
    tempSr &= ~consts.SP_STATUS_BROKE if value & SP_CLR_BROKE
    if value & SP_SET_INTR
      @triggerSPInterrupt pc, isFromDelaySlot
    #to use else if here is a possible bux fix (what is this?..this looks weird).
    # No. this else causes freezing.
   # else @clearMIInterrupt consts.MI_INTR_SP if value & SP_CLR_INTR
    if value & SP_SET_SSTEP
      tempSr |= SP_STATUS_SSTEP
    else tempSr &= ~SP_STATUS_SSTEP if value & SP_CLR_SSTEP
    if value & SP_SET_INTR_BREAK
      tempSr |= SP_STATUS_INTR_BREAK
    else tempSr &= ~SP_STATUS_INTR_BREAK  if value & SP_CLR_INTR_BREAK
    if value & SP_SET_YIELD
      tempSr |= SP_STATUS_YIELD
    else tempSr &= ~SP_STATUS_YIELD  if value & SP_CLR_YIELD
    if value & SP_SET_YIELDED
      tempSr |= SP_STATUS_YIELDED
    else tempSr &= ~SP_STATUS_YIELDED  if value & SP_CLR_YIELDED
    if value & SP_SET_TASKDONE
      tempSr |= SP_STATUS_TASKDONE
    else tempSr &= ~SP_STATUS_YIELDED  if value & SP_CLR_YIELDED
    if value & SP_SET_SIG3
      tempSr |= SP_STATUS_SIG3
    else tempSr &= ~SP_STATUS_SIG3  if value & SP_CLR_SIG3
    if value & SP_SET_SIG4
      tempSr |= SP_STATUS_SIG4
    else tempSr &= ~SP_STATUS_SIG4  if value & SP_CLR_SIG4
    if value & SP_SET_SIG5
      tempSr |= SP_STATUS_SIG5
    else tempSr &= ~SP_STATUS_SIG5  if value & SP_CLR_SIG5
    if value & SP_SET_SIG6
      tempSr |= SP_STATUS_SIG6
    else tempSr &= ~SP_STATUS_SIG6  if value & SP_CLR_SIG6
    if value & SP_SET_SIG7
      tempSr |= SP_STATUS_SIG7
    else tempSr &= ~SP_STATUS_SIG7  if value & SP_CLR_SIG7
    if value & SP_SET_HALT
      tempSr |= SP_STATUS_HALT
      core.memory.setInt32 core.memory.spReg1Uint8Array, consts.SP_STATUS_REG, tempSr
    else if value & SP_CLR_HALT
      if (tempSr & SP_STATUS_BROKE) is 0 #bugfix.
        tempSr &= ~SP_STATUS_HALT
        core.memory.setInt32 core.memory.spReg1Uint8Array, consts.SP_STATUS_REG, tempSr
        spDmemTask = core.memory.getUint32(core.memory.spMemUint8Array, consts.SP_DMEM_TASK)
        #log "SP Task triggered. SP_DMEM_TASK=" + spDmemTask
        @runSPTask spDmemTask
      else
        core.memory.setInt32 core.memory.spReg1Uint8Array, consts.SP_STATUS_REG, tempSr
    return

  #Added by Rice, 2001.08.10
  #SP_STATUS_REG |= SP_STATUS_HALT;  //why?
  # this.setFlag(spReg1Uint8Array, consts.SP_STATUS_REG, consts.SP_STATUS_HALT); //why?
  @writeDPCStatusReg = (value, pc, isFromDelaySlot) ->
    @clrFlag core.memory.dpcUint8Array, consts.DPC_STATUS_REG, consts.DPC_STATUS_XBUS_DMEM_DMA  if value & consts.DPC_CLR_XBUS_DMEM_DMA
    @setFlag core.memory.dpcUint8Array, consts.DPC_STATUS_REG, consts.DPC_STATUS_XBUS_DMEM_DMA  if value & consts.DPC_SET_XBUS_DMEM_DMA
    @clrFlag core.memory.dpcUint8Array, consts.DPC_STATUS_REG, consts.DPC_STATUS_FREEZE  if value & consts.DPC_CLR_FREEZE
    @setFlag core.memory.dpcUint8Array, consts.DPC_STATUS_REG, consts.DPC_STATUS_FREEZE  if value & consts.DPC_SET_FREEZE
    @clrFlag core.memory.dpcUint8Array, consts.DPC_STATUS_REG, consts.DPC_STATUS_FLUSH  if value & consts.DPC_CLR_FLUSH
    @setFlag core.memory.dpcUint8Array, consts.DPC_STATUS_REG, consts.DPC_STATUS_FLUSH  if value & consts.DPC_SET_FLUSH
    return

  #
  #if(value & DPC_CLR_TMEM_REG) (DPC_TMEM_REG) = 0;
  #if(value & DPC_CLR_PIPEBUSY_REG) (DPC_PIPEBUSY_REG) = 0;
  #if(value & DPC_CLR_BUFBUSY_REG) (DPC_BUFBUSY_REG) = 0;
  #if(value & DPC_CLR_CLOCK_REG) (DPC_CLOCK_REG) = 0;
  #
  @writeDPC = (offset, value, pc, isFromDelaySlot) ->
    switch offset
      when consts.DPC_STATUS_REG
        @writeDPCStatusReg value, pc, isFromDelaySlot
      when consts.DPC_START_REG
        core.memory.setInt32 core.memory.dpcUint8Array, offset, value
      when consts.DPC_END_REG
        core.memory.setInt32 core.memory.dpcUint8Array, offset, value
        @processRDPList()
      when consts.DPC_CLOCK_REG, consts.DPC_BUFBUSY_REG, consts.DPC_PIPEBUSY_REG, consts.DPC_TMEM_REG
        break
      else
        core.memory.setInt32 core.memory.dpcUint8Array, offset, value
        #log "unhandled dpc write: " + offset
    return

  @writePIStatusReg = (value, pc, isFromDelaySlot) ->
    @clearMIInterrupt consts.MI_INTR_PI  if value & consts.PI_STATUS_CLR_INTR
    if value & consts.PI_STATUS_RESET
      #When PIC is reset, if PIC happens to be busy, an interrupt will be generated
      #as PIC returns to idle. Otherwise, no interrupt will be generated and PIC
      #remains idle.
      if core.memory.getUint32(core.memory.piUint8Array, consts.PI_STATUS_REG) & (consts.PI_STATUS_IO_BUSY | consts.PI_STATUS_DMA_BUSY) #Is PI busy?
        #Reset the PIC
        core.memory.setInt32 core.memory.piUint8Array, consts.PI_STATUS_REG, 0

        #Reset finished, set PI Interrupt
        @triggerPIInterrupt pc, isFromDelaySlot
      else
        #Reset the PIC
        core.memory.setInt32 core.memory.piUint8Array, consts.PI_STATUS_REG, 0
    return

  #Does not actually write into the PI_STATUS_REG
  @runSPTask = (spDmemTask) ->
    #  throw 'todo: run hle task';
    switch spDmemTask
      when consts.BAD_TASK
        #log "bad sp task"
        break
      when consts.GFX_TASK
        core.videoHLE = new C1964jsVideoHLE(core, core.webGL.gl)  if core.videoHLE is null or core.videoHLE is `undefined`
        wireframe = document.getElementById("wireframe")
        core.settings.wireframe = false
        core.settings.wireframe = true if wireframe isnt null and wireframe.checked
        repeatDList = document.getElementById("repeatDList")
        core.settings.repeatDList = false
        core.settings.repeatDList = true if repeatDList isnt null and repeatDList.checked
        if core.terminate is false
          core.videoHLE.processDisplayList()
          if core.settings.repeatDList is true
            core.stopEmulatorAndCleanup()
            @interval = setInterval(=>
              core.videoHLE.processDisplayList()
              @triggerRspBreak 0, false
              return
            , 1000)
          else
            @triggerRspBreak 0, false
      when consts.SND_TASK
        @processAudioList()
        @triggerRspBreak 0, false
      when consts.JPG_TASK
        @processJpegTask()
        @triggerRspBreak 0, false
      else
        #log "unhandled sp task: " + spDmemTask
        break
    @checkInterrupts()
    return

  @processAudioList = ->
    #log "todo: process Audio List"

    #just clear flags now to get the gfx tasks :)
    #see UpdateFifoFlag in 1964cpp's AudioLLE main.cpp.
    @clrFlag core.memory.aiUint8Array, consts.AI_STATUS_REG, consts.AI_STATUS_FIFO_FULL
    #@interrupts.triggerAIInterrupt 0, false
    #core.kfi = 512
    return

  @processJpegTask = ->
    #log "todo: processJpegTask"
    return

  @processRDPList = ->
    #log "todo: process rdp list"
    return

  @checkInterrupts = ->
    @triggerDPInterrupt 0, false  if (core.memory.getUint32(core.memory.miUint8Array, consts.MI_INTR_REG) & consts.MI_INTR_DP) isnt 0
    @triggerAIInterrupt 0, false  if (core.memory.getUint32(core.memory.miUint8Array, consts.MI_INTR_REG) & consts.MI_INTR_AI) isnt 0
    @triggerSIInterrupt 0, false  if (core.memory.getUint32(core.memory.miUint8Array, consts.MI_INTR_REG) & consts.MI_INTR_SI) isnt 0
    @triggerRspBreak 0, false  if (core.memory.getUint32(core.memory.miUint8Array, consts.MI_INTR_REG) & consts.MI_INTR_SP) isnt 0
    #if ((core.memory.getUint32(miUint8Array, consts.MI_INTR_REG) & consts.MI_INTR_VI) !== 0)
    #    this.triggerVIInterrupt(0, false);
    @setException consts.EXC_INT, 0, core.p, false  if (cp0[consts.CAUSE] & cp0[consts.STATUS] & 0x0000FF00) isnt 0

    #do not process interrupts here as we don't have support for
    #interrupts in delay slots. process them in the main runLoop.
    return
  return this

#hack global space until we export classes properly
#node.js uses exports; browser uses this (window)
root = exports ? self
root.C1964jsInterrupts = C1964jsInterrupts
