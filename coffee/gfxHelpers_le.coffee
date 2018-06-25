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

class C1964jsVideoHLEle extends C1964jsVideoHLE
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
    `const u16 = this.core.memory.u16`
    `const matToLoad = this.matToLoad`
    while i < 4
      j = 0
      while j < 4
        # 0.0000152587890625 is 1.0/65536.0
        matToLoad[k] = ((u16[(a>>>1)^1] << 16 | u16[((a + 32)>>>1)^1])>>0) * 0.0000152587890625
        matToLoad[k+1] = ((u16[a>>>1] << 16 | u16[(a + 32)>>>1])>>0) * 0.0000152587890625
        k += 2
        a += 4
        j += 2
      i += 1
    return


C1964jsVideoHLEle::getGbi0MoveWordOffset = (pc) ->
  @core.memory.u8[pc+2]<<8 | @core.memory.u8[pc+1]

C1964jsVideoHLEle::getGbi0MoveWordType = (pc) ->
  @core.memory.u8[pc]

C1964jsVideoHLEle::getGbi0MoveWordValue = (pc) ->
  @core.memory.u32[(pc+4)>>>2]

#GBI0 Dlist struct
C1964jsVideoHLEle::getGbi0DlistParam = (pc) ->
  #(@core.memory.u32[pc>>>2]) >>> 16 & 0x00ff
  @core.memory.u8[pc+2]

C1964jsVideoHLEle::getGbi0DlistAddr = (pc) -> #this will probably be generic getGbi0Addr
  @core.memory.u32[(pc+4)>>>2]

C1964jsVideoHLEle::getCommand = (pc) ->
  @core.memory.u8[pc+3]

#GBI0 Tri1 struct
C1964jsVideoHLEle::getGbi0Tri1Flag = (pc) ->
  @core.memory.u8[pc+7]

C1964jsVideoHLEle::getGbi0Tri1V0 = (pc) ->
  @core.memory.u8[pc+6]

C1964jsVideoHLEle::getGbi0Tri1V1 = (pc) ->
  @core.memory.u8[pc+5]

C1964jsVideoHLEle::getGbi0Tri1V2 = (pc) ->
  @core.memory.u8[pc+4]

#GBI1 Tri2 struct
C1964jsVideoHLEle::getGbi1Tri2V3 = (pc) ->
  @core.memory.u8[pc+2]

C1964jsVideoHLEle::getGbi1Tri2V4 = (pc) ->
  @core.memory.u8[pc+1]

C1964jsVideoHLEle::getGbi1Tri2V5 = (pc) ->
  @core.memory.u8[pc]

#GBI1 Line3D
C1964jsVideoHLEle::getGbi1Line3dV0 = (pc) ->
  @core.memory.u8[pc + 6]

C1964jsVideoHLEle::getGbi1Line3dV1 = (pc) ->
  @core.memory.u8[pc + 5]

C1964jsVideoHLEle::getGbi1Line3dV2 = (pc) ->
  @core.memory.u8[pc + 4]

C1964jsVideoHLEle::getGbi1Line3dV3 = (pc) ->
  @core.memory.u8[pc + 7]


#GBI0 vertex struct
C1964jsVideoHLEle::getGbi0NumVertices = (pc) ->
  #(@core.memory.u32[pc>>>2]) >>> 20 & 0x0F
  (@core.memory.u8[pc+2] >> 4 ) & 0x0F

C1964jsVideoHLEle::getGbi0Vertex0 = (pc) ->
  #(@core.memory.u32[pc>>>2]) >>> 16 & 0x0F
  @core.memory.u8[pc+2] & 0x0F


#GBI1 vertex struct
C1964jsVideoHLEle::getGbi1NumVertices = (pc) ->
  ((@core.memory.u8[pc+1])>>>2) & 0x3F

C1964jsVideoHLEle::getGbi1Vertex0 = (pc) ->
  (@core.memory.u8[pc + 2]>>>1) & 0x7F


#Fiddled vertex struct - Legacy
C1964jsVideoHLEle::getFiddledVertexX = (pc) ->
  @core.memory.u32[pc>>>2] >> 16

C1964jsVideoHLEle::getFiddledVertexY = (pc) ->
  @core.memory.u32[pc>>>2] << 16 >> 16

C1964jsVideoHLEle::getFiddledVertexZ = (pc) ->
  @core.memory.u32[(pc+4)>>>2] >> 16

