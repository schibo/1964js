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
#GBI0 MoveWord struct:
#typedef struct {
#    unsigned int    type:8;
#    unsigned int    offset:16;
#    unsigned int    cmd:8;
#    unsigned int    value;
#} GGBI0_MoveWord;
#
C1964jsVideoHLE::getGbi0MoveWordType = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array, pc) & 0x00ff

C1964jsVideoHLE::getGbi0MoveWordOffset = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array, pc) >> 8 & 0x00ffff

C1964jsVideoHLE::getGbi0MoveWordValue = (pc) ->
  @core.memory.getInt32 @core.memory.rdramUint8Array, pc + 4

#GBI0 Dlist struct
C1964jsVideoHLE::getGbi0DlistParam = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array, pc) >>> 16 & 0x00ff

C1964jsVideoHLE::getGbi0DlistAddr = (pc) -> #this will probably be generic getGbi0Addr
  @core.memory.getInt32 @core.memory.rdramUint8Array, pc + 4

C1964jsVideoHLE::getCommand = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array, pc) >>> 24 & 0x00ff

#GBI0 Tri1 struct
C1964jsVideoHLE::getGbi0Tri1V2 = (pc) ->
  @core.memory.rdramUint8Array[pc + 7]

C1964jsVideoHLE::getGbi0Tri1V1 = (pc) ->
  @core.memory.rdramUint8Array[pc + 6]

C1964jsVideoHLE::getGbi0Tri1V0 = (pc) ->
  @core.memory.rdramUint8Array[pc + 5]
  
C1964jsVideoHLE::getGbi0Tri1Flag = (pc) ->
  @core.memory.rdramUint8Array[pc + 4]

#GBI0 vertex struct
C1964jsVideoHLE::getGbi0NumVertices = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array, pc) >>> 20 & 0x0F

C1964jsVideoHLE::getGbi0Vertex0 = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array, pc) >>> 16 & 0x0F

#Fiddled vertex struct - Legacy
C1964jsVideoHLE::getFiddledVertexX = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array, pc) >> 16

C1964jsVideoHLE::getFiddledVertexY = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array, pc) << 16 >> 16

C1964jsVideoHLE::getFiddledVertexZ = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array, pc + 4) >> 16
  
#Vertex Struct
C1964jsVideoHLE::getVertexX = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array, pc) >> 16
  
C1964jsVideoHLE::getVertexY = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array, pc) << 16 >> 16

C1964jsVideoHLE::getVertexZ = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array, pc + 4) >> 16

C1964jsVideoHLE::getVertexS = (pc) ->
  #@core.memory.getInt32(@core.memory.rdramUint8Array, pc + 8) >> 16
  (@core.memory.rdramUint8Array[pc + 8]<<8 | @core.memory.rdramUint8Array[pc + 9])<<16>>16

C1964jsVideoHLE::getVertexT = (pc) ->
  #@core.memory.getInt32(@core.memory.rdramUint8Array, pc + 8) << 16 >> 16
  (@core.memory.rdramUint8Array[pc + 10]<<8 | @core.memory.rdramUint8Array[pc + 11])<<16>>16
  
C1964jsVideoHLE::getVertexColorR = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array, pc + 12) >>> 24
  
C1964jsVideoHLE::getVertexColorG = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array, pc + 12) >> 16 & 0xFF
  
C1964jsVideoHLE::getVertexColorB = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array, pc + 12) >> 8 & 0xFF
  
C1964jsVideoHLE::getVertexAlpha = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array, pc + 12) & 0xFF
  
C1964jsVideoHLE::getVertexNormalX = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array, pc + 12) >>> 24
  
C1964jsVideoHLE::getVertexNormalY = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array, pc + 12) >> 16 & 0xFF
  
C1964jsVideoHLE::getVertexNormalZ = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array, pc + 12) >> 8 & 0xFF
  
C1964jsVideoHLE::toSByte = (ub) ->
  if ub > 127 then return ub - 256 else return ub
  
