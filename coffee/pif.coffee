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
#jslint todo: true, bitwise: true, devel: true, browser: true
#globals consts, log
g1964buttons = 0x00000000 #todo: don't depend on global buttons!
C1964jsPif = (pifUint8Array) ->
  "use strict"
  @pifUint8Array = pifUint8Array
  @EEProm_Status_Byte = 0
  @controlsPresent = new Array(4)
  @controlsPresent[0] = true
  @controlsPresent[1] = false
  @controlsPresent[2] = false
  @controlsPresent[3] = false
  return this

(->
  "use strict"
  C1964jsPif::processPif = ->
    cmd = undefined
    device = 0
    count = 0
    pifRamStart = consts.MEMORY_START_PIF_RAM - consts.MEMORY_START_PIF
    
    #todo: pif ram decryption
    throw Error "todo: decrypt"  if (@pifUint8Array[pifRamStart] is 0xff) and (@pifUint8Array[pifRamStart + 1] is 0xff) and (@pifUint8Array[pifRamStart + 2] is 0xff) and (@pifUint8Array[pifRamStart + 3] is 0xff) #see iPif.cpp. the first 4 dwords will be -1, not just the first 4 bytes. Make pifUint32Array and use it 4 times.
    count = 0
    while count < 64
      cmd = @pifUint8Array[pifRamStart + count]
      if cmd is 0xFE #Command block ready
        break
      #no-op commands (0xFD is from Command & Conquer)
      else if cmd isnt 0xFF and cmd isnt 0xFD and cmd isnt 0xB4 and cmd isnt 0x56 and cmd isnt 0xB8 #Unknown
        if cmd is 0 #Next device
          device += 1
        else if device is 4 #EEprom
          @processEeprom pifRamStart, count
          break
        else if device < 4 #Controllers 0-3
          break  if @processController(count, device, pifRamStart) is false
          device += 1
          
          #size of Command-Bytes + size of Answer-Bytes + 2 for the 2 size Bytes (1 is in count++)
          count += cmd + (@pifUint8Array[pifRamStart + count + 1] & 0x3F) + 1
        else
          log "Device > 4. Device = " + device
          break
      count += 1
    @pifUint8Array[pifRamStart + 63] = 0 #Set the last bit to 0 (successful return)
    return

  C1964jsPif::processEeprom = (pifRamStart, count) ->
    switch @pifUint8Array[pifRamStart + count + 2]
      when 0xFF, 0x00
        @pifUint8Array[pifRamStart + count + 3] = 0x00
        @pifUint8Array[pifRamStart + count + 4] = @EEProm_Status_Byte
        @pifUint8Array[pifRamStart + count + 5] = 0x00
      when 0x04 #Read from Eeprom
        alert "read eeprom"
      #this.readEEprom(&cmd[4], cmd[3] * 8);
      when 0x05 #Write to Eeprom
        alert "write eeprom"
      #this.writeEEprom((char*)&cmd[4], cmd[3] * 8);
      else
    false

  C1964jsPif::processController = (count, device, pifRamStart) ->
    if @controlsPresent[device] is false
      @pifUint8Array[pifRamStart + count + 1] |= 0x80
      @pifUint8Array[pifRamStart + count + 3] = 0
      @pifUint8Array[pifRamStart + count + 4] = 0
      @pifUint8Array[pifRamStart + count + 5] = 0
      return true
    buttons = undefined
    cmd = @pifUint8Array[pifRamStart + count + 2]
    switch cmd
      #0xFF could be something like Reset Controller and return the status
      when 0xFF, 0 #0x00 return the status
        @pifUint8Array[pifRamStart + count + 3] = 5 #For Adaptoid
        @pifUint8Array[pifRamStart + count + 4] = 0 #For Adaptoid
        #todo: mempak, sram, eeprom save save & rumblepak
        @pifUint8Array[pifRamStart + count + 5] = 0 #no mempak (For Adaptoid)
      when 1
        buttons = @readControllerData()
        @pifUint8Array[pifRamStart + count + 3] = buttons >> 24
        @pifUint8Array[pifRamStart + count + 4] = buttons >> 16
        @pifUint8Array[pifRamStart + count + 5] = buttons >> 8
        @pifUint8Array[pifRamStart + count + 6] = buttons
      when 2, 3
        log "todo: read/write controller pak"
        return false
      else
        log "unknown controller command: " + cmd
    true

  C1964jsPif::readControllerData = ->
    g1964buttons
)()