#Vertex Struct
C1964jsVideoHLEle::getVertexX = (pc) ->
  #if ((pc>>>0) > 0x00800000)
  #  alert "oops"
  @core.memory.u16[(pc>>>1)^1]<<16>>16

C1964jsVideoHLEle::getVertexY = (pc) ->
  @core.memory.u16[pc>>>1]<<16>>16

C1964jsVideoHLEle::getVertexZ = (pc) ->
  @core.memory.u16[((pc+4)>>>1)^1]<<16>>16

C1964jsVideoHLEle::getVertexW = (pc) ->
  @core.memory.u16[(pc+4)>>>1]<<16>>16


C1964jsVideoHLEle::getVertexS = (pc) ->
  @core.memory.u16[(pc+10)>>>1]<<16>>16

C1964jsVideoHLEle::getVertexT = (pc) ->
  @core.memory.u16[(pc+8)>>>1]<<16>>16

C1964jsVideoHLEle::getVertexColorR = (pc) ->
  @core.memory.u8[pc+15]

C1964jsVideoHLEle::getVertexColorG = (pc) ->
  @core.memory.u8[pc+14]

C1964jsVideoHLEle::getVertexColorB = (pc) ->
  @core.memory.u8[pc+13]

C1964jsVideoHLEle::getVertexAlpha = (pc) ->
  @core.memory.u8[pc+12]

C1964jsVideoHLEle::getVertexNormalX = (pc) ->
  #(@core.memory.u8[pc+15] << 24 | @core.memory.u8[pc+14] << 16 | @core.memory.u8[pc+13] << 8 | @core.memory.u8[pc+12]) >> 24
  @core.memory.u8[pc+15]<<24>>24

C1964jsVideoHLEle::getVertexNormalY = (pc) ->
  #(@core.memory.u8[pc+15] << 24 | @core.memory.u8[pc+14] << 16 | @core.memory.u8[pc+13] << 8 | @core.memory.u8[pc+12]) << 8 >> 24
  @core.memory.u8[pc+14]<<24>>24

C1964jsVideoHLEle::getVertexNormalZ = (pc) ->
  #(@core.memory.u8[pc+15] << 24 | @core.memory.u8[pc+14] << 16 | @core.memory.u8[pc+13] << 8 | @core.memory.u8[pc+12]) << 16 >> 24
  @core.memory.u8[pc+13]<<24>>24

C1964jsVideoHLEle::getVertexNormalA = (pc) ->
  @core.memory.u8[pc+12]<<24>>24

C1964jsVideoHLEle::getVertexLightX = (pc) ->
  @core.memory.u8[pc+11]<<24>>24

C1964jsVideoHLEle::getVertexLightY = (pc) ->
  @core.memory.u8[pc+10]<<24>>24

C1964jsVideoHLEle::getVertexLightZ = (pc) ->
  @core.memory.u8[pc+9]<<24>>24


#Texture Struct
C1964jsVideoHLEle::getTextureLevel = (pc) ->
  (@core.memory.u32[pc>>>2]) >> 11 & 7

C1964jsVideoHLEle::getTextureTile = (pc) ->
  #(@core.memory.u32[pc>>>2]) >> 8 & 7
  @core.memory.u8[pc+1] & 7

C1964jsVideoHLEle::getTextureOn = (pc) ->
  #(@core.memory.u32[pc>>>2]) & 15
  @core.memory.u8[pc] & 15

C1964jsVideoHLEle::getTextureScaleS = (pc) ->
  #(@core.memory.u32[(pc+4)>>>2]) >> 16 & 0xFFFF
  @core.memory.u16[(pc+6)>>>1]

C1964jsVideoHLEle::getTextureScaleT = (pc) ->
  #(@core.memory.u32[(pc+4)>>>2]) & 0xFFFF
  @core.memory.u16[(pc+4)>>>1]

#Combine Struct

C1964jsVideoHLEle::getCombineLo = (pc) ->
  @core.memory.u32[pc>>>2]

C1964jsVideoHLEle::getCombineHi = (pc) ->
  @core.memory.u32[(pc+4)>>>2]

C1964jsVideoHLEle::getCombineA0 = (pc) ->
  ((@core.memory.u32[pc>>>2]) >> 20) & 15

C1964jsVideoHLEle::getCombineB0 = (pc) ->
  ((@core.memory.u32[(pc+4)>>>2]) >> 28) & 15

C1964jsVideoHLEle::getCombineC0 = (pc) ->
  (@core.memory.u32[pc>>>2]) >> 15 & 31

