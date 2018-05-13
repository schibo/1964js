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
#
# Project started March 4, 2012
# For fastest results, use Chrome.
#
# NOTES:
# fixed bgtz bgtzl
# improved ldc1,sdc1 ..could still be bugged.
#
# possible BUGS in original 1964cpp?:
# - JAL & JALR instr_index: upper 4 bits are from the pc's delay slot, not the current pc!
# write to si_status reg was clearing MI_INTR_SI unconditionally! this was
# causing sinus, plasma, hardcoded, mandelbrot zoomer, lightforce, and other demos to not work in 1964js.
# - mtc0 index should be cp0[index] & 0x80000000 | r[n] & 0x3f?
# - aValue is not applicable in jalr (dynabranch.h)
# - shift amounts of 0 truncate 64bit registers to 32bit. This is a possible bug in the original 1964cpp.
# 1964 Masked loads and store addresses to make them aligned in load/store opcodes.
# Check_SW, setting DPC_END_REG equal to DPC_START_REG is risky initialization:
# setInt32(spReg1Uint8Array, SP_STATUS_REG, SP_STATUS_HALT);
# 1964cpp's init sets SP_STATUS_REG to SP_STATUS_HALT but then clears it in RCP_Reset() !
# call to tlbwi masked index with &31 .. (seems wrong)
#
# Use a typed-array but access it a byte at a time for endian-safety.
# Do not use the DataView .getInt16, getInt32, etc functions. These will ensure endian
# safety but they are a lot slower than accessing an Int8Array() by its index with the [] notation.
#
#TODO:
# Long-term: more opcodes/timers/WinGL
# Short-term:
#  - sdr, sdl, etc..
# AI_LEN_REG so SP Goldeneye Crap demo can work.
# dmult, and ddiv don't handle negative correctly. BigInt.js
# - Where are dadd and dmult?
#
# - Should handle exceptions in delay slots by catching thrown exceptions.
#
#Convention:
# When loading/storing registers back into n64 memory,
# do so byte-by-byte since typed-arrays aren't endian-safe.
# It's easier to get your head around and it's plenty fast.
# The hope is that the compiler will optimimize the pattern
# with a swap or bswap.
#
# Take care when using @helpers.RS(i) + "+" + @helpers.soffset_imm(i). I used to explicitly wrap it in ()>>0 to convert to int, but
# everywhere it is currently used implicitly uses it as a 32bit int. In a few cases, if it is assigned to a float, it could be larger than 32bits.
#
###jslint bitwise: true, evil: true, undef: false, todo: true, browser: true, devel: true###
###globals Int32Array, ArrayBuffer, Float32Array, C1964jsMemory, C1964jsInterrupts, C1964jsConstants, C1964jsPif, C1964jsDMA, Float64Array, C1964jsWebGL, cancelAnimFrame, C1964jsHelpers, dec2hex, Uint8Array, Uint16Array, requestAnimFrame###

"use strict"
consts = new C1964jsConstants()
offset = undefined

