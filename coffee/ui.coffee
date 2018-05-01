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
#todo: refactor ui.coffee to remove @ globals.

g_settings = undefined
reader = undefined
@progress = document.querySelector(".percent")
alertMessage = ""
unless self.File
  alertMessage += " self.File"
else unless self.FileReader
  alertMessage += " self.FileReader"
else unless self.FileList
  alertMessage += " self.FileList"
else alertMessge += " self.Blob"  unless self.Blob
log "Unsupported in this browser: " + alertMessage  if alertMessage.length > 0
@i1964js = undefined

showValue = (newValue) ->
  document.getElementById("range").innerHTML = newValue
  c = document.getElementById("DebugCanvas")
  ctx = c.getContext("2d")
  repaint ctx, ImDat2, newValue | 0  if ImDat2
  return

# Read a page's GET URL variables and return them as an associative array.
getUrlVars = ->
  vars = []
  hash = undefined
  hashes = self.location.href.slice(self.location.href.indexOf("?") + 1).split("&")
  i = 0
  while i < hashes.length
    hash = hashes[i].split("=")
    vars.push hash[0]
    vars[hash[0]] = unescape(hash[1])
    i++
  vars

initTryCatch = (buffer) ->
  try
    #cleanup old compiled code on page if exists
    if @i1964js isnt `undefined` and @i1964js?
      @i1964js.stopEmulatorAndCleanup()

    @i1964js = new C1964jsEmulator g_settings, buffer
    @i1964js.startEmulator()
  catch e
    if @i1964js isnt `undefined` and @i1964js?
      @i1964js.terminate = true
    throw e
  return

uncompressAndRun = (romPath, response) ->
  if romPath.split(".").pop().toLowerCase() isnt "zip"
    buffer = new Uint8Array(response)
    @romLength = buffer.byteLength
    initTryCatch buffer
  else
    #This zip library seems to only work if there is one file in the root of the zip's filesystem.
    #Compressing with MacOS causes problems.
    unzipper = new bitjs.archive.Unzipper(response, "lib/bitjs/")
    unzipper.addEventListener bitjs.archive.UnarchiveEvent.Type.EXTRACT, (e) ->
      if e.unarchivedFile
        console.log "extracted: " + e.unarchivedFile.filename
        buffer = new Uint8Array(e.unarchivedFile.fileData)
        @romLength = buffer.byteLength
        initTryCatch buffer
    unzipper.addEventListener bitjs.archive.UnarchiveEvent.Type.INFO, (e) ->
      console.log "zip info: " + e.msg
    unzipper.addEventListener bitjs.archive.UnarchiveEvent.Type.PROGRESS, (e) ->
    #for (var i in e)
    #    console.log(i +': '+ e[i]);
    unzipper.addEventListener bitjs.archive.UnarchiveEvent.Type.FINISH, (e) ->
      console.log "finish: " + e.msg
    unzipper.addEventListener bitjs.archive.UnarchiveEvent.Type.ERROR, (e) ->
      console.log "ERROR: " + e.msg
    unzipper.start()
  return

@start1964 = (settings) ->
  g_settings = settings

  vars = getUrlVars()
  romPath = undefined
  i = 0
  while i < vars.length
    romPath = vars[vars[i]]  if vars[i] is "rom"
    i++
  if romPath isnt `undefined` and romPath?
    xhr = new XMLHttpRequest()
    xhr.open "GET", romPath, true
    xhr.responseType = "arraybuffer"
    xhr.send()
    xhr.onload = (e) =>
      # hide the user panel
      hideUserPanel()
      uncompressAndRun romPath, e.target.response
  else
    showUserPanel()
  return

#Check for the various File API support.
abortRead = ->
  reader.abort()
  return

#don't fade out if one of the child divs makes caused this event.
#if ((event.relatedTarget || event.toElement) == this.parentNode)
#don't fade out if one of the child divs makes caused this event.
#if ((event.relatedTarget || event.toElement) == this.parentNode)
toggleUi = ->
  el = document.getElementById("user_panel")
  if el.className is ""
    el.className = "show_fast"
  else
    el.className = ""
  return

errorHandler = (evt) ->
  switch evt.target.error.code
    when evt.target.error.NOT_FOUND_ERR
      alert "File Not Found!"
    when evt.target.error.NOT_READABLE_ERR
      alert "File is not readable"
    when evt.target.error.ABORT_ERR
    # noop
    else
      alert "An error occurred reading this file."
  return

updateProgress = (evt) ->
  # evt is a ProgressEvent.
  if evt.lengthComputable
    percentLoaded = Math.round((evt.loaded / evt.total) * 100)
    # Increase the progress bar length.
    if percentLoaded < 100
      unless @progress is `undefined`
        @progress.style.width = percentLoaded + "%"
        @progress.textContent = percentLoaded + "%"
  return

handleFileSelect = (evt) ->
  if (evt.target.files == undefined || evt.target.files[0] == undefined)
    return
  fileName = evt.target.files[0].name
  @progressBar = document.getElementById("progress_bar")

  # Reset progress indicator on new file selection.
  unless @progress is `undefined`
    @progress.style.width = "0%"
    @progress.textContent = "0%"
  reader = new FileReader()
  reader.onerror = errorHandler
  reader.onprogress = updateProgress
  reader.onabort = (e) ->
    alert "File read cancelled"
    return

  reader.onloadstart = (e) ->
    document.getElementById("progress_bar").className = "loading"  unless @progressBar is `undefined`
    return

  reader.onload = (e) ->
    # Ensure that the progress bar displays 100% at the end.
    unless @progress is `undefined`
      @progress.style.width = "100%"
      @progress.textContent = "100%"
    #setTimeout "document.getElementById('progress_bar').className='';document.getElementById('user_panel').className='';", 1000  unless @progressBar is `undefined`
    setTimeout "document.getElementById('files').disabled = true;document.getElementById('user_panel').className='';", 1000
    uncompressAndRun fileName, reader.result
    return

  # Read in the file as an array buffer.
  reader.readAsArrayBuffer evt.target.files[0]
  return

document.getElementById("user_panel").ontouchend = (event) ->
  showUserPanel()

showUserPanel = () ->
  document.getElementById("user_panel").className = "show"
  self.startGradientBackground()

hideUserPanel = () ->
  document.getElementById("user_panel").className = ""
  #disable the animating background
  self.stopGradientBackground()

document.onmouseup = (event) ->

  if event.target.className is "dropbtn" or event.target.className is "file"
    # disallow hiding if presssing the dropdown
    event.cancelBubble = true
    event.stopPropagation() if event.stopPropagation
    return

  if document.getElementById("user_panel").className is "" 
    showUserPanel()
  else if document.getElementById("user_panel").className is "show"
    hideUserPanel()

document.ontouchend = (event) ->
  if event.target.className is "dropbtn" or event.target.className is "file"
    # disallow hiding if presssing the dropdown
    event.cancelBubble = true
    event.stopPropagation() if event.stopPropagation
    return

  if document.getElementById("user_panel").className is "" 
    showUserPanel()
  else if document.getElementById("user_panel").className is "show"
    hideUserPanel()

document.getElementById("files").addEventListener "change", handleFileSelect, false
