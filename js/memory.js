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
var _1964jsMemory = function(core) {

    this.romUint8Array; // set after rom is loaded.
    this.rom; // set after rom is loaded.
    this.rdramUint8Array = new Uint8Array(0x800000);
    this.spMemUint8Array = new Uint8Array(0x10000);
    this.spReg1Uint8Array = new Uint8Array(0x10000);
    this.spReg2Uint8Array = new Uint8Array(0x10000);
    this.dpcUint8Array = new Uint8Array(0x10000);
    this.dpsUint8Array = new Uint8Array(0x10000);
    this.miUint8Array = new Uint8Array(0x10000);
    this.viUint8Array = new Uint8Array(0x10000);
    this.aiUint8Array = new Uint8Array(0x10000);
    this.piUint8Array = new Uint8Array(0x10000);
    this.siUint8Array = new Uint8Array(0x10000);
    this.c2a1Uint8Array = new Uint8Array(0x10000);
    this.c1a1Uint8Array = new Uint8Array(0x10000);
    this.c2a2Uint8Array = new Uint8Array(0x10000);
    this.c1a3Uint8Array = new Uint8Array(0x10000);
    this.riUint8Array = new Uint8Array(0x10000);
    this.pifUint8Array = new Uint8Array(0x10000);
    this.gioUint8Array = new Uint8Array(0x10000);
    this.ramRegs0Uint8Array = new Uint8Array(0x10000);
    this.ramRegs4Uint8Array = new Uint8Array(0x10000);
    this.ramRegs8Uint8Array = new Uint8Array(0x10000);
    this.dummyReadWriteUint8Array = new Uint8Array(0x10000);

    //getInt32 and getUint32 are identical. they both return signed.
    this.getInt32 = function(sregion, uregion, off) {
        return uregion[off]<<24|uregion[off+1]<<16|uregion[off+2]<<8|uregion[off+3];
    }

    this.getUint32 = function(uregion, off) {
        return uregion[off]<<24|uregion[off+1]<<16|uregion[off+2]<<8|uregion[off+3];
    }

    this.setInt32 = function(uregion, off, val) {
        uregion[off]=val>>24;uregion[off+1]=val>>16;uregion[off+2]=val>>8;uregion[off+3]=val;
    }

    this.loadByte = function(addr) {
        if ((addr & 0xff000000) === 0x84000000)
            throw 'todo: mirrored load address';
        
        var a = addr & 0x1FFFFFFF;    
        
        if (a >= MEMORY_START_RDRAM && a < MEMORY_START_RDRAM + MEMORY_SIZE_RDRAM) {
            var off=a-MEMORY_START_RDRAM;
            return this.rdramUint8Array[off];
        } else if (a >= MEMORY_START_RAMREGS4 && a < MEMORY_START_RAMREGS4 + MEMORY_SIZE_RAMREGS4) {
            var off=a-MEMORY_START_RAMREGS4;
            return this.ramRegs4Uint8Array[off];
        } else if (a >= MEMORY_START_SPMEM && a < MEMORY_START_SPMEM + MEMORY_SIZE_SPMEM) {
            var off=a-MEMORY_START_SPMEM;
            return this.spMemUint8Array[off];        
        } else if (a >= MEMORY_START_SPREG_1 && a < MEMORY_START_SPREG_1 + MEMORY_SIZE_SPREG_1) {
            var off=a-MEMORY_START_SPREG_1;
            return core.interrupts.readSPReg1(off);
        } else if (a >= MEMORY_START_SPREG_2 && a < MEMORY_START_SPREG_2 + MEMORY_SIZE_SPREG_2) {
            var off=a-MEMORY_START_SPREG_2;
            return this.spReg2Uint8Array[off];        
        } else if (a >= MEMORY_START_DPC && a < MEMORY_START_DPC + MEMORY_SIZE_DPC) {
            var off=a-MEMORY_START_DPC;
            return this.dpcUint8Array[off];        
        } else if (a >= MEMORY_START_DPS && a < MEMORY_START_DPS + MEMORY_SIZE_DPS) {
            var off=a-MEMORY_START_DPS;
            return this.dpsUint8Array[off];        
        } else if (a >= MEMORY_START_MI && a < MEMORY_START_MI + MEMORY_SIZE_MI) {
            //alert('load mi:' + dec2hex(addr));
            var off=a-MEMORY_START_MI;
            return this.miUint8Array[off];        
        } else if (a >= MEMORY_START_VI && a < MEMORY_START_VI + MEMORY_SIZE_VI) {
            var off=a-MEMORY_START_VI;
            return core.interrupts.readVI(off);
        } else if (a >= MEMORY_START_AI && a < MEMORY_START_AI + MEMORY_SIZE_AI) {
            //alert('load ai:' + dec2hex(addr));
            var off=a-MEMORY_START_AI;
            return core.interrupts.readAI(off);
        } else if (a >= MEMORY_START_PI && a < MEMORY_START_PI + MEMORY_SIZE_PI) {
           // alert('load pi:' + dec2hex(addr));
            var off=a-MEMORY_START_PI;
            return this.piUint8Array[off];        
        } else if (a >= MEMORY_START_SI && a < MEMORY_START_SI + MEMORY_SIZE_SI) {
           // alert('load si');
            var off=a-MEMORY_START_SI;
            return core.interrupts.readSI(off);
        } else if (a >= MEMORY_START_C2A1 && a < MEMORY_START_C2A1 + MEMORY_SIZE_C2A1) {
            var off=a-MEMORY_START_C2A1;
            return this.c2a1Uint8Array[off];        
        } else if (a >= MEMORY_START_C1A1 && a < MEMORY_START_C1A1 + MEMORY_SIZE_C1A1) {
            var off=a-MEMORY_START_C1A1;
            return this.c1a1Uint8Array[off];        
        } else if (a >= MEMORY_START_C2A2 && a < MEMORY_START_C2A2 + MEMORY_SIZE_C2A2) {
            var off=a-MEMORY_START_C2A2;
            return this.c2a2Uint8Array[off];        
        } else if (a >= MEMORY_START_ROM_IMAGE && a < MEMORY_START_ROM_IMAGE + romLength) { //todo: could be a problem to use romLength
          //  alert('load rom');
            var off=a-MEMORY_START_ROM_IMAGE;
            return this.romUint8Array[off];        
        } else if (a >= MEMORY_START_C1A3 && a < MEMORY_START_C1A3 + MEMORY_SIZE_C1A3) {
            var off=a-MEMORY_START_C1A3;
            return this.c1a3Uint8Array[off];        
        } else if (a >= MEMORY_START_RI && a < MEMORY_START_RI + MEMORY_SIZE_RI) {
            var off=a-MEMORY_START_RI;
            return this.riUint8Array[off];        
        } else if(a >= MEMORY_START_PIF && a < MEMORY_START_PIF + MEMORY_SIZE_PIF) {
            var off=a-MEMORY_START_PIF;
            return this.pifUint8Array[off];        
    	} else if(a >= MEMORY_START_GIO && a < MEMORY_START_GIO + MEMORY_SIZE_GIO_REG) {
            var off=a-MEMORY_START_GIO;
            return this.gioUint8Array[off];        
    	} else if(a >= MEMORY_START_RAMREGS0 && a < MEMORY_START_RAMREGS0 + MEMORY_SIZE_RAMREGS0) {
            var off=a-MEMORY_START_RAMREGS0;
            return this.ramRegs0Uint8Array[off];        
    	} else if(a >= MEMORY_START_RAMREGS8 && a < MEMORY_START_RAMREGS8 + MEMORY_SIZE_RAMREGS8) {
            var off=a-MEMORY_START_RAMREGS8;
            return this.ramRegs8Uint8Array[off];        
    	} else {
            log( 'reading from invalid memory at ' + dec2hex(addr));
            //stopEmulator();
            var off=a&0x0000fffc;
            return this.dummyReadWriteUint8Array[off];        
    	}
    }

    this.loadHalf = function(addr) {
        if ((addr & 0xff000000) === 0x84000000)
            throw 'todo: mirrored load address';
        
        var a = addr & 0x1FFFFFFF;
        
        if (a >= MEMORY_START_RDRAM && a < MEMORY_START_RDRAM + MEMORY_SIZE_RDRAM) {
            var off=a-MEMORY_START_RDRAM;
            return this.rdramUint8Array[off]<<8 | this.rdramUint8Array[off+1];
        } else if (a >= MEMORY_START_RAMREGS4 && a < MEMORY_START_RAMREGS4 + MEMORY_SIZE_RAMREGS4) {
            var off=a-MEMORY_START_RAMREGS4;
            return this.ramRegs4Uint8Array[off]<<8 | this.ramRegs4Uint8Array[off+1];
        } else if (a >= MEMORY_START_SPMEM && a < MEMORY_START_SPMEM + MEMORY_SIZE_SPMEM) {
            var off=a-MEMORY_START_SPMEM;
            return this.spMemUint8Array[off]<<8 | this.spMemUint8Array[off+1];        
        } else if (a >= MEMORY_START_SPREG_1 && a < MEMORY_START_SPREG_1 + MEMORY_SIZE_SPREG_1) {
            var off=a-MEMORY_START_SPREG_1;
            return core.interrupts.readSPReg1(off);
        } else if (a >= MEMORY_START_SPREG_2 && a < MEMORY_START_SPREG_2 + MEMORY_SIZE_SPREG_2) {
            var off=a-MEMORY_START_SPREG_2;
            return this.spReg2Uint8Array[off]<<8 | this.spReg2Uint8Array[off+1];        
        } else if (a >= MEMORY_START_DPC && a < MEMORY_START_DPC + MEMORY_SIZE_DPC) {
            var off=a-MEMORY_START_DPC;
            return this.dpcUint8Array[off]<<8 | this.dpcUint8Array[off+1];        
        } else if (a >= MEMORY_START_DPS && a < MEMORY_START_DPS + MEMORY_SIZE_DPS) {
            var off=a-MEMORY_START_DPS;
            return this.dpsUint8Array[off]<<8 | this.dpsUint8Array[off+1];        
        } else if (a >= MEMORY_START_MI && a < MEMORY_START_MI + MEMORY_SIZE_MI) {
            //alert('load mi:' + dec2hex(addr));
            var off=a-MEMORY_START_MI;
            return this.miUint8Array[off]<<8 | this.miUint8Array[off+1];
        } else if (a >= MEMORY_START_VI && a < MEMORY_START_VI + MEMORY_SIZE_VI) {
            var off=a-MEMORY_START_VI;
            return core.interrupts.readVI(off);
        } else if (a >= MEMORY_START_AI && a < MEMORY_START_AI + MEMORY_SIZE_AI) {
            //alert('load ai:' + dec2hex(addr));
            var off=a-MEMORY_START_AI;
            return core.interrupts.readAI(off);
        } else if (a >= MEMORY_START_PI && a < MEMORY_START_PI + MEMORY_SIZE_PI) {
           // alert('load pi:' + dec2hex(addr));
            var off=a-MEMORY_START_PI;
            return this.piUint8Array[off]<<8 | this.piUint8Array[off+1];        
        } else if (a >= MEMORY_START_SI && a < MEMORY_START_SI + MEMORY_SIZE_SI) {
           // alert('load si');
            var off=a-MEMORY_START_SI;
            return core.interrupts.readSI(off);
        } else if (a >= MEMORY_START_C2A1 && a < MEMORY_START_C2A1 + MEMORY_SIZE_C2A1) {
            var off=a-MEMORY_START_C2A1;
            return this.c2a1Uint8Array[off]<<8 | this.c2a1Uint8Array[off+1];        
        } else if (a >= MEMORY_START_C1A1 && a < MEMORY_START_C1A1 + MEMORY_SIZE_C1A1) {
            var off=a-MEMORY_START_C1A1;
            return this.c1a1Uint8Array[off]<<8 | this.c1a1Uint8Array[off+1];
        } else if (a >= MEMORY_START_C2A2 && a < MEMORY_START_C2A2 + MEMORY_SIZE_C2A2) {
            var off=a-MEMORY_START_C2A2;
            return this.c2a2Uint8Array[off]<<8 | this.c2a2Uint8Array[off+1];
        } else if (a >= MEMORY_START_ROM_IMAGE && a < MEMORY_START_ROM_IMAGE + romLength) {
            //alert('load rom');
            var off=a-MEMORY_START_ROM_IMAGE;
            return this.romUint8Array[off]<<8 | this.romUint8Array[off+1];
        } else if (a >= MEMORY_START_C1A3 && a < MEMORY_START_C1A3 + MEMORY_SIZE_C1A3) {
            var off=a-MEMORY_START_C1A3;
            return this.c1a3Uint8Array[off]<<8 | this.c1a3Uint8Array[off+1];
        } else if (a >= MEMORY_START_RI && a < MEMORY_START_RI + MEMORY_SIZE_RI) {
            var off=a-MEMORY_START_RI;
            return this.riUint8Array[off]<<8 | this.riUint8Array[off+1];
        } else if(a >= MEMORY_START_PIF && a < MEMORY_START_PIF + MEMORY_SIZE_PIF) {
            var off=a-MEMORY_START_PIF;
            return this.pifUint8Array[off]<<8 | this.pifUint8Array[off+1];
    	} else if(a >= MEMORY_START_GIO && a < MEMORY_START_GIO + MEMORY_SIZE_GIO_REG) {
            var off=a-MEMORY_START_GIO;
            return this.gioUint8Array[off]<<8 | this.gioUint8Array[off+1];
    	} else if(a >= MEMORY_START_RAMREGS0 && a < MEMORY_START_RAMREGS0 + MEMORY_SIZE_RAMREGS0) {
            var off=a-MEMORY_START_RAMREGS0;
            return this.ramRegs0Uint8Array[off]<<8 | this.ramRegs0Uint8Array[off+1];
    	} else if(a >= MEMORY_START_RAMREGS8 && a < MEMORY_START_RAMREGS8 + MEMORY_SIZE_RAMREGS8) {
            var off=a-MEMORY_START_RAMREGS8;
            return this.ramRegs8Uint8Array[off]<<8 | this.ramRegs8Uint8Array[off+1];
    	} else {
            log( 'reading from invalid memory at ' + dec2hex(addr));
            //stopEmulator();
            var off=a&0x0000fffc;
            return this.dummyReadWriteUint8Array[off]<<8 | this.dummyReadWriteUint8Array[off+1];
    	}
    }

    this.loadWord = function(addr) {
        if ((addr & 0xff000000) === 0x84000000)
            throw 'todo: mirrored load address';
        
        var a = addr & 0x1FFFFFFF;    
        
        if (a >= MEMORY_START_RDRAM && a < MEMORY_START_RDRAM + MEMORY_SIZE_RDRAM) {
            var off=a-MEMORY_START_RDRAM;
            return this.rdramUint8Array[off]<<24 | this.rdramUint8Array[off+1]<<16 | this.rdramUint8Array[off+2]<<8 | this.rdramUint8Array[off+3];
            return //getInt32(rdramUint8Array, rdramUint8Array, a-MEMORY_START_RDRAM);
        } else if (a >= MEMORY_START_RAMREGS4 && a < MEMORY_START_RAMREGS4 + MEMORY_SIZE_RAMREGS4) {
            var off=a-MEMORY_START_RAMREGS4;
            return this.ramRegs4Uint8Array[off]<<24 | this.ramRegs4Uint8Array[off+1]<<16 | this.ramRegs4Uint8Array[off+2]<<8 | this.ramRegs4Uint8Array[off+3];
        } else if (a >= MEMORY_START_SPMEM && a < MEMORY_START_SPMEM + MEMORY_SIZE_SPMEM) {
            var off=a-MEMORY_START_SPMEM;
            return this.spMemUint8Array[off]<<24 | this.spMemUint8Array[off+1]<<16 | this.spMemUint8Array[off+2]<<8 | this.spMemUint8Array[off+3];        
        } else if (a >= MEMORY_START_SPREG_1 && a < MEMORY_START_SPREG_1 + MEMORY_SIZE_SPREG_1) {
            var off=a-MEMORY_START_SPREG_1;
            return core.interrupts.readSPReg1(off);
        } else if (a >= MEMORY_START_SPREG_2 && a < MEMORY_START_SPREG_2 + MEMORY_SIZE_SPREG_2) {
            var off=a-MEMORY_START_SPREG_2;
            return this.spReg2Uint8Array[off]<<24 | this.spReg2Uint8Array[off+1]<<16 | this.spReg2Uint8Array[off+2]<<8 | this.spReg2Uint8Array[off+3];        
        } else if (a >= MEMORY_START_DPC && a < MEMORY_START_DPC + MEMORY_SIZE_DPC) {
            var off=a-MEMORY_START_DPC;
            return this.dpcUint8Array[off]<<24 | this.dpcUint8Array[off+1]<<16 | this.dpcUint8Array[off+2]<<8 | this.dpcUint8Array[off+3];        
        } else if (a >= MEMORY_START_DPS && a < MEMORY_START_DPS + MEMORY_SIZE_DPS) {
            var off=a-MEMORY_START_DPS;
            return this.dpsUint8Array[off]<<24 | this.dpsUint8Array[off+1]<<16 | this.dpsUint8Array[off+2]<<8 | this.dpsUint8Array[off+3];        
        } else if (a >= MEMORY_START_MI && a < MEMORY_START_MI + MEMORY_SIZE_MI) {
            //alert('load mi:' + dec2hex(addr));
            var off=a-MEMORY_START_MI;
            //if (off === 8) //hack for read-only mi_intr_reg
            //    return -1;
            return this.miUint8Array[off]<<24 | this.miUint8Array[off+1]<<16 | this.miUint8Array[off+2]<<8 | this.miUint8Array[off+3];        
        } else if (a >= MEMORY_START_VI && a < MEMORY_START_VI + MEMORY_SIZE_VI) {
            var off=a-MEMORY_START_VI;
            return core.interrupts.readVI(off);
        } else if (a >= MEMORY_START_AI && a < MEMORY_START_AI + MEMORY_SIZE_AI) {
            //alert('load ai:' + dec2hex(addr));
            var off=a-MEMORY_START_AI;
            return core.interrupts.readAI(off);
        } else if (a >= MEMORY_START_PI && a < MEMORY_START_PI + MEMORY_SIZE_PI) {
           // alert('load pi:' + dec2hex(addr));
            var off=a-MEMORY_START_PI;
            return this.piUint8Array[off]<<24 | this.piUint8Array[off+1]<<16 | this.piUint8Array[off+2]<<8 | this.piUint8Array[off+3];        
        } else if (a >= MEMORY_START_SI && a < MEMORY_START_SI + MEMORY_SIZE_SI) {
           // alert('load si');
            var off=a-MEMORY_START_SI;
            return core.interrupts.readSI(off);
        } else if (a >= MEMORY_START_C2A1 && a < MEMORY_START_C2A1 + MEMORY_SIZE_C2A1) {
            var off=a-MEMORY_START_C2A1;
            return this.c2a1Uint8Array[off]<<24 | this.c2a1Uint8Array[off+1]<<16 | this.c2a1Uint8Array[off+2]<<8 | this.c2a1Uint8Array[off+3];        
        } else if (a >= MEMORY_START_C1A1 && a < MEMORY_START_C1A1 + MEMORY_SIZE_C1A1) {
            var off=a-MEMORY_START_C1A1;
            return this.c1a1Uint8Array[off]<<24 | this.c1a1Uint8Array[off+1]<<16 | this.c1a1Uint8Array[off+2]<<8 | this.c1a1Uint8Array[off+3];        
        } else if (a >= MEMORY_START_C2A2 && a < MEMORY_START_C2A2 + MEMORY_SIZE_C2A2) {
            var off=a-MEMORY_START_C2A2;
            return this.c2a2Uint8Array[off]<<24 | this.c2a2Uint8Array[off+1]<<16 | this.c2a2Uint8Array[off+2]<<8 | this.c2a2Uint8Array[off+3];        
        } else if (a >= MEMORY_START_ROM_IMAGE && a < MEMORY_START_ROM_IMAGE + romLength) {
            //alert('load rom');
            var off=a-MEMORY_START_ROM_IMAGE;
            return this.romUint8Array[off]<<24 | this.romUint8Array[off+1]<<16 | this.romUint8Array[off+2]<<8 | this.romUint8Array[off+3];        
        } else if (a >= MEMORY_START_C1A3 && a < MEMORY_START_C1A3 + MEMORY_SIZE_C1A3) {
            var off=a-MEMORY_START_C1A3;
            return this.c1a3Uint8Array[off]<<24 | this.c1a3Uint8Array[off+1]<<16 | this.c1a3Uint8Array[off+2]<<8 | this.c1a3Uint8Array[off+3];        
        } else if (a >= MEMORY_START_RI && a < MEMORY_START_RI + MEMORY_SIZE_RI) {
            var off=a-MEMORY_START_RI;
            return this.riUint8Array[off]<<24 | this.riUint8Array[off+1]<<16 | this.riUint8Array[off+2]<<8 | this.riUint8Array[off+3];        
        } else if(a >= MEMORY_START_PIF && a < MEMORY_START_PIF + MEMORY_SIZE_PIF) {
            var off=a-MEMORY_START_PIF;
            return this.pifUint8Array[off]<<24 | this.pifUint8Array[off+1]<<16 | this.pifUint8Array[off+2]<<8 | this.pifUint8Array[off+3];        
    	} else if(a >= MEMORY_START_GIO && a < MEMORY_START_GIO + MEMORY_SIZE_GIO_REG) {
            var off=a-MEMORY_START_GIO;
            return this.gioUint8Array[off]<<24 | this.gioUint8Array[off+1]<<16 | this.gioUint8Array[off+2]<<8 | this.gioUint8Array[off+3];        
    	} else if(a >= MEMORY_START_RAMREGS0 && a < MEMORY_START_RAMREGS0 + MEMORY_SIZE_RAMREGS0) {
            var off=a-MEMORY_START_RAMREGS0;
            return this.ramRegs0Uint8Array[off]<<24 | this.ramRegs0Uint8Array[off+1]<<16 | this.ramRegs0Uint8Array[off+2]<<8 | this.ramRegs0Uint8Array[off+3];        
    	} else if(a >= MEMORY_START_RAMREGS8 && a < MEMORY_START_RAMREGS8 + MEMORY_SIZE_RAMREGS8) {
            var off=a-MEMORY_START_RAMREGS8;
            return this.ramRegs8Uint8Array[off]<<24 | this.ramRegs8Uint8Array[off+1]<<16 | this.ramRegs8Uint8Array[off+2]<<8 | this.ramRegs8Uint8Array[off+3];        
    	} else {
            log( 'reading from invalid memory at ' + dec2hex(addr));
            //stopEmulator();
            var off=a&0x0000fffc;
            return this.dummyReadWriteUint8Array[off]<<24 | this.dummyReadWriteUint8Array[off+1]<<16 | this.dummyReadWriteUint8Array[off+2]<<8 | this.dummyReadWriteUint8Array[off+3];        
    	}
    }

    this.storeWord = function(val, addr, pc, isDelaySlot) {
        var a = addr & 0x1FFFFFFF;

        if (a >= MEMORY_START_RDRAM && a < MEMORY_START_RDRAM + MEMORY_SIZE_RDRAM) {
            var off=a-MEMORY_START_RDRAM;
            this.rdramUint8Array[off] = val>>24; this.rdramUint8Array[off+1] = val>>16; this.rdramUint8Array[off+2] = val>>8; this.rdramUint8Array[off+3] = val;
            return;    
        } else if (a >= MEMORY_START_SPMEM && a < MEMORY_START_SPMEM + MEMORY_SIZE_SPMEM) {
            var off=a-MEMORY_START_SPMEM;
            this.spMemUint8Array[off] = val>>24; this.spMemUint8Array[off+1] = val>>16; this.spMemUint8Array[off+2] = val>>8; this.spMemUint8Array[off+3] = val;
            return;
        } else if (a >= MEMORY_START_RI && a < MEMORY_START_RI + MEMORY_SIZE_RI) {
            var off=a-MEMORY_START_RI;
            this.riUint8Array[off] = val>>24; this.riUint8Array[off+1] = val>>16; this.riUint8Array[off+2] = val>>8; this.riUint8Array[off+3] = val;
            return;
        } else if (a >= MEMORY_START_MI && a < MEMORY_START_MI + MEMORY_SIZE_MI) {
            var off=a-MEMORY_START_MI;
            core.interrupts.writeMI(off, val, pc, isDelaySlot);
            return;
        } else if(a >= MEMORY_START_RAMREGS8 && a < MEMORY_START_RAMREGS8 + MEMORY_SIZE_RAMREGS8) {
            var off=a-MEMORY_START_RAMREGS8;
            this.ramRegs8Uint8Array[off] = val>>24; this.ramRegs8Uint8Array[off+1] = val>>16; this.ramRegs8Uint8Array[off+2] = val>>8; this.ramRegs8Uint8Array[off+3] = val;
            return;
    	} else if (a >= MEMORY_START_RAMREGS4 && a < MEMORY_START_RAMREGS4 + MEMORY_SIZE_RAMREGS4) {
            var off=a-MEMORY_START_RAMREGS4;
            this.ramRegs4Uint8Array[off] = val>>24; this.ramRegs4Uint8Array[off+1] = val>>16; this.ramRegs4Uint8Array[off+2] = val>>8; this.ramRegs4Uint8Array[off+3] = val;
            return;
        } else if(a >= MEMORY_START_RAMREGS0 && a < MEMORY_START_RAMREGS0 + MEMORY_SIZE_RAMREGS0) {
            var off=a-MEMORY_START_RAMREGS0;
            this.ramRegs0Uint8Array[off] = val>>24; this.ramRegs0Uint8Array[off+1] = val>>16; this.ramRegs0Uint8Array[off+2] = val>>8; this.ramRegs0Uint8Array[off+3] = val;
            return;
    	} else if (a >= MEMORY_START_SPREG_1 && a < MEMORY_START_SPREG_1 + MEMORY_SIZE_SPREG_1) {
            var off=a-MEMORY_START_SPREG_1;
            core.interrupts.writeSPReg1(off, val, pc, isDelaySlot);
            return;
        } else if (a >= MEMORY_START_PI && a < MEMORY_START_PI + MEMORY_SIZE_PI) {
            var off=a-MEMORY_START_PI;
            core.interrupts.writePI(off, val, pc, isDelaySlot);
            return; 
        } else if (a >= MEMORY_START_SI && a < MEMORY_START_SI + MEMORY_SIZE_SI) {
            var off=a-MEMORY_START_SI;
            core.interrupts.writeSI(off, val, pc, isDelaySlot);
            return;
        } else if (a >= MEMORY_START_AI && a < MEMORY_START_AI + MEMORY_SIZE_AI) {
            var off=a-MEMORY_START_AI;
            core.interrupts.writeAI(off, val, pc, isDelaySlot);
            return;
        } else if (a >= MEMORY_START_VI && a < MEMORY_START_VI + MEMORY_SIZE_VI) {
            var off=a-MEMORY_START_VI;
            core.interrupts.writeVI(off, val, pc, isDelaySlot);
            return;
        } else if (a >= MEMORY_START_SPREG_2 && a < MEMORY_START_SPREG_2 + MEMORY_SIZE_SPREG_2) {
            var off=a-MEMORY_START_SPREG_2;
            core.interrupts.writeSPReg2(off, val, pc, isDelaySlot);
            return;
        } else if (a >= MEMORY_START_DPC && a < MEMORY_START_DPC + MEMORY_SIZE_DPC) {
            var off=a-MEMORY_START_DPC;
            core.interrupts.writeDPC(off, val, pc, isDelaySlot);
            return;
        } else if (a >= MEMORY_START_DPS && a < MEMORY_START_DPS + MEMORY_SIZE_DPS) {
            var off=a-MEMORY_START_DPS;
            this.dpsUint8Array[off] = val>>24; this.dpsUint8Array[off+1] = val>>16; this.dpsUint8Array[off+2] = val>>8; this.dpsUint8Array[off+3] = val;
            return;
        } else if (a >= MEMORY_START_C2A1 && a < MEMORY_START_C2A1 + MEMORY_SIZE_C2A1) {
            var off=a-MEMORY_START_C2A1;
            this.c2a1Uint8Array[off] = val>>24; this.c2a1Uint8Array[off+1] = val>>16; this.c2a1Uint8Array[off+2] = val>>8; this.c2a1Uint8Array[off+3] = val;
            return;
        } else if (a >= MEMORY_START_C1A1 && a < MEMORY_START_C1A1 + MEMORY_SIZE_C1A1) {
            var off=a-MEMORY_START_C1A1;
            this.c1a1Uint8Array[off] = val>>24; this.c1a1Uint8Array[off+1] = val>>16; this.c1a1Uint8Array[off+2] = val>>8; this.c1a1Uint8Array[off+3] = val;
            return;
        } else if (a >= MEMORY_START_C2A2 && a < MEMORY_START_C2A2 + MEMORY_SIZE_C2A2) {
            var off=a-MEMORY_START_C2A2;
            this.c2a2Uint8Array[off] = val>>24; this.c2a2Uint8Array[off+1] = val>>16; this.c2a2Uint8Array[off+2] = val>>8; this.c2a2Uint8Array[off+3] = val;
            return;
        } else if (a >= MEMORY_START_ROM_IMAGE && a < MEMORY_START_ROM_IMAGE + romLength) {
            alert('attempt to overwrite rom!');
            var off=a-MEMORY_START_ROM_IMAGE;
            this.romUint8Array[off] = val>>24; this.romUint8Array[off+1] = val>>16; this.romUint8Array[off+2] = val>>8; this.romUint8Array[off+3] = val;
            return;
        } else if (a >= MEMORY_START_C1A3 && a < MEMORY_START_C1A3 + MEMORY_SIZE_C1A3) {
            var off=a-MEMORY_START_C1A3;
            this.c1a3Uint8Array[off] = val>>24; this.c1a3Uint8Array[off+1] = val>>16; this.c1a3Uint8Array[off+2] = val>>8; this.c1a3Uint8Array[off+3] = val;
            return;
        } else if(a >= MEMORY_START_PIF && a < MEMORY_START_PIF + MEMORY_SIZE_PIF) {
            var off=a-MEMORY_START_PIF;
            this.pifUint8Array[off] = val>>24; this.pifUint8Array[off+1] = val>>16; this.pifUint8Array[off+2] = val>>8; this.pifUint8Array[off+3] = val;
            return;
    	} else if(a >= MEMORY_START_GIO && a < MEMORY_START_GIO + MEMORY_SIZE_GIO_REG) {
            var off=a-MEMORY_START_GIO;
            this.gioUint8Array[off] = val>>24; this.gioUint8Array[off+1] = val>>16; this.gioUint8Array[off+2] = val>>8; this.gioUint8Array[off+3] = val;
            return;
    	} else {
            log('writing to invalid memory at ' + dec2hex(addr));
            //stopEmulator();
            var off=a&0x0000fffc;
            this.rdramUint8Array[off] = val>>24; this.rdramUint8Array[off+1] = val>>16; this.rdramUint8Array[off+2] = val>>8; this.rdramUint8Array[off+3] = val;
            return;
    	}
    }

    //Same routine as storeWord, but store a byte 
    this.storeByte = function(val, addr, pc, isDelaySlot) {
        var a = addr & 0x1FFFFFFF;

        if (a >= MEMORY_START_RDRAM && a < MEMORY_START_RDRAM + MEMORY_SIZE_RDRAM) {
            var off=a-MEMORY_START_RDRAM;
            this.rdramUint8Array[off] = val;
            return;    
        } else if (a >= MEMORY_START_SPMEM && a < MEMORY_START_SPMEM + MEMORY_SIZE_SPMEM) {
            var off=a-MEMORY_START_SPMEM;
            this.spMemUint8Array[off] = val;
            return;
        } else if (a >= MEMORY_START_RI && a < MEMORY_START_RI + MEMORY_SIZE_RI) {
            var off=a-MEMORY_START_RI;
            this.riUint8Array[off] = val;
            return;
        } else if (a >= MEMORY_START_MI && a < MEMORY_START_MI + MEMORY_SIZE_MI) {
            var off=a-MEMORY_START_MI;
            core.interrupts.writeMI(off, val, pc, isDelaySlot);
            return;
        } else if(a >= MEMORY_START_RAMREGS8 && a < MEMORY_START_RAMREGS8 + MEMORY_SIZE_RAMREGS8) {
            var off=a-MEMORY_START_RAMREGS8;
            this.ramRegs8Uint8Array[off] = val;
            return;
    	} else if (a >= MEMORY_START_RAMREGS4 && a < MEMORY_START_RAMREGS4 + MEMORY_SIZE_RAMREGS4) {
            var off=a-MEMORY_START_RAMREGS4;
            this.ramRegs4Uint8Array[off] = val;
            return;
        } else if(a >= MEMORY_START_RAMREGS0 && a < MEMORY_START_RAMREGS0 + MEMORY_SIZE_RAMREGS0) {
            var off=a-MEMORY_START_RAMREGS0;
            this.ramRegs0Uint8Array[off] = val;
            return;
    	} else if (a >= MEMORY_START_SPREG_1 && a < MEMORY_START_SPREG_1 + MEMORY_SIZE_SPREG_1) {
            var off=a-MEMORY_START_SPREG_1;
            core.interrupts.writeSPReg1(off, val, pc, isDelaySlot);
            return;
        } else if (a >= MEMORY_START_PI && a < MEMORY_START_PI + MEMORY_SIZE_PI) {
            var off=a-MEMORY_START_PI;
            core.interrupts.writePI(off, val, pc, isDelaySlot);
            return; 
        } else if (a >= MEMORY_START_SI && a < MEMORY_START_SI + MEMORY_SIZE_SI) {
            var off=a-MEMORY_START_SI;
            core.interrupts.writeSI(off, val, pc, isDelaySlot);
            return;
        } else if (a >= MEMORY_START_AI && a < MEMORY_START_AI + MEMORY_SIZE_AI) {
            var off=a-MEMORY_START_AI;
            core.interrupts.writeAI(off, val, pc, isDelaySlot);
            return;
        } else if (a >= MEMORY_START_VI && a < MEMORY_START_VI + MEMORY_SIZE_VI) {
            var off=a-MEMORY_START_VI;
            core.interrupts.writeVI(off, val, pc, isDelaySlot);
            return;
        } else if (a >= MEMORY_START_SPREG_2 && a < MEMORY_START_SPREG_2 + MEMORY_SIZE_SPREG_2) {
            var off=a-MEMORY_START_SPREG_2;
            core.interrupts.writeSPReg2(off, val, pc, isDelaySlot);
            return;
        } else if (a >= MEMORY_START_DPC && a < MEMORY_START_DPC + MEMORY_SIZE_DPC) {
            var off=a-MEMORY_START_DPC;
            core.interrupts.writeDPC(off, val, pc, isDelaySlot);
            return;
        } else if (a >= MEMORY_START_DPS && a < MEMORY_START_DPS + MEMORY_SIZE_DPS) {
            var off=a-MEMORY_START_DPS;
            this.dpsUint8Array[off] = val;
            return;
        } else if (a >= MEMORY_START_C2A1 && a < MEMORY_START_C2A1 + MEMORY_SIZE_C2A1) {
            var off=a-MEMORY_START_C2A1;
            this.c2a1Uint8Array[off] = val;
            return;
        } else if (a >= MEMORY_START_C1A1 && a < MEMORY_START_C1A1 + MEMORY_SIZE_C1A1) {
            var off=a-MEMORY_START_C1A1;
            this.c1a1Uint8Array[off] = val;
            return;
        } else if (a >= MEMORY_START_C2A2 && a < MEMORY_START_C2A2 + MEMORY_SIZE_C2A2) {
            var off=a-MEMORY_START_C2A2;
            this.c2a2Uint8Array[off] = val;
            return;
        } else if (a >= MEMORY_START_ROM_IMAGE && a < MEMORY_START_ROM_IMAGE + romLength) {
            alert('attempt to overwrite rom!');
            var off=a-MEMORY_START_ROM_IMAGE;
            this.romUint8Array[off] = val;
            return;
        } else if (a >= MEMORY_START_C1A3 && a < MEMORY_START_C1A3 + MEMORY_SIZE_C1A3) {
            var off=a-MEMORY_START_C1A3;
            this.c1a3Uint8Array[off] = val;
            return;
        } else if(a >= MEMORY_START_PIF && a < MEMORY_START_PIF + MEMORY_SIZE_PIF) {
            var off=a-MEMORY_START_PIF;
            this.pifUint8Array[off] = val;
            return;
    	} else if(a >= MEMORY_START_GIO && a < MEMORY_START_GIO + MEMORY_SIZE_GIO_REG) {
            var off=a-MEMORY_START_GIO;
            this.gioUint8Array[off] = val;
            return;
    	} else {
            log('writing to invalid memory at ' + dec2hex(addr));
            //stopEmulator();
            var off=a&0x0000fffc;
            this.rdramUint8Array[off] = val;
            return;
    	}
    }

    this.storeHalf = function(val, addr, pc, isDelaySlot) {
        var a = addr & 0x1FFFFFFF;

        if (a >= MEMORY_START_RDRAM && a < MEMORY_START_RDRAM + MEMORY_SIZE_RDRAM) {
            var off=a-MEMORY_START_RDRAM;
            this.rdramUint8Array[off] = val>>8; this.rdramUint8Array[off+1] = val;
            return;    
        } else if (a >= MEMORY_START_SPMEM && a < MEMORY_START_SPMEM + MEMORY_SIZE_SPMEM) {
            var off=a-MEMORY_START_SPMEM;
            this.spMemUint8Array[off] = val>>8; this.spMemUint8Array[off+1] = val;
            return;
        } else if (a >= MEMORY_START_RI && a < MEMORY_START_RI + MEMORY_SIZE_RI) {
            var off=a-MEMORY_START_RI;
            this.riUint8Array[off] = val>>8; this.riUint8Array[off+1] = val;
            return;
        } else if (a >= MEMORY_START_MI && a < MEMORY_START_MI + MEMORY_SIZE_MI) {
            var off=a-MEMORY_START_MI;
            core.interrupts.writeMI(off, val, pc, isDelaySlot);
            return;
        } else if(a >= MEMORY_START_RAMREGS8 && a < MEMORY_START_RAMREGS8 + MEMORY_SIZE_RAMREGS8) {
            var off=a-MEMORY_START_RAMREGS8;
            this.ramRegs8Uint8Array[off] = val>>8; this.ramRegs8Uint8Array[off+1] = val;
            return;
    	} else if (a >= MEMORY_START_RAMREGS4 && a < MEMORY_START_RAMREGS4 + MEMORY_SIZE_RAMREGS4) {
            var off=a-MEMORY_START_RAMREGS4;
            this.ramRegs4Uint8Array[off] = val>>8; this.ramRegs4Uint8Array[off+1] = val;
            return;
        } else if(a >= MEMORY_START_RAMREGS0 && a < MEMORY_START_RAMREGS0 + MEMORY_SIZE_RAMREGS0) {
            var off=a-MEMORY_START_RAMREGS0;
            this.ramRegs0Uint8Array[off] = val>>8; this.ramRegs0Uint8Array[off+1] = val;
            return;
    	} else if (a >= MEMORY_START_SPREG_1 && a < MEMORY_START_SPREG_1 + MEMORY_SIZE_SPREG_1) {
            var off=a-MEMORY_START_SPREG_1;
            core.interrupts.writeSPReg1(off, val, pc, isDelaySlot);
            return;
        } else if (a >= MEMORY_START_PI && a < MEMORY_START_PI + MEMORY_SIZE_PI) {
            var off=a-MEMORY_START_PI;
            core.interrupts.writePI(off, val, pc, isDelaySlot);
            return; 
        } else if (a >= MEMORY_START_SI && a < MEMORY_START_SI + MEMORY_SIZE_SI) {
            var off=a-MEMORY_START_SI;
            core.interrupts.writeSI(off, val, pc, isDelaySlot);
            return;
        } else if (a >= MEMORY_START_AI && a < MEMORY_START_AI + MEMORY_SIZE_AI) {
            var off=a-MEMORY_START_AI;
            core.interrupts.writeAI(off, val, pc, isDelaySlot);
            return;
        } else if (a >= MEMORY_START_VI && a < MEMORY_START_VI + MEMORY_SIZE_VI) {
            var off=a-MEMORY_START_VI;
            core.interrupts.writeVI(off, val, pc, isDelaySlot);
            return;
        } else if (a >= MEMORY_START_SPREG_2 && a < MEMORY_START_SPREG_2 + MEMORY_SIZE_SPREG_2) {
            var off=a-MEMORY_START_SPREG_2;
            core.interrupts.writeSPReg2(off, val, pc, isDelaySlot);
            return;
        } else if (a >= MEMORY_START_DPC && a < MEMORY_START_DPC + MEMORY_SIZE_DPC) {
            var off=a-MEMORY_START_DPC;
            core.interrupts.writeDPC(off, val, pc, isDelaySlot);
            return;
        } else if (a >= MEMORY_START_DPS && a < MEMORY_START_DPS + MEMORY_SIZE_DPS) {
            var off=a-MEMORY_START_DPS;
            this.dpsUint8Array[off] = val>>8; this.dpsUint8Array[off+1] = val;
            return;
        } else if (a >= MEMORY_START_C2A1 && a < MEMORY_START_C2A1 + MEMORY_SIZE_C2A1) {
            var off=a-MEMORY_START_C2A1;
            this.c2a1Uint8Array[off] = val>>8; this.c2a1Uint8Array[off+1] = val;
            return;
        } else if (a >= MEMORY_START_C1A1 && a < MEMORY_START_C1A1 + MEMORY_SIZE_C1A1) {
            var off=a-MEMORY_START_C1A1;
            this.c1a1Uint8Array[off] = val>>8; this.c1a1Uint8Array[off+1] = val;
            return;
        } else if (a >= MEMORY_START_C2A2 && a < MEMORY_START_C2A2 + MEMORY_SIZE_C2A2) {
            var off=a-MEMORY_START_C2A2;
            this.c2a2Uint8Array[off] = val>>8; this.c2a2Uint8Array[off+1] = val;
            return;
        } else if (a >= MEMORY_START_ROM_IMAGE && a < MEMORY_START_ROM_IMAGE + romLength) {
            alert('attempt to overwrite rom!');
            var off=a-MEMORY_START_ROM_IMAGE;
            this.romUint8Array[off] = val>>8; this.romUint8Array[off+1] = val;
            return;
        } else if (a >= MEMORY_START_C1A3 && a < MEMORY_START_C1A3 + MEMORY_SIZE_C1A3) {
            var off=a-MEMORY_START_C1A3;
            this.c1a3Uint8Array[off] = val>>8; this.c1a3Uint8Array[off+1] = val;
            return;
        } else if(a >= MEMORY_START_PIF && a < MEMORY_START_PIF + MEMORY_SIZE_PIF) {
            var off=a-MEMORY_START_PIF;
            this.pifUint8Array[off] = val>>8; this.pifUint8Array[off+1] = val;
            return;
    	} else if(a >= MEMORY_START_GIO && a < MEMORY_START_GIO + MEMORY_SIZE_GIO_REG) {
            var off=a-MEMORY_START_GIO;
            this.gioUint8Array[off] = val>>8; this.gioUint8Array[off+1] = val;
            return;
    	} else {
            log('writing to invalid memory at ' + dec2hex(addr));
            //stopEmulator();
            var off=a&0x0000fffc;
            this.rdramUint8Array[off] = val>>8; this.rdramUint8Array[off+1] = val;
            return;
    	}
    }
}
