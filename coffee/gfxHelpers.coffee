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
  @core.memory.u8[pc+1]<<8 | @core.memory.u8[pc+2]

C1964jsVideoHLE::getGbi0MoveWordType = (pc) ->
  @core.memory.u8[pc+3]

C1964jsVideoHLE::getGbi0MoveWordValue = (pc) ->
  #@core.memory.getInt32 @core.memory.u8, pc + 4
  @core.memory.u8[pc+4]<<24 | @core.memory.u8[pc+5]<<16 | @core.memory.u8[pc+6]<<8 | @core.memory.u8[pc+7]

#GBI0 Dlist struct
C1964jsVideoHLE::getGbi0DlistParam = (pc) ->
  #(@core.memory.u8[pc] << 24 | @core.memory.u8[pc + 1] << 16 | @core.memory.u8[pc + 2] << 8 | @core.memory.u8[pc + 3]) >>> 16 & 0x00ff
  @core.memory.u8[pc + 1]

C1964jsVideoHLE::getGbi0DlistAddr = (pc) -> #this will probably be generic getGbi0Addr
  #@core.memory.getInt32 @core.memory.u8, pc + 4
  @core.memory.u8[pc+4]<<24 | @core.memory.u8[pc+5]<<16 | @core.memory.u8[pc+6]<<8 | @core.memory.u8[pc+7]

C1964jsVideoHLE::getCommand = (pc) ->
  @core.memory.u8[pc]

#GBI0 Tri1 struct
C1964jsVideoHLE::getGbi0Tri1Flag = (pc) ->
  @core.memory.u8[pc + 4]

C1964jsVideoHLE::getGbi0Tri1V0 = (pc) ->
  @core.memory.u8[pc + 5]

C1964jsVideoHLE::getGbi0Tri1V1 = (pc) ->
  @core.memory.u8[pc + 6]

C1964jsVideoHLE::getGbi0Tri1V2 = (pc) ->
  @core.memory.u8[pc + 7]


#GBI0 vertex struct
C1964jsVideoHLE::getGbi0NumVertices = (pc) ->
  #(@core.memory.u8[pc] << 24 | @core.memory.u8[pc + 1] << 16 | @core.memory.u8[pc + 2] << 8 | @core.memory.u8[pc + 3]) >>> 20 & 0x0F
  (@core.memory.u8[pc + 1] >> 4 ) & 0x0F

C1964jsVideoHLE::getGbi0Vertex0 = (pc) ->
  #(@core.memory.u8[pc] << 24 | @core.memory.u8[pc + 1] << 16 | @core.memory.u8[pc + 2] << 8 | @core.memory.u8[pc + 3]) >>> 16 & 0x0F
  (@core.memory.u8[pc + 1]) & 0x0F


#Fiddled vertex struct - Legacy
C1964jsVideoHLE::getFiddledVertexX = (pc) ->
  (@core.memory.u8[pc] << 24 | @core.memory.u8[pc + 1] << 16 | @core.memory.u8[pc + 2] << 8 | @core.memory.u8[pc + 3]) >> 16

C1964jsVideoHLE::getFiddledVertexY = (pc) ->
  (@core.memory.u8[pc] << 24 | @core.memory.u8[pc + 1] << 16 | @core.memory.u8[pc + 2] << 8 | @core.memory.u8[pc + 3]) << 16 >> 16

C1964jsVideoHLE::getFiddledVertexZ = (pc) ->
  (@core.memory.u8[pc+4] << 24 | @core.memory.u8[pc+5] << 16 | @core.memory.u8[pc+6] << 8 | @core.memory.u8[pc+7]) >> 16

#Vertex Struct
C1964jsVideoHLE::getVertexX = (pc) ->
  #if ((pc>>>0) > 0x00800000)
  #  alert "oops"
  (@core.memory.u8[pc] << 24 | @core.memory.u8[pc + 1] << 16) >> 16

