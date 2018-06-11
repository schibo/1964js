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

class C1964jsRendererLE extends C1964jsRenderer
  constructor: (settings, glx, webGL) ->
    super(settings, glx, webGL)
    return

  convertRGBA16: (texture, tm, texWidth, texHeight, srcRowOffset, dstRowOffset, srcRowStride, dstRowStride) ->
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

  convertIA8: (texture, tm, texWidth, texHeight, srcRowOffset, dstRowOffset, srcRowStride, dstRowStride) ->
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

  convertCI4_RGBA16: (texture, tm, palette, ram, texWidth, texHeight, srcRowOffset, dstRowOffset, srcRowStride, dstRowStride) ->
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

  convertCI8_RGBA16: (texture, tm, palette, ram, texWidth, texHeight, srcRowOffset, dstRowOffset, srcRowStride, dstRowStride) ->
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


  convertCI8_IA16: (texture, tm, palette, ram, texWidth, texHeight, srcRowOffset, dstRowOffset, srcRowStride, dstRowStride) ->
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


  convertIA16ToRGBA: (wIA) ->
    intensity = (wIA >> 8) & 0xFF
    alpha     = (wIA     ) & 0xFF
    return @COLOR_RGBA dwIntensity, dwIntensity, dwIntensity, dwAlpha


  convertIA4: (texture, tm, texWidth, texHeight, srcRowOffset, dstRowOffset, srcRowStride, dstRowStride) ->
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

  convertIA16: (texture, tm, texWidth, texHeight, srcRowOffset, dstRowOffset, srcRowStride, dstRowStride) ->
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

#hack global space until we export classes properly
#node.js uses exports; browser uses this (window)
root = exports ? self
root.C1964jsRendererLE = C1964jsRendererLE