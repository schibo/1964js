  
class C1964jsAudio

  audioContext = undefined
  audioBuffer = undefined

  constructor: ->

  processAudio: (memory, from, length) ->
    return
    try
      return  if audioContext is "unsupported"
      audioContext = new webkitAudioContext()  if audioContext is `undefined`
    catch error
      #log "Your browser doesn't support Web Audio."
      audioContext = "unsupported"
      return false
    
    PI_2_400 = 1.0 / (Math.PI * 2 * 400)

    # Create/set audio buffer for each chunk
    source = audioContext.createBufferSource()
    return  if length < 4
    audioBuffer = audioContext.createBuffer(2, length / 2 / 2, 44100)  if audioBuffer is `undefined`
    left = audioBuffer.getChannelData(0)
    right = audioBuffer.getChannelData(1)
    i = from
    k = 0
    while k < length
      left[k] = ((memory.u8[i] << 8 | memory.u8[i + 1]) << 16 >> 16) * PI_2_400
      right[k] = ((memory.u8[i + 2] << 8 | memory.u8[i + 3]) << 16 >> 16) * PI_2_400
      i += 4
      k++
    source.buffer = audioBuffer
    @startTime += audioBuffer.duration
    source.connect audioContext.destination
    source.loop = false
    source.noteOn @startTime
    return true

#hack global space until we export classes properly
#node.js uses exports; browser uses this (window)
root = exports ? self
root.C1964jsAudio = C1964jsAudio