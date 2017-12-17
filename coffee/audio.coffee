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
class C1964jsAudio

  audioContext = undefined
  audioBuffer = undefined

  constructor: ->
    @sampleNum = 0
    @lastLength = 0
    @audioBuffer = null
    @startTime = null
    @source = null
    @left = null
    @right = null
    try
      @audioContext = new (window.AudioContext || window.webkitAudioContext)() if audioContext is `undefined`
    catch error
      #log "Your browser doesn't support Web Audio."
      @audioContext = "unsupported"
      return false

  playAudio: (memory, from, length) ->
    return if audioContext is "unsupported"

    PI_2_400 = 1.0 / (Math.PI * 2.0 * 400.0)
    normalizer = 1.0 / 32768.0

    # Create/set audio buffer for each chunk
    return  if length < 4
    @source = @audioContext.createBufferSource()
    @audioBuffer = @audioContext.createBuffer(2, length / 4, 44100)  #if audioBuffer is `undefined`
    @source.buffer = @audioBuffer
    @startTime += @audioBuffer.duration
    @source.connect @audioContext.destination
    @source.loop = false
    @left = @audioBuffer.getChannelData(0)
    @right = @audioBuffer.getChannelData(1)
   
    i = from & 0x00FFFFFF
    k = 0
    while k < length
      @left[k+@lastLength] = ((memory.rdramUint8Array[i] << 8 | memory.rdramUint8Array[i + 1]) << 16 >> 16) * normalizer #* PI_2_400
      @right[k+@lastLength] = ((memory.rdramUint8Array[i + 2] << 8 | memory.rdramUint8Array[i + 3]) << 16 >> 16) * normalizer
      i += 4
      k += 1
 
    @sampleNum += 1
    @lastLength += length / 4
#    if @sampleNum is 120
    @source.start()
    @sampleNum = 0
    @lastLength = 0
    return true
    return false

#hack global space until we export classes properly
#node.js uses exports; browser uses this (window)
root = exports ? this
root.C1964jsAudio = C1964jsAudio