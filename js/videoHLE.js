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

function processDisplayList()
{
    log('todo: process display list');
    
    dlParserProcess();
    drawScene();

   // triggerDPInterrupt(0, false);
    triggerSPInterrupt(0, false);
}

var dlistStackPointer = 0;
var dlistStack = new Array(MAX_DL_STACK_SIZE);
for (var i=0; i<MAX_DL_STACK_SIZE; i++)
    dlistStack[i] = new Object();
var texImg = new Object();
var segments = new Array(16);
for (var i=0; i<segments.length; i++)
    segments[i] = 0;

//todo: different microcodes support
var currentMicrocodeMap = microcodeMap0;

function dlParserProcess()
{
    dlistStackPointer = 0;
    dlistStack[dlistStackPointer].pc = getInt32(spMemUint8Array, spMemUint8Array, TASK_DATA_PTR);
    dlistStack[dlistStackPointer].countdown = MAX_DL_COUNT;

    //see RSP_Parser.cpp
    //TODO: purge old textures
    //TODO: stats
    //TODO: force screen clear
    //TODO: set vi scales
    //TODO: render reset
    //TODO: begin rendering
    //TODO: set viewport
    //TODO: set fill mode

    while (dlistStackPointer >= 0)
    {
        var pc = dlistStack[dlistStackPointer].pc;
        var cmd = getCommand(pc);
        
        log('cmd = ' + dec2hex(cmd));

        dlistStack[dlistStackPointer].pc += 8;

        var func = currentMicrocodeMap[cmd];
        
        window[func](pc);

        if (dlistStackPointer >= 0 && --dlistStack[dlistStackPointer].countdown < 0 )
            dlistStackPointer--;
    }
    
    log('finished dlist');
    
    triggerSPInterrupt(0, false);
    
    //TODO: end rendering
}

function RSP_RDP_Nothing(pc)
{
    log('RSP RDP NOTHING');
    dlistStackPointer--;
}

function RSP_GBI1_MoveMem(pc)
{
    var type = getGbi1Type(pc);
    var length = getGbi1Length(pc);
    var addr = getGbi1RspSegmentAddr(pc);
    
    log('movemem type=' + type + ', length=' + length + ' addr=' + addr);
}

function RSP_GBI1_SpNoop(pc)
{
    log('RSP_GBI1_SpNoop');
}

function RSP_GBI1_Reserved(pc)
{
    log('RSP_GBI1_Reserved');
}

function RSP_GBI0_Mtx(pc)
{
    var addr = getRspSegmentAddr(pc);
    log('RSP_GBI0_Mtx addr: ' + dec2hex(addr));
    loadMatrix(addr);
}

function loadMatrix(addr)
{
	var i, j;

	for (i=0; i<4; i++) {
		for (j=0; j<4; j++) {
            var addr = addr+(i<<3)+(j<<1);
            var hi = rdramUint8Array[addr]<<8 | rdramUint8Array[addr+1]; 
            var lo = rdramUint8Array[addr+32]<<8 | rdramUint8Array[addr+32+1]; 
		//	matToLoad.m[i][j] = (float)((hi<<16) | (lo))/ 65536.0f;
		}
	}
}

function DLParser_SetTImg(pc)
{
    texImg.format = getTexImgFormat(pc);
    texImg.size = getTexImgSize(pc);
    texImg.width = getTexImgWidth(pc);
    texImg.addr = getRspSegmentAddr(pc);
    texImg.bpl = texImg.width << texImg.size >> 1;

    log('Texture: format=' + texImg.format + ' size=' + texImg.size + ' ' + 'width=' + texImg.width + ' addr=' + texImg.addr + ' bpl=' + texImg.bpl);
}

function RSP_GBI0_Vtx(pc)
{
    var num = getGbi0NumVertices(pc);
    var v0 = getGbi0Vertex0(pc);
    var addr = getRspSegmentAddr(pc);

    if ((v0 + num) > 80)
        num = 32 - v0;

    //TODO: check that address is valid

    processVertexData(addr, v0, num);
}