C1964jsVideoHLEle::getCombineD0 = (pc) ->
  ((@core.memory.u32[(pc+4)>>>2]) >> 15) & 7

C1964jsVideoHLEle::getCombineA0a = (pc) ->
  ((@core.memory.u32[pc>>>2]) >> 12) & 7

C1964jsVideoHLEle::getCombineB0a = (pc) ->
  ((@core.memory.u32[(pc+4)>>>2]) >> 12) & 7

C1964jsVideoHLEle::getCombineC0a = (pc) ->
  ((@core.memory.u32[pc>>>2]) >> 9) & 7

C1964jsVideoHLEle::getCombineD0a = (pc) ->
  ((@core.memory.u32[(pc+4)>>>2]) >> 9) & 7

C1964jsVideoHLEle::getCombineA1 = (pc) ->
  ((@core.memory.u32[pc>>>2]) >> 5) & 15

C1964jsVideoHLEle::getCombineB1 = (pc) ->
  ((@core.memory.u32[(pc+4)>>>2]) >> 24) & 15

C1964jsVideoHLEle::getCombineC1 = (pc) ->
  (@core.memory.u32[pc>>>2]) & 31

C1964jsVideoHLEle::getCombineD1 = (pc) ->
  ((@core.memory.u32[(pc+4)>>>2]) >> 6) & 7

C1964jsVideoHLEle::getCombineA1a = (pc) ->
  ((@core.memory.u32[(pc+4)>>>2]) >> 21) & 7

C1964jsVideoHLEle::getCombineB1a = (pc) ->
  ((@core.memory.u32[(pc+4)>>>2]) >> 3) & 7

C1964jsVideoHLEle::getCombineC1a = (pc) ->
  ((@core.memory.u32[(pc+4)>>>2]) >> 18) & 7

C1964jsVideoHLEle::getCombineD1a = (pc) ->
  (@core.memory.u32[(pc+4)>>>2]) & 7

#GBI0 matrix struct
C1964jsVideoHLEle::gbi0isProjectionMatrix = (pc) ->
  (if ((@core.memory.u8[pc+2] & 1) isnt 0) then true else false)

C1964jsVideoHLEle::gbi0LoadMatrix = (pc) ->
  (if ((@core.memory.u8[pc+2] & 2) isnt 0) then true else false)

C1964jsVideoHLEle::gbi0PushMatrix = (pc) ->
  (if ((@core.memory.u8[pc+2] & 4) isnt 0) then true else false)

C1964jsVideoHLEle::gbi0PopMtxIsProjection = (pc) ->
  (if ((@core.memory.u8[pc+4] & 1) isnt 0) then true else false)

#TexRect struct
#    uint32 dwXH    = (((gfx->words.w0)>>12)&0x0FFF)/4;
# uint32 dwYH   = (((gfx->words.w0)    )&0x0FFF)/4;
# uint32 tileno = ((gfx->words.w1)>>24)&0x07;
# uint32 dwXL   = (((gfx->words.w1)>>12)&0x0FFF)/4;
# uint32 dwYL   = (((gfx->words.w1)    )&0x0FFF)/4;
# uint16 uS   = (uint16)(  dwCmd2>>16)&0xFFFF;
# uint16 uT   = (uint16)(  dwCmd2    )&0xFFFF;
# uint16  uDSDX   = (uint16)((  dwCmd3>>16)&0xFFFF);
# uint16  uDTDY     = (uint16)((  dwCmd3    )&0xFFFF);
#X coordinate of lower right
C1964jsVideoHLEle::getTexRectXh = (pc) ->
  (@core.memory.u32[pc>>>2]) >>> 12 & 0xFFF

#Y coordinate of lower right
C1964jsVideoHLEle::getTexRectYh = (pc) ->
  #(@core.memory.u32[pc>>>2]) & 0xFFF
  @core.memory.u16[pc>>>1] & 0xFFF

C1964jsVideoHLEle::getTexRectTileNo = (pc) ->
  #(@core.memory.u32[(pc+4)>>>2]) >>> 24 & 7
  @core.memory.u8[pc+7] & 7

#X coordinate of upper left
C1964jsVideoHLEle::getTexRectXl = (pc) ->
  @core.memory.u32[(pc+4)>>>2] >>> 12 & 0xFFF

#Y coordinate of upper left
C1964jsVideoHLEle::getTexRectYl = (pc) ->
  #(@core.memory.u32[(pc+4)>>>2]) & 0xFFF
  @core.memory.u16[(pc+4)>>>1] & 0xFFF

