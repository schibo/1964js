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
  i = undefined
  @core = core #only needed for gfxHelpers prototypes to access.
  @gl = glx
 
  #todo: make gRSP a class object.
  @RICE_MATRIX_STACK = 60
  @MAX_TEXTURES = 8
  @MAX_VERTICES = 80
  @MAX_TILES = 8
  @textureTiles = []
  @N64VertexList = []
  @vtxTransformed = []
  @vtxNonTransformed = []
  @vecProjected = []
  @vtxProjected5 = []
  @gRSP = {}
  @matToLoad = mat4.create()
  @gRSPworldProject = mat4.create()
  @triangleVertexPositionBuffer = `undefined`
  @triangleVertexColorBuffer = `undefined`
  @dlistStackPointer = 0
  @dlistStack = []
  @renderer = new C1964jsRenderer(@core.settings, @core.webGL.gl, @core.webGL)
  @texImg = {}
  @segments = []

  #todo: different microcodes support
  @currentMicrocodeMap = @microcodeMap0
  i = 0
  while i< @MAX_TILES
    @textureTiles[i] = []
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
  C1964jsVideoHLE::processDisplayList = ->
    if @core.showFB is true
      @initBuffers()
      @core.webGL.show3D()
      @core.showFB = false
    @core.webGL.beginDList()
    @dlParserProcess()

    #this.core.interrupts.triggerDPInterrupt(0, false);
    @core.interrupts.triggerSPInterrupt 0, false

  C1964jsVideoHLE::videoLog = (msg) ->
    #console.log msg
    return

  C1964jsVideoHLE::dlParserProcess = ->
    @dlistStackPointer = 0
    @dlistStack[@dlistStackPointer].pc = @core.memory.getInt32(@core.memory.spMemUint8Array, @core.memory.spMemUint8Array, consts.TASK_DATA_PTR)
    @dlistStack[@dlistStackPointer].countdown = consts.MAX_DL_COUNT
    @vertices = []
    @triVertices = []
    @triangleVertexPositionBuffer.numItems = 0
    @triangleVertexColorBuffer.numItems = 0
    @gRSP.numVertices = 0

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
      func = undefined
      cmd = undefined
      pc = @dlistStack[@dlistStackPointer].pc
      cmd = @getCommand(pc)
      @dlistStack[@dlistStackPointer].pc += 8
      func = @currentMicrocodeMap[cmd]
      this[func] pc
      if @dlistStackPointer >= 0
        @dlistStack[@dlistStackPointer].countdown -= 1
        @dlistStackPointer -= 1  if @dlistStack[@dlistStackPointer].countdown < 0
    @videoLog "finished dlist"
    @core.interrupts.triggerSPInterrupt 0, false
    @drawScene(false, 7)
    return

  #TODO: end rendering
  C1964jsVideoHLE::RDP_GFX_PopDL = ->
    @dlistStackPointer -= 1
    return

  C1964jsVideoHLE::RSP_RDP_Nothing = (pc) ->
    @videoLog "RSP RDP NOTHING"
    @dlistStackPointer -= 1
    return

  C1964jsVideoHLE::RSP_GBI1_MoveMem = (pc) ->
    addr = undefined
    length = undefined
    type = @getGbi1Type(pc)
    length = @getGbi1Length(pc)
    addr = @getGbi1RspSegmentAddr(pc)
    @videoLog "movemem type=" + type + ", length=" + length + " addr=" + addr
    return

  C1964jsVideoHLE::RSP_GBI1_SpNoop = (pc) ->
    @videoLog "RSP_GBI1_SpNoop"
    return

  C1964jsVideoHLE::RSP_GBI1_Reserved = (pc) ->
    @videoLog "RSP_GBI1_Reserved"
    return

  C1964jsVideoHLE::setProjection = (mat, bPush, bReplace) ->
    if bPush
      @gRSP.projectionMtxTop += 1  if @gRSP.projectionMtxTop < (@RICE_MATRIX_STACK - 1)
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
      @gRSP.modelViewMtxTop += 1  if @gRSP.modelViewMtxTop < (@RICE_MATRIX_STACK - 1)
      
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
    @videoLog "RSP_GBI0_Mtx addr: " + dec2hex(addr)
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
        hi = (@core.memory.rdramUint8Array[a] << 8 | @core.memory.rdramUint8Array[a + 1]) << 16 >> 16
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
    @texImg.width = @getTImgWidth(pc)
    @texImg.addr = @getTImgAddr(pc)
    @texImg.bpl = @texImg.width << @texImg.size >> 1
    @texImg.changed = true #no texture cache
    @videoLog "TODO: DLParser_SetTImg"
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
    if @gRSP.bMatrixIsUpdated
      pmtx = undefined
      vmtx = @gRSP.modelviewMtxs[@gRSP.modelViewMtxTop]
      pmtx = @gRSP.projectionMtxs[@gRSP.projectionMtxTop]
      mat4.multiply pmtx, vmtx, @gRSPworldProject
      
      #this.gRSPworldProject = this.gRSP.modelviewMtxs[this.gRSP.modelViewMtxTop] * this.gRSP.projectionMtxs[this.gRSP.projectionMtxTop];
      @gRSP.bMatrixIsUpdated = false
      @gRSP.bCombinedMatrixIsUpdated = true
    @gRSP.bCombinedMatrixIsUpdated = false
    return

  C1964jsVideoHLE::processVertexData = (addr, v0, num) ->
    a = undefined
    i = v0
    @updateCombinedMatrix()
    i = v0
    while i < v0 + num
      a = addr + 16 * (i - v0)
	  
	  # Legacy 
      @vtxNonTransformed[i] = {}
      @vtxNonTransformed[i].x = @getFiddledVertexX(a)
      @vtxNonTransformed[i].y = @getFiddledVertexY(a)
      @vtxNonTransformed[i].z = @getFiddledVertexZ(a)
	  # End Legacy
	  
      @N64VertexList[i].x = @getVertexX(a)
      @N64VertexList[i].y = @getVertexY(a)
      @N64VertexList[i].z = @getVertexZ(a)
	  
      @N64VertexList[i].s = @getVertexS(a)
      @N64VertexList[i].t = @getVertexT(a)
	  
      @N64VertexList[i].r = @getVertexColorR(a)
      @N64VertexList[i].g = @getVertexColorG(a)
      @N64VertexList[i].b = @getVertexColorB(a)
      @N64VertexList[i].a = @getVertexAlpha(a)
	  
      @N64VertexList[i].nx = @toSByte @getVertexNormalX(a)
      @N64VertexList[i].ny = @toSByte @getVertexNormalY(a)
      @N64VertexList[i].nz = @toSByte @getVertexNormalZ(a)

      #Legacy
      @vtxTransformed[i] = {}
      @vtxTransformed[i].x = @vtxNonTransformed[i].x * @gRSPworldProject[0] + @vtxNonTransformed[i].y * @gRSPworldProject[4] + @vtxNonTransformed[i].z * @gRSPworldProject[8] + @gRSPworldProject[12]
      @vtxTransformed[i].y = @vtxNonTransformed[i].x * @gRSPworldProject[1] + @vtxNonTransformed[i].y * @gRSPworldProject[5] + @vtxNonTransformed[i].z * @gRSPworldProject[9] + @gRSPworldProject[13]
      @vtxTransformed[i].z = @vtxNonTransformed[i].x * @gRSPworldProject[2] + @vtxNonTransformed[i].y * @gRSPworldProject[6] + @vtxNonTransformed[i].z * @gRSPworldProject[10] + @gRSPworldProject[14]
      @vtxTransformed[i].w = @vtxNonTransformed[i].x * @gRSPworldProject[3] + @vtxNonTransformed[i].y * @gRSPworldProject[7] + @vtxNonTransformed[i].z * @gRSPworldProject[11] + @gRSPworldProject[15]
      @vecProjected[i] = {}
      @vecProjected[i].w = 1.0 / @vtxTransformed[i].w
      @vecProjected[i].x = @vtxTransformed[i].x * @vecProjected[i].w
      @vecProjected[i].y = @vtxTransformed[i].y * @vecProjected[i].w
      @vecProjected[i].z = @vtxTransformed[i].z * @vecProjected[i].w
      
      #temp
      @vtxTransformed[i].x = @vecProjected[i].x
      @vtxTransformed[i].y = @vecProjected[i].y
      @vtxTransformed[i].z = @vecProjected[i].z
      i += 1
    return

  C1964jsVideoHLE::DLParser_SetCImg = (pc) ->
    @videoLog "TODO: DLParser_SetCImg"
    return

  #Gets new display list address
  C1964jsVideoHLE::RSP_GBI0_DL = (pc) ->
    param = undefined
    addr = undefined
    seg = @getGbi0DlistAddr(pc)
    addr = @getRspSegmentAddr(seg)
    @videoLog "dlist address = " + dec2hex(addr)
    
    #TODO: address adjust
    param = @getGbi0DlistParam(pc)
    @dlistStackPointer += 1  if param is consts.RSP_DLIST_PUSH
    @dlistStack[@dlistStackPointer].pc = addr
    @dlistStack[@dlistStackPointer].countdown = consts.MAX_DL_COUNT
    return

  C1964jsVideoHLE::DLParser_SetCombine = (pc) ->
    @videoLog "TODO: DLParser_SetCombine"
    return

  C1964jsVideoHLE::RSP_GBI1_MoveWord = (pc) ->
    @videoLog "RSP_GBI1_MoveWord"
    switch @getGbi0MoveWordType(pc)
      when consts.RSP_MOVE_WORD_MATRIX
        @RSP_RDP_InsertMatrix()
      when consts.RSP_MOVE_WORD_SEGMENT
        dwBase = undefined
        dwSegment = (@getGbi0MoveWordOffset(pc) >> 2) & 0x0F
        dwBase = @getGbi0MoveWordValue(pc) & 0x00FFFFFF
        @segments[dwSegment] = dwBase
      else
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
    @gRSP.bCombinedMatrixIsUpdated = true
    return

  C1964jsVideoHLE::DLParser_SetScissor = (pc) ->
    @videoLog "TODO: DLParser_SetScissor"
    return

  C1964jsVideoHLE::RSP_GBI1_SetOtherModeH = (pc) ->
    @videoLog "TODO: DLParser_GBI1_SetOtherModeH"
    return

  C1964jsVideoHLE::RSP_GBI1_SetOtherModeL = (pc) ->
    @videoLog "TODO: DLParser_GBI1_SetOtherModeL"
    return

  C1964jsVideoHLE::RSP_GBI0_Sprite2DBase = (pc) ->
    @videoLog "TODO: RSP_GBI0_Sprite2DBase"
    return

  C1964jsVideoHLE::RSP_GBI0_Tri4 = (pc) ->
    @videoLog "TODO: RSP_GBI0_Tri4"
    return

  C1964jsVideoHLE::RSP_GBI1_RDPHalf_Cont = (pc) ->
    @videoLog "TODO: RSP_GBI1_RDPHalf_Cont"
    return

  C1964jsVideoHLE::RSP_GBI1_RDPHalf_2 = (pc) ->
    @videoLog "TODO: RSP_GBI1_RDPHalf_2"
    return

  C1964jsVideoHLE::RSP_GBI1_RDPHalf_1 = (pc) ->
    @videoLog "TODO: RSP_GBI1_RDPHalf_1"
    return

  C1964jsVideoHLE::RSP_GBI1_Line3D = (pc) ->
    @videoLog "TODO: RSP_GBI1_Line3D"
    return

  C1964jsVideoHLE::RSP_GBI1_ClearGeometryMode = (pc) ->
    @videoLog "TODO: RSP_GBI1_ClearGeometryMode"
    return

  C1964jsVideoHLE::RSP_GBI1_SetGeometryMode = (pc) ->
    @videoLog "TODO: RSP_GBI1_SetGeometryMode"
    return

  C1964jsVideoHLE::RSP_GBI1_EndDL = (pc) ->
    @videoLog "RSP_GBI1_EndDL"
    @RDP_GFX_PopDL()
    return

  C1964jsVideoHLE::RSP_GBI1_Texture = (pc) ->
    tile = @getTextureTile(pc)
    @textureTiles[tile].on    = @getTextureOn(pc)
    @textureTiles[tile].level = @getTextureLevel(pc)
    @textureTiles[tile].scales = @getTextureScaleS(pc) / 0x8000
    @textureTiles[tile].scalet = @getTextureScaleT(pc) / 0x8000
    #console.log "RSP_GBI1_Texture: Tile:" + tile + " On:" + @textureTiles[tile].on + " Level:" + @textureTiles[tile].level + " ScaleS:" + @textureTiles[tile].scales + " ScaleT:" + @textureTiles[tile].scalet
    return

  #test for dummy gray textures
  #create a heap of dummy texture mem.
  testTextureMem = new Array(256 * 256 * 4)
  testTextureMem = new Uint8Array(testTextureMem)
  k = 0
  while k < 1024 * 1024
    testTextureMem[k] = 128
    k++

  C1964jsVideoHLE::RSP_GBI1_PopMtx = (pc) ->
    @videoLog "TODO: RSP_GBI1_PopMtx"
    return

  C1964jsVideoHLE::RSP_GBI1_CullDL = (pc) ->
    @videoLog "TODO: RSP_GBI1_CullDL"
    return

  C1964jsVideoHLE::RSP_GBI1_Tri1 = (pc) ->
    v2 = undefined
    v1 = undefined
    v0 = @getGbi0Tri1V0(pc) / @gRSP.vertexMult
    v1 = @getGbi0Tri1V1(pc) / @gRSP.vertexMult
    v2 = @getGbi0Tri1V2(pc) / @gRSP.vertexMult
    didSucceed = @prepareTriangle v1, v2, v0
    if didSucceed is false
      @drawScene(false, 7)
      @triangleVertexPositionBuffer.numItems = 0
      @triangleVertexColorBuffer.numItems = 0
      @gRSP.numVertices = 0
      return

    cmd = @getCommand(pc+8)
    func = @currentMicrocodeMap[cmd]

    if @dlistStackPointer >= 0
      if @dlistStack[@dlistStackPointer].countdown is 0
        if @dlistStackPointer - 1 < 0
          @drawScene(false, 7)
          return

    if func[12] isnt "1"
      if @core.settings.wireframe is true
        @drawScene false, 7
      else
        #@drawScene true, 7 #not ready yet
        @drawScene false, 7

      @triangleVertexPositionBuffer.numItems = 0
      @triangleVertexColorBuffer.numItems = 0
      @gRSP.numVertices = 0
    return

  C1964jsVideoHLE::RSP_GBI1_Noop = (pc) ->
    @videoLog "TODO: RSP_GBI1_Noop"
    return

  C1964jsVideoHLE::RDP_TriFill = (pc) ->
    @videoLog "TODO: RDP_TriFill"
    return

  C1964jsVideoHLE::RDP_TriFillZ = (pc) ->
    @videoLog "RDP_TriFillZ"
    return

  C1964jsVideoHLE::RDP_TriTxtr = (pc) ->
    @videoLog "TODO: RDP_TriTxtr"
    return

  C1964jsVideoHLE::RDP_TriTxtrZ = (pc) ->
    @videoLog "TODO: RDP_TriTxtrZ"
    return

  C1964jsVideoHLE::RDP_TriShade = (pc) ->
    @videoLog "TODO: RDP_TriShade"
    return

  C1964jsVideoHLE::RDP_TriShadeZ = (pc) ->
    @videoLog "TODO: RDP_TriShadeZ"
    return

  C1964jsVideoHLE::RDP_TriShadeTxtr = (pc) ->
    @videoLog "TODO: RDP_TriShadeTxtr"
    return

  C1964jsVideoHLE::RDP_TriShadeTxtrZ = (pc) ->
    @videoLog "TODO: RDP_TriShadeTxtrZ"
    return

  C1964jsVideoHLE::DLParser_TexRect = (pc) ->
    @videoLog "TODO: DLParser_TexRect"
    xl = undefined
    yl = undefined
    s = undefined
    t = undefined
    dsdx = undefined
    dtdy = undefined
    yh = undefined
    tileno = undefined
    xh = @getTexRectXh(pc)
    yh = @getTexRectYh(pc)
    tileno = @getTexRectTileNo(pc)
    xl = @getTexRectXl(pc)
    yl = @getTexRectYl(pc)
    s = @getTexRectS(pc)
    t = @getTexRectT(pc)
    dsdx = @getTexRectDsDx(pc)
    dtdy = @getTexRectDtDy(pc)
    @renderer.texRect xl, yl, xh, yh, s, t, dsdx, dtdy, tileno, @core.memory.rdramUint8Array, @texImg
    @dlistStack[@dlistStackPointer].pc += 8
    return

  C1964jsVideoHLE::DLParser_TexRectFlip = (pc) ->
    @dlistStack[@dlistStackPointer].pc += 8
    @videoLog "TODO: DLParser_TexRectFlip"
    return

  C1964jsVideoHLE::DLParser_RDPLoadSynch = (pc) ->
    @videoLog "TODO: DLParser_RDPLoadSynch"
    return

  C1964jsVideoHLE::DLParser_RDPPipeSynch = (pc) ->
    @videoLog "TODO: DLParser_RDPPipeSynch"
    return

  C1964jsVideoHLE::DLParser_RDPTileSynch = (pc) ->
    @videoLog "TODO: DLParser_RDPTileSynch"
    return

  C1964jsVideoHLE::DLParser_RDPFullSynch = (pc) ->
    @videoLog "TODO: DLParser_RDPFullSynch"
    @core.interrupts.triggerDPInterrupt 0, false
    return

  C1964jsVideoHLE::DLParser_SetKeyGB = (pc) ->
    @videoLog "TODO: DLParser_SetKeyGB"
    return

  C1964jsVideoHLE::DLParser_SetKeyR = (pc) ->
    @videoLog "TODO: DLParser_SetKeyR"
    return

  C1964jsVideoHLE::DLParser_SetConvert = (pc) ->
    @videoLog "TODO: DLParser_SetConvert"
    return

  C1964jsVideoHLE::DLParser_SetPrimDepth = (pc) ->
    @videoLog "TODO: DLParser_SetPrimDepth"
    return

  C1964jsVideoHLE::DLParser_RDPSetOtherMode = (pc) ->
    @videoLog "TODO: DLParser_RDPSetOtherMode"
    return

  C1964jsVideoHLE::DLParser_LoadTLut = (pc) ->
    @videoLog "TODO: DLParser_LoadTLut"
    return

  C1964jsVideoHLE::DLParser_SetTileSize = (pc) ->
    @videoLog "TODO: DLParser_SetTileSize"
    return

  C1964jsVideoHLE::DLParser_LoadBlock = (pc) ->
    # this.texImg.changed = true;
    @videoLog "TODO: DLParser_LoadBlock"
    return

  C1964jsVideoHLE::DLParser_LoadTile = (pc) ->
    @videoLog "TODO: DLParser_LoadTile"
    return

  C1964jsVideoHLE::DLParser_SetTile = (pc) ->
    @videoLog "TODO: DLParser_SetTile"
    return

  C1964jsVideoHLE::DLParser_FillRect = (pc) ->
    @videoLog "TODO: DLParser_FillRect"
    return

  C1964jsVideoHLE::DLParser_SetFillColor = (pc) ->
    @videoLog "TODO: DLParser_SetFillColor"
    return

  C1964jsVideoHLE::DLParser_SetFogColor = (pc) ->
    @videoLog "TODO: DLParser_SetFogColor"
    return

  C1964jsVideoHLE::DLParser_SetBlendColor = (pc) ->
    @videoLog "TODO: DLParser_SetBlendColor"
    return

  C1964jsVideoHLE::DLParser_SetPrimColor = (pc) ->
    @videoLog "TODO: DLParser_SetPrimColor"
    return

  C1964jsVideoHLE::DLParser_SetEnvColor = (pc) ->
    @videoLog "TODO: DLParser_SetEnvColor"
    return

  C1964jsVideoHLE::DLParser_SetZImg = (pc) ->
    @videoLog "TODO: DLParser_SetZImg"
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
    return false  if vtxIndex >= consts.MAX_VERTS
    @vtxProjected5[vtxIndex] = []  if @vtxProjected5[vtxIndex] is `undefined` and vtxIndex < consts.MAX_VERTS
    return false  if @vtxTransformed[dwV] is `undefined`
    @vtxProjected5[vtxIndex][0] = @vtxTransformed[dwV].x
    @vtxProjected5[vtxIndex][1] = @vtxTransformed[dwV].y
    @vtxProjected5[vtxIndex][2] = @vtxTransformed[dwV].z
    @vtxProjected5[vtxIndex][3] = @vtxTransformed[dwV].w
    @vtxProjected5[vtxIndex][4] = @vecProjected[dwV].z
    @vtxProjected5[vtxIndex][4] = 0 if @vtxTransformed[dwV].w < 0
    vtxIndex[vtxIndex] = vtxIndex

    #this.gl.bindBuffer(this.gl.ARRAY_BUFFER, this.triangleVertexPositionBuffer);
    offset = 3 * (@triangleVertexPositionBuffer.numItems)
    @triVertices[offset] = @vtxProjected5[vtxIndex][0]
    @triVertices[offset + 1] = @vtxProjected5[vtxIndex][1]
    @triVertices[offset + 2] = @vtxProjected5[vtxIndex][2]
    @triangleVertexPositionBuffer.itemSize = 3
    @triangleVertexPositionBuffer.numItems += 1

    #hack: throw in some color
    colorOffset = 4 * (@triangleVertexColorBuffer.numItems)
    @triColorVertices[colorOffset] = @triVertices[offset+2] / 20
    @triColorVertices[colorOffset + 1] = @triVertices[offset+2] / 20
    @triColorVertices[colorOffset + 2] = @triVertices[offset+2] / 20
    @triColorVertices[colorOffset + 3] = 1.0

    @triangleVertexColorBuffer.itemSize = 4
    @triangleVertexColorBuffer.numItems += 1
    true

  C1964jsVideoHLE::drawScene = (useTexture, tileno) ->
    @core.webGL.switchShader @core.webGL.triangleShaderProgram, @core.settings.wireframe

    @gl.disable @gl.DEPTH_TEST
    @gl.enable @gl.BLEND
    @gl.blendFunc @gl.SRC_ALPHA, @gl.ONE
    
    #simple lighting. Get the normal matrix of the model-view matrix

    @gl.bindBuffer @gl.ARRAY_BUFFER, @triangleVertexPositionBuffer
    @gl.bufferData @gl.ARRAY_BUFFER, new Float32Array(@triVertices), @gl.STATIC_DRAW
    @gl.vertexAttribPointer @core.webGL.triangleShaderProgram.vertexPositionAttribute, @triangleVertexPositionBuffer.itemSize, @gl.FLOAT, false, 0, 0
    
    @gl.bindBuffer @gl.ARRAY_BUFFER, @triangleVertexColorBuffer
    @gl.bufferData @gl.ARRAY_BUFFER, new Float32Array(@triColorVertices), @gl.STATIC_DRAW
    @gl.vertexAttribPointer @core.webGL.triangleShaderProgram.vertexColorAttribute, @triangleVertexColorBuffer.itemSize, @gl.FLOAT, false, 0, 0

    #@gl.bindBuffer @gl.ARRAY_BUFFER, @triangleVertexTextureCoordBuffer
    #@gl.bufferData @gl.ARRAY_BUFFER, new Float32Array(@triTextureCoords), @gl.STATIC_DRAW
    @gl.vertexAttribPointer @core.webGL.triangleShaderProgram.textureCoordAttribute, @triangleVertexTextureCoordBuffer.itemSize, @gl.FLOAT, false, 0, 0
    if useTexture is true
      @gl.activeTexture @gl.TEXTURE0
      @gl.bindTexture @gl.TEXTURE_2D, window["neheTexture" + tileno]
    @gl.uniform1i @core.webGL.triangleShaderProgram.samplerUniform, 0
    
    #  this.gl.bindBuffer(this.gl.ELEMENT_ARRAY_BUFFER, cubeVertexIndexBuffer);
    @core.webGL.setMatrixUniforms @core.webGL.triangleShaderProgram
    if @core.settings.wireframe is true
      @gl.drawArrays @gl.LINES, 0, @triangleVertexPositionBuffer.numItems
    else
      @gl.drawArrays @gl.TRIANGLES, 0, @triangleVertexPositionBuffer.numItems
    return

  #  mvPopMatrix();
  C1964jsVideoHLE::initBuffers = ->
    @triangleVertexPositionBuffer = @gl.createBuffer()
    @gl.bindBuffer @gl.ARRAY_BUFFER, @triangleVertexPositionBuffer
    @triVertices = [0.0, 1.0, 0.0, -1.0, -1.0, 0.0, 1.0, -1.0, 0.0]
    @triangleVertexPositionBuffer.itemSize = 3
    @triangleVertexPositionBuffer.numItems = @triVertices.length / 3

    @triangleVertexColorBuffer = @gl.createBuffer()
    @gl.bindBuffer @gl.ARRAY_BUFFER, @triangleVertexColorBuffer
    @triColorVertices = [0.5, 1.0, 0.5, 1.0]
    @triangleVertexColorBuffer.itemSize = 4
    @triangleVertexColorBuffer.numItems = @triColorVertices.length / 4

    @triangleVertexTextureCoordBuffer = @gl.createBuffer()
    @gl.bindBuffer @gl.ARRAY_BUFFER, @triangleVertexTextureCoordBuffer
   
    #front face
    @triTextureCoords = [1.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0, 0.0, 1.0]
    @gl.bufferData @gl.ARRAY_BUFFER, new Float32Array(@triTextureCoords), @gl.STATIC_DRAW
    @gl.vertexAttribPointer @core.webGL.triangleShaderProgram.vertexPositionAttribute, @triangleVertexPositionBuffer.itemSize, @gl.FLOAT, false, 0, 0
    @triangleVertexTextureCoordBuffer.itemSize = 3
    @triangleVertexTextureCoordBuffer.numItems = @triTextureCoords.length / 3
    return
)()
#hack global space until we export classes properly
#node.js uses exports; browser uses this (window)
root = exports ? this
root.C1964jsVideoHLE = C1964jsVideoHLE