class C1964jsEmulator
  callBind: (fn, me) ->
    ->
      fn.call me

  constructor: (userSettings, buffer) ->
    #@runLoop = @callBind @runLoop, this
    i = undefined
    @settings = userSettings
    @request = `undefined`
    @debug = false
    @cp0 = new Int32Array(32)
    @cp1Buffer = new ArrayBuffer(32 * 4) # *4 because ArrayBuffers are in bytes
    @cp1_i = new Int32Array(@cp1Buffer)
    @cp1_f = new Float32Array(@cp1Buffer)
    @cp1_f64 = new Float64Array(@cp1Buffer)
    @cp1Con = new Int32Array(32)
    @LLbit = 0

    #var docElement, errorElement, g, s, interval, stopCompiling, offset, programCounter, romLength, redrawDebug=0;
    @terminate = false
    @NUM_CHANNELS = 1
    @NUM_SAMPLES = 40000
    @SAMPLE_RATE = 40000
    @isLittleEndian = 0
    @isBigEndian = 0
    @interval = 0
    @m = new Int32Array(1)
    @m[0] = -625000 #which is magic_number / (interval+1)

    @forceRepaint = false #presumably origin reg doesn't change because not double or triple-buffered (single-buffered)
    #main run loop
    @doOnce = 0
    @kk = 0
    @TV_SYSTEM_NTSC = 1
    @TV_SYSTEM_PAL = 0
    @currentHack = 0
    @kfi = 3200000
    @cnt = 0
    # temps start at r[35]
    @gpr = new ArrayBuffer(35*4 + 4*5) # 32GPRs, 1 dummy location to catch attempts to write to r0, and 1 lo and 1 hi, 4 temporary vars.
    @r = new Int32Array(@gpr)
    @r[0] = 0
    @r[1] = 0
    @r[2] = 0xd1731be9
    @r[3] = 0xd1731be9
    @r[4] = 0x001be9
    @r[5] = 0xf45231e5
    @r[6] = 0xa4001f0c
    @r[7] = 0xa4001f08
    @r[8] = 0x070
    @r[9] = 0
    @r[10] = 0x040
    @r[11] = 0xA4000040
    @r[12] = 0xd1330bc3
    @r[13] = 0xd1330bc3
    @r[14] = 0x25613a26
    @r[15] = 0x2ea04317
    @r[16] = 0 
    @r[17] = 0 
    @r[18] = 0 
    @r[19] = 0 
    @r[20] = 0 
    @r[21] = 0 
    @r[22] = 0 
    @r[23] = 0x06
    @r[24] = 0
    @r[25] = 0xd73f2993
    @r[26] = 0
    @r[27] = 0
    @r[28] = 0
    @r[29] = 0xa4001ff0
    @r[30] = 0
    @r[31] = 0xa4001554
    @r[32] = 0
    @r[33] = 0
    @r[34] = 0
    @gprh = new ArrayBuffer(35*4)
    @h = new Int32Array(@gprh)
    @fnLut = [];#new Map()
    @fn = undefined

    #hook-up system objects
    @memory = new C1964jsMemory(this)
    @interrupts = new C1964jsInterrupts(this, @cp0)
    @pif = new C1964jsPif(@memory.pifUint8Array)
    @dma = new C1964jsDMA(@memory, @interrupts, @pif)
    @webGL = new C1964jsWebGL(this, userSettings.wireframe)
    @log = (message) ->
      console.log message
    @endianTest()
    @helpers = new C1964jsHelpers(this, @isLittleEndian)
    @initTLB()

    #todo: verity that r[8] is 0x070
    cancelAnimFrame @request
    @currentHack = 0
    @dma.startTime = 0
    @kfi = 512
    @doOnce = 0
    @interval = 0
    @m[0] = -125000 #which is magic_number / (interval+1)
    @flushDynaCache()
    @showFB = true
    @webGL.hide3D()
    #canvas
    @ctx = document.getElementById("Canvas").getContext("2d")

    ###*
     * @const
    ###    
    @ImDat = @ctx.createImageData(320, 240)
    @stopCompiling = false
    @docElement = document.getElementById("screen")
    @errorElement = document.getElementById("error")
    @p = new Int32Array(1)
    #set ram size
    MEMORY_SIZE_NO_EXPANSION = 0x400000
    MEMORY_SIZE_WITH_EXPANSION = 0x800000
    @currentRdramSize = MEMORY_SIZE_WITH_EXPANSION
    @crc1 = 0
    @crc2 = 0
    @romName = new Uint8Array 20

    #runTest();

  # function init()
  #   r[32] = LO for mult
  #   r[33] = HI for mult
  #   r[34] = write-only. to protect r0, write here.
    @memory.rom = buffer

    #rom = new Uint8Array(buffer);
    @memory.romUint8Array = buffer

    #fill alpha
    i = 3
    y = 0
    while y < 240
      x = 0
      while x < 320
        @ImDat.data[i] = 255
        i += 4
        x += 1
      y += 1
    @byteSwap @memory.rom

    #copy first 4096 bytes to sp_dmem and run from there.
    k = 0
    while k < 0x1000
      @memory.spMemUint8Array[k] = @memory.rom[k]
      k += 1
    @r[20] = @getTVSystem(@memory.romUint8Array[0x3D])
    bootCode = @getBootCode()
    @r[22] = bootCode.cic
    @cp0[consts.STATUS] = 0x70400004
    @cp0[consts.RANDOM] = 0x0000001f
    @cp0[consts.CONFIG] = 0x0006e463
    @cp0[consts.PREVID] = 0x00000b00
    @cp1Con[0] = 0x00000511

    @p[0] = 0xA4000040 #set programCounter to start of SP_MEM and after the 64 byte ROM header.
    @memory.setInt32 @memory.miUint8Array, consts.MI_VERSION_REG, 0x01010101
    @memory.setInt32 @memory.riUint8Array, consts.RI_CONFIG_REG, 0x00000001
    @memory.setInt32 @memory.viUint8Array, consts.VI_INTR_REG, 0x000003FF
    @memory.setInt32 @memory.viUint8Array, consts.VI_V_SYNC_REG, 0x000000D1
    @memory.setInt32 @memory.viUint8Array, consts.VI_H_SYNC_REG, 0x000D2047
    
    # rom header
    #copy rom name
    for i in [0...20]
      @romName[i] = @memory.rom[32+i]
    #copy crc1
    @crc1 = (@memory.rom[16] << 24 | @memory.rom[17] << 16 | @memory.rom[18] << 8 | @memory.rom[19]) >>> 0
    #copy crc2
    @crc2 = (@memory.rom[20] << 24 | @memory.rom[21] << 16 | @memory.rom[22] << 8 | @memory.rom[23]) >>> 0

    @pif.eepromName = @pif.binArrayToJson(@romName) + "-" + dec2hex(@crc1) + dec2hex(@crc2) + ".eep"
    
    @memory.setInt32 @memory.u8, bootCode.rdramSizeAddress, @currentRdramSize 

    #this.memory.setInt32(this.memory.spReg1Uint8Array, SP_STATUS_REG, SP_STATUS_HALT);
    #1964cpp sets this then clears it in RCP_Reset() !

    #set hi vals
    i = 0
    while i < 35
      @h[i] = @r[i] >> 31
      i += 1
    return

  #swap to 0x80371240
  byteSwap: (rom) ->
    k = undefined
    fmt = undefined
    temp = undefined
    console.log "byte swapping..."
    fmt = @memory.getUint32(rom, 0)
    switch fmt >>> 0
      when 0x37804012
        alert "help: support odd byte lengths for this swap"  if (rom.byteLength % 2) isnt 0
        k = 0
        while k < rom.byteLength
          temp = rom[k]
          rom[k] = rom[k + 1]
          rom[k + 1] = temp
          k += 2
      when 0x80371240
      else
        @log "Unhandled byte order: 0x" + dec2hex(fmt)
    console.log "swap done"
    return

  endianTest: ->
    ii = new ArrayBuffer(2)
    iiSetView = new Uint8Array(ii)
    iiView = new Uint16Array(ii)
    iiSetView[0] = 0xff
    iiSetView[1] = 0x11
    if iiView[0] is 0x11FF
      @log "You are on a little-endian system"
      @isLittleEndian = 1
      @isBigEndian = 0
    else
      @log "You are on a big-endian system"
      @isLittleEndian = 0
      @isBigEndian = 1
    return

  repaint: (ctx, ImDat) ->
    out = undefined
    i = 0
    y = undefined
    return  unless @showFB
    #get origin
    k = @memory.getInt32(@memory.viUint8Array, consts.VI_ORIGIN_REG) & 0x00FFFFFF
    out = ImDat.data

    #endian-safe blit: rgba5551
    y = -240 * 320
    `const u8 = this.memory.u8`
    while y isnt 0
      out[i] = (u8[k] & 0xF8)
      out[i + 1] = (((u8[k] << 5) | (u8[k + 1] >>> 3)) & 0xF8)
      out[i + 2] = (u8[k + 1] << 2 & 0xF8)
      out[i + 4] = (u8[k + 2] & 0xF8)
      out[i + 5] = (((u8[k + 2] << 5) | (u8[k + 3] >>> 3)) & 0xF8)
      out[i + 6] = (u8[k + 3] << 2 & 0xF8)
      k += 4
      i += 8
      y += 2
    ctx.putImageData ImDat, 0, 0
    return

  initTLB: ->
    @tlb = new Array(32)
    i = 0
    while i < 32
      @tlb[i] = {
        valid : false,
        entryHi : new Int32Array(1),
        entryLo1 : new Int32Array(1),
        entryLo0 : new Int32Array(1),
        pageMask : new Int32Array(1),
        loCompare : new Int32Array(1),
        myHiMask : new Int32Array(1)
      }
      i += 1

    iTLBIndex = [0, 0]
    dTLBIndex = [0, 0, 0]
    lastITLBIndex = 0
    lastDTLBIndex = 0

    @memory.initts()
    return

  runLoop: () =>
    #setTimeout to be a good citizen..don't allow for the cpu to be pegged at 100%.
    #8ms idle time will be 50% cpu max if a 60FPS game is slow.
    if @startTime is undefined
      @startTime = Date.now();
    #@request = requestAnimFrame(@runLoop)  if @terminate is false
    if @terminate is true
      clearInterval @mySetInterval
      return

    `const m = this.m`
    `const r = this.r`
    `const h = this.h`
    `const p = this.p`

    fn = @fn

    while @terminate is false
      #@interrupts.checkInterrupts()
      if m[0] >= 0
        @interval += 1
        #@m[0] = -125000 # which is -625000 / (interval+1)
        m[0] = -156250 # which is -625000 / (interval+1) / 2
        pc = p[0]
        @interrupts.processException p[0]
        if @interval is 4
          @interval = 0
          @repaintWrapper()
          #@cp0[consts.COUNT] += 625000*2 #todo: set count to count + @m*2 when count is requested in code
          @cp0[consts.COUNT] += 625000*2 #todo: set count to count + @m*2 when count is requested in code
          @interrupts.triggerCompareInterrupt 0, false
          @interrupts.triggerVIInterrupt 0, false #if ((@memory.getUint32(@memory.miUint8Array, consts.MI_INTR_REG) & consts.MI_INTR_VI) isnt 0)
        else if @interval is 2
          @interrupts.checkInterrupts()
          if pc isnt p[0]
            pc = p[0] >>> 2
            fn = @fnLut[pc]
          break
        if pc isnt p[0]
          pc = p[0] >>> 2
          fn = @fnLut[pc]
      else
      #  @interrupts.processException @p[0]

        #this is broken-up so that we can process more interrupts. If we freeze,
        #we probably need to split this up more.
        try
          fn = @run fn, r, h
        catch e
          #so, we really need to know what type of exception this is,
          #but right now, we're assuming that we need to compile a block due to
          #an attempt to call an undefined function. Are there standard exception types
          #in javascript?
          if e instanceof TypeError
            fn = @decompileBlock(p[0])
            #fn = fn(r, h, @memory, this)
          else
            throw e
    @fn = fn
    this

  run: (fn, r, h) ->
    `const m = this.m`
    `const mem = this.memory`
    `const t = this`
    while m[0] < 0
      fn = fn(r, h, mem, t)
    return fn

  repaintWrapper: ->
    @repaint @ctx, @ImDat
    return

  asyncFastLoop: () ->    
    @myFastInterval = setInterval(=>
      @runLoop()
      return
    , 0.0)
    return

  startEmulator: () ->
    self.requestAnimationFrame = self.requestAnimationFrame or
    self.mozRequestAnimationFrame or
    self.webkitRequestAnimationFrame or
    self.msRequestAnimationFrame or f(=>
      return setTimeout f, 0.0)

    @terminate = false
    @log "startEmulator"
    @settings.rateWithDelta = 1000.0/60.0
    
    MainLoop.setUpdate().setDraw(i1964js.runLoop).setEnd().start();
    return

  #make way for another 1964 instance. cleanup old scripts written to the page.
  stopEmulatorAndCleanup: =>
    MainLoop.stop()
    @stopCompiling = true
    @terminate = true
    clearInterval @myFastInterval 
    @log "stopEmulatorAndCleanup"
    @flushDynaCache()
    return

  onSpeedLimitChanged: ->
    speedlimit =  document.getElementById("speedlimit")
    clearInterval @myFastInterval 
    if speedlimit is null or speedlimit.checked is false
      MainLoop.stop()
      @asyncFastLoop()
    else
      @startEmulator()
    return

  #clearInterval(interval);
  getFnName: (pc) ->
    "_" + (pc >>> 2)

  decompileBlock: (pc) ->
    offset = 0
    g = undefined
    s = undefined
    @cnt = 0
    instruction = undefined
    string = undefined
    fnName = "_" + (pc >>> 2)

    #Syntax: function(register, hiRegister, this.memory, this)
    string = "var " + fnName + "=(r,h,m,t)=>{"
    until @stopCompiling
      instruction = @memory.lw(pc + offset)
      @cnt += 1
      string += this[@CPU_instruction[instruction >> 26 & 0x3f]](instruction)
      offset += 4
      throw Error "too many instructions! bailing."  if offset > 10000
    @stopCompiling = false

    #close out the function
    string += "t.m[0]+=" + @cnt
    string += ";t.p[0]=" + ((pc + offset)|0)
    string += ";return self." + @getFnName((pc + offset)|0) + "}"
    g = document.createElement("script")
    s = document.getElementsByTagName("script")[@kk]
    @kk += 1
    s.parentNode.insertBefore g, s
    g.text = string
    @fnLut[pc>>>2] = self[fnName]

  r4300i_add: (i) ->
    @helpers.sLogic i, "+"

  r4300i_addu: (i) ->
    @helpers.sLogic i, "+"

  r4300i_sub: (i) ->
    @helpers.sLogic i, "-"

  r4300i_subu: (i) ->
    @helpers.sLogic i, "-"

  r4300i_or: (i) ->
    @helpers.dLogic i, "|"

  r4300i_xor: (i) ->
    @helpers.dLogic i, "^"

  r4300i_nor: (i) ->
    @helpers.tRD(i) + "=~(" + @helpers.RS(i) + "|" + @helpers.RT(i) + ");" + @helpers.tRDH(i) + "=~(" + @helpers.RSH(i) + "|" + @helpers.RTH(i) + ");"

  r4300i_and: (i) ->
    @helpers.dLogic i, "&"

  r4300i_lui: (i) ->
    temp = ((i & 0x0000ffff) << 16)
    tempHi = temp >> 31
    @helpers.tRT(i) + "=" + temp + ";" + @helpers.tRTH(i) + "=" + tempHi + ";" 

  r4300i_lw: (i) ->
    @helpers.virtualToPhysical(@helpers.RS(i) + "+" + @helpers.soffset_imm(i)) + @helpers.tRT(i) + "=m.LW[r[36]>>>16](m,r[36]);" + @helpers.tRTH(i) + "=" + @helpers.RT(i) + ">>31;"

  r4300i_lwu: (i) ->
    @helpers.virtualToPhysical(@helpers.RS(i) + "+" + @helpers.soffset_imm(i)) + @helpers.tRT(i) + "=m.LW[r[36]>>>16](m,r[36]);" + @helpers.tRTH(i) + "=0;"

  r4300i_sw: (i, isDelaySlot) ->
    a = undefined