C1964jsVideoHLE::getVertexY = (pc) ->
  (@core.memory.u8[pc + 2] << 24 | @core.memory.u8[pc + 3] << 16) >> 16

C1964jsVideoHLE::getVertexZ = (pc) ->
  (@core.memory.u8[pc + 4] << 24 | @core.memory.u8[pc + 5] << 16) >> 16

C1964jsVideoHLE::getVertexW = (pc) ->
  (@core.memory.u8[pc + 6] << 24 | @core.memory.u8[pc + 7] << 16) >> 16


C1964jsVideoHLE::getVertexS = (pc) ->
  #@core.memory.getInt32(@core.memory.u8, pc + 8) >> 16
  (@core.memory.u8[pc + 8]<<8 | @core.memory.u8[pc + 9])<<16>>16

C1964jsVideoHLE::getVertexT = (pc) ->
  #@core.memory.getInt32(@core.memory.u8, pc + 8) << 16 >> 16
  (@core.memory.u8[pc + 10]<<8 | @core.memory.u8[pc + 11])<<16>>16

C1964jsVideoHLE::getVertexColorR = (pc) ->
  @core.memory.u8[pc+12]

C1964jsVideoHLE::getVertexColorG = (pc) ->
  @core.memory.u8[pc+13]

C1964jsVideoHLE::getVertexColorB = (pc) ->
  @core.memory.u8[pc+14]

C1964jsVideoHLE::getVertexAlpha = (pc) ->
  @core.memory.u8[pc+15]

C1964jsVideoHLE::getVertexNormalX = (pc) ->
  #(@core.memory.u8[pc+12] << 24 | @core.memory.u8[pc+13] << 16 | @core.memory.u8[pc+14] << 8 | @core.memory.u8[pc+15]) >> 24
  @core.memory.u8[pc+12] << 24 >> 24

C1964jsVideoHLE::getVertexNormalY = (pc) ->
  #(@core.memory.u8[pc+12] << 24 | @core.memory.u8[pc+13] << 16 | @core.memory.u8[pc+14] << 8 | @core.memory.u8[pc+15]) << 8 >> 24
  @core.memory.u8[pc+13] << 24 >> 24

C1964jsVideoHLE::getVertexNormalZ = (pc) ->
  #(@core.memory.u8[pc+12] << 24 | @core.memory.u8[pc+13] << 16 | @core.memory.u8[pc+14] << 8 | @core.memory.u8[pc+15]) << 16 >> 24
  @core.memory.u8[pc+14] << 24 >> 24

C1964jsVideoHLE::getVertexNormalA = (pc) ->
  (@core.memory.u8[pc+12] << 24 | @core.memory.u8[pc+13] << 16 | @core.memory.u8[pc+14] << 8 | @core.memory.u8[pc+15]) << 24 >> 24


C1964jsVideoHLE::getVertexLightX = (pc) ->
  @core.memory.u8[pc+8] << 24>> 24

C1964jsVideoHLE::getVertexLightY = (pc) ->
  @core.memory.u8[pc+9] << 24>> 24

C1964jsVideoHLE::getVertexLightZ = (pc) ->
  @core.memory.u8[pc+10] << 24>> 24



C1964jsVideoHLE::toSByte = (ub) ->
  if ub > 127 then return ub - 256 else return ub

#Texture Struct
C1964jsVideoHLE::getTextureLevel = (pc) ->
  (@core.memory.u8[pc] << 24 | @core.memory.u8[pc+1] << 16 | @core.memory.u8[pc+2] << 8 | @core.memory.u8[pc+3]) >> 11 & 7

C1964jsVideoHLE::getTextureTile = (pc) ->
  #(@core.memory.u8[pc] << 24 | @core.memory.u8[pc+1] << 16 | @core.memory.u8[pc+2] << 8 | @core.memory.u8[pc+3]) >> 8 & 7
  @core.memory.u8[pc+2] & 7