C1964jsVideoHLEle::getTexRectS = (pc) ->
  #(@core.memory.u8[pc+15] << 24 | @core.memory.u8[pc+14] << 16 | @core.memory.u8[pc+13] << 8 | @core.memory.u8[pc+12]) >>> 16 & 0xFFFF
  @core.memory.u16[(pc+14)>>>1]

C1964jsVideoHLEle::getTexRectT = (pc) ->
  #(@core.memory.u8[pc+15] << 24 | @core.memory.u8[pc+14] << 16 | @core.memory.u8[pc+13] << 8 | @core.memory.u8[pc+12]) & 0xFFFF
  @core.memory.u16[(pc+12)>>>1]

C1964jsVideoHLEle::getTexRectDsDx = (pc) ->
  @core.memory.getInt32(@core.memory.u8, pc + 20, @core.memory.u32) >>> 16 & 0xFFFF

C1964jsVideoHLEle::getTexRectDtDy = (pc) ->
  @core.memory.getInt32(@core.memory.u8, pc + 20, @core.memory.u32) & 0xFFFF

#is this right?
C1964jsVideoHLEle::getGbi1Type = (pc) ->
  (@core.memory.u32[pc>>>2]) >>> 16 & 0xFF

C1964jsVideoHLEle::getRspSegmentAddr = (seg) ->
  #TODO: May need to mask with rdram size - 1
  (@segments[(seg >> 24) & 0x0F]&0xffffff) + (seg & 0xFFFFFF)


C1964jsVideoHLEle::getOtherModeL = (pc) ->
  (@core.memory.u32[pc>>>2])

C1964jsVideoHLEle::getOtherModeH = (pc) ->
  (@core.memory.u32[pc>>>2])


C1964jsVideoHLEle::getWord0 = (pc) ->
  (@core.memory.u32[pc>>>2])

C1964jsVideoHLEle::getWord1 = (pc) ->
  (@core.memory.u32[(pc+4)>>>2])

C1964jsVideoHLEle::getShort = (pc) ->
  (@core.memory.u8[pc^3] << 24 | @core.memory.u8[(pc+1)^3] << 16) >> 16


#
#typedef struct {
#    unsigned int    width:12;
#    unsigned int    :7;
#    unsigned int    siz:2;
#    unsigned int    fmt:3;
#    unsigned int    cmd:8;
#    unsigned int    addr;
#} GSetImg;
#
C1964jsVideoHLEle::getTImgWidth = (pc) ->
  (@core.memory.u32[pc>>>2]) & 0xFFF

C1964jsVideoHLEle::getTImgSize = (pc) ->
  (@core.memory.u32[pc>>>2]) >>> 19 & 3

C1964jsVideoHLEle::getTImgFormat = (pc) ->
  (@core.memory.u32[pc>>>2]) >>> 21 & 7

C1964jsVideoHLEle::getTImgAddr = (pc) ->
  tImgAddr = (@core.memory.u32[(pc+4)>>>2])
  @getRspSegmentAddr tImgAddr

#SetTile

C1964jsVideoHLEle::getSetTileFmt = (pc) ->
  (@core.memory.u32[pc>>>2]) >> 21 & 7

C1964jsVideoHLEle::getSetTileSiz = (pc) ->
  (@core.memory.u32[pc>>>2]) >> 19 & 3

C1964jsVideoHLEle::getSetTileLine = (pc) ->
  (@core.memory.u32[pc>>>2]) >> 9 & 0x1FF

C1964jsVideoHLEle::getSetTileTmem = (pc) ->
  (@core.memory.u32[pc>>>2]) & 0x1FF

C1964jsVideoHLEle::getSetTileTile = (pc) ->
  (@core.memory.u8[(pc+4)^3]) & 7

C1964jsVideoHLEle::getSetTilePal = (pc) ->
  (@core.memory.u32[(pc+4)>>>2]) >> 20 & 15

C1964jsVideoHLEle::getSetTileCmt = (pc) ->
  (@core.memory.u32[(pc+4)>>>2]) >> 18 & 3

C1964jsVideoHLEle::getSetTileMirrorT = (pc) ->
  (@core.memory.u32[(pc+4)>>>2]) >> 15 & 1

C1964jsVideoHLEle::getSetTileMaskt = (pc) ->
  (@core.memory.u32[(pc+4)>>>2]) >> 14 & 15

C1964jsVideoHLEle::getSetTileShiftt = (pc) ->
  (@core.memory.u32[(pc+4)>>>2]) >> 10 & 15

