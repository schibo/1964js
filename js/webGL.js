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

/*globals log, document, alert, mat4*/
/*jslint bitwise: true, todo: true*/

//TODO: parameterize "Canvas3D" so this dom id can be arbitrary.

var C1964jsWebGL = function () {
    "use strict";
    this.gl = undefined;
    this.tileShaderProgram = undefined;
    this.triangleShaderProgram = undefined;
    this.webGLStart();
};

(function () {
    "use strict";

    var nMatrix, pMatrix, mvMatrixStack, mvMatrix = mat4.create();
    mvMatrixStack = [];
    pMatrix = mat4.create();
    nMatrix = mat4.create();

    C1964jsWebGL.prototype.initGL = function (canvas) {
        try {
            log("canvas = " + canvas);
            log("canvas.getContext = " + canvas.getContext);
            this.gl = canvas.getContext("webgl") || canvas.getContext("moz-webgl") || canvas.getContext("webkit-3d") || canvas.getContext("experimental-webgl");
            log("gl = " + this.gl);
            this.gl.viewportWidth = canvas.width;
            log("this.gl.viewportWidth = " + this.gl.viewportWidth);
            this.gl.viewportHeight = canvas.height;
            log("this.gl.viewportHeight = " + this.gl.viewportHeight);
        } catch (e) {
        }
        if (!this.gl) {
            log("Could not initialise WebGL. Your browser may not support it.");
        }
    };

    C1964jsWebGL.prototype.getShader = function (id) {
        var k, shaderScript, shader, str = "";

        shaderScript = document.getElementById(id);
        if (!shaderScript) {
            return null;
        }

        k = shaderScript.firstChild;
        while (k) {
            if (k.nodeType === 3) {
                str += k.textContent;
            }
            k = k.nextSibling;
        }

        if (shaderScript.type === "x-shader/x-fragment") {
            shader = this.gl.createShader(this.gl.FRAGMENT_SHADER);
        } else if (shaderScript.type === "x-shader/x-vertex") {
            shader = this.gl.createShader(this.gl.VERTEX_SHADER);
        } else {
            return null;
        }

        this.gl.shaderSource(shader, str);
        this.gl.compileShader(shader);

        if (!this.gl.getShaderParameter(shader, this.gl.COMPILE_STATUS)) {
            alert(this.gl.getShaderInfoLog(shader));
            return null;
        }

        return shader;
    };

    C1964jsWebGL.prototype.initShaders = function (fs, vs) {
        var shaderProgram, vertexShader, fragmentShader = this.getShader(fs);
        vertexShader = this.getShader(vs);

        shaderProgram = this.gl.createProgram();
        this.gl.attachShader(shaderProgram, vertexShader);
        this.gl.attachShader(shaderProgram, fragmentShader);
        this.gl.linkProgram(shaderProgram);

        if (!this.gl.getProgramParameter(shaderProgram, this.gl.LINK_STATUS)) {
            alert("Could not initialize shaders");
        }

        this.gl.useProgram(shaderProgram);

        shaderProgram.vertexPositionAttribute = this.gl.getAttribLocation(shaderProgram, "aVertexPosition");

        shaderProgram.pMatrixUniform = this.gl.getUniformLocation(shaderProgram, "uPMatrix");
        shaderProgram.mvMatrixUniform = this.gl.getUniformLocation(shaderProgram, "uMVMatrix");
        shaderProgram.nMatrixUniform = this.gl.getUniformLocation(shaderProgram, "uNormalMatrix");
        shaderProgram.textureCoordAttribute = this.gl.getAttribLocation(shaderProgram, "aTextureCoord");
        shaderProgram.samplerUniform = this.gl.getUniformLocation(shaderProgram, "uSampler");

        return shaderProgram;
    };

    C1964jsWebGL.prototype.switchShader = function (shaderProgram) {
        this.gl.useProgram(shaderProgram);

        //if (shaderProgram.vertexPositionAttribute !== -1)
        this.gl.enableVertexAttribArray(shaderProgram.vertexPositionAttribute);

        //if (shaderProgram.textureCoordAttribute !== -1)
        this.gl.enableVertexAttribArray(shaderProgram.textureCoordAttribute);
    };

    C1964jsWebGL.prototype.beginDList = function () {
        this.gl.viewport(0, 0, this.gl.viewportWidth, this.gl.viewportHeight);
        this.gl.clear(this.gl.COLOR_BUFFER_BIT | this.gl.DEPTH_BUFFER_BIT);

        mat4.perspective(45, this.gl.viewportWidth / this.gl.viewportHeight, 0.1, 100.0, pMatrix);
        mat4.identity(mvMatrix);
        mat4.translate(mvMatrix, [0.0, 0.0, -2.4]);
        mat4.set(mvMatrix, nMatrix);
        mat4.inverse(nMatrix, nMatrix);
        mat4.transpose(nMatrix);

       // mvPushMatrix();
        mat4.translate(mvMatrix, [0.0, 0.0, -1.0]);
    };

    C1964jsWebGL.prototype.setMatrixUniforms = function (shaderProgram) {
        this.gl.uniformMatrix4fv(shaderProgram.pMatrixUniform, false, pMatrix);
        this.gl.uniformMatrix4fv(shaderProgram.mvMatrixUniform, false, mvMatrix);
        this.gl.uniformMatrix4fv(shaderProgram.nMatrixUniform, false, nMatrix);
    };

    C1964jsWebGL.prototype.mvPushMatrix = function () {
        var copy = mat4.create();
        mat4.set(mvMatrix, copy);
        mvMatrixStack.push(copy);
    };

    C1964jsWebGL.prototype.mvPopMatrix = function () {
        if (mvMatrixStack.length === 0) {
            throw "Invalid popMatrix!";
        }
        mvMatrix = mvMatrixStack.pop();
    };

    C1964jsWebGL.prototype.webGLStart = function () {
        var canvas = document.getElementById("Canvas3D");

        this.initGL(canvas);
        if (this.gl) {
            this.tileShaderProgram = this.initShaders("tile-fragment-shader", "tile-vertex-shader");
            this.triangleShaderProgram = this.initShaders("triangle-fragment-shader", "triangle-vertex-shader");

            this.gl.clearColor(0.0, 0.0, 0.0, 1.0);
        }

        canvas.style.visibility = "hidden";
    };

    C1964jsWebGL.prototype.show3D = function () {
        var canvas3D = document.getElementById("Canvas3D");

        canvas3D.style.visibility = "visible";
    };

    C1964jsWebGL.prototype.hide3D = function () {
        var canvas3D = document.getElementById("Canvas3D");

        canvas3D.style.visibility = "hidden";
    };
}());