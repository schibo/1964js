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
_1964jsVideoHLE.prototype.getGbi0MoveWordType = function(pc) {
    return this.core.memory.getInt32(this.core.memory.rdramUint8Array, this.core.memory.rdramUint8Array, pc) & 0x00ff;
}

_1964jsVideoHLE.prototype.getGbi0MoveWordOffset = function(pc) {
    return this.core.memory.getInt32(this.core.memory.rdramUint8Array, this.core.memory.rdramUint8Array, pc) >> 8 & 0x00ffff;
}

_1964jsVideoHLE.prototype.getGbi0MoveWordValue = function(pc) {
    return this.core.memory.getInt32(this.core.memory.rdramUint8Array, this.core.memory.rdramUint8Array, pc+4);
}

//GBI0 Dlist struct
_1964jsVideoHLE.prototype.getGbi0DlistParam = function(pc) {
    return this.core.memory.getInt32(this.core.memory.rdramUint8Array, this.core.memory.rdramUint8Array, pc) >>> 16 & 0x00ff;
}
_1964jsVideoHLE.prototype.getGbi0DlistAddr = function(pc) {//this will probably be generic getGbi0Addr 
    return this.core.memory.getInt32(this.core.memory.rdramUint8Array, this.core.memory.rdramUint8Array, pc+4);
}

_1964jsVideoHLE.prototype.getCommand = function(pc) {
    return this.core.memory.getInt32(this.core.memory.rdramUint8Array, this.core.memory.rdramUint8Array, pc) >>> 24 & 0x00ff;
}

//GBI0 Tri1 struct
_1964jsVideoHLE.prototype.getGbi0Tri1V2 = function(pc) {
    return this.core.memory.rdramUint8Array[pc+7];
}
_1964jsVideoHLE.prototype.getGbi0Tri1V1 = function(pc) {
    return this.core.memory.rdramUint8Array[pc+6];
}
_1964jsVideoHLE.prototype.getGbi0Tri1V0 = function(pc) {
    return this.core.memory.rdramUint8Array[pc+5];
}

//GBI0 vertex struct
_1964jsVideoHLE.prototype.getGbi0NumVertices = function(pc) {
    return this.core.memory.getInt32(this.core.memory.rdramUint8Array, this.core.memory.rdramUint8Array, pc) >>> 20 & 0x0F;
}
_1964jsVideoHLE.prototype.getGbi0Vertex0 = function(pc) {
    return this.core.memory.getInt32(this.core.memory.rdramUint8Array, this.core.memory.rdramUint8Array, pc) >>> 16 & 0x0F;
}

//Fiddled vertex struct
_1964jsVideoHLE.prototype.getFiddledVertexX = function(pc) {
    return Number(this.core.memory.getInt32(this.core.memory.rdramUint8Array, this.core.memory.rdramUint8Array, pc) >> 16);    
}
_1964jsVideoHLE.prototype.getFiddledVertexY = function(pc) {
    return Number(this.core.memory.getInt32(this.core.memory.rdramUint8Array, this.core.memory.rdramUint8Array, pc) << 16 >> 16);    
}
_1964jsVideoHLE.prototype.getFiddledVertexZ = function(pc) {
    return Number(this.core.memory.getInt32(this.core.memory.rdramUint8Array, this.core.memory.rdramUint8Array, pc+4) >> 16);    
}