#Texture Struct
C1964jsVideoHLE::getTextureLevel = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array, pc ) >> 11 & 0x07
  
C1964jsVideoHLE::getTextureTile = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array, pc ) >> 8 & 0x07
  
C1964jsVideoHLE::getTextureOn = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array, pc ) & 0x0F
  
C1964jsVideoHLE::getTextureScaleS = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array, pc + 4 ) >> 16 & 0xFFFF
  
C1964jsVideoHLE::getTextureScaleT = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array, pc + 4 ) & 0xFFFF
  
#Combine Struct
C1964jsVideoHLE::getCombineA0 = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array, pc ) >> 20 & 0x0F
  
C1964jsVideoHLE::getCombineB0 = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array, pc + 4 ) >> 28 & 0x0F
  
C1964jsVideoHLE::getCombineC0 = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array, pc ) >> 15 & 0x1F
  
C1964jsVideoHLE::getCombineD0 = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array, pc + 4 ) >> 15 & 0x07
  
C1964jsVideoHLE::getCombineA0a = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array, pc ) >> 12 & 0x07
  
C1964jsVideoHLE::getCombineB0a = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array, pc + 4 ) >> 12 & 0x07
  
C1964jsVideoHLE::getCombineC0a = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array, pc ) >> 9 & 0x07
  
C1964jsVideoHLE::getCombineD0a = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array, pc + 4 ) >> 9 & 0x07
  
C1964jsVideoHLE::getCombineA1 = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array, pc ) >> 5 & 0x0F
  
C1964jsVideoHLE::getCombineB1 = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array, pc + 4 ) >> 24 & 0x0F
  
C1964jsVideoHLE::getCombineC1 = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array, pc ) & 0x1F
  
C1964jsVideoHLE::getCombineD1 = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array, pc + 4 ) >> 6 & 0x07
  
C1964jsVideoHLE::getCombineA1a = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array, pc + 4 ) >> 21 & 0x07
  
C1964jsVideoHLE::getCombineB1a = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array, pc + 4 ) >> 3 & 0x07
  
C1964jsVideoHLE::getCombineC1a = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array, pc + 4 ) >> 18 & 0x07
  
C1964jsVideoHLE::getCombineD1a = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array, pc + 4 ) & 0x07

  
#GBI0 matrix struct
C1964jsVideoHLE::gbi0isProjectionMatrix = (pc) ->
  (if ((@core.memory.rdramUint8Array[pc + 1] & 0x00000001) isnt 0) then true else false)

C1964jsVideoHLE::gbi0LoadMatrix = (pc) ->
  (if ((@core.memory.rdramUint8Array[pc + 1] & 0x00000002) isnt 0) then true else false)

C1964jsVideoHLE::gbi0PushMatrix = (pc) ->
  (if ((@core.memory.rdramUint8Array[pc + 1] & 0x00000004) isnt 0) then true else false)

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
C1964jsVideoHLE::getTexRectXh = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array, pc) >>> 12 & 0x0FFF

#Y coordinate of lower right
C1964jsVideoHLE::getTexRectYh = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array, pc) & 0x0FFF

C1964jsVideoHLE::getTexRectTileNo = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array, pc + 4) >>> 24 & 0x07

#X coordinate of upper left
C1964jsVideoHLE::getTexRectXl = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array, pc + 4) >>> 12 & 0x0FFF

#Y coordinate of upper left
C1964jsVideoHLE::getTexRectYl = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array, pc + 4) & 0x0FFF

C1964jsVideoHLE::getTexRectS = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array, pc + 12) >>> 16 & 0xFFFF

C1964jsVideoHLE::getTexRectT = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array, pc + 12) & 0xFFFF

C1964jsVideoHLE::getTexRectDsDx = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array, pc + 20) >>> 16 & 0xFFFF

C1964jsVideoHLE::getTexRectDtDy = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array, pc + 20) & 0xFFFF

C1964jsVideoHLE::getGbi1Type = (pc) ->


#    return this.core.memory.rdramView.getInt32(pc+4, false) >>> 16 & 0x00ff;
C1964jsVideoHLE::getGbi1Length = (pc) ->


