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

#keyboard event handlers
"use strict"

#reordered
`const R_PAD = 0x00010000`
`const L_PAD = 0x00020000`
`const D_PAD = 0x00040000`
`const U_PAD = 0x00080000`
`const START_BUTTON = 0x10000000`
`const UNKNOWN_BUTTON = 0x00200000`
`const R_TRIG = 0x00400000`
`const L_TRIG = 0x00800000`
`const R_CBUTTON = 0x01000000`
`const L_CBUTTON = 0x02000000`
`const D_CBUTTON = 0x04000000`
`const U_CBUTTON = 0x08000000`
`const A_BUTTON = 0x80000000 | 0`
`const B_BUTTON = 0x40000000`
`const Z_TRIG = 0x20000000`
`const Y_AXIS = 0x000000FF`
`const X_AXIS = 0x0000FF00`
`const LEFT_MAX = 0x000008000`
`const RIGHT_MAX = 0x00007F00`
`const UP_MAX = 0x00000007F`
`const DOWN_MAX = 0x00000080`

C1964jsPif::onKeyDown = (e) ->
  if e
    switch e.which
      when 40
        @g1964buttons = (@g1964buttons & 0xffffff00) | DOWN_MAX
      when 38
        @g1964buttons = (@g1964buttons & 0xffffff00) | UP_MAX
      when 39
        @g1964buttons = (@g1964buttons & 0xffff00ff) | RIGHT_MAX
      when 37
        @g1964buttons = (@g1964buttons & 0xffff00ff) | LEFT_MAX
      when 13
        @g1964buttons |= START_BUTTON
      when 90 #z
        @g1964buttons |= A_BUTTON
      when 83 #s
        @g1964buttons |= D_PAD
      when 87 #w
        @g1964buttons |= U_PAD
      when 68 #d
        @g1964buttons |= R_PAD
      when 65 #a
        @g1964buttons |= L_PAD
      when 88 #x
        @g1964buttons |= B_BUTTON
      when 73 #i
        @g1964buttons |= U_CBUTTON
      when 74 #j
        @g1964buttons |= L_CBUTTON
      when 75 #k
        @g1964buttons |= D_CBUTTON
      when 76 #l
        @g1964buttons |= R_CBUTTON
      when 32 #space
        @g1964buttons |= Z_TRIG
      when 49 #1
        @g1964buttons |= L_TRIG
      when 48 #0
        @g1964buttons |= R_TRIG
  return

C1964jsPif::onKeyUp = (e) ->
  if e
    switch e.which
      when 40
        @g1964buttons &= ~DOWN_MAX
      when 38
        @g1964buttons &= ~UP_MAX
      when 39
        @g1964buttons &= ~RIGHT_MAX
      when 37
        @g1964buttons &= ~LEFT_MAX
      when 13
        @g1964buttons &= ~START_BUTTON
      when 90 #z
        @g1964buttons &= ~A_BUTTON
      when 83 #s
        @g1964buttons &= ~D_PAD
      when 87 #w
        @g1964buttons &= ~U_PAD
      when 68 #d
        @g1964buttons &= ~R_PAD
      when 65 #a
        @g1964buttons &= ~L_PAD
      when 88 #x
        @g1964buttons &= ~B_BUTTON
      when 73 #i
        @g1964buttons &= ~U_CBUTTON
      when 74 #j
        @g1964buttons &= ~L_CBUTTON
      when 75 #k
        @g1964buttons &= ~D_CBUTTON
      when 76 #l
        @g1964buttons &= ~R_CBUTTON
      when 32 #space
        @g1964buttons &= ~Z_TRIG
      when 49 #1
        @g1964buttons &= ~L_TRIG
      when 48 #2
        @g1964buttons &= ~R_TRIG
      when 27 #escape
        toggleUi()
  return