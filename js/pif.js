/*
1964js - JavaScript/HTML5 port of 1964 - N64 emulator
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
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/

var controlsPresent = new Array(4);
controlsPresent[0] = true;
controlsPresent[1] = false;
controlsPresent[2] = false;
controlsPresent[3] = false;
var buttons = 0x00000000;

function processPif()
{
    var pifRamStart = MEMORY_START_PIF_RAM - MEMORY_START_PIF;
    var count = 0;
    var device = 0;

    //todo: pif ram decryption

    if ((pifUint8Array[pifRamStart] === 0xff)
    && (pifUint8Array[pifRamStart+1] === 0xff)
    && (pifUint8Array[pifRamStart+2] === 0xff)
    && (pifUint8Array[pifRamStart+3] === 0xff))
        throw 'todo: decrypt'; //see iPif.cpp. the first 4 dwords will be -1, not just the first 4 bytes. Make pifUint32Array and use it 4 times.

    while (count++ < 64)
    {
        var cmd = pifUint8Array[pifRamStart+count];
        
        if (cmd === 0xFE) //Command block ready
            break;

        else if (cmd === 0xFF || cmd === 0xFD //no-op commands (0xFD is from Command & Conquer)
            || cmd === 0xB4 || cmd === 0x56 || cmd === 0xB8) //Unknown
            continue;

        else if (cmd === 0) //Next device
        {
            device++;
            continue;
        }

        else if (device === 4) //EEprom
            throw 'todo: handle eeprom command';

        else if (device < 4) //Controllers 0-3
        {
            if (processController(count, device, pifRamStart) === false)
                break;
                
            device++;
            //size of Command-Bytes + size of Answer-Bytes + 2 for the 2 size Bytes (1 is in count++)
            count += cmd + (pifUint8Array[pifRamStart+count+1] & 0x3F) + 1;
        }
        else
        {
            log('Device > 4. Device = ' + device);
            break;
        }
    }
    
    pifUint8Array[pifRamStart+63] = 0; //Set the last bit to 0 (successful return)
}
/*
//Button masks
var R_PAD = 0x00800000
var L_PAD = 0x00400000
var D_PAD = 0x00200000
var U_PAD = 0x00100000
var START_BUTTON = 0x00080000
var Z_TRIG = 0x00040000
var B_BUTTON = 0x00020000
var A_BUTTON = 0x00010000
var R_CBUTTON = 0x80000000
var L_CBUTTON = 0x40000000
var D_CBUTTON = 0x20000000
var U_CBUTTON = 0x10000000
var R_TRIG = 0x08000000
var L_TRIG = 0x04000000
var RESERVED1 = 0x02000000
var RESERVED2 = 0x01000000
var Y_AXIS = 0x000000FF
var X_AXIS = 0x0000FF00
*/

//reordered

var R_PAD = 0x00010000
var L_PAD = 0x00020000
var D_PAD = 0x00040000
var U_PAD = 0x00080000
var START_BUTTON = 0x00100000
var Z_TRIG = 0x00200000
var B_BUTTON = 0x00400000
var A_BUTTON = 0x00800000
var R_CBUTTON = 0x01000000
var L_CBUTTON = 0x02000000
var D_CBUTTON = 0x04000000
var U_CBUTTON = 0x08000000
var R_TRIG = 0x10000000
var L_TRIG = 0x20000000
var RESERVED1 = 0x40000000
var RESERVED2 = 0x80000000
var Y_AXIS = 0x000000FF
var X_AXIS = 0x0000FF00


var LEFT_MAX = 0x000008000
var RIGHT_MAX = 0x00007F00
var UP_MAX = 0x00000007F
var DOWN_MAX = 0x00000080

