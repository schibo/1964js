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

C1964jsEmulator::flushDynaCache = ->
  "use strict"
  pc = undefined
  while @kk
    @kk -= 1
    @deleteFunction @kk
  @fnLut = new Map()
  return

#must not use strict here.
C1964jsEmulator::deleteFunction = (k) ->

  #log('cleanup');
  fnName = undefined
  splitResult = undefined
  s = document.getElementsByTagName("script")[k]
  splitResult = s.text.split("_")
  splitResult = splitResult[1].split("=")
  fnName = "_" + splitResult[0]
  s.parentNode.removeChild s

  #allow deletion of this function
  eval "if (typeof " + fnName + " !== 'undefined') delete " + fnName + ";"
  self[fnName] = undefined
  alert "self[fnName] should have been null."  if self[fnName]
  return