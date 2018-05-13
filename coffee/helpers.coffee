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

#///////////////
#Operand helpers
#///////////////

#jslint bitwise: true, devel: true, todo: true
#global consts
#global goog, BigInt, bigint_mul, bigint_div, bigint_mod

C1964jsHelpers = (core, isLittleEndian) ->
  "use strict"
  this.core = core
  @isLittleEndian = isLittleEndian
  @isBigEndian = (isLittleEndian is false)
  @fs = (i) ->
    i >> 11 & 0x1f

  @ft = (i) ->
    i >> 16 & 0x1f

  @FS32ArrayView = (i) ->
    (i >> 11 & 0x1f) ^ @isBigEndian

  @FS32HIArrayView = (i) ->
    (i >> 11 & 0x1f) ^ @isLittleEndian

  @FT32ArrayView = (i) ->
    (i >> 16 & 0x1f) ^ @isBigEndian

  @FT32HIArrayView = (i) ->
    (i >> 16 & 0x1f) ^ @isLittleEndian

  @FD32ArrayView = (i) ->
    (i >> 6 & 0x1F) ^ @isBigEndian

  @FD32HIArrayView = (i) ->
    (i >> 6 & 0x1f) ^ @isLittleEndian

  @FS64ArrayView = (i) ->
    (i >> 11 & 0x1f) >> 1

  @FT64ArrayView = (i) ->
    (i >> 16 & 0x1f) >> 1

  @FD64ArrayView = (i) ->
    (i >> 6 & 0x1F) >> 1

  @rd = (i) ->
    i >> 11 & 0x1f

  @rs = (i) ->
    i >> 21 & 0x1f

  @RS = (i) ->
    reg = (i >> 21 & 0x1f)
    return "~-1"  if reg is 0
    "~~r[" + reg + "]"

  @RSH = (i) ->
    reg = (i >> 21 & 0x1f)
    return "~-1"  if reg is 0
    "~~h[" + reg + "]"

  @uRS = (i) ->
    reg = (i >> 21 & 0x1f)
    return "~-1"  if reg is 0
    "(r[" + reg + "]>>>0)"

  @uRSH = (i) ->
    reg = (i >> 21 & 0x1f)
    return "~-1"  if reg is 0
    "(h[" + reg + "]>>>0)"

  @tRS = (i) ->
    reg = (i >> 21 & 0x1f)
    return "r[34]"  if reg is 0
    "r[" + reg + "]"

  @tRSH = (i) ->
    reg = (i >> 21 & 0x1f)
    return "h[34]"  if reg is 0
    "h[" + reg + "]"

  @tRD = (i) ->
    reg = (i >> 11 & 0x1f)
    return "r[34]"  if reg is 0
    "r[" + reg + "]"

  @tRDH = (i) ->
    reg = (i >> 11 & 0x1f)
    return "h[34]"  if reg is 0
    "h[" + reg + "]"

  @tRT = (i) ->
    reg = (i >> 16 & 0x1f)
    return "r[34]"  if reg is 0
    "r[" + reg + "]"

  @tRTH = (i) ->
    reg = (i >> 16 & 0x1f)
    return "h[34]"  if reg is 0
    "h[" + reg + "]"

  @RD = (i) ->
    reg = (i >> 11 & 0x1f)
    return "~-1"  if reg is 0
    "~~r[" + reg + "]"

  @RDH = (i) ->
    reg = (i >> 11 & 0x1f)
    return "~-1"  if reg is 0
    "~~h[" + reg + "]"

  @uRD = (i) ->
    reg = (i >> 11 & 0x1f)
    return "~-1"  if reg is 0
    "(r[" + reg + "]>>>0)"

  @uRDH = (i) ->
    reg = (i >> 11 & 0x1f)
    return "~-1"  if reg is 0
    "(h[" + reg + "]>>>0)"

  @RT = (i) ->
    reg = (i >> 16 & 0x1f)
    return "~-1"  if reg is 0
    "~~r[" + reg + "]"

  @RTH = (i) ->
    reg = (i >> 16 & 0x1f)
    return "~-1"  if reg is 0
    "~~h[" + reg + "]"

  @uRT = (i) ->
    reg = (i >> 16 & 0x1f)
    return "~-1"  if reg is 0
    "(r[" + reg + "]>>>0)"

  @uRTH = (i) ->
    reg = (i >> 16 & 0x1f)
    return "~-1"  if reg is 0
    "(h[" + reg + "]>>>0)"

  @rt = (i) ->
    i >> 16 & 0x1f

  @offset_imm = (i) ->
    i & 0xffff

  @soffset_imm = (i) ->
    i << 16 >> 16

  @setVAddr = (i) ->
    "r[38]=" + @RS(i) + "+" + @soffset_imm(i) + ";"

  @fn = (i) ->
    i & 0x3f

  @sa = (i) ->
    i >> 6 & 0x1F

  @fd = (i) ->
    i >> 6 & 0x1F

  @sLogic = (i, n) ->
    if (@rd(i) is @rs(i))
      @tRD(i) + n + "=" + @RT(i) + ";" + @tRDH(i) + "=" + @RD(i) + ">>31;"
    else
      @tRD(i) + "=" + @RS(i) + n + @RT(i) + ";" + @tRDH(i) + "=" + @RD(i) + ">>31;";

  @dLogic = (i, n) ->
    if (@rd(i) is @rs(i))
      @tRD(i) + n + "=" + @RT(i) + ";" + @tRDH(i) + n + "=" + @RTH(i) + ";"
    else
      @tRD(i) + "=" + @RS(i) + n + @RT(i) + ";" + @tRDH(i) + "=" + @RSH(i) + n + @RTH(i) + ";"

  @virtualToPhysical = (addr) ->
    "r[35]=" + addr + ";r[36]=(m.t[r[35]>>>12]<<16)|(r[35]&0xffff);"

  #//////////////////////////
  #Interpreted opcode helpers
  #//////////////////////////

  #called function, not compiled
  @inter_mtc0 = (r, f, rt, isDelaySlot, pc, cp0, interrupts) ->

    #incomplete:
    switch f
      when consts.CAUSE
        cp0[f] &= ~0x300
        cp0[f] |= r[rt] & 0x300

        #      if (((r[rt] & 1)===1) && (cp0[f] & 1)===0) //possible fix over 1964cpp?
        interrupts.setException consts.EXC_INT, 0, pc, isDelaySlot  if (cp0[consts.CAUSE] & cp0[consts.STATUS] & 0x0000FF00) isnt 0  and (r[rt] & 0x300) isnt 0

      #interrupts.processException(pc, isDelaySlot);
      when consts.COUNT
        cp0[f] = r[rt]
      when consts.COMPARE
        cp0[consts.CAUSE] &= ~consts.CAUSE_IP8
        cp0[f] = r[rt]
      when consts.STATUS
        if ((r[rt] & consts.EXL) is 0) and ((cp0[f] & consts.EXL) is 1)
          if (cp0[consts.CAUSE] & cp0[consts.STATUS] & 0x0000FF00) isnt 0
            cp0[f] = r[rt]
            interrupts.setException consts.EXC_INT, 0, pc, isDelaySlot

            #interrupts.processException(pc, isDelaySlot);
            return
        if ((r[rt] & consts.IE) is 1) and ((cp0[f] & consts.IE) is 0)
          if (cp0[consts.CAUSE] & cp0[consts.STATUS] & 0x0000FF00) isnt 0
            cp0[f] = r[rt]
            interrupts.setException consts.EXC_INT, 0, pc, isDelaySlot

            #interrupts.processException(pc, isDelaySlot);
            return
        cp0[f] = r[rt]
      #tlb:
      when consts.BADVADDR, consts.PREVID, consts.RANDOM
        break
      when consts.INDEX
        cp0[f] = r[rt] & 0x8000003F
      when consts.ENTRYLO0
        cp0[f] = r[rt] & 0x3FFFFFFF
      when consts.ENTRYLO1
        cp0[f] = r[rt] & 0x3FFFFFFF
      when consts.ENTRYHI
        cp0[f] = r[rt] & 0xFFFFE0FF
      when consts.PAGEMASK
        cp0[f] = r[rt] & 0x01FFE000
      when consts.WIRED
        cp0[f] = r[rt] & 0x1f
        cp0[consts.RANDOM] = 0x1f
      else
        cp0[f] = r[rt]
    return

  @inter_mult = (r, h, i) ->
    res = undefined
    r1 = undefined
    r2 = undefined
    rt32 = undefined
    rs32 = r[@rs(i)]
    rt32 = r[@rt(i)]
    r1 = goog.math.Long.fromBits(rs32, rs32 >> 31)
    r2 = goog.math.Long.fromBits(rt32, rt32 >> 31)
    res = r1.multiply(r2)
    r[32] = res.getLowBits() #lo
    h[32] = r[32] >> 31
    r[33] = res.getHighBits() #hi
    h[33] = r[33] >> 31
    return

  @inter_multu = (r, h, i) ->
    res = undefined
    r1 = undefined
    r2 = undefined
    rt32 = undefined
    rs32 = r[@rs(i)]
    rt32 = r[@rt(i)]
    r1 = goog.math.Long.fromBits(rs32, 0)
    r2 = goog.math.Long.fromBits(rt32, 0)
    res = r1.multiply(r2)
    r[32] = res.getLowBits() #lo
    h[32] = r[32] >> 31
    r[33] = res.getHighBits() #hi
    h[33] = r[33] >> 31
    return

  #    alert('multu: '+r[this.rs(i)]+'*'+r[this.rt(i)]+'='+dec2hex(h[33]) +' '+dec2hex(r[33])+' '+dec2hex(h[32])+' '+dec2hex(r[32]));
  @inter_daddi = (r, h, i) ->
    rtres = undefined
    imm = undefined
    rs1 = goog.math.Long.fromBits(r[@rs(i)], h[@rs(i)])
    imm = goog.math.Long.fromBits(@soffset_imm(i), @soffset_imm(i) >> 31)
    rtres = rs1.add(imm)
    r[@rt(i)] = rtres.getLowBits() #lo
    h[@rt(i)] = rtres.getHighBits() #hi
    return

  @inter_daddiu = (r, h, i) ->
    rtres = undefined
    imm = undefined
    rs1 = goog.math.Long.fromBits(r[@rs(i)], h[@rs(i)])
    imm = goog.math.Long.fromBits(@soffset_imm(i), @soffset_imm(i) >> 31)
    rtres = rs1.add(imm)
    r[@rt(i)] = rtres.getLowBits() #lo
    h[@rt(i)] = rtres.getHighBits() #hi
    return

  @inter_dadd = (r, h, i) ->
    rdres = undefined
    rt1 = undefined
    rs1 = goog.math.Long.fromBits(r[@rs(i)], h[@rs(i)])
    rt1 = goog.math.Long.fromBits(r[@rt(i)], h[@rt(i)])
    rdres = rs1.add(rt1)
    r[@rd(i)] = rdres.getLowBits() #lo
    h[@rd(i)] = rdres.getHighBits() #hi
    return

  @inter_daddu = (r, h, i) ->
    rdres = undefined
    rt1 = undefined
    rs1 = goog.math.Long.fromBits(r[@rs(i)], h[@rs(i)])
    rt1 = goog.math.Long.fromBits(r[@rt(i)], h[@rt(i)])
    rdres = rs1.add(rt1)
    r[@rd(i)] = rdres.getLowBits() #lo
    h[@rd(i)] = rdres.getHighBits() #hi
    return

  @inter_div = (r, h, i) ->
    if r[@rt(i)] is 0
      alert "divide by zero"
      return

    #todo: handle div by zero
    r[32] = r[@rs(i)] / r[@rt(i)] #lo
    h[32] = r[32] >> 31 #hi
    r[33] = r[@rs(i)] % r[@rt(i)] #lo
    h[33] = r[33] >> 31 #hi
    return

  #alert('div: '+r[this.rs(i)]+'/'+r[this.rt(i)]+'='+dec2hex(h[33]) +' '+dec2hex(r[33])+' '+dec2hex(h[32])+' '+dec2hex(r[32]));
  @inter_ddiv = (r, h, i) ->
    res = undefined
    mod = undefined
    rsh32 = undefined
    rth32 = undefined
    r1 = undefined
    r2 = undefined
    rt32 = undefined
    rs32 = r[@rs(i)]
    rt32 = r[@rt(i)]
    rsh32 = h[@rs(i)]
    rth32 = h[@rt(i)]
    r1 = goog.math.Long.fromBits(rs32, rsh32)
    r2 = goog.math.Long.fromBits(rt32, rth32)
    if r2 is 0
      alert "divide by zero"
      return
    res = r1.div(r2)
    mod = r1.modulo(r2)
    r[32] = res.getLowBits() #lo
    h[32] = res.getHighBits() #hi
    r[33] = mod.getLowBits() #lo
    h[33] = mod.getHighBits() #hi
    return

  #alert('ddiv: '+rs64+'/'+rt64+'='+dec2hex(h[33]) +' '+dec2hex(r[33])+' '+dec2hex(h[32])+' '+dec2hex(r[32]));
  @inter_divu = (r, h, i) ->
    if r[@rt(i)] is 0
      alert "divide by zero"
      return

    #todo: handle div by zero
    r[32] = (r[@rs(i)] >>> 0) / (r[@rt(i)] >>> 0) #lo
    h[32] = r[32] >> 31 #hi
    r[33] = (r[@rs(i)] >>> 0) % (r[@rt(i)] >>> 0) #lo
    h[33] = r[33] >> 31 #hi
    return

  #alert('divu: '+r[this.rs(i)]+'/'+r[this.rt(i)]+'='+dec2hex(h[33]) +' '+dec2hex(r[33])+' '+dec2hex(h[32])+' '+dec2hex(r[32]));
  @inter_dmult = (r, h, i) ->
    #this is wrong..i think BigInt it will treat hex as unsigned?
    delim = undefined
    x = undefined
    y = undefined
    z = undefined
    num = undefined
    rt64 = undefined

    alert "dmult RSh negative:" + h[@rs(i)]  if h[@rs(i)] < 0
    alert "dmult RTh negative:" + h[@rt(i)]  if h[@rt(i)] < 0

    rs64 = "0x" + String(dec2hex(h[@rs(i)])) + String(dec2hex(r[@rs(i)]))
    rt64 = "0x" + String(dec2hex(h[@rt(i)])) + String(dec2hex(r[@rt(i)]))
    x = new BigInt(rs64)
    y = new BigInt(rt64)
    z = bigint_mul(x, y)
    num = z.toStringBase(16)
    alert "dmult:" + num  if num[0] is "-"
    if num.length > 24
      delim = num.length - 24
      h[33] = ("0x" + num.substr(0, delim)) >>> 0 # hi of HIREG
      r[33] = ("0x" + num.substr(delim, 8)) >>> 0 # lo of HIREG
      h[32] = ("0x" + num.substr(delim + 8, 8)) >>> 0 # hi of LOREG
      r[32] = ("0x" + num.substr(delim + 16, 8)) >>> 0 # lo of LOREG
    else if num.length > 16
      delim = num.length - 16
      h[33] = 0 # hi of HIREG
      r[33] = ("0x" + num.substr(0, delim)) >>> 0 # lo of HIREG
      h[32] = ("0x" + num.substr(delim, 8)) >>> 0 # hi of LOREG
      r[32] = ("0x" + num.substr(delim + 8, 8)) >>> 0 # lo of LOREG
    else if num.length > 8
      delim = num.length - 8
      h[33] = 0 # hi of HIREG
      r[33] = 0 # lo of HIREG
      h[32] = ("0x" + num.substr(0, delim)) >>> 0 # hi of LOREG
      r[32] = ("0x" + num.substr(delim, 8)) >>> 0 # lo of LOREG
    else
      delim = num.length
      h[33] = 0 # hi of HIREG
      r[33] = 0 # lo of HIREG
      h[32] = 0 # hi of LOREG
      r[32] = ("0x" + num.substr(0, delim)) >>> 0 # lo of LOREG
    return

  #alert('dmult: '+rs64+'*'+rt64+'='+dec2hex(h[33]) +' '+dec2hex(r[33])+' '+dec2hex(h[32])+' '+dec2hex(r[32]));
  @inter_dmultu = (r, h, i) ->
    #Attax demo
    delim = undefined
    x = undefined
    y = undefined
    z = undefined
    num = undefined
    rt64 = undefined
    rs64 = "0x0" + String(dec2hex(h[@rs(i)])) + String(dec2hex(r[@rs(i)]))
    rt64 = "0x0" + String(dec2hex(h[@rt(i)])) + String(dec2hex(r[@rt(i)]))
    x = new BigInt(rs64)
    y = new BigInt(rt64)
    z = bigint_mul(x, y)
    num = z.toStringBase(16)
    alert "dmultu:" + num  if num[0] is "-"
    if num.length > 24
      delim = num.length - 24
      h[33] = ("0x" + num.substr(0, delim)) >>> 0 # hi of HIREG
      r[33] = ("0x" + num.substr(delim, 8)) >>> 0 # lo of HIREG
      h[32] = ("0x" + num.substr(delim + 8, 8)) >>> 0 # hi of LOREG
      r[32] = ("0x" + num.substr(delim + 16, 8)) >>> 0 # lo of LOREG
    else if num.length > 16
      delim = num.length - 16
      h[33] = 0 # hi of HIREG
      r[33] = ("0x" + num.substr(0, delim)) >>> 0 # lo of HIREG
      h[32] = ("0x" + num.substr(delim, 8)) >>> 0 # hi of LOREG
      r[32] = ("0x" + num.substr(delim + 8, 8)) >>> 0 # lo of LOREG
    else if num.length > 8
      delim = num.length - 8
      h[33] = 0 # hi of HIREG
      r[33] = 0 # lo of HIREG
      h[32] = ("0x" + num.substr(0, delim)) >>> 0 # hi of LOREG
      r[32] = ("0x" + num.substr(delim, 8)) >>> 0 # lo of LOREG
    else
      delim = num.length
      h[33] = 0 # hi of HIREG
      r[33] = 0 # lo of HIREG
      h[32] = 0 # hi of LOREG
      r[32] = ("0x" + num.substr(0, delim)) >>> 0 # lo of LOREG
    return

  #alert('dmultu: '+rs64+'*'+rt64+'='+dec2hex(h[33]) +' '+dec2hex(r[33])+' '+dec2hex(h[32])+' '+dec2hex(r[32]));
  @inter_ddivu = (r, h, i) ->
    delim = undefined
    x = undefined
    y = undefined
    z = undefined
    num = undefined
    rt64 = undefined
    rs64 = "0x0" + String(dec2hex(h[@rs(i)])) + String(dec2hex(r[@rs(i)]))
    rt64 = "0x0" + String(dec2hex(h[@rt(i)])) + String(dec2hex(r[@rt(i)]))
    x = new BigInt(rs64)
    y = new BigInt(rt64)
    z = bigint_div(x, y)
    unless z
      r[32] = 0
      h[32] = 0
    else
      num = z.toStringBase(16)
      alert "ddivu:" + num  if num[0] is "-"
      if num.length > 8
        delim = num.length - 8
        h[32] = ("0x" + num.substr(0, delim)) >>> 0 # hi of LOREG
        r[32] = ("0x" + num.substr(delim, 8)) >>> 0 # lo of LOREG
      else
        delim = num.length
        h[32] = 0 # hi of LOREG
        r[32] = ("0x" + num.substr(0, delim)) >>> 0 # lo of LOREG

    #mod
    z = bigint_mod(x, y)
    num = z.toStringBase(16)
    if num.length > 8
      delim = num.length - 8
      h[33] = ("0x" + num.substr(0, delim)) >>> 0 # hi of LOREG
      r[33] = ("0x" + num.substr(delim, 8)) >>> 0 # lo of LOREG
    else
      delim = num.length
      h[33] = 0 # hi of LOREG
      r[33] = ("0x" + num.substr(0, delim)) >>> 0 # lo of LOREG
    return

  #alert('ddivu: '+rs64+'/'+rt64+'='+dec2hex(h[33]) +' '+dec2hex(r[33])+' '+dec2hex(h[32])+' '+dec2hex(r[32]));
  @inter_r4300i_C_cond_fmt_s = (instruction, cp1Con, cp1_f) ->
    fcFS32 = undefined
    fcFT32 = undefined
    less = undefined
    equal = undefined
    unordered = undefined
    cond = undefined
    cond0 = undefined
    cond1 = undefined
    cond2 = undefined
    cond3 = undefined

    #CHK_ODD_FPR_2_REG(RD_FS, RT_FT);
    cond0 = (instruction) & 0x1
    cond1 = (instruction >> 1) & 0x1
    cond2 = (instruction >> 2) & 0x1
    cond3 = (instruction >> 3) & 0x1
    fcFS32 = cp1_f[@FS32ArrayView(instruction)]
    fcFT32 = cp1_f[@FT32ArrayView(instruction)]
    if isNaN(fcFS32) or isNaN(fcFT32)
      less = false
      equal = false
      unordered = true
      #Fire invalid operation exception
      return  if cond3 isnt 0
    else
      less = (fcFS32 < fcFT32)
      equal = (fcFS32 is fcFT32)
      unordered = false
    cond = ((cond0 and unordered) or (cond1 and equal) or (cond2 and less))
    cp1Con[31] &= ~consts.COP1_CONDITION_BIT
    cp1Con[31] |= consts.COP1_CONDITION_BIT  if cond
    return

  @inter_r4300i_C_cond_fmt_d = (instruction, cp1Con, cp1_f64) ->
    fcFS64 = undefined
    fcFT64 = undefined
    less = undefined
    equal = undefined
    unordered = undefined
    cond = undefined
    cond0 = undefined
    cond1 = undefined
    cond2 = undefined
    cond3 = undefined

    # CHK_ODD_FPR_2_REG(RD_FS, RT_FT);
    cond0 = (instruction) & 0x1
    cond1 = (instruction >> 1) & 0x1
    cond2 = (instruction >> 2) & 0x1
    cond3 = (instruction >> 3) & 0x1
    fcFS64 = cp1_f64[@FS64ArrayView(instruction)]
    fcFT64 = cp1_f64[@FT64ArrayView(instruction)]
    if isNaN(fcFS64) or isNaN(fcFT64)
      less = false
      equal = false
      unordered = true

      #Fire invalid operation exception
      return  if cond3 isnt 0
    else
      less = (fcFS64 < fcFT64)
      equal = (fcFS64 is fcFT64)
      unordered = false
    cond = ((cond0 and unordered) or (cond1 and equal) or (cond2 and less))
    cp1Con[31] &= ~consts.COP1_CONDITION_BIT
    cp1Con[31] |= consts.COP1_CONDITION_BIT  if cond
    return

  @writeTLBEntry = (tlb, cp0) ->
    g = cp0[consts.ENTRYLO0] & cp0[consts.ENTRYLO1] & consts.TLBLO_G

    tlb.pageMask = cp0[consts.PAGEMASK] >>> 0
    tlb.entryLo1 = (cp0[consts.ENTRYLO1] | g) >>> 0
    tlb.entryLo0 = (cp0[consts.ENTRYLO0] | g) >>> 0
    tlb.myHiMask = ((~tlb.pageMask >>> 0) & consts.TLBHI_VPN2MASK) >>> 0
    tlb.entryHi = ((cp0[consts.ENTRYHI]>>>0) & (~cp0[consts.PAGEMASK] >>> 0)) >>> 0

    switch tlb.pageMask
      when 0x00000000 then tlb.loCompare = 0x00001000 #4k
      when 0x00006000 then tlb.loCompare = 0x00004000 #16k
      when 0x0001e000 then tlb.loCompare = 0x00010000 #64k
      when 0x0007e000 then tlb.loCompare = 0x00040000 #256k
      when 0x001fe000 then tlb.loCompare = 0x00100000 #1M
      when 0x007fe000 then tlb.loCompare = 0x00400000 #4M
      when 0x01ffe000 then tlb.loCompare = 0x01000000 #16M
      else console.log "ERROR: tlbwi - invalid page size" + tlb.pageMask

    @newtlb = true
    return

  @buildTLBHelper = (start, end, entry, mask, clear) ->
    i = start>>>12
    lend = end>>>12

    if (clear is true) #clear unconditionally or if (entry & 3)? If so, why?
      while i < lend
        @core.memory.t[i] = (i & 0x1ffff) >>> 4
        i++
    else #if (entry & 0x3) #why?
      realAddress = (0x80000000 | (((entry << 6)>>>0) & (mask >>> 1))) >>> 0

      while i < lend
        real = (realAddress + (i << 12) - start) & 0x1fffffff
        @core.memory.t[i] = real >>> 16
        i++
    return

  @buildTLB = (tlb, clear) ->
    #calculate the mapped address range that this TLB entry is mapping
    lowest = (tlb.entryHi & 0xffffff00) >>> 0  #Don't support ASID field
    middle = (lowest + tlb.loCompare) >>> 0
    highest = (lowest + tlb.loCompare * 2) >>> 0

    @buildTLBHelper lowest, middle, tlb.entryLo0, tlb.myHiMask, clear
    @buildTLBHelper middle, highest, tlb.entryLo1, tlb.myHiMask, clear
    return

  @refreshTLB = (tlb, cp0) ->
    @buildTLB tlb, true if tlb.valid is 1 #clear old tlb
    @writeTLBEntry tlb, cp0
    tlb.valid = 0
    tlb.valid = 1 if (cp0[consts.ENTRYLO1] & consts.TLBLO_V) or (cp0[consts.ENTRYLO0] & consts.TLBLO_V)
    @buildTLB tlb if tlb.valid is 1
    return

  @inter_tlbwi = (index, tlb, cp0) ->
    if index < 0 or index > 31
      console.log "ERROR: tlbwi received an invalid index=%08X", index
      return

    @refreshTLB tlb[index], cp0
    return

  @inter_tlbp = (tlb, cp0) ->
    cp0[consts.INDEX] |= 0x80000000 #initially set high-order bit
    idx = 0
    while idx < 31
      if (tlb[idx].entryHi & tlb[idx].myHiMask) is (cp0[consts.ENTRYHI] & tlb[idx].myHiMask)
        if (tlb[idx].entryLo0 & consts.TLBLO_G & tlb[idx].entryLo1) or (tlb[idx].entryHi & consts.TLBHI_PIDMASK) is (cp0[consts.ENTRYHI] & consts.TLBHI_PIDMASK)
          cp0[consts.INDEX] = idx
          break
      idx++
    return

  @inter_tlbr = (tlb, cp0) ->
    index = cp0[consts.INDEX] & 0x7FFFFFFF

    if index < 0 or index > 31
      console.log "ERROR: tlbr received an invalid index=%08X", index
      return

    cp0[consts.PAGEMASK] = tlb[index].pageMask
    cp0[consts.ENTRYHI] = tlb[index].entryHi
    cp0[consts.ENTRYHI] &= (~tlb[index].pageMask >>> 0)
    cp0[consts.ENTRYLO1] = tlb[index].entryLo1
    cp0[consts.ENTRYLO0] = tlb[index].entryLo0
    return
  this

#hack global space until we export classes properly
#node.js uses exports; browser uses this (window)
root = exports ? self
root.C1964jsHelpers = C1964jsHelpers
#print out a hex number
root.dec2hex = (u) ->
  "use strict"
  d = undefined
  h = undefined
  hD = "0123456789ABCDEF"
  d = u
  h = hD.substr(d & 15, 1)
  loop
    d >>= 4
    d &= 0x0fffffff
    h = hD.substr(d & 15, 1) + h
    break unless d > 15
  h