function processVertexData(addr, v0, num)
{
    log('processVertexData: addr=' + addr + ' v0=' + v0 + ' num=' + num); 
    
    for (var i=v0; i<v0+num; i++)
    {
        //var x = rdramView.getInt16(i-v0, false);
        //var y = rdramView.getInt16(i-v0+2, false);
        //var z = rdramView.getInt16(i-v0+4, false);
        
        log('vertex: x=' + x + ' y=' + y + 'z=' + z);
    }
}

function DLParser_SetCImg(pc)
{
    log('TODO: DLParser_SetCImg');
}

//Gets new display list address
function RSP_GBI0_DL(pc)
{
    var addr = getRspSegmentAddr(pc);
    log('dlist address = ' + dec2hex(addr));
    
    //TODO: address adjust
    
    var param = getGbi0DlistParam(pc);
    
    if (param === RSP_DLIST_PUSH)
        dlistStackPointer++;
        
    dlistStack[dlistStackPointer].pc = addr;
    dlistStack[dlistStackPointer].countdown = MAX_DL_COUNT;
}

function DLParser_SetCombine(pc)
{
    log('TODO: DLParser_SetCombine');
}











































    var triangleVertexPositionBuffer;
    var squareVertexPositionBuffer;

    function initBuffers() {
    
        triangleVertexPositionBuffer = gl.createBuffer();
        gl.bindBuffer(gl.ARRAY_BUFFER, triangleVertexPositionBuffer);
        var vertices = [
             0.0,  1.0,  0.0,
            -1.0, -1.0,  0.0,
             1.0, -1.0,  0.0
        ];
        gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(vertices), gl.STATIC_DRAW);
        triangleVertexPositionBuffer.itemSize = 3;
        triangleVertexPositionBuffer.numItems = 3;

        squareVertexPositionBuffer = gl.createBuffer();
        gl.bindBuffer(gl.ARRAY_BUFFER, squareVertexPositionBuffer);
        vertices = [
             1.0,  1.0,  0.0,
            -1.0,  1.0,  0.0,
             1.0, -1.0,  0.0,
            -1.0, -1.0,  0.0
        ];
        gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(vertices), gl.STATIC_DRAW);
        squareVertexPositionBuffer.itemSize = 3;
        squareVertexPositionBuffer.numItems = 4;
    }

var deg = 0;
function drawScene() {
        gl.viewport(0, 0, gl.viewportWidth, gl.viewportHeight);
        gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);

        mat4.perspective(45, gl.viewportWidth / gl.viewportHeight, 0.1, 100.0, pMatrix);

        mat4.identity(mvMatrix);

        mat4.translate(mvMatrix, [-1.5, 0.0, -7.0]);
        
        mvPushMatrix();
        mat4.rotate(mvMatrix, deg++*Math.PI/180, [1, 0, 0]);
        
        if (deg == 360)
            deg = 0;
        
        gl.bindBuffer(gl.ARRAY_BUFFER, triangleVertexPositionBuffer);
        gl.vertexAttribPointer(shaderProgram.vertexPositionAttribute, triangleVertexPositionBuffer.itemSize, gl.FLOAT, false, 0, 0);
        setMatrixUniforms();
        gl.drawArrays(gl.TRIANGLES, 0, triangleVertexPositionBuffer.numItems);

        mvPopMatrix();

        mat4.translate(mvMatrix, [3.0, 0.0, 0.0]);
        gl.bindBuffer(gl.ARRAY_BUFFER, squareVertexPositionBuffer);
        gl.vertexAttribPointer(shaderProgram.vertexPositionAttribute, squareVertexPositionBuffer.itemSize, gl.FLOAT, false, 0, 0);
        setMatrixUniforms();
        gl.drawArrays(gl.TRIANGLE_STRIP, 0, squareVertexPositionBuffer.numItems);
    }