#    return this.core.memory.rdramView.getInt32(pc+4, false) & 0xffff;
C1964jsVideoHLE::getGbi1RspSegmentAddr = (pc) ->


#    return this.core.memory.rdramView.getInt32(pc, false);
C1964jsVideoHLE::getRspSegmentAddr = (seg) ->
  
  #TODO: May need to mask with rdram size - 1
  @segments[seg >> 24 & 0x0F] + (seg & 0x00FFFFFF)


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
C1964jsVideoHLE::getTImgWidth = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array, pc) & 0x0FFF

C1964jsVideoHLE::getTImgSize = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array, pc) >>> 19 & 3

C1964jsVideoHLE::getTImgFormat = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array, pc) >>> 21 & 0x7

C1964jsVideoHLE::getTImgAddr = (pc) ->
  tImgAddr = @core.memory.getInt32(@core.memory.rdramUint8Array, pc + 4)
  @getRspSegmentAddr tImgAddr
  
#SetTile

C1964jsVideoHLE::getSetTileFmt = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array,pc) >> 21 & 0x07
  
C1964jsVideoHLE::getSetTileSiz = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array,pc) >> 19 & 0x03
  
C1964jsVideoHLE::getSetTileLine = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array,pc) >> 9 & 0x01FF
  
C1964jsVideoHLE::getSetTileTmem = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array,pc) & 0x01FF
  
C1964jsVideoHLE::getSetTileTile = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array,pc + 4 ) >> 24 & 0x07
  
C1964jsVideoHLE::getSetTilePal = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array,pc + 4 ) >> 20 & 0x0F
  
C1964jsVideoHLE::getSetTileCmt = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array,pc + 4 ) >> 18 & 0x03
  
C1964jsVideoHLE::getSetTileMaskt = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array,pc + 4 ) >> 14 & 0x0F
  
C1964jsVideoHLE::getSetTileShiftt = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array,pc + 4 ) >> 10 & 0x0F
  
C1964jsVideoHLE::getSetTileCms = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array,pc + 4 ) >> 8 & 0x03
  
C1964jsVideoHLE::getSetTileMasks = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array,pc + 4 ) >> 4 & 0x0F
  
C1964jsVideoHLE::getSetTileShifts = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array,pc + 4 ) & 0x0F
  
#LoadBlock

C1964jsVideoHLE::getLoadBlockTile = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array,pc + 4 ) >> 24 & 0x07
  
C1964jsVideoHLE::getLoadBlockUls = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array,pc ) >> 12 & 0x0FFF
  
C1964jsVideoHLE::getLoadBlockUlt = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array,pc ) & 0x0FFF
  
C1964jsVideoHLE::getLoadBlockLrs = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array,pc + 4 ) >> 12 & 0x0FFF
  
C1964jsVideoHLE::getLoadBlockDxt = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array,pc + 4 ) & 0x0FFF
  
#SetTileSize

C1964jsVideoHLE::getSetTileSizeTile = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array,pc + 4 ) >> 24 & 0x07
  
C1964jsVideoHLE::getSetTileSizeUls = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array,pc ) >> 12 & 0x0FFF
  
C1964jsVideoHLE::getSetTileSizeUlt = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array,pc ) & 0x0FFF
  
C1964jsVideoHLE::getSetTileSizeLrs = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array,pc + 4 ) >> 12 & 0x0FFF
  
C1964jsVideoHLE::getSetTileSizeLrt = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array,pc + 4 ) & 0x0FFF
  
#SetPrimColor

C1964jsVideoHLE::getSetPrimColorM = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array,pc ) >> 8 & 0xFF
  
C1964jsVideoHLE::getSetPrimColorL = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array,pc ) & 0xFF
  
C1964jsVideoHLE::getSetPrimColorR = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array,pc + 4 ) >> 24 & 0xFF
  
C1964jsVideoHLE::getSetPrimColorG = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array,pc + 4 ) >> 16 & 0xFF
  