C1964jsVideoHLEle::getSetTileCms = (pc) ->
  (@core.memory.u32[(pc+4)>>>2]) >> 8 & 3

C1964jsVideoHLEle::getSetTileMirrorS = (pc) ->
  (@core.memory.u32[(pc+4)>>>2]) >> 5 & 1

C1964jsVideoHLEle::getSetTileMasks = (pc) ->
  (@core.memory.u32[(pc+4)>>>2]) >> 4 & 15

C1964jsVideoHLEle::getSetTileShifts = (pc) ->
  (@core.memory.u32[(pc+4)>>>2]) & 15

#LoadBlock

C1964jsVideoHLEle::getLoadBlockTile = (pc) ->
  (@core.memory.u8[(pc+4)^3]) & 7

C1964jsVideoHLEle::getLoadBlockUls = (pc) ->
  (@core.memory.u32[pc>>>2]) >> 12 & 0xFFF

C1964jsVideoHLEle::getLoadBlockUlt = (pc) ->
  (@core.memory.u32[pc>>>2]) & 0xFFF

C1964jsVideoHLEle::getLoadBlockLrs = (pc) ->
  (@core.memory.u32[(pc+4)>>>2]) >> 12 & 0xFFF

C1964jsVideoHLEle::getLoadBlockDxt = (pc) ->
  (@core.memory.u32[(pc+4)>>>2]) & 0xFFF

#SetTileSize

C1964jsVideoHLEle::getSetTileSizeTile = (pc) ->
  (@core.memory.u8[(pc+4)^3]) & 7

C1964jsVideoHLEle::getSetTileSizeUls = (pc) ->
  (@core.memory.u32[pc>>>2]) >> 12 & 0xFFF

C1964jsVideoHLEle::getSetTileSizeUlt = (pc) ->
  (@core.memory.u32[pc>>>2]) & 0xFFF

C1964jsVideoHLEle::getSetTileSizeLrs = (pc) ->
  (@core.memory.u32[(pc+4)>>>2]) >> 12 & 0xFFF

C1964jsVideoHLEle::getSetTileSizeLrt = (pc) ->
  (@core.memory.u32[(pc+4)>>>2]) & 0xFFF

#SetPrimColor

C1964jsVideoHLEle::getSetPrimColorM = (pc) ->
  (@core.memory.u32[pc>>>2]) >>> 8 & 0xFF

C1964jsVideoHLEle::getSetPrimColorL = (pc) ->
  (@core.memory.u32[pc>>>2]) & 0xFF

C1964jsVideoHLEle::getSetPrimColorR = (pc) ->
  @core.memory.u8[pc+7]

C1964jsVideoHLEle::getSetPrimColorG = (pc) ->
  @core.memory.u8[pc+6]

C1964jsVideoHLEle::getSetPrimColorB = (pc) ->
  @core.memory.u8[pc+5]

C1964jsVideoHLEle::getSetPrimColorA = (pc) ->
  @core.memory.u8[pc+4]

#SetGeometryMode

C1964jsVideoHLEle::getSetGeometryMode = (pc) ->
  @core.memory.u32[(pc+4)>>>2]

C1964jsVideoHLEle::getClearGeometryMode = (pc) ->
  @core.memory.u32[(pc+4)>>>2]

C1964jsVideoHLEle::pow2roundup = (value) ->
  result = 1
  while result < value
    result <<= 1
  return result

#SetFillColor

C1964jsVideoHLEle::getSetFillColorR = (pc) ->
  @core.memory.u8[pc+7]

C1964jsVideoHLEle::getSetFillColorG = (pc) ->
  @core.memory.u8[pc+6]

C1964jsVideoHLEle::getSetFillColorB = (pc) ->
  @core.memory.u8[pc+5]

C1964jsVideoHLEle::getSetFillColorA = (pc) ->
  @core.memory.u8[pc+4]

#setEnvColor

C1964jsVideoHLEle::getSetEnvColorR = (pc) ->
  @core.memory.u8[pc+7]

C1964jsVideoHLEle::getSetEnvColorG = (pc) ->
  @core.memory.u8[pc+6]

C1964jsVideoHLEle::getSetEnvColorB = (pc) ->
  @core.memory.u8[pc+5]

C1964jsVideoHLEle::getSetEnvColorA = (pc) ->
  @core.memory.u8[pc+4]

#hack global space until we export classes properly
#node.js uses exports; browser uses this (window)
root = exports ? self
root.C1964jsVideoHLEle = C1964jsVideoHLEle

