/*
1964js - JavaScript/HTML5 port of 1964 - N64 emulator
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
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/

/*
GBI0 MoveWord struct:
typedef struct {
    unsigned int    type:8;
    unsigned int    offset:16;
    unsigned int    cmd:8;
    unsigned int    value;
} GGBI0_MoveWord;
*/
C1964jsVideoHLE.prototype.getGbi0MoveWordType = function(pc) {
    return this.core.memory.getInt32(this.core.memory.rdramUint8Array, this.core.memory.rdramUint8Array, pc) & 0x00ff;
}

C1964jsVideoHLE.prototype.getGbi0MoveWordOffset = function(pc) {
    return this.core.memory.getInt32(this.core.memory.rdramUint8Array, this.core.memory.rdramUint8Array, pc) >> 8 & 0x00ffff;
}

C1964jsVideoHLE.prototype.getGbi0MoveWordValue = function(pc) {
    return this.core.memory.getInt32(this.core.memory.rdramUint8Array, this.core.memory.rdramUint8Array, pc+4);
}

//GBI0 Dlist struct
C1964jsVideoHLE.prototype.getGbi0DlistParam = function(pc) {
    return this.core.memory.getInt32(this.core.memory.rdramUint8Array, this.core.memory.rdramUint8Array, pc) >>> 16 & 0x00ff;
}
C1964jsVideoHLE.prototype.getGbi0DlistAddr = function(pc) {//this will probably be generic getGbi0Addr 
    return this.core.memory.getInt32(this.core.memory.rdramUint8Array, this.core.memory.rdramUint8Array, pc+4);
}

C1964jsVideoHLE.prototype.getCommand = function(pc) {
    return this.core.memory.getInt32(this.core.memory.rdramUint8Array, this.core.memory.rdramUint8Array, pc) >>> 24 & 0x00ff;
}

//GBI0 Tri1 struct
C1964jsVideoHLE.prototype.getGbi0Tri1V2 = function(pc) {
    return this.core.memory.rdramUint8Array[pc+7];
}
C1964jsVideoHLE.prototype.getGbi0Tri1V1 = function(pc) {
    return this.core.memory.rdramUint8Array[pc+6];
}
C1964jsVideoHLE.prototype.getGbi0Tri1V0 = function(pc) {
    return this.core.memory.rdramUint8Array[pc+5];
}

//GBI0 vertex struct
C1964jsVideoHLE.prototype.getGbi0NumVertices = function(pc) {
    return this.core.memory.getInt32(this.core.memory.rdramUint8Array, this.core.memory.rdramUint8Array, pc) >>> 20 & 0x0F;
}
C1964jsVideoHLE.prototype.getGbi0Vertex0 = function(pc) {
    return this.core.memory.getInt32(this.core.memory.rdramUint8Array, this.core.memory.rdramUint8Array, pc) >>> 16 & 0x0F;
}

//Fiddled vertex struct
C1964jsVideoHLE.prototype.getFiddledVertexX = function(pc) {
    return Number(this.core.memory.getInt32(this.core.memory.rdramUint8Array, this.core.memory.rdramUint8Array, pc) >> 16);    
}
C1964jsVideoHLE.prototype.getFiddledVertexY = function(pc) {
    return Number(this.core.memory.getInt32(this.core.memory.rdramUint8Array, this.core.memory.rdramUint8Array, pc) << 16 >> 16);    
}
C1964jsVideoHLE.prototype.getFiddledVertexZ = function(pc) {
    return Number(this.core.memory.getInt32(this.core.memory.rdramUint8Array, this.core.memory.rdramUint8Array, pc+4) >> 16);    
}

//GBI0 matrix struct
C1964jsVideoHLE.prototype.gbi0isProjectionMatrix = function(pc) {
    return ((this.core.memory.rdramUint8Array[pc+1] & 0x00000001) !== 0) ? true : false;
}
C1964jsVideoHLE.prototype.gbi0LoadMatrix = function(pc) {
    return ((this.core.memory.rdramUint8Array[pc+1] & 0x00000002) !== 0) ? true : false;
}
C1964jsVideoHLE.prototype.gbi0PushMatrix = function(pc) {
    return ((this.core.memory.rdramUint8Array[pc+1] & 0x00000004) !== 0) ? true : false;
}

