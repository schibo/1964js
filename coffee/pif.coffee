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
"use strict"
class C1964jsPif
  constructor: (pifUint8Array) ->
    @pifUint8Array = pifUint8Array
    @EEProm_Status_Byte = 0
    @controlsPresent = new Array(4)
    @controlsPresent[0] = true
    @controlsPresent[1] = false
    @controlsPresent[2] = false
    @controlsPresent[3] = false
    @g1964buttons = 0x00000000 #todo: don't depend on global buttons!
    window.onkeydown = this.onKeyDown.bind(this)
    window.onkeyup = this.onKeyUp.bind(this)

  processPif: ->
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

  processEeprom: (pifRamStart, count) ->
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

  processController: (count, device, pifRamStart) ->
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

  readControllerData: ->
    @g1964buttons

#hack global space until we export classes properly
#node.js uses exports; browser uses this (window)
root = exports ? this
root.C1964jsPif = C1964jsPif
