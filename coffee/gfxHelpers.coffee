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

C1964jsVideoHLE::getGbi0MoveWordOffset = (pc) ->
  (@core.memory.rdramUint8Array[pc+1]<<8 | @core.memory.rdramUint8Array[pc+2])>>>0

C1964jsVideoHLE::getGbi0MoveWordType = (pc) ->
  @core.memory.rdramUint8Array[pc+3] & 0x00ff

C1964jsVideoHLE::getGbi0MoveWordValue = (pc) ->
  #@core.memory.getInt32 @core.memory.rdramUint8Array, pc + 4
  (@core.memory.rdramUint8Array[pc+4]<<24 | @core.memory.rdramUint8Array[pc+5]<<16 | @core.memory.rdramUint8Array[pc+6]<<8 | @core.memory.rdramUint8Array[pc+7])>>>0

#GBI0 Dlist struct
C1964jsVideoHLE::getGbi0DlistParam = (pc) ->
  #(@core.memory.rdramUint8Array[pc] << 24 | @core.memory.rdramUint8Array[pc + 1] << 16 | @core.memory.rdramUint8Array[pc + 2] << 8 | @core.memory.rdramUint8Array[pc + 3]) >>> 16 & 0x00ff
  (@core.memory.rdramUint8Array[pc + 1]) & 0x0FF

C1964jsVideoHLE::getGbi0DlistAddr = (pc) -> #this will probably be generic getGbi0Addr
  #@core.memory.getInt32 @core.memory.rdramUint8Array, pc + 4
  (@core.memory.rdramUint8Array[pc+4]<<24 | @core.memory.rdramUint8Array[pc+5]<<16 | @core.memory.rdramUint8Array[pc+6]<<8 | @core.memory.rdramUint8Array[pc+7])>>>0

C1964jsVideoHLE::getCommand = (pc) ->
  @core.memory.rdramUint8Array[pc] & 0x00ff

#GBI0 Tri1 struct
C1964jsVideoHLE::getGbi0Tri1Flag = (pc) ->
  @core.memory.rdramUint8Array[pc + 4]

C1964jsVideoHLE::getGbi0Tri1V0 = (pc) ->
  @core.memory.rdramUint8Array[pc + 5]

C1964jsVideoHLE::getGbi0Tri1V1 = (pc) ->
  @core.memory.rdramUint8Array[pc + 6]

C1964jsVideoHLE::getGbi0Tri1V2 = (pc) ->
  @core.memory.rdramUint8Array[pc + 7]


#GBI0 vertex struct
C1964jsVideoHLE::getGbi0NumVertices = (pc) ->
  #(@core.memory.rdramUint8Array[pc] << 24 | @core.memory.rdramUint8Array[pc + 1] << 16 | @core.memory.rdramUint8Array[pc + 2] << 8 | @core.memory.rdramUint8Array[pc + 3]) >>> 20 & 0x0F
  (@core.memory.rdramUint8Array[pc + 1] >> 4 ) & 0x0F

C1964jsVideoHLE::getGbi0Vertex0 = (pc) ->
  #(@core.memory.rdramUint8Array[pc] << 24 | @core.memory.rdramUint8Array[pc + 1] << 16 | @core.memory.rdramUint8Array[pc + 2] << 8 | @core.memory.rdramUint8Array[pc + 3]) >>> 16 & 0x0F
  (@core.memory.rdramUint8Array[pc + 1]) & 0x0F


#Fiddled vertex struct - Legacy
C1964jsVideoHLE::getFiddledVertexX = (pc) ->
  (@core.memory.rdramUint8Array[pc] << 24 | @core.memory.rdramUint8Array[pc + 1] << 16 | @core.memory.rdramUint8Array[pc + 2] << 8 | @core.memory.rdramUint8Array[pc + 3]) >> 16

C1964jsVideoHLE::getFiddledVertexY = (pc) ->
  (@core.memory.rdramUint8Array[pc] << 24 | @core.memory.rdramUint8Array[pc + 1] << 16 | @core.memory.rdramUint8Array[pc + 2] << 8 | @core.memory.rdramUint8Array[pc + 3]) << 16 >> 16

C1964jsVideoHLE::getFiddledVertexZ = (pc) ->
  (@core.memory.rdramUint8Array[pc+4] << 24 | @core.memory.rdramUint8Array[pc+5] << 16 | @core.memory.rdramUint8Array[pc+6] << 8 | @core.memory.rdramUint8Array[pc+7]) >> 16