C1964jsVideoHLE::getTextureOn = (pc) ->
  #(@core.memory.u8[pc] << 24 | @core.memory.u8[pc+1] << 16 | @core.memory.u8[pc+2] << 8 | @core.memory.u8[pc+3]) & 15
  @core.memory.u8[pc+3] & 15

C1964jsVideoHLE::getTextureScaleS = (pc) ->
  #(@core.memory.u8[pc+4] << 24 | @core.memory.u8[pc+5] << 16 | @core.memory.u8[pc+6] << 8 | @core.memory.u8[pc+7]) >> 16 & 0xFFFF
  @core.memory.u8[pc+4] << 8 | @core.memory.u8[pc+5]

C1964jsVideoHLE::getTextureScaleT = (pc) ->
  #(@core.memory.u8[pc+4] << 24 | @core.memory.u8[pc+5] << 16 | @core.memory.u8[pc+6] << 8 | @core.memory.u8[pc+7]) & 0xFFFF
  @core.memory.u8[pc+6] << 8 | @core.memory.u8[pc+7]

#Combine Struct

C1964jsVideoHLE::getCombineLo = (pc) ->
  @core.memory.u8[pc] << 24 | @core.memory.u8[pc+1] << 16 | @core.memory.u8[pc+2] << 8 | @core.memory.u8[pc+3]

C1964jsVideoHLE::getCombineHi = (pc) ->
  @core.memory.u8[pc+4] << 24 | @core.memory.u8[pc+5] << 16 | @core.memory.u8[pc+6] << 8 | @core.memory.u8[pc+7]

C1964jsVideoHLE::getCombineA0 = (pc) ->
  ((@core.memory.u8[pc] << 24 | @core.memory.u8[pc+1] << 16 | @core.memory.u8[pc+2] << 8 | @core.memory.u8[pc+3]) >> 20) & 15

C1964jsVideoHLE::getCombineB0 = (pc) ->
  ((@core.memory.u8[pc+4] << 24 | @core.memory.u8[pc+5] << 16 | @core.memory.u8[pc+6] << 8 | @core.memory.u8[pc+7]) >> 28) & 15

C1964jsVideoHLE::getCombineC0 = (pc) ->
  (@core.memory.u8[pc] << 24 | @core.memory.u8[pc+1] << 16 | @core.memory.u8[pc+2] << 8 | @core.memory.u8[pc+3]) >> 15 & 31

C1964jsVideoHLE::getCombineD0 = (pc) ->
  ((@core.memory.u8[pc+4] << 24 | @core.memory.u8[pc+5] << 16 | @core.memory.u8[pc+6] << 8 | @core.memory.u8[pc+7]) >> 15) & 7

C1964jsVideoHLE::getCombineA0a = (pc) ->
  ((@core.memory.u8[pc] << 24 | @core.memory.u8[pc+1] << 16 | @core.memory.u8[pc+2] << 8 | @core.memory.u8[pc+3]) >> 12) & 7

C1964jsVideoHLE::getCombineB0a = (pc) ->
  ((@core.memory.u8[pc+4] << 24 | @core.memory.u8[pc+5] << 16 | @core.memory.u8[pc+6] << 8 | @core.memory.u8[pc+7]) >> 12) & 7

C1964jsVideoHLE::getCombineC0a = (pc) ->
  ((@core.memory.u8[pc] << 24 | @core.memory.u8[pc+1] << 16 | @core.memory.u8[pc+2] << 8 | @core.memory.u8[pc+3]) >> 9) & 7

C1964jsVideoHLE::getCombineD0a = (pc) ->
  ((@core.memory.u8[pc+4] << 24 | @core.memory.u8[pc+5] << 16 | @core.memory.u8[pc+6] << 8 | @core.memory.u8[pc+7]) >> 9) & 7

C1964jsVideoHLE::getCombineA1 = (pc) ->
  ((@core.memory.u8[pc] << 24 | @core.memory.u8[pc+1] << 16 | @core.memory.u8[pc+2] << 8 | @core.memory.u8[pc+3]) >> 5) & 15