#    string = "m.sw(" + @helpers.RT(i) + ";" + @helpers.RS(i) + "+" + @helpers.soffset_imm(i)
    string = @helpers.virtualToPhysical("" + @helpers.RS(i) + "+" + @helpers.soffset_imm(i) + "") + "m.SW[r[36]>>>16](m," + @helpers.RT(i) + ",r[36]"

    #So we can process exceptions
    if isDelaySlot is true
      a = (@p[0] + offset + 4) | 0
      string += "," + a + ",true);"
    else
      a = (@p[0] + offset) | 0
      string += "," + a + ");"
    string

  delaySlot: (i, likely) ->
    pc = undefined
    instruction = undefined
    opcode = undefined
    string = undefined
    pc = (@p[0] + offset + 4 + (@helpers.soffset_imm(i) << 2)) | 0
    instruction = @memory.lw((@p[0] + offset + 4) | 0)
    opcode = this[@CPU_instruction[instruction >> 26 & 0x3f]](instruction, true)
    #speed hack
    if instruction is 0 and @helpers.soffset_imm(i) is -1
      string = opcode + "t.m[0]=0;t.p[0]=" + pc + ";return self." + @getFnName(pc) + "}"
    else
      c=@cnt+1
      string = opcode + "t.m[0]+="+c+";t.p[0]=" + pc + ";return self." + @getFnName(pc) + "}"
    

    #if likely and if branch not taken, skip delay slot
    if likely is false
      string += opcode + "t.m[0]++;"
    offset += 4
    string

  r4300i_bne: (i) ->
    @stopCompiling = true
    "if(" + @helpers.RS(i) + "-" + @helpers.RT(i) + "|" + @helpers.RSH(i) + "-" + @helpers.RTH(i) + "){" + @delaySlot(i, false)

  r4300i_bnel: (i) ->
    @stopCompiling = true
    "if(" + @helpers.RS(i) + "-" + @helpers.RT(i) + "|" + @helpers.RSH(i) + "-" + @helpers.RTH(i) + "){" + @delaySlot(i, true)

  r4300i_beq: (i) ->
    @stopCompiling = true
    if @helpers.rs(i) is @helpers.rt(i)
      "{" + @delaySlot(i, false)
    else
      "if(" + @helpers.RS(i) + "===" + @helpers.RT(i) + "&" + @helpers.RSH(i) + "===" + @helpers.RTH(i) + "){" + @delaySlot(i, false)

  r4300i_beql: (i) ->
    @stopCompiling = true
    if @helpers.rs(i) is @helpers.rt(i)
      "{" + @delaySlot(i, true)
    else
      "if(" + @helpers.RS(i) + "===" + @helpers.RT(i) + "&" + @helpers.RSH(i) + "===" + @helpers.RTH(i) + "){" + @delaySlot(i, true)

  r4300i_blez: (i) ->
    @stopCompiling = true
    "if(" + @helpers.RSH(i) + "<0|!(" + @helpers.RSH(i) + "|" + @helpers.RS(i) + ")){" + @delaySlot(i, false)

  r4300i_blezl: (i) ->
    @stopCompiling = true
    "if(" + @helpers.RSH(i) + "<0|!(" + @helpers.RSH(i) + "|" + @helpers.RS(i) + ")){" + @delaySlot(i, true)

  r4300i_bgez: (i) ->
    @stopCompiling = true
    "if(" + @helpers.RSH(i) + ">=0){" + @delaySlot(i, false)

  r4300i_bgezl: (i) ->
    @stopCompiling = true
    "if(" + @helpers.RSH(i) + ">=0){" + @delaySlot(i, true)

  r4300i_bgtz: (i) ->
    @stopCompiling = true
    "if(" + @helpers.RSH(i) + ">=0&(" + @helpers.RSH(i) + "|" + @helpers.RS(i) + ")!==0){" + @delaySlot(i, false)

  r4300i_bgtzl: (i) ->
    @stopCompiling = true
    "if(" + @helpers.RSH(i) + ">=0&(" + @helpers.RSH(i) + "|" + @helpers.RS(i) + ")!==0){" + @delaySlot(i, true)

  r4300i_bltzl: (i) ->
    @stopCompiling = true
    "if(" + @helpers.RSH(i) + "<0){" + @delaySlot(i, true)

  r4300i_bgezal: (i) ->
    @stopCompiling = true
    link = (@p[0] + offset + 8) >> 0
    "if(" + @helpers.RSH(i) + ">=0){r[31]=" + link + ";" + "h[31]=" + (link >> 31) + ";" + @delaySlot(i, false)

  r4300i_bgezall: (i) ->
    @stopCompiling = true
    link = (@p[0] + offset + 8) >> 0
    "if(" + @helpers.RSH(i) + ">=0){r[31]=" + link + ";" + "h[31]=" + (link >> 31) + ";" + @delaySlot(i, true)

  r4300i_bltz: (i) ->
    @stopCompiling = true
    "if(" + @helpers.RSH(i) + "<0){" + @delaySlot(i, false)

  r4300i_COP1_bc1f: (i) ->
    @stopCompiling = true
    "if(!(t.cp1Con[31]&0x800000)){" + @delaySlot(i, false)

  r4300i_COP1_bc1t: (i) ->
    @stopCompiling = true
    "if(t.cp1Con[31]&0x800000){" + @delaySlot(i, false)

  r4300i_COP1_bc1tl: (i) ->
    @stopCompiling = true
    "if(t.cp1Con[31]&0x800000){" + @delaySlot(i, true)

  r4300i_COP1_bc1fl: (i) ->
    @stopCompiling = true
    "if(!(t.cp1Con[31]&0x800000)){" + @delaySlot(i, true)

  r4300i_j: (i) ->
    @stopCompiling = true
    instruction = undefined
    instr_index = ((((@p[0] + offset + 4) & 0xF0000000) | ((i & 0x03FFFFFF) << 2)) | 0)

    #delay slot
    instruction = @memory.lw((@p[0] + offset + 4) | 0)

    #speed hack
    speedUp = false
    speedUp = true if ((instr_index >> 0) is (@p[0] + offset) >> 0) and (instruction is 0)

    string = this[@CPU_instruction[instruction >> 26 & 0x3f]](instruction, true)
    if speedUp is true
      string += "t.m[0]=0"
    else
      string += "t.m[0]+=" + (@cnt+1)

    string += ";t.p[0]=" + instr_index + ";return self." + @getFnName(instr_index) + ";"

  r4300i_jal: (i) ->
    @stopCompiling = true
    pc = undefined
    instruction = undefined
    instr_index = ((((@p[0] + offset + 4) & 0xF0000000) | ((i & 0x03FFFFFF) << 2)) | 0)

    #delay slot
    instruction = @memory.lw((@p[0] + offset + 4) | 0)
    string = this[@CPU_instruction[instruction >> 26 & 0x3f]](instruction, true)
    pc = (@p[0] + offset + 8) | 0
    string += "t.m[0]+=" + (@cnt+1) + ";t.p[0]=" + instr_index + ";r[31]=" + pc + ";h[31]=" + (pc >> 31) + ";return self." + @getFnName(instr_index) + ";"

  #should we set the programCounter after the delay slot or before it?
  r4300i_jalr: (i) ->
    @stopCompiling = true
    instruction = undefined
    opcode = undefined
    link = undefined
    # r[39] is a temp variable specific to vAddr for jalr
    string = "r[39]=" + @helpers.RS(i) + ";"
    link = (@p[0] + offset + 8) >> 0
    string += @helpers.tRD(i) + "=" + link + ";" + @helpers.tRDH(i) + "=" + (link >> 31) + ";"

    #delay slot
    instruction = @memory.lw((@p[0] + offset + 4) | 0)
    opcode = this[@CPU_instruction[instruction >> 26 & 0x3f]](instruction, true)
    string += opcode
    string += "t.m[0]+=" + (@cnt+1) + ";t.p[0]=r[39];return t.fnLut[r[39]>>>2];"
    string

  r4300i_jr: (i) ->
    @stopCompiling = true
    instruction = undefined
    opcode = undefined
    # r[37] is a temp variable specific to vAddr for jr
    string = "r[37]=" + @helpers.RS(i) + ";"

    #delay slot
    instruction = @memory.lw((@p[0] + offset + 4) | 0)
    opcode = this[@CPU_instruction[instruction >> 26 & 0x3f]](instruction, true)
    string += opcode
    string += "t.m[0]+=" + (@cnt+1) + ";t.p[0]=r[37];return t.fnLut[r[37]>>>2];"

  UNUSED: (i) ->
    @log "warning: UNUSED"
    ""

  r4300i_COP0_eret: (i) ->
    @stopCompiling = true
    string = "if((t.cp0[" + consts.STATUS + "]&" + consts.ERL + ")!==0){alert(\"error epc\");t.p[0]=t.cp0[" + consts.ERROREPC + "];"
    string += "t.cp0[" + consts.STATUS + "]&=~" + consts.ERL + "}else{t.p[0]=t.cp0[" + consts.EPC + "];t.cp0[" + consts.STATUS + "]&=~" + consts.EXL + "}"
    string += "t.m[0]+=" + (@cnt+1) + ";t.LLbit=0;return t.fnLut[t.p[0]>>>2];"

  r4300i_COP0_mtc0: (i, isDelaySlot) ->
    delaySlot = undefined
    lpc = undefined
    if isDelaySlot is true
      lpc = (@p[0] + offset + 4) | 0
      delaySlot = "true"
    else
      lpc = (@p[0] + offset) | 0
      delaySlot = "false"
    "t.helpers.inter_mtc0(r," + @helpers.fs(i) + "," + @helpers.rt(i) + "," + delaySlot + "," + lpc + ",t.cp0,t.interrupts);"

  r4300i_sll: (i) ->
    return ""  if (i & 0x001FFFFF) is 0 # NOP
    if @helpers.rd(i) is @helpers.rt(i)
      @helpers.tRD(i) + "<<=" + @helpers.sa(i) + ";" + @helpers.tRDH(i) + "=" + @helpers.RD(i) + ">>31;"
    else  
      @helpers.tRD(i) + "=" + @helpers.RT(i) + "<<" + @helpers.sa(i) + ";" + @helpers.tRDH(i) + "=" + @helpers.RD(i) + ">>31;"

  r4300i_srl: (i) ->
    sa = @helpers.sa(i)
    if sa > 0
      @helpers.tRD(i) + "=" + @helpers.RT(i) + ">>>" + sa + ";" + @helpers.tRDH(i) + "=0;"
    else
      #alert "ok"
      @helpers.tRDH(i) + "=" + @helpers.RT(i) + ">>31;" + @helpers.tRD(i) + "=" + @helpers.RT(i) + ";"

  r4300i_ori: (i) ->
    if @helpers.rt(i) is @helpers.rs(i)
      @helpers.tRT(i) + "|=" + @helpers.offset_imm(i) + ";"
    else
      @helpers.tRT(i) + "=" + @helpers.RS(i) + "|" + @helpers.offset_imm(i) + ";" + @helpers.tRTH(i) + "=" + @helpers.RSH(i) + ";"

  r4300i_xori: (i) ->
    if @helpers.rt(i) is @helpers.rs(i)
      @helpers.tRT(i) + "^=" + @helpers.offset_imm(i) + ";"
    else
      @helpers.tRT(i) + "=" + @helpers.RS(i) + "^" + @helpers.offset_imm(i) + ";" + @helpers.tRTH(i) + "=" + @helpers.RSH(i) + ";"

  r4300i_andi: (i) ->
    if @helpers.rt(i) is @helpers.rs(i)
      @helpers.tRT(i) + "&=" + @helpers.offset_imm(i) + ";" + @helpers.tRTH(i) + "=0;"
    else
      @helpers.tRT(i) + "=" + @helpers.RS(i) + "&" + @helpers.offset_imm(i) + ";" + @helpers.tRTH(i) + "=0;"

  r4300i_addi: (i) ->
    if @helpers.rt(i) is @helpers.rs(i)
      @helpers.tRT(i) + "+=" + @helpers.soffset_imm(i) + ";" + @helpers.tRTH(i) + "=" + @helpers.RT(i) + ">>31;"  
    else
      @helpers.tRT(i) + "=" + @helpers.RS(i) + "+" + @helpers.soffset_imm(i) + ";" + @helpers.tRTH(i) + "=" + @helpers.RT(i) + ">>31;"

  r4300i_addiu: (i) ->
    if @helpers.rt(i) is @helpers.rs(i)
      @helpers.tRT(i) + "+=" + @helpers.soffset_imm(i) + ";" + @helpers.tRTH(i) + "=" + @helpers.RT(i) + ">>31;"  
    else
      @helpers.tRT(i) + "=" + @helpers.RS(i) + "+" + @helpers.soffset_imm(i) + ";" + @helpers.tRTH(i) + "=" + @helpers.RT(i) + ">>31;"

  r4300i_slt: (i) ->
    @helpers.tRD(i) + "=((" + @helpers.RSH(i) + "<" + @helpers.RTH(i) + ")|(!(" + @helpers.RSH(i) + "-" + @helpers.RTH(i) + ")&(" + @helpers.uRS(i) + "<" + @helpers.uRT(i) + ")));" + @helpers.tRDH(i) + "=0;"

  r4300i_sltu: (i) ->
    @helpers.tRD(i) + "=((" + @helpers.uRSH(i) + "<" + @helpers.uRTH(i) + ")|(!(" + @helpers.uRSH(i) + "-" + @helpers.uRTH(i) + ")&(" + @helpers.uRS(i) + "<" + @helpers.uRT(i) + ")));" + @helpers.tRDH(i) + "=0;"

  r4300i_slti: (i) ->
    uoffset_imm_lo = undefined
    soffset_imm_hi = (@helpers.soffset_imm(i)) >> 31
    uoffset_imm_lo = (@helpers.soffset_imm(i)) >>> 0
    #space is important after the minus in "- " because soffset_imm_hi could be negative, and -- is decrement operator
    @helpers.tRT(i) + "=((" + @helpers.RSH(i) + "<" + soffset_imm_hi + ")|(!(" + @helpers.RSH(i) + "- " + soffset_imm_hi + ")&(" + @helpers.uRS(i) + "<" + uoffset_imm_lo + ")));" + @helpers.tRTH(i) + "=0;"

  r4300i_sltiu: (i) ->
    uoffset_imm_lo = undefined
    uoffset_imm_hi = (@helpers.soffset_imm(i) >> 31) >>> 0
    uoffset_imm_lo = (@helpers.soffset_imm(i)) >>> 0
    #space is important after the minus in "- " because uoffset_imm_hi could be negative, and -- is decrement operator
    @helpers.tRT(i) + "=((" + @helpers.uRSH(i) + "<" + uoffset_imm_hi + ")|(!(" + @helpers.uRSH(i) + "- " + uoffset_imm_hi + ")&(" + @helpers.uRS(i) + "<" + uoffset_imm_lo + ")));" + @helpers.tRTH(i) + "=0;"

  r4300i_cache: (i) ->
    @log "todo: r4300i_cache"
    @stopCompiling = true
    ""

  r4300i_multu: (i) ->
    "t.helpers.inter_multu(r,h," + i + ");"

  r4300i_mult: (i) ->
    "t.helpers.inter_mult(r,h," + i + ");"

  r4300i_mflo: (i) ->
    @helpers.tRD(i) + "=r[32];" + @helpers.tRDH(i) + "=h[32];"

  r4300i_mfhi: (i) ->
    @helpers.tRD(i) + "=r[33];" + @helpers.tRDH(i) + "=h[33];"

  r4300i_mtlo: (i) ->
    "r[32]=" + @helpers.RS(i) + ";h[32]=" + @helpers.RSH(i) + ";"

  r4300i_mthi: (i) ->
    "r[33]=" + @helpers.RS(i) + ";h[33]=" + @helpers.RSH(i) + ";"

  r4300i_COP0_mfc0: (i) ->
    string = ""
    switch @helpers.fs(i)
      when consts.RANDOM
        alert "RANDOM"
      when consts.COUNT
        #string += 't.cp0[' + this.helpers.fs(i) + ']-=t.m*2;'; # should this be t.m * 2?
      else
    string += @helpers.tRT(i) + "=t.cp0[" + @helpers.fs(i) + "];" + @helpers.tRTH(i) + "=t.cp0[" + @helpers.fs(i) + "]>>31;"

  r4300i_lb: (i) ->
    @helpers.virtualToPhysical(@helpers.RS(i) + "+" + @helpers.soffset_imm(i)) + @helpers.tRT(i) + "=m.LB[r[36]>>>16](m,r[36])<<24>>24;" + @helpers.tRTH(i) + "=" + @helpers.RT(i) + ">>8;"

  r4300i_lbu: (i) ->
    @helpers.virtualToPhysical(@helpers.RS(i) + "+" + @helpers.soffset_imm(i)) + @helpers.tRT(i) + "=m.LB[r[36]>>>16](m,r[36]);" + @helpers.tRTH(i) + "=0;"

  r4300i_lh: (i) ->
    @helpers.virtualToPhysical(@helpers.RS(i) + "+" + @helpers.soffset_imm(i)) + @helpers.tRT(i) + "=m.LH[r[36]>>>16](m,r[36])<<16>>16;" + @helpers.tRTH(i) + "=" + @helpers.RT(i) + ">>16;";

  r4300i_lhu: (i) ->
    @helpers.virtualToPhysical(@helpers.RS(i) + "+" + @helpers.soffset_imm(i)) + @helpers.tRT(i) + "=m.LH[r[36]>>>16](m,r[36]);" + @helpers.tRTH(i) + "=0;"

  r4300i_sb: (i, isDelaySlot) ->
    #"m.sb(" + @helpers.RT(i) + "," + @helpers.RS(i) + "+" + @helpers.soffset_imm(i) + ");"
    #string = "a = m.virtualToPhysical(" + @helpers.RS(i) + "+" + @helpers.soffset_imm(i) + ");m.SB[a>>>16](m," + @helpers.RT(i) + ",a"
    string = @helpers.virtualToPhysical(@helpers.RS(i) + "+" + @helpers.soffset_imm(i)) + "m.SB[r[36]>>>16](m," + @helpers.RT(i) + ",r[36]"

    #So we can process exceptions
    if isDelaySlot is true
      a = (@p[0] + offset + 4) | 0
      string += "," + a + ",true);"
    else
      a = (@p[0] + offset) | 0
      string += "," + a + ");"
    string

  r4300i_sh: (i, isDelaySlot) ->
    #"m.sh(" + @helpers.RT(i) + "," + @helpers.RS(i) + "+" + @helpers.soffset_imm(i) + ");"
    string = @helpers.virtualToPhysical(@helpers.RS(i) + "+" + @helpers.soffset_imm(i)) + "m.SH[r[36]>>>16](m," + @helpers.RT(i) + ",r[36]"

    #So we can process exceptions
    if isDelaySlot is true
      a = (@p[0] + offset + 4) | 0
      string += "," + a + ",true);"
    else
      a = (@p[0] + offset) | 0
      string += "," + a + ");"
    string

  r4300i_srlv: (i) ->
    @helpers.tRD(i) + "=" + @helpers.RT(i) + ">>>(" + @helpers.RS(i) + "&0x1f);" + @helpers.tRDH(i) + "=" + @helpers.RD(i) + ">>31;"

  r4300i_sllv: (i) ->
    @helpers.tRD(i) + "=" + @helpers.RT(i) + "<<(" + @helpers.RS(i) + "&0x1f);" + @helpers.tRDH(i) + "=" + @helpers.RD(i) + ">>31;"

  r4300i_srav: (i) ->
    #optimization: r[hi] can safely right-shift rt
    #"{" + @helpers.tRD(i) + "=" + @helpers.RT(i) + ">>(" + @helpers.RS(i) + "&0x1f);" + @helpers.tRDH(i) + "=" + @helpers.RT(i) + ">>31}"
    @helpers.tRDH(i) + "=(" + @helpers.tRD(i) + "=" + @helpers.RT(i) + ">>(" + @helpers.RS(i) + "&0x1f))>>31;"

  r4300i_COP1_cfc1: (i) ->
    @helpers.tRTH(i) + "=(" + @helpers.tRT(i) + "=t.cp1Con[" + @helpers.fs(i) + "])>>31;" if @helpers.fs(i) is 0 or @helpers.fs(i) is 31

  r4300i_COP1_ctc1: (i) ->
    #incomplete:
    "t.cp1Con[31]=" + @helpers.RT(i) + ";"  if @helpers.fs(i) is 31

  r4300i_ld: (i) ->
    @helpers.setVAddr(i) + @helpers.tRT(i) + "=m.lw((r[38]+4)|0);" + @helpers.tRTH(i) + "=m.lw(r[38]);"

  r4300i_lld: (i) ->
    @helpers.setVAddr(i) + @helpers.tRT(i) + "=m.lw((r[38]+4)|0);" + @helpers.tRTH(i) + "=m.lw(r[38]);t.LLbit=1;"

  #address error exceptions in ld and sd are weird since this is split up
  #into 2 reads or writes. i guess they're fatal exceptions, so
  #doesn't matter.
  r4300i_sd: (i, isDelaySlot) ->
    #lo
    a = undefined
    string = @helpers.setVAddr(i) + "m.sw(" + @helpers.RT(i) + ",(r[38]+4)|0"

    #So we can process exceptions
    if isDelaySlot is true
      a = (@p[0] + offset + 4) | 0
      string += "," + a + ",true);"
    else
      a = (@p[0] + offset) | 0
      string += "," + a + ");"

    #hi
    string += "m.sw(" + @helpers.RTH(i) + ",r[38]"

    #So we can process exceptions
    if isDelaySlot is true
      a = (@p[0] + offset + 4) | 0
      string += "," + a + ",true);"
    else
      a = (@p[0] + offset) | 0
      string += "," + a + ");"
    string

  r4300i_dmultu: (i) ->
    "t.helpers.inter_dmultu(r,h," + i + ");"

  r4300i_dsll32: (i) ->
    @helpers.tRDH(i) + "=" + @helpers.RT(i) + "<<" + @helpers.sa(i) + ";" + @helpers.tRD(i) + "=0;"

  r4300i_dsra32: (i) ->
    @helpers.tRD(i) + "=" + @helpers.RTH(i) + ">>" + @helpers.sa(i) + ";" + @helpers.tRDH(i) + "=" + @helpers.RTH(i) + ">>31;"

  r4300i_ddivu: (i) ->
    "t.helpers.inter_ddivu(r,h," + i + ");"

  r4300i_ddiv: (i) ->
    "t.helpers.inter_ddiv(r,h," + i + ");"

  r4300i_dadd: (i) ->
    @log "todo: dadd"
    ""

  r4300i_break: (i) ->
    @log "todo: break"
    ""

  r4300i_div: (i) ->
    "t.helpers.inter_div(r,h," + i + ");"

  r4300i_divu: (i) ->
    "t.helpers.inter_divu(r,h," + i + ");"

  r4300i_sra: (i) ->
    #optimization: sra's r[hi] can safely right-shift RT.
    string = @helpers.tRDH(i) + "=" + @helpers.RT(i) + ">>31;"

    if @helpers.rd(i) is @helpers.rt(i)
      string += @helpers.tRD(i) + ">>=" + @helpers.sa(i) + ";"
    else
      string += @helpers.tRD(i) + "=" + @helpers.RT(i) + ">>" + @helpers.sa(i) + ";"
    string

  r4300i_COP0_tlbwi: (i) ->
    "t.helpers.inter_tlbwi(t.cp0[" + consts.INDEX + "], t.tlb, t.cp0);"

  r4300i_COP0_tlbp: (i) ->
    "t.helpers.inter_tlbp(t.tlb, t.cp0);"

  r4300i_COP0_tlbr: (i) ->
    "t.helpers.inter_tlbr(t.tlb, t.cp0);"

  r4300i_lwl: (i) ->
    string = "{" + @helpers.setVAddr(i)
    string += "const vAddrAligned=(r[38]&-4)|0;const value=m.lw(vAddrAligned);"
    # r[38] = vAddress

    string += "const cas=r[38]&3;const mask=-1>>>(24-(cas<<3))>>>8;const shf=(cas<<3);"
    string += @helpers.tRT(i) + "&=mask;" + @helpers.tRT(i) + "|=((value<<shf)>>>0);"

