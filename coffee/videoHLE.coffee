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
#jslint todo: true, bitwise: true

#globals window, mat4, C1964jsRenderer, consts, dec2hex, Float32Array
C1964jsVideoHLE = (core, glx) ->
  "use strict"

  @processDisplayList = @callBind @processDisplayList, this

  i = undefined
  @core = core #only needed for gfxHelpers prototypes to access.
  @gl = glx

  #todo: make gRSP a class object.
  @RICE_MATRIX_STACK = 60
  @MAX_TEXTURES = 8
  @MAX_VERTICES = 80
  @MAX_TILES = 8
  @tmem = new Uint8Array(1024 * 4)
  @activeTile = 0
  @textureTile = []
  @N64VertexList = []
  @vtxTransformed = []
  @vtxNonTransformed = []
  @vecProjected = []
  @vtxProjected5 = []
  @geometryMode = 0
  @gRSP = {}
  @gRSPlights = [{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{}]
  @gRSPn64lights = [{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{}]
  @gRSPnumLights = 0
  @matToLoad = mat4.create()
  @lightingMat = mat4.create()
  @gRSPworldProject = mat4.create()
  @triangleVertexPositionBuffer = `undefined`
  @triangleVertexColorBuffer = `undefined`
  @dlistStackPointer = 0
  @dlistStack = []
  @renderer = new C1964jsRenderer(@core.settings, @core.webGL.gl, @core.webGL)
  @texImg = {}
  @segments = []
  @primColor = []
  @fillColor = []
  @blendColor = []
  @envColor = []
  @triVertices = new Float32Array(16384)
  @triColorVertices = new Uint8Array(16384)
  @triTextureCoords = new Float32Array(16384)
  @otherModeL = 0x00500001
  @otherModeH = 0
  @cycleType = 0
  @alphaTestEnabled = 0
  @bShade = false
  @bTextureGen = false
  @bLightingEnable = false
  @bFogEnable = false
  @bZBufferEnable = false

  @normalMat = mat4.create()
  @transformed = mat4.create()
  @nonTransformed = mat4.create()


  #todo: different microcodes support
  @currentMicrocodeMap = @microcodeMap0
  i = 0
  while i < @MAX_TILES
    @textureTile[i] = []
    i += 1
  i = 0
  while i < @MAX_VERTICES
    @N64VertexList[i] = {}
    i += 1
  i = 0
  while i < consts.MAX_DL_STACK_SIZE
    @dlistStack[i] = {}
    i += 1
  i = 0
  while i < @segments.length
    @segments[i] = 0
    i += 1
  @gRSP.projectionMtxs = []
  @gRSP.modelviewMtxs = []
  @gRSP.ambientLightIndex = 0
  @gRSP.ambientLightColor = 0
  @gRSP.fAmbientLightA = 0
  @gRSP.fAmbientLightR = 0
  @gRSP.fAmbientLightG = 0
  @gRSP.fAmbientLightB = 0


  #todo: allocate on-demand
  i = 0
  while i < @RICE_MATRIX_STACK
    @gRSP.projectionMtxs[i] = mat4.create()
    @gRSP.modelviewMtxs[i] = mat4.create()
    i += 1
  @gRSP.vertexMult = 10
  @triangleVertexTextureCoordBuffer = `undefined`
  return this

(->
  "use strict"

  C1964jsVideoHLE::callBind = (fn, me) ->
    ->
      fn.call me

  C1964jsVideoHLE::processDisplayList = ->
    if @core.showFB is true
      @initBuffers()
      @core.webGL.show3D()
      @core.showFB = false
      @resetState()

    @core.webGL.beginDList()
    @dlParserProcess()

    #this.core.interrupts.triggerDPInterrupt(0, false);
    @core.interrupts.triggerSPInterrupt 0, false

  C1964jsVideoHLE::videoLog = (msg) ->
    #console.log msg
    return

  C1964jsVideoHLE::dlParserProcess = ->
    @dlistStackPointer = 0


    @dlistStack[@dlistStackPointer].pc = (@core.memory.spMemUint8Array[consts.TASK_DATA_PTR] << 24 | @core.memory.spMemUint8Array[consts.TASK_DATA_PTR + 1] << 16 | @core.memory.spMemUint8Array[consts.TASK_DATA_PTR + 2] << 8 | @core.memory.spMemUint8Array[consts.TASK_DATA_PTR + 3])>>>0
    @dlistStack[@dlistStackPointer].countdown = consts.MAX_DL_COUNT

    #see RSP_Parser.cpp
    #TODO: purge old textures
    #TODO: stats
    #TODO: force screen clear
    #TODO: set vi scales
    @renderReset()

    #TODO: render reset
    #TODO: begin rendering
    #TODO: set viewport
    #TODO: set fill mode
    while @dlistStackPointer >= 0
      pc = @dlistStack[@dlistStackPointer].pc
      cmd = @getCommand(pc)
      func = @currentMicrocodeMap[cmd]
      @dlistStack[@dlistStackPointer].pc += 8
      this[func] pc
      if @dlistStackPointer >= 0
        @dlistStack[@dlistStackPointer].countdown -= 1
        @dlistStackPointer -= 1  if @dlistStack[@dlistStackPointer].countdown < 0
    #@videoLog "finished dlist"
    @core.interrupts.triggerSPInterrupt 0, false
    return

  #TODO: end rendering
  C1964jsVideoHLE::RDP_GFX_PopDL = ->
    @dlistStackPointer -= 1
    return

  C1964jsVideoHLE::RSP_RDP_Nothing = (pc) ->
    #@videoLog "RSP RDP NOTHING"
    @dlistStackPointer -= 1
    return

  C1964jsVideoHLE::RSP_GBI1_MoveMem = (pc) ->
    addr = undefined
    length = undefined
    type = @getGbi1Type(pc)
    length = @getGbi1Length(pc)
    addr = @getGbi1RspSegmentAddr(pc)
    switch type
      when consts.RSP_GBI1_MV_MEM_VIEWPORT
        @RSP_MoveMemViewport addr
      #case RSP_GBI1_MV_MEM_LOOKATY:
      #break;
      #case RSP_GBI1_MV_MEM_LOOKATX:
      #break;
      when consts.RSP_GBI1_MV_MEM_L0, consts.RSP_GBI1_MV_MEM_L1, consts.RSP_GBI1_MV_MEM_L2, consts.RSP_GBI1_MV_MEM_L3, consts.RSP_GBI1_MV_MEM_L4, consts.RSP_GBI1_MV_MEM_L5, consts.RSP_GBI1_MV_MEM_L6, consts.RSP_GBI1_MV_MEM_L7
        dwLight = (type-consts.RSP_GBI1_MV_MEM_L0)/2
        @RSP_MoveMemLight dwLight, addr
    return

  C1964jsVideoHLE::RSP_MoveMemViewport = (addr) ->
    #todo
    return

  C1964jsVideoHLE::RSP_GBI1_SpNoop = (pc) ->
    #@videoLog "RSP_GBI1_SpNoop"
    return

  C1964jsVideoHLE::RSP_GBI1_Reserved = (pc) ->
    #@videoLog "RSP_GBI1_Reserved"
    return

  C1964jsVideoHLE::setProjection = (mat, bPush, bReplace) ->
    if bPush is true
      if @gRSP.projectionMtxTop >= (@RICE_MATRIX_STACK - 1)
        @gRSP.bMatrixIsUpdated = true
        return

      @gRSP.projectionMtxTop += 1
      if bReplace

        # Load projection matrix
        mat4.set mat, @gRSP.projectionMtxs[@gRSP.projectionMtxTop]
      else
        mat4.multiply @gRSP.projectionMtxs[@gRSP.projectionMtxTop - 1], mat, @gRSP.projectionMtxs[@gRSP.projectionMtxTop]
    else
      if bReplace

        # Load projection matrix
        mat4.set mat, @gRSP.projectionMtxs[@gRSP.projectionMtxTop]
      else
        mat4.multiply @gRSP.projectionMtxs[@gRSP.projectionMtxTop], mat, @gRSP.projectionMtxs[@gRSP.projectionMtxTop]
    @gRSP.bMatrixIsUpdated = true
    return

  C1964jsVideoHLE::setWorldView = (mat, bPush, bReplace) ->
    if bPush is true
      if @gRSP.modelViewMtxTop >= (@RICE_MATRIX_STACK - 1)
        @gRSP.bMatrixIsUpdated = true
        return

      @gRSP.modelViewMtxTop += 1
      # We should store the current projection matrix...
      if bReplace

        # Load projection matrix
        mat4.set mat, @gRSP.modelviewMtxs[@gRSP.modelViewMtxTop]
      else # Multiply projection matrix
        mat4.multiply @gRSP.modelviewMtxs[@gRSP.modelViewMtxTop - 1], mat, @gRSP.modelviewMtxs[@gRSP.modelViewMtxTop]

    #  this.gRSP.modelviewMtxs[this.gRSP.modelViewMtxTop] = mat * this.gRSP.modelviewMtxs[this.gRSP.modelViewMtxTop-1];
    else # NoPush
      if bReplace

        # Load projection matrix
        mat4.set mat, @gRSP.modelviewMtxs[@gRSP.modelViewMtxTop]
      else

        # Multiply projection matrix
        mat4.multiply @gRSP.modelviewMtxs[@gRSP.modelViewMtxTop], mat, @gRSP.modelviewMtxs[@gRSP.modelViewMtxTop]

    #this.gRSP.modelviewMtxs[this.gRSP.modelViewMtxTop] = mat * this.gRSP.modelviewMtxs[this.gRSP.modelViewMtxTop];

    #gRSPmodelViewTop = this.gRSP.modelviewMtxs[this.gRSP.modelViewMtxTop];
    @gRSP.bMatrixIsUpdated = true
    return

  C1964jsVideoHLE::RSP_GBI0_Mtx = (pc) ->
    addr = undefined
    seg = @getGbi0DlistAddr(pc)
    addr = @getRspSegmentAddr(seg)
    #@videoLog "RSP_GBI0_Mtx addr: " + dec2hex(addr)
    @loadMatrix addr
    if @gbi0isProjectionMatrix(pc)
      @setProjection @matToLoad, @gbi0PushMatrix(pc), @gbi0LoadMatrix(pc)
    else
      @setWorldView @matToLoad, @gbi0PushMatrix(pc), @gbi0LoadMatrix(pc)
    return

  C1964jsVideoHLE::loadMatrix = (addr) ->
    #  todo: port and probably log warning message if true
    #    if (addr + 64 > g_dwRamSize)
    #    {
    #        return;
    #    }
    i = undefined
    j = undefined
    lo = undefined
    hi = undefined
    a = undefined
    k = 0
    i = 0
    while i < 4
      j = 0
      while j < 4
        a = addr + (i << 3) + (j << 1)
        hi = (@core.memory.rdramUint8Array[a] << 8 | @core.memory.rdramUint8Array[a + 1]) & 0x0000FFFF
        lo = (@core.memory.rdramUint8Array[a + 32] << 8 | @core.memory.rdramUint8Array[a + 32 + 1]) & 0x0000FFFF
        @matToLoad[k] = ((hi << 16) | lo) / 65536.0
        k += 1
        j += 1
      i += 1
    return

  #tile info.
  C1964jsVideoHLE::DLParser_SetTImg = (pc) ->
    @texImg.format = @getTImgFormat(pc)
    @texImg.size = @getTImgSize(pc)
    @texImg.width = @getTImgWidth(pc) + 1
    @texImg.addr = @getTImgAddr(pc)
    @texImg.bpl = @texImg.width << @texImg.size >> 1
    @texImg.changed = true #no texture cache
    #console.log "SetTImg: Format:"+ @texImg.format + " Size:" + @texImg.size + " Width: "+ @texImg.width
    #@videoLog "TODO: DLParser_SetTImg"
    return

  #this.videoLog('Texture: format=' + this.texImg.format + ' size=' + this.texImg.size + ' ' + 'width=' + this.texImg.width + ' addr=' + this.texImg.addr + ' bpl=' + this.texImg.bpl);

  C1964jsVideoHLE::RSP_GBI0_Vtx = (pc) ->
    v0 = undefined
    seg = undefined
    addr = undefined
    num = @getGbi0NumVertices(pc) + 1
    v0 = @getGbi0Vertex0(pc)
    seg = @getGbi0DlistAddr(pc)
    addr = @getRspSegmentAddr(seg)
    num = 32 - v0  if (v0 + num) > 80

    #TODO: check that address is valid
    @processVertexData addr, v0, num
    return

  C1964jsVideoHLE::updateCombinedMatrix = ->
    return #this is set in the shader
    if @gRSP.bMatrixIsUpdated
      pmtx = undefined
      vmtx = @gRSP.modelviewMtxs[@gRSP.modelViewMtxTop]
      pmtx = @gRSP.projectionMtxs[@gRSP.projectionMtxTop]
      mat4.multiply pmtx, vmtx, @gRSPworldProject

      #this.gRSPworldProject = this.gRSP.modelviewMtxs[this.gRSP.modelViewMtxTop] * this.gRSP.projectionMtxs[this.gRSP.projectionMtxTop];
      @gRSP.bMatrixIsUpdated = false
    return

  C1964jsVideoHLE::processVertexData = (addr, v0, num) ->
    a = undefined
    i = v0
    @updateCombinedMatrix()
    i = v0
    texWidth = @textureTile[@activeTile].width
    texHeight = @textureTile[@activeTile].height
    while i < v0 + num
      a = addr + 16 * (i - v0)

      @N64VertexList[i].x = @getVertexX(a)
      @N64VertexList[i].y = @getVertexY(a)
      @N64VertexList[i].z = @getVertexZ(a)

      @N64VertexList[i].s = @getVertexS(a)/32 / texWidth
      @N64VertexList[i].t = @getVertexT(a)/32 / texHeight

      if @bLightingEnable is true
        @normalMat[0] = @getVertexNormalX(a)
        @normalMat[1] = @getVertexNormalY(a)
        @normalMat[2] = @getVertexNormalZ(a)
        @normalMat[3] = 0
        modelViewtransposedInverse = mat4.create()
        mat4.inverse @gRSP.modelviewMtxs[@gRSP.modelViewMtxTop], modelViewtransposedInverse
        mat4.transpose modelViewtransposedInverse, modelViewtransposedInverse

        #mat4.transpose modelViewtransposedInverse, @normalMat
        @normalMat = vec3.normalize @normalMat
        @normalMat = mat4.multiply modelViewtransposedInverse, @normalMat


        worldViewtransposedInverse = mat4.create()
        mat4.inverse @gRSP.projectionMtxs[@gRSP.projectionMtxTop], worldViewtransposedInverse
        mat4.transpose worldViewtransposedInverse, worldViewtransposedInverse
        @normalMat = mat4.multiply worldViewtransposedInverse, @normalMat



        vertColor = @lightVertex @normalMat
        @N64VertexList[i].r = vertColor[0]
        @N64VertexList[i].g = vertColor[1]
        @N64VertexList[i].b = vertColor[2]
        @N64VertexList[i].a = vertColor[3]
      else if @bShade is false
        @N64VertexList[i].r = @primColor[0] * 255.0
        @N64VertexList[i].g = @primColor[1] * 255.0
        @N64VertexList[i].b = @primColor[2] * 255.0
        @N64VertexList[i].a = @primColor[3] * 255.0
      else
        @N64VertexList[i].r = @getVertexColorR(a)
        @N64VertexList[i].g = @getVertexColorG(a)
        @N64VertexList[i].b = @getVertexColorB(a)
        @N64VertexList[i].a = @getVertexAlpha(a)


      #until we use it..
      #@N64VertexList[i].nx = (@toSByte @getVertexNormalX(a))
      #@N64VertexList[i].ny = (@toSByte @getVertexNormalY(a))
      #@N64VertexList[i].nz = (@toSByte @getVertexNormalZ(a))

      #console.log "Vertex "+i+": XYZ("+@N64VertexList[i].x+" , "+@N64VertexList[i].y+" , "+@N64VertexList[i].z+") ST("+@N64VertexList[i].s+" , "+@N64VertexList[i].t+") RGBA("+@N64VertexList[i].r+" , "+@N64VertexList[i].g+" , "+@N64VertexList[i].b+" , "+@N64VertexList[i].a+") N("+@N64VertexList[i].nx+" , "+@N64VertexList[i].ny+" , "+@N64VertexList[i].nz+")"

      i += 1
    return

  C1964jsVideoHLE::DLParser_SetCImg = (pc) ->
    #@videoLog "TODO: DLParser_SetCImg"
    return

  #Gets new display list address
  C1964jsVideoHLE::RSP_GBI0_DL = (pc) ->
    param = undefined
    seg = @getGbi0DlistAddr(pc)
    addr = @getRspSegmentAddr(seg)
    #@videoLog "dlist address = " + dec2hex(addr)

    #TODO: address adjust
    param = @getGbi0DlistParam(pc)
    @dlistStackPointer += 1  if param is consts.RSP_DLIST_PUSH
    @dlistStack[@dlistStackPointer].pc = addr
    @dlistStack[@dlistStackPointer].countdown = consts.MAX_DL_COUNT
    return

  C1964jsVideoHLE::DLParser_SetCombine = (pc) ->
    @combineA0 = @getCombineA0(pc)
    @combineB0 = @getCombineB0(pc)
    @combineC0 = @getCombineC0(pc)
    @combineD0 = @getCombineD0(pc)
    # @combineA0 = 0xFF if @combineA0 is 15
    # @combineB0 = 0xFF if @combineB0 is 15
    # @combineC0 = 0xFF if @combineC0 is 31
    # @combineD0 = 0xFF if @combineD0 is 7
    @combineA0a = @getCombineA0a(pc)
    @combineB0a = @getCombineB0a(pc)
    @combineC0a = @getCombineC0a(pc)
    @combineD0a = @getCombineD0a(pc)
    # @combineA0a = 0xFF if @combineA0a is 7
    # @combineB0a = 0xFF if @combineB0a is 7
    # @combineC0a = 0xFF if @combineC0a is 7
    # @combineD0a = 0xFF if @combineD0a is 7
    @combineA1 = @getCombineA1(pc)
    @combineB1 = @getCombineB1(pc)
    @combineC1 = @getCombineC1(pc)
    @combineD1 = @getCombineD1(pc)
    # @combineA1 = 0xFF if @combineA1 is 15
    # @combineB1 = 0xFF if @combineB1 is 15
    # @combineC1 = 0xFF if @combineC1 is 31
    # @combineD1 = 0xFF if @combineD1 is 7
    @combineA1a = @getCombineA1a(pc)
    @combineB1a = @getCombineB1a(pc)
    @combineC1a = @getCombineC1a(pc)
    @combineD1a = @getCombineD1a(pc)
    # @combineA1a = 0xFF if @combineA1a is 7
    # @combineB1a = 0xFF if @combineB1a is 7
    # @combineC1a = 0xFF if @combineC1a is 7
    # @combineD1a = 0xFF if @combineD1a is 7

    w0 = @core.memory.rdramUint8Array[pc] << 24 | @core.memory.rdramUint8Array[pc + 1] << 16 | @core.memory.rdramUint8Array[pc + 2] << 8 | @core.memory.rdramUint8Array[pc + 3]
    w1 = @core.memory.rdramUint8Array[pc + 4] << 24 | @core.memory.rdramUint8Array[pc + 5] << 16 | @core.memory.rdramUint8Array[pc + 6] << 8 | @core.memory.rdramUint8Array[pc + 7]

    #if (@combineD0 == 4)
    #  console.log " a0:" + @combineA0 + " b0:" + @combineB0 + " c0:" + @combineC0 + " d0:" + @combineD0 + " a0a:" + @combineA0a + " b0a:" + @combineB0a + " c0a:" + @combineC0a + " d0a:" + @combineD0a + " a1:" + @combineA1 + " b1:" + @combineB1 + " c1:" + @combineC1 + " d1:" + @combineD1 + " a1a:" + @combineA1a + " b1a:" + @combineB1a + " c1a:" + @combineC1a + " d1a:" + @combineD1a

    #@videoLog "TODO: DLParser_SetCombine"
    return

  C1964jsVideoHLE::RSP_GBI1_MoveWord = (pc) ->
    #@videoLog "RSP_GBI1_MoveWord"
    switch @getGbi0MoveWordType(pc)
      when consts.RSP_MOVE_WORD_MATRIX
        @RSP_RDP_InsertMatrix()
      when consts.RSP_MOVE_WORD_SEGMENT
        dwBase = undefined
        dwSegment = (@getGbi0MoveWordOffset(pc) >> 2) & 0x0F
        dwBase = @getGbi0MoveWordValue(pc) & 0x00FFFFFF
        @segments[dwSegment] = dwBase
      when consts.RSP_MOVE_WORD_NUMLIGHT
        dwNumLights = (@getGbi0MoveWordValue(pc)<< 1 >>> 6)-1
        @gRSP.ambientLightIndex = dwNumLights
        @gRSPnumLights = dwNumLights
      when consts.RSP_MOVE_WORD_LIGHTCOL
        light = @getGbi0MoveWordOffset(pc) >>> 5
        field = @getGbi0MoveWordOffset(pc)>>>0 & 0x7
        if field is 0
          if light is @gRSP.ambientLightIndex
            @setAmbientLight @getGbi0MoveWordValue(pc)>>8
          else
            @setLightCol light, @getGbi0MoveWordValue(pc)
    return

  C1964jsVideoHLE::setAmbientLight = (col) ->
    @gRSP.ambientLightColor = col
    @gRSP.fAmbientLightR = (col >>> 24) & 0xff
    @gRSP.fAmbientLightG = (col >>> 16) & 0xff
    @gRSP.fAmbientLightB = (col >>> 8) & 0xff
    @gRSP.fAmbientLightA = col & 0xff
    return

  C1964jsVideoHLE::setLightCol = (dwLight, dwCol) ->
    @gRSPlights[dwLight].r = (dwCol >>> 24)&0xFF
    @gRSPlights[dwLight].g = (dwCol >>> 16)&0xFF
    @gRSPlights[dwLight].b = (dwCol >>>  8)&0xFF
    @gRSPlights[dwLight].a = @gRSPlights[dwLight].b
    @gRSPlights[dwLight].fr = @gRSPlights[dwLight].r
    @gRSPlights[dwLight].fg = @gRSPlights[dwLight].g
    @gRSPlights[dwLight].fb = @gRSPlights[dwLight].b
    @gRSPlights[dwLight].fa = @gRSPlights[dwLight].a
    return

  C1964jsVideoHLE::setLightDirection = (dwLight, x, y, z) ->
    w = Math.sqrt(x*x+y*y+z*z)

    @gRSPlights[dwLight].x = x/w
    @gRSPlights[dwLight].y = y/w
    @gRSPlights[dwLight].z = z/w
    return

  C1964jsVideoHLE::lightVertex = (norm) ->
    r = @gRSP.fAmbientLightR
    g = @gRSP.fAmbientLightG
    b = @gRSP.fAmbientLightB
    a = @gRSP.fAmbientLightA

    for l in [0...@gRSPnumLights]
      fCosT = norm[0]*@gRSPlights[l].x + norm[1]*@gRSPlights[l].y + norm[2]*@gRSPlights[l].z
      if fCosT > 0
        r += @gRSPlights[l].fr * fCosT
        g += @gRSPlights[l].fg * fCosT
        b += @gRSPlights[l].fb * fCosT
        a += @gRSPlights[l].fa * fCosT

    if r < 0.0
      r = 0.0
    if g < 0.0
      g = 0.0
    if b < 0.0
      b = 0.0
    if a < 0.0
      a = 0.0
    if r > 255.0
      r = 255.0
    if g > 255.0
      g = 255.0
    if b > 255.0
      b = 255.0
    if a > 255.0
      a = 255.0

    return [r, g, b, 255.0]

  C1964jsVideoHLE::RSP_MoveMemLight = (dwLight, dwAddr) ->
    if dwLight >= 16
      return

    @gRSPn64lights[dwLight].dwRGBA = @getGbi0MoveWordValue(dwAddr)
    @gRSPn64lights[dwLight].dwRGBACopy = @getGbi0MoveWordValue(dwAddr+4)
    @gRSPn64lights[dwLight].x = @getCommand(dwAddr+8)
    @gRSPn64lights[dwLight].y = @getCommand(dwAddr+9)
    @gRSPn64lights[dwLight].z = @getCommand(dwAddr+10)

    # disabled in Rice's code.
    # /*
    # {
    #   // Normalize light
    #   double sum = (double)gRSPn64lights[dwLight].x * gRSPn64lights[dwLight].x;
    #   sum += (double)gRSPn64lights[dwLight].y * gRSPn64lights[dwLight].y;
    #   sum += (double)gRSPn64lights[dwLight].z * gRSPn64lights[dwLight].z;
    #   sum = sqrt(sum);
    #   sum = sum/128.0;
    #   gRSPn64lights[dwLight].x /= sum;
    #   gRSPn64lights[dwLight].y /= sum;
    #   gRSPn64lights[dwLight].z /= sum;
    # }
    # */

    # normalize light
    # sum = @gRSPn64lights[dwLight].x * @gRSPn64lights[dwLight].x
    # sum += @gRSPn64lights[dwLight].y * @gRSPn64lights[dwLight].y
    # sum += @gRSPn64lights[dwLight].z * @gRSPn64lights[dwLight].z
    # sum = Math.sqrt(sum)
    # sum = sum/128.0
    # @gRSPn64lights[dwLight].x /= sum
    # @gRSPn64lights[dwLight].y /= sum
    # @gRSPn64lights[dwLight].z /= sum

    if dwLight == @gRSP.ambientLightIndex
      dwCol = @gRSPn64lights[dwLight].dwRGBA
      @setAmbientLight dwCol
    else
      @setLightCol dwLight, @gRSPn64lights[dwLight].dwRGBA
      if @getGbi0MoveWordValue(dwAddr+8) is 0  # Direction is 0!
      else
        @setLightDirection dwLight, @gRSPn64lights[dwLight].x, @gRSPn64lights[dwLight].y, @gRSPn64lights[dwLight].z
    return

  C1964jsVideoHLE::renderReset = ->

    #UpdateClipRectangle();
    @resetMatrices()

    #SetZBias(0);
    @gRSP.numVertices = 0
    @gRSP.curTile = 0
    @gRSP.fTexScaleX = 1 / 32.0
    @gRSP.fTexScaleY = 1 / 32.0
    return

  C1964jsVideoHLE::resetMatrices = ->
    @gRSP.projectionMtxTop = 0
    @gRSP.modelViewMtxTop = 0
    @gRSP.projectionMtxs[0] = mat4.create()
    @gRSP.modelviewMtxs[0] = mat4.create()
    mat4.identity @gRSP.modelviewMtxs[0]
    mat4.identity @gRSP.projectionMtxs[0]
    @gRSP.bMatrixIsUpdated = true
    @updateCombinedMatrix()
    return

  C1964jsVideoHLE::RSP_RDP_InsertMatrix = ->
    @updateCombinedMatrix()
    @gRSP.bMatrixIsUpdated = false
    return

  C1964jsVideoHLE::DLParser_SetScissor = (pc) ->
    #@videoLog "TODO: DLParser_SetScissor"
    return

  C1964jsVideoHLE::RSP_GBI1_SetOtherModeH = (pc) ->
    #@videoLog "TODO: DLParser_GBI1_SetOtherModeH"
    word0 = @getOtherModeH(pc) >>> 0
    length = (word0 >>> 0) & 0xFF
    shift = ((word0 >>> 8) & 0xFF)
    mask = ((1<<length)-1)<<shift
    @otherModeH &= ~mask
    @otherModeH |= @getOtherModeH pc+4
    #alert @otherModeH
    return

  C1964jsVideoHLE::RSP_GBI1_SetOtherModeL = (pc) ->
    #@videoLog "TODO: DLParser_GBI1_SetOtherModeL"
    word0 = @getOtherModeL(pc) >>> 0
    length = (word0 >>> 0) & 0xFF
    shift = ((word0 >>> 8) & 0xFF)
    mask = ((1<<length)-1)<<shift
    @otherModeL &= ~mask
    @otherModeL |= @getOtherModeL pc+4
    #alert dec2hex @otherModeL
    return

  C1964jsVideoHLE::RSP_GBI0_Sprite2DBase = (pc) ->
    #@videoLog "TODO: RSP_GBI0_Sprite2DBase"
    return

  C1964jsVideoHLE::RSP_GBI0_Tri4 = (pc) ->
    #@videoLog "TODO: RSP_GBI0_Tri4"
    return

  C1964jsVideoHLE::RSP_GBI1_RDPHalf_Cont = (pc) ->
    #@videoLog "TODO: RSP_GBI1_RDPHalf_Cont"
    return

  C1964jsVideoHLE::RSP_GBI1_RDPHalf_2 = (pc) ->
    #@videoLog "TODO: RSP_GBI1_RDPHalf_2"
    return

  C1964jsVideoHLE::RSP_GBI1_RDPHalf_1 = (pc) ->
    #@videoLog "TODO: RSP_GBI1_RDPHalf_1"
    return

  C1964jsVideoHLE::RSP_GBI1_Line3D = (pc) ->
    #@videoLog "TODO: RSP_GBI1_Line3D"
    return

  C1964jsVideoHLE::RSP_GBI1_ClearGeometryMode = (pc) ->
    data = @getClearGeometryMode(pc)>>>0
    @geometryMode &= ~data
    @initGeometryMode()
    return

  C1964jsVideoHLE::RSP_GBI1_SetGeometryMode = (pc) ->
    data = @getSetGeometryMode(pc)>>>0
    @geometryMode |= data
    @initGeometryMode()
    return

  C1964jsVideoHLE::initGeometryMode = () ->
    # cull face
    bCullFront = @geometryMode & consts.G_CULL_FRONT
    bCullBack = @geometryMode & consts.G_CULL_BACK
    if bCullBack isnt 0 and bCullFront isnt 0
      @gl.enable @gl.CULL_FACE
      @gl.cullFace @gl.FRONT_AND_BACK
    else if bCullBack isnt 0
      @gl.enable @gl.CULL_FACE
      @gl.cullFace @gl.BACK
    else if bCullFront isnt 0
      @gl.enable @gl.CULL_FACE
      @gl.cullFace @gl.FRONT
    else
      @gl.disable @gl.CULL_FACE

    if (@geometryMode & consts.G_SHADE) isnt 0
      @bShade = true
    else
      @bShade = false
    #this doesn't exist in WebGL, so find a replacement if
    #we need flat-shading.
    #bShadeSmooth = @geometryMode & consts.G_SHADING_SMOOTH
    #if bShade isnt 0 and bShadeSmooth isnt 0
    #  @gl.shadeModel @gl.SMOOTH
    #else
    #  @gl.shadeModel @gl.FLAT

    if (@geometryMode & consts.G_TEXTURE_GEN) isnt 0
      @bTextureGen = true
    else
      @bTexueGen = false
    if (@geometryMode & consts.G_LIGHTING) isnt 0
      @bLightingEnable = true
    else
      @bLightingEnable = false
    if (@geometryMode & consts.G_FOG) isnt 0
      @bFogEnable = true
    else
      @bFogEnable = false
    if (@geometryMode & consts.G_ZBUFFER) isnt 0
      @bZBufferEnable = true
    else
      @bZBufferEnable = false
    return

  C1964jsVideoHLE::RSP_GBI1_EndDL = (pc) ->
    #@videoLog "RSP_GBI1_EndDL"
    @RDP_GFX_PopDL()
    @drawScene(false, 7)

    #alert "EndFrame"
    return

  C1964jsVideoHLE::RSP_GBI1_Texture = (pc) ->
    tile = @getTextureTile(pc)
    @textureTile[tile].on    = @getTextureOn(pc)
    @textureTile[tile].level = @getTextureLevel(pc)
    @textureTile[tile].scales = @getTextureScaleS(pc) / 0x8000
    @textureTile[tile].scalet = @getTextureScaleT(pc) / 0x8000
    #console.log "RSP_GBI1_Texture: Tile:" + tile + " On:" + @textureTile[tile].on + " Level:" + @textureTile[tile].level + " ScaleS:" + @textureTile[tile].scales + " ScaleT:" + @textureTile[tile].scalet
    return

  C1964jsVideoHLE::RSP_GBI1_PopMtx = (pc) ->
    #@videoLog "TODO: RSP_GBI1_PopMtx"
    return

  C1964jsVideoHLE::RSP_GBI1_CullDL = (pc) ->
    #@videoLog "TODO: RSP_GBI1_CullDL"
    return

  C1964jsVideoHLE::RSP_GBI1_Tri1 = (pc) ->
    v0 = @getGbi0Tri1V0(pc) / @gRSP.vertexMult
    v1 = @getGbi0Tri1V1(pc) / @gRSP.vertexMult
    v2 = @getGbi0Tri1V2(pc) / @gRSP.vertexMult
    flag = @getGbi0Tri1Flag(pc)
    #console.log "Tri1: "+v0+", "+v1+", "+v2+"   Flag: "+flag
    didSucceed = @prepareTriangle v0, v1, v2

    if didSucceed is false
      return

    #cmd = @getCommand(pc+8)
    #func = @currentMicrocodeMap[cmd]

 #   @drawScene(false, 7)

  #  if func isnt "RSP_GBI1_Tri1"
  #    @drawScene false, 7

    @setBlendFunc()
    return

  C1964jsVideoHLE::RSP_GBI1_Noop = (pc) ->
    #@videoLog "TODO: RSP_GBI1_Noop"
    return

  C1964jsVideoHLE::RDP_TriFill = (pc) ->
    #@videoLog "TODO: RDP_TriFill"
    return

  C1964jsVideoHLE::RDP_TriFillZ = (pc) ->
    #@videoLog "RDP_TriFillZ"
    return

  C1964jsVideoHLE::RDP_TriTxtr = (pc) ->
    #@videoLog "TODO: RDP_TriTxtr"
    return

  C1964jsVideoHLE::RDP_TriTxtrZ = (pc) ->
    #@videoLog "TODO: RDP_TriTxtrZ"
    return

  C1964jsVideoHLE::RDP_TriShade = (pc) ->
    #@videoLog "TODO: RDP_TriShade"
    return

  C1964jsVideoHLE::RDP_TriShadeZ = (pc) ->
    #@videoLog "TODO: RDP_TriShadeZ"
    return

  C1964jsVideoHLE::RDP_TriShadeTxtr = (pc) ->
    #@videoLog "TODO: RDP_TriShadeTxtr"
    return

  C1964jsVideoHLE::RDP_TriShadeTxtrZ = (pc) ->
    #@videoLog "TODO: RDP_TriShadeTxtrZ"
    return

  C1964jsVideoHLE::DLParser_TexRect = (pc) ->
    #@videoLog "TODO: DLParser_TexRect"
    xh = @getTexRectXh(pc) / 4
    yh = @getTexRectYh(pc) / 4
    tileno = @getTexRectTileNo(pc)
    xl = @getTexRectXl(pc) / 4
    yl = @getTexRectYl(pc) / 4
    s = @getTexRectS(pc) / 32
    t = @getTexRectT(pc) / 32
    dsdx = @getTexRectDsDx(pc) / 1024
    dtdy = @getTexRectDtDy(pc) / 1024
    #console.log "Texrect: UL("+xl+","+yl+") LR("+xh+","+yh+") Tile:"+tileno+" TexCoord:("+s+","+t+") TexSlope:("+dsdx+","+dtdy+")"
    @renderer.texRect xl, yl, xh, yh, s, t, dsdx, dtdy, @textureTile[tileno], @tmem, this
    @dlistStack[@dlistStackPointer].pc += 8
    @hasTexture = true
    return

  C1964jsVideoHLE::DLParser_TexRectFlip = (pc) ->
    @dlistStack[@dlistStackPointer].pc += 8
    #@videoLog "TODO: DLParser_TexRectFlip"
    return

  C1964jsVideoHLE::DLParser_RDPLoadSynch = (pc) ->
    #@videoLog "TODO: DLParser_RDPLoadSynch"
    return

  C1964jsVideoHLE::DLParser_RDPPipeSynch = (pc) ->
    #@videoLog "TODO: DLParser_RDPPipeSynch"
    return

  C1964jsVideoHLE::DLParser_RDPTileSynch = (pc) ->
    #@videoLog "TODO: DLParser_RDPTileSynch"
    return

  C1964jsVideoHLE::DLParser_RDPFullSynch = (pc) ->
    #@videoLog "TODO: DLParser_RDPFullSynch"
    @core.interrupts.triggerDPInterrupt 0, false
    #@drawScene(7, false)
    return

  C1964jsVideoHLE::DLParser_SetKeyGB = (pc) ->
    #@videoLog "TODO: DLParser_SetKeyGB"
    return

  C1964jsVideoHLE::DLParser_SetKeyR = (pc) ->
    #@videoLog "TODO: DLParser_SetKeyR"
    return

  C1964jsVideoHLE::DLParser_SetConvert = (pc) ->
    #@videoLog "TODO: DLParser_SetConvert"
    return

  C1964jsVideoHLE::DLParser_SetPrimDepth = (pc) ->
    #@videoLog "TODO: DLParser_SetPrimDepth"
    return

  C1964jsVideoHLE::DLParser_RDPSetOtherMode = (pc) ->
    #@videoLog "TODO: DLParser_RDPSetOtherMode"
    return

  C1964jsVideoHLE::DLParser_LoadTLut = (pc) ->
    #@videoLog "TODO: DLParser_LoadTLut"
    return

  C1964jsVideoHLE::DLParser_SetTileSize = (pc) ->
    tile = @getSetTileSizeTile(pc)
    @textureTile[tile].uls = @getSetTileSizeUls(pc)
    @textureTile[tile].ult = @getSetTileSizeUlt(pc)
    @textureTile[tile].lrs = (@getSetTileSizeLrs(pc) >> 2) + 1
    @textureTile[tile].lrt = (@getSetTileSizeLrt(pc) >> 2) + 1
    @textureTile[tile].width = @textureTile[tile].lrs - @textureTile[tile].uls
    @textureTile[tile].height = @textureTile[tile].lrt - @textureTile[tile].ult
    #console.log "SetTileSize: UL("+@textureTile[tile].uls+"/"+@textureTile[tile].ult+") LR("+@textureTile[tile].lrs+"/"+@textureTile[tile].lrt+") Dim: "+@textureTile[tile].width+"x"+@textureTile[tile].height
    #@videoLog "TODO: DLParser_SetTileSize"
    return

  C1964jsVideoHLE::DLParser_LoadBlock = (pc) ->
    tile = @getLoadBlockTile(pc)
    uls = @getLoadBlockUls(pc)
    ult = @getLoadBlockUlt(pc)
    lrs = @getLoadBlockLrs(pc)+1
    dxt = @getLoadBlockDxt(pc)
    #console.log "LoadBlock: Tile:"+tile+" UL("+uls+"/"+ult+") LRS:"+lrs+" DXT: 0x"+dec2hex(dxt)
    #textureAddr = @core.memory.rdramUint8Array[@texImg.addr])
    bytesToXfer = lrs * @textureTile[tile].siz
    if bytesToXfer > 4096
      console.error "LoadBlock is making too large of a transfer. "+bytesToXfer+" bytes"
    i=0
    while i < bytesToXfer
      @tmem[i]= @core.memory.rdramUint8Array[@texImg.addr+i]
      i++
    #@videoLog "TODO: DLParser_LoadBlock"
    return

  C1964jsVideoHLE::DLParser_LoadTile = (pc) ->
    #@videoLog "TODO: DLParser_LoadTile"
    return

  C1964jsVideoHLE::DLParser_SetTile = (pc) ->
    tile = @getSetTileTile(pc)
    @activeTile = tile
    @textureTile[tile].fmt = @getSetTileFmt(pc);
    @textureTile[tile].siz = @getSetTileSiz(pc);
    @textureTile[tile].line = @getSetTileLine(pc);
    @textureTile[tile].tmem = @getSetTileTmem(pc);
    @textureTile[tile].pal = @getSetTilePal(pc);
    @textureTile[tile].cmt = @getSetTileCmt(pc);
    @textureTile[tile].cms = @getSetTileCms(pc);
    @textureTile[tile].maskt = @getSetTileMaskt(pc);
    @textureTile[tile].masks = @getSetTileMasks(pc);
    @textureTile[tile].shiftt = @getSetTileShiftt(pc);
    @textureTile[tile].shifts = @getSetTileShifts(pc);
    #if @combineD0 == 4
    #console.log "SetTile:"+tile+" FMT:"+@textureTile[tile].fmt+" SIZ:"+@textureTile[tile].siz+" LINE: "+@textureTile[tile].line+" TMEM:"+@textureTile[tile].tmem+" PAL:"+@textureTile[tile].pal+" CMS/T:"+@textureTile[tile].cms+"/"+@textureTile[tile].cmt+" MASKS/T:"+@textureTile[tile].masks+"/"+@textureTile[tile].maskt+" SHIFTS/T:"+@textureTile[tile].shifts+"/"+@textureTile[tile].shiftt
    #@videoLog "TODO: DLParser_SetTile"
    return

  C1964jsVideoHLE::DLParser_FillRect = (pc) ->
    #@videoLog "TODO: DLParser_FillRect"
    return

  C1964jsVideoHLE::DLParser_SetFillColor = (pc) ->
    @fillColor = []
    @fillColor.push @getSetFillColorR(pc)/255.0
    @fillColor.push @getSetFillColorG(pc)/255.0
    @fillColor.push @getSetFillColorB(pc)/255.0
    @fillColor.push @getSetFillColorA(pc)/255.0

    #@videoLog "TODO: DLParser_SetFillColor"
    return

  C1964jsVideoHLE::DLParser_SetFogColor = (pc) ->
    #@videoLog "TODO: DLParser_SetFogColor"
    return

  C1964jsVideoHLE::DLParser_SetBlendColor = (pc) ->
    @blendColor = []
    @blendColor.push @getSetFillColorR(pc)/255.0
    @blendColor.push @getSetFillColorG(pc)/255.0
    @blendColor.push @getSetFillColorB(pc)/255.0
    @blendColor.push @getSetFillColorA(pc)/255.0
    @alphaTestEnabled = 1
    return

  C1964jsVideoHLE::DLParser_SetPrimColor = (pc) ->
    @primColor = []
    @primColor.push @getSetPrimColorR(pc)/255.0
    @primColor.push @getSetPrimColorG(pc)/255.0
    @primColor.push @getSetPrimColorB(pc)/255.0
    @primColor.push @getSetPrimColorA(pc)/255.0
    #alert @primColor
    #@videoLog "TODO: DLParser_SetPrimColor"
    return

  C1964jsVideoHLE::DLParser_SetEnvColor = (pc) ->
    @envColor = []
    @envColor.push @getSetEnvColorR(pc)/255.0
    @envColor.push @getSetEnvColorG(pc)/255.0
    @envColor.push @getSetEnvColorB(pc)/255.0
    @envColor.push @getSetEnvColorA(pc)/255.0

    #@videoLog "TODO: DLParser_SetEnvColor"
    return

  C1964jsVideoHLE::DLParser_SetZImg = (pc) ->
    #@videoLog "TODO: DLParser_SetZImg"
    return

  C1964jsVideoHLE::prepareTriangle = (dwV0, dwV1, dwV2) ->
    #SP_Timing(SP_Each_Triangle);
    didSucceed = undefined #(CRender::g_pRender->IsTextureEnabled() || this.gRSP.ucode == 6 );
    textureFlag = false
    didSucceed = @initVertex(dwV0, @gRSP.numVertices, textureFlag)
    didSucceed = @initVertex(dwV1, @gRSP.numVertices + 1, textureFlag)  if didSucceed
    didSucceed = @initVertex(dwV2, @gRSP.numVertices + 2, textureFlag)  if didSucceed
    @gRSP.numVertices += 3  if didSucceed
    didSucceed

  C1964jsVideoHLE::initVertex = (dwV, vtxIndex, bTexture) ->
    #console.log "Vertex Index: "+vtxIndex+" dwV:"+dwV
    return false  if dwV >= consts.MAX_VERTS

    offset = 3 * (@triangleVertexPositionBuffer.numItems)
    @triVertices[offset] = @N64VertexList[dwV].x
    @triVertices[offset+1] = @N64VertexList[dwV].y
    @triVertices[offset+2] = @N64VertexList[dwV].z - 2.0

    @triangleVertexPositionBuffer.numItems += 1

    colorOffset = @triangleVertexColorBuffer.numItems << 2
    @triColorVertices[colorOffset]     = @N64VertexList[dwV].r;
    @triColorVertices[colorOffset + 1] = @N64VertexList[dwV].g;
    @triColorVertices[colorOffset + 2] = @N64VertexList[dwV].b;
    @triColorVertices[colorOffset + 3] = @N64VertexList[dwV].a;
    @triangleVertexColorBuffer.numItems += 1

    texOffset = @triangleVertexTextureCoordBuffer.numItems << 1
    @triTextureCoords[texOffset]     = @N64VertexList[dwV].s
    @triTextureCoords[texOffset + 1] = @N64VertexList[dwV].t
    @triangleVertexTextureCoordBuffer.numItems += 1
    true

  C1964jsVideoHLE::setBlendFunc = () ->
    CYCLE_TYPE_1 = 0
    CYCLE_TYPE_2 = 1
    CYCLE_TYPE_COPY = 2
    CYCLE_TYPE_FILL = 3
    CVG_DST_CLAMP = 0
    CVG_DST_WRAP = 0x100
    CVG_DST_FULL = 0x200
    CVG_DST_SAVE = 0x300
    BLEND_NOOP = 0x0000
    BLEND_NOOP5 = 0xcc48
    BLEND_NOOP4 = 0xcc08
    BLEND_FOG_ASHADE = 0xc800
    BLEND_FOG_3 = 0xc000
    BLEND_FOG_MEM = 0xc440
    BLEND_FOG_APRIM = 0xc400
    BLEND_BLENDCOLOR = 0x8c88
    BLEND_BI_AFOG = 0x8400
    BLEND_BI_AIN = 0x8040
    BLEND_MEM = 0x4c40
    BLEND_FOG_MEM_3 = 0x44c0
    BLEND_NOOP3 = 0x0c48
    BLEND_PASS = 0x0c08
    BLEND_FOG_MEM_IN_MEM = 0x0440
    BLEND_FOG_MEM_FOG_MEM = 0x04c0
    BLEND_OPA = 0x0044
    BLEND_XLU = 0x0040
    BLEND_MEM_ALPHA_IN = 0x4044

    blendMode1 = @otherModeL >>> 16 & 0xCCCC
    blendMode2 = @otherModeL >>> 16 & 0x3333
    @cycleType = @otherModeH >> 20 & 0x3

    switch @cycleType
      when CYCLE_TYPE_FILL
        @gl.disable @gl.BLEND
      when CYCLE_TYPE_COPY
        @gl.enable @gl.BLEND
        @gl.blendFunc @gl.ONE, @gl.ZERO
      when CYCLE_TYPE_2
        forceBl = @otherModeL >> 14 & 0x1
        zCmp = @otherModeL >> 4 & 0x1
        alphaCvgSel = @otherModeL >> 13 & 0x1
        cvgXAlpha = @otherModeL >> 12 & 0x1

        if forceBl is 1 and zCmp is 1
          @gl.blendFunc @gl.SRC_ALPHA, @gl.ONE_MINUS_SRC_ALPHA
          @gl.enable @gl.BLEND
        else if alphaCvgSel is 1 && cvgXAlpha is 0
          @gl.blendFunc @gl.ONE, @gl.ZERO
          @gl.enable @gl.BLEND
        else switch blendMode1+blendMode2
          when (BLEND_PASS+(BLEND_PASS>>2)), (BLEND_FOG_APRIM+(BLEND_PASS>>2))
            @gl.blendFunc @gl.ONE, @gl.ZERO
            @gl.enable @gl.blendFunc
    #       if( gRDP.otherMode.alpha_cvg_sel )
    #       {
    #         Enable();
    #       }
    #       else
    #       {
    #         Enable();
    #       }
    #       break;
          when BLEND_PASS+(BLEND_OPA>>2)
            if cvgXAlpha is 1 and alphaCvgSel is 1
              @gl.blendFunc @gl.SRC_ALPHA, @gl.ONE_MINUS_SRC_ALPHA
              @gl.enable @gl.BLEND
            else
              @gl.blendFunc @gl.ONE, @gl.ZERO
              @gl.enable @gl.BLEND
          when (BLEND_PASS + (BLEND_XLU>>2)), (BLEND_FOG_ASHADE + (BLEND_XLU>>2)), (BLEND_FOG_APRIM + (BLEND_XLU>>2)), (BLEND_FOG_MEM_FOG_MEM + (BLEND_PASS>>2)), (BLEND_XLU + (BLEND_XLU>>2)), (BLEND_BI_AFOG + (BLEND_XLU>>2)), (BLEND_XLU + (BLEND_FOG_MEM_IN_MEM>>2)), (BLEND_PASS + (BLEND_FOG_MEM_IN_MEM>>2))
            @gl.blendFunc @gl.SRC_ALPHA, @gl.ONE_MINUS_SRC_ALPHA
            @gl.enable @gl.BLEND
          when BLEND_FOG_MEM_FOG_MEM + (BLEND_OPA>>2)
            @gl.blendFunc @gl.ONE, @gl.ZERO
            @gl.enable @gl.BLEND
          when (BLEND_FOG_APRIM + (BLEND_OPA>>2)), (BLEND_FOG_ASHADE + (BLEND_OPA>>2)), (BLEND_BI_AFOG + (BLEND_OPA>>2)), (BLEND_FOG_ASHADE + (BLEND_NOOP>>2)), (BLEND_NOOP + (BLEND_OPA>>2)), (BLEND_NOOP4 + (BLEND_NOOP>>2)), (BLEND_FOG_ASHADE+(BLEND_PASS>>2)), (BLEND_FOG_3+(BLEND_PASS>>2))
            @gl.blendFunc @gl.ONE, @gl.ZERO
            @gl.enable @gl.BLEND
          when BLEND_FOG_ASHADE+0x0301
            @gl.blendFunc @gl.SRC_ALPHA, @gl.ZERO
            @gl.enable @gl.BLEND
          when 0x0c08+0x1111
            @gl.blendFunc @gl.ZERO, @gl.DEST_ALPHA
            @gl.enable @gl.BLEND
          else
            if blendMode2 == BLEND_PASS>>2
              @gl.blendFunc @gl.ONE, @g.ZERO
            else
              @gl.blendFunc  @gl.SRC_ALPHA, @gl.ONE_MINUS_SRC_ALPHA
            @gl.enable @gl.BLEND
      else  # 1/2 Cycle or Copy
        forceBl = @otherModeL >> 14 & 0x1
        zCmp = @otherModeL >> 4 & 0x1
        if forceBl is 1 and zCmp is 1 and blendMode1 isnt BLEND_FOG_ASHADE
          @gl.blendFunc @gl.SRC_ALPHA, @gl.ONE_MINUS_SRC_ALPHA
          @gl.enable @gl.BLEND
    #    if( gRDP.otherMode.force_bl && options.enableHackForGames == HACK_FOR_COMMANDCONQUER )
    #    {
    #      BlendFunc(D3DBLEND_SRCALPHA, D3DBLEND_INVSRCALPHA);
    #      Enable();
    #      break;
    #    }
        else switch blendMode1
    #    //switch ( blendmode_2<<2 )
          when BLEND_XLU, BLEND_BI_AIN, BLEND_FOG_MEM, BLEND_FOG_MEM_IN_MEM, BLEND_BLENDCOLOR, 0x00c0
            @gl.blendFunc @gl.SRC_ALPHA, @gl.ONE_MINUS_SRC_ALPHA
            @gl.enable @gl.BLEND
          when BLEND_MEM_ALPHA_IN
            @gl.blendFunc @gl.ZERO, @gl.DEST_ALPHA
            @gl.enable @gl.BLEND
          when BLEND_PASS
            alphaCvgSel = @otherModeL >> 13 & 0x1
            @gl.blendFunc @gl.ONE, @gl.ZERO
            if alphaCvgSel != 0
              @gl.enable @gl.BLEND
            else
              @gl.disable @gl.BLEND
          when BLEND_OPA
          #  if( options.enableHackForGames == HACK_FOR_MARIO_TENNIS )
          #  {
          #    BlendFunc(D3DBLEND_SRCALPHA, D3DBLEND_INVSRCALPHA);
          #  }
          #  else
          #  {
            @gl.blendFunc @gl.ONE, @gl.ZERO
          #  }
            @gl.enable @gl.BLEND
          when BLEND_NOOP, BLEND_FOG_ASHADE, BLEND_FOG_MEM_3, BLEND_BI_AFOG
            @gl.blendFunc @gl.ONE, @gl.ZERO
            @gl.enable @gl.BLEND
          when BLEND_FOG_APRIM
            @gl.blendFunc @gl.ONE_MINUS_SRC_ALPHA, @gl.ZERO
            @gl.enable @gl.BLEND
          when BLEND_NOOP3, BLEND_NOOP5
            @gl.blendFunc @gl.ZERO, @gl.ONE
            @gl.enable @gl.BLEND
          when BLEND_MEM
            # WaveRace
            @gl.blendFunc @gl.ZERO, @gl.ONE
            @gl.blendEquation @gl.FUNC_ADD
            @gl.enable @gl.BLEND
          else
            @gl.blendFunc @gl.SRC_ALPHA, @gl.ONE_MINUS_SRC_ALPHA
            @gl.blendEquation @gl.FUNC_ADD
            @gl.enable @gl.BLEND
            #render->SetAlphaTestEnable(TRUE);
    return

  C1964jsVideoHLE::drawScene = (useTexture, tileno) ->
    @gl.useProgram @core.webGL.shaderProgram
    @gl.enable @gl.DEPTH_TEST
    @gl.depthFunc @gl.LEQUAL

    if @triangleVertexPositionBuffer.numItems > 0
      @gl.bindBuffer @gl.ARRAY_BUFFER, @triangleVertexPositionBuffer
      @gl.bufferData @gl.ARRAY_BUFFER, @triVertices.subarray(0, @triangleVertexPositionBuffer.numItems*@triangleVertexPositionBuffer.itemSize*4), @gl.STATIC_DRAW
      @gl.enableVertexAttribArray @core.webGL.shaderProgram.vertexPositionAttribute
      @gl.vertexAttribPointer @core.webGL.shaderProgram.vertexPositionAttribute, @triangleVertexPositionBuffer.itemSize, @gl.FLOAT, false, 0, 0

    if @triangleVertexColorBuffer.numItems > 0
      @gl.bindBuffer @gl.ARRAY_BUFFER, @triangleVertexColorBuffer
      @gl.bufferData @gl.ARRAY_BUFFER, @triColorVertices.subarray(0, @triangleVertexColorBuffer.numItems*@triangleVertexColorBuffer.itemSize), @gl.STATIC_DRAW
      @gl.enableVertexAttribArray @core.webGL.shaderProgram.vertexColorAttribute
      @gl.vertexAttribPointer @core.webGL.shaderProgram.vertexColorAttribute, @triangleVertexColorBuffer.itemSize, @gl.UNSIGNED_BYTE, true, 0, 0

    if @triangleVertexTextureCoordBuffer.numItems > 0
      @gl.bindBuffer @gl.ARRAY_BUFFER, @triangleVertexTextureCoordBuffer
      @gl.bufferData @gl.ARRAY_BUFFER, @triTextureCoords.subarray(0, @triangleVertexTextureCoordBuffer.numItems*@triangleVertexTextureCoordBuffer.itemSize*4), @gl.STATIC_DRAW
      @gl.enableVertexAttribArray @core.webGL.shaderProgram.textureCoordAttribute
      @gl.vertexAttribPointer @core.webGL.shaderProgram.textureCoordAttribute, @triangleVertexTextureCoordBuffer.itemSize, @gl.FLOAT, false, 0, 0
      tile = @textureTile[@activeTile]
      canvaswidth = @pow2roundup tile.width
      canvasheight = @pow2roundup tile.height
      texture = @renderer.formatTexture(tile, @tmem, canvaswidth, canvasheight)
      colorsTexture = @gl.createTexture()
      @gl.activeTexture(@gl.TEXTURE0)
      @gl.bindTexture(@gl.TEXTURE_2D, colorsTexture)
      @gl.texImage2D( @gl.TEXTURE_2D, 0, @gl.RGBA, tile.width, tile.height, 0, @gl.RGBA, @gl.UNSIGNED_BYTE, texture)
      @gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_MAG_FILTER, @gl.LINEAR)
      @gl.texParameteri(@gl.TEXTURE_2D, @gl.TEXTURE_MIN_FILTER, @gl.NEAREST)
      @gl.uniform1i @core.webGL.shaderProgram.samplerUniform, colorsTexture

    if @primColor.length > 0
      @gl.uniform4fv @core.webGL.shaderProgram.uPrimColor, @primColor

    if @fillColor.length > 0
      @gl.uniform4fv @core.webGL.shaderProgram.uFillColor, @fillColor

    if @envColor.length > 0
      @gl.uniform4fv @core.webGL.shaderProgram.uEnvColor, @envColor

    if @blendColor.length > 0
      @gl.uniform4fv @core.webGL.shaderProgram.uBlendColor, @blendColor

    #@gl.uniform1i @core.webGL.shaderProgram.otherModeL, @otherModeL
    #@gl.uniform1i @core.webGL.shaderProgram.otherModeH, @otherModeH
    @gl.uniform1i @core.webGL.shaderProgram.cycleType, @cycleType
    @gl.uniform1i @core.webGL.shaderProgram.uAlphaTestEnabled, @alphaTestEnabled

    @core.webGL.setCombineUniforms @core.webGL.shaderProgram

    @gl.uniform1i @core.webGL.shaderProgram.wireframeUniform, if @core.settings.wireframe then 1 else 0

    # Matrix Uniforms
    @gl.uniformMatrix4fv(@core.webGL.shaderProgram.pMatrixUniform, false, @gRSP.projectionMtxs[@gRSP.projectionMtxTop]);
    @gl.uniformMatrix4fv(@core.webGL.shaderProgram.mvMatrixUniform, false, @gRSP.modelviewMtxs[@gRSP.modelViewMtxTop]);

    if @triangleVertexPositionBuffer.numItems > 0
      if @core.settings.wireframe is true
        @gl.drawArrays @gl.LINES, 0, @triangleVertexPositionBuffer.numItems
      else
        @gl.drawArrays @gl.TRIANGLES, 0, @triangleVertexPositionBuffer.numItems

    @resetState()
    return

  C1964jsVideoHLE::resetState = ->
    @triangleVertexPositionBuffer.numItems = 0
    @triangleVertexColorBuffer.numItems = 0
    @triangleVertexTextureCoordBuffer.numItems = 0
    @otherModeL = 0x00500001
    @otherModeH = 0
   # @geometryMode = 0
    @initGeometryMode()
    @alphaTestEnabled = 0
    return

  C1964jsVideoHLE::initBuffers = ->
    @triangleVertexPositionBuffer = @gl.createBuffer()
    @gl.bindBuffer @gl.ARRAY_BUFFER, @triangleVertexPositionBuffer
    @triangleVertexPositionBuffer.itemSize = 3
    @triangleVertexPositionBuffer.numItems = 0

    @triangleVertexColorBuffer = @gl.createBuffer()
    @gl.bindBuffer @gl.ARRAY_BUFFER, @triangleVertexColorBuffer
    @triangleVertexColorBuffer.itemSize = 4
    @triangleVertexColorBuffer.numItems = 0

    @triangleVertexTextureCoordBuffer = @gl.createBuffer()
    @gl.bindBuffer @gl.ARRAY_BUFFER, @triangleVertexTextureCoordBuffer
    @triangleVertexTextureCoordBuffer.itemSize = 2
    @triangleVertexTextureCoordBuffer.numItems = 0
    return
)()
#hack global space until we export classes properly
#node.js uses exports; browser uses this (window)
root = exports ? this
root.C1964jsVideoHLE = C1964jsVideoHLE