#Vertex Struct
C1964jsVideoHLE::getVertexX = (pc) ->
  #if ((pc>>>0) > 0x00800000)
  #  alert "oops"
  (@core.memory.rdramUint8Array[pc] << 24 | @core.memory.rdramUint8Array[pc + 1] << 16) >> 16

C1964jsVideoHLE::getVertexY = (pc) ->
  (@core.memory.rdramUint8Array[pc + 2] << 24 | @core.memory.rdramUint8Array[pc + 3] << 16) >> 16

C1964jsVideoHLE::getVertexZ = (pc) ->
  (@core.memory.rdramUint8Array[pc + 4] << 24 | @core.memory.rdramUint8Array[pc + 5] << 16) >> 16

C1964jsVideoHLE::getVertexW = (pc) ->
  (@core.memory.rdramUint8Array[pc + 6] << 24 | @core.memory.rdramUint8Array[pc + 7] << 16) >> 16


C1964jsVideoHLE::getVertexS = (pc) ->
  #@core.memory.getInt32(@core.memory.rdramUint8Array, pc + 8) >> 16
  (@core.memory.rdramUint8Array[pc + 8]<<8 | @core.memory.rdramUint8Array[pc + 9])<<16>>16

C1964jsVideoHLE::getVertexT = (pc) ->
  #@core.memory.getInt32(@core.memory.rdramUint8Array, pc + 8) << 16 >> 16
  (@core.memory.rdramUint8Array[pc + 10]<<8 | @core.memory.rdramUint8Array[pc + 11])<<16>>16

C1964jsVideoHLE::getVertexColorR = (pc) ->
  @core.memory.rdramUint8Array[pc+12] >>> 0

C1964jsVideoHLE::getVertexColorG = (pc) ->
  @core.memory.rdramUint8Array[pc+13] >>> 0

C1964jsVideoHLE::getVertexColorB = (pc) ->
  @core.memory.rdramUint8Array[pc+14] >>> 0

C1964jsVideoHLE::getVertexAlpha = (pc) ->
  @core.memory.rdramUint8Array[pc+15] >>> 0

C1964jsVideoHLE::getVertexNormalX = (pc) ->
  (@core.memory.rdramUint8Array[pc+12] << 24 | @core.memory.rdramUint8Array[pc+13] << 16 | @core.memory.rdramUint8Array[pc+14] << 8 | @core.memory.rdramUint8Array[pc+15]) >> 24

C1964jsVideoHLE::getVertexNormalY = (pc) ->
  (@core.memory.rdramUint8Array[pc+12] << 24 | @core.memory.rdramUint8Array[pc+13] << 16 | @core.memory.rdramUint8Array[pc+14] << 8 | @core.memory.rdramUint8Array[pc+15]) << 8 >> 24

C1964jsVideoHLE::getVertexNormalZ = (pc) ->
  (@core.memory.rdramUint8Array[pc+12] << 24 | @core.memory.rdramUint8Array[pc+13] << 16 | @core.memory.rdramUint8Array[pc+14] << 8 | @core.memory.rdramUint8Array[pc+15]) << 16 >> 24

C1964jsVideoHLE::getVertexNormalA = (pc) ->
  (@core.memory.rdramUint8Array[pc+12] << 24 | @core.memory.rdramUint8Array[pc+13] << 16 | @core.memory.rdramUint8Array[pc+14] << 8 | @core.memory.rdramUint8Array[pc+15]) << 24 >> 24


C1964jsVideoHLE::getVertexLightX = (pc) ->
  @core.memory.rdramUint8Array[pc+8] << 24>> 24

C1964jsVideoHLE::getVertexLightY = (pc) ->
  @core.memory.rdramUint8Array[pc+9] << 24>> 24

C1964jsVideoHLE::getVertexLightZ = (pc) ->
  @core.memory.rdramUint8Array[pc+10] << 24>> 24



C1964jsVideoHLE::toSByte = (ub) ->
  if ub > 127 then return ub - 256 else return ub

#Texture Struct
C1964jsVideoHLE::getTextureLevel = (pc) ->
  (@core.memory.rdramUint8Array[pc] << 24 | @core.memory.rdramUint8Array[pc+1] << 16 | @core.memory.rdramUint8Array[pc+2] << 8 | @core.memory.rdramUint8Array[pc+3]) >> 11 & 0x07

C1964jsVideoHLE::getTextureTile = (pc) ->
  (@core.memory.rdramUint8Array[pc] << 24 | @core.memory.rdramUint8Array[pc+1] << 16 | @core.memory.rdramUint8Array[pc+2] << 8 | @core.memory.rdramUint8Array[pc+3]) >> 8 & 0x07

