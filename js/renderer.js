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

var useExternalTextures = false; //for loading community texture packs
var wireframe = false; //wireframe mode for debugging
var neheTexture;

var _1964jsRenderer = function() {

    var squareVertexPositionBuffer;
    var tilesInitialized = true;

    this.texRect = function(xl, yl, xh, yh, s, t, dsdx, dtdy, tileno, ram, texImg) {
        if (wireframe == true)
            this.drawWireframeQuad(xl, yl, xh, yh);
        else { 
            if (texImg.changed === true)
                blitTexture(ram, texImg.addr, tileno);

            initQuad(xl, yl, xh, yh); //inits a quad. good for tiles
            draw(tileno, texImg.changed);
            texImg.changed = false;
        }
    }

    this.drawWireframeQuad = function(xl, yl, xh, yh) {
        if (!squareVertexPositionBuffer) {

            squareVertexPositionBuffer = gl.createBuffer()
            gl.bindBuffer(gl.ARRAY_BUFFER, squareVertexPositionBuffer);
        }

        squareVertexPositionBuffer.numItems = 0;

        var offset = 12*(squareVertexPositionBuffer.numItems/4);

        var vertices = [
         xh, yh, 0.0,
         xh, yl, 0.0,
         xl, yl, 0.0,
         xl, yh, 0.0
        ];

        squareVertexPositionBuffer.itemSize = 3;
        squareVertexPositionBuffer.numItems += vertices.length/3;

        gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(vertices), gl.STATIC_DRAW);
        gl.vertexAttribPointer(triangleShaderProgram.vertexPositionAttribute, squareVertexPositionBuffer.itemSize, gl.FLOAT, false, 0, 0);
        gl.drawArrays(gl.LINE_LOOP, 0, squareVertexPositionBuffer.numItems);        
    }
}

function blitTexture(ram, offset, idx) {
    //test dummy textures
    var cc = document.getElementById("pow2Texture"+idx);
    var cctx = cc.getContext("2d");

    var ImDat=cctx.createImageData(32,32);
    var out = ImDat.data;

    var iii=0;
    var k=offset;
    for (var y = -32*32; y !== 0; y++) {
        var hi = ram[k]; 
        var lo = ram[k+1];
            out[iii+3] = 255; //alpha
            out[iii] = (hi & 0xF8);
            k+=2;
            out[iii+1] = (((hi<<5) | (lo>>>3)) & 0xF8);
            out[iii+2] = (lo << 2 & 0xF8);
            iii+=4;
    }
    cctx.putImageData(ImDat,0,0);
}

function handleLoadedTexture(texture, imageSrc) {
    gl.bindTexture(gl.TEXTURE_2D, texture);
    gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, true);
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, imageSrc);
    //console.log('getError returns: ' + gl.getError());
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_NEAREST);

    gl.generateMipmap(gl.TEXTURE_2D);
    gl.bindTexture(gl.TEXTURE_2D, null);

    // console.log('getError returns: ' + gl.getError());
}