//TexRect struct
//	uint32 dwXH		= (((gfx->words.w0)>>12)&0x0FFF)/4;
//	uint32 dwYH		= (((gfx->words.w0)    )&0x0FFF)/4;
//	uint32 tileno	= ((gfx->words.w1)>>24)&0x07;
//	uint32 dwXL		= (((gfx->words.w1)>>12)&0x0FFF)/4;
//	uint32 dwYL		= (((gfx->words.w1)    )&0x0FFF)/4;
//	uint16 uS		= (uint16)(  dwCmd2>>16)&0xFFFF;
//	uint16 uT		= (uint16)(  dwCmd2    )&0xFFFF;
//	uint16  uDSDX 	= (uint16)((  dwCmd3>>16)&0xFFFF);
//	uint16  uDTDY	    = (uint16)((  dwCmd3    )&0xFFFF);
//X coordinate of upper left
C1964jsVideoHLE.prototype.getTexRectXh = function(pc) { 
    return (this.core.memory.getInt32(this.core.memory.rdramUint8Array, this.core.memory.rdramUint8Array, pc)>>>12&0x0FFF);
}
//Y coordinate of upper left
C1964jsVideoHLE.prototype.getTexRectYh = function(pc) { 
    return (this.core.memory.getInt32(this.core.memory.rdramUint8Array, this.core.memory.rdramUint8Array, pc)&0x0FFF);
}
C1964jsVideoHLE.prototype.getTexRectTileNo = function(pc) {
    return (this.core.memory.getInt32(this.core.memory.rdramUint8Array, this.core.memory.rdramUint8Array, pc+4)>>>24&0x07);
}
//X coordinate of lower right
C1964jsVideoHLE.prototype.getTexRectXl = function(pc) {
    return (this.core.memory.getInt32(this.core.memory.rdramUint8Array, this.core.memory.rdramUint8Array, pc+4)>>>12&0x0FFF);
}
//Y coordinate of lower right
C1964jsVideoHLE.prototype.getTexRectYl = function(pc) {
    return (this.core.memory.getInt32(this.core.memory.rdramUint8Array, this.core.memory.rdramUint8Array, pc+4)&0x0FFF);
}
C1964jsVideoHLE.prototype.getTexRectS = function(pc) {
    return (this.core.memory.getInt32(this.core.memory.rdramUint8Array, this.core.memory.rdramUint8Array, pc+8)>>>16&0xFFFF);
}
C1964jsVideoHLE.prototype.getTexRectT = function(pc) {
    return (this.core.memory.getInt32(this.core.memory.rdramUint8Array, this.core.memory.rdramUint8Array, pc+8)&0xFFFF);
}
C1964jsVideoHLE.prototype.getTexRectDsDx = function(pc) {
    return (this.core.memory.getInt32(this.core.memory.rdramUint8Array, this.core.memory.rdramUint8Array, pc+12)>>>16&0xFFFF);
}
C1964jsVideoHLE.prototype.getTexRectDtDy = function(pc) {
    return (this.core.memory.getInt32(this.core.memory.rdramUint8Array, this.core.memory.rdramUint8Array, pc+12)&0xFFFF);
}

C1964jsVideoHLE.prototype.getGbi1Type = function(pc) {
//    return this.core.memory.rdramView.getInt32(pc+4, false) >>> 16 & 0x00ff;
}

C1964jsVideoHLE.prototype.getGbi1Length = function(pc) {
//    return this.core.memory.rdramView.getInt32(pc+4, false) & 0xffff;
}

C1964jsVideoHLE.prototype.getGbi1RspSegmentAddr = function(pc) {
//    return this.core.memory.rdramView.getInt32(pc, false);
}

C1964jsVideoHLE.prototype.getRspSegmentAddr = function(seg) {
//TODO: May need to mask with rdram size - 1    
    return this.segments[seg>>24&0x0F] + (seg&0x00FFFFFF);
}

