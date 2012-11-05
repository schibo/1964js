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
useExternalTextures = false #for loading community texture packs
neheTexture = undefined

C1964jsRenderer = (settings, glx, webGL) ->
  gl = glx
  squareVertexPositionBuffer = undefined
  tilesInitialized = true
  cubeVertexPositionBuffer = undefined
  cubeVertexTextureCoordBuffer = undefined
  cubeVertexIndexBuffer = undefined
  #hack: getting width and height of texture by vertices
  #temp: ortho to [-1, 1]. assuming 320x240. todo: ortho projection based on screen res
  #inits a quad. good for tiles
  #initQuad(xl, yl, xh, yh ); //inits a quad. good for tiles
  #hack: getting width and height of texture by vertices
  #if (texImg.changed == true) {
  #}
  #var textureWidth = document.getElementById(textureName).width;
  #var textureHeight = document.getElementById(textureName).height;
  #var scalex = (xh-xl)*((textureWidth/w)-1);
  #var scaley = (yh-yl)*((textureHeight/h)-1);
  #initQuad(xl, yl, xh+scalex, yh+scaley ); //inits a quad. good for tiles
  #initQuad(xl, yl, xh, yh ); //inits a quad. good for tiles
  #   this.draw(tileno, texImg.changed);
  # texImg.changed = false;
  blitTexture = (ram, offset, idx, width, height) ->
    #test dummy textures
    textureName = "pow2Texture" + idx.toString()
    cc = document.getElementById(textureName)
    cctx = cc.getContext("2d")
    ImDat = cctx.createImageData(cc.width, cc.height)
    out = ImDat.data
    stride = (cc.width - width) * 4 #Bytes per pixel = 4;
    iii = 0
    k = offset
    y = -height

    while y isnt 0
      x = 0
      while x < width
        hi = ram[k]
        lo = ram[k + 1]
        out[iii + 3] = 255 #alpha
        out[iii] = (hi & 0xF8)
        k += 2
        out[iii + 1] = (((hi << 5) | (lo >>> 3)) & 0xF8)
        out[iii + 2] = (lo << 2 & 0xF8)
        iii += 4
        x++
      iii += stride
      y++
    cctx.putImageData ImDat, 0, 0
    return

  handleLoadedTexture = (texture, imageSrc) ->
    gl.bindTexture gl.TEXTURE_2D, texture
    gl.pixelStorei gl.UNPACK_FLIP_Y_WEBGL, true
    gl.texImage2D gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, imageSrc
    
    #console.log('getError returns: ' + gl.getError());
    
    #gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
    #gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_NEAREST);
    gl.texParameteri gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST
    gl.texParameteri gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_NEAREST
    
    #no wrapping
    #    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
    #    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
    gl.generateMipmap gl.TEXTURE_2D
    gl.bindTexture gl.TEXTURE_2D, null
    return
  
  # console.log('getError returns: ' + gl.getError());
  initTexture = (tileno, changed) ->
    return 0  if changed is false and window["neheTexture" + tileno] isnt `undefined`
    window["neheTexture" + tileno] = gl.createTexture()
    if useExternalTextures is true #this will be loading community hires texture packs in the future
      neheTexture.image = new Image()
      neheTexture.image.onload = ->
        handleLoadedTexture neheTexture, neheTexture.image

      neheTexture.image.src = "nehe.gif"
    else
      
      #load texture from a canvas
      handleLoadedTexture window["neheTexture" + tileno], document.getElementById("pow2Texture" + tileno)
    gl.getError()
    return

  initQuad = (xl, yl, xh, yh) ->
    #if (!cubeVertexPositionBuffer) {
    cubeVertexPositionBuffer = gl.createBuffer()
    gl.bindBuffer gl.ARRAY_BUFFER, cubeVertexPositionBuffer
    #}
    vertices = [xh, yh, 0.0, xh, yl, 0.0, xl, yl, 0.0, xl, yh, 0.0]
    gl.bufferData gl.ARRAY_BUFFER, new Float32Array(vertices), gl.DYNAMIC_DRAW
    cubeVertexPositionBuffer.itemSize = 3
    cubeVertexPositionBuffer.numItems = 4
    
    #if (!cubeVertexTextureCoordBuffer) {
    cubeVertexTextureCoordBuffer = gl.createBuffer()
    gl.bindBuffer gl.ARRAY_BUFFER, cubeVertexTextureCoordBuffer
    #}
    
    # Front face
    textureCoords = [1.0, 0.0, 1.0, 1.0, 0.0, 1.0, 0.0, 0.0]
    gl.bufferData gl.ARRAY_BUFFER, new Float32Array(textureCoords), gl.STATIC_DRAW
    cubeVertexTextureCoordBuffer.itemSize = 2
    cubeVertexTextureCoordBuffer.numItems = 4
    unless cubeVertexIndexBuffer
      cubeVertexIndexBuffer = gl.createBuffer()
      gl.bindBuffer gl.ELEMENT_ARRAY_BUFFER, cubeVertexIndexBuffer
      cubeVertexIndices = [0, 1, 2, 0, 2, 3] # Front face
      gl.bufferData gl.ELEMENT_ARRAY_BUFFER, new Uint16Array(cubeVertexIndices), gl.STATIC_DRAW
      cubeVertexIndexBuffer.itemSize = 1
      cubeVertexIndexBuffer.numItems = 6
    return
  
  @texRect = (xl, yl, xh, yh, s, t, dsdx, dtdy, tileno, ram, texImg) ->
    w = xh - xl
    w /= 4
    h = yh - yl
    h /= 4
    if settings.wireframe is false
      blitTexture ram, texImg.addr, tileno, w, h  if texImg.changed is true
      textureName = "pow2Texture" + tileno
    xh -= 160 * 4
    xh /= (160 * 4)
    xl -= 160 * 4
    xl /= (160 * 4)
    yl -= 120 * 4
    yl /= (-120 * 4)
    yh -= 120 * 4
    yh /= (-120 * 4)
    
    if settings.wireframe is false
      textureWidth = document.getElementById(textureName).width
      textureHeight = document.getElementById(textureName).height
    else
      textureWidth = w
      textureHeight = h
    scalex = (xh - xl) * ((textureWidth / w) - 1)
    scaley = (yh - yl) * ((textureHeight / h) - 1)
    initQuad xl, yl, xh + scalex, yh + scaley
    @draw tileno, texImg.changed
    texImg.changed = false
    return

  @texTri = (xl, yl, xh, yh, s, t, dsdx, dtdy, tileno, ram, texImg) ->
    if settings.wireframe is false
      w = 256
      h = 256
      blitTexture ram, texImg.addr, tileno, w, h
      textureName = "pow2Texture" + tileno
      error = initTexture(tileno, true)
    return

  @draw = (tileno, changed) ->
    webGL.switchShader webGL.tileShaderProgram, settings.wireframe

    if settings.wireframe is false
      error = initTexture(tileno, changed) #this is where things get really slow and we need a texture cache

    gl.disable gl.DEPTH_TEST
    gl.enable gl.BLEND
    gl.blendFunc gl.SRC_ALPHA, gl.ONE
    gl.bindBuffer gl.ARRAY_BUFFER, cubeVertexPositionBuffer
    gl.vertexAttribPointer webGL.tileShaderProgram.vertexPositionAttribute, cubeVertexPositionBuffer.itemSize, gl.FLOAT, false, 0, 0
    gl.bindBuffer gl.ARRAY_BUFFER, cubeVertexTextureCoordBuffer
    gl.vertexAttribPointer webGL.tileShaderProgram.textureCoordAttribute, cubeVertexTextureCoordBuffer.itemSize, gl.FLOAT, false, 0, 0
    if settings.wireframe is false
      gl.activeTexture gl.TEXTURE0
      gl.bindTexture gl.TEXTURE_2D, window["neheTexture" + tileno]
    gl.uniform1i webGL.tileShaderProgram.samplerUniform, 0
    gl.bindBuffer gl.ELEMENT_ARRAY_BUFFER, cubeVertexIndexBuffer
    webGL.setMatrixUniforms webGL.tileShaderProgram
    if settings.wireframe is false
      gl.drawElements gl.LINE_STRIP, cubeVertexIndexBuffer.numItems, gl.UNSIGNED_SHORT, 0
    else
      gl.drawElements gl.TRIANGLES, cubeVertexIndexBuffer.numItems, gl.UNSIGNED_SHORT, 0
    return
  return this
#hack global space until we export classes properly
#node.js uses exports; browser uses this (window)
root = exports ? this
root.C1964jsRenderer = C1964jsRenderer
