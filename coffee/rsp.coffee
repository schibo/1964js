class C1964jsRsp
  "use strict"

  constructor: ->
    @instruction = [@special, @stateimm, @j, @jal, @beq, @bne, @blez, @bgtz, @addi, @addiu, @slti, @sltiu, @andi, @ori, @xori, @lui, @cop0, @reserved, @cop2, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @lb, @lh, @reserved, @lw, @lbu, @lhu, @reserved, @reserved, @sb, @sh, @reserved, @sw, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @lwc2, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @reserved, @swc2, @reserved, @reserved, @reserved, @reserved, @reserved]
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
    return

  stateimm: (i) ->
    return

  cop0: (i) ->
    return

  cop2: (i) ->
    return

  vectop: (i) ->
    return


  # opcodes

  j: (i) ->
    return

  jal: (i) ->
    return

  beq: (i) ->
    return

  bne: (i) ->
    return

  blez: (i) ->
    return

  bgtz: (i) ->
    return

  addi: (i) ->
    return

  addiu: (i) ->
    return

  slti: (i) ->
    return

  sltiu: (i) ->
    return

  andi: (i) ->
    return

  ori: (i) ->
    return

  xori: (i) ->
    return

  lui: (i) ->
    return

  lb: (i) ->
    return

  lh: (i) ->
    return

  lw: (i) ->
    return

  lbu: (i) ->
    return

  lhu: (i) ->
    return

  sb: (i) ->
    return

  sh: (i) ->
    return

  sw: (i) ->
    return

  lwc2: (i) ->
    return

  swc2: (i) ->
    return

  sll: (i) ->
    return

  srl: (i) ->
    return

  sra: (i) ->
    return

  sllv: (i) ->
    return

  srlv: (i) ->
    return

  srav: (i) ->
    return

  jr: (i) ->
    return

  jalr: (i) ->
    return

  _break: (i) ->
    return

  add: (i) ->
    return

  addu: (i) ->
    return

  sub: (i) ->
    return

  subu: (i) ->
    return

  _and: (i) ->
    return

  _or: (i) ->
    return

  xor: (i) ->
    return

  nor: (i) ->
    return

  slt: (i) ->
    return

  sltu: (i) ->
    return

  bltz: (i) ->
    return

  bgez: (i) ->
    return

  bltzal: (i) ->
    return

  bgezal: (i) ->
    return

  mfc0: (i) ->
    return

  mtc0: (i) ->
    return

  mfc2: (i) ->
    return

  cfc2: (i) ->
    return

  mtc2: (i) ->
    return

  ctc2: (i) ->
    return

  vmulf: (i) ->
    return

  vmulu: (i) ->
    return

  vrndp: (i) ->
    return

  vmulq: (i) ->
    return

  vmudl: (i) ->
    return

  vmudm: (i) ->
    return

  vmudn: (i) ->
    return

  vmudh: (i) ->
    return

  vmacf: (i) ->
    return

  vmacu: (i) ->
    return

  vrndn: (i) ->
    return

  vmacq: (i) ->
    return

  vmadl: (i) ->
    return

  vmadm: (i) ->
    return

  vmadn: (i) ->
    return

  vmadh: (i) ->
    return

  vadd: (i) ->
    return

  vsub: (i) ->
    return

  vabs: (i) ->
    return

  vaddc: (i) ->
    return

  vsubc: (i) ->
    return

  vsaw: (i) ->
    return

  vlt: (i) ->
    return

  veq: (i) ->
    return

  vne: (i) ->
    return

  vge: (i) ->
    return

  vcl: (i) ->
    return

  vch: (i) ->
    return

  vcr: (i) ->
    return

  vmrg: (i) ->
    return

  vand: (i) ->
    return

  vnand: (i) ->
    return

  vor: (i) ->
    return

  vnor: (i) ->
    return

  vxor: (i) ->
    return

  vnxor: (i) ->
    return

  vrcp: (i) ->
    return

  vrcpl: (i) ->
    return

  vrcph: (i) ->
    return

  vmov: (i) ->
    return

  vrsq: (i) ->
    return

  vrsql: (i) ->
    return

  vrsqh: (i) ->
    return

  vnoop: (i) ->
    return

  lbv: (i) ->
    return

  lsv: (i) ->
    return

  llv: (i) ->
    return

  ldv: (i) ->
    return

  lqv: (i) ->
    return

  lrv: (i) ->
    return

  lpv: (i) ->
    return

  luv: (i) ->
    return

  lhv: (i) ->
    return

  lfv: (i) ->
    return

  lwv: (i) ->
    return

  ltv: (i) ->
    return

  sbv: (i) ->
    return

  ssv: (i) ->
    return

  slv: (i) ->
    return

  sdv: (i) ->
    return

  sqv: (i) ->
    return

  srv: (i) ->
    return

  spv: (i) ->
    return

  suv: (i) ->
    return

  shv: (i) ->
    return

  sfv: (i) ->
    return

  swv: (i) ->
    return

  stv: (i) ->
    return

#hack global space until we export classes properly
#node.js uses exports; browser uses this (window)
root = exports ? this
root.C1964jsRsp = C1964jsRsp