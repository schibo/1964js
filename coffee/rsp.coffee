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
class C1964jsRsp
  "use strict"

  constructor: (helpers, ram, spMem, writeToDom, core) ->
    @core = core
    @kk = 0
    @ram = ram
    @spDmem = spMem
    # spImem is &spDmem[0x1000 (bytes)]
    @helpers = helpers
    @p = new Int32Array(1)
    @p[0] = 0 # 0x04001000
    @writeToDom = writeToDom
    if writeToDom is true
      @code = window
    else
      @code = {}

    @m = new Int32Array(1)
    @m[0] = 0
    @cnt = 0

    # registers
    @gpr = new ArrayBuffer 35*4 # 32GPRs, 1 dummy location to catch attempts to write to r0, and 1 lo and 1 hi
    @r = new Int32Array @gpr
    @ru = new Uint32Array @gpr
    @flag = new Int16Array 4
    @vectors = []
    for k in [0...32]
      @vectors.push new ArrayBuffer 128
    @accum = []
    for k in [0...8]
      @accum.push new ArrayBuffer 128
    @pcDelay = 0
    @delay = 0
    @halt = 0
    @offset = 0

    @stopCompiling = false
    @spDmemDmaAddress = 0
    @ramDmaAddress = 0

    @CPU_instruction = [@special, @regimm, @j, @jal, @beq, @bne, @blez, @bgtz, @addi, @addiu, @slti, @sltiu, @andi, @ori, @xori, @lui, @cop0, @reserved, @cop2, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @lb, @lh, @reserved, @lw, @lbu, @lhu, @reserved, @reserved, @sb, @sh, @reserved, @sw, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @lwc2, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @swc2, @reserved, @reserved, @reserved, @reserved, @reserved]
    @special_map = [@sll, @reserved, @srl, @sra, @sllv, @reserved, @srlv, @srav, @jr, @jalr, @reserved, @reserved, @reserved, @_break, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @add, @addu, @sub, @subu, @_and, @_or, @xor, @nor, @reserved, @reserved, @slt, @sltu, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved]
    @regimm_map = [@bltz, @bgez, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @bltzal, @bgezal, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved]
    @cop0_map = [@mfc0, @reserved, @reserved, @reserved, @mtc0, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved]
    @cop2_map = [@mfc2, @reserved, @cfc2, @reserved, @mtc2, @reserved, @ctc2, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @vectop, @vectop, @vectop, @vectop, @vectop, @vectop, @vectop, @vectop, @vectop, @vectop, @vectop, @vectop, @vectop, @vectop, @vectop, @vectop]
    @vectop_map = [@vmulf, @vmulu, @vrndp, @vmulq, @vmudl, @vmudm, @vmudn, @vmudh, @vmacf, @vmacu, @vrndn, @vmacq, @vmadl, @vmadm, @vmadn, @vmadh, @vadd, @vsub, @reserved, @vabs, @vaddc, @vsubc, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @vsaw, @reserved, @reserved, @vlt, @veq, @vne, @vge, @vcl, @vch, @vcr, @vmrg, @vand, @vnand, @vor, @vnor, @vxor, @vnxor, @reserved, @reserved, @vrcp, @vrcpl, @vrcph, @vmov, @vrsq, @vrsql, @vrsqh, @vnoop, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved]
    @lwc2_map = [@lbv, @lsv, @llv, @ldv, @lqv, @lrv, @lpv, @luv, @lhv, @lfv, @lwv, @ltv, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved]
    @swc2_map = [@sbv, @ssv, @slv, @sdv, @sqv, @srv, @spv, @suv, @shv, @sfv, @swv, @stv, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved]
    return

  # opcode callers

  special: (i) ->
    @special_map[@helpers.fn(i)].call @, i

  regimm: (i) ->
    @regimm_map[@helpers.rt(i)].call @, i

  cop0: (i) ->
    @cop0_map[@helpers.rs(i)].call @, i

  cop2: (i) ->
    @cop2_map[@helpers.rs(i)].call @, i

  vectop: (i) ->
    @vectop_map[@helpers.fn(i)].call @, i    

  lwc2: (i) ->
    @lwc2_map[@helpers.rd(i)].call @, i

  swc2: (i) ->
    @swc2_map[@helpers.rd(i)].call @, i

  reserved: (i) ->
    "/*reserved*/"

  # opcodes

  j: (i) ->
    @stopCompiling = true
    instr_index = @targetPC i
    pc = (@p[0] + @offset + 4) | 0
    instruction = @loadInstruction(pc)
    string = "{" + @CPU_instruction[instruction >> 26 & 0x3f].call(@, instruction, true)
    c=@cnt+1
    string += "t.m[0]+="+c+";t.p[0]=" + instr_index + ";return t.code." + @getFnName(instr_index) + "}"

  jal: (i) ->
    @stopCompiling = true
    instr_index = @targetPC i
    pc = (@p[0] + @offset + 4) | 0
    instruction = @loadInstruction(pc)
    string = "{" + @CPU_instruction[instruction >> 26 & 0x3f].call(@, instruction, true)
    c=@cnt+1
    pc = (@p[0] + @offset + 8) | 0
    string += "t.m[0]+=" + c + ";"
    string += "t.p[0]=" + instr_index + ";r[31]=" + pc + ";return t.code." + @getFnName(instr_index) + "}"

  jr: (i) ->
    @stopCompiling = true
    string = "{var temp=" + @helpers.RS(i) + "&0x0fff;"

    #delay slot
    instruction = @loadInstruction((@p[0] + @offset + 4) | 0)
    opcode = @CPU_instruction[instruction >> 26 & 0x3f].call(@, instruction, true)
    string += opcode
    string += "t.m[0]+=" + (@cnt+1) + ";"

    string += "t.p[0]=temp;return t.code['_r'+(temp>>>2)]}"


  jalr: (i) ->
    @stopCompiling = true
    string = "{var temp=" + @helpers.RS(i) + "&0x0fff;"
    link = (@p[0] + @offset + 8) >> 0
    string += @helpers.tRD(i) + "=" + link + ";"

    #delay slot
    instruction = @loadInstruction((@p[0] + @offset + 4) | 0)
    opcode = @CPU_instruction[instruction >> 26 & 0x3f].call(@, instruction, true)
    string += opcode
    string += "t.m[0]+=" + (@cnt+1) + ";"
    string += "t.p[0]=temp;return t.code['_r'+(temp>>>2)]}"

  _break: (i) ->
    @stopCompiling = true
    "t.halt=1;"

  beq: (i) ->
    @stopCompiling = true
    "if(" + @helpers.RS(i) + "===" + @helpers.RT(i) + "){" + @delaySlot i

  bne: (i) ->
    @stopCompiling = true
    "if(" + @helpers.RS(i) + "!==" + @helpers.RT(i) + "){" + @delaySlot i

  blez: (i) ->
    @stopCompiling = true
    "if(" + @helpers.RS(i) + "<=0){" + @delaySlot i

  bgtz: (i) ->
    @stopCompiling = true
    "if(" + @helpers.RS(i) + ">0){" + @delaySlot i

  bltz: (i) ->
    @stopCompiling = true
    "if(" + @helpers.RS(i) + "<0){" + @delaySlot i

  bgez: (i) ->
    @stopCompiling = true
    "if(" + @helpers.RS(i) + ">=0){" + @delaySlot i

  bltzal: (i) ->
    @stopCompiling = true
    link = (@p[0] + offset + 8) >> 0
    "if(" + @helpers.RS(i) + "<0){" + "r[31]=" + link + ";" + @delaySlot(i, false)

  bgezal: (i) ->
    @stopCompiling = true
    link = (@p[0] + offset + 8) >> 0
    "if(" + @helpers.RS(i) + ">=0){" + "r[31]=" + link + ";" + @delaySlot(i, false)

  addi: (i) ->
    @helpers.tRT(i) + "=" + @helpers.RS(i) + "+" + @helpers.soffset_imm(i) + ";"

  addiu: (i) ->
    @helpers.tRT(i) + "=" + @helpers.RS(i) + "+" + @helpers.soffset_imm(i) + ";"

  slti: (i) ->
    uoffset_imm_lo = undefined
    uoffset_imm_lo = (@helpers.soffset_imm(i)) >>> 0
    "{if(" + @helpers.RS(i) + "<" + uoffset_imm_lo + ")" + @helpers.tRT(i) + "=1;" + "else " + @helpers.tRT(i) + "=0}"

  sltiu: (i) ->
    uoffset_imm_lo = undefined
    uoffset_imm_lo = (@helpers.soffset_imm(i)) >>> 0
    "{if(" + @helpers.uRS(i) + "<" + uoffset_imm_lo + ")" + @helpers.tRT(i) + "=1;" + "else " + @helpers.tRT(i) + "=0}"

  andi: (i) ->
    @helpers.tRT(i) + "=" + @helpers.RS(i) + "&" + @helpers.offset_imm(i) + ";"

  ori: (i) ->
    @helpers.tRT(i) + "=" + @helpers.RS(i) + "|" + @helpers.offset_imm(i) + ";"

  xori: (i) ->
    @helpers.tRT(i) + "=" + @helpers.RS(i) + "^" + @helpers.offset_imm(i) + ";"

  lui: (i) ->
    temp = ((i & 0x0000ffff) << 16)
    @helpers.tRT(i) + "=" + temp + ";"

  lb: (i) ->
    string = "{var a=((" + @helpers.RS(i) + "+" + @helpers.soffset_imm(i) + ")&0xfff);"
    string += @helpers.tRT(i) + "=t.spDmem[a]<<24>>24}"

  lh: (i) ->
    string = "{var a=((" + @helpers.RS(i) + "+" + @helpers.soffset_imm(i) + ")&0xfff);"
    string += @helpers.tRT(i) + "=(t.spDmem[a]<<8 | t.spDmem[a+1])<<16>>16}"

  lw: (i) ->
    string = "{var a=((" + @helpers.RS(i) + "+" + @helpers.soffset_imm(i) + ")&0xfff);"
    string += @helpers.tRT(i) + "=(t.spDmem[a]<<24 | t.spDmem[a+1]<<16 | t.spDmem[a+2]<<8 | t.spDmem[a+3])}"

  lbu: (i) ->
    string = "{var a=((" + @helpers.RS(i) + "+" + @helpers.soffset_imm(i) + ")&0xfff);"
    string += @helpers.tRT(i) + "=t.spDmem[a]&0x000000ff}"

  lhu: (i) ->
    string = "{var a=((" + @helpers.RS(i) + "+" + @helpers.soffset_imm(i) + ")&0xfff);"
    string += @helpers.tRT(i) + "=(t.spDmem[a]<<8 | t.spDmem[a+1])&0x0000ffff}"

  sb: (i) ->
    string = "{var a=((" + @helpers.RS(i) + "+" + @helpers.soffset_imm(i) + ")&0xfff);"
    string += "t.spDmem[a]=" + @helpers.RT(i) + "}"

  sh: (i) ->
    string = "{var a=((" + @helpers.RS(i) + "+" + @helpers.soffset_imm(i) + ")&0xfff);"
    string += "var b =" + @helpers.RT(i) + ";" 
    string += "t.spDmem[a]=b>>>8;t.spDmem[a+1]=b}"

  sw: (i) ->
    string = "{var a=((" + @helpers.RS(i) + "+" + @helpers.soffset_imm(i) + ")&0xfff);"
    string += "var b=" + @helpers.RT(i) + ";" 
    string += "t.spDmem[a]=b>>>24;t.spDmem[a+1]=b>>>16;t.spDmem[a+2]=b>>>8;t.spDmem[a+3]=b}"

  sll: (i) ->
    return ""  if (i & 0x001FFFFF) is 0 # NOP
    @helpers.tRD(i) + "=" + @helpers.RT(i) + "<<" + @helpers.sa(i) + ";"

  srl: (i) ->
    @helpers.tRD(i) + "=" + @helpers.RT(i) + ">>>" + @helpers.sa(i) + ";"

  sra: (i) ->
    @helpers.tRD(i) + "=" + @helpers.RT(i) + ">>" + @helpers.sa(i) + ";"

  sllv: (i) ->
    @helpers.tRD(i) + "=" + @helpers.RT(i) + "<<(" + @helpers.RS(i) + "&0x1f);"

  srlv: (i) ->
    @helpers.tRD(i) + "=" + @helpers.RT(i) + ">>>(" + @helpers.RS(i) + "&0x1f);"

  srav: (i) ->
    @helpers.tRD(i) + "=" + @helpers.RT(i) + ">>(" + @helpers.RS(i) + "&0x1f);"

  add: (i) ->
    @helpers.sLogic32 i, "+"

  addu: (i) ->
    @helpers.sLogic32 i, "+"

  sub: (i) ->
    @helpers.sLogic32 i, "-"

  subu: (i) ->
    @helpers.sLogic32 i, "-"

  _and: (i) ->
    @helpers.sLogic32 i, "&"

  _or: (i) ->
    @helpers.sLogic32 i, "|"

  xor: (i) ->
    @helpers.sLogic32 i, "^"

  nor: (i) ->
    @helpers.tRD(i) + "=~(" + @helpers.RS(i) + "|" + @helpers.RT(i) + ");"

  slt: (i) ->
    "{if(" + @helpers.RS(i) + "<" + @helpers.RT(i) + ")" + @helpers.tRD(i) + "=1;" + "else " + @helpers.tRD(i) + "=0}"

  sltu: (i) ->
    "{if(" + @helpers.uRS(i) + "<" + @helpers.uRT(i) + ")" + @helpers.tRD(i) + "=1;" + "else " + @helpers.tRD(i) + "=0}"

  mfc0: (i) ->
    switch @helpers.rd(i)
      when 8 # DPC_START_REG
        return @helpers.tRT(i) + "=t.loadFromSpDmem(t, " + (8*4).toString() + ");"
      when 9 # DPC_END_REG
        return @helpers.tRT(i) + "=t.loadFromSpDmem(t, " + (9*4).toString() + ");"
      when 10 # DPC_START_REG
        return @helpers.tRT(i) + "=t.loadFromSpDmem(t, " + (10*4).toString() + ");"
      when 11 # DPC_STATUS_REG
        return @helpers.tRT(i) + "=0;"
      when 12 # DPC_STATUS_REG
        return @helpers.tRT(i) + "=t.loadFromSpDmem(t, " + (12*4).toString() + ");"
    #@helpers.tRT(i) + "=t.loadFromSpDmem(t, " + (@helpers.rd(i)*4).toString() + ");"
    @helpers.tRT(i) + "=0;"

  mtc0: (i) ->
    switch @helpers.rd(i)
      when 0 # SP_DMEM_ADDR_REG
        return "t.spDmemDmaAddress=" + @helpers.RT(i) + ";"
      when 1 # SP_DRAM_ADDR_REG
        return "t.ramDmaAddress=" + @helpers.RT(i) + ";"
      when 2 # Read RDRAM
        return "t.dmaRead(" + @helpers.RT(i) + ");"
      when 3 # write RDRAM
        return "t.dmaWrite(" + @helpers.RT(i) + ");"
    ""

  mfc2: (i) ->
    "/*mfc2*/"

  cfc2: (i) ->
    "/*cfc2*/"

  mtc2: (i) ->
    "/*mtc2*/"

  ctc2: (i) ->
    "/*ctc2*/"

  vmulf: (i) ->
    "/*vmulf*/"

  vmulu: (i) ->
    "/*vmulu*/"

  vrndp: (i) ->
    "/*vrndp*/"

  vmulq: (i) ->
    "/*vmulq*/"

  vmudl: (i) ->
    "/*vmudl*/"

  vmudm: (i) ->
    "/*vmudm*/"

  vmudn: (i) ->
    "/*vmudn*/"

  vmudh: (i) ->
    "/*vmudh*/"

  vmacf: (i) ->
    "/*vmacf*/"

  vmacu: (i) ->
    "/*vmacu*/"

  vrndn: (i) ->
    "/*vrndn*/"

  vmacq: (i) ->
    "/*vmacq*/"

  vmadl: (i) ->
    "/*vmadl*/"

  vmadm: (i) ->
    "/*vmadm*/"

  vmadn: (i) ->
    "/*vmadn*/"

  vmadh: (i) ->
    "/*vmadh*/"

  vadd: (i) ->
    "/*vadd*/"

  vsub: (i) ->
    "/*vsub*/"

  vabs: (i) ->
    "/*vabs*/"

  vaddc: (i) ->
    "/*vaddc*/"

  vsubc: (i) ->
    "/*vsubc*/"

  vsaw: (i) ->
    "/*vsaw*/"

  vlt: (i) ->
    "/*vlt*/"

  veq: (i) ->
    "/*veq*/"

  vne: (i) ->
    "/*vne*/"

  vge: (i) ->
    "/*vge*/"

  vcl: (i) ->
    "/*vcl*/"

  vch: (i) ->
    "/*vch*/"

  vcr: (i) ->
    "/*vcr*/"

  vmrg: (i) ->
    "/*vmrg*/"

  vand: (i) ->
    "/*vand*/"

  vnand: (i) ->
    "/*vnand*/"

  vor: (i) ->
    "/*vor*/"

  vnor: (i) ->
    "/*vnor*/"

  vxor: (i) ->
    "/*vxor*/"

  vnxor: (i) ->
    "/*vxnor*/"

  vrcp: (i) ->
    "/*vrcp*/"

  vrcpl: (i) ->
    "/*vrcpl*/"

  vrcph: (i) ->
    "/*vrcph*/"

  vmov: (i) ->
    "/*vmov*/"

  vrsq: (i) ->
    "/*vrsq*/"

  vrsql: (i) ->
    "/*vrsql*/"

  vrsqh: (i) ->
    "/*vrsqh*/"

  vnoop: (i) ->
    "/*vnoop*/"

  lbv: (i) ->
    "/*lbv*/"

  lsv: (i) ->
    "/*lsv*/"

  llv: (i) ->
    "/*llv*/"

  ldv: (i) ->
    "/*ldv*/"

  lqv: (i) ->
    "/*lqv*/"

  lrv: (i) ->
    "/*lrv*/"

  lpv: (i) ->
    "/*lpv*/"

  luv: (i) ->
    "/*luv*/"

  lhv: (i) ->
    "/*lhv*/"

  lfv: (i) ->
    "/*lfv*/"

  lwv: (i) ->
    "/*lwv*/"

  ltv: (i) ->
    "/*ltv*/"

  sbv: (i) ->
    "/*sbv*/"

  ssv: (i) ->
    "/*ssv*/"

  slv: (i) ->
    "/*slv*/"

  sdv: (i) ->
    "/*sdv*/"

  sqv: (i) ->
    "/*sqv*/"

  srv: (i) ->
    "/*srv*/"

  spv: (i) ->
    "/*spv*/"

  suv: (i) ->
    "/*suv*/"

  shv: (i) ->
    "/*shv*/"

  sfv: (i) ->
    "/*sfv*/"

  swv: (i) ->
    "/*swv*/"

  stv: (i) ->
    "/*stv*/"

  dmaWrite: (length) ->
    rdramOffset = @ramDmaAddress & 0x00FFFFFF
    spOffset = @spDmemDmaAddress & 0x0000FFFF
    length += 1

    # safety check the copy
    return if ((spOffset >= 0x2000) or (rdramOffset >= 0x00800000))
    length = (0x2000 - spOffset) if ((spOffset + length) > 0x2000)
    length = (0x00800000 - rdramOffset) if ((rdramOffset + length) > 0x00800000) 
    for k in [0...length]
      @ram[k+rdramOffset] = @spDmem[k+spOffset] 
    return

  dmaRead: (length) ->
    rdramOffset = @ramDmaAddress & 0x00FFFFFF
    spOffset = @spDmemDmaAddress & 0x0000FFFF
    length += 1

    # safety check the copy
    # TODO - this should use the real rdram size and not assume expansion pak
    return if ((spOffset >= 0x2000) || (rdramOffset >= 0x00800000))
    
    length = (0x2000 - spOffset) if ((spOffset + length) > 0x2000)
    length = (0x00800000 - rdramOffset) if ((rdramOffset + length) > 0x00800000)
    for k in [0...length]
      @spDmem[k+spOffset] = @ram[k+rdramOffset] 

    @core.flushRspDynaCache @ #if (spOffset + length) >= 0x1000 # if in IMEM, flush dyna
    return

  targetPC: (i) ->
    ((i & 0x03FF) << 2) | 0
    
  getFnName: (pc) ->
    "_r" + (pc >>> 2)

  wrapEval: (string) ->
    eval string
  
  delaySlot: (i) ->
    delayPC = (@p[0] + @offset + 4) | 0
    instruction = @loadInstruction(delayPC)
    opcode = @CPU_instruction[instruction >> 26 & 0x3f].call(@, instruction, true)
    c=@cnt+1

    #speed hack
    if instruction is 0 and @helpers.soffset_imm(i) is -1
      opcode += "t.m[0]=2000000;"
    else
      opcode += "t.m[0]+=" + c + ";"

    retPC = (@p[0] + @offset + 4 + (@helpers.soffset_imm(i) << 2)) | 0
    opcode + "t.p[0]=" + retPC + ";return t.code." + @getFnName(retPC) + "}"


  runLoop: ->
    @m[0] = 0
    @halt = 0
    @p[0] = (@core.memory.getInt32 @core.memory.spReg2Uint8Array, consts.SP_PC_REG) & 0xffc

    while @halt is 0 and @m[0] < 100000
      fnName = "_r" + (@p[0] >>> 2)

      #this is broken-up so that we can process more interrupts. If we freeze,
      #we probably need to split this up more.
      try
        fn = @code[fnName]
        @run fn, @r, @ru
      catch e
        #so, we really need to know what type of exception this is,
        #but right now, we're assuming that we need to compile a block due to
        #an attempt to call an undefined function. Are there standard exception types
        #in javascript?
        if e instanceof TypeError
          fn = @decompileBlock @p[0]
          fn = fn @r, @ru, @
        else
          throw e
    return

  run: (fn, r, ru) ->
    while @halt is 0 and @m[0] < 100000
      fn = fn r, ru, @
    return

  loadInstruction: (addr) ->
    a = (addr & 0xfff) + 0x1000 # load from SP_IMEM. IMEM is 0x1000 offset into SP_DMEM
    (@spDmem[a] << 24 | @spDmem[a+1] << 16 | @spDmem[a+2] << 8 | @spDmem[a+3])>>>0

  loadFromSpDmem: (t, offset) ->
    (t.spDmem[offset] << 24 | t.spDmem[offset+1] << 16 | t.spDmem[offset+2] << 8 | t.spDmem[offset+3])>>>0

  decompileBlock: (pc) ->
    @offset = 0 # imem is 0x1000 bytes into dmem
    g = undefined
    s = undefined
    @cnt = 0
    instruction = undefined
    string = undefined
    fnName = "_r" + (pc >>> 2) # underscore r for rsp

    #Syntax: function(register, hiRegister, this.memory, this)
    if @writeToDom is true
      string = "function " + fnName + "(r, ru, t){"
    else
      string = "i1964js.code." + fnName + "=function(r, ru, t){"
    until @stopCompiling
      instruction = @loadInstruction(pc + @offset)
      @cnt += 1
      string += @CPU_instruction[instruction >> 26 & 0x3f].call(@, instruction)
      @offset += 4
      throw Error "too many instructions! bailing."  if @offset > 10000
    @stopCompiling = false

    #close out the function
    string += "t.m[0]+=" + @cnt + ";"
    string += "t.p[0]=" + ((pc + @offset) >> 0)
    string += ";return t.code." + @getFnName((pc + @offset) >> 0) + "}"
    if @writeToDom is true
      g = document.createElement("script")
      g.className = "rsp"
      s = document.getElementsByTagName("script")[@kk]
      @kk += 1
      s.parentNode.insertBefore g, s
      g.text = string
    else
      @wrapEval string
    @code[fnName]

#hack global space until we export classes properly
#node.js uses exports; browser uses this (window)
root = exports ? this
root.C1964jsRsp = C1964jsRsp