function initTexture(tileno, changed) {

    if (changed === false && window['neheTexture'+tileno] !== undefined)
        return 0;

    window['neheTexture'+tileno] = gl.createTexture();

    if (useExternalTextures === true) { //this will be loading community hires texture packs in the future
        neheTexture.image = new Image();
        neheTexture.image.onload = function() {
            handleLoadedTexture(neheTexture, neheTexture.image);
        }
        neheTexture.image.src = "nehe.gif";
    } else {
        //load texture from a canvas
        handleLoadedTexture(window['neheTexture'+tileno], document.getElementById('pow2Texture'+tileno));
    }

    return gl.getError();
}


    var mvMatrix = mat4.create();
    var mvMatrixStack = [];
    var pMatrix = mat4.create();

    function mvPushMatrix() {
        var copy = mat4.create();
        mat4.set(mvMatrix, copy);
        mvMatrixStack.push(copy);
    }

    function mvPopMatrix() {
        if (mvMatrixStack.length == 0) {
            throw "Invalid popMatrix!";
        }
        mvMatrix = mvMatrixStack.pop();
    }


    function setMatrixUniforms(shaderProgram) {
        gl.uniformMatrix4fv(shaderProgram.pMatrixUniform, false, pMatrix);
        gl.uniformMatrix4fv(shaderProgram.mvMatrixUniform, false, mvMatrix);
    }


    function degToRad(degrees) {
        return degrees * Math.PI / 180;
    }

    var cubeVertexPositionBuffer;
    var cubeVertexTextureCoordBuffer;
    var cubeVertexIndexBuffer;

    function initBuffers() {
        if (!cubeVertexPositionBuffer) {
            cubeVertexPositionBuffer = gl.createBuffer();
            gl.bindBuffer(gl.ARRAY_BUFFER, cubeVertexPositionBuffer);
        }

        vertices = [
            // Front face
            -1.0, -1.0,  1.0,
             1.0, -1.0,  1.0,
             1.0,  1.0,  1.0,
            -1.0,  1.0,  1.0,

            // Back face
            -1.0, -1.0, -1.0,
            -1.0,  1.0, -1.0,
             1.0,  1.0, -1.0,
             1.0, -1.0, -1.0,

            // Top face
            -1.0,  1.0, -1.0,
            -1.0,  1.0,  1.0,
             1.0,  1.0,  1.0,
             1.0,  1.0, -1.0,

            // Bottom face
            -1.0, -1.0, -1.0,
             1.0, -1.0, -1.0,
             1.0, -1.0,  1.0,
            -1.0, -1.0,  1.0,

            // Right face
             1.0, -1.0, -1.0,
             1.0,  1.0, -1.0,
             1.0,  1.0,  1.0,
             1.0, -1.0,  1.0,

            // Left face
            -1.0, -1.0, -1.0,
            -1.0, -1.0,  1.0,
            -1.0,  1.0,  1.0,
            -1.0,  1.0, -1.0
        ];

        gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(vertices), gl.STATIC_DRAW);
        cubeVertexPositionBuffer.itemSize = 3;
        cubeVertexPositionBuffer.numItems = 24;

        if (!cubeVertexTextureCoordBuffer) {
            cubeVertexTextureCoordBuffer = gl.createBuffer();
            gl.bindBuffer(gl.ARRAY_BUFFER, cubeVertexTextureCoordBuffer);
        }

        var textureCoords = [
          // Front face
          0.0, 0.0,
          1.0, 0.0,
          1.0, 1.0,
          0.0, 1.0,

          // Back face
          1.0, 0.0,
          1.0, 1.0,
          0.0, 1.0,
          0.0, 0.0,

          // Top face
          0.0, 1.0,
          0.0, 0.0,
          1.0, 0.0,
          1.0, 1.0,

          // Bottom face
          1.0, 1.0,
          0.0, 1.0,
          0.0, 0.0,
          1.0, 0.0,

          // Right face
          1.0, 0.0,
          1.0, 1.0,
          0.0, 1.0,
          0.0, 0.0,

          // Left face
          0.0, 0.0,
          1.0, 0.0,
          1.0, 1.0,
          0.0, 1.0
        ];
        gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(textureCoords), gl.STATIC_DRAW);
        cubeVertexTextureCoordBuffer.itemSize = 2;
        cubeVertexTextureCoordBuffer.numItems = 24;

        if (!cubeVertexIndexBuffer) {
            cubeVertexIndexBuffer = gl.createBuffer();
            gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, cubeVertexIndexBuffer);
        }

        var cubeVertexIndices = [
            0, 1, 2,      0, 2, 3,    // Front face
            4, 5, 6,      4, 6, 7,    // Back face
            8, 9, 10,     8, 10, 11,  // Top face
            12, 13, 14,   12, 14, 15, // Bottom face
            16, 17, 18,   16, 18, 19, // Right face
            20, 21, 22,   20, 22, 23  // Left face
        ];
        gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, new Uint16Array(cubeVertexIndices), gl.STATIC_DRAW);
        cubeVertexIndexBuffer.itemSize = 1;
        cubeVertexIndexBuffer.numItems = 36;
    }

    function initQuad(xl, yl, xh, yh) {

        //if (!cubeVertexPositionBuffer) {
            cubeVertexPositionBuffer = gl.createBuffer();
            gl.bindBuffer(gl.ARRAY_BUFFER, cubeVertexPositionBuffer);
        //}

        var vertices = [
         xh, yh, 0.0,
         xh, yl, 0.0,
         xl, yl, 0.0,
         xl, yh, 0.0
        ];

        gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(vertices), gl.DYNAMIC_DRAW);
        cubeVertexPositionBuffer.itemSize = 3;
        cubeVertexPositionBuffer.numItems = 4;

        //if (!cubeVertexTextureCoordBuffer) {
            cubeVertexTextureCoordBuffer = gl.createBuffer();
            gl.bindBuffer(gl.ARRAY_BUFFER, cubeVertexTextureCoordBuffer);
        //}

        var textureCoords = [
          // Front face
          1.0, 0.0,
          1.0, 1.0,
          0.0, 1.0,
          0.0, 0.0
        ];

        gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(textureCoords), gl.STATIC_DRAW);
        cubeVertexTextureCoordBuffer.itemSize = 2;
        cubeVertexTextureCoordBuffer.numItems = 4;

        if (!cubeVertexIndexBuffer) {
            cubeVertexIndexBuffer = gl.createBuffer();
            gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, cubeVertexIndexBuffer);
            var cubeVertexIndices = [
                0, 1, 2,      0, 2, 3];    // Front face

            gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, new Uint16Array(cubeVertexIndices), gl.STATIC_DRAW);
            cubeVertexIndexBuffer.itemSize = 1;
            cubeVertexIndexBuffer.numItems = 6;
        }
    }


   var xRot = 0;
    var yRot = 0;
    var zRot = 0;

    function draw(tileno, changed) {

        if (wireframe === true) {
            gl.useProgram(triangleShaderProgram);
            return;
        }

       gl.useProgram(tileShaderProgram);

        initTexture(tileno, changed);

        gl.disable(gl.DEPTH_TEST);
        gl.enable(gl.BLEND);
        gl.blendFunc(gl.SRC_ALPHA, gl.ONE);

//rotation test
/*
            var elapsed = 0.16;
            xRot += (90 * elapsed) / 1000.0;
            yRot += (90 * elapsed) / 1000.0;
            zRot += (90 * elapsed) / 1000.0;

        mat4.rotate(mvMatrix, degToRad(xRot), [1, 0, 0]);
        mat4.rotate(mvMatrix, degToRad(yRot), [0, 1, 0]);
        mat4.rotate(mvMatrix, degToRad(zRot), [0, 0, 1]);
*/

        gl.bindBuffer(gl.ARRAY_BUFFER, cubeVertexPositionBuffer);
        gl.vertexAttribPointer(tileShaderProgram.vertexPositionAttribute, cubeVertexPositionBuffer.itemSize, gl.FLOAT, false, 0, 0);

        gl.bindBuffer(gl.ARRAY_BUFFER, cubeVertexTextureCoordBuffer);
        gl.vertexAttribPointer(tileShaderProgram.textureCoordAttribute, cubeVertexTextureCoordBuffer.itemSize, gl.FLOAT, false, 0, 0);

        gl.activeTexture(gl.TEXTURE0);
        gl.bindTexture(gl.TEXTURE_2D, window['neheTexture'+tileno]);
        gl.uniform1i(tileShaderProgram.samplerUniform, 0);

        gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, cubeVertexIndexBuffer);
        setMatrixUniforms(tileShaderProgram);
        gl.drawElements(gl.TRIANGLES, cubeVertexIndexBuffer.numItems, gl.UNSIGNED_SHORT, 0);
    }