C1964jsVideoHLE::getTextureOn = (pc) ->
  (@core.memory.rdramUint8Array[pc] << 24 | @core.memory.rdramUint8Array[pc+1] << 16 | @core.memory.rdramUint8Array[pc+2] << 8 | @core.memory.rdramUint8Array[pc+3]) & 0x0F

C1964jsVideoHLE::getTextureScaleS = (pc) ->
  (@core.memory.rdramUint8Array[pc+4] << 24 | @core.memory.rdramUint8Array[pc+5] << 16 | @core.memory.rdramUint8Array[pc+6] << 8 | @core.memory.rdramUint8Array[pc+7]) >> 16 & 0xFFFF

C1964jsVideoHLE::getTextureScaleT = (pc) ->
  (@core.memory.rdramUint8Array[pc+4] << 24 | @core.memory.rdramUint8Array[pc+5] << 16 | @core.memory.rdramUint8Array[pc+6] << 8 | @core.memory.rdramUint8Array[pc+7]) & 0xFFFF

#Combine Struct
C1964jsVideoHLE::getCombineA0 = (pc) ->
  ((@core.memory.rdramUint8Array[pc] << 24 | @core.memory.rdramUint8Array[pc+1] << 16 | @core.memory.rdramUint8Array[pc+2] << 8 | @core.memory.rdramUint8Array[pc+3]) >> 20) & 0x0F

C1964jsVideoHLE::getCombineB0 = (pc) ->
  ((@core.memory.rdramUint8Array[pc+4] << 24 | @core.memory.rdramUint8Array[pc+5] << 16 | @core.memory.rdramUint8Array[pc+6] << 8 | @core.memory.rdramUint8Array[pc+7]) >> 28) & 0x0F

C1964jsVideoHLE::getCombineC0 = (pc) ->
  (@core.memory.rdramUint8Array[pc] << 24 | @core.memory.rdramUint8Array[pc+1] << 16 | @core.memory.rdramUint8Array[pc+2] << 8 | @core.memory.rdramUint8Array[pc+3]) >> 15 & 0x1F

C1964jsVideoHLE::getCombineD0 = (pc) ->
  ((@core.memory.rdramUint8Array[pc+4] << 24 | @core.memory.rdramUint8Array[pc+5] << 16 | @core.memory.rdramUint8Array[pc+6] << 8 | @core.memory.rdramUint8Array[pc+7]) >> 15) & 0x07

C1964jsVideoHLE::getCombineA0a = (pc) ->
  ((@core.memory.rdramUint8Array[pc] << 24 | @core.memory.rdramUint8Array[pc+1] << 16 | @core.memory.rdramUint8Array[pc+2] << 8 | @core.memory.rdramUint8Array[pc+3]) >> 12) & 0x07

C1964jsVideoHLE::getCombineB0a = (pc) ->
  ((@core.memory.rdramUint8Array[pc+4] << 24 | @core.memory.rdramUint8Array[pc+5] << 16 | @core.memory.rdramUint8Array[pc+6] << 8 | @core.memory.rdramUint8Array[pc+7]) >> 12) & 0x07

C1964jsVideoHLE::getCombineC0a = (pc) ->
  ((@core.memory.rdramUint8Array[pc] << 24 | @core.memory.rdramUint8Array[pc+1] << 16 | @core.memory.rdramUint8Array[pc+2] << 8 | @core.memory.rdramUint8Array[pc+3]) >> 9) & 0x07

C1964jsVideoHLE::getCombineD0a = (pc) ->
  ((@core.memory.rdramUint8Array[pc+4] << 24 | @core.memory.rdramUint8Array[pc+5] << 16 | @core.memory.rdramUint8Array[pc+6] << 8 | @core.memory.rdramUint8Array[pc+7]) >> 9) & 0x07

C1964jsVideoHLE::getCombineA1 = (pc) ->
  ((@core.memory.rdramUint8Array[pc] << 24 | @core.memory.rdramUint8Array[pc+1] << 16 | @core.memory.rdramUint8Array[pc+2] << 8 | @core.memory.rdramUint8Array[pc+3]) >> 5) & 0x0F

C1964jsVideoHLE::getCombineB1 = (pc) ->
  ((@core.memory.rdramUint8Array[pc+4] << 24 | @core.memory.rdramUint8Array[pc+5] << 16 | @core.memory.rdramUint8Array[pc+6] << 8 | @core.memory.rdramUint8Array[pc+7]) >> 24) & 0x0F

