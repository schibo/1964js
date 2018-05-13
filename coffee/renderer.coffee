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
  @texture = new Uint8Array(1024*1024*4)


  texrectVertexPositionBuffer = gl.createBuffer()
  texrectVertexTextureCoordBuffer = gl.createBuffer()
  texrectVertexIndexBuffer = gl.createBuffer()
  texrectVertexIndices = [0, 1, 2, 0, 2, 3]
  gl.bindBuffer gl.ELEMENT_ARRAY_BUFFER, texrectVertexIndexBuffer
  gl.bufferData gl.ELEMENT_ARRAY_BUFFER, new Uint16Array(texrectVertexIndices), gl.STATIC_DRAW
  texrectVertexIndexBuffer.itemSize = 1
  texrectVertexIndexBuffer.numItems = 6
  @colorsTexture0 = gl.createTexture()

  @videoHLE = undefined
  `const fivetoeight = new Uint8Array([0x00,0x08,0x10,0x18,0x21,0x29,0x31,0x39,0x42,0x4A,0x52,0x5A,0x63,0x6B,0x73,0x7B,0x84,0x8C,0x94,0x9C,0xA5,0xAD,0xB5,0xBD,0xC6,0xCE,0xD6,0xDE,0xE7,0xEF,0xF7,0xFF])
  const fourtoeight = new Uint8Array([0x00,0x11,0x22,0x33,0x44,0x55,0x66,0x77,0x88,0x99,0xaa,0xbb,0xcc,0xdd,0xee,0xff])
  const threetoeight = new Uint8Array([
    0x00,   // 000 -> 00 00 00 00
    0x24,   // 001 -> 00 10 01 00
    0x49,   // 010 -> 01 00 10 01
    0x6d,   // 011 -> 01 10 11 01
    0x92,   // 100 -> 10 01 00 10
    0xb6,   // 101 -> 10 11 01 10
    0xdb,   // 110 -> 11 01 10 11
    0xff    // 111 -> 11 11 11 11
  ])
  const onetoeight = new Uint8Array([
    0x00,   // 0 -> 00 00 00 00
    0xff    // 1 -> 11 11 11 11
  ])`

  @textureCache = new Object()

  @texRect = (tileno, xl, yl, xh, yh, s, t, dsdx, dtdy, tile, tmem, videoHLE, isFillRect) ->

    tileWidth = (((tile.lrs >> 2) + 1) - tile.uls)|0
    tileHeight = (((tile.lrt >> 2) + 1) - tile.ult)|0

    @videoHLE = videoHLE

    supportsNonPowerOf2 = true

    if !supportsNonPowerOf2
      nextPow2Width = videoHLE.pow2roundup tileWidth
      nextPow2Height = videoHLE.pow2roundup tileHeight
      widthscale = tileWidth / nextPow2Width
      heightscale = tileHeight / nextPow2Height
    else
      nextPow2Width = tileWidth
      nextPow2Height = tileHeight
      widthscale = 1.0
      heightscale = 1.0

    rectWidth = xh-xl
    rectHeight = yh-yl

    #console.log "Rectsize:"+rectWidth+"x"+rectHeight+" S:"+s+"("+dsdx+") T:"+t+"("+dtdy

    sl = s / tileHeight
    tl = t / tileWidth
    sh = (s + (rectWidth*dsdx)) / tileWidth * widthscale
    th = (t + (rectHeight*dtdy)) / tileHeight * heightscale

    xTrans = 160
    yTrans = 120
    xl = (xl-xTrans)*0.00625 #0.000625 is 1.0/160.0
    xh = (xh-xTrans)*0.00625
    yl = -(yl-yTrans)/yTrans
    yh = -(yh-yTrans)/yTrans

    initQuad xl, yl, xh, yh, sl, tl, sh, th, videoHLE
    @draw tileno, tile, tmem, videoHLE, nextPow2Width, nextPow2Height, tileWidth, tileHeight, isFillRect
    return

  @formatTexture = (tile, tmem, videoHLE, isFillRect) ->
    @videoHLE = videoHLE

    return undefined if tile.lrs is undefined or tile.lrt is undefined or tile.uls is undefined or tile.ult is undefined

    tileWidth = ((tile.lrs >> 2) + 1) - (tile.uls|0)
    tileHeight = ((tile.lrt >> 2) + 1) - (tile.ult|0)

    supportsNonPowerOf2 = true
    if !supportsNonPowerOf2
      nextPow2Width = @videoHLE.pow2roundup (tileWidth*4)
      nextPow2Height = @videoHLE.pow2roundup tileHeight
    else
      nextPow2Width = tileWidth<<2
      nextPow2Height = tileHeight

    textureSize = nextPow2Width * nextPow2Height
    #hacky texture cache unique id (want to see how fast we currently are)

    if tileWidth is undefined or tileHeight is undefined
      e = Error
      e.message = "Undefined tile dimensions"
      throw e

    # @useTextureCache = false #change to true to try texture cache
    # if @useTextureCache is true
    #   randomPixel = nextPow2Width * nextPow2Height
    #   textureId = (tmem[randomPixel]>>>0) << 24 | (tmem[randomPixel+nextPow2Width+1]>>>0) << 16 | (tmem[randomPixel+nextPow2Width*2+1]>>>0) << 8 | tmem[randomPixel+nextPow2Width*3+1]>>>0
    #   return @textureCache[textureId] if @textureCache[textureId]?

    # if (nextPow2Width isnt tileWidth) or (nextPow2Height isnt tileHeight)
    #   # handle non-power of 2 textures
    #   if @canvas is undefined
    #     @canvas = document.getElementById('Canvas');
    #   @canvas.width = tileWidth
    #   @canvas.height = tileHeight
    #   context = @canvas.getContext('2d')
    #   imageData = context.createImageData(nextPow2Width, nextPow2Height)
    #   texture = imageData.data
    # else
    texture = @texture

    dstRowOffset = 0
    `const dstRowStride = nextPow2Width`
    `const srcRowStride = tile.line<<3`
    srcRowOffset = tile.tmem<<3

    if videoHLE.cycleType is 3 or isFillRect is true
      # no need to copy`
    else
      if @useTextureCache is true
        @textureCache[textureId] = texture
      switch tile.fmt
        when consts.TXT_FMT_RGBA # rgba
          switch tile.siz
            when consts.TXT_SIZE_16b # rgba5551
              @convertRGBA16 texture, tmem, tileWidth, tileHeight, srcRowOffset, dstRowOffset, srcRowStride, dstRowStride
            else
              console.error "TODO: tile format " + tile.fmt + ", tile.size:" + tile.siz
        when consts.TXT_FMT_IA # ia
          switch tile.siz
            when consts.TXT_SIZE_8b # ia8
              @convertIA8 texture, tmem, tileWidth, tileHeight, srcRowOffset, dstRowOffset, srcRowStride, dstRowStride
            when consts.TXT_SIZE_4b # ia4
              @convertIA4 texture, tmem, tileWidth, tileHeight, srcRowOffset, dstRowOffset, srcRowStride, dstRowStride
            when consts.TXT_SIZE_16b # ia16
              @convertIA16 texture, tmem, tileWidth, tileHeight, srcRowOffset, dstRowOffset, srcRowStride, dstRowStride
            else
              console.error "TODO: tile format " + tile.fmt + ", tile.size" + tile.siz
        when consts.TXT_FMT_CI
          switch tile.siz
            when consts.TXT_SIZE_8b
              if tile.otherModeL & consts.TLUT_FMT_RGBA16
                ram = videoHLE.core.memory.u8
                @convertCI8_RGBA16 texture, tmem, tile.pal, ram, tileWidth, tileHeight, srcRowOffset, dstRowOffset, srcRowStride, dstRowStride
              else if tile.otherModeL & consts.TLUT_FMT_IA16
                ram = videoHLE.core.memory.u8
                @convertCI8_IA16 texture, tmem, tile.pal, ram, tileWidth, tileHeight, srcRowOffset, dstRowOffset, srcRowStride, dstRowStride
              else
                console.error "TODO: tile format " + tile.fmt + ", tile.otherModeL" + tile.otherModeL  
            when consts.TXT_SIZE_16b
              console.error "TODO: tile format " + tile.fmt + ", tile.size" + tile.siz
            else
              console.error "TODO: tile format " + tile.fmt + ", tile.size" + tile.siz
        else
          console.error "TODO: tile format " + tile.fmt + ", tile.size" + tile.siz

   # if @useTextureCache is true
   #   return @textureCache[textureId]
   # if (nextPow2Width isnt tileWidth) or (nextPow2Height isnt tileHeight)
   #   context.putImageData(imageData, 0, 0);
   #   return @canvas
    return {textureData:texture, nextPow2Width: nextPow2Width, nextPow2Height: nextPow2Height}

  initQuad = (xl, yl, xh, yh, sl, tl, sh, th, videoHLE) ->
    vertices = [xh, yh, 0.0, xh, yl, 0.0, xl, yl, 0.0, xl, yh, 0.0]
    gl.bindBuffer gl.ARRAY_BUFFER, texrectVertexPositionBuffer
    gl.bufferData gl.ARRAY_BUFFER, new Float32Array(vertices), gl.DYNAMIC_DRAW
    texrectVertexPositionBuffer.itemSize = 3
    texrectVertexPositionBuffer.numItems = 4

    textureCoords = [sh, th, sh, tl, sl, tl, sl, th]
    gl.bindBuffer gl.ARRAY_BUFFER, texrectVertexTextureCoordBuffer
    gl.bufferData gl.ARRAY_BUFFER, new Float32Array(textureCoords), gl.STATIC_DRAW
    texrectVertexTextureCoordBuffer.itemSize = 2
    texrectVertexTextureCoordBuffer.numItems = 4
    return

  @convertRGBA16 = (texture, tm, texWidth, texHeight, srcRowOffset, dstRowOffset, srcRowStride, dstRowStride) ->
    `const tmem = tm` 
    `const height = texHeight|0`
    `const width = texWidth|0`

    j=-height
    while j < 0
      i=-width
      srcOffset = srcRowOffset|0
      dstOffset = dstRowOffset|0
      while i < 0
        hi = tmem[srcOffset]|0
        lo = tmem[srcOffset+1]|0
        i++
        texture[dstOffset] = fivetoeight[hi >>> 3]
        srcOffset += 2
        texture[dstOffset + 1] = fivetoeight[(lo >>> 6 | ((hi & 7) << 2))]
        texture[dstOffset + 2] = fivetoeight[lo >> 1 & 0x1F]
        texture[dstOffset + 3] = lo << 31 >> 31
        dstOffset += 4
      j++
      srcRowOffset += srcRowStride
      dstRowOffset += dstRowStride
    return

  @convertIA8 = (texture, tm, texWidth, texHeight, srcRowOffset, dstRowOffset, srcRowStride, dstRowStride) ->
    `const tmem = tm` 
    `const height = texHeight|0`
    `const width = texWidth|0`

    j=-height
    while j < 0
      i=-width
      srcOffset = srcRowOffset
      dstOffset = dstRowOffset
      while i < 0
        b = tmem[srcOffset]|0
        i++
        I = ((b >>> 4) & 0xF) | (b & 0xF0) 
        srcOffset += 1
        texture[dstOffset] = I
        texture[dstOffset + 1] = I
        texture[dstOffset + 2] = I
        texture[dstOffset + 3] = ((b << 4) & 0xF0) | (b & 0xF)
        dstOffset += 4
      j++
      srcRowOffset += srcRowStride
      dstRowOffset += dstRowStride
    return

  @convertCI4_RGBA16 = (texture, tm, palette, ram, texWidth, texHeight, srcRowOffset, dstRowOffset, srcRowStride, dstRowStride) ->
    `const tmem = tm`
    `const pal = palette`
    `const height = texHeight|0`
    `const width = texWidth|0`
    `const u8 = ram`

    j=-height
    while j < 0
      i=-width
      srcOffset = srcRowOffset
      dstOffset = dstRowOffset
      while i < 0
        bHi = tmem[srcOffset]&0xF0 >>> 4
        bLo = tmem[srcOffset]&0xF
        colorHi = u8[pal+bHi]<<8 | u8[pal+bHi+1]
        colorLo = u8[pal+bLo]<<8 | u8[pal+bLo+1]
        i++
        texture[dstOffset] = fivetoeight[colorHi >> 11 & 0x1F]
        srcOffset += 2
        texture[dstOffset + 1] = fivetoeight[colorHi >> 6 & 0x1F]
        texture[dstOffset + 2] = fivetoeight[colorHi >> 1 & 0x1F]
        texture[dstOffset + 3] = 255 #colorHi << 31 >> 31
        texture[dstOffset + 4] = fivetoeight[colorLo >> 11 & 0x1F]
        texture[dstOffset + 5] = fivetoeight[colorLo >> 6 & 0x1F]
        texture[dstOffset + 6] = fivetoeight[colorLo >> 1 & 0x1F]
        texture[dstOffset + 7] = 255 # colorLo << 31 >> 31
        dstOffset += 8
      j++
      srcRowOffset += srcRowStride
      dstRowOffset += dstRowStride
    return

  @convertCI8_RGBA16 = (texture, tm, palette, ram, texWidth, texHeight, srcRowOffset, dstRowOffset, srcRowStride, dstRowStride) ->
    `const tmem = tm`
    `const pal = palette`
    `const height = texHeight|0`
    `const width = texWidth|0`
    `const u8 = ram`

    j=-height
    while j < 0
      i=-width
      srcOffset = srcRowOffset
      dstOffset = dstRowOffset
      while i < 0
        b = tmem[srcOffset]
        color = u8[pal+b]<<8 | u8[pal+b+1]
        i++
        srcOffset += 1
        texture[dstOffset] = fivetoeight[color >> 11 & 0x1F]
        texture[dstOffset + 1] = fivetoeight[color >> 6 & 0x1F]
        texture[dstOffset + 2] = fivetoeight[color >> 1 & 0x1F]
        texture[dstOffset + 3] = 255 # colorLo << 31 >> 31
        dstOffset += 4
      j++
      srcRowOffset += srcRowStride
      dstRowOffset += dstRowStride
    return


  @convertCI8_IA16 = (texture, tm, palette, ram, texWidth, texHeight, srcRowOffset, dstRowOffset, srcRowStride, dstRowStride) ->
    `const tmem = tm`
    `const pal = palette`
    `const height = texHeight|0`
    `const width = texWidth|0`
    `const u8 = ram`

    j=-height
    while j < 0
      i=-width
      srcOffset = srcRowOffset
      dstOffset = dstRowOffset
      while i < 0
        b = tmem[srcOffset]
        I = u8[pal+b]
        a = u8[pal+b+1]
        i++
        srcOffset += 1
        texture[dstOffset] = I
        texture[dstOffset + 1] = I
        texture[dstOffset + 2] = I
        texture[dstOffset + 3] = a
        dstOffset += 4
      j++
      srcRowOffset += srcRowStride
      dstRowOffset += dstRowStride
    return


  @convertIA16ToRGBA = (wIA) ->
    intensity = (wIA >> 8) & 0xFF
    alpha     = (wIA     ) & 0xFF
    return @COLOR_RGBA dwIntensity, dwIntensity, dwIntensity, dwAlpha


  @convertIA4 = (texture, tm, texWidth, texHeight, srcRowOffset, dstRowOffset, srcRowStride, dstRowStride) ->
    `const tmem = tm` 
    `const height = texHeight|0`
    `const width = texWidth|0`

    j=-height
    while j < 0
      i=-width
      srcOffset = srcRowOffset
      dstOffset = dstRowOffset
      while i < 0
        b = tmem[srcOffset]|0
        i+=2
        I0 = threetoeight[(b & 0xe0)>>>5]
        srcOffset += 1
        I1 = threetoeight[(b & 0x0e)>>>1]
        texture[dstOffset] = I0
        texture[dstOffset + 1] = I0
        texture[dstOffset + 2] = I0
        texture[dstOffset + 3] = b << 27 >> 31
        texture[dstOffset + 4] = I1
        texture[dstOffset + 5] = I1
        texture[dstOffset + 6] = I1
        texture[dstOffset + 7] = b << 31 >> 31
        dstOffset += 8
      if width & 1
        b = tmem[srcOffset]|0
        i+=1
        I0 = threetoeight[(b & 0xe0)>>>5]
        srcOffset += 1
        texture[dstOffset] = I0
        texture[dstOffset + 1] = I0
        texture[dstOffset + 2] = I0
        texture[dstOffset + 3] = b << 27 >> 31
        dstOffset += 4
      j++
      srcRowOffset += srcRowStride
      dstRowOffset += dstRowStride
    return

  @convertIA16 = (texture, tm, texWidth, texHeight, srcRowOffset, dstRowOffset, srcRowStride, dstRowStride) ->
    `const tmem = tm` 
    `const height = texHeight|0`
    `const width = texWidth|0`

    j=-height
    while j < 0
      i=-width
      srcOffset = srcRowOffset
      dstOffset = dstRowOffset
      while i < 0
        I = tmem[srcOffset]|0
        i++
        texture[dstOffset] = I
        texture[dstOffset + 1] = I
        texture[dstOffset + 2] = I
        texture[dstOffset + 3] = tmem[srcOffset+1]
        srcOffset += 2
        dstOffset += 4
      j++
      srcRowOffset += srcRowStride
      dstRowOffset += dstRowStride
    return

  @draw = (tileno, tile, tmem, videoHLE, nextPow2Width, nextPow2Height, tileWidth, tileHeight, isFillRect) ->
    videoHLE.setBlendFunc()