/*
typedef struct {
    unsigned int    width:12;
    unsigned int    :7;
    unsigned int    siz:2;
    unsigned int    fmt:3;
    unsigned int    cmd:8;
    unsigned int    addr;
} GSetImg;
*/
C1964jsVideoHLE.prototype.getTImgWidth = function(pc) {
    return this.core.memory.getInt32(this.core.memory.rdramUint8Array, this.core.memory.rdramUint8Array, pc) & 0x0FFF;
}

C1964jsVideoHLE.prototype.getTImgSize = function(pc) {
    return this.core.memory.getInt32(this.core.memory.rdramUint8Array, this.core.memory.rdramUint8Array, pc) >>> 19 & 3;
}

C1964jsVideoHLE.prototype.getTImgFormat = function(pc) {
    return this.core.memory.getInt32(this.core.memory.rdramUint8Array, this.core.memory.rdramUint8Array, pc) >>> 21 & 0x7;
}

C1964jsVideoHLE.prototype.getTImgAddr = function(pc) {
    var tImgAddr = this.core.memory.getInt32(this.core.memory.rdramUint8Array, this.core.memory.rdramUint8Array, pc+4);
    return this.getRspSegmentAddr(tImgAddr);
}

C1964jsVideoHLE.prototype.microcodeMap0 = [
    'RSP_GBI1_SpNoop', 'RSP_GBI0_Mtx', 'RSP_GBI1_Reserved', 'RSP_GBI1_MoveMem',
    'RSP_GBI0_Vtx', 'RSP_GBI1_Reserved', 'RSP_GBI0_DL', 'RSP_GBI1_Reserved',
    'RSP_GBI1_Reserved', 'RSP_GBI0_Sprite2DBase', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
//10
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
//20
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
//30
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
//40
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
//50
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
//60
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
//70
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
//80
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
//90
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
//a0
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
//b0
    'RSP_RDP_Nothing', 'RSP_GBI0_Tri4', 'RSP_GBI1_RDPHalf_Cont', 'RSP_GBI1_RDPHalf_2',
    'RSP_GBI1_RDPHalf_1', 'RSP_GBI1_Line3D', 'RSP_GBI1_ClearGeometryMode', 'RSP_GBI1_SetGeometryMode',
    'RSP_GBI1_EndDL', 'RSP_GBI1_SetOtherModeL', 'RSP_GBI1_SetOtherModeH', 'RSP_GBI1_Texture',
    'RSP_GBI1_MoveWord', 'RSP_GBI1_PopMtx', 'RSP_GBI1_CullDL', 'RSP_GBI1_Tri1',
//c0
    'RSP_GBI1_Noop', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RDP_TriFill', 'RDP_TriFillZ', 'RDP_TriTxtr', 'RDP_TriTxtrZ',
    'RDP_TriShade', 'RDP_TriShadeZ', 'RDP_TriShadeTxtr', 'RDP_TriShadeTxtrZ',
//d0
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
//e0
    'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing', 'RSP_RDP_Nothing',
    'DLParser_TexRect', 'DLParser_TexRectFlip', 'DLParser_RDPLoadSynch', 'DLParser_RDPPipeSynch',
    'DLParser_RDPTileSynch', 'DLParser_RDPFullSynch', 'DLParser_SetKeyGB', 'DLParser_SetKeyR',
    'DLParser_SetConvert', 'DLParser_SetScissor', 'DLParser_SetPrimDepth', 'DLParser_RDPSetOtherMode',
//f0
    'DLParser_LoadTLut', 'RSP_RDP_Nothing', 'DLParser_SetTileSize', 'DLParser_LoadBlock',
    'DLParser_LoadTile', 'DLParser_SetTile', 'DLParser_FillRect', 'DLParser_SetFillColor',
    'DLParser_SetFogColor', 'DLParser_SetBlendColor', 'DLParser_SetPrimColor', 'DLParser_SetEnvColor',
    'DLParser_SetCombine', 'DLParser_SetTImg', 'DLParser_SetZImg', 'DLParser_SetCImg'
];
