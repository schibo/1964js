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
###globals C1964jsEmulator###
C1964jsEmulator::getTVSystem = (countryCode) ->
  "use strict"
  system = undefined
  switch countryCode
    when 0 # Demo
      system = @TV_SYSTEM_NTSC
    when 0x37 # '7'
      system = @TV_SYSTEM_NTSC
    when 0x41
      system = @TV_SYSTEM_NTSC
    when 0x44 # 'D' Germany
      system = @TV_SYSTEM_PAL
    when 0x45 #'E' United States
      system = @TV_SYSTEM_NTSC
    when 0x46 # 'F' France
      system = @TV_SYSTEM_PAL
    when "I" # 'I' Italy
      system = @TV_SYSTEM_PAL
    when 0x4A # 'J' Japan
      system = @TV_SYSTEM_NTSC
    when 0x50 # 'P' Europe
      system = @TV_SYSTEM_PAL
    when 0x53 #'S' Spain
      system = @TV_SYSTEM_PAL
    when 0x55 # 'U' Australia
      system = @TV_SYSTEM_PAL
    when 0x58 # 'X'
      system = @TV_SYSTEM_PAL
    when 0x59 # 'Y' Australia
      system = @TV_SYSTEM_PAL
    when 0x20, 0x21, 0x38, 0x70
      system = @TV_SYSTEM_PAL
    else
      system = @TV_SYSTEM_PAL
  system

C1964jsEmulator::getBootCode = ->
  "use strict"
  i = undefined
  cic = 0
  CIC_CRC = 0
  i = 0
  bootCode = {}
  while i < 0xFC0
    CIC_CRC = CIC_CRC + @memory.romUint8Array[0x40 + i]
    i += 1
  switch CIC_CRC
    #CIC-NUS-6101 (starfox)
    when 0x33a27, 0x3421e
      @log "Using CIC-NUS-6101 for starfox\n"
      bootCode.cic = 0x3f
      bootCode.rdramSizeAddress = 0x318
    when 0x34044 #CIC-NUS-6102 (mario)
      @log "Using CIC-NUS-6102 for mario\n"
      bootCode.cic = 0x3f
      bootCode.rdramSizeAddress = 0x318
    when 0x357d0 #CIC-NUS-6103 (Banjo)
      @log "Using CIC-NUS-6103 for Banjo\n"
      bootCode.cic = 0x78
      bootCode.rdramSizeAddress = 0x318
    when 0x47a81 #CIC-NUS-6105 (Zelda)
      @log "Using CIC-NUS-6105 for Zelda\n"
      bootCode.cic = 0x91
      bootCode.rdramSizeAddress = 0x3F0
    when 0x371cc #CIC-NUS-6106 (F-Zero X)
      @log "Using CIC-NUS-6106 for F-Zero/Yoshi Story\n"
      bootCode.cic = 0x85
      bootCode.rdramSizeAddress = 0x318
    when 0x343c9 #F1 World Grand Prix
      @log "Using Boot Code for F1 World Grand Prix\n"
      bootCode.cic = 0x85
      bootCode.rdramSizeAddress = 0x3F0
    else
      @log "Unknown boot code, using Mario boot code instead"
      bootCode.cic = 0x3f
      bootCode.rdramSizeAddress = 0x318
  
  # Init_VI_Counter(game_country_tvsystem);
  bootCode