C1964jsVideoHLE::getCombineB1 = (pc) ->
  ((@core.memory.u8[pc+4] << 24 | @core.memory.u8[pc+5] << 16 | @core.memory.u8[pc+6] << 8 | @core.memory.u8[pc+7]) >> 24) & 15

C1964jsVideoHLE::getCombineC1 = (pc) ->
  (@core.memory.u8[pc] << 24 | @core.memory.u8[pc+1] << 16 | @core.memory.u8[pc+2] << 8 | @core.memory.u8[pc+3]) & 31

C1964jsVideoHLE::getCombineD1 = (pc) ->
  ((@core.memory.u8[pc+4] << 24 | @core.memory.u8[pc+5] << 16 | @core.memory.u8[pc+6] << 8 | @core.memory.u8[pc+7]) >> 6) & 7

C1964jsVideoHLE::getCombineA1a = (pc) ->
  ((@core.memory.u8[pc+4] << 24 | @core.memory.u8[pc+5] << 16 | @core.memory.u8[pc+6] << 8 | @core.memory.u8[pc+7]) >> 21) & 7

C1964jsVideoHLE::getCombineB1a = (pc) ->
  ((@core.memory.u8[pc+4] << 24 | @core.memory.u8[pc+5] << 16 | @core.memory.u8[pc+6] << 8 | @core.memory.u8[pc+7]) >> 3) & 7

C1964jsVideoHLE::getCombineC1a = (pc) ->
  ((@core.memory.u8[pc+4] << 24 | @core.memory.u8[pc+5] << 16 | @core.memory.u8[pc+6] << 8 | @core.memory.u8[pc+7]) >> 18) & 7

C1964jsVideoHLE::getCombineD1a = (pc) ->
  (@core.memory.u8[pc+4] << 24 | @core.memory.u8[pc+5] << 16 | @core.memory.u8[pc+6] << 8 | @core.memory.u8[pc+7]) & 7

#GBI0 matrix struct
C1964jsVideoHLE::gbi0isProjectionMatrix = (pc) ->
  (if ((@core.memory.u8[pc + 1] & 1) isnt 0) then true else false)

C1964jsVideoHLE::gbi0LoadMatrix = (pc) ->
  (if ((@core.memory.u8[pc + 1] & 2) isnt 0) then true else false)

C1964jsVideoHLE::gbi0PushMatrix = (pc) ->
  (if ((@core.memory.u8[pc + 1] & 4) isnt 0) then true else false)

C1964jsVideoHLE::gbi0PopMtxIsProjection = (pc) ->
  (if ((@core.memory.u8[pc + 7] & 1) isnt 0) then true else false)

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
  (@core.memory.u8[pc] << 24 | @core.memory.u8[pc + 1] << 16 | @core.memory.u8[pc + 2] << 8 | @core.memory.u8[pc + 3]) >>> 12 & 0xFFF

#Y coordinate of lower right
C1964jsVideoHLE::getTexRectYh = (pc) ->
  #(@core.memory.u8[pc] << 24 | @core.memory.u8[pc + 1] << 16 | @core.memory.u8[pc + 2] << 8 | @core.memory.u8[pc + 3]) & 0xFFF
  (@core.memory.u8[pc + 2] << 8 | @core.memory.u8[pc + 3]) & 0xFFF

C1964jsVideoHLE::getTexRectTileNo = (pc) ->
  #(@core.memory.u8[pc+4] << 24 | @core.memory.u8[pc+5] << 16 | @core.memory.u8[pc+6] << 8 | @core.memory.u8[pc+7]) >>> 24 & 7
  @core.memory.u8[pc+4] & 7

#X coordinate of upper left
C1964jsVideoHLE::getTexRectXl = (pc) ->
  (@core.memory.u8[pc+4] << 24 | @core.memory.u8[pc+5] << 16 | @core.memory.u8[pc+6] << 8 | @core.memory.u8[pc+7]) >>> 12 & 0xFFF