C1964jsVideoHLE::getCombineC1 = (pc) ->
  (@core.memory.rdramUint8Array[pc] << 24 | @core.memory.rdramUint8Array[pc+1] << 16 | @core.memory.rdramUint8Array[pc+2] << 8 | @core.memory.rdramUint8Array[pc+3]) & 0x1F

C1964jsVideoHLE::getCombineD1 = (pc) ->
  ((@core.memory.rdramUint8Array[pc+4] << 24 | @core.memory.rdramUint8Array[pc+5] << 16 | @core.memory.rdramUint8Array[pc+6] << 8 | @core.memory.rdramUint8Array[pc+7]) >> 6) & 0x07

C1964jsVideoHLE::getCombineA1a = (pc) ->
  ((@core.memory.rdramUint8Array[pc+4] << 24 | @core.memory.rdramUint8Array[pc+5] << 16 | @core.memory.rdramUint8Array[pc+6] << 8 | @core.memory.rdramUint8Array[pc+7]) >> 21) & 0x07

C1964jsVideoHLE::getCombineB1a = (pc) ->
  ((@core.memory.rdramUint8Array[pc+4] << 24 | @core.memory.rdramUint8Array[pc+5] << 16 | @core.memory.rdramUint8Array[pc+6] << 8 | @core.memory.rdramUint8Array[pc+7]) >> 3) & 0x07

C1964jsVideoHLE::getCombineC1a = (pc) ->
  ((@core.memory.rdramUint8Array[pc+4] << 24 | @core.memory.rdramUint8Array[pc+5] << 16 | @core.memory.rdramUint8Array[pc+6] << 8 | @core.memory.rdramUint8Array[pc+7]) >> 18) & 0x07

C1964jsVideoHLE::getCombineD1a = (pc) ->
  (@core.memory.rdramUint8Array[pc+4] << 24 | @core.memory.rdramUint8Array[pc+5] << 16 | @core.memory.rdramUint8Array[pc+6] << 8 | @core.memory.rdramUint8Array[pc+7]) & 0x07


#GBI0 matrix struct
C1964jsVideoHLE::gbi0isProjectionMatrix = (pc) ->
  (if ((@core.memory.rdramUint8Array[pc + 1] & 0x00000001) isnt 0) then true else false)

C1964jsVideoHLE::gbi0LoadMatrix = (pc) ->
  (if ((@core.memory.rdramUint8Array[pc + 1] & 0x00000002) isnt 0) then true else false)

C1964jsVideoHLE::gbi0PushMatrix = (pc) ->
  (if ((@core.memory.rdramUint8Array[pc + 1] & 0x00000004) isnt 0) then true else false)

C1964jsVideoHLE::gbi0PopMtxIsProjection = (pc) ->
  (if ((@core.memory.rdramUint8Array[pc + 7] & 0x00000001) isnt 0) then true else false)

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
  (@core.memory.rdramUint8Array[pc] << 24 | @core.memory.rdramUint8Array[pc + 1] << 16 | @core.memory.rdramUint8Array[pc + 2] << 8 | @core.memory.rdramUint8Array[pc + 3]) >>> 12 & 0x0FFF

#Y coordinate of lower right
C1964jsVideoHLE::getTexRectYh = (pc) ->
  (@core.memory.rdramUint8Array[pc] << 24 | @core.memory.rdramUint8Array[pc + 1] << 16 | @core.memory.rdramUint8Array[pc + 2] << 8 | @core.memory.rdramUint8Array[pc + 3]) & 0x0FFF

C1964jsVideoHLE::getTexRectTileNo = (pc) ->
  (@core.memory.rdramUint8Array[pc+4] << 24 | @core.memory.rdramUint8Array[pc+5] << 16 | @core.memory.rdramUint8Array[pc+6] << 8 | @core.memory.rdramUint8Array[pc+7]) >>> 24 & 0x07

#X coordinate of upper left
C1964jsVideoHLE::getTexRectXl = (pc) ->
  (@core.memory.rdramUint8Array[pc+4] << 24 | @core.memory.rdramUint8Array[pc+5] << 16 | @core.memory.rdramUint8Array[pc+6] << 8 | @core.memory.rdramUint8Array[pc+7]) >>> 12 & 0x0FFF

#Y coordinate of upper left
C1964jsVideoHLE::getTexRectYl = (pc) ->
  (@core.memory.rdramUint8Array[pc+4] << 24 | @core.memory.rdramUint8Array[pc+5] << 16 | @core.memory.rdramUint8Array[pc+6] << 8 | @core.memory.rdramUint8Array[pc+7]) & 0x0FFF

