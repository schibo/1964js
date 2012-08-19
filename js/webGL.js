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

//TODO: parameterize "Canvas3D" so this dom id can be arbitrary.

   var gl;
    function initGL(canvas) {
        try {
            log("canvas = " + canvas);
            log("canvas.getContext = " + canvas.getContext);
            gl = canvas.getContext("webgl") || canvas.getContext("moz-webgl") || canvas.getContext("webkit-3d") || canvas.getContext("experimental-webgl");
            log("gl = " + gl);
            gl.viewportWidth = canvas.width;
            log("gl.viewportWidth = " + gl.viewportWidth);
            gl.viewportHeight = canvas.height;
            log("gl.viewportHeight = " + gl.viewportHeight);
            
        } catch (e) {
        }
        if (!gl) {
            log("Could not initialise WebGL. Your browser may not support it.");
        }
    }


    function getShader(gl, id) {

        var shaderScript = document.getElementById(id);
        if (!shaderScript) {
            return null;
        }

        var str = "";
        var k = shaderScript.firstChild;
        while (k) {
            if (k.nodeType == 3) {
                str += k.textContent;
            }
            k = k.nextSibling;
        }

        var shader;
        if (shaderScript.type == "x-shader/x-fragment") {
            shader = gl.createShader(gl.FRAGMENT_SHADER);
        } else if (shaderScript.type == "x-shader/x-vertex") {
            shader = gl.createShader(gl.VERTEX_SHADER);
        } else {
            return null;
        }

        gl.shaderSource(shader, str);
        gl.compileShader(shader);

        if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
            alert(gl.getShaderInfoLog(shader));
            return null;
        }

        return shader;
    }


    var tileShaderProgram;
    var triangleShaderProgram;

    function initShaders(fs, vs) {
        
        var fragmentShader = getShader(gl, fs);
        var vertexShader = getShader(gl, vs);

        shaderProgram = gl.createProgram();
        gl.attachShader(shaderProgram, vertexShader);
        gl.attachShader(shaderProgram, fragmentShader);
        gl.linkProgram(shaderProgram);

        if (!gl.getProgramParameter(shaderProgram, gl.LINK_STATUS)) {
            alert("Could not initialize shaders");
        }

        gl.useProgram(shaderProgram);

        shaderProgram.vertexPositionAttribute = gl.getAttribLocation(shaderProgram, "aVertexPosition");
        
        shaderProgram.pMatrixUniform = gl.getUniformLocation(shaderProgram, "uPMatrix");
        shaderProgram.mvMatrixUniform = gl.getUniformLocation(shaderProgram, "uMVMatrix");
        shaderProgram.nMatrixUniform = gl.getUniformLocation(shaderProgram, "uNormalMatrix");
        shaderProgram.textureCoordAttribute = gl.getAttribLocation(shaderProgram, "aTextureCoord");
        shaderProgram.samplerUniform = gl.getUniformLocation(shaderProgram, "uSampler");

        return shaderProgram;
    }

    function switchShader(shaderProgram) {
        
        gl.useProgram(shaderProgram);

        //if (shaderProgram.vertexPositionAttribute !== -1)
            gl.enableVertexAttribArray(shaderProgram.vertexPositionAttribute);
        
        if (shaderProgram === tileShaderProgram)
        //if (shaderProgram.textureCoordAttribute !== -1)
            gl.enableVertexAttribArray(shaderProgram.textureCoordAttribute);
    }

    function setMatrixUniforms(shaderProgram) {
        gl.uniformMatrix4fv(shaderProgram.pMatrixUniform, false, pMatrix);
        gl.uniformMatrix4fv(shaderProgram.mvMatrixUniform, false, mvMatrix);
        gl.uniformMatrix4fv(shaderProgram.nMatrixUniform, false, nMatrix);
    }

    var mvMatrix = mat4.create();
    var mvMatrixStack = [];
    var pMatrix = mat4.create();
    var nMatrix = mat4.create();

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

    function webGLStart(videoHLE) {

        var canvas = document.getElementById("Canvas3D");

        initGL(canvas);
        if (gl) {
            tileShaderProgram = initShaders("tile-fragment-shader", "tile-vertex-shader");
            initQuad(-1,-1,1,1);
            triangleShaderProgram = initShaders("triangle-fragment-shader", "triangle-vertex-shader");
            videoHLE.initBuffers();

            gl.clearColor(0.0, 0.0, 0.0, 1.0);
        }
        
        canvas.style.visibility = "hidden";
    }

    function show3D() {
        var canvas3D = document.getElementById("Canvas3D");

        canvas3D.style.visibility = "visible";    
    }

    function hide3D() {
        var canvas3D = document.getElementById("Canvas3D");

        canvas3D.style.visibility = "hidden";    
    }