#Y coordinate of upper left
C1964jsVideoHLE::getTexRectYl = (pc) ->
  #(@core.memory.u8[pc+4] << 24 | @core.memory.u8[pc+5] << 16 | @core.memory.u8[pc+6] << 8 | @core.memory.u8[pc+7]) & 0xFFF
  (@core.memory.u8[pc+6] << 8 | @core.memory.u8[pc+7]) & 0xFFF

C1964jsVideoHLE::getTexRectS = (pc) ->
  #(@core.memory.u8[pc+12] << 24 | @core.memory.u8[pc+13] << 16 | @core.memory.u8[pc+14] << 8 | @core.memory.u8[pc+15]) >>> 16 & 0xFFFF
  @core.memory.u8[pc+12] << 8 | @core.memory.u8[pc+13]

C1964jsVideoHLE::getTexRectT = (pc) ->
  #(@core.memory.u8[pc+12] << 24 | @core.memory.u8[pc+13] << 16 | @core.memory.u8[pc+14] << 8 | @core.memory.u8[pc+15]) & 0xFFFF
  @core.memory.u8[pc+14] << 8 | @core.memory.u8[pc+15]

C1964jsVideoHLE::getTexRectDsDx = (pc) ->
  @core.memory.getInt32(@core.memory.u8, pc + 20) >>> 16 & 0xFFFF

C1964jsVideoHLE::getTexRectDtDy = (pc) ->
  @core.memory.getInt32(@core.memory.u8, pc + 20) & 0xFFFF

#is this right?
C1964jsVideoHLE::getGbi1Type = (pc) ->
  (@core.memory.u8[pc] << 24 | @core.memory.u8[pc+1] << 16 | @core.memory.u8[pc+2] << 8 | @core.memory.u8[pc+3]) >>> 16 & 0xFF

C1964jsVideoHLE::getRspSegmentAddr = (seg) ->
  #TODO: May need to mask with rdram size - 1
  (@segments[(seg >> 24) & 0x0F]&0xffffff) + (seg & 0xFFFFFF)


C1964jsVideoHLE::getOtherModeL = (pc) ->
  (@core.memory.u8[pc] << 24 | @core.memory.u8[pc + 1] << 16 | @core.memory.u8[pc + 2] << 8 | @core.memory.u8[pc + 3])

C1964jsVideoHLE::getOtherModeH = (pc) ->
  (@core.memory.u8[pc] << 24 | @core.memory.u8[pc + 1] << 16 | @core.memory.u8[pc + 2] << 8 | @core.memory.u8[pc + 3])


C1964jsVideoHLE::getWord0 = (pc) ->
  (@core.memory.u8[pc] << 24 | @core.memory.u8[pc + 1] << 16 | @core.memory.u8[pc + 2] << 8 | @core.memory.u8[pc + 3])

C1964jsVideoHLE::getWord1 = (pc) ->
  (@core.memory.u8[pc + 4] << 24 | @core.memory.u8[pc + 5] << 16 | @core.memory.u8[pc + 6] << 8 | @core.memory.u8[pc + 7])

C1964jsVideoHLE::getShort = (pc) ->
  (@core.memory.u8[pc] << 24 | @core.memory.u8[pc + 1] << 16) >> 16


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
  (@core.memory.u8[pc] << 24 | @core.memory.u8[pc + 1] << 16 | @core.memory.u8[pc + 2] << 8 | @core.memory.u8[pc + 3]) & 0xFFF

C1964jsVideoHLE::getTImgSize = (pc) ->
  (@core.memory.u8[pc] << 24 | @core.memory.u8[pc + 1] << 16 | @core.memory.u8[pc + 2] << 8 | @core.memory.u8[pc + 3]) >>> 19 & 3

C1964jsVideoHLE::getTImgFormat = (pc) ->
  (@core.memory.u8[pc] << 24 | @core.memory.u8[pc + 1] << 16 | @core.memory.u8[pc + 2] << 8 | @core.memory.u8[pc + 3]) >>> 21 & 7