C1964jsVideoHLE::getTexRectS = (pc) ->
  (@core.memory.rdramUint8Array[pc+12] << 24 | @core.memory.rdramUint8Array[pc+13] << 16 | @core.memory.rdramUint8Array[pc+14] << 8 | @core.memory.rdramUint8Array[pc+15]) >>> 16 & 0xFFFF

C1964jsVideoHLE::getTexRectT = (pc) ->
  (@core.memory.rdramUint8Array[pc+12] << 24 | @core.memory.rdramUint8Array[pc+13] << 16 | @core.memory.rdramUint8Array[pc+14] << 8 | @core.memory.rdramUint8Array[pc+15]) & 0xFFFF

C1964jsVideoHLE::getTexRectDsDx = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array, pc + 20) >>> 16 & 0xFFFF

C1964jsVideoHLE::getTexRectDtDy = (pc) ->
  @core.memory.getInt32(@core.memory.rdramUint8Array, pc + 20) & 0xFFFF

#is this right?
C1964jsVideoHLE::getGbi1Type = (pc) ->
  (@core.memory.rdramUint8Array[pc] << 24 | @core.memory.rdramUint8Array[pc+1] << 16 | @core.memory.rdramUint8Array[pc+2] << 8 | @core.memory.rdramUint8Array[pc+3]) >>> 16 & 0x0FF

C1964jsVideoHLE::getRspSegmentAddr = (seg) ->
  #TODO: May need to mask with rdram size - 1
  (@segments[(seg >> 24) & 0x0F]&0x00ffffff) + (seg & 0x00FFFFFF)


C1964jsVideoHLE::getOtherModeL = (pc) ->
  (@core.memory.rdramUint8Array[pc] << 24 | @core.memory.rdramUint8Array[pc + 1] << 16 | @core.memory.rdramUint8Array[pc + 2] << 8 | @core.memory.rdramUint8Array[pc + 3])

C1964jsVideoHLE::getOtherModeH = (pc) ->
  (@core.memory.rdramUint8Array[pc] << 24 | @core.memory.rdramUint8Array[pc + 1] << 16 | @core.memory.rdramUint8Array[pc + 2] << 8 | @core.memory.rdramUint8Array[pc + 3])


C1964jsVideoHLE::getWord0 = (pc) ->
  (@core.memory.rdramUint8Array[pc] << 24 | @core.memory.rdramUint8Array[pc + 1] << 16 | @core.memory.rdramUint8Array[pc + 2] << 8 | @core.memory.rdramUint8Array[pc + 3])

C1964jsVideoHLE::getWord1 = (pc) ->
  (@core.memory.rdramUint8Array[pc + 4] << 24 | @core.memory.rdramUint8Array[pc + 5] << 16 | @core.memory.rdramUint8Array[pc + 6] << 8 | @core.memory.rdramUint8Array[pc + 7])

C1964jsVideoHLE::getShort = (pc) ->
  (@core.memory.rdramUint8Array[pc] << 24 | @core.memory.rdramUint8Array[pc + 1] << 16) >> 16


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
  (@core.memory.rdramUint8Array[pc] << 24 | @core.memory.rdramUint8Array[pc + 1] << 16 | @core.memory.rdramUint8Array[pc + 2] << 8 | @core.memory.rdramUint8Array[pc + 3]) & 0x0FFF

C1964jsVideoHLE::getTImgSize = (pc) ->
  (@core.memory.rdramUint8Array[pc] << 24 | @core.memory.rdramUint8Array[pc + 1] << 16 | @core.memory.rdramUint8Array[pc + 2] << 8 | @core.memory.rdramUint8Array[pc + 3]) >>> 19 & 3

C1964jsVideoHLE::getTImgFormat = (pc) ->
  (@core.memory.rdramUint8Array[pc] << 24 | @core.memory.rdramUint8Array[pc + 1] << 16 | @core.memory.rdramUint8Array[pc + 2] << 8 | @core.memory.rdramUint8Array[pc + 3]) >>> 21 & 0x7

C1964jsVideoHLE::getTImgAddr = (pc) ->
  tImgAddr = (@core.memory.rdramUint8Array[pc+4] << 24 | @core.memory.rdramUint8Array[pc+5] << 16 | @core.memory.rdramUint8Array[pc+6] << 8 | @core.memory.rdramUint8Array[pc+7])
  @getRspSegmentAddr tImgAddr

#SetTile

C1964jsVideoHLE::getSetTileFmt = (pc) ->
  (@core.memory.rdramUint8Array[pc] << 24 | @core.memory.rdramUint8Array[pc + 1] << 16 | @core.memory.rdramUint8Array[pc + 2] << 8 | @core.memory.rdramUint8Array[pc + 3]) >> 21 & 0x07