#    gl.useProgram webGL.shaderProgram

    gl.enableVertexAttribArray webGL.shaderProgram.vertexPositionAttribute
    gl.bindBuffer gl.ARRAY_BUFFER, texrectVertexPositionBuffer
    gl.vertexAttribPointer webGL.shaderProgram.vertexPositionAttribute, texrectVertexPositionBuffer.itemSize, gl.FLOAT, false, 0, 0

    gl.enableVertexAttribArray webGL.shaderProgram.textureCoordAttribute
    gl.bindBuffer gl.ARRAY_BUFFER, texrectVertexTextureCoordBuffer
    gl.vertexAttribPointer webGL.shaderProgram.textureCoordAttribute, texrectVertexTextureCoordBuffer.itemSize, gl.FLOAT, false, 0, 0

    #console.log "Binding Texture Size: "+tileWidth+" x "+tileHeight+" -> "+canvaswidth+" x "+canvasheight

    tData = @formatTexture(tile, tmem, videoHLE, isFillRect)

    if tData isnt undefined and tData.textureData isnt undefined
      textureData = tData.textureData

      gl.activeTexture(gl.TEXTURE0 + tileno)
      gl.bindTexture(gl.TEXTURE_2D, @colorsTexture0)
      gl.texImage2D( gl.TEXTURE_2D, 0, gl.RGBA, tileWidth, tileHeight, 0, gl.RGBA, gl.UNSIGNED_BYTE, textureData)

      wrapS = gl.REPEAT
      wrapT = gl.REPEAT
      if ((tile.cms is consts.RDP_TXT_CLAMP) or (tile.masks is 0))
        wrapS = gl.CLAMP_TO_EDGE
      else if tile.cms is consts.RDP_TXT_MIRROR
        wrapS = gl.MIRRORED_REPEAT
      if ((tile.cmt is consts.RDP_TXT_CLAMP) or (tile.maskt is 0))
        wrapT = gl.CLAMP_TO_EDGE
      else if tile.cmt is consts.RDP_TXT_MIRROR
        wrapT = gl.MIRRORED_REPEAT
      gl.texParameterf(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, wrapS)
      gl.texParameterf(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, wrapT)

      gl.texParameterf(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST)
      gl.texParameterf(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST)
      gl.uniform1i webGL.shaderProgram.samplerUniform, @colorsTexture0

      if videoHLE.primColor.length > 0
        gl.uniform4fv webGL.shaderProgram.uPrimColor, videoHLE.primColor

      if videoHLE.fillColor.length > 0
        gl.uniform4fv webGL.shaderProgram.uFillColor, videoHLE.fillColor

      if videoHLE.blendColor.length > 0
        gl.uniform4fv webGL.shaderProgram.uBlendColor, videoHLE.blendColor

      if videoHLE.envColor.length > 0
        gl.uniform4fv webGL.shaderProgram.uEnvColor, videoHLE.envColor


      if isFillRect is true
        cycleType = 3
      else 
        cycleType = videoHLE.cycleType
      gl.uniform1i webGL.shaderProgram.cycleType, cycleType

    gl.bindBuffer gl.ELEMENT_ARRAY_BUFFER, texrectVertexIndexBuffer
    webGL.setMatrixUniforms webGL.shaderProgram
   # webGL.setCombineUniforms videoHLE, webGL.shaderProgram

    if settings.wireframe is true
      gl.drawElements gl.LINE_LOOP, texrectVertexIndexBuffer.numItems, gl.UNSIGNED_SHORT, 0
    else
      gl.drawElements gl.TRIANGLES, texrectVertexIndexBuffer.numItems, gl.UNSIGNED_SHORT, 0

    texrectVertexTextureCoordBuffer.numItems = 0
    texrectVertexPositionBuffer.numItems = 0
    return

  return this
#hack global space until we export classes properly
#node.js uses exports; browser uses this (window)
root = exports ? self
root.C1964jsRenderer = C1964jsRenderer