C1964jsVideoHLE::getTImgAddr = (pc) ->
  tImgAddr = (@core.memory.u8[pc+4] << 24 | @core.memory.u8[pc+5] << 16 | @core.memory.u8[pc+6] << 8 | @core.memory.u8[pc+7])
  @getRspSegmentAddr tImgAddr

#SetTile

C1964jsVideoHLE::getSetTileFmt = (pc) ->
  (@core.memory.u8[pc] << 24 | @core.memory.u8[pc + 1] << 16 | @core.memory.u8[pc + 2] << 8 | @core.memory.u8[pc + 3]) >> 21 & 7

C1964jsVideoHLE::getSetTileSiz = (pc) ->
  (@core.memory.u8[pc] << 24 | @core.memory.u8[pc + 1] << 16 | @core.memory.u8[pc + 2] << 8 | @core.memory.u8[pc + 3]) >> 19 & 3

C1964jsVideoHLE::getSetTileLine = (pc) ->
  (@core.memory.u8[pc] << 24 | @core.memory.u8[pc + 1] << 16 | @core.memory.u8[pc + 2] << 8 | @core.memory.u8[pc + 3]) >> 9 & 0x1FF

C1964jsVideoHLE::getSetTileTmem = (pc) ->
  (@core.memory.u8[pc] << 24 | @core.memory.u8[pc + 1] << 16 | @core.memory.u8[pc + 2] << 8 | @core.memory.u8[pc + 3]) & 0x1FF

C1964jsVideoHLE::getSetTileTile = (pc) ->
  (@core.memory.u8[pc+4] << 24 | @core.memory.u8[pc+5] << 16 | @core.memory.u8[pc+6] << 8 | @core.memory.u8[pc+7]) >> 24 & 7

C1964jsVideoHLE::getSetTilePal = (pc) ->
  (@core.memory.u8[pc+4] << 24 | @core.memory.u8[pc+5] << 16 | @core.memory.u8[pc+6] << 8 | @core.memory.u8[pc+7]) >> 20 & 15

C1964jsVideoHLE::getSetTileCmt = (pc) ->
  (@core.memory.u8[pc+4] << 24 | @core.memory.u8[pc+5] << 16 | @core.memory.u8[pc+6] << 8 | @core.memory.u8[pc+7]) >> 18 & 3

C1964jsVideoHLE::getSetTileMirrorT = (pc) ->
  (@core.memory.u8[pc+4] << 24 | @core.memory.u8[pc+5] << 16 | @core.memory.u8[pc+6] << 8 | @core.memory.u8[pc+7]) >> 15 & 1

C1964jsVideoHLE::getSetTileMaskt = (pc) ->
  (@core.memory.u8[pc+4] << 24 | @core.memory.u8[pc+5] << 16 | @core.memory.u8[pc+6] << 8 | @core.memory.u8[pc+7]) >> 14 & 15

C1964jsVideoHLE::getSetTileShiftt = (pc) ->
  (@core.memory.u8[pc+4] << 24 | @core.memory.u8[pc+5] << 16 | @core.memory.u8[pc+6] << 8 | @core.memory.u8[pc+7]) >> 10 & 15

C1964jsVideoHLE::getSetTileCms = (pc) ->
  (@core.memory.u8[pc+4] << 24 | @core.memory.u8[pc+5] << 16 | @core.memory.u8[pc+6] << 8 | @core.memory.u8[pc+7]) >> 8 & 3

C1964jsVideoHLE::getSetTileMirrorS = (pc) ->
  (@core.memory.u8[pc+4] << 24 | @core.memory.u8[pc+5] << 16 | @core.memory.u8[pc+6] << 8 | @core.memory.u8[pc+7]) >> 5 & 1

C1964jsVideoHLE::getSetTileMasks = (pc) ->
  (@core.memory.u8[pc+4] << 24 | @core.memory.u8[pc+5] << 16 | @core.memory.u8[pc+6] << 8 | @core.memory.u8[pc+7]) >> 4 & 15