C1964jsVideoHLE::getSetTileSiz = (pc) ->
  (@core.memory.rdramUint8Array[pc] << 24 | @core.memory.rdramUint8Array[pc + 1] << 16 | @core.memory.rdramUint8Array[pc + 2] << 8 | @core.memory.rdramUint8Array[pc + 3]) >> 19 & 0x03

C1964jsVideoHLE::getSetTileLine = (pc) ->
  (@core.memory.rdramUint8Array[pc] << 24 | @core.memory.rdramUint8Array[pc + 1] << 16 | @core.memory.rdramUint8Array[pc + 2] << 8 | @core.memory.rdramUint8Array[pc + 3]) >> 9 & 0x01FF

C1964jsVideoHLE::getSetTileTmem = (pc) ->
  (@core.memory.rdramUint8Array[pc] << 24 | @core.memory.rdramUint8Array[pc + 1] << 16 | @core.memory.rdramUint8Array[pc + 2] << 8 | @core.memory.rdramUint8Array[pc + 3]) & 0x01FF

C1964jsVideoHLE::getSetTileTile = (pc) ->
  (@core.memory.rdramUint8Array[pc+4] << 24 | @core.memory.rdramUint8Array[pc+5] << 16 | @core.memory.rdramUint8Array[pc+6] << 8 | @core.memory.rdramUint8Array[pc+7]) >> 24 & 0x07

C1964jsVideoHLE::getSetTilePal = (pc) ->
  (@core.memory.rdramUint8Array[pc+4] << 24 | @core.memory.rdramUint8Array[pc+5] << 16 | @core.memory.rdramUint8Array[pc+6] << 8 | @core.memory.rdramUint8Array[pc+7]) >> 20 & 0x0F

C1964jsVideoHLE::getSetTileCmt = (pc) ->
  (@core.memory.rdramUint8Array[pc+4] << 24 | @core.memory.rdramUint8Array[pc+5] << 16 | @core.memory.rdramUint8Array[pc+6] << 8 | @core.memory.rdramUint8Array[pc+7]) >> 18 & 0x03

C1964jsVideoHLE::getSetTileMirrorT = (pc) ->
  (@core.memory.rdramUint8Array[pc+4] << 24 | @core.memory.rdramUint8Array[pc+5] << 16 | @core.memory.rdramUint8Array[pc+6] << 8 | @core.memory.rdramUint8Array[pc+7]) >> 15 & 0x01

C1964jsVideoHLE::getSetTileMaskt = (pc) ->
  (@core.memory.rdramUint8Array[pc+4] << 24 | @core.memory.rdramUint8Array[pc+5] << 16 | @core.memory.rdramUint8Array[pc+6] << 8 | @core.memory.rdramUint8Array[pc+7]) >> 14 & 0x0F

C1964jsVideoHLE::getSetTileShiftt = (pc) ->
  (@core.memory.rdramUint8Array[pc+4] << 24 | @core.memory.rdramUint8Array[pc+5] << 16 | @core.memory.rdramUint8Array[pc+6] << 8 | @core.memory.rdramUint8Array[pc+7]) >> 10 & 0x0F

C1964jsVideoHLE::getSetTileCms = (pc) ->
  (@core.memory.rdramUint8Array[pc+4] << 24 | @core.memory.rdramUint8Array[pc+5] << 16 | @core.memory.rdramUint8Array[pc+6] << 8 | @core.memory.rdramUint8Array[pc+7]) >> 8 & 0x03

C1964jsVideoHLE::getSetTileMirrorS = (pc) ->
  (@core.memory.rdramUint8Array[pc+4] << 24 | @core.memory.rdramUint8Array[pc+5] << 16 | @core.memory.rdramUint8Array[pc+6] << 8 | @core.memory.rdramUint8Array[pc+7]) >> 5 & 0x01

C1964jsVideoHLE::getSetTileMasks = (pc) ->
  (@core.memory.rdramUint8Array[pc+4] << 24 | @core.memory.rdramUint8Array[pc+5] << 16 | @core.memory.rdramUint8Array[pc+6] << 8 | @core.memory.rdramUint8Array[pc+7]) >> 4 & 0x0F

C1964jsVideoHLE::getSetTileShifts = (pc) ->
  (@core.memory.rdramUint8Array[pc+4] << 24 | @core.memory.rdramUint8Array[pc+5] << 16 | @core.memory.rdramUint8Array[pc+6] << 8 | @core.memory.rdramUint8Array[pc+7]) & 0x0F

#LoadBlock

