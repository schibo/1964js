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
var neheTexture;

var C1964jsRenderer = function(settings, glx, webGL) {

    var gl = glx;
    var squareVertexPositionBuffer;
    var tilesInitialized = true;

    this.texRect = function(xl, yl, xh, yh, s, t, dsdx, dtdy, tileno, ram, texImg) { 
        //hack: getting width and height of texture by vertices
        var w=xh-xl; w/=4;
        var h=yh-yl; h/=4;
        if (texImg.changed == true) {                
            blitTexture(ram, texImg.addr, tileno, w, h);
        }

        var textureName = "pow2Texture"+tileno;

        //temp: ortho to [-1, 1]. assuming 320x240. todo: ortho projection based on screen res
        xh -= 160*4; xh /= (160*4);
        xl -= 160*4; xl /= (160*4);
        yl -= 120*4; yl /= (-120*4);
        yh -= 120*4; yh /= (-120*4);

        var textureWidth = document.getElementById(textureName).width;
        var textureHeight = document.getElementById(textureName).height;
        var scalex = (xh-xl)*((textureWidth/w)-1);
        var scaley = (yh-yl)*((textureHeight/h)-1);
        initQuad(xl, yl, xh+scalex, yh+scaley ); //inits a quad. good for tiles
        //initQuad(xl, yl, xh, yh ); //inits a quad. good for tiles
        this.draw(tileno, texImg.changed);
        texImg.changed = false;
    }

    this.texTri = function(xl, yl, xh, yh, s, t, dsdx, dtdy, tileno, ram, texImg) { 
        //hack: getting width and height of texture by vertices
        var w=xh-xl;
        var h=yh-yl;
      //  if (texImg.changed == true) {                
            blitTexture(ram, texImg.addr, tileno, w, h);
       // }

        var textureName = "pow2Texture"+tileno;

        var error = initTexture(tileno, true);



        //var textureWidth = document.getElementById(textureName).width;
        //var textureHeight = document.getElementById(textureName).height;
        //var scalex = (xh-xl)*((textureWidth/w)-1);
        //var scaley = (yh-yl)*((textureHeight/h)-1);
        //initQuad(xl, yl, xh+scalex, yh+scaley ); //inits a quad. good for tiles
        //initQuad(xl, yl, xh, yh ); //inits a quad. good for tiles
     //   this.draw(tileno, texImg.changed);
       // texImg.changed = false;
    }

    this.draw = function(tileno, changed) {

        webGL.switchShader(webGL.tileShaderProgram);

        var error = initTexture(tileno, changed);

        gl.disable(gl.DEPTH_TEST);
        gl.enable(gl.BLEND);
        gl.blendFunc(gl.SRC_ALPHA, gl.ONE);

        gl.bindBuffer(gl.ARRAY_BUFFER, cubeVertexPositionBuffer);
        gl.vertexAttribPointer(webGL.tileShaderProgram.vertexPositionAttribute, cubeVertexPositionBuffer.itemSize, gl.FLOAT, false, 0, 0);

        gl.bindBuffer(gl.ARRAY_BUFFER, cubeVertexTextureCoordBuffer);
        gl.vertexAttribPointer(webGL.tileShaderProgram.textureCoordAttribute, cubeVertexTextureCoordBuffer.itemSize, gl.FLOAT, false, 0, 0);

        gl.activeTexture(gl.TEXTURE0);
        gl.bindTexture(gl.TEXTURE_2D, window['neheTexture'+tileno]);
        gl.uniform1i(webGL.tileShaderProgram.samplerUniform, 0);

        gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, cubeVertexIndexBuffer);
        webGL.setMatrixUniforms(webGL.tileShaderProgram);
        
        if (settings.wireframe === false)
            gl.drawElements(gl.TRIANGLES, cubeVertexIndexBuffer.numItems, gl.UNSIGNED_SHORT, 0);
        else
            gl.drawElements(gl.LINE_STRIP, cubeVertexIndexBuffer.numItems, gl.UNSIGNED_SHORT, 0);
    }

    function blitTexture(ram, offset, idx, width, height) {
        //test dummy textures
        var textureName = "pow2Texture"+idx.toString();

        var cc = document.getElementById(textureName);
        var cctx = cc.getContext("2d");


        var ImDat=cctx.createImageData(cc.width,cc.height);
        var out = ImDat.data;

        var stride = (cc.width-width) * 4; //Bytes per pixel = 4;
        var iii=0;
        var k=offset;
        for (var y = -height; y !== 0; y++) {
            for (var x=0; x < width; x++) {
                var hi = ram[k]; 
                var lo = ram[k+1];
                    out[iii+3] = 255; //alpha
                    out[iii] = (hi & 0xF8);
                    k+=2;
                    out[iii+1] = (((hi<<5) | (lo>>>3)) & 0xF8);
                    out[iii+2] = (lo << 2 & 0xF8);
                    iii+=4;
            }
            iii+=stride;
        }
        cctx.putImageData(ImDat,0,0);
    }

    function handleLoadedTexture(texture, imageSrc) {
        gl.bindTexture(gl.TEXTURE_2D, texture);
        gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, true);
        gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, imageSrc);
        //console.log('getError returns: ' + gl.getError());

        //gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
        //gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_NEAREST);

        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_NEAREST);

        //no wrapping
    //    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
    //    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);

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


     function degToRad(degrees) {
        return degrees * Math.PI / 180;
    }

    var cubeVertexPositionBuffer;
    var cubeVertexTextureCoordBuffer;
    var cubeVertexIndexBuffer;

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
}

