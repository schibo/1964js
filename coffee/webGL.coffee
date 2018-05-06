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
#globals log, document, alert, mat4
#jslint bitwise: true, todo: true
#TODO: parameterize "Canvas3D" so this dom id can be arbitrary.

C1964jsWebGL = (core, wireframe) ->
  "use strict"
  @gl = `undefined`
  @core = core
  @webGLStart(wireframe)
  return this

(->
  "use strict"
  pMatrix = undefined
  mvMatrixStack = undefined
  mvMatrix = mat4.create()
  mvMatrixStack = []
  pMatrix = mat4.create()
  C1964jsWebGL::initGL = (canvas) ->
    try
      log "canvas = " + canvas
      log "canvas.getContext = " + canvas.getContext
      @gl = canvas.getContext("webgl") or canvas.getContext("moz-webgl") or canvas.getContext("webkit-3d") or canvas.getContext("experimental-webgl")
      log "gl = " + @gl
      @gl.viewportWidth = canvas.width
      log "this.gl.viewportWidth = " + @gl.viewportWidth
      @gl.viewportHeight = canvas.height
      log "this.gl.viewportHeight = " + @gl.viewportHeight
      @gl.clear @gl.COLOR_BUFFER_BIT | @gl.DEPTH_BUFFER_BIT
    log "Could not initialize WebGL. Your browser may not support it."  unless @gl
    return

  C1964jsWebGL::createShader = (type, source) ->
    shader = @gl.createShader type
    @gl.shaderSource shader, source
    @gl.compileShader shader
    success = @gl.getShaderParameter(shader, @gl.COMPILE_STATUS)
    if success
      return shader

    console.log @gl.getShaderInfoLog shader
    @gl.deleteShader shader
    return

  C1964jsWebGL::initShaders = (fs, vs) ->
    shaderProgram = undefined
    vertexShaderSource = document.getElementById("vertex-shader").text
    fragmentShaderSource = document.getElementById("fragment-shader").text
    vertexShader = @createShader(@gl.VERTEX_SHADER, vertexShaderSource)
    fragmentShader = @createShader(@gl.FRAGMENT_SHADER, fragmentShaderSource)

    shaderProgram = @gl.createProgram()
    @gl.attachShader shaderProgram, vertexShader
    @gl.attachShader shaderProgram, fragmentShader
    @gl.linkProgram shaderProgram
    alert "Could not initialize shaders"  unless @gl.getProgramParameter(shaderProgram, @gl.LINK_STATUS)
    @gl.useProgram shaderProgram
    shaderProgram.vertexPositionAttribute = @gl.getAttribLocation(shaderProgram, "aVertexPosition")
    shaderProgram.vertexColorAttribute = @gl.getAttribLocation(shaderProgram, "aVertexColor")
    shaderProgram.pMatrixUniform = @gl.getUniformLocation(shaderProgram, "uPMatrix")
    shaderProgram.mvMatrixUniform = @gl.getUniformLocation(shaderProgram, "uMVMatrix")
    shaderProgram.textureCoordAttribute = @gl.getAttribLocation(shaderProgram, "aTextureCoord")
    shaderProgram.samplerUniform = @gl.getUniformLocation(shaderProgram, "uSampler")
    shaderProgram.wireframeUniform = @gl.getUniformLocation(shaderProgram, "uWireframe")

    shaderProgram.uCombineA0 = @gl.getUniformLocation(shaderProgram, "uCombineA0")
    shaderProgram.uCombineB0 = @gl.getUniformLocation(shaderProgram, "uCombineB0")
    shaderProgram.uCombineC0 = @gl.getUniformLocation(shaderProgram, "uCombineC0")
    shaderProgram.uCombineD0 = @gl.getUniformLocation(shaderProgram, "uCombineD0")
    shaderProgram.uCombineA0a = @gl.getUniformLocation(shaderProgram, "uCombineA0a")
    shaderProgram.uCombineB0a = @gl.getUniformLocation(shaderProgram, "uCombineB0a")
    shaderProgram.uCombineC0a = @gl.getUniformLocation(shaderProgram, "uCombineC0a")
    shaderProgram.uCombineD0a = @gl.getUniformLocation(shaderProgram, "uCombineD0a")
    shaderProgram.uCombineA1 = @gl.getUniformLocation(shaderProgram, "uCombineA1")
    shaderProgram.uCombineB1 = @gl.getUniformLocation(shaderProgram, "uCombineB1")
    shaderProgram.uCombineC1 = @gl.getUniformLocation(shaderProgram, "uCombineC1")
    shaderProgram.uCombineD1 = @gl.getUniformLocation(shaderProgram, "uCombineD1")
    shaderProgram.uCombineA1a = @gl.getUniformLocation(shaderProgram, "uCombineA1a")
    shaderProgram.uCombineB1a = @gl.getUniformLocation(shaderProgram, "uCombineB1a")
    shaderProgram.uCombineC1a = @gl.getUniformLocation(shaderProgram, "uCombineC1a")
    shaderProgram.uCombineD1a = @gl.getUniformLocation(shaderProgram, "uCombineD1a")

    shaderProgram.uPrimColor = @gl.getUniformLocation(shaderProgram, "uPrimColor")
    shaderProgram.uFillColor = @gl.getUniformLocation(shaderProgram, "uFillColor")
    shaderProgram.uEnvColor = @gl.getUniformLocation(shaderProgram, "uEnvColor")
    shaderProgram.uBlendColor = @gl.getUniformLocation(shaderProgram, "uBlendColor")
    #shaderProgram.otherModeL = @gl.getUniformLocation(shaderProgram, "otherModeL")
    #shaderProgram.otherModeH = @gl.getUniformLocation(shaderProgram, "otherModeH")
    shaderProgram.cycleType = @gl.getUniformLocation(shaderProgram, "cycleType")
    shaderProgram.uAlphaTestEnabled = @gl.getUniformLocation(shaderProgram, "uAlphaTestEnabled")
    shaderProgram

  C1964jsWebGL::setCombineUniforms = (vhle, shaderProgram) ->
    @gl.uniform1i shaderProgram.uCombineA0, vhle.combine[0]
    @gl.uniform1i shaderProgram.uCombineB0, vhle.combine[2]
    @gl.uniform1i shaderProgram.uCombineC0, vhle.combine[4]
    @gl.uniform1i shaderProgram.uCombineD0, vhle.combine[6]
    @gl.uniform1i shaderProgram.uCombineA0a, vhle.combine[1]
    @gl.uniform1i shaderProgram.uCombineB0a, vhle.combine[3]
    @gl.uniform1i shaderProgram.uCombineC0a, vhle.combine[5]
    @gl.uniform1i shaderProgram.uCombineD0a, vhle.combine[7]
    @gl.uniform1i shaderProgram.uCombineA1, vhle.combine[8]
    @gl.uniform1i shaderProgram.uCombineB1, vhle.combine[10]
    @gl.uniform1i shaderProgram.uCombineC1, vhle.combine[12]
    @gl.uniform1i shaderProgram.uCombineD1, vhle.combine[14]
    @gl.uniform1i shaderProgram.uCombineA1a, vhle.combine[9]
    @gl.uniform1i shaderProgram.uCombineB1a, vhle.combine[11]
    @gl.uniform1i shaderProgram.uCombineC1a, vhle.combine[13]
    @gl.uniform1i shaderProgram.uCombineD1a, vhle.combine[15]
    return

  C1964jsWebGL::setMatrixUniforms = (shaderProgram) ->
    @gl.uniformMatrix4fv shaderProgram.pMatrixUniform, false, pMatrix
    @gl.uniformMatrix4fv shaderProgram.mvMatrixUniform, false, mvMatrix
    #@gl.uniformMatrix4fv shaderProgram.nMatrixUniform, false, nMatrix
    return

  C1964jsWebGL::beginDList = ->
    # matrices for quad tiles only
    #@gl.viewport 0, 0, @gl.viewportWidth, @gl.viewportHeight
    newAspect = (self.innerWidth) / (self.innerHeight)
    aspectWidth = @gl.viewportWidth
    aspectHeight = @gl.viewportHeight
    x = 0
    y = 0
    
    stretch = document.getElementById("stretch").checked

    nativeAspect = @core.videoHLE.n64ViewportWidth / @core.videoHLE.n64ViewportHeight

    if !stretch
      if newAspect >= nativeAspect
        aspectWidth = @gl.viewportWidth / newAspect * nativeAspect
        x = (@gl.viewportWidth - aspectWidth) / 2.0 # center x
      else
        aspectHeight = @gl.viewportHeight * newAspect / nativeAspect
        y = (@gl.viewportHeight - aspectHeight) / 2.0 # center y

    @gl.viewport x, y, aspectWidth, aspectHeight
    #needed for game selection screen in mario
    #mat4.perspective 90, (@gl.viewportWidth/@gl.viewportHeight), 1.0, 1023.0, pMatrix
    mat4.identity mvMatrix
    mat4.identity pMatrix
    mat4.translate mvMatrix, [0.0, 0.0, -(@gl.viewportWidth/@gl.viewportHeight)]
    return

  C1964jsWebGL::webGLStart = (wireframe) ->
    canvas3D = document.getElementById("Canvas3D")
    @initGL canvas3D
    @shaderProgram = @initShaders("fragment-shader", "vertex-shader")

    if @gl
      @gl.clearColor 0.0, 0.0, 0.0, 1.0
    canvas3D.style.visibility = "hidden"
    return

  C1964jsWebGL::show3D = ->
    canvas3D = document.getElementById("Canvas3D")
    canvas3D.style.visibility = "visible"
    canvas2D = document.getElementById("Canvas")
    canvas2D.style.visibility = "hidden"
    return

  C1964jsWebGL::hide3D = ->
    canvas3D = document.getElementById("Canvas3D")
    canvas3D.style.visibility = "hidden"
    canvas2D = document.getElementById("Canvas")
    canvas2D.style.visibility = "visible"
    return
)()
#hack global space until we export classes properly
#node.js uses exports; browser uses this (window)
root = exports ? self
root.C1964jsWebGL = C1964jsWebGL