C1964jsVideoHLE::getSetTileShifts = (pc) ->
  (@core.memory.u8[pc+4] << 24 | @core.memory.u8[pc+5] << 16 | @core.memory.u8[pc+6] << 8 | @core.memory.u8[pc+7]) & 15

#LoadBlock

C1964jsVideoHLE::getLoadBlockTile = (pc) ->
  (@core.memory.u8[pc+4] << 24 | @core.memory.u8[pc+5] << 16 | @core.memory.u8[pc+6] << 8 | @core.memory.u8[pc+7]) >> 24 & 7

C1964jsVideoHLE::getLoadBlockUls = (pc) ->
  (@core.memory.u8[pc] << 24 | @core.memory.u8[pc + 1] << 16 | @core.memory.u8[pc + 2] << 8 | @core.memory.u8[pc + 3]) >> 12 & 0xFFF

C1964jsVideoHLE::getLoadBlockUlt = (pc) ->
  (@core.memory.u8[pc] << 24 | @core.memory.u8[pc + 1] << 16 | @core.memory.u8[pc + 2] << 8 | @core.memory.u8[pc + 3]) & 0xFFF

C1964jsVideoHLE::getLoadBlockLrs = (pc) ->
  (@core.memory.u8[pc+4] << 24 | @core.memory.u8[pc+5] << 16 | @core.memory.u8[pc+6] << 8 | @core.memory.u8[pc+7]) >> 12 & 0xFFF

C1964jsVideoHLE::getLoadBlockDxt = (pc) ->
  (@core.memory.u8[pc+4] << 24 | @core.memory.u8[pc+5] << 16 | @core.memory.u8[pc+6] << 8 | @core.memory.u8[pc+7]) & 0xFFF

#SetTileSize

C1964jsVideoHLE::getSetTileSizeTile = (pc) ->
  (@core.memory.u8[pc+4] << 24 | @core.memory.u8[pc+5] << 16 | @core.memory.u8[pc+6] << 8 | @core.memory.u8[pc+7]) >> 24 & 7

C1964jsVideoHLE::getSetTileSizeUls = (pc) ->
  (@core.memory.u8[pc] << 24 | @core.memory.u8[pc + 1] << 16 | @core.memory.u8[pc + 2] << 8 | @core.memory.u8[pc + 3]) >> 12 & 0xFFF

C1964jsVideoHLE::getSetTileSizeUlt = (pc) ->
  (@core.memory.u8[pc] << 24 | @core.memory.u8[pc + 1] << 16 | @core.memory.u8[pc + 2] << 8 | @core.memory.u8[pc + 3]) & 0xFFF

C1964jsVideoHLE::getSetTileSizeLrs = (pc) ->
  (@core.memory.u8[pc+4] << 24 | @core.memory.u8[pc+5] << 16 | @core.memory.u8[pc+6] << 8 | @core.memory.u8[pc+7]) >> 12 & 0xFFF

C1964jsVideoHLE::getSetTileSizeLrt = (pc) ->
  (@core.memory.u8[pc+4] << 24 | @core.memory.u8[pc+5] << 16 | @core.memory.u8[pc+6] << 8 | @core.memory.u8[pc+7]) & 0xFFF

#SetPrimColor

C1964jsVideoHLE::getSetPrimColorM = (pc) ->
  (@core.memory.u8[pc] << 24 | @core.memory.u8[pc + 1] << 16 | @core.memory.u8[pc + 2] << 8 | @core.memory.u8[pc + 3]) >>> 8 & 0xFF

C1964jsVideoHLE::getSetPrimColorL = (pc) ->
  (@core.memory.u8[pc] << 24 | @core.memory.u8[pc + 1] << 16 | @core.memory.u8[pc + 2] << 8 | @core.memory.u8[pc + 3]) & 0xFF