#keyboard event handlers
(->
  "use strict"

  #reordered
  R_PAD = 0x00010000
  L_PAD = 0x00020000
  D_PAD = 0x00040000
  U_PAD = 0x00080000
  START_BUTTON = 0x10000000
  Z_TRIG = 0x00200000
  B_BUTTON = 0x00400000
  A_BUTTON = 0x00800000
  R_CBUTTON = 0x01000000
  L_CBUTTON = 0x02000000
  D_CBUTTON = 0x04000000
  U_CBUTTON = 0x08000000
  R_TRIG = 0x80000000 | 0
  L_TRIG = 0x20000000
  Y_AXIS = 0x000000FF
  X_AXIS = 0x0000FF00
  LEFT_MAX = 0x000008000
  RIGHT_MAX = 0x00007F00
  UP_MAX = 0x00000007F
  DOWN_MAX = 0x00000080
  window.onkeydown = (e) ->
    if e
      switch e.which
        when 40
          g1964buttons = (g1964buttons & 0xffff00ff) | DOWN_MAX
        when 38
          g1964buttons = (g1964buttons & 0xffff00ff) | UP_MAX
        when 39
          g1964buttons = (g1964buttons & 0xffffff00) | RIGHT_MAX
        when 37
          g1964buttons = (g1964buttons & 0xffffff00) | LEFT_MAX
        when 13
          g1964buttons |= START_BUTTON
        when 90 #z
          g1964buttons |= A_BUTTON
        when 83 #s
          g1964buttons |= D_PAD
        when 87 #w
          g1964buttons |= U_PAD
        when 68 #d
          g1964buttons |= R_PAD
        when 65 #a
          g1964buttons |= L_PAD
        when 88 #x
          g1964buttons |= B_BUTTON
        when 73 #i
          g1964buttons |= U_CBUTTON
        when 74 #j
          g1964buttons |= L_CBUTTON
        when 75 #k
          g1964buttons |= D_CBUTTON
        when 76 #l
          g1964buttons |= R_CBUTTON
        when 32 #space
          g1964buttons |= Z_TRIG
        when 49 #1
          g1964buttons |= L_TRIG
        when 48 #0
          g1964buttons |= R_TRIG
    return

  window.onkeyup = (e) ->
    if e
      switch e.which
        when 40
          g1964buttons &= ~DOWN_MAX
        when 38
          g1964buttons &= ~UP_MAX
        when 39
          g1964buttons &= ~RIGHT_MAX
        when 37
          g1964buttons &= ~LEFT_MAX
        when 13
          g1964buttons &= ~START_BUTTON
        when 90 #z
          g1964buttons &= ~A_BUTTON
        when 83 #s
          g1964buttons &= ~D_PAD
        when 87 #w
          g1964buttons &= ~U_PAD
        when 68 #d
          g1964buttons &= ~R_PAD
        when 65 #a
          g1964buttons &= ~L_PAD
        when 88 #x
          g1964buttons &= ~B_BUTTON
        when 73 #i
          g1964buttons &= ~U_CBUTTON
        when 74 #j
          g1964buttons &= ~L_CBUTTON
        when 75 #k
          g1964buttons &= ~D_CBUTTON
        when 76 #l
          g1964buttons &= ~R_CBUTTON
        when 32 #space
          g1964buttons &= ~Z_TRIG
        when 49 #1
          g1964buttons &= ~L_TRIG
        when 48 #2
          g1964buttons &= ~R_TRIG
        when 27 #escape
          toggleUi()
    return
)()
#hack global space until we export classes properly
#node.js uses exports; browser uses this (window)
root = exports ? this
root.C1964jsPif = C1964jsPif
