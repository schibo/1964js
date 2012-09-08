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

var _1964buttons = 0x00000000; //todo: don't depend on global buttons!

var C1964jsPif = function (pifUint8Array) {
    "use strict";

    this.pifUint8Array = pifUint8Array;
    this.EEProm_Status_Byte = 0;
    this.controlsPresent = new Array(4);
    this.controlsPresent[0] = true;
    this.controlsPresent[1] = false;
    this.controlsPresent[2] = false;
    this.controlsPresent[3] = false;
};

(function () {
    "use strict";

    C1964jsPif.prototype.processPif = function () {
        var pifRamStart = consts.MEMORY_START_PIF_RAM - consts.MEMORY_START_PIF;
        var count = 0;
        var device = 0;

        //todo: pif ram decryption

        if ((this.pifUint8Array[pifRamStart] === 0xff)
        && (this.pifUint8Array[pifRamStart+1] === 0xff)
        && (this.pifUint8Array[pifRamStart+2] === 0xff)
        && (this.pifUint8Array[pifRamStart+3] === 0xff))
            throw 'todo: decrypt'; //see iPif.cpp. the first 4 dwords will be -1, not just the first 4 bytes. Make pifUint32Array and use it 4 times.

        for (count=0; count<64; count++) {
            var cmd = this.pifUint8Array[pifRamStart+count];
            
            if (cmd === 0xFE) //Command block ready
                break;
            else if (cmd === 0xFF || cmd === 0xFD //no-op commands (0xFD is from Command & Conquer)
                || cmd === 0xB4 || cmd === 0x56 || cmd === 0xB8) //Unknown
                continue;
            else if (cmd === 0) { //Next device
                device++;
                continue;
            } else if (device === 4) { //EEprom
                this.processEeprom(pifRamStart, count);
                break;
            } else if (device < 4) { //Controllers 0-3
                if (this.processController(count, device, pifRamStart) === false)
                    break;

                device++;
                //size of Command-Bytes + size of Answer-Bytes + 2 for the 2 size Bytes (1 is in count++)
                count += cmd + (this.pifUint8Array[pifRamStart+count+1] & 0x3F) + 1;
            } else {
                log('Device > 4. Device = ' + device);
                break;
            }
        }

        this.pifUint8Array[pifRamStart+63] = 0; //Set the last bit to 0 (successful return)
    };

    C1964jsPif.prototype.processEeprom = function (pifRamStart, count) {
    	switch(this.pifUint8Array[pifRamStart+count+2]) {
    	case 0xFF:
    	case 0x00:
    		this.pifUint8Array[pifRamStart+count+3] = 0x00;
    		this.pifUint8Array[pifRamStart+count+4] = this.EEProm_Status_Byte;
    		this.pifUint8Array[pifRamStart+count+5] = 0x00;
    		break;
    	case 0x04: //Read from Eeprom 
            alert('read eeprom');
    		//this.readEEprom(&cmd[4], cmd[3] * 8);
    		break;
    	case 0x05: 	//Write to Eeprom
            alert('write eeprom');
    		//this.writeEEprom((char*)&cmd[4], cmd[3] * 8);
    		break;

    	default:
    		break;
    	}

    	return false;
    };

    C1964jsPif.prototype.processController = function (count, device, pifRamStart) {
        if (this.controlsPresent[device] === false) {
            this.pifUint8Array[pifRamStart+count+1] |= 0x80;
            this.pifUint8Array[pifRamStart+count+3] = 0;
            this.pifUint8Array[pifRamStart+count+4] = 0;
            this.pifUint8Array[pifRamStart+count+5] = 0;
            return true;     
        }

        var cmd = this.pifUint8Array[pifRamStart+count+2];

        switch (cmd) {
            case 0xFF: //0xFF could be something like Reset Controller and return the status
            case 0: //0x00 return the status
                this.pifUint8Array[pifRamStart+count+3] = 5; //For Adaptoid
                this.pifUint8Array[pifRamStart+count+4] = 0; //For Adaptoid
                //todo: mempak, sram, eeprom save save & rumblepak
                this.pifUint8Array[pifRamStart+count+5] = 0; //no mempak (For Adaptoid)
            break;

            case 1: 
                var buttons = this.readControllerData();
                this.pifUint8Array[pifRamStart+count+3] = buttons >> 24;
                this.pifUint8Array[pifRamStart+count+4] = buttons >> 16;
                this.pifUint8Array[pifRamStart+count+5] = buttons >> 8;
                this.pifUint8Array[pifRamStart+count+6] = buttons;
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
    };

    C1964jsPif.prototype.readControllerData = function () {
        return _1964buttons;
    };
}());

//keyboard event handlers
(function () {
    "use strict";

    //reordered
    var R_PAD = 0x00010000;
    var L_PAD = 0x00020000;
    var D_PAD = 0x00040000;
    var U_PAD = 0x00080000;
    var START_BUTTON = 0x10000000;
    var Z_TRIG = 0x00200000;
    var B_BUTTON = 0x00400000;
    var A_BUTTON = 0x00800000;
    var R_CBUTTON = 0x01000000;
    var L_CBUTTON = 0x02000000;
    var D_CBUTTON = 0x04000000;
    var U_CBUTTON = 0x08000000;
    var R_TRIG = 0x80000000 | 0;
    var L_TRIG = 0x20000000;
    var Y_AXIS = 0x000000FF;
    var X_AXIS = 0x0000FF00;
    var LEFT_MAX = 0x000008000;
    var RIGHT_MAX = 0x00007F00;
    var UP_MAX = 0x00000007F;
    var DOWN_MAX = 0x00000080;

    window.onkeydown = function (e) {
        var keyCode;

        if (e) {
            keyCode = e.which;

            if (keyCode === 40)
                _1964buttons = (_1964buttons & 0xffff00ff) | DOWN_MAX;
            else if (keyCode === 38)
                _1964buttons = (_1964buttons & 0xffff00ff) | UP_MAX;
            else if (keyCode === 39)
                _1964buttons = (_1964buttons & 0xffffff00) | RIGHT_MAX;
            else if (keyCode === 37)
                _1964buttons = (_1964buttons & 0xffffff00) | LEFT_MAX;
            else if (keyCode === 13)
                _1964buttons |= START_BUTTON;
            else if (keyCode === 90) //z
                _1964buttons |= A_BUTTON;
            else if (keyCode === 83) //s
                _1964buttons |= D_PAD; 
            else if (keyCode === 87) //w
                _1964buttons |= U_PAD;
            else if (keyCode === 68) //d
                _1964buttons |= R_PAD;
            else if (keyCode === 65) //a
                _1964buttons |= L_PAD;
            else if (keyCode === 88) //x
                _1964buttons |= B_BUTTON;
            else if (keyCode === 73) //i
                _1964buttons |= U_CBUTTON;
            else if (keyCode === 74) //j
                _1964buttons |= L_CBUTTON;
            else if (keyCode === 75) //k
                _1964buttons |= D_CBUTTON;
            else if (keyCode === 76) //l
                _1964buttons |= R_CBUTTON;
            else if (keyCode === 32) //space
                _1964buttons |= Z_TRIG;
            else if (keyCode === 49) //1
                _1964buttons |= L_TRIG;
            else if (keyCode === 48) //0
                _1964buttons |= R_TRIG;
        }
    };

    window.onkeyup = function (e) {
        var keyCode;
        
        if (e) {
            keyCode = e.which;

            if (keyCode === 40)
                _1964buttons &= ~DOWN_MAX;
            else if (keyCode === 38)
                _1964buttons &= ~UP_MAX;
            else if (keyCode === 39)
                _1964buttons &= ~RIGHT_MAX;
            else if (keyCode === 37)
                _1964buttons &= ~LEFT_MAX;
            else if (keyCode === 13)
                _1964buttons &= ~START_BUTTON;
            else if (keyCode === 90) //z
                _1964buttons &= ~A_BUTTON;
            else if (keyCode === 83) //s
                _1964buttons &= ~D_PAD; 
            else if (keyCode === 87) //w
                _1964buttons &= ~U_PAD;
            else if (keyCode === 68) //d
                _1964buttons &= ~R_PAD;
            else if (keyCode === 65) //a
                _1964buttons &= ~L_PAD;
            else if (keyCode === 88) //x
                _1964buttons &= ~B_BUTTON;
            else if (keyCode === 73) //i
                _1964buttons &= ~U_CBUTTON;
            else if (keyCode === 74) //j
                _1964buttons &= ~L_CBUTTON;
            else if (keyCode === 75) //k
                _1964buttons &= ~D_CBUTTON;
            else if (keyCode === 76) //l
                _1964buttons &= ~R_CBUTTON;
            else if (keyCode === 32) //space
                _1964buttons &= ~Z_TRIG;
            else if (keyCode === 49) //1
                _1964buttons &= ~L_TRIG;
            else if (keyCode === 48) //2
                _1964buttons &= ~R_TRIG;
        }
    };
}());