C1964jsVideoHLE::getSetPrimColorB = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array,pc + 4 ) >> 8 & 0xFF
  
C1964jsVideoHLE::getSetPrimColorA = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array,pc + 4 ) & 0xFF
  
#SetGeometryMode

C1964jsVideoHLE::getSetGeometryMode = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array,pc + 4 ) 
  
C1964jsVideoHLE::getClearGeometryMode = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array,pc + 4 ) 
  
C1964jsVideoHLE::pow2roundup = (value) ->
  result = 1
  while result < value
    result <<= 1
  return result

#SetFillColor
  
C1964jsVideoHLE::getSetFillColorR = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array,pc + 4 ) >> 24 & 0xFF
  
C1964jsVideoHLE::getSetFillColorG = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array,pc + 4 ) >> 16 & 0xFF
  
C1964jsVideoHLE::getSetFillColorB = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array,pc + 4 ) >> 8 & 0xFF
  
C1964jsVideoHLE::getSetFillColorA = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array,pc + 4 ) & 0xFF

#setEnvColor

C1964jsVideoHLE::getSetEnvColorR = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array,pc + 4 ) >> 24 & 0xFF
  
C1964jsVideoHLE::getSetEnvColorG = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array,pc + 4 ) >> 16 & 0xFF
  
C1964jsVideoHLE::getSetEnvColorB = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array,pc + 4 ) >> 8 & 0xFF
  
C1964jsVideoHLE::getSetEnvColorA = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array,pc + 4 ) & 0xFF


C1964jsVideoHLE::microcodeMap0 = [
    'RSP_GBI1_SpNoop', 'RSP_GBI0_Mtx', 'RSP_GBI1_Reserved', 'RSP_GBI1_MoveMem',
    'RSP_GBI0_Vtx', 'RSP_GBI1_Reserved', 'RSP_GBI0_DL', 'RSP_GBI1_Reserved',
    'RSP_GBI1_Reserved', 'RSP_GBI0_Sprite2DBase', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_GBI0_Tri4', 'RSP_GBI1_RDPHalf_Cont', 'RSP_GBI1_RDPHalf_2',
    'RSP_GBI1_RDPHalf_1', 'RSP_GBI1_Line3D', 'RSP_GBI1_ClearGeometryMode', 'RSP_GBI1_SetGeometryMode',
    'RSP_GBI1_EndDL', 'RSP_GBI1_SetOtherModeL', 'RSP_GBI1_SetOtherModeH', 'RSP_GBI1_Texture',
    'RSP_GBI1_MoveWord', 'RSP_GBI1_PopMtx', 'RSP_GBI1_CullDL', 'RSP_GBI1_Tri1',
    'RSP_GBI1_Noop', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RDP_TriFill', 'RDP_TriFillZ', 'RDP_TriTxtr', 'RDP_TriTxtrZ',
    'RDP_TriShade', 'RDP_TriShadeZ', 'RDP_TriShadeTxtr', 'RDP_TriShadeTxtrZ',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'DLParser_TexRect', 'DLParser_TexRectFlip', 'DLParser_RDPLoadSynch', 'DLParser_RDPPipeSynch',
    'DLParser_RDPTileSynch', 'DLParser_RDPFullSynch', 'DLParser_SetKeyGB', 'DLParser_SetKeyR',
    'DLParser_SetConvert', 'DLParser_SetScissor', 'DLParser_SetPrimDepth', 'DLParser_RDPSetOtherMode',
    'DLParser_LoadTLut', 'RSP_RDP_Nothing', 'DLParser_SetTileSize', 'DLParser_LoadBlock',
    'DLParser_LoadTile', 'DLParser_SetTile', 'DLParser_FillRect', 'DLParser_SetFillColor',
    'DLParser_SetFogColor', 'DLParser_SetBlendColor', 'DLParser_SetPrimColor', 'DLParser_SetEnvColor',
    'DLParser_SetCombine', 'DLParser_SetTImg', 'DLParser_SetZImg', 'DLParser_SetCImg'
]