C1964jsVideoHLE::getSetPrimColorR = (pc) ->
  (@core.memory.u8[pc+4] << 24 | @core.memory.u8[pc+5] << 16 | @core.memory.u8[pc+6] << 8 | @core.memory.u8[pc+7]) >>> 24

C1964jsVideoHLE::getSetPrimColorG = (pc) ->
  (@core.memory.u8[pc+4] << 24 | @core.memory.u8[pc+5] << 16 | @core.memory.u8[pc+6] << 8 | @core.memory.u8[pc+7]) << 8 >>> 24

C1964jsVideoHLE::getSetPrimColorB = (pc) ->
  (@core.memory.u8[pc+4] << 24 | @core.memory.u8[pc+5] << 16 | @core.memory.u8[pc+6] << 8 | @core.memory.u8[pc+7]) << 16 >>> 24

C1964jsVideoHLE::getSetPrimColorA = (pc) ->
  (@core.memory.u8[pc+4] << 24 | @core.memory.u8[pc+5] << 16 | @core.memory.u8[pc+6] << 8 | @core.memory.u8[pc+7]) << 24 >>> 24

#SetGeometryMode

C1964jsVideoHLE::getSetGeometryMode = (pc) ->
  (@core.memory.u8[pc+4] << 24 | @core.memory.u8[pc+5] << 16 | @core.memory.u8[pc+6] << 8 | @core.memory.u8[pc+7])

C1964jsVideoHLE::getClearGeometryMode = (pc) ->
  (@core.memory.u8[pc+4] << 24 | @core.memory.u8[pc+5] << 16 | @core.memory.u8[pc+6] << 8 | @core.memory.u8[pc+7])

C1964jsVideoHLE::pow2roundup = (value) ->
  result = 1
  while result < value
    result <<= 1
  return result

#SetFillColor

C1964jsVideoHLE::getSetFillColorR = (pc) ->
  (@core.memory.u8[pc+4] << 24 | @core.memory.u8[pc+5] << 16 | @core.memory.u8[pc+6] << 8 | @core.memory.u8[pc+7]) >>> 24

C1964jsVideoHLE::getSetFillColorG = (pc) ->
  (@core.memory.u8[pc+4] << 24 | @core.memory.u8[pc+5] << 16 | @core.memory.u8[pc+6] << 8 | @core.memory.u8[pc+7]) << 8 >>> 24

C1964jsVideoHLE::getSetFillColorB = (pc) ->
  (@core.memory.u8[pc+4] << 24 | @core.memory.u8[pc+5] << 16 | @core.memory.u8[pc+6] << 8 | @core.memory.u8[pc+7]) << 16 >>> 24

C1964jsVideoHLE::getSetFillColorA = (pc) ->
  (@core.memory.u8[pc+4] << 24 | @core.memory.u8[pc+5] << 16 | @core.memory.u8[pc+6] << 8 | @core.memory.u8[pc+7]) << 24 >>> 24

#setEnvColor

C1964jsVideoHLE::getSetEnvColorR = (pc) ->
  (@core.memory.u8[pc+4] << 24 | @core.memory.u8[pc+5] << 16 | @core.memory.u8[pc+6] << 8 | @core.memory.u8[pc+7]) >>> 24

C1964jsVideoHLE::getSetEnvColorG = (pc) ->
  (@core.memory.u8[pc+4] << 24 | @core.memory.u8[pc+5] << 16 | @core.memory.u8[pc+6] << 8 | @core.memory.u8[pc+7]) << 8 >>> 24

C1964jsVideoHLE::getSetEnvColorB = (pc) ->
  (@core.memory.u8[pc+4] << 24 | @core.memory.u8[pc+5] << 16 | @core.memory.u8[pc+6] << 8 | @core.memory.u8[pc+7]) << 16 >>> 24

C1964jsVideoHLE::getSetEnvColorA = (pc) ->
  (@core.memory.u8[pc+4] << 24 | @core.memory.u8[pc+5] << 16 | @core.memory.u8[pc+6] << 8 | @core.memory.u8[pc+7]) << 24 >>> 24

