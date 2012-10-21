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

C1964jsWebGL = (wireframe) ->
  "use strict"
  @gl = `undefined`
  @wireframeTileShaderProgram = `undefined`
  @wireframeTriangleShaderProgram = `undefined`
  @tileShaderProgram = `undefined`
  @triangleShaderProgram = `undefined`
  @normalTileShaderProgram = `undefined`
  @normalTriangleShaderProgram = `undefined`
  @webGLStart(wireframe)
  return this

(->
  "use strict"
  nMatrix = undefined
  pMatrix = undefined
  mvMatrixStack = undefined
  mvMatrix = mat4.create()
  mvMatrixStack = []
  pMatrix = mat4.create()
  nMatrix = mat4.create()
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
    log "Could not initialise WebGL. Your browser may not support it."  unless @gl
    return

  C1964jsWebGL::getShader = (id) ->
    k = undefined
    shaderScript = undefined
    shader = undefined
    str = ""
    shaderScript = document.getElementById(id)
    return null  unless shaderScript
    k = shaderScript.firstChild
    while k
      str += k.textContent  if k.nodeType is 3
      k = k.nextSibling
    if shaderScript.type is "x-shader/x-fragment"
      shader = @gl.createShader(@gl.FRAGMENT_SHADER)
    else if shaderScript.type is "x-shader/x-vertex"
      shader = @gl.createShader(@gl.VERTEX_SHADER)
    else
      return null
    @gl.shaderSource shader, str
    @gl.compileShader shader
    unless @gl.getShaderParameter(shader, @gl.COMPILE_STATUS)
      alert @gl.getShaderInfoLog(shader)
      return null
    shader

  C1964jsWebGL::initShaders = (fs, vs) ->
    shaderProgram = undefined
    vertexShader = undefined
    fragmentShader = @getShader(fs)
    vertexShader = @getShader(vs)
    shaderProgram = @gl.createProgram()
    @gl.attachShader shaderProgram, vertexShader
    @gl.attachShader shaderProgram, fragmentShader
    @gl.linkProgram shaderProgram
    alert "Could not initialize shaders"  unless @gl.getProgramParameter(shaderProgram, @gl.LINK_STATUS)
    @gl.useProgram shaderProgram
    shaderProgram.vertexPositionAttribute = @gl.getAttribLocation(shaderProgram, "aVertexPosition")
    shaderProgram.pMatrixUniform = @gl.getUniformLocation(shaderProgram, "uPMatrix")
    shaderProgram.mvMatrixUniform = @gl.getUniformLocation(shaderProgram, "uMVMatrix")
    shaderProgram.nMatrixUniform = @gl.getUniformLocation(shaderProgram, "uNormalMatrix")
    shaderProgram.textureCoordAttribute = @gl.getAttribLocation(shaderProgram, "aTextureCoord")
    shaderProgram.samplerUniform = @gl.getUniformLocation(shaderProgram, "uSampler")
    shaderProgram

  C1964jsWebGL::switchShader = (shaderProgram, wireframe) ->

    if wireframe is true
      @tileShaderProgram = @wireframeTileShaderProgram
      @triangleShaderProgram = @wireframeTriangleShaderProgram
    else
      @tileShaderProgram = @normalTileShaderProgram
      @triangleShaderProgram = @normalTriangleShaderProgram


    @gl.useProgram shaderProgram
    
    #if (shaderProgram.vertexPositionAttribute !== -1)
    @gl.enableVertexAttribArray shaderProgram.vertexPositionAttribute
    
    #if (shaderProgram.textureCoordAttribute !== -1)
    @gl.enableVertexAttribArray shaderProgram.textureCoordAttribute

    return

  C1964jsWebGL::beginDList = ->
    @gl.viewport 0, 0, @gl.viewportWidth, @gl.viewportHeight
    @gl.clear @gl.COLOR_BUFFER_BIT | @gl.DEPTH_BUFFER_BIT
    mat4.perspective 45, @gl.viewportWidth / @gl.viewportHeight, 0.1, 100.0, pMatrix
    mat4.identity mvMatrix
    mat4.translate mvMatrix, [0.0, 0.0, -2.4]
    mat4.set mvMatrix, nMatrix
    mat4.inverse nMatrix, nMatrix
    mat4.transpose nMatrix
    # mvPushMatrix();
    mat4.translate mvMatrix, [0.0, 0.0, -1.0]
    return

  C1964jsWebGL::setMatrixUniforms = (shaderProgram) ->
    @gl.uniformMatrix4fv shaderProgram.pMatrixUniform, false, pMatrix
    @gl.uniformMatrix4fv shaderProgram.mvMatrixUniform, false, mvMatrix
    @gl.uniformMatrix4fv shaderProgram.nMatrixUniform, false, nMatrix
    return

  C1964jsWebGL::mvPushMatrix = ->
    copy = mat4.create()
    mat4.set mvMatrix, copy
    mvMatrixStack.push copy
    return

  C1964jsWebGL::mvPopMatrix = ->
    throw Error "Invalid popMatrix!"  if mvMatrixStack.length is 0
    mvMatrix = mvMatrixStack.pop()
    return

  C1964jsWebGL::webGLStart = (wireframe) ->
    canvas = document.getElementById("Canvas3D")
    @initGL canvas

    @wireframeTileShaderProgram = @initShaders("color-framebuffer-fragment-shader", "tile-vertex-shader")
    @wireframeTriangleShaderProgram = @initShaders("color-framebuffer-fragment-shader", "triangle-vertex-shader")
    @normalTileShaderProgram = @initShaders("tile-fragment-shader", "tile-vertex-shader")
    @normalTriangleShaderProgram = @initShaders("triangle-fragment-shader", "triangle-vertex-shader")

    if wireframe is true
      @tileShaderProgram = @wireframeTileShaderProgram
      @triangleShaderProgram = @wireframeTriangleShaderProgram
    else
      @tileShaderProgram = @normalTileShaderProgram
      @triangleShaderProgram = @normalTriangleShaderProgram

    if @gl
      @gl.clearColor 0.0, 0.0, 0.0, 1.0
    canvas.style.visibility = "hidden"
    return

  C1964jsWebGL::show3D = ->
    canvas3D = document.getElementById("Canvas3D")
    canvas3D.style.visibility = "visible"
    return

  C1964jsWebGL::hide3D = ->
    canvas3D = document.getElementById("Canvas3D")
    canvas3D.style.visibility = "hidden"
    return
)()
#hack global space until we export classes properly
#node.js uses exports; browser uses this (window)
root = exports ? this
root.C1964jsWebGL = C1964jsWebGL