#    string += "switch(r[38]&3){case 0:" + @helpers.tRT(i) + "=value;break;"
#    string += "case 1:" + @helpers.tRT(i) + "=(" + @helpers.RT(i) + "&0x000000ff)|((value<<8)>>>0);break;"
#    string += "case 2:" + @helpers.tRT(i) + "=(" + @helpers.RT(i) + "&0x0000ffff)|((value<<16)>>>0);break;"
#    string += "case 3:" + @helpers.tRT(i) + "=(" + @helpers.RT(i) + "&0x00ffffff)|((value<<24)>>>0);break;}"
    string += @helpers.tRTH(i) + "=" + @helpers.RT(i) + ">>31}"


  # r4300i_lwr: (i) ->
  #   string = "{" + @helpers.setVAddr(i)
  #   string += "var vAddrAligned=(r[38]&0xfffffffc)|0;var value=m.lw(vAddrAligned);"
  #   string += "switch(r[38]&3){"
  #   string += "case 0:" + @helpers.tRT(i) + "=(" + @helpers.RT(i) + "&0xffffff00)|(value>>>24);break;"
  #   string += "case 1:" + @helpers.tRT(i) + "=(" + @helpers.RT(i) + "&0xffff0000)|(value>>>16);break;"
  #   string += "case 2:" + @helpers.tRT(i) + "=(" + @helpers.RT(i) + "&0xff000000)|(value>>>8);break;"
  #   string += "case 3:" + @helpers.tRT(i) + "=value;break;}"
  #   string += @helpers.tRTH(i) + "=" + @helpers.RT(i) + ">>31}"

  r4300i_lwr: (i) ->
    string = "{" + @helpers.setVAddr(i)
    string += "const vAddrAligned=(r[38]&-4)|0;const value=m.lw(vAddrAligned);"
    # do not try to optimize further. 24<<8 is 32 but -1<<32 is not the same as -1<<24<<8.
    # in other words, shifting left by 32 requires 2 operations.
    # normally, you would not shift at all if it's 32, and we'd just set the target to 0, 
    # but we don't know if the shift amount is 32 until runtime,
    # and the optimization here is avoiding the switch (and thus the branching).
    # if we propagate constants, we could potentially know the shift amount sometimes.
    string += "const cas=r[38]&3;const mask=-1<<(cas<<3)<<8;const shf=32-((cas+1)<<3);"
    string += @helpers.tRT(i) + "&=mask;" + @helpers.tRT(i) + "|=(value>>>shf);"
    string += @helpers.tRTH(i) + "=" + @helpers.RT(i) + ">>31}"

  r4300i_swl: (i) ->
    string = "{" + @helpers.setVAddr(i)
    string += "const vAddrAligned=(r[38]&-4)|0;let value=m.lw(vAddrAligned);"
    string += "switch(r[38]&3){case 0:value=" + @helpers.RT(i) + ";break;"
    string += "case 1:value=((value&0xff000000)|(" + @helpers.RT(i) + ">>>8));break;"
    string += "case 2:value=((value&0xffff0000)|(" + @helpers.RT(i) + ">>>16));break;"
    string += "case 3:value=((value&0xffffff00)|(" + @helpers.RT(i) + ">>>24));break;}"
    string += "m.sw(value,vAddrAligned,false)}"

  r4300i_swr: (i) ->
    string = "{" + @helpers.setVAddr(i)
    string += "const vAddrAligned=(r[38]&-4)|0;let value=m.lw(vAddrAligned);"
    string += "switch(r[38]&3){case 3:value=" + @helpers.RT(i) + ";break;"
    string += "case 2:value=((value & 0xFF)|((" + @helpers.RT(i) + "<<8)>>>0));break;"
    string += "case 1:value=((value & 0xFFFF)|((" + @helpers.RT(i) + "<<16)>>>0));break;"
    string += "case 0:value=((value & 0xFFFFFF)|((" + @helpers.RT(i) + "<<24)>>>0));break;}"
    string += "m.sw(value,vAddrAligned,false)}"

  r4300i_lwc1: (i) ->
    "t.cp1_i[" + @helpers.FT32ArrayView(i) + "]=m.lw(" + @helpers.RS(i) + "+" + @helpers.soffset_imm(i) + ");"

  r4300i_ldc1: (i) ->
    string = @helpers.setVAddr(i) + "t.cp1_i[" + @helpers.FT32ArrayView(i) + "]=m.lw((r[38]+4)|0);"
    string += "t.cp1_i[" + @helpers.FT32HIArrayView(i) + "]=m.lw((r[38])|0);"

  r4300i_swc1: (i, isDelaySlot) ->
    a = undefined
    string = "m.sw(t.cp1_i[" + @helpers.FT32ArrayView(i) + "]," + @helpers.RS(i) + "+" + @helpers.soffset_imm(i)

    #So we can process exceptions
    if isDelaySlot is true
      a = (@p[0] + offset + 4) | 0
      string += "," + a + ",true);"
    else
      a = (@p[0] + offset) | 0
      string += "," + a + ");"
    string

  r4300i_sdc1: (i, isDelaySlot) ->
    a = undefined
    string = @helpers.setVAddr(i) + "m.sw(t.cp1_i[" + @helpers.FT32ArrayView(i) + "],(r[38]+4)|0"

    #So we can process exceptions
    if isDelaySlot is true
      a = (@p[0] + offset + 4) | 0
      string += "," + a + ",true);"
    else
      a = (@p[0] + offset) | 0
      string += "," + a + ");"
    string += "m.sw(t.cp1_i[" + @helpers.FT32HIArrayView(i) + "],(r[38])|0"

    #So we can process exceptions
    if isDelaySlot is true
      a = (@p[0] + offset + 4) | 0
      string += "," + a + ",true);"
    else
      a = (@p[0] + offset) | 0
      string += "," + a + ");"
    string

  r4300i_COP1_mtc1: (i) ->
    "t.cp1_i[" + @helpers.FS32ArrayView(i) + "]=" + @helpers.RT(i) + ";"

  r4300i_COP1_mfc1: (i) ->
    @helpers.tRTH(i) + "=(" + @helpers.tRT(i) + "=t.cp1_i[" + @helpers.FS32ArrayView(i) + "])>>31;"

  r4300i_COP1_cvts_w: (i) ->
    "t.cp1_f[" + @helpers.FD32ArrayView(i) + "]=t.cp1_i[" + @helpers.FS32ArrayView(i) + "];"

  r4300i_COP1_cvtw_s: (i) ->
    "t.cp1_i[" + @helpers.FD32ArrayView(i) + "]=t.cp1_f[" + @helpers.FS32ArrayView(i) + "];"

  r4300i_COP1_div_s: (i) ->
    "t.cp1_f[" + @helpers.FD32ArrayView(i) + "]=t.cp1_f[" + @helpers.FS32ArrayView(i) + "]/t.cp1_f[" + @helpers.FT32ArrayView(i) + "];"

  r4300i_COP1_div_d: (i) ->
    "t.cp1_f64[" + @helpers.FD64ArrayView(i) + "]=t.cp1_f64[" + @helpers.FS64ArrayView(i) + "]/t.cp1_f64[" + @helpers.FT64ArrayView(i) + "];"

  r4300i_COP1_mul_s: (i) ->
    "t.cp1_f[" + @helpers.FD32ArrayView(i) + "]=t.cp1_f[" + @helpers.FS32ArrayView(i) + "]*t.cp1_f[" + @helpers.FT32ArrayView(i) + "];"

  r4300i_COP1_mul_d: (i) ->
    "t.cp1_f64[" + @helpers.FD64ArrayView(i) + "]=t.cp1_f64[" + @helpers.FS64ArrayView(i) + "]*t.cp1_f64[" + @helpers.FT64ArrayView(i) + "];"

  r4300i_COP1_mov_s: (i) ->
    "t.cp1_i[" + @helpers.FD32ArrayView(i) + "]=t.cp1_i[" + @helpers.FS32ArrayView(i) + "];"

  r4300i_COP1_mov_d: (i) ->
    "t.cp1_f64[" + @helpers.FD32ArrayView(i) + "]=t.cp1_f64[" + @helpers.FS32ArrayView(i) + "];"

  r4300i_COP1_add_s: (i) ->
    "t.cp1_f[" + @helpers.FD32ArrayView(i) + "]=t.cp1_f[" + @helpers.FS32ArrayView(i) + "]+t.cp1_f[" + @helpers.FT32ArrayView(i) + "];"

  r4300i_COP1_sub_s: (i) ->
    "t.cp1_f[" + @helpers.FD32ArrayView(i) + "]=t.cp1_f[" + @helpers.FS32ArrayView(i) + "]-t.cp1_f[" + @helpers.FT32ArrayView(i) + "];"

  r4300i_COP1_cvtd_s: (i) ->
    "t.cp1_f64[" + @helpers.FD64ArrayView(i) + "]=t.cp1_f[" + @helpers.FS32ArrayView(i) + "];"

  r4300i_COP1_cvtd_w: (i) ->
    "t.cp1_f64[" + @helpers.FD64ArrayView(i) + "]=t.cp1_i[" + @helpers.FS32ArrayView(i) + "];"

  r4300i_COP1_cvts_d: (i) ->
    "t.cp1_f[" + @helpers.FD32ArrayView(i) + "]=t.cp1_f64[" + @helpers.FS64ArrayView(i) + "];"

  r4300i_COP1_cvtw_d: (i) ->
    "t.cp1_i[" + @helpers.FD32ArrayView(i) + "]=t.cp1_f64[" + @helpers.FS64ArrayView(i) + "];"

  r4300i_COP1_add_d: (i) ->
    "t.cp1_f64[" + @helpers.FD64ArrayView(i) + "]=t.cp1_f64[" + @helpers.FS64ArrayView(i) + "]+t.cp1_f64[" + @helpers.FT64ArrayView(i) + "];"

  r4300i_COP1_sub_d: (i) ->
    "t.cp1_f64[" + @helpers.FD64ArrayView(i) + "]=t.cp1_f64[" + @helpers.FS64ArrayView(i) + "]-t.cp1_f64[" + @helpers.FT64ArrayView(i) + "];"

  #todo:rounding
  r4300i_COP1_truncw_d: (i) ->
    "t.cp1_i[" + @helpers.FD32ArrayView(i) + "]=t.cp1_f64[" + @helpers.FS64ArrayView(i) + "];"

  r4300i_COP1_truncw_s: (i) ->
    "t.cp1_i[" + @helpers.FD32ArrayView(i) + "]=t.cp1_f[" + @helpers.FS32ArrayView(i) + "];"

  r4300i_COP1_neg_s: (i) ->
    "t.cp1_i[" + @helpers.FD32ArrayView(i) + "]=t.cp1_i[" + @helpers.FS32ArrayView(i) + "]^0x80000000;"

  r4300i_COP1_neg_d: (i) ->
    "t.cp1_i[" + @helpers.FD32HIArrayView(i) + "]=t.cp1_i[" + @helpers.FS32HIArrayView(i) + "]^0x80000000;"

  r4300i_COP1_abs_s: (i) ->
    "t.cp1_i[" + @helpers.FD32ArrayView(i) + "]=t.cp1_i[" + @helpers.FS32ArrayView(i) + "]&0x7fffffff;"

  r4300i_COP1_abs_d: (i) ->
    "t.cp1_i[" + @helpers.FD32HIArrayView(i) + "]=t.cp1_i[" + @helpers.FS32HIArrayView(i) + "]&0x7fffffff;"

  r4300i_COP1_sqrt_s: (i) ->
    "t.cp1_f[" + @helpers.FD32ArrayView(i) + "]=Math.sqrt(t.cp1_f[" + @helpers.FS32ArrayView(i) + "]);"

  r4300i_COP1_sqrt_d: (i) ->
    "t.cp1_f64[" + @helpers.FD64ArrayView(i) + "]=Math.sqrt(t.cp1_f64[" + @helpers.FS64ArrayView(i) + "]);"

  r4300i_sync: (i) ->
    @log "todo: sync"
    ""

  r4300i_sdr: (i) ->
    @log "todo: sdr"
    ""

  r4300i_ldr: (i) ->
    @log "todo: ldr"
    ""

  r4300i_sdl: (i) ->
    @log "todo: sdl"
    ""

  r4300i_ldl: (i) ->
    @log "todo: ldl"
    ""

  r4300i_sc: (i) ->
    @log "todo: sc"
    ""

  r4300i_scd: (i) ->
    @log "todo: scd"
    ""

  r4300i_daddi: (i) ->
    "t.helpers.inter_daddi(r,h," + i + ");"

  r4300i_teq: (i) ->
    @log "todo: r4300i_teq"
    ""

  r4300i_tgeu: (i) ->
    @log "todo: r4300i_tgeu"
    ""

  r4300i_tlt: (i) ->
    @log "todo: r4300i_tlt"
    ""

  r4300i_tltu: (i) ->
    @log "todo: r4300i_tltu"
    ""

  r4300i_tne: (i) ->
    @log "todo: r4300i_tne"
    ""

  #using same as daddi
  r4300i_daddiu: (i) ->
    "t.helpers.inter_daddiu(r,h," + i + ");"

  r4300i_daddu: (i) ->
    "t.helpers.inter_daddu(r,h," + i + ");"

  r4300i_C_F_S: (i) ->
    "t.helpers.inter_r4300i_C_cond_fmt_s(" + i + ",t.cp1Con,t.cp1_f);"

  r4300i_C_UN_S: (i) ->
    "t.helpers.inter_r4300i_C_cond_fmt_s(" + i + ",t.cp1Con,t.cp1_f);"

  r4300i_C_EQ_S: (i) ->
    "t.helpers.inter_r4300i_C_cond_fmt_s(" + i + ",t.cp1Con,t.cp1_f);"

  r4300i_C_UEQ_S: (i) ->
    "t.helpers.inter_r4300i_C_cond_fmt_s(" + i + ",t.cp1Con,t.cp1_f);"

  r4300i_C_OLT_S: (i) ->
    "t.helpers.inter_r4300i_C_cond_fmt_s(" + i + ",t.cp1Con,t.cp1_f);"

  r4300i_C_ULT_S: (i) ->
    "t.helpers.inter_r4300i_C_cond_fmt_s(" + i + ",t.cp1Con,t.cp1_f);"

  r4300i_C_OLE_S: (i) ->
    "t.helpers.inter_r4300i_C_cond_fmt_s(" + i + ",t.cp1Con,t.cp1_f);"

  r4300i_C_ULE_S: (i) ->
    "t.helpers.inter_r4300i_C_cond_fmt_s(" + i + ",t.cp1Con,t.cp1_f);"

  r4300i_C_SF_S: (i) ->
    "t.helpers.inter_r4300i_C_cond_fmt_s(" + i + ",t.cp1Con,t.cp1_f);"

  r4300i_C_NGLE_S: (i) ->
    "t.helpers.inter_r4300i_C_cond_fmt_s(" + i + ",t.cp1Con,t.cp1_f);"

  r4300i_C_SEQ_S: (i) ->
    "t.helpers.inter_r4300i_C_cond_fmt_s(" + i + ",t.cp1Con,t.cp1_f);"

  r4300i_C_NGL_S: (i) ->
    "t.helpers.inter_r4300i_C_cond_fmt_s(" + i + ",t.cp1Con,t.cp1_f);"

  r4300i_C_LT_S: (i) ->
    "t.helpers.inter_r4300i_C_cond_fmt_s(" + i + ",t.cp1Con,t.cp1_f);"

  r4300i_C_NGE_S: (i) ->
    "t.helpers.inter_r4300i_C_cond_fmt_s(" + i + ",t.cp1Con,t.cp1_f);"

  r4300i_C_LE_S: (i) ->
    "t.helpers.inter_r4300i_C_cond_fmt_s(" + i + ",t.cp1Con,t.cp1_f);"

  r4300i_C_NGT_S: (i) ->
    "t.helpers.inter_r4300i_C_cond_fmt_s(" + i + ",t.cp1Con,t.cp1_f);"

  r4300i_C_F_D: (i) ->
    "t.helpers.inter_r4300i_C_cond_fmt_d(" + i + ",t.cp1Con,t.cp1_f64);"

  r4300i_C_UN_D: (i) ->
    "t.helpers.inter_r4300i_C_cond_fmt_d(" + i + ",t.cp1Con,t.cp1_f64);"

  r4300i_C_EQ_D: (i) ->
    "t.helpers.inter_r4300i_C_cond_fmt_d(" + i + ",t.cp1Con,t.cp1_f64);"

  r4300i_C_UEQ_D: (i) ->
    "t.helpers.inter_r4300i_C_cond_fmt_d(" + i + ",t.cp1Con,t.cp1_f64);"

  r4300i_C_OLT_D: (i) ->
    "t.helpers.inter_r4300i_C_cond_fmt_d(" + i + ",t.cp1Con,t.cp1_f64);"

  r4300i_C_ULT_D: (i) ->
    "t.helpers.inter_r4300i_C_cond_fmt_d(" + i + ",t.cp1Con,t.cp1_f64);"

  r4300i_C_OLE_D: (i) ->
    "t.helpers.inter_r4300i_C_cond_fmt_d(" + i + ",t.cp1Con,t.cp1_f64);"

  r4300i_C_ULE_D: (i) ->
    "t.helpers.inter_r4300i_C_cond_fmt_d(" + i + ",t.cp1Con,t.cp1_f64);"

  r4300i_C_SF_D: (i) ->
    "t.helpers.inter_r4300i_C_cond_fmt_d(" + i + ",t.cp1Con,t.cp1_f64);"

  r4300i_C_NGLE_D: (i) ->
    "t.helpers.inter_r4300i_C_cond_fmt_d(" + i + ",t.cp1Con,t.cp1_f64);"

  r4300i_C_SEQ_D: (i) ->
    "t.helpers.inter_r4300i_C_cond_fmt_d(" + i + ",t.cp1Con,t.cp1_f64);"

  r4300i_C_NGL_D: (i) ->
    "t.helpers.inter_r4300i_C_cond_fmt_d(" + i + ",t.cp1Con,t.cp1_f64);"

  r4300i_C_LT_D: (i) ->
    "t.helpers.inter_r4300i_C_cond_fmt_d(" + i + ",t.cp1Con,t.cp1_f64);"

  r4300i_C_NGE_D: (i) ->
    "t.helpers.inter_r4300i_C_cond_fmt_d(" + i + ",t.cp1Con,t.cp1_f64);"

  r4300i_C_LE_D: (i) ->
    "t.helpers.inter_r4300i_C_cond_fmt_d(" + i + ",t.cp1Con,t.cp1_f64);"

  r4300i_C_NGT_D: (i) ->
    "t.helpers.inter_r4300i_C_cond_fmt_d(" + i + ",t.cp1Con,t.cp1_f64);"

#hack global space until we export classes properly
#node.js uses exports; browser uses this (window)
root = exports ? self
root.C1964jsEmulator = C1964jsEmulator
root.consts = consts
