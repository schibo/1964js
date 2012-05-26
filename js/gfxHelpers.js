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

function getGbi0MoveWordType(pc) {
    return getInt32(rdramUint8Array, rdramUint8Array, pc) & 0x00ff;
}
function getGbi0MoveWordOffset(pc) {
    return getInt32(rdramUint8Array, rdramUint8Array, pc) >> 8 & 0x00ffff;
}
function getGbi0MoveWordValue(pc) {
    return getInt32(rdramUint8Array, rdramUint8Array, pc+4);
}
function getGbi0DlistParam(pc) {
    return getInt32(rdramUint8Array, rdramUint8Array, pc) >>> 16 & 0x00ff;
}
function getGbi0DlistAddr(pc) {
    return getInt32(rdramUint8Array, rdramUint8Array, pc+4);
}

function getCommand(pc) {
    return getInt32(rdramUint8Array, rdramUint8Array, pc) >>> 24 & 0x00ff;
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

function getGbi0NumVertices(pc) {
    return getInt32(rdramUint8Array, rdramUint8Array, pc) >>> 8 & 0x0F;
}

function getGbi0Vertex0(pc) {
    return getInt32(rdramUint8Array, rdramUint8Array, pc) >>> 12 & 0x0F;
}
