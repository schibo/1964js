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
"use strict"

class C1964jsVideoHLE
  constructor: (core, glx) ->
    @ucode = -1
    @processDisplayList = @callBind @processDisplayList, this

    i = undefined    
    ###*
     * @const
    ###
    @core = core #only needed for gfxHelpers prototypes to access.
    ###*
     * @const
    ###
    @gl = glx

    @fogIsImplemented = false #enable this when we supoort fog

    #todo: make gRSP a class object.
    @RICE_MATRIX_STACK = 60
    @MAX_TEXTURES = 8
    @MAX_VERTICES = 80
    @MAX_TILES = 8
    @tmem = new Uint8Array(1024 * 4)
    @activeTile = 0
    @textureTile = []
    @zDepthImage = {fmt: 0, siz: 0, width: 0, addr: 0}
    @zColorImage = {fmt: 0, siz: 0, width: 0, addr: 0}
    ###*
     * @const
    ###
    @N64VertexList = []
    @geometryMode = 0
    ###*
     * @const
    ###
    @gRSP = {}
    ###*
     * @const
    ###
    @gRSPlights = [{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{}]
    ###*
     * @const
    ###
    @gRSPn64lights = [{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{}]
    @gRSPnumLights = 0
    @matToLoad = mat4.create()
    @lightingMat = mat4.create()
    @triangleVertexPositionBuffer = `undefined`
    @triangleVertexColorBuffer = `undefined`
    @dlistStackPointer = 0
    @dlistStack = []

    if core.isLittleEndian is 1 and core.useByteCompatibilityMode is false
      @renderer = new C1964jsRendererLE @core.settings, @core.webGL.gl, @core.webGL
    else
      @renderer = new C1964jsRenderer @core.settings, @core.webGL.gl, @core.webGL
    
    @texImg = {}
    @segments = []
    @gl.useProgram @core.webGL.shaderProgram
    ###*
     * @const
    ###
    @primColor = [0.0, 0.0, 0.0, 0.0]
    ###*
     * @const
    ###
    @fillColor = [0.0, 0.0, 0.0, 0.0]
    ###*
     * @const
    ###
    @blendColor = [0.0, 0.0, 0.0, 0.0]
    ###*
     * @const
    ###
    @envColor = [0.0, 0.0, 0.0, 0.0]
    ###*
     * @const
    ###
    @triVertices = new Float32Array(16384)
    ###*
     * @const
    ###
    @triColorVertices = new Uint8Array(16384)
    ###*
     * @const
    ###
    @triTextureCoords = new Float32Array(16384)

    @tempVec4 = new Float32Array 4
    @tempVec3Buffer = new ArrayBuffer(3 * @MAX_VERTICES * 4)

    @otherModeL = 0
    @otherModeH = 0
    @cycleType = 0
    @alphaTestEnabled = 0
    @bShade = false
    @bTextureGen = false
    @bLightingEnable = false
    @bFogEnable = false
    @bZBufferEnable = false
    @colorsTexture0 = @gl.createTexture()
    @colorsTexture1 = @gl.createTexture()
    @renderStateChanged = false
    @inverseTransposeCalculated = false

    ###*
     * @const
    ###
    @normalMat = new Float32Array 4
    ###*
     * @const
    ###
    @modelViewInverse = mat4.create()
    ###*
     * @const
    ###
    @modelViewTransposedInverse = mat4.create()

    # Native Viewport
    @n64ViewportWidth = 640
    @n64ViewportHeight = 480
    @n64ViewportLeft = 0
    @n64ViewportTop = 0
    @n64ViewportRight = 320
    @n64ViewportBottom = 240

    ###*
     * Microcode 0 LUT
     * @type {!Array<!function(number)>}
     * @const
    ###

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

    @gl.clearColor 0.0, 0.0, 0.0, 0.0
    @gl.depthFunc @gl.LEQUAL
    @gl.clearDepth 1.0
    @gl.disable @gl.DEPTH_TEST

    #todo: allocate on-demand
    i = 0
    while i < @RICE_MATRIX_STACK
      @gRSP.projectionMtxs[i] = mat4.create()
      @gRSP.modelviewMtxs[i] = mat4.create()
      i += 1
    @triangleVertexTextureCoordBuffer = `undefined`
    @resetMatrices()
    @combine = new Uint32Array(16)
    @makeUcodeData()
    @makeUcodeMap()
    @crcTable = @makeCRCTable()

    @vertexMultVals = [
      10, # ucode 0 - Mario
      2,  # ucode 1 - GBI1
      10, # ucode 2 - Golden Eye
      2,  # ucode 3 - S2DEX GBI2
      5,  # ucode 4 - Wave Racer
      2,  # ucode 5 - BGI2
      10, # ucode 6 - DKR
      2,  # ucode 7 - S2DEX
      10, # ucode 8 - ucode 0 with sprite2D, for Demo Puzzle Master 64
      10, # ucode 9 - Perfect Dark
      2,  # ucode 10 - Conker
      10, # ucode 11 - Gemini
      2,  # ucode 12 - Silicon Valley, Spacestation
      2,  # ucode 13 - modified ucode S2DEX
      2,  # ucode 14 - OgreBattle Background
      10, # ucode 15 - ucode 0 with sprite2D
      5,  # ucode 16 - Star War, Shadow of Empire

      2,  # ucode 17 - Star Wars - Rogue Squadron, 
      2,  # ucode 18 - World Driver Championship, check me here
      2,  # ucode 19 - Last Legion UX, check me here
      2,  # ucode 20 - ZSortp
    ]
    return

  makeUcodeMap: () ->
    @microcodeMap0 = [@RSP_GBI1_SpNoop, @RSP_GBI0_Mtx, @RSP_GBI1_Reserved, @RSP_GBI1_MoveMem,
      @RSP_GBI0_Vtx, @RSP_GBI1_Reserved, @RSP_GBI0_DL, @RSP_GBI1_Reserved,
      @RSP_GBI1_Reserved, @RSP_GBI0_Sprite2DBase, @RSP_RDP_Nothing, @RSP_RDP_Nothing,
      @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing,
      @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing,
      @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing,
      @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing,
      @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing,
      @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing,
      @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing,
      @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing,
      @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing,
      @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing,
      @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing,
      @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing,
      @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing,
      @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing,
      @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing,
      @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing,
      @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing,
      @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing,
      @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing,
      @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing,
      @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing,
      @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing,
      @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing,
      @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing,
      @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing,
      @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing,
      @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing,
      @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing,
      @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing,
      @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing,
      @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing,
      @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing,
      @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing,
      @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing,
      @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing,
      @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing,
      @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing,
      @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing,
      @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing,
      @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing,
      @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing,
      @RSP_RDP_Nothing, @RSP_GBI0_Tri4, @RSP_GBI1_RDPHalf_Cont, @RSP_GBI1_RDPHalf_2,
      @RSP_GBI1_RDPHalf_1, @RSP_GBI1_Line3D, @RSP_GBI1_ClearGeometryMode, @RSP_GBI1_SetGeometryMode,
      @RSP_GBI1_EndDL, @RSP_GBI1_SetOtherModeL, @RSP_GBI1_SetOtherModeH, @RSP_GBI1_Texture,
      @RSP_GBI1_MoveWord, @RSP_GBI1_PopMtx, @RSP_GBI1_CullDL, @RSP_GBI1_Tri1,
      @RSP_GBI1_Noop, @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing,
      @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing,
      @RDP_TriFill, @RDP_TriFillZ, @RDP_TriTxtr, @RDP_TriTxtrZ,
      @RDP_TriShade, @RDP_TriShadeZ, @RDP_TriShadeTxtr, @RDP_TriShadeTxtrZ,
      @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing,
      @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing,
      @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing,
      @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing,
      @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing, @RSP_RDP_Nothing,
      @DLParser_TexRect, @DLParser_TexRectFlip, @DLParser_RDPLoadSynch, @DLParser_RDPPipeSynch,
      @DLParser_RDPTileSynch, @DLParser_RDPFullSynch, @DLParser_SetKeyGB, @DLParser_SetKeyR,
      @DLParser_SetConvert, @DLParser_SetScissor, @DLParser_SetPrimDepth, @DLParser_RDPSetOtherMode,
      @DLParser_LoadTLut, @RSP_RDP_Nothing, @DLParser_SetTileSize, @DLParser_LoadBlock,
      @DLParser_LoadTile, @DLParser_SetTile, @DLParser_FillRect, @DLParser_SetFillColor,
      @DLParser_SetFogColor, @DLParser_SetBlendColor, @DLParser_SetPrimColor, @DLParser_SetEnvColor,
      @DLParser_SetCombine, @DLParser_SetTImg, @DLParser_SetZImg, @DLParser_SetCImg]
    return



  makeUcodeData: () ->
    @ucodeData = [
      #ucode, crc_size, crc_800, ucode_name, non_nearclip, reject
      [0, 0x150c3ce8, 0x150c3ce8, "RSP SW Version: 2.0D, 04-01-96"], # Super Mario 64
      [4, 0x2b94276f, 0x2b94276f, "RSP SW Version: 2.0D, 04-01-96"], # Wave Race 64 (v1.0)
      [16,0xb1870454, 0xb1870454, "RSP SW Version: 2.0D, 04-01-96"], # Star Wars - Shadows of the Empire (v1.0),
      [0, 0x51671ae4, 0x51671ae4, "RSP SW Version: 2.0D, 04-01-96"], # Pilot Wings 64,
      [0, 0x67b5ac55, 0x67b5ac55, "RSP SW Version: 2.0D, 04-01-96"], # Wibble,
      [0, 0x64dc8104, 0x64dc8104, "RSP SW Version: 2.0D, 04-01-96"], # Dark Rift,
      [0, 0x309f363d, 0x309f363d, "RSP SW Version: 2.0D, 04-01-96"], # Killer Instinct Gold,
      [0, 0xfcb57e57, 0xfcb57e57, "RSP SW Version: 2.0D, 04-01-96"], # Blast Corps,
      [0, 0xb420f35a, 0xb420f35a, "RSP SW Version: 2.0D, 04-01-96"], # Blast Corps,
      [0, 0x6e26c1df, 0x7c98e9c2, "RSP SW Version: 2.0D, 04-01-96"],
      [2, 0xc02ac7bc, 0xc02ac7bc, "RSP SW Version: 2.0G, 09-30-96"], # GoldenEye 007,
      [0, 0xe5fee3bc, 0xe5fee3bc, "RSP SW Version: 2.0G, 09-30-96"], # Aero Fighters Assault,
      [8, 0xe4bb5ad8, 0x80129845, "RSP SW Version: 2.0G, 09-30-96"], # Puzzle Master 64,
      [0, 0x72109ec6, 0x72109ec6, "RSP SW Version: 2.0H, 02-12-97"], # Duke Nukem 64,
      [0, 0xf24a9a04, 0xf24a9a04, "RSP SW Version: 2.0H, 02-12-97"], # Tetrisphere,
      [15,0x700de42e, 0x700de42e, "RSP SW Version: 2.0H, 02-12-97"], # Wipeout 64 (uses GBI1 too!),
      [15,0x1b304a74, 0x1b304a74, "RSP SW Version: 2.0H, 02-12-97"], # Flying Dragon,
      [15,0xe4bb5ad8, 0xa7b2f704, "RSP SW Version: 2.0H, 02-12-97"], # Silicon Valley,
      [15,0xe4bb5ad8, 0x88202781, "RSP SW Version: 2.0H, 02-12-97"], # Glover,
      [0, 0xe466b5bd, 0xe466b5bd, "Unknown 0xe466b5bd, 0xe466b5bd"], # Dark Rift,
      [9, 0x7064a163, 0x7064a163, "Unknown 0x7064a163, 0x7064a163"], # Perfect Dark (v1.0),
      [0, 0x6522df69, 0x71bd078d, "Unknown 0x6522df69, 0x71bd078d"], # Tetris
      [0, 0x6522df69, 0x1b0c23a8, "Unknown 0x6522df69, 0x1b0c23a8"], # Pachinko Nichi
      # GBI1
      [1, 0x45ca328e, 0x45ca328e, "RSP Gfx ucode F3DLX 0.95 Yoshitaka Yasumoto Nintendo."], # Mario Kart 64,
      [1, 0x98e3b909, 0x98e3b909, "RSP Gfx ucode F3DEX 0.95 Yoshitaka Yasumoto Nintendo."],  # Mario Kart 64
      [1, 0x5d446090, 0x5d446090, "RSP Gfx ucode F3DLP.Rej 0.96 Yoshitaka Yasumoto Nintendo.",0,1], # Jikkyou J. League Perfect Striker,
      [1, 0x244f5ca3, 0x244f5ca3, "RSP Gfx ucode F3DEX 1.00 Yoshitaka Yasumoto Nintendo."], # F-1 Pole Position 64,
      [1, 0x6a022585, 0x6a022585, "RSP Gfx ucode F3DEX.NoN 1.00 Yoshitaka Yasumoto Nintendo.",1], # Turok - The Dinosaur Hunter (v1.0),
      [1, 0x150706be, 0x150706be, "RSP Gfx ucode F3DLX.NoN 1.00 Yoshitaka Yasumoto Nintendo.",1], # Extreme-G,
      [1, 0x503f2c53, 0x503f2c53, "RSP Gfx ucode F3DEX.NoN 1.21 Yoshitaka Yasumoto Nintendo.",1], # Bomberman 64,
      [1, 0xc705c37c, 0xc705c37c, "RSP Gfx ucode F3DLX 1.21 Yoshitaka Yasumoto Nintendo."], # Fighting Force 64, Wipeout 64
      [1, 0xa2146075, 0xa2146075, "RSP Gfx ucode F3DLX.NoN 1.21 Yoshitaka Yasumoto Nintendo.",1], # San Francisco Rush - Extreme Racing,
      [1, 0xb65aa2da, 0xb65aa2da, "RSP Gfx ucode L3DEX 1.21 Yoshitaka Yasumoto Nintendo."], # Wipeout 64,
      [1, 0x0c8e5ec9, 0x0c8e5ec9, "RSP Gfx ucode F3DEX 1.21 Yoshitaka Yasumoto Nintendo."], #
      [1, 0xe30795f2, 0xa53df3c4, "RSP Gfx ucode F3DLP.Rej 1.21 Yoshitaka Yasumoto Nintendo.",0,1],
      [1, 0xaebeda7d, 0xaebeda7d, "RSP Gfx ucode F3DLX.Rej 1.21 Yoshitaka Yasumoto Nintendo.",0,1], # Jikkyou World Soccer 3,
      [1, 0x0c8e5ec9, 0x0c8e5ec9, "RSP Gfx ucode F3DEX 1.23 Yoshitaka Yasumoto Nintendo" ], # Wave Race 64 (Rev. 2) - Shindou Rumble Edition (JAP)
      [1, 0xc705c37c, 0xc705c37c, "RSP Gfx ucode F3DLX 1.23 Yoshitaka Yasumoto Nintendo."], # GT
      [1, 0x2a61350d, 0x2a61350d, "RSP Gfx ucode F3DLX 1.23 Yoshitaka Yasumoto Nintendo."], # Toy Story2
      [1, 0x0c8e5ec9, 0x0c8e5ec9, "RSP Gfx ucode F3DEX 1.23 Yoshitaka Yasumoto Nintendo."], # Wave Race 64 Shindou Edition
      [12,0xfc6529aa, 0xfc6529aa, "RSP Gfx ucode F3DEX 1.23 Yoshitaka Yasumoto Nintendo."], # Superman - The Animated Series,
      [1, 0xa56cf996, 0xa56cf996, "RSP Gfx ucode L3DEX 1.23 Yoshitaka Yasumoto Nintendo."], # Flying Dragon,
      [1, 0xcc83b43f, 0xcc83b43f, "RSP Gfx ucode F3DEX.NoN 1.23 Yoshitaka Yasumoto Nintendo.",1], # AeroGauge,
      [1, 0xca8927a0, 0xca8927a0, "RSP Gfx ucode F3DLX.Rej 1.23 Yoshitaka Yasumoto Nintendo.",0,1], # Puzzle Bobble 64,
      [1, 0x25689c75, 0xbe481ae8, "RSP Gfx ucode F3DLP.Rej 1.23 Yoshitaka Yasumoto Nintendo.",0,1],
      [1, 0xd2d747b7, 0xd2d747b7, "RSP Gfx ucode F3DLX.NoN 1.23 Yoshitaka Yasumoto Nintendo.",1], # Penny Racers,
      [1, 0xa849c858, 0x5bd32b5a, "RSP Gfx ucode F3DTEX/A 1.23 Yoshitaka Yasumoto Nintendo."], # Tamagotchi
      [7, 0xecd8b772, 0xecd8b772, "RSP Gfx ucode S2DEX 1.06 Yoshitaka Yasumoto Nintendo."], # Yoshi's Story,
      [7, 0xf59132f5, 0xf59132f5, "RSP Gfx ucode S2DEX 1.07 Yoshitaka Yasumoto Nintendo."], # Bakuretsu Muteki Bangaioh,
      [7, 0x961dd811, 0x961dd811, "RSP Gfx ucode S2DEX 1.03 Yoshitaka Yasumoto Nintendo."], # GT
      [5, 0x3e083afa, 0x722f97cc, "RSP Gfx ucode F3DEX.NoN fifo 2.03 Yoshitaka Yasumoto 1998 Nintendo.",1], # F-Zero X,
      [5, 0xa8050bd1, 0xa8050bd1, "RSP Gfx ucode F3DEX fifo 2.03 Yoshitaka Yasumoto 1998 Nintendo."], # F-Zero X,
      [5, 0x4e8055f0, 0x4e8055f0, "RSP Gfx ucode F3DLX.Rej fifo 2.03 Yoshitaka Yasumoto 1998 Nintendo.",0,1], # F-Zero X,
      [5, 0xabf001f5, 0xabf001f5, "RSP Gfx ucode F3DFLX.Rej fifo 2.03F Yoshitaka Yasumoto 1998 Nintendo.",0,1], # F-Zero X,
      [5, 0xadb4b686, 0xadb4b686, "RSP Gfx ucode F3DEX fifo 2.04 Yoshitaka Yasumoto 1998 Nintendo."], # Top Gear Rally 2,
      [5, 0x779e2a9b, 0x779e2a9b, "RSP Gfx ucode F3DEX.NoN fifo 2.04 Yoshitaka Yasumoto 1998 Nintendo.",1], # California Speed,
      [5, 0xa8cb3e09, 0xa8cb3e09, "RSP Gfx ucode L3DEX fifo 2.04 Yoshitaka Yasumoto 1998 Nintendo."], # In-Fisherman Bass Hunter 64,
      [5, 0x2a1341d6, 0x2a1341d6, "RSP Gfx ucode F3DEX fifo 2.04H Yoshitaka Yasumoto 1998 Nintendo."], # Kirby 64 - The Crystal Shards,
      [5, 0x3e083afa, 0x89a8e0ed, "RSP Gfx ucode F3DEX.NoN fifo 2.05 Yoshitaka Yasumoto 1998 Nintendo.",1], # Carmageddon 64 (uncensored),
      [5, 0x4964b75d, 0x4964b75d, "RSP Gfx ucode F3DEX.NoN fifo 2.05 Yoshitaka Yasumoto 1998 Nintendo.",1],
      [5, 0x39e3e95a, 0x39e3e95a, "RSP Gfx ucode F3DEX fifo 2.05 Yoshitaka Yasumoto 1998 Nintendo."], # Knife Edge - Nose Gunner,
      [5, 0xd2913522, 0xd2913522, "RSP Gfx ucode F3DAM fifo 2.05 Yoshitaka Yasumoto 1998 Nintendo."], # Hey You, Pikachu!,
      [5, 0x3e083afa, 0xc998443f, "RSP Gfx ucode F3DEX xbus 2.05 Yoshitaka Yasumoto 1998 Nintendo."], #Triple play
      [5, 0xf4184a7d, 0xf4184a7d, "RSP Gfx ucode F3DEX fifo 2.06 Yoshitaka Yasumoto 1998 Nintendo."], # Hey You, Pikachu!,
      [5, 0x595a88de, 0x595a88de, "RSP Gfx ucode F3DEX.Rej fifo 2.06 Yoshitaka Yasumoto 1998 Nintendo.",0,1], # Bio Hazard 2,
      [5, 0x0259f764, 0x0259f764, "RSP Gfx ucode F3DLX.Rej fifo 2.06 Yoshitaka Yasumoto 1998 Nintendo.",0,1], # Mario Party,
      [5, 0xe1a5477a, 0xe1a5477a, "RSP Gfx ucode F3DEX.NoN xbus 2.06 Yoshitaka Yasumoto 1998 Nintendo.",1], # Command & Conquer,
      [5, 0x4cfa0a19, 0x4cfa0a19, "RSP Gfx ucode F3DZEX.NoN fifo 2.06H Yoshitaka Yasumoto 1998 Nintendo.",1], # The Legend of Zelda - Ocarina of Time (v1.0),
      [5, 0x2cbd9514, 0x5f40b9f5, "RSP Gfx ucode F3DZEX.NoN fifo 2.06H Yoshitaka Yasumoto 1998 Nintendo.",1],
      [5, 0x3e083afa, 0x882680f4, "RSP Gfx ucode L3DEX fifo 2.07 Yoshitaka Yasumoto 1998 Nintendo."], # Polaris Sno
      [5, 0xdeb1cac0, 0xdeb1cac0, "RSP Gfx ucode F3DEX.NoN fifo 2.07 Yoshitaka Yasumoto 1998 Nintendo.",1], # Knockout Kings 2000,
      [5, 0xf4184a7d, 0xf4184a7d, "RSP Gfx ucode F3DEX fifo 2.07 Yoshitaka Yasumoto 1998 Nintendo."], # Xena Warrior Princess - Talisman of Fate, Army Men - Air Combat, Destruction Derby
      [5, 0x4b013e60, 0x4b013e60, "RSP Gfx ucode F3DEX xbus 2.07 Yoshitaka Yasumoto 1998 Nintendo."], # Lode Runner 3-D,
      [5, 0xd1a63836, 0xd1a63836, "RSP Gfx ucode L3DEX fifo 2.08 Yoshitaka Yasumoto 1999 Nintendo."], # Hey You, Pikachu!,
      [5, 0x97193667, 0x97193667, "RSP Gfx ucode F3DEX fifo 2.08 Yoshitaka Yasumoto 1999 Nintendo."], # Top Gear Hyper-Bike,
      [5, 0x92149ba8, 0x92149ba8, "RSP Gfx ucode F3DEX fifo 2.08 Yoshitaka Yasumoto/Kawasedo 1999."], # Paper Mario,
      [5, 0xae0fb88f, 0xae0fb88f, "RSP Gfx ucode F3DEX xbus 2.08 Yoshitaka Yasumoto 1999 Nintendo."], # WWF WrestleMania 2000,
      [5, 0xc572f368, 0xc572f368, "RSP Gfx ucode F3DLX.Rej xbus 2.08 Yoshitaka Yasumoto 1999 Nintendo."], # WWF No Mercy,
      [5, 0x3e083afa, 0x74252492, "RSP Gfx ucode F3DEX.NoN xbus 2.08 Yoshitaka Yasumoto 1999 Nintendo.",1],
      [5, 0x9c2edb70, 0xea98e740, "RSP Gfx ucode F3DEX.NoN fifo 2.08 Yoshitaka Yasumoto 1999 Nintendo.",1], # LEGO Racers,
      [5, 0x79e004a6, 0x79e004a6, "RSP Gfx ucode F3DLX.Rej fifo 2.08 Yoshitaka Yasumoto 1999 Nintendo.",0,1], # Mario Party 2,
      [5, 0xaa6ab3ca, 0xaa6ab3ca, "RSP Gfx ucode F3DEX.Rej fifo 2.08 Yoshitaka Yasumoto 1999 Nintendo.",0,1], # V-Rally Edition 99,
      [5, 0x2c597e0f, 0x2c597e0f, "RSP Gfx ucode F3DEX fifo 2.08 Yoshitaka Yasumoto 1999 Nintendo."], # Cruis'n Exotica,
      [10, 0x4e5f3e3b, 0x4e5f3e3b,"RSP Gfx ucode F3DEXBG.NoN fifo 2.08 Yoshitaka Yasumoto 1999 Nintendo.",1], # Conker The Bad Fur Day
      [5, 0x61f31862, 0x61f31862, "RSP Gfx ucode F3DEX.NoN fifo 2.08H Yoshitaka Yasumoto 1999 Nintendo.",1], # Pokemon Snap,
      [5, 0x005f5b71, 0x005f5b71, "RSP Gfx ucode F3DZEX.NoN fifo 2.08I Yoshitaka Yasumoto/Kawasedo 1999.",1], # The Legend of Zelda 2 - Majora's Mask,
      [3, 0x41839d1e, 0x41839d1e, "RSP Gfx ucode S2DEX fifo 2.05 Yoshitaka Yasumoto 1998 Nintendo."], # Chou Snobow Kids,
      [3, 0x2cbd9514, 0xc639dbb9, "RSP Gfx ucode S2DEX xbus 2.06 Yoshitaka Yasumoto 1998 Nintendo."],
      [3, 0xec89e273, 0xec89e273, "RSP Gfx ucode S2DEX fifo 2.08 Yoshitaka Yasumoto 1999 Nintendo."], # V-Rally Edition 99,
      [3, 0x9429b7d6, 0x9429b7d6, "RSP Gfx ucode S2DEX xbus 2.08 Yoshitaka Yasumoto 1999 Nintendo."], # Star Craft,
      # {14,0x5a72397b, 0xec89e273, "RSP Gfx ucode S2DEX fifo 2.08 Yoshitaka Yasumoto 1999 Nintendo."], # OgreBattle Background,
      [3, 0x2cbd9514, 0xec89e273, "RSP Gfx ucode S2DEX fifo 2.08 Yoshitaka Yasumoto 1999 Nintendo."], # Zelda MM,
      [6, 0x6aef74f8, 0x6aef74f8, "Unknown 0x6aef74f8, 0x6aef74f8"], # Diddy Kong Racing (v1.0),
      [6, 0x4c4eead8, 0x4c4eead8, "Unknown 0x4c4eead8, 0x4c4eead8"], # Diddy Kong Racing (v1.1),
      [1, 0xed421e9a, 0xed421e9a, "Unknown 0xed421e9a, 0xed421e9a"], # Kuiki Uhabi Suigo,
      [5, 0x37751932, 0x55c0fd25, "Unknown 0x37751932, 0x55c0fd25"], # Bio Hazard 2,
      [11,0xbe0b83e7, 0xbe0b83e7,"Unknown 0xbe0b83e7, 0xbe0b83e7"], # Jet Force Gemini,
      [17, 0x02e882cf, 0x2ad17281, "Unknown 0x02e882cf, 0x2ad17281"], # Indiana Jones,
      [17, 0x1f7d9118, 0xdab2199b, "Unknown 0x1f7d9118, 0xdab2199b"], # Battle Naboo,
      [17, 0x74583614, 0x74583614, "Unknown 0x74583614, 0x74583614"], # Star Wars - Rogue Squadron,
      [17, 0xe37e2f49, 0x1eb63fd8, "Unknown 0xe37e2f49, 0x1eb63fd8"], # Star Wars - Rogue Squadron,
      [17, 0x8ce1af3d, 0xb2760ea2, "Unknown 0x8ce1af3d, 0xb2760ea2"], # Star Wars - Rogue Squadron,
      [18, 0x7b685972, 0x57b8095a, "Unknown 0x7b685972, 0x57b8095a"], # World Driver Championship
      [18, 0xe92dbb9b, 0x57b8095a, "Unknown 0xe92dbb9b, 0x57b8095a"], # World Driver Championship
      [18, 0xe6c9acc1, 0x65f80845, "Unknown 0xe6c9acc1, 0x65f80845"], # World Driver Championship
      [18, 0x6522df69, 0x720b88a0, "Unknown 0x6522df69, 0x720b88a0"], # World Driver Championship
      [18, 0x6522df69, 0xf1e8ba9e, "Unknown 0x6522df69, 0xf1e8ba9e"], # World Driver Championship
      [19, 0xa486bed3, 0xa486bed3, "Unknown 0xa486bed3, 0xa486bed3"], # Last Legion UX,
      [19, 0x6b519381, 0xfebacfd8, "Unknown in Toukan Road"],  # I don't know which ucode
      [20, 0x6d2a01b1, 0x6d2a01b1, "RSP Gfx ucode ZSortp 0.33 Yoshitaka Yasumoto Nintendo."], # Mia Hamm Soccer 64,
    ]

  makeCRCTable: () ->
    crcTable = []
    # terms of polynomial defining this crc (except x^32):
    p = [0,1,2,4,5,7,8,10,11,12,16,22,23,26]

    # make exclusive-or pattern from polynomial (0xedb88320L)
    poly = 0 # polynomial exclusive-or pattern
    for n in [0...p.length]
      poly |= 1 << (31 - p[n])
   
    c = 0
    for n in [0...256]
      c = n
      for k in [0...8]
        if c & 1
          c = (poly ^ (c >>> 1))>>>0
        else
          c >>>= 1
      crcTable[n] = c
    crcTable

  computeCRC32: (crc, base, len) ->
    crc ^= 0xffffffff
    crc >>>= 0

    # the crcs hat 1964 made were based on little-endian memory layout, so 
    # for big endian and byteCompatibility mode, we need to ^3 to each byte.
    if @core.useByteCompatibilityMode is true or @core.isLittleEndian is 0
      while (len > 0)
        crc = (@crcTable[(crc ^ @core.memory.u8[base^3]) & 0xff] ^ (crc >>> 8))>>>0
        base++
        len--
    else
      while (len > 0)
        crc = (@crcTable[(crc ^ @core.memory.u8[base]) & 0xff] ^ (crc >>> 8))>>>0
        base++
        len--
    return (crc ^ 0xffffffff)>>>0

  DLParser_CheckUCode: (start, dStart, size, dSize) ->
    ucode = -1
    base = dStart & 0x1fffffff
    str = "" 
    if base < @core.currentRdramSize+0x1000
      for i in [0...(0x1000-2)]
        # check for 'R' 'S' 'P' ("RSP") ascii 82, 83, 80
        if @core.memory.readRdram8(base + i) is 82 and @core.memory.readRdram8(base + i + 1) is 83 and @core.memory.readRdram8(base + i + 2) is 80
          #concat chars (32 is ascii for space character)
          while @core.memory.u8[ base + (i ^ 3) ] >= 32
            str += String.fromCharCode(@core.memory.u8[ base + (i ^ 3) ])
            i++
          crcSize = @computeCRC32 0, start, 8
          crc800 = @computeCRC32 0, start, 0x800
          ucode = @DLParser_IdentifyUcode crc800
          if ucode != -1 
            console.log "Detected microcode " + ucode
          else
            console.log "Unknown ucode. Using microcode #5"
            ucode = 5
          @RDP_SetUcodeMap ucode
          break
    return ucode

  RDP_SetUcodeMap: (ucode) ->
    switch ucode
      when 1
        @microcodeMap0[4] = @RSP_GBI1_Vtx
        @microcodeMap0[9] = @RSP_GBI1_Sprite2DBase
        @microcodeMap0[0xaf] = @RSP_GBI1_LoadUCode
        @microcodeMap0[0xb0] = @RSP_GBI1_BranchZ
        @microcodeMap0[0xb1] = @RSP_GBI1_Tri2
        @microcodeMap0[0xb2] = @RSP_GBI1_ModifyVtx
        @microcodeMap0[0xc1] = @RSP_S2DEX_SPObjLoadTxtr_Ucode1
    return

  DLParser_IdentifyUcode: (crc800) ->
    for i in [0...@ucodeData.length]
      #get crc_800 field
      if @ucodeData[i][2] is crc800
        #return ucode field
        return @ucodeData[i][0]
    return -1 # not found

  callBind: (fn, me) ->
    ->
      fn.call me

  processDisplayList: ->
    if @core.showFB is true
      @initBuffers()
      @core.webGL.show3D()
      @core.showFB = false
      @resetState()

    @core.webGL.beginDList()
    @dlParserProcess()

    #this.core.interrupts.triggerDPInterrupt(0, false);
    @core.interrupts.delayNextInterrupt = true #don't process immediately
    @core.interrupts.triggerDPInterrupt 0, false
    return

  videoLog : (msg) ->
    #console.log msg
    return

  checkUcode: ->
    if @currentMicrocodeMap is undefined

      tUcode = @core.memory.getInt32(@core.memory.spMemUint8Array, consts.TASK_MICROCODE, @core.memory.spMemUint32Array)
      tUcodeData = @core.memory.getInt32(@core.memory.spMemUint8Array, consts.TASK_MICROCODE_DATA, @core.memory.spMemUint32Array)
      tUcodeSize = @core.memory.getInt32(@core.memory.spMemUint8Array, consts.TASK_MICROCODE_SIZE, @core.memory.spMemUint32Array)
      tUcodeDataSize = @core.memory.getInt32(@core.memory.spMemUint8Array, consts.TASK_MICROCODE_DATA_SIZE, @core.memory.spMemUint32Array)

      @ucode = @DLParser_CheckUCode tUcode, tUcodeData, tUcodeSize, tUcodeDataSize
      @currentMicrocodeMap = @microcodeMap0 # to only execute this once
    return

  dlParserProcess: ->

    @checkUcode()

    @dlistStackPointer = 0
    @dlistStack[@dlistStackPointer].pc = @core.memory.getInt32(@core.memory.spMemUint8Array, consts.TASK_DATA_PTR, @core.memory.spMemUint32Array)>>>0
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
    aa = 10000
    while @dlistStackPointer >= 0 and aa > 0
      aa--
      pc = @dlistStack[@dlistStackPointer].pc
      cmd = @getCommand(pc)
      func = @currentMicrocodeMap[cmd]
      @dlistStack[@dlistStackPointer].pc += 8
      func.call this, pc
      if @dlistStackPointer >= 0
        @dlistStack[@dlistStackPointer].countdown -= 1
        @dlistStackPointer -= 1  if @dlistStack[@dlistStackPointer].countdown < 0

    if aa <= 0
      alert "Too many dlist calls"
      @core.terminate = true
    return

  #TODO: end rendering
  RDP_GFX_PopDL: ->
    @dlistStackPointer -= 1
    return

  RSP_RDP_Nothing: (pc) ->
    #@videoLog "RSP RDP NOTHING"
    #@dlistStackPointer -= 1
    return

  RSP_GBI1_MoveMem: (pc) ->
    addr = undefined
    length = undefined
    type = @getGbi1Type(pc)
    seg = @getGbi0DlistAddr(pc)
    addr = @getRspSegmentAddr(seg)
    switch type
      when consts.RSP_GBI1_MV_MEM_VIEWPORT
        @RSP_MoveMemViewport addr
      #case RSP_GBI1_MV_MEM_LOOKATY:
      #break;
      #case RSP_GBI1_MV_MEM_LOOKATX:
      #break;
      when consts.RSP_GBI1_MV_MEM_L0, consts.RSP_GBI1_MV_MEM_L1, consts.RSP_GBI1_MV_MEM_L2, consts.RSP_GBI1_MV_MEM_L3, consts.RSP_GBI1_MV_MEM_L4, consts.RSP_GBI1_MV_MEM_L5, consts.RSP_GBI1_MV_MEM_L6, consts.RSP_GBI1_MV_MEM_L7
        dwLight = (type-consts.RSP_GBI1_MV_MEM_L0)/2
        @RSP_MoveMemLight dwLight, addr, pc
      when consts.RSP_GBI1_MV_MEM_MATRIX1
        @RSP_GFX_Force_Matrix pc
    return

  RSP_GFX_Force_Matrix: (pc) ->
    @RSP_GBI0_Mtx pc

  RSP_MoveMemViewport: (addr) ->
    @videoLog "RSP_MoveMemViewport"

    if addr + 16 >= @core.currentRdramSize
      console.warn "viewport addresses beyond mem size"
      return

    scale = new Float32Array(4)
    trans = new Float32Array(4)

    scale[0] = @getShort addr+0*2
    scale[1] = @getShort addr+1*2
    scale[2] = @getShort addr+2*2
    scale[3] = @getShort addr+3*2

    trans[0] = @getShort addr+4*2
    trans[1] = @getShort addr+5*2
    trans[2] = @getShort addr+6*2
    trans[3] = @getShort addr+7*2

    centerX = trans[0] / 4.0
    centerY = trans[1] / 4.0
    @n64ViewportWidth = scale[0] / 4.0
    @n64ViewportHeight = scale[1] / 4.0

    @n64ViewportWidth = -@n64ViewportWidth if @n64ViewportWidth < 0
    @n64ViewportHeight = -@n64ViewportHeight if @n64ViewportHeight < 0
    @n64ViewportLeft = centerX - @n64ViewportWidth
    @n64ViewportTop = centerY - @n64ViewportHeight
    @n64ViewportRight = centerX + @n64ViewportWidth
    @n64ViewportBottom = centerY + @n64ViewportHeight

    maxZ = 0x3FF

    #@setViewPort left, top, right, bottom, maxZ

    return

  RSP_GBI1_SpNoop: (pc) ->
    #@videoLog "RSP_GBI1_SpNoop"
    return

  RSP_GBI1_Reserved: (pc) ->
    #@videoLog "RSP_GBI1_Reserved"
    return

  setProjection: (mat, bPush, bReplace) ->
    if bPush is true
      if @gRSP.projectionMtxTop >= (@RICE_MATRIX_STACK - 1)
        @gRSP.bMatrixIsUpdated = true
        @inverseTransposeCalculated = false
        return
      @gRSP.projectionMtxTop += 1
      # We should store the current projection matrix...
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
    @inverseTransposeCalculated = false

    #hack to show Mario's head (as an ortho projection. This if/else is wrong.
    if @gRSP.projectionMtxs[@gRSP.projectionMtxTop][14] > 0
      mat4.ortho -1024, 1024, -1024, 1024, -1023.0, 1024.0, @gRSP.projectionMtxs[@gRSP.projectionMtxTop]
    else
      mat4.ortho -1, 1, -1, 1, -1, 1, 1.0, 1024.0, this.gRSP.projectionMtxs[this.gRSP.projectionMtxTop]
    return

  setWorldView: (mat, bPush, bReplace) ->
    if bPush is true
      if @gRSP.modelViewMtxTop >= (@RICE_MATRIX_STACK - 1)
        @gRSP.bMatrixIsUpdated = true
        @inverseTransposeCalculated = false
        return
      @gRSP.modelViewMtxTop += 1
      if bReplace
        # Load modelView matrix
        mat4.set mat, @gRSP.modelviewMtxs[@gRSP.modelViewMtxTop]
      else # Multiply modelView matrix
        mat4.multiply @gRSP.modelviewMtxs[@gRSP.modelViewMtxTop - 1], mat, @gRSP.modelviewMtxs[@gRSP.modelViewMtxTop]
    else # NoPush
      if bReplace
        # Load modelView matrix
        mat4.set mat, @gRSP.modelviewMtxs[@gRSP.modelViewMtxTop]
      else
        # Multiply modelView matrix
        mat4.multiply @gRSP.modelviewMtxs[@gRSP.modelViewMtxTop], mat, @gRSP.modelviewMtxs[@gRSP.modelViewMtxTop]
    @gRSP.bMatrixIsUpdated = true
    @inverseTransposeCalculated = false
    return

  RSP_GBI0_Mtx: (pc) ->
    addr = undefined
    seg = @getGbi0DlistAddr(pc)
    addr = @getRspSegmentAddr(seg)
    #@videoLog "RSP_GBI0_Mtx addr: " + dec2hex(addr)
    @loadMatrix addr
    if @gbi0isProjectionMatrix pc
      @setProjection @matToLoad, @gbi0PushMatrix(pc), @gbi0LoadMatrix(pc)
    else
      @setWorldView @matToLoad, @gbi0PushMatrix(pc), @gbi0LoadMatrix(pc)

    @renderStateChanged = true
    return

  loadMatrix: (addr) ->
    #  todo: port and probably log warning message if true
    if (addr + 64 > @core.currentRdramSize)
      console.warn "loading matrix beyond ram size"
      return
    i = undefined
    j = undefined
    a = addr
    b = undefined
    k = 0
    i = 0
    `const u8 = this.core.memory.u8`
    `const matToLoad = this.matToLoad`
    while i < 4
      j = 0
      while j < 4
        # 0.0000152587890625 is 1.0/65536.0
        matToLoad[k] = ((u8[a] << 24 | u8[a + 1] << 16 | u8[a + 32] << 8 | u8[a + 32 + 1])>>0) * 0.0000152587890625
        k += 1
        a += 2
        j += 1
      i += 1
    return

  #tile info.
  DLParser_SetTImg: (pc) ->
    @texImg.format = @getTImgFormat(pc)
    @texImg.size = @getTImgSize(pc)
    @texImg.width = @getTImgWidth(pc) + 1
    @texImg.addr = @getTImgAddr(pc)
    @texImg.bpl = @texImg.width << @texImg.size >> 1
    @texImg.changed = true #no texture cache
    #console.log "SetTImg: Format:"+ @texImg.format + " Size:" + @texImg.size + " Width: "+ @texImg.width
    return

  #this.videoLog('Texture: format=' + this.texImg.format + ' size=' + this.texImg.size + ' ' + 'width=' + this.texImg.width + ' addr=' + this.texImg.addr + ' bpl=' + this.texImg.bpl);

  RSP_GBI0_Vtx: (pc) ->
    num = @getGbi0NumVertices(pc) + 1
    v0 = @getGbi0Vertex0(pc)
    seg = @getGbi0DlistAddr(pc)
    addr = @getRspSegmentAddr(seg)
    num = 32 - v0  if (v0 + num) > @MAX_VERTICES

    #Check that the address is valid
    if (addr + num*16) > @core.currentRdramSize
      console.warn "vertex is beyond ram size"
    else
      @processVertexData addr, v0, num
    return

  RSP_GBI1_Vtx: (pc) ->
    num = @getGbi1NumVertices(pc) + 1
    v0 = @getGbi1Vertex0(pc)
    seg = @getGbi0DlistAddr(pc)
    addr = @getRspSegmentAddr(seg)
    num = 32 - v0  if (v0 + num) > @MAX_VERTICES

    #Check that the address is valid
    if (addr + num*16) > @core.currentRdramSize
      console.warn "vertex is beyond ram size"
    else
      @processVertexData addr, v0, num
    return

  RSP_GBI1_Sprite2DBase: (pc) ->
    alert "todo: RSP_GBI1_Sprite2DBase"
    return

  RSP_GBI1_LoadUCode: (pc) ->
    alert "todo: RSP_GBI1_LoadUCode"
    return

  RSP_GBI1_BranchZ: (pc) ->
    alert "todo: RSP_GBI1_BranchZ"
    return

  RSP_GBI1_Tri2: (pc) ->
    alert "todo: RSP_GBI1_Tri2"
    return

  RSP_GBI1_ModifyVtx: (pc) ->
    alert "todo: RSP_GBI1_ModifyVtx"
    return

  RSP_S2DEX_SPObjLoadTxtr_Ucode1: (pc) ->
    alert "todo: RSP_S2DEX_SPObjLoadTxtr_Ucode1"
    return


  processLights: (vo, i, a, sMult, tMult) ->
    `const n = this.normalMat`
    o = 0
    vo |= 0
    i |= 0
    while i < 0
      v = @N64VertexList[vo+i]
      n[0] = @getVertexNormalX a
      i += 1
      n[1] = @getVertexNormalY a
      n[2] = @getVertexNormalZ a
      #n[3] = 1.0

      tempVec3 = new Float32Array(@tempVec3Buffer, o)
      v.u = @getVertexS(a) * sMult
      v.w = @getVertexW(a)
      mat4.multiplyVec3 @modelViewTransposedInverse, n, tempVec3
      v.y = @getVertexY(a)
      v.z = @getVertexZ(a)
      vect = vec3.normalize tempVec3
      v.v = @getVertexT(a) * tMult
      v.x = @getVertexX(a)
      @lightVertex vect, v
      a += 16
      o += 12
    return

  processShades: (vo, i, a, sMult, tMult) ->
    while i < 0
      v = @N64VertexList[vo+i]
      v.w = @getVertexW(a)
      v.x = @getVertexX(a)
      v.y = @getVertexY(a)
      i += 1
      v.u = @getVertexS(a) * sMult
      v.z = @getVertexZ(a)
      v.r = @getVertexColorR(a)
      v.g = @getVertexColorG(a)
      v.b = @getVertexColorB(a)
      v.a = @getVertexAlpha(a)
      v.v = @getVertexT(a) * tMult
      a += 16
    return

  processPrims: (vo, i, a, sMult, tMult) ->
    while i < 0
      v = @N64VertexList[vo+i]
      v.w = @getVertexW(a)
      v.r = @primColor[0]
      v.x = @getVertexX(a)
      i += 1
      v.u = @getVertexS(a) * sMult
      v.g = @primColor[1]
      v.y = @getVertexY(a)
      v.b = @primColor[2]
      v.z = @getVertexZ(a)
      v.a = @primColor[3]
      v.v = @getVertexT(a) * tMult
      a += 16
    return

  processVertexData: (addr, v0, num) ->
    a = addr|0
    i = -num
    `const vo = v0+num`
    `const tile = this.textureTile[this.activeTile]`
    `const texWidth = (((tile.lrs >> 2) + 1) - tile.uls)|0`
    `const texHeight = (((tile.lrt >> 2) + 1) - tile.ult)|0`
    `const sMult = 1.0 / (texWidth<<5)`
    `const tMult = 1.0 / (texHeight<<5)`

    if @bLightingEnable is true
      if @inverseTransposeCalculated is false and @gRSP.bMatrixIsUpdated is true
        mat4.inverse @gRSP.modelviewMtxs[@gRSP.modelViewMtxTop], @modelViewInverse
        mat4.transpose @modelViewInverse, @modelViewTransposedInverse
        @inverseTransposeCalculated = true
      @processLights vo, i, a, sMult, tMult
    else if @bShade is true
      @processShades vo, i, a, sMult, tMult
    else
      @processPrims vo, i, a, sMult, tMult
    return

  DLParser_SetCImg: (pc) ->
    @zColorImage.fmt = @getSetTileFmt pc
    @zColorImage.siz = @getSetTileSiz pc
    @zColorImage.width = @getTImgWidth(pc) + 1
    seg = @getGbi0DlistAddr(pc)
    @zColorImage.addr = @getRspSegmentAddr seg
    return

  DLParser_SetZImg: (pc) ->
    @zDepthImage.fmt = @getSetTileFmt pc
    @zDepthImage.siz = @getSetTileSiz pc
    @zDepthImage.width = @getTImgWidth(pc) + 1
    seg = @getGbi0DlistAddr(pc)
    @zDepthImage.addr = @getRspSegmentAddr seg
    return

  #Gets new display list address
  RSP_GBI0_DL: (pc) ->
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

  DLParser_SetCombine: (pc) ->
    `const lo = this.getCombineLo(pc) >>> 0`
    `const hi = this.getCombineHi(pc) >>> 0`

    @combine[0] = (lo >> 20) & 15 # @getCombineA0(pc)
    @combine[2] = (hi >> 28) & 15 # @getCombineB0(pc)
    @combine[4] = (lo >> 15) & 31 # @getCombineC0(pc)
    @combine[6] = (hi >> 15) & 7 # @getCombineD0(pc)
    # @combineA0 = 0xFF if @combineA0 is 15
    # @combineB0 = 0xFF if @combineB0 is 15
    # @combineC0 = 0xFF if @combineC0 is 31
    # @combineD0 = 0xFF if @combineD0 is 7
    @combine[1] = (lo >> 12) & 7 # @getCombineA0a(pc)
    @combine[3] = (hi >> 12) & 7 # @getCombineB0a(pc)
    @combine[5] = (lo >> 9) & 7 # @getCombineC0a(pc)
    @combine[7] = (hi >> 9) & 7 # @getCombineD0a(pc)
    # @combineA0a = 0xFF if @combineA0a is 7
    # @combineB0a = 0xFF if @combineB0a is 7
    # @combineC0a = 0xFF if @combineC0a is 7
    # @combineD0a = 0xFF if @combineD0a is 7
    @combine[8] = (lo >> 5) & 15 # @getCombineA1(pc)
    @combine[10] = (hi >> 24) & 15 # @getCombineB1(pc)
    @combine[12] = lo & 31 # @getCombineC1(pc)
    @combine[14] = (hi >> 6) & 7 # @getCombineD1(pc)
    # @combineA1 = 0xFF if @combineA1 is 15
    # @combineB1 = 0xFF if @combineB1 is 15
    # @combineC1 = 0xFF if @combineC1 is 31
    # @combineD1 = 0xFF if @combineD1 is 7
    @combine[9] = (hi >> 21) & 7 # @getCombineA1a(pc)
    @combine[11] = (hi >> 3) & 7 # @getCombineB1a(pc)
    @combine[13] = (hi >> 18) & 7 # @getCombineC1a(pc)
    @combine[15] = hi & 7 # @getCombineD1a(pc)
    # @combineA1a = 0xFF if @combineA1a is 7
    # @combineB1a = 0xFF if @combineB1a is 7
    # @combineC1a = 0xFF if @combineC1a is 7
    # @combineD1a = 0xFF if @combineD1a is 7

 #   w0 = @core.memory.u8[pc] << 24 | @core.memory.u8[pc + 1] << 16 | @core.memory.u8[pc + 2] << 8 | @core.memory.u8[pc + 3]
 #   w1 = @core.memory.u8[pc + 4] << 24 | @core.memory.u8[pc + 5] << 16 | @core.memory.u8[pc + 6] << 8 | @core.memory.u8[pc + 7]

    #if (@combineD0 == 4)
    #  console.log " a0:" + @combineA0 + " b0:" + @combineB0 + " c0:" + @combineC0 + " d0:" + @combineD0 + " a0a:" + @combineA0a + " b0a:" + @combineB0a + " c0a:" + @combineC0a + " d0a:" + @combineD0a + " a1:" + @combineA1 + " b1:" + @combineB1 + " c1:" + @combineC1 + " d1:" + @combineD1 + " a1a:" + @combineA1a + " b1a:" + @combineB1a + " c1a:" + @combineC1a + " d1a:" + @combineD1a

    #@videoLog "TODO: DLParser_SetCombine"
    @core.webGL.setCombineUniforms this, @core.webGL.shaderProgram
    return

  RSP_GBI1_MoveWord: (pc) ->
    #@videoLog "RSP_GBI1_MoveWord"
    switch @getGbi0MoveWordType(pc)
      when consts.RSP_MOVE_WORD_MATRIX
        @RSP_RDP_InsertMatrix()
      when consts.RSP_MOVE_WORD_SEGMENT
        dwBase = undefined
        dwSegment = (@getGbi0MoveWordOffset(pc) >> 2) & 0x0F
        dwBase = @getGbi0MoveWordValue(pc) & 0xFFFFFF
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
            @setAmbientLight @getGbi0MoveWordValue(pc)
          else
            @setLightCol light, @getGbi0MoveWordValue(pc)
    return

  setAmbientLight: (col) ->
    @gRSP.ambientLightColor = col
    r = (col >>> 24) & 0xff
    g = (col >>> 16) & 0xff
    b = (col >>> 8) & 0xff
    a = col & 0xff
    @gRSP.fAmbientLightR = r
    @gRSP.fAmbientLightG = g
    @gRSP.fAmbientLightB = b
    @gRSP.fAmbientLightA = a
    return

  setLightCol: (dwLight, dwCol) ->
    r = ((dwCol >>> 24) & 0xFF)
    g = ((dwCol >>> 16) & 0xFF)
    b = ((dwCol >>> 8) & 0xFF)
    a = ((dwCol >>> 0) & 0xFF)
    @gRSPlights[dwLight].r = r
    @gRSPlights[dwLight].g = g
    @gRSPlights[dwLight].b = b
    @gRSPlights[dwLight].a = a
    return

  setLightDirection: (dwLight, x, y, z) ->
    lightVec = new Float32Array(3)
    lightVec[0] = x
    lightVec[1] = y
    lightVec[2] = z
    lightVec = vec3.normalize(lightVec)

    @gRSPlights[dwLight].x = lightVec[0]
    @gRSPlights[dwLight].y = lightVec[1]
    @gRSPlights[dwLight].z = lightVec[2]
    return

  lightVertex: (norm, v) ->
    r = @gRSP.fAmbientLightR
    g = @gRSP.fAmbientLightG
    b = @gRSP.fAmbientLightB
    #a = @gRSP.fAmbientLightA

    for l in [0...@gRSPnumLights]
      light = @gRSPlights[l]
      fCosT = norm[0]*light.x + norm[1]*light.y + norm[2]*light.z
      if fCosT > 0
        r += light.r * fCosT
        g += light.g * fCosT
        b += light.b * fCosT
        #a += light.a * fCosT

    if r < 0.0
      r = 0.0
    if g < 0.0
      g = 0.0
    if b < 0.0
      b = 0.0
    #if a < 0.0
    #  a = 0.0
    if r > 255.0
      r = 255.0
    if g > 255.0
      g = 255.0
    if b > 255.0
      b = 255.0
    #if a > 255.0
    #  a = 255.0

    v.r = r
    v.g = g
    v.b = b
    v.a = 255.0
    return

  RSP_MoveMemLight: (dwLight, dwAddr, pc) ->
    if dwLight >= 16
      return

    @gRSPn64lights[dwLight].dwRGBA = @getGbi0MoveWordValue(dwAddr)
    @gRSPn64lights[dwLight].dwRGBACopy = @getGbi0MoveWordValue(dwAddr+4)
    @gRSPn64lights[dwLight].x = @getVertexLightX dwAddr
    @gRSPn64lights[dwLight].y = @getVertexLightY dwAddr
    @gRSPn64lights[dwLight].z = @getVertexLightZ dwAddr

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
      if @getGbi0MoveWordValue(dwAddr+4) is 0  # Direction is 0! // This sucks. Give it a better name
      else
        @setLightDirection dwLight, @gRSPn64lights[dwLight].x, @gRSPn64lights[dwLight].y, @gRSPn64lights[dwLight].z
    return

  renderReset: ->

    #UpdateClipRectangle();
    #@resetMatrices()
    @gRSP.projectionMtxTop = 0
    @gRSP.modelViewMtxTop = 0

    #SetZBias(0);
    @gRSP.numVertices = 0
    @gRSP.curTile = 0
#    @gRSP.fTexScaleX = 1 / 32.0
#    @gRSP.fTexScaleY = 1 / 32.0

    @gl.clearDepth 1.0
    @gl.depthMask true
    @gl.clear @gl.DEPTH_BUFFER_BIT
    return

  resetMatrices: ->
    @gRSP.projectionMtxTop = 0
    @gRSP.modelViewMtxTop = 0
    mat4.identity @gRSP.modelviewMtxs[0]
    mat4.identity @gRSP.projectionMtxs[0]

    i = 0
    while (i < @RICE_MATRIX_STACK)
      mat4.identity @gRSP.projectionMtxs[i]
      mat4.identity @gRSP.modelviewMtxs[i]
      i += 1

    @gRSP.bMatrixIsUpdated = false
    @inverseTransposeCalculated = false
    return

  RSP_RDP_InsertMatrix: ->
    @videoLog "TODO: Insert Matrix"
    @gRSP.bMatrixIsUpdated = false
    return

  DLParser_SetScissor: (pc) ->
    @videoLog "TODO: DLParser_SetScissor"
    return

  RSP_GBI1_SetOtherModeH: (pc) ->
    word0 = @getOtherModeH pc
    length = (word0 >>> 0) & 0xFF
    shift = (word0 >>> 8) & 0xFF
    mask = ((1<<length)-1)<<shift
    @otherModeH &= ~mask
    @otherModeH |= @getOtherModeH pc+4
    #alert @otherModeH
    @renderStateChanged = true
    return

  RSP_GBI1_SetOtherModeL: (pc) ->
    word0 = @getOtherModeL pc
    length = (word0 >>> 0) & 0xFF
    shift = (word0 >>> 8) & 0xFF
    mask = ((1<<length)-1)<<shift
    @otherModeL &= ~mask
    @otherModeL |= @getOtherModeL pc+4
    #alert dec2hex @otherModeL
    @DLParser_RDPSetOtherModeL(@otherModeL)
    @renderStateChanged = true
    return

  RSP_GBI0_Sprite2DBase: (pc) ->
    @videoLog "TODO: RSP_GBI0_Sprite2DBase"
    return

  RSP_GBI0_Tri4: (pc) ->
    @videoLog "TODO: RSP_GBI0_Tri4"
    return

  RSP_GBI1_RDPHalf_Cont: (pc) ->
    @videoLog "TODO: RSP_GBI1_RDPHalf_Cont"
    return

  RSP_GBI1_RDPHalf_2: (pc) ->
    @videoLog "TODO: RSP_GBI1_RDPHalf_2"
    return

  RSP_GBI1_RDPHalf_1: (pc) ->
    @videoLog "TODO: RSP_GBI1_RDPHalf_1"
    return

  RSP_GBI1_Line3D: (pc) ->
    @videoLog "TODO: RSP_GBI1_Line3D"
    return

  RSP_GBI1_ClearGeometryMode: (pc) ->
    data = @getClearGeometryMode(pc)>>>0
    @geometryMode &= ~data
    @initGeometryMode()
    @setDepthTest()
    return

  RSP_GBI1_SetGeometryMode: (pc) ->
    data = @getSetGeometryMode(pc)>>>0
    @geometryMode |= data
    @initGeometryMode()
    @setDepthTest()
    return

  initGeometryMode: () ->
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


  RSP_GBI1_EndDL: (pc) ->
    @RDP_GFX_PopDL()
    @drawScene(false, @activeTile)
    #@resetState()
    return

  RSP_GBI1_Texture: (pc) ->
    tile = @getTextureTile(pc)
    @activeTile = tile
    @textureTile[tile].on = @getTextureOn(pc)
    @textureTile[tile].level = @getTextureLevel(pc)
    @textureTile[tile].scales = @getTextureScaleS(pc) / 0x8000
    @textureTile[tile].scalet = @getTextureScaleT(pc) / 0x8000
    #console.log "RSP_GBI1_Texture: Tile:" + tile + " On:" + @textureTile[tile].on + " Level:" + @textureTile[tile].level + " ScaleS:" + @textureTile[tile].scales + " ScaleT:" + @textureTile[tile].scalet
    @drawScene false, tile
    return

  popProjection: () ->
    if @gRSP.projectionMtxTop > 0
      @gRSP.projectionMtxTop--
    return

  popWorldView: () ->
    if @gRSP.modelViewMtxTop > 0
      @gRSP.modelViewMtxTop--
      @gRSPmodelViewTop = @gRSP.modelviewMtxs[@gRSP.modelViewMtxTop]
      @gRSP.bMatrixIsUpdated = true
      @inverseTransposeCalculated = false
    return

  RSP_GBI1_PopMtx: (pc) ->
    if @gbi0PopMtxIsProjection pc
      @popProjection()
    else
      @popWorldView()
    @renderStateChanged = true
    return

  RSP_GBI1_CullDL: (pc) ->
    @videoLog "TODO: RSP_GBI1_CullDL"
    return

  RSP_GBI1_Tri1: (pc) ->
    mult = 1.0 / @vertexMultVals[@ucode]
    v0 = @getGbi0Tri1V0(pc) * mult
    v1 = @getGbi0Tri1V1(pc) * mult
    v2 = @getGbi0Tri1V2(pc) * mult
    flag = @getGbi0Tri1Flag(pc)
    #console.log "Tri1: "+v0+", "+v1+", "+v2+"   Flag: "+flag
    didSucceed = @prepareTriangle v0, v1, v2

    if didSucceed is false
      return

    pc = @dlistStack[@dlistStackPointer].pc
    cmd = @getCommand(pc)
    func = @currentMicrocodeMap[cmd]
    if func is @RSP_GBI1_Tri1
      return #loops until not tri1, then it will drawScene

    if @renderStateChanged is true
      @drawScene false, @activeTile
    return

  RSP_GBI1_Noop: (pc) ->
    #@videoLog "TODO: RSP_GBI1_Noop"
    return

  RDP_TriFill: (pc) ->
    @videoLog "TODO: RDP_TriFill"
    return

  RDP_TriFillZ: (pc) ->
    @videoLog "RDP_TriFillZ"
    return

  RDP_TriTxtr: (pc) ->
    @videoLog "TODO: RDP_TriTxtr"
    return

  RDP_TriTxtrZ: (pc) ->
    @videoLog "TODO: RDP_TriTxtrZ"
    return

  RDP_TriShade: (pc) ->
    @videoLog "TODO: RDP_TriShade"
    return

  RDP_TriShadeZ: (pc) ->
    @videoLog "TODO: RDP_TriShadeZ"
    return

  RDP_TriShadeTxtr: (pc) ->
    @videoLog "TODO: RDP_TriShadeTxtr"
    return

  RDP_TriShadeTxtrZ: (pc) ->
    @videoLog "TODO: RDP_TriShadeTxtrZ"
    return

  DLParser_TexRect: (pc, isFillRect) ->
    depthTestEnabled = true
    if depthTestEnabled
      #@setDepthTest()
      @gl.enable @gl.DEPTH_TEST
      @gl.depthFunc @gl.LEQUAL
    else
      @gl.disable @gl.DEPTH_TEST

    xh = @getTexRectXh(pc) >>> 2
    yh = @getTexRectYh(pc) >>> 2
    tileno = @getTexRectTileNo(pc)
    xl = @getTexRectXl(pc) >>> 2
    yl = @getTexRectYl(pc) >>> 2
    s = @getTexRectS(pc) >>> 5
    t = @getTexRectT(pc) >>> 5
    dsdx = @getTexRectDsDx(pc) >>> 10
    dtdy = @getTexRectDtDy(pc) >>> 10

    if @cycleType is consts.CYCLE_TYPE_COPY
      dsdx *= 0.25

    if @cycleType is consts.CYCLE_TYPE_FILL or @cycleType is consts.CYCLE_TYPE_COPY
      xh += 1.0
      yh += 1.0

    #console.log "Texrect: UL("+xl+","+yl+") LR("+xh+","+yh+") Tile:"+tileno+" TexCoord:("+s+","+t+") TexSlope:("+dsdx+","+dtdy+")"
    @renderer.texRect tileno, xl, yl, xh, yh, s, t, dsdx, dtdy, @textureTile[tileno], @tmem, this, isFillRect
    @hasTexture = true
    #@setDepthTest()
    #@drawScene false, 7
    return

  DLParser_TexRectFlip: (pc) ->
    @videoLog "TODO: DLParser_TexRectFlip"
    return

  DLParser_RDPLoadSynch: (pc) ->
    @renderStateChanged = true
    @videoLog "TODO: DLParser_RDPLoadSynch"
    return

  DLParser_RDPPipeSynch: (pc) ->
    @videoLog "TODO: DLParser_RDPPipeSynch"
    return

  DLParser_RDPTileSynch: (pc) ->
    @videoLog "TODO: DLParser_RDPTileSynch"
    return

  DLParser_RDPFullSynch: (pc) ->
    #@drawScene(7, false)
    return

  DLParser_SetKeyGB: (pc) ->
    @videoLog "TODO: DLParser_SetKeyGB"
    return

  DLParser_SetKeyR: (pc) ->
    @videoLog "TODO: DLParser_SetKeyR"
    return

  DLParser_SetConvert: (pc) ->
    @videoLog "TODO: DLParser_SetConvert"
    return

  DLParser_SetPrimDepth: (pc) ->
    @videoLog "TODO: DLParser_SetPrimDepth"
    return

  DLParser_RDPSetOtherModeL: (otherModeL) ->
    if (otherModeL & (consts.RDP_ALPHA_COMPARE_THRESHOLD|consts.RDP_ALPHA_COMPARE_DITHER)) isnt 0
      @alphaTestEnabled = 1
    else
      @alphaTestEnabled = 0
    return

  DLParser_LoadTLut: (pc) ->
    @videoLog "TODO: DLParser_LoadTLut"
    return

  DLParser_SetTileSize: (pc) ->
    tile = @getSetTileSizeTile(pc)
    @textureTile[tile].uls = @getSetTileSizeUls(pc)
    @textureTile[tile].ult = @getSetTileSizeUlt(pc)
    @textureTile[tile].lrs = @getSetTileSizeLrs(pc)
    @textureTile[tile].lrt = @getSetTileSizeLrt(pc)
    #console.log "SetTileSize: UL("+@textureTile[tile].uls+"/"+@textureTile[tile].ult+") LR("+@textureTile[tile].lrs+"/"+@textureTile[tile].lrt+") Dim: "+@textureTile[tile].width+"x"+@textureTile[tile].height
    return

  DLParser_LoadBlock: (pc) ->
    tile = @getLoadBlockTile(pc)
    uls = @getLoadBlockUls(pc)
    ult = @getLoadBlockUlt(pc)
    lrs = @getLoadBlockLrs(pc)
    dxt = @getLoadBlockDxt(pc)
    #console.log "LoadBlock: Tile:"+tile+" UL("+uls+"/"+ult+") LRS:"+lrs+" DXT: 0x"+dec2hex(dxt)
    #textureAddr = @core.memory.u8[@texImg.addr])
    bytesToXfer = (lrs+1) * @textureTile[tile].siz
    if bytesToXfer > 4096
      console.error "LoadBlock is making too large of a transfer. "+bytesToXfer+" bytes"
    i=0
    `const u8 = this.core.memory.u8
    var addr = this.texImg.addr|0
    const tmem = this.tmem`
    while i < bytesToXfer
      tmem[i] = u8[addr]
      i++
      addr++
    return

  DLParser_LoadTile: (pc) ->
    tile = @getLoadBlockTile(pc)
    lrs = @textureTile[tile].lrs
    #console.log "LoadBlock: Tile:"+tile+" UL("+uls+"/"+ult+") LRS:"+lrs+" DXT: 0x"+dec2hex(dxt)
    #textureAddr = @core.memory.u8[@texImg.addr])
    bytesToXfer = (lrs+1) * @textureTile[tile].siz
    bytesToXfer = 4096
    if bytesToXfer > 4096
      console.error "LoadTile is making too large of a transfer. "+bytesToXfer+" bytes"
    i=0
    `const u8 = this.core.memory.u8
    addr = this.texImg.addr|0
    const tmem = this.tmem`
    while i < bytesToXfer
      tmem[i] = u8[addr]
      i++
      addr++
    return

  DLParser_SetTile: (pc) ->
    tile = @getSetTileTile(pc)
    @textureTile[tile].fmt = @getSetTileFmt(pc)
    @textureTile[tile].siz = @getSetTileSiz(pc)
    @textureTile[tile].line = @getSetTileLine(pc)
    @textureTile[tile].tmem = @getSetTileTmem(pc)
    @textureTile[tile].pal = @getSetTilePal(pc)
    @textureTile[tile].cmt = @getSetTileCmt(pc)
    @textureTile[tile].cms = @getSetTileCms(pc)
    @textureTile[tile].mirrorS = @getSetTileMirrorS(pc)
    @textureTile[tile].mirrorT = @getSetTileMirrorT(pc)
    @textureTile[tile].maskt = @getSetTileMaskt(pc)
    @textureTile[tile].masks = @getSetTileMasks(pc)
    @textureTile[tile].shiftt = @getSetTileShiftt(pc)
    @textureTile[tile].shifts = @getSetTileShifts(pc)
    @textureTile[tile].otherModeL = @otherModeL

    #if @combineD0 == 4
    #console.log "SetTile:"+tile+" FMT:"+@textureTile[tile].fmt+" SIZ:"+@textureTile[tile].siz+" LINE: "+@textureTile[tile].line+" TMEM:"+@textureTile[tile].tmem+" PAL:"+@textureTile[tile].pal+" CMS/T:"+@textureTile[tile].cms+"/"+@textureTile[tile].cmt+" MASKS/T:"+@textureTile[tile].masks+"/"+@textureTile[tile].maskt+" SHIFTS/T:"+@textureTile[tile].shifts+"/"+@textureTile[tile].shiftt
    return

  DLParser_FillRect: (pc) ->
    # if @zDepthImage.addr isnt undefined and (@zDepthImage.addr is @zColorImage.addr)
    #   @gl.clearDepth 1.0
    #   @gl.depthMask true
    #   @gl.clear @gl.DEPTH_BUFFER_BIT
      #@gl.clearColor @fillColor[0], @fillColor[1], @fillColor[2], 1.0
      #@gl.clear @gl.COLOR_BUFFER_BIT
      #@gl.clearColor 0.0, 0.0, 0.0, 0.0
      #return

    @DLParser_TexRect pc, true

    # if @fillColor isnt undefined
    #   if @zDepthImage.addr isnt @zColorImage.addr
    #     @gl.clearColor 1.0, @fillColor[1], @fillColor[2], 1.0
    #     @gl.clear @gl.COLOR_BUFFER_BIT
    return

  DLParser_SetFillColor: (pc) ->
    @fillColor = []
    @fillColor.push @getSetFillColorR(pc)/255.0
    @fillColor.push @getSetFillColorG(pc)/255.0
    @fillColor.push @getSetFillColorB(pc)/255.0
    @fillColor.push @getSetFillColorA(pc)/255.0
    @gl.uniform4fv @core.webGL.shaderProgram.uFillColor, @fillColor
    return

  DLParser_SetFogColor: (pc) ->
    @videoLog "TODO: DLParser_SetFogColor"
    return

  DLParser_SetBlendColor: (pc) ->
    @blendColor = []
    @blendColor.push @getSetFillColorR(pc)/255.0
    @blendColor.push @getSetFillColorG(pc)/255.0
    @blendColor.push @getSetFillColorB(pc)/255.0
    @blendColor.push @getSetFillColorA(pc)/255.0
    @gl.uniform4fv @core.webGL.shaderProgram.uBlendColor, @blendColor
    return

  DLParser_SetPrimColor: (pc) ->
    @primColor = []
    @primColor.push @getSetPrimColorR(pc)/255.0
    @primColor.push @getSetPrimColorG(pc)/255.0
    @primColor.push @getSetPrimColorB(pc)/255.0
    @primColor.push @getSetPrimColorA(pc)/255.0
    #alert @primColor
    @gl.uniform4fv @core.webGL.shaderProgram.uPrimColor, @primColor
    return

  DLParser_SetEnvColor: (pc) ->
    @envColor = []
    @envColor.push @getSetEnvColorR(pc)/255.0
    @envColor.push @getSetEnvColorG(pc)/255.0
    @envColor.push @getSetEnvColorB(pc)/255.0
    @envColor.push @getSetEnvColorA(pc)/255.0
    @gl.uniform4fv @core.webGL.shaderProgram.uEnvColor, @envColor
    return

  prepareTriangle: (dwV0, dwV1, dwV2) ->
    #SP_Timing(SP_Each_Triangle);
    didSucceed = undefined #(CRender::g_pRender->IsTextureEnabled() || this.gRSP.ucode == 6 );
    textureFlag = false
    didSucceed = @initVertex(dwV0, @gRSP.numVertices, textureFlag)
    didSucceed = @initVertex(dwV1, @gRSP.numVertices + 1, textureFlag)  if didSucceed
    didSucceed = @initVertex(dwV2, @gRSP.numVertices + 2, textureFlag)  if didSucceed
    @gRSP.numVertices += 3  if didSucceed
    didSucceed

  initVertex: (dwV, vtxIndex, bTexture) ->
    #console.log "Vertex Index: "+vtxIndex+" dwV:"+dwV
    return false  if dwV >= consts.MAX_VERTS

    offset = 4 * @triangleVertexPositionBuffer.numItems++ # postfix addition is intentional for performance
    vertex = @N64VertexList[dwV]

    @triVertices[offset] = vertex.x
    @triVertices[offset+1] = vertex.y
    @triVertices[offset+2] = vertex.z
    @triVertices[offset+3] = vertex.w
    @triVertices[offset+3] = 1.0 if vertex.w == 0

    colorOffset = @triangleVertexColorBuffer.numItems++ << 2 # postfix addition is intentional for performance
    @triColorVertices[colorOffset]     = vertex.r
    @triColorVertices[colorOffset + 1] = vertex.g
    @triColorVertices[colorOffset + 2] = vertex.b
    @triColorVertices[colorOffset + 3] = vertex.a

    texOffset = @triangleVertexTextureCoordBuffer.numItems++ << 1 # postfix addition is intentional for performance
    @triTextureCoords[texOffset]     = vertex.u
    @triTextureCoords[texOffset + 1] = vertex.v
    true

  setBlendFunc: () ->
    `const CYCLE_TYPE_1 = 0`
    `const CYCLE_TYPE_2 = 1`
    `const CYCLE_TYPE_COPY = 2`
    `const CYCLE_TYPE_FILL = 3`
    `const CVG_DST_CLAMP = 0`
    `const CVG_DST_WRAP = 0x100`
    `const CVG_DST_FULL = 0x200`
    `const CVG_DST_SAVE = 0x300`
    `const BLEND_NOOP = 0x0000`
    `const BLEND_NOOP5 = 0xcc48`
    `const BLEND_NOOP4 = 0xcc08`
    `const BLEND_FOG_ASHADE = 0xc800`
    `const BLEND_FOG_3 = 0xc000`
    `const BLEND_FOG_MEM = 0xc440`
    `const BLEND_FOG_APRIM = 0xc400`
    `const BLEND_BLENDCOLOR = 0x8c88`
    `const BLEND_BI_AFOG = 0x8400`
    `const BLEND_BI_AIN = 0x8040`
    `const BLEND_MEM = 0x4c40`
    `const BLEND_FOG_MEM_3 = 0x44c0`
    `const BLEND_NOOP3 = 0x0c48`
    `const BLEND_PASS = 0x0c08`
    `const BLEND_FOG_MEM_IN_MEM = 0x0440`
    `const BLEND_FOG_MEM_FOG_MEM = 0x04c0`
    `const BLEND_OPA = 0x0044`
    `const BLEND_XLU = 0x0040`
    `const BLEND_MEM_ALPHA_IN = 0x4044`

    blendMode1 = @otherModeL >>> 16 & 0xCCCC
    blendMode2 = @otherModeL >>> 16 & 0x3333
    @cycleType = @otherModeH >> 20 & 0x3

    switch @cycleType
      when CYCLE_TYPE_FILL
        @gl.disable @gl.BLEND
      when CYCLE_TYPE_COPY
        #this is wrong, but better for now. Hud has no alpha.
        # We should be calculating alpha transparency at the bottom of this function
        @gl.blendFunc @gl.SRC_ALPHA, @gl.ONE_MINUS_SRC_ALPHA
        @gl.enable @gl.BLEND
      when CYCLE_TYPE_2
        forceBl = @otherModeL >> 14 & 0x1
        zCmp = @otherModeL >> 4 & 0x1
        alphaCvgSel = @otherModeL >> 13 & 0x1
        cvgXAlpha = @otherModeL >> 12 & 0x1

        if forceBl is 1 and zCmp is 1
          @gl.blendFunc @gl.SRC_ALPHA, @gl.ONE_MINUS_SRC_ALPHA
          @gl.enable @gl.BLEND
        # else if alphaCvgSel is 1 && cvgXAlpha is 0
        #   @gl.blendFunc @gl.ONE, @gl.ZERO
        #   @gl.enable @gl.BLEND
        else switch blendMode1+blendMode2
          when (BLEND_PASS+(BLEND_PASS>>2)), (BLEND_FOG_APRIM+(BLEND_PASS>>2))
            @gl.blendFunc @gl.ONE, @gl.ZERO
            @gl.enable @gl.blendFunc
            if @cvgXAlpha is 1
              @gl.blendFunc @gl.ALPHA, @gl.ONE_MINUS_SRC_ALPHA
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
            if @fogIsImplemented
              @gl.blendFunc @gl.ONE, @gl.ZERO
              @gl.enable @gl.BLEND
            else
              @gl.blendFunc @gl.SRC_ALPHA, @gl.ONE_MINUS_SRC_ALPHA
              @gl.enable @gl.BLEND

          when (BLEND_FOG_APRIM + (BLEND_OPA>>2)), (BLEND_FOG_ASHADE + (BLEND_OPA>>2)), (BLEND_BI_AFOG + (BLEND_OPA>>2)), (BLEND_FOG_ASHADE + (BLEND_NOOP>>2)), (BLEND_NOOP + (BLEND_OPA>>2)), (BLEND_NOOP4 + (BLEND_NOOP>>2)), (BLEND_FOG_ASHADE+(BLEND_PASS>>2)), (BLEND_FOG_3+(BLEND_PASS>>2))
            if @fogIsImplemented
              @gl.blendFunc @gl.ONE, @gl.ZERO
              @gl.enable @gl.BLEND
            else
              @gl.blendFunc @gl.SRC_ALPHA, @gl.ONE_MINUS_SRC_ALPHA
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
            HACK_FOR_MARIO_TENNIS = true
            if HACK_FOR_MARIO_TENNIS
              @gl.blendFunc @gl.SRC_ALPHA, @gl.ONE_MINUS_SRC_ALPHA
            else
              @gl.blendFunc @gl.ONE, @gl.ZERO
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

  setDepthTest: () ->
    zBufferMode = (@geometryMode & consts.G_ZBUFFER) isnt 0
    zCmp = (@otherModeL & consts.Z_COMPARE) isnt 0
    zUpd = (@otherModeL & consts.Z_UPDATE) isnt 0
    if ((zBufferMode and zCmp) or zUpd)
      @gl.enable @gl.DEPTH_TEST
#      @gl.depthFunc @gl.LEQUAL
#      @gl.depthRange 0, 0.0001 # fixes shadows
#      @gl.depthMask true
    else
      @gl.disable @gl.DEPTH_TEST
    @gl.depthMask zUpd
    return

  drawScene: (useTexture, tileno) ->
    @setBlendFunc()
    @setDepthTest()

    @renderStateChanged = false

    if @triangleVertexPositionBuffer.numItems > 0
      @gl.bindBuffer @gl.ARRAY_BUFFER, @triangleVertexPositionBuffer
      @gl.bufferData @gl.ARRAY_BUFFER, @triVertices.subarray(0, @triangleVertexPositionBuffer.numItems*@triangleVertexPositionBuffer.itemSize), @gl.STATIC_DRAW
      @gl.enableVertexAttribArray @core.webGL.shaderProgram.vertexPositionAttribute
      @gl.vertexAttribPointer @core.webGL.shaderProgram.vertexPositionAttribute, @triangleVertexPositionBuffer.itemSize, @gl.FLOAT, false, 0, 0

    if @triangleVertexColorBuffer.numItems > 0
      @gl.bindBuffer @gl.ARRAY_BUFFER, @triangleVertexColorBuffer
      @gl.bufferData @gl.ARRAY_BUFFER, @triColorVertices.subarray(0, @triangleVertexColorBuffer.numItems*@triangleVertexColorBuffer.itemSize), @gl.STATIC_DRAW
      @gl.enableVertexAttribArray @core.webGL.shaderProgram.vertexColorAttribute
      @gl.vertexAttribPointer @core.webGL.shaderProgram.vertexColorAttribute, @triangleVertexColorBuffer.itemSize, @gl.UNSIGNED_BYTE, true, 0, 0

    if @triangleVertexTextureCoordBuffer.numItems > 0
      @gl.bindBuffer @gl.ARRAY_BUFFER, @triangleVertexTextureCoordBuffer
      @gl.bufferData @gl.ARRAY_BUFFER, @triTextureCoords.subarray(0, @triangleVertexTextureCoordBuffer.numItems*@triangleVertexTextureCoordBuffer.itemSize), @gl.STATIC_DRAW
      @gl.enableVertexAttribArray @core.webGL.shaderProgram.textureCoordAttribute
      @gl.vertexAttribPointer @core.webGL.shaderProgram.textureCoordAttribute, @triangleVertexTextureCoordBuffer.itemSize, @gl.FLOAT, false, 0, 0
      tile = @textureTile[tileno]
      tileWidth = ((tile.lrs >> 2) + 1) - tile.uls
      tileHeight = ((tile.lrt >> 2) + 1) - tile.ult
      tData = @renderer.formatTexture(tile, @tmem, this)

      if tData isnt undefined and tData.textureData isnt undefined
        textureData = tData.textureData
        @gl.activeTexture(@gl.TEXTURE0 + tileno)
        @gl.bindTexture(@gl.TEXTURE_2D, @colorsTexture0)
        wrapS = @gl.REPEAT
        wrapT = @gl.REPEAT
        if ((tile.cms is consts.RDP_TXT_CLAMP) or (tile.masks is 0))
          wrapS = @gl.CLAMP_TO_EDGE
        else if tile.cms is consts.RDP_TXT_MIRROR
          wrapS = @gl.MIRRORED_REPEAT
        if ((tile.cmt is consts.RDP_TXT_CLAMP) or (tile.maskt is 0))
          wrapT = @gl.CLAMP_TO_EDGE
        else if tile.cmt is consts.RDP_TXT_MIRROR
          wrapT = @gl.MIRRORED_REPEAT
        @gl.texParameterf(@gl.TEXTURE_2D, @gl.TEXTURE_WRAP_S, wrapS)
        @gl.texParameterf(@gl.TEXTURE_2D, @gl.TEXTURE_WRAP_T, wrapT)
        @gl.texParameterf(@gl.TEXTURE_2D, @gl.TEXTURE_MAG_FILTER, @gl.LINEAR)
        @gl.texParameterf(@gl.TEXTURE_2D, @gl.TEXTURE_MIN_FILTER, @gl.NEAREST)
        @gl.texImage2D(@gl.TEXTURE_2D, 0, @gl.RGBA, tileWidth, tileHeight, 0, @gl.RGBA, @gl.UNSIGNED_BYTE, textureData)

    #@gl.uniform1i @core.webGL.shaderProgram.otherModeL, @otherModeL
    #@gl.uniform1i @core.webGL.shaderProgram.otherModeH, @otherModeH
    @gl.uniform1i @core.webGL.shaderProgram.cycleType, @cycleType
    @gl.uniform1i @core.webGL.shaderProgram.uAlphaTestEnabled, @alphaTestEnabled

    # Matrix Uniforms
    @gl.uniformMatrix4fv(@core.webGL.shaderProgram.pMatrixUniform, false, @gRSP.projectionMtxs[@gRSP.projectionMtxTop]);
    @gl.uniformMatrix4fv(@core.webGL.shaderProgram.mvMatrixUniform, false, @gRSP.modelviewMtxs[@gRSP.modelViewMtxTop]);

    if @triangleVertexPositionBuffer.numItems > 0
      if @core.settings.wireframe is true
        @gl.drawArrays @gl.LINES, 0, @triangleVertexPositionBuffer.numItems
      else
        @gl.drawArrays @gl.TRIANGLES, 0, @triangleVertexPositionBuffer.numItems

    @triangleVertexPositionBuffer.numItems = 0
    @triangleVertexColorBuffer.numItems = 0
    @triangleVertexTextureCoordBuffer.numItems = 0
    @gRSP.numVertices = 0
    return

  resetState: ->
    @geometryMode = 0
    @initGeometryMode()
    @alphaTestEnabled = 0
    @activeTile = 0
    return

  initBuffers: ->
    @triangleVertexPositionBuffer = @gl.createBuffer()
    @gl.bindBuffer @gl.ARRAY_BUFFER, @triangleVertexPositionBuffer
    @triangleVertexPositionBuffer.itemSize = 4
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

#hack global space until we export classes properly
#node.js uses exports; browser uses this (window)
root = exports ? self
root.C1964jsVideoHLE = C1964jsVideoHLE