function processController(count, device, pifRamStart)
{
    if (controlsPresent[device] === false)
    {
        pifUint8Array[pifRamStart+count+1] |= 0x80;
        pifUint8Array[pifRamStart+count+3] = 0;
        pifUint8Array[pifRamStart+count+4] = 0;
        pifUint8Array[pifRamStart+count+5] = 0;
        return true;     
    }

    var cmd = pifUint8Array[pifRamStart+count+2];

    switch (cmd)
    {
        case 0xFF: //0xFF could be something like Reset Controller and return the status
        case 0: //0x00 return the status
            pifUint8Array[pifRamStart+count+3] = 5; //For Adaptoid
            pifUint8Array[pifRamStart+count+4] = 0; //For Adaptoid
            //todo: mempak, sram, eeprom save save & rumblepak
            pifUint8Array[pifRamStart+count+5] = 0; //no mempak (For Adaptoid)
        break;

        case 1: 
            var buttons = readControllerData();
            pifUint8Array[pifRamStart+count+3] = buttons >> 24;
            pifUint8Array[pifRamStart+count+4] = buttons >> 16;
            pifUint8Array[pifRamStart+count+5] = buttons >> 8;
            pifUint8Array[pifRamStart+count+6] = buttons;
        break;

        case 2:
        case 3:
            log('todo: read/write controller pak');
        return false;
        break;

        default:
            log('unknown controller command: ' + cmd);
        break;
    }

    return true;
}

function readControllerData()
{
    return buttons;
}

//move to canvas
window.onkeydown = keydown;
window.onkeyup = keyup;

function keydown(e) {
    var keyCode;
    
    if (e)
    {
        keyCode = e.which;

        if (keyCode === 40)
            buttons = (buttons & 0xffff00ff) | DOWN_MAX;
        else if (keyCode === 38)
            buttons = (buttons & 0xffff00ff) | UP_MAX;
        else if (keyCode === 39)
            buttons = (buttons & 0xffffff00) | RIGHT_MAX;
        else if (keyCode === 37)
            buttons = (buttons & 0xffffff00) | LEFT_MAX;
        else if (keyCode === 13)
            buttons |= 0xffffffff;
        else if (keyCode === 90) //z
            buttons |= A_BUTTON;
        else if (keyCode === 83) //s
            buttons |= D_PAD; 
        else if (keyCode === 87) //w
            buttons |= U_PAD;
        else if (keyCode === 68) //d
            buttons |= R_PAD;
        else if (keyCode === 65) //a
            buttons |= L_PAD;
        else if (keyCode === 88) //x
            buttons |= B_BUTTON;
        else if (keyCode === 73) //i
            buttons |= U_CBUTTON;
        else if (keyCode === 74) //j
            buttons |= L_CBUTTON;
        else if (keyCode === 75) //k
            buttons |= D_CBUTTON;
        else if (keyCode === 76) //l
            buttons |= R_CBUTTON;
        else if (keyCode === 32) //space
            buttons |= Z_TRIG;
        else if (keyCode === 49) //1
            buttons |= L_TRIG;
        else if (keyCode === 48) //2
            buttons |= R_TRIG;
    }
}

function keyup(e)
{
    var keyCode;
    
    if (e)
    {
        keyCode = e.which;

        if (keyCode === 40)
            buttons &= ~DOWN_MAX;
        else if (keyCode === 38)
            buttons &= ~UP_MAX;
        else if (keyCode === 39)
            buttons &= ~RIGHT_MAX;
        else if (keyCode === 37)
            buttons &= ~LEFT_MAX;
        else if (keyCode === 13)
            buttons = 0;
        else if (keyCode === 90) //z
            buttons &= ~A_BUTTON;
        else if (keyCode === 83) //s
            buttons &= ~D_PAD; 
        else if (keyCode === 87) //w
            buttons &= ~U_PAD;
        else if (keyCode === 68) //d
            buttons &= ~R_PAD;
        else if (keyCode === 65) //a
            buttons &= ~L_PAD;
        else if (keyCode === 88) //x
            buttons &= ~B_BUTTON;
        else if (keyCode === 73) //i
            buttons &= ~U_CBUTTON;
        else if (keyCode === 74) //j
            buttons &= ~L_CBUTTON;
        else if (keyCode === 75) //k
            buttons &= ~D_CBUTTON;
        else if (keyCode === 76) //l
            buttons &= ~R_CBUTTON;
        else if (keyCode === 32) //space
            buttons &= ~Z_TRIG;
        else if (keyCode === 49) //1
            buttons &= ~L_TRIG;
        else if (keyCode === 48) //2
            buttons &= ~R_TRIG;
    }
}