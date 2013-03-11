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
  texrectVertexPositionBuffer = undefined
  texrectVertexTextureCoordBuffer = undefined
  texrectVertexIndexBuffer = undefined
  @videoHLE = undefined
  fivetoeight = [0x00,0x08,0x10,0x18,0x21,0x29,0x31,0x39,0x42,0x4A,0x52,0x5A,0x63,0x6B,0x73,0x7B,0x84,0x8C,0x94,0x9C,0xA5,0xAD,0xB5,0xBD,0xC6,0xCE,0xD6,0xDE,0xE7,0xEF,0xF7,0xFF]
  @textureCache = new Object()

  @texRect = (xl, yl, xh, yh, s, t, dsdx, dtdy, tile, tmem, videoHLE) ->
  
    @videoHLE = videoHLE
  
    canvaswidth = videoHLE.pow2roundup tile.width
    canvasheight = videoHLE.pow2roundup tile.height
	
    widthscale = tile.width / canvaswidth
    heightscale = tile.height / canvasheight  
	
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
    @draw tile, tmem, videoHLE
    return

  @formatTexture = (tile, tmem, cw, ch) ->
    canvaswidth = cw
    canvasheight = ch

    texturesize = canvasheight * canvaswidth * 4
    #hacky texture cache unique id (want to see how fast we currently are)
    
    @useTextureCache = true #change to true to try texture cache
    if @useTextureCache is true
      randomPixel = canvasheight * canvaswidth
      textureId = (tmem[randomPixel]>>>0) << 24 | (tmem[randomPixel+canvaswidth+1]>>>0) << 16 | (tmem[randomPixel+canvaswidth*2+1]>>>0) << 8 | tmem[randomPixel+canvaswidth*3+1]>>>0 
      return @textureCache[textureId] if @textureCache[textureId]?

    buffer = new ArrayBuffer(texturesize)
    texture = new Uint8Array(buffer)

    if @useTextureCache is true
      @textureCache[textureId] = texture
    switch tile.fmt
      when 0
        switch tile.siz
          when 2
            width = tile.width;
            j=0
            while j < tile.height
              i=0
              while i < tile.width
                base2 = (j*width*2) + (i*2)
                base4 = (j*canvaswidth*4) + (i*4) 
                color16 = tmem[base2]<<8 | tmem[base2+1]           
                texture[base4]     = fivetoeight[color16 >> 11 & 0x1F]
                texture[base4 + 1] = fivetoeight[color16 >> 6 & 0x1F]
                texture[base4 + 2] = fivetoeight[color16 >> 1 & 0x1F]
                texture[base4 + 3] = if color16 & 0x01 == 0 then 0x00 else 0xFF
                i++
              j++

   # if @useTextureCache is true
   #   return @textureCache[textureId]
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
  

  @draw = (tile, tmem, videoHLE) ->
    gl.useProgram webGL.shaderProgram
    
    # basic settings
    gl.disable gl.DEPTH_TEST
    gl.enable gl.BLEND
    gl.blendFunc gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA
    
    gl.enableVertexAttribArray webGL.shaderProgram.vertexPositionAttribute
    gl.bindBuffer gl.ARRAY_BUFFER, texrectVertexPositionBuffer
    gl.vertexAttribPointer webGL.shaderProgram.vertexPositionAttribute, texrectVertexPositionBuffer.itemSize, gl.FLOAT, false, 0, 0

    gl.enableVertexAttribArray webGL.shaderProgram.textureCoordAttribute
    gl.bindBuffer gl.ARRAY_BUFFER, texrectVertexTextureCoordBuffer
    gl.vertexAttribPointer webGL.shaderProgram.textureCoordAttribute, texrectVertexTextureCoordBuffer.itemSize, gl.FLOAT, false, 0, 0
	
    canvaswidth = videoHLE.pow2roundup tile.width
    canvasheight = videoHLE.pow2roundup tile.height
    #console.log "Binding Texture Size: "+tile.width+" x "+tile.height+" -> "+canvaswidth+" x "+canvasheight
    
    texture = @formatTexture(tile, tmem, canvaswidth, canvasheight)
    if texture isnt undefined
      colorsTexture = gl.createTexture()
      gl.activeTexture(gl.TEXTURE0)
      gl.bindTexture(gl.TEXTURE_2D, colorsTexture)
      gl.texImage2D( gl.TEXTURE_2D, 0, gl.RGBA, canvaswidth, canvasheight, 0, gl.RGBA, gl.UNSIGNED_BYTE, texture)
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