C1964jsVideoHLE::getLoadBlockTile = (pc) ->
  (@core.memory.rdramUint8Array[pc+4] << 24 | @core.memory.rdramUint8Array[pc+5] << 16 | @core.memory.rdramUint8Array[pc+6] << 8 | @core.memory.rdramUint8Array[pc+7]) >> 24 & 0x07

C1964jsVideoHLE::getLoadBlockUls = (pc) ->
  (@core.memory.rdramUint8Array[pc] << 24 | @core.memory.rdramUint8Array[pc + 1] << 16 | @core.memory.rdramUint8Array[pc + 2] << 8 | @core.memory.rdramUint8Array[pc + 3]) >> 12 & 0x0FFF

C1964jsVideoHLE::getLoadBlockUlt = (pc) ->
  (@core.memory.rdramUint8Array[pc] << 24 | @core.memory.rdramUint8Array[pc + 1] << 16 | @core.memory.rdramUint8Array[pc + 2] << 8 | @core.memory.rdramUint8Array[pc + 3]) & 0x0FFF

C1964jsVideoHLE::getLoadBlockLrs = (pc) ->
  (@core.memory.rdramUint8Array[pc+4] << 24 | @core.memory.rdramUint8Array[pc+5] << 16 | @core.memory.rdramUint8Array[pc+6] << 8 | @core.memory.rdramUint8Array[pc+7]) >> 12 & 0x0FFF

C1964jsVideoHLE::getLoadBlockDxt = (pc) ->
  (@core.memory.rdramUint8Array[pc+4] << 24 | @core.memory.rdramUint8Array[pc+5] << 16 | @core.memory.rdramUint8Array[pc+6] << 8 | @core.memory.rdramUint8Array[pc+7]) & 0x0FFF

#SetTileSize

C1964jsVideoHLE::getSetTileSizeTile = (pc) ->
  (@core.memory.rdramUint8Array[pc+4] << 24 | @core.memory.rdramUint8Array[pc+5] << 16 | @core.memory.rdramUint8Array[pc+6] << 8 | @core.memory.rdramUint8Array[pc+7]) >> 24 & 0x07

C1964jsVideoHLE::getSetTileSizeUls = (pc) ->
  (@core.memory.rdramUint8Array[pc] << 24 | @core.memory.rdramUint8Array[pc + 1] << 16 | @core.memory.rdramUint8Array[pc + 2] << 8 | @core.memory.rdramUint8Array[pc + 3]) >> 12 & 0x0FFF

C1964jsVideoHLE::getSetTileSizeUlt = (pc) ->
  (@core.memory.rdramUint8Array[pc] << 24 | @core.memory.rdramUint8Array[pc + 1] << 16 | @core.memory.rdramUint8Array[pc + 2] << 8 | @core.memory.rdramUint8Array[pc + 3]) & 0x0FFF

C1964jsVideoHLE::getSetTileSizeLrs = (pc) ->
  (@core.memory.rdramUint8Array[pc+4] << 24 | @core.memory.rdramUint8Array[pc+5] << 16 | @core.memory.rdramUint8Array[pc+6] << 8 | @core.memory.rdramUint8Array[pc+7]) >> 12 & 0x0FFF

C1964jsVideoHLE::getSetTileSizeLrt = (pc) ->
  (@core.memory.rdramUint8Array[pc+4] << 24 | @core.memory.rdramUint8Array[pc+5] << 16 | @core.memory.rdramUint8Array[pc+6] << 8 | @core.memory.rdramUint8Array[pc+7]) & 0x0FFF

#SetPrimColor

C1964jsVideoHLE::getSetPrimColorM = (pc) ->
  (@core.memory.rdramUint8Array[pc] << 24 | @core.memory.rdramUint8Array[pc + 1] << 16 | @core.memory.rdramUint8Array[pc + 2] << 8 | @core.memory.rdramUint8Array[pc + 3]) >>> 8 & 0xFF

C1964jsVideoHLE::getSetPrimColorL = (pc) ->
  (@core.memory.rdramUint8Array[pc] << 24 | @core.memory.rdramUint8Array[pc + 1] << 16 | @core.memory.rdramUint8Array[pc + 2] << 8 | @core.memory.rdramUint8Array[pc + 3]) & 0x000000FF

C1964jsVideoHLE::getSetPrimColorR = (pc) ->
  (@core.memory.rdramUint8Array[pc+4] << 24 | @core.memory.rdramUint8Array[pc+5] << 16 | @core.memory.rdramUint8Array[pc+6] << 8 | @core.memory.rdramUint8Array[pc+7]) >>> 24