//GBI0 matrix struct
_1964jsVideoHLE.prototype.gbi0isProjectionMatrix = function(pc) {
    return ((this.core.memory.rdramUint8Array[pc+1] & 0x00000001) !== 0) ? true : false;
}
_1964jsVideoHLE.prototype.gbi0LoadMatrix = function(pc) {
    return ((this.core.memory.rdramUint8Array[pc+1] & 0x00000002) !== 0) ? true : false;
}
_1964jsVideoHLE.prototype.gbi0PushMatrix = function(pc) {
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
_1964jsVideoHLE.prototype.getTexRectXh = function(pc) { 
    return (this.core.memory.getInt32(this.core.memory.rdramUint8Array, this.core.memory.rdramUint8Array, pc)>>>12&0x0FFF);
}
//Y coordinate of upper left
_1964jsVideoHLE.prototype.getTexRectYh = function(pc) { 
    return (this.core.memory.getInt32(this.core.memory.rdramUint8Array, this.core.memory.rdramUint8Array, pc)&0x0FFF);
}
_1964jsVideoHLE.prototype.getTexRectTileNo = function(pc) {
    return (this.core.memory.getInt32(this.core.memory.rdramUint8Array, this.core.memory.rdramUint8Array, pc+4)>>>24&0x07);
}
//X coordinate of lower right
_1964jsVideoHLE.prototype.getTexRectXl = function(pc) {
    return (this.core.memory.getInt32(this.core.memory.rdramUint8Array, this.core.memory.rdramUint8Array, pc+4)>>>12&0x0FFF);
}
//Y coordinate of lower right
_1964jsVideoHLE.prototype.getTexRectYl = function(pc) {
    return (this.core.memory.getInt32(this.core.memory.rdramUint8Array, this.core.memory.rdramUint8Array, pc+4)&0x0FFF);
}
_1964jsVideoHLE.prototype.getTexRectS = function(pc) {
    return (this.core.memory.getInt32(this.core.memory.rdramUint8Array, this.core.memory.rdramUint8Array, pc+8)>>>16&0xFFFF);
}
_1964jsVideoHLE.prototype.getTexRectT = function(pc) {
    return (this.core.memory.getInt32(this.core.memory.rdramUint8Array, this.core.memory.rdramUint8Array, pc+8)&0xFFFF);
}
_1964jsVideoHLE.prototype.getTexRectDsDx = function(pc) {
    return (this.core.memory.getInt32(this.core.memory.rdramUint8Array, this.core.memory.rdramUint8Array, pc+12)>>>16&0xFFFF);
}
_1964jsVideoHLE.prototype.getTexRectDtDy = function(pc) {
    return (this.core.memory.getInt32(this.core.memory.rdramUint8Array, this.core.memory.rdramUint8Array, pc+12)&0xFFFF);
}

_1964jsVideoHLE.prototype.getGbi1Type = function(pc) {
//    return this.core.memory.rdramView.getInt32(pc+4, false) >>> 16 & 0x00ff;
}

_1964jsVideoHLE.prototype.getGbi1Length = function(pc) {
//    return this.core.memory.rdramView.getInt32(pc+4, false) & 0xffff;
}

_1964jsVideoHLE.prototype.getGbi1RspSegmentAddr = function(pc) {
//    return this.core.memory.rdramView.getInt32(pc, false);
}

_1964jsVideoHLE.prototype.getRspSegmentAddr = function(seg) {
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
_1964jsVideoHLE.prototype.getTImgWidth = function(pc) {
    return this.core.memory.getInt32(this.core.memory.rdramUint8Array, this.core.memory.rdramUint8Array, pc) & 0x0FFF;
}

_1964jsVideoHLE.prototype.getTImgSize = function(pc) {
    return this.core.memory.getInt32(this.core.memory.rdramUint8Array, this.core.memory.rdramUint8Array, pc) >>> 19 & 3;
}

_1964jsVideoHLE.prototype.getTImgFormat = function(pc) {
    return this.core.memory.getInt32(this.core.memory.rdramUint8Array, this.core.memory.rdramUint8Array, pc) >>> 21 & 0x7;
}

_1964jsVideoHLE.prototype.getTImgAddr = function(pc) {
    var tImgAddr = this.core.memory.getInt32(this.core.memory.rdramUint8Array, this.core.memory.rdramUint8Array, pc+4);
    return this.getRspSegmentAddr(tImgAddr);
}
