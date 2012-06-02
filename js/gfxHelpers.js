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

//GBI0 MoveWord struct
function getGbi0MoveWordType(pc) {
    return getInt32(rdramUint8Array, rdramUint8Array, pc) & 0x00ff;
}
function getGbi0MoveWordOffset(pc) {
    return getInt32(rdramUint8Array, rdramUint8Array, pc) >> 8 & 0x00ffff;
}
function getGbi0MoveWordValue(pc) {
    return getInt32(rdramUint8Array, rdramUint8Array, pc+4);
}

//GBI0 Dlist struct
function getGbi0DlistParam(pc) {
    return getInt32(rdramUint8Array, rdramUint8Array, pc) >>> 16 & 0x00ff;
}
function getGbi0DlistAddr(pc) {//this will probably be generic getGbi0Addr 
    return getInt32(rdramUint8Array, rdramUint8Array, pc+4);
}

function getCommand(pc) {
    return getInt32(rdramUint8Array, rdramUint8Array, pc) >>> 24 & 0x00ff;
}

//GBI0 Tri1 struct
function getGbi0Tri1V2(pc) {
    return rdramUint8Array[pc+7];
}
function getGbi0Tri1V1(pc) {
    return rdramUint8Array[pc+6];
}
function getGbi0Tri1V0(pc) {
    return rdramUint8Array[pc+5];
}

//GBI0 vertex struct
function getGbi0NumVertices(pc) {
    return getInt32(rdramUint8Array, rdramUint8Array, pc) >>> 20 & 0x0F;
}
function getGbi0Vertex0(pc) {
    return getInt32(rdramUint8Array, rdramUint8Array, pc) >>> 16 & 0x0F;
}

//Fiddled vertex struct
function getFiddledVertexX(pc) {
    return Number(getInt32(rdramUint8Array, rdramUint8Array, pc) >> 16);    
}
function getFiddledVertexY(pc) {
    return Number(getInt32(rdramUint8Array, rdramUint8Array, pc) << 16 >> 16);    
}
function getFiddledVertexZ(pc) {
    return Number(getInt32(rdramUint8Array, rdramUint8Array, pc+4) >> 16);    
}

//GBI0 matrix struct
function gbi0isProjectionMatrix(pc) {
    return ((rdramUint8Array[pc+1] & 0x00000001) !== 0) ? true : false;
}
function gbi0LoadMatrix(pc) {
    return ((rdramUint8Array[pc+1] & 0x00000002) !== 0) ? true : false;
}
function gbi0PushMatrix(pc) {
    return ((rdramUint8Array[pc+1] & 0x00000004) !== 0) ? true : false;
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
function getTexRectXh(pc) { 
    return (getInt32(rdramUint8Array, rdramUint8Array, pc)>>>12&0x0FFF)/4;
}
//Y coordinate of upper left
function getTexRectYh(pc) { 
    return (getInt32(rdramUint8Array, rdramUint8Array, pc)&0x0FFF)/4;
}
function getTexRectTileNo(pc) {
    return 0;
}
//X coordinate of lower right
function getTexRectXl(pc) {
    return (getInt32(rdramUint8Array, rdramUint8Array, pc+4)>>>12&0x0FFF)/4;
}
//Y coordinate of lower right
function getTexRectYl(pc) {
    return (getInt32(rdramUint8Array, rdramUint8Array, pc+4)&0x0FFF)/4;
}
function getTexRectS(pc) {
    return 0;
}
function getTexRectT(pc) {
    return 0;
}
function getTexRectDsDx(pc) {
    return 0;
}
function getTexRectDtDy(pc) {
    return 0;
}



function getGbi1Type(pc) {
//    return rdramView.getInt32(pc+4, false) >>> 16 & 0x00ff;
}

function getGbi1Length(pc) {
//    return rdramView.getInt32(pc+4, false) & 0xffff;
}

function getGbi1RspSegmentAddr(pc) {
//    return rdramView.getInt32(pc, false);
}

function getRspSegmentAddr(seg) {
//TODO: May need to mask with rdram size - 1    
    return segments[seg>>24&0x0F] + (seg&0x00FFFFFF);
}

function getTexImgWidth(pc) {
    return getInt32(rdramUint8Array, rdramUint8Array, pc) >>> 20 & 0x0FFF;
}

function getTexImgSize(pc) {
    return getInt32(rdramUint8Array, rdramUint8Array, pc) >>> 11 & 3;
}

function getTexImgFormat(pc) {
    return getInt32(rdramUint8Array, rdramUint8Array, pc) >>> 8 & 0x7;
}