C1964jsVideoHLE::getSetPrimColorG = (pc) ->
  (@core.memory.rdramUint8Array[pc+4] << 24 | @core.memory.rdramUint8Array[pc+5] << 16 | @core.memory.rdramUint8Array[pc+6] << 8 | @core.memory.rdramUint8Array[pc+7]) << 8 >>> 24

C1964jsVideoHLE::getSetPrimColorB = (pc) ->
  (@core.memory.rdramUint8Array[pc+4] << 24 | @core.memory.rdramUint8Array[pc+5] << 16 | @core.memory.rdramUint8Array[pc+6] << 8 | @core.memory.rdramUint8Array[pc+7]) << 16 >>> 24

C1964jsVideoHLE::getSetPrimColorA = (pc) ->
  (@core.memory.rdramUint8Array[pc+4] << 24 | @core.memory.rdramUint8Array[pc+5] << 16 | @core.memory.rdramUint8Array[pc+6] << 8 | @core.memory.rdramUint8Array[pc+7]) << 24 >>> 24

#SetGeometryMode

C1964jsVideoHLE::getSetGeometryMode = (pc) ->
  (@core.memory.rdramUint8Array[pc+4] << 24 | @core.memory.rdramUint8Array[pc+5] << 16 | @core.memory.rdramUint8Array[pc+6] << 8 | @core.memory.rdramUint8Array[pc+7])

C1964jsVideoHLE::getClearGeometryMode = (pc) ->
  (@core.memory.rdramUint8Array[pc+4] << 24 | @core.memory.rdramUint8Array[pc+5] << 16 | @core.memory.rdramUint8Array[pc+6] << 8 | @core.memory.rdramUint8Array[pc+7])

C1964jsVideoHLE::pow2roundup = (value) ->
  result = 1
  while result < value
    result <<= 1
  return result

#SetFillColor

C1964jsVideoHLE::getSetFillColorR = (pc) ->
  (@core.memory.rdramUint8Array[pc+4] << 24 | @core.memory.rdramUint8Array[pc+5] << 16 | @core.memory.rdramUint8Array[pc+6] << 8 | @core.memory.rdramUint8Array[pc+7]) >>> 24

C1964jsVideoHLE::getSetFillColorG = (pc) ->
  (@core.memory.rdramUint8Array[pc+4] << 24 | @core.memory.rdramUint8Array[pc+5] << 16 | @core.memory.rdramUint8Array[pc+6] << 8 | @core.memory.rdramUint8Array[pc+7]) << 8 >>> 24

C1964jsVideoHLE::getSetFillColorB = (pc) ->
  (@core.memory.rdramUint8Array[pc+4] << 24 | @core.memory.rdramUint8Array[pc+5] << 16 | @core.memory.rdramUint8Array[pc+6] << 8 | @core.memory.rdramUint8Array[pc+7]) << 16 >>> 24

C1964jsVideoHLE::getSetFillColorA = (pc) ->
  (@core.memory.rdramUint8Array[pc+4] << 24 | @core.memory.rdramUint8Array[pc+5] << 16 | @core.memory.rdramUint8Array[pc+6] << 8 | @core.memory.rdramUint8Array[pc+7]) << 24 >>> 24

#setEnvColor

C1964jsVideoHLE::getSetEnvColorR = (pc) ->
  (@core.memory.rdramUint8Array[pc+4] << 24 | @core.memory.rdramUint8Array[pc+5] << 16 | @core.memory.rdramUint8Array[pc+6] << 8 | @core.memory.rdramUint8Array[pc+7]) >>> 24

C1964jsVideoHLE::getSetEnvColorG = (pc) ->
  (@core.memory.rdramUint8Array[pc+4] << 24 | @core.memory.rdramUint8Array[pc+5] << 16 | @core.memory.rdramUint8Array[pc+6] << 8 | @core.memory.rdramUint8Array[pc+7]) << 8 >>> 24

C1964jsVideoHLE::getSetEnvColorB = (pc) ->
  (@core.memory.rdramUint8Array[pc+4] << 24 | @core.memory.rdramUint8Array[pc+5] << 16 | @core.memory.rdramUint8Array[pc+6] << 8 | @core.memory.rdramUint8Array[pc+7]) << 16 >>> 24

C1964jsVideoHLE::getSetEnvColorA = (pc) ->
  (@core.memory.rdramUint8Array[pc+4] << 24 | @core.memory.rdramUint8Array[pc+5] << 16 | @core.memory.rdramUint8Array[pc+6] << 8 | @core.memory.rdramUint8Array[pc+7]) << 24 >>> 24


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
