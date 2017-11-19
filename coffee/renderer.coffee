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

C1964jsRenderer = (settings, glx, webGL) ->
  gl = glx
  @canvas = undefined

  texrectVertexPositionBuffer = undefined
  texrectVertexTextureCoordBuffer = undefined
  texrectVertexIndexBuffer = undefined
  @videoHLE = undefined
  fivetoeight = [0x00,0x08,0x10,0x18,0x21,0x29,0x31,0x39,0x42,0x4A,0x52,0x5A,0x63,0x6B,0x73,0x7B,0x84,0x8C,0x94,0x9C,0xA5,0xAD,0xB5,0xBD,0xC6,0xCE,0xD6,0xDE,0xE7,0xEF,0xF7,0xFF]
  fourtoeight = [0x00,0x11,0x22,0x33,0x44,0x55,0x66,0x77,0x88,0x99,0xaa,0xbb,0xcc,0xdd,0xee,0xff]
  threetoeight = [
    0x00,   # 000 -> 00 00 00 00
    0x24,   # 001 -> 00 10 01 00
    0x49,   # 010 -> 01 00 10 01
    0x6d,   # 011 -> 01 10 11 01
    0x92,   # 100 -> 10 01 00 10
    0xb6,   # 101 -> 10 11 01 10
    0xdb,   # 110 -> 11 01 10 11
    0xff    # 111 -> 11 11 11 11
  ]
  onetoeight = [
    0x00,   # 0 -> 00 00 00 00
    0xff    # 1 -> 11 11 11 11
  ]

  @textureCache = new Object()

  @texRect = (xl, yl, xh, yh, s, t, dsdx, dtdy, tile, tmem, videoHLE) ->

    @videoHLE = videoHLE

    nextPow2Width = videoHLE.pow2roundup tile.width
    nextPow2Height = videoHLE.pow2roundup tile.height

    widthscale = tile.width / nextPow2Width
    heightscale = tile.height / nextPow2Height

    rectWidth = xh-xl
    rectHeight = yh-yl

    #console.log "Rectsize:"+rectWidth+"x"+rectHeight+" S:"+s+"("+dsdx+") T:"+t+"("+dtdy

    sl = s / tile.height
    tl = t / tile.width
    sh = (s + (rectWidth*dsdx)) / tile.width * widthscale
    th = (t + (rectHeight*dtdy)) / tile.height * heightscale

    xl = (xl-160)/160
    xh = (xh-160)/160
    yl = -(yl-120)/120
    yh = -(yh-120)/120

    initQuad xl, yl, xh, yh, sl, tl, sh, th, videoHLE
    @draw tile, tmem, videoHLE, nextPow2Width, nextPow2Height
    return

  @formatTexture = (tile, tmem, videoHLE) ->
    @videoHLE = videoHLE

    if tile.width is undefined or tile.height is undefined
      tile.width = 2
      tile.height = 2
      return new Uint8Array([0, 255, 0, 0, 0, 255, 0, 0, 0, 255, 0, 0, 0, 255, 0, 0])

    nextPow2Width = @videoHLE.pow2roundup tile.width
    nextPow2Height = @videoHLE.pow2roundup tile.height

    textureSize = nextPow2Width * nextPow2Height * 4
    #hacky texture cache unique id (want to see how fast we currently are)

    @useTextureCache = false #change to true to try texture cache
    if @useTextureCache is true
      randomPixel = nextPow2Width * nextPow2Height
      textureId = (tmem[randomPixel]>>>0) << 24 | (tmem[randomPixel+nextPow2Width+1]>>>0) << 16 | (tmem[randomPixel+nextPow2Width*2+1]>>>0) << 8 | tmem[randomPixel+nextPow2Width*3+1]>>>0
      return @textureCache[textureId] if @textureCache[textureId]?

    if (nextPow2Width isnt tile.width) or (nextPow2Height isnt tile.height)
      # handle non-power of 2 textures
      if @canvas is undefined
        @canvas = document.getElementById('Canvas');
      @canvas.width = tile.width
      @canvas.height = tile.height
      context = @canvas.getContext('2d')
      imageData = context.createImageData(nextPow2Width, nextPow2Height)
      texture = imageData.data
    else
      texture = new Uint8Array(textureSize)

    dstRowOffset = 0
    dstRowStride = nextPow2Width * 4
    srcRowStride = tile.line<<3
    srcRowOffset = tile.tmem

    if @useTextureCache is true
      @textureCache[textureId] = texture
    switch tile.fmt
      when consts.TXT_FMT_RGBA # rgba
        switch tile.siz
          when consts.TXT_SIZE_16b # rgba5551
            j=0
            while j < tile.height
              i=0
              srcOffset = srcRowOffset
              dstOffset = dstRowOffset
              while i < tile.width
                color16 = tmem[srcOffset]<<8 | tmem[srcOffset+1]
                texture[dstOffset] = fivetoeight[color16 >> 11 & 0x1F]
                texture[dstOffset + 1] = fivetoeight[color16 >> 6 & 0x1F]
                texture[dstOffset + 2] = fivetoeight[color16 >> 1 & 0x1F]
                texture[dstOffset + 3] = if ((color16 & 0x01) is 0) then 0x00 else 0xFF
                i++
                srcOffset += 2
                dstOffset += 4
              j++
              srcRowOffset += srcRowStride
              dstRowOffset += dstRowStride
          else
            console.error "TODO: tile format " + tile.fmt + ", tile.size:" + tile.siz
      when consts.TXT_FMT_IA # ia
        switch tile.siz
          when consts.TXT_SIZE_8b # ia8
            j=0
            while j < tile.height
              i=0
              srcOffset = srcRowOffset
              dstOffset = dstRowOffset
              while i < tile.width
                b = tmem[srcOffset]
                I = fourtoeight[(b >>> 4)& 0x0F]
                a = fourtoeight[b & 0x0F]
                texture[dstOffset] = I
                texture[dstOffset + 1] = I
                texture[dstOffset + 2] = I
                texture[dstOffset + 3] = a
                i++
                srcOffset += 1
                dstOffset += 4
              j++
              srcRowOffset += srcRowStride
              dstRowOffset += dstRowStride
          when consts.TXT_SIZE_4b # ia4
            j=0
            while j < tile.height
              i=0
              srcOffset = srcRowOffset
              dstOffset = dstRowOffset
              while i < tile.width
                b = tmem[srcOffset]
                I0 = threetoeight[(b & 0xe0)>>>5]
                a0 = onetoeight[(b & 0x10)>>>4]
                I1 = threetoeight[(b & 0xe0)>>>1]
                a1 = onetoeight[(b & 0x01)>>>0]
                texture[dstOffset] = I0
                texture[dstOffset + 1] = I0
                texture[dstOffset + 2] = I0
                texture[dstOffset + 3] = a0
                texture[dstOffset + 4] = I1
                texture[dstOffset + 5] = I1
                texture[dstOffset + 6] = I1
                texture[dstOffset + 7] = a1
                i+=2
                srcOffset += 1
                dstOffset += 8
              if tile.width & 1
                I0 = threetoeight[(b & 0xe0)>>>5]
                a0 = onetoeight[(b & 0x10)>>>4]
                texture[dstOffset] = I0
                texture[dstOffset + 1] = I0
                texture[dstOffset + 2] = I0
                texture[dstOffset + 3] = a0
                srcOffset += 1
                dstOffset += 4
              j++
              srcRowOffset += srcRowStride
              dstRowOffset += dstRowStride
          when consts.TXT_SIZE_16b # ia16
            j=0
            while j < tile.height
              i=0
              srcOffset = srcRowOffset
              dstOffset = dstRowOffset
              while i < tile.width
                I = tmem[srcOffset]
                a = tmem[srcOffset+1]
                texture[dstOffset] = I
                texture[dstOffset + 1] = I
                texture[dstOffset + 2] = I
                texture[dstOffset + 3] = a
                i++
                srcOffset += 2
                dstOffset += 4
              j++
              srcRowOffset += srcRowStride
              dstRowOffset += dstRowStride
          else
            console.error "TODO: tile format " + tile.fmt + ", tile.size" + tile.siz
      else
        console.error "TODO: tile format " + tile.fmt + ", tile.size" + tile.siz

    console.log "tile: w: " + tile.width + ", h: " + tile.height + ", pow2w: " + nextPow2Width + ", pow2H: " + nextPow2Height
   # if @useTextureCache is true
   #   return @textureCache[textureId]
    if (nextPow2Width isnt tile.width) or (nextPow2Height isnt tile.height)
      context.putImageData(imageData, 0, 0);
      return @canvas
    return texture

  initQuad = (xl, yl, xh, yh, sl, tl, sh, th, videoHLE) ->
    vertices = [xh, yh, 0.0, xh, yl, 0.0, xl, yl, 0.0, xl, yh, 0.0]
    texrectVertexPositionBuffer = gl.createBuffer()
    gl.bindBuffer gl.ARRAY_BUFFER, texrectVertexPositionBuffer
    gl.bufferData gl.ARRAY_BUFFER, new Float32Array(vertices), gl.DYNAMIC_DRAW
    texrectVertexPositionBuffer.itemSize = 3
    texrectVertexPositionBuffer.numItems = 4

    textureCoords = [sh, th, sh, tl, sl, tl, sl, th]
    texrectVertexTextureCoordBuffer = gl.createBuffer()
    gl.bindBuffer gl.ARRAY_BUFFER, texrectVertexTextureCoordBuffer
    gl.bufferData gl.ARRAY_BUFFER, new Float32Array(textureCoords), gl.STATIC_DRAW
    texrectVertexTextureCoordBuffer.itemSize = 2
    texrectVertexTextureCoordBuffer.numItems = 4

    texrectVertexIndices = [0, 1, 2, 0, 2, 3]
    texrectVertexIndexBuffer = gl.createBuffer()
    gl.bindBuffer gl.ELEMENT_ARRAY_BUFFER, texrectVertexIndexBuffer
    gl.bufferData gl.ELEMENT_ARRAY_BUFFER, new Uint16Array(texrectVertexIndices), gl.STATIC_DRAW
    texrectVertexIndexBuffer.itemSize = 1
    texrectVertexIndexBuffer.numItems = 6
    return

  @draw = (tile, tmem, videoHLE, nextPow2Width, nextPow2Height) ->
    gl.useProgram webGL.shaderProgram

    gl.enableVertexAttribArray webGL.shaderProgram.vertexPositionAttribute
    gl.bindBuffer gl.ARRAY_BUFFER, texrectVertexPositionBuffer
    gl.vertexAttribPointer webGL.shaderProgram.vertexPositionAttribute, texrectVertexPositionBuffer.itemSize, gl.FLOAT, false, 0, 0

    gl.enableVertexAttribArray webGL.shaderProgram.textureCoordAttribute
    gl.bindBuffer gl.ARRAY_BUFFER, texrectVertexTextureCoordBuffer
    gl.vertexAttribPointer webGL.shaderProgram.textureCoordAttribute, texrectVertexTextureCoordBuffer.itemSize, gl.FLOAT, false, 0, 0

    #console.log "Binding Texture Size: "+tile.width+" x "+tile.height+" -> "+canvaswidth+" x "+canvasheight

    textureData = @formatTexture(tile, tmem, videoHLE)
    if textureData isnt undefined
      colorsTexture = gl.createTexture()
      gl.activeTexture(gl.TEXTURE0)
      gl.bindTexture(gl.TEXTURE_2D, colorsTexture)
      if textureData instanceof HTMLElement
        #it's a canvas
        gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, textureData)
      else
        gl.texImage2D( gl.TEXTURE_2D, 0, gl.RGBA, nextPow2Width, nextPow2Height, 0, gl.RGBA, gl.UNSIGNED_BYTE, textureData)


      wrapS = gl.REPEAT
      wrapT = gl.REPEAT
      if ((tile.cms is consts.RDP_TXT_CLAMP) or (tile.masks is 0))
        wrapS = gl.CLAMP_TO_EDGE
      else if tile.cms is consts.RDP_TXT_MIRROR
        wrapS = gl.MIRRORED_REPEAT
      if ((tile.cmt is consts.RDP_TXT_CLAMP) or (tile.maskt is 0))
        wrapT = gl.CLAMP_TO_EDGE
      else if tile.cms is consts.RDP_TXT_MIRROR
        wrapT = gl.MIRRORED_REPEAT
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, wrapS)
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, wrapT)

      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST)
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST)
      gl.uniform1i webGL.shaderProgram.samplerUniform, colorsTexture

      if videoHLE.primColor.length > 0
        gl.uniform4fv webGL.shaderProgram.uPrimColor, videoHLE.primColor

      if videoHLE.fillColor.length > 0
        gl.uniform4fv webGL.shaderProgram.uFillColor, videoHLE.fillColor

      if videoHLE.blendColor.length > 0
        gl.uniform4fv webGL.shaderProgram.uBlendColor, videoHLE.blendColor

      if videoHLE.envColor.length > 0
        gl.uniform4fv webGL.shaderProgram.uEnvColor, videoHLE.envColor

      gl.bindBuffer gl.ELEMENT_ARRAY_BUFFER, texrectVertexIndexBuffer
      webGL.setMatrixUniforms webGL.shaderProgram
      webGL.setCombineUniforms webGL.shaderProgram
      gl.uniform1i webGL.shaderProgram.wireframeUniform, if settings.wireframe then 1 else 0

      if settings.wireframe is true
        gl.drawElements gl.LINE_LOOP, texrectVertexIndexBuffer.numItems, gl.UNSIGNED_SHORT, 0
      else
        gl.drawElements gl.TRIANGLES, texrectVertexIndexBuffer.numItems, gl.UNSIGNED_SHORT, 0
    return
  return this
#hack global space until we export classes properly
#node.js uses exports; browser uses this (window)
root = exports ? this
root.C1964jsRenderer = C1964jsRenderer
