/*
1964js - JavaScript/HTML5 port of 1964 - N64 emulator
Copyright (C) 2012 JdummyReadWriteUint8Arrayoel Middendorf

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

//getInt32 and getUint32 are identical. they both return signed.
function getInt32(sregion, uregion, off)
{
    return uregion[off]<<24|uregion[off+1]<<16|uregion[off+2]<<8|uregion[off+3];
}

function getUint32(uregion, off)
{
    return uregion[off]<<24|uregion[off+1]<<16|uregion[off+2]<<8|uregion[off+3];
}

function setInt32(uregion, off, val)
{
    uregion[off]=val>>24;uregion[off+1]=val>>16;uregion[off+2]=val>>8;uregion[off+3]=val;
}

function loadByte(addr)
{
    if ((addr & 0xff000000) === 0x84000000)
        throw 'todo: mirrored load address';
    
    var a = addr & 0x1FFFFFFF;    
    
    if (a >= MEMORY_START_RDRAM && a < MEMORY_START_RDRAM + MEMORY_SIZE_RDRAM) {
        var off=a-MEMORY_START_RDRAM;
        return rdramUint8Array[off];
    }
    else if (a >= MEMORY_START_RAMREGS4 && a < MEMORY_START_RAMREGS4 + MEMORY_SIZE_RAMREGS4) {
        var off=a-MEMORY_START_RAMREGS4;
        return ramRegsUint8Array[off];
    }
    else if (a >= MEMORY_START_SPMEM && a < MEMORY_START_SPMEM + MEMORY_SIZE_SPMEM) {
        var off=a-MEMORY_START_SPMEM;
        return spMemUint8Array[off];        
    }
    else if (a >= MEMORY_START_SPREG_1 && a < MEMORY_START_SPREG_1 + MEMORY_SIZE_SPREG_1) {
        var off=a-MEMORY_START_SPREG_1;
        return readSPReg1(off);
    }
    else if (a >= MEMORY_START_SPREG_2 && a < MEMORY_START_SPREG_2 + MEMORY_SIZE_SPREG_2) {
        var off=a-MEMORY_START_SPREG_2;
        return spReg2Uint8Array[off];        
    }
    else if (a >= MEMORY_START_DPC && a < MEMORY_START_DPC + MEMORY_SIZE_DPC) {
        alert('get dpc');
        var off=a-MEMORY_START_DPC;
        return dpcUint8Array[off];        
    }
    else if (a >= MEMORY_START_DPS && a < MEMORY_START_DPS + MEMORY_SIZE_DPS) {
        var off=a-MEMORY_START_DPS;
        return dpsUint8Array[off];        
    }
    else if (a >= MEMORY_START_MI && a < MEMORY_START_MI + MEMORY_SIZE_MI) {
        //alert('load mi:' + dec2hex(addr));
        var off=a-MEMORY_START_MI;
        return miUint8Array[off];        
    }
    else if (a >= MEMORY_START_VI && a < MEMORY_START_VI + MEMORY_SIZE_VI) {
        var off=a-MEMORY_START_VI;
        return readVI(off);
    }
    else if (a >= MEMORY_START_AI && a < MEMORY_START_AI + MEMORY_SIZE_AI) {
        //alert('load ai:' + dec2hex(addr));
        var off=a-MEMORY_START_AI;
        return readAI(off);
    }
    else if (a >= MEMORY_START_PI && a < MEMORY_START_PI + MEMORY_SIZE_PI) {
       // alert('load pi:' + dec2hex(addr));
        var off=a-MEMORY_START_PI;
        return piUint8Array[off];        
    }
    else if (a >= MEMORY_START_SI && a < MEMORY_START_SI + MEMORY_SIZE_SI) {
       // alert('load si');
        var off=a-MEMORY_START_SI;
        return readSI(off);
    }
    else if (a >= MEMORY_START_C2A1 && a < MEMORY_START_C2A1 + MEMORY_SIZE_C2A1) {
        var off=a-MEMORY_START_C2A1;
        return c2a1Uint8Array[off];        
    }
    else if (a >= MEMORY_START_C1A1 && a < MEMORY_START_C1A1 + MEMORY_SIZE_C1A1) {
        var off=a-MEMORY_START_C1A1;
        return c1a1Uint8Array[off];        
    }
    else if (a >= MEMORY_START_C2A2 && a < MEMORY_START_C2A2 + MEMORY_SIZE_C2A2) {
        var off=a-MEMORY_START_C2A2;
        return c2a2Uint8Array[off];        
    }
    else if (a >= MEMORY_START_ROM_IMAGE && a < MEMORY_START_ROM_IMAGE + romLength) { //todo: could be a problem to use romLength
      //  alert('load rom');
        var off=a-MEMORY_START_ROM_IMAGE;
        return romUint8Array[off];        
    }
    else if (a >= MEMORY_START_C1A3 && a < MEMORY_START_C1A3 + MEMORY_SIZE_C1A3) {
        var off=a-MEMORY_START_C1A3;
        return c1a3Uint8Array[off];        
    }
    else if (a >= MEMORY_START_RI && a < MEMORY_START_RI + MEMORY_SIZE_RI) {
        var off=a-MEMORY_START_RI;
        return riUint8Array[off];        
    }
    else if(a >= MEMORY_START_PIF && a < MEMORY_START_PIF + MEMORY_SIZE_PIF) {
        var off=a-MEMORY_START_PIF;
        return pifUint8Array[off];        
	}
	else if(a >= MEMORY_START_GIO && a < MEMORY_START_GIO + MEMORY_SIZE_GIO_REG) {
        var off=a-MEMORY_START_GIO;
        return gioUint8Array[off];        
	}
	else if(a >= MEMORY_START_RAMREGS0 && a < MEMORY_START_RAMREGS0 + MEMORY_SIZE_RAMREGS0) {
        var off=a-MEMORY_START_RAMREGS0;
        return ramRegs0Uint8Array[off];        
	}
	else if(a >= MEMORY_START_RAMREGS8 && a < MEMORY_START_RAMREGS8 + MEMORY_SIZE_RAMREGS8) {
        var off=a-MEMORY_START_RAMREGS8;
        return ramRegs8Uint8Array[off];        
	}
	else {
        throw( 'reading from invalid memory at ' + dec2hex(addr));
        //stopEmulator();
        var off=a&0x0000fffc;
        return dummyReadWriteUint8Array[off];        
	}
}

function loadHalf(addr)
{
    if ((addr & 0xff000000) === 0x84000000)
        throw 'todo: mirrored load address';
    
    var a = addr & 0x1FFFFFFF;
    
    if (a >= MEMORY_START_RDRAM && a < MEMORY_START_RDRAM + MEMORY_SIZE_RDRAM) {
        var off=a-MEMORY_START_RDRAM;
        return rdramUint8Array[off]<<8 | rdramUint8Array[off+1];
    }
    else if (a >= MEMORY_START_RAMREGS4 && a < MEMORY_START_RAMREGS4 + MEMORY_SIZE_RAMREGS4) {
        var off=a-MEMORY_START_RAMREGS4;
        return ramRegsUint8Array[off]<<8 | ramRegsUint8Array[off+1];
    }
    else if (a >= MEMORY_START_SPMEM && a < MEMORY_START_SPMEM + MEMORY_SIZE_SPMEM) {
        var off=a-MEMORY_START_SPMEM;
        return spMemUint8Array[off]<<8 | spMemUint8Array[off+1];        
    }
    else if (a >= MEMORY_START_SPREG_1 && a < MEMORY_START_SPREG_1 + MEMORY_SIZE_SPREG_1) {
        var off=a-MEMORY_START_SPREG_1;
        return readSPReg1(off);
    }
    else if (a >= MEMORY_START_SPREG_2 && a < MEMORY_START_SPREG_2 + MEMORY_SIZE_SPREG_2) {
        var off=a-MEMORY_START_SPREG_2;
        return spReg2Uint8Array[off]<<8 | spReg2Uint8Array[off+1];        
    }
    else if (a >= MEMORY_START_DPC && a < MEMORY_START_DPC + MEMORY_SIZE_DPC) {
        alert('get dpc');
        var off=a-MEMORY_START_DPC;
        return dpcUint8Array[off]<<8 | dpcUint8Array[off+1];        
    }
    else if (a >= MEMORY_START_DPS && a < MEMORY_START_DPS + MEMORY_SIZE_DPS) {
        var off=a-MEMORY_START_DPS;
        return dpsUint8Array[off]<<8 | dpsUint8Array[off+1];        
    }
    else if (a >= MEMORY_START_MI && a < MEMORY_START_MI + MEMORY_SIZE_MI) {
        //alert('load mi:' + dec2hex(addr));
        var off=a-MEMORY_START_MI;
        return miUint8Array[off]<<8 | miUint8Array[off+1];
    }
    else if (a >= MEMORY_START_VI && a < MEMORY_START_VI + MEMORY_SIZE_VI) {
        var off=a-MEMORY_START_VI;
        return readVI(off);
    }
    else if (a >= MEMORY_START_AI && a < MEMORY_START_AI + MEMORY_SIZE_AI) {
        //alert('load ai:' + dec2hex(addr));
        var off=a-MEMORY_START_AI;
        return readAI(off);
    }
    else if (a >= MEMORY_START_PI && a < MEMORY_START_PI + MEMORY_SIZE_PI) {
       // alert('load pi:' + dec2hex(addr));
        var off=a-MEMORY_START_PI;
        return piUint8Array[off]<<8 | piUint8Array[off+1];        
    }
    else if (a >= MEMORY_START_SI && a < MEMORY_START_SI + MEMORY_SIZE_SI) {
       // alert('load si');
        var off=a-MEMORY_START_SI;
        return readSI(off);
    }
    else if (a >= MEMORY_START_C2A1 && a < MEMORY_START_C2A1 + MEMORY_SIZE_C2A1) {
        var off=a-MEMORY_START_C2A1;
        return c2a1Uint8Array[off]<<8 | c2a1Uint8Array[off+1];        
    }
    else if (a >= MEMORY_START_C1A1 && a < MEMORY_START_C1A1 + MEMORY_SIZE_C1A1) {
        var off=a-MEMORY_START_C1A1;
        return c1a1Uint8Array[off]<<8 | c1a1Uint8Array[off+1];
    }
    else if (a >= MEMORY_START_C2A2 && a < MEMORY_START_C2A2 + MEMORY_SIZE_C2A2) {
        var off=a-MEMORY_START_C2A2;
        return c2a2Uint8Array[off]<<8 | c2a2Uint8Array[off+1];
    }
    else if (a >= MEMORY_START_ROM_IMAGE && a < MEMORY_START_ROM_IMAGE + romLength) {
      //  alert('load rom');
        var off=a-MEMORY_START_ROM_IMAGE;
        return romUint8Array[off]<<8 | romUint8Array[off+1];
    }
    else if (a >= MEMORY_START_C1A3 && a < MEMORY_START_C1A3 + MEMORY_SIZE_C1A3) {
        var off=a-MEMORY_START_C1A3;
        return c1a3Uint8Array[off]<<8 | c1a3Uint8Array[off+1];
    }
    else if (a >= MEMORY_START_RI && a < MEMORY_START_RI + MEMORY_SIZE_RI) {
        var off=a-MEMORY_START_RI;
        return riUint8Array[off]<<8 | riUint8Array[off+1];
    }
    else if(a >= MEMORY_START_PIF && a < MEMORY_START_PIF + MEMORY_SIZE_PIF) {
        var off=a-MEMORY_START_PIF;
        return pifUint8Array[off]<<8 | pifUint8Array[off+1];
	}
	else if(a >= MEMORY_START_GIO && a < MEMORY_START_GIO + MEMORY_SIZE_GIO_REG) {
        var off=a-MEMORY_START_GIO;
        return gioUint8Array[off]<<8 | gioUint8Array[off+1];
	}
	else if(a >= MEMORY_START_RAMREGS0 && a < MEMORY_START_RAMREGS0 + MEMORY_SIZE_RAMREGS0) {
        var off=a-MEMORY_START_RAMREGS0;
        return ramRegs0Uint8Array[off]<<8 | ramRegs0Uint8Array[off+1];
	}
	else if(a >= MEMORY_START_RAMREGS8 && a < MEMORY_START_RAMREGS8 + MEMORY_SIZE_RAMREGS8) {
        var off=a-MEMORY_START_RAMREGS8;
        return ramRegs8Uint8Array[off]<<8 | ramRegs8Uint8Array[off+1];
	}
	else {
        throw( 'reading from invalid memory at ' + dec2hex(addr));
        //stopEmulator();
        var off=a&0x0000fffc;
        return dummyReadWriteUint8Array[off]<<8 | dummyReadWriteUint8Array[off+1];
	}
}

function loadWord(addr)
{
    if ((addr & 0xff000000) === 0x84000000)
        throw 'todo: mirrored load address';
    
    var a = addr & 0x1FFFFFFF;    
    
    if (a >= MEMORY_START_RDRAM && a < MEMORY_START_RDRAM + MEMORY_SIZE_RDRAM) {
        var off=a-MEMORY_START_RDRAM;
        return rdramUint8Array[off]<<24 | rdramUint8Array[off+1]<<16 | rdramUint8Array[off+2]<<8 | rdramUint8Array[off+3];
        return //getInt32(rdramUint8Array, rdramUint8Array, a-MEMORY_START_RDRAM);
    }
    else if (a >= MEMORY_START_RAMREGS4 && a < MEMORY_START_RAMREGS4 + MEMORY_SIZE_RAMREGS4) {
        var off=a-MEMORY_START_RAMREGS4;
        return ramRegsUint8Array[off]<<24 | ramRegsUint8Array[off+1]<<16 | ramRegsUint8Array[off+2]<<8 | ramRegsUint8Array[off+3];
    }
    else if (a >= MEMORY_START_SPMEM && a < MEMORY_START_SPMEM + MEMORY_SIZE_SPMEM) {
        var off=a-MEMORY_START_SPMEM;
        return spMemUint8Array[off]<<24 | spMemUint8Array[off+1]<<16 | spMemUint8Array[off+2]<<8 | spMemUint8Array[off+3];        
    }
    else if (a >= MEMORY_START_SPREG_1 && a < MEMORY_START_SPREG_1 + MEMORY_SIZE_SPREG_1) {
        var off=a-MEMORY_START_SPREG_1;
        return readSPReg1(off);
    }
    else if (a >= MEMORY_START_SPREG_2 && a < MEMORY_START_SPREG_2 + MEMORY_SIZE_SPREG_2) {
        var off=a-MEMORY_START_SPREG_2;
        return spReg2Uint8Array[off]<<24 | spReg2Uint8Array[off+1]<<16 | spReg2Uint8Array[off+2]<<8 | spReg2Uint8Array[off+3];        
    }
    else if (a >= MEMORY_START_DPC && a < MEMORY_START_DPC + MEMORY_SIZE_DPC) {
        alert('get dpc');
        var off=a-MEMORY_START_DPC;
        return dpcUint8Array[off]<<24 | dpcUint8Array[off+1]<<16 | dpcUint8Array[off+2]<<8 | dpcUint8Array[off+3];        
    }
    else if (a >= MEMORY_START_DPS && a < MEMORY_START_DPS + MEMORY_SIZE_DPS) {
        var off=a-MEMORY_START_DPS;
        return dpsUint8Array[off]<<24 | dpsUint8Array[off+1]<<16 | dpsUint8Array[off+2]<<8 | dpsUint8Array[off+3];        
    }
    else if (a >= MEMORY_START_MI && a < MEMORY_START_MI + MEMORY_SIZE_MI) {
        //alert('load mi:' + dec2hex(addr));
        var off=a-MEMORY_START_MI;
      //  if (off === 8) //hack for read-only mi_intr_reg
      //      return -1;
        return miUint8Array[off]<<24 | miUint8Array[off+1]<<16 | miUint8Array[off+2]<<8 | miUint8Array[off+3];        
    }
    else if (a >= MEMORY_START_VI && a < MEMORY_START_VI + MEMORY_SIZE_VI) {
        var off=a-MEMORY_START_VI;
        return readVI(off);
    }
    else if (a >= MEMORY_START_AI && a < MEMORY_START_AI + MEMORY_SIZE_AI) {
        //alert('load ai:' + dec2hex(addr));
        var off=a-MEMORY_START_AI;
        return readAI(off);
    }
    else if (a >= MEMORY_START_PI && a < MEMORY_START_PI + MEMORY_SIZE_PI) {
       // alert('load pi:' + dec2hex(addr));
        var off=a-MEMORY_START_PI;
        return piUint8Array[off]<<24 | piUint8Array[off+1]<<16 | piUint8Array[off+2]<<8 | piUint8Array[off+3];        
    }
    else if (a >= MEMORY_START_SI && a < MEMORY_START_SI + MEMORY_SIZE_SI) {
       // alert('load si');
        var off=a-MEMORY_START_SI;
        return readSI(off);
    }
    else if (a >= MEMORY_START_C2A1 && a < MEMORY_START_C2A1 + MEMORY_SIZE_C2A1) {
        var off=a-MEMORY_START_C2A1;
        return c2a1Uint8Array[off]<<24 | c2a1Uint8Array[off+1]<<16 | c2a1Uint8Array[off+2]<<8 | c2a1Uint8Array[off+3];        
    }
    else if (a >= MEMORY_START_C1A1 && a < MEMORY_START_C1A1 + MEMORY_SIZE_C1A1) {
        var off=a-MEMORY_START_C1A1;
        return c1a1Uint8Array[off]<<24 | c1a1Uint8Array[off+1]<<16 | c1a1Uint8Array[off+2]<<8 | c1a1Uint8Array[off+3];        
    }
    else if (a >= MEMORY_START_C2A2 && a < MEMORY_START_C2A2 + MEMORY_SIZE_C2A2) {
        var off=a-MEMORY_START_C2A2;
        return c2a2Uint8Array[off]<<24 | c2a2Uint8Array[off+1]<<16 | c2a2Uint8Array[off+2]<<8 | c2a2Uint8Array[off+3];        
    }
    else if (a >= MEMORY_START_ROM_IMAGE && a < MEMORY_START_ROM_IMAGE + romLength) {
      //  alert('load rom');
        var off=a-MEMORY_START_ROM_IMAGE;
        return romUint8Array[off]<<24 | romUint8Array[off+1]<<16 | romUint8Array[off+2]<<8 | romUint8Array[off+3];        
    }
    else if (a >= MEMORY_START_C1A3 && a < MEMORY_START_C1A3 + MEMORY_SIZE_C1A3) {
        var off=a-MEMORY_START_C1A3;
        return c1a3Uint8Array[off]<<24 | c1a3Uint8Array[off+1]<<16 | c1a3Uint8Array[off+2]<<8 | c1a3Uint8Array[off+3];        
    }
    else if (a >= MEMORY_START_RI && a < MEMORY_START_RI + MEMORY_SIZE_RI) {
        var off=a-MEMORY_START_RI;
        return riUint8Array[off]<<24 | riUint8Array[off+1]<<16 | riUint8Array[off+2]<<8 | riUint8Array[off+3];        
    }
    else if(a >= MEMORY_START_PIF && a < MEMORY_START_PIF + MEMORY_SIZE_PIF) {
        var off=a-MEMORY_START_PIF;
        return pifUint8Array[off]<<24 | pifUint8Array[off+1]<<16 | pifUint8Array[off+2]<<8 | pifUint8Array[off+3];        
	}
	else if(a >= MEMORY_START_GIO && a < MEMORY_START_GIO + MEMORY_SIZE_GIO_REG) {
        var off=a-MEMORY_START_GIO;
        return gioUint8Array[off]<<24 | gioUint8Array[off+1]<<16 | gioUint8Array[off+2]<<8 | gioUint8Array[off+3];        
	}
	else if(a >= MEMORY_START_RAMREGS0 && a < MEMORY_START_RAMREGS0 + MEMORY_SIZE_RAMREGS0) {
        var off=a-MEMORY_START_RAMREGS0;
        return ramRegs0Uint8Array[off]<<24 | ramRegs0Uint8Array[off+1]<<16 | ramRegs0Uint8Array[off+2]<<8 | ramRegs0Uint8Array[off+3];        
	}
	else if(a >= MEMORY_START_RAMREGS8 && a < MEMORY_START_RAMREGS8 + MEMORY_SIZE_RAMREGS8) {
        var off=a-MEMORY_START_RAMREGS8;
        return ramRegs8Uint8Array[off]<<24 | ramRegs8Uint8Array[off+1]<<16 | ramRegs8Uint8Array[off+2]<<8 | ramRegs8Uint8Array[off+3];        
	}
	else {
        throw( 'reading from invalid memory at ' + dec2hex(addr));
        //stopEmulator();
        var off=a&0x0000fffc;
        return dummyReadWriteUint8Array[off]<<24 | dummyReadWriteUint8Array[off+1]<<16 | dummyReadWriteUint8Array[off+2]<<8 | dummyReadWriteUint8Array[off+3];        
	}
}

function storeWord(val, addr, pc, isDelaySlot)
{
    var a = addr & 0x1FFFFFFF;

    if (a >= MEMORY_START_RDRAM && a < MEMORY_START_RDRAM + MEMORY_SIZE_RDRAM) {
        var off=a-MEMORY_START_RDRAM;
        rdramUint8Array[off] = val>>24;rdramUint8Array[off+1] = val>>16;rdramUint8Array[off+2] = val>>8;rdramUint8Array[off+3] = val;
        return;    
    }
    else if (a >= MEMORY_START_SPMEM && a < MEMORY_START_SPMEM + MEMORY_SIZE_SPMEM) {
        var off=a-MEMORY_START_SPMEM;
        spMemUint8Array[off] = val>>24;spMemUint8Array[off+1] = val>>16;spMemUint8Array[off+2] = val>>8;spMemUint8Array[off+3] = val;
        return;
    }
    else if (a >= MEMORY_START_RI && a < MEMORY_START_RI + MEMORY_SIZE_RI) {
        var off=a-MEMORY_START_RI;
        riUint8Array[off] = val>>24;riUint8Array[off+1] = val>>16;riUint8Array[off+2] = val>>8;riUint8Array[off+3] = val;
        return;
    }
    else if (a >= MEMORY_START_MI && a < MEMORY_START_MI + MEMORY_SIZE_MI) {
        var off=a-MEMORY_START_MI;
        writeMI(off, val, pc, isDelaySlot);
        return;
    }
	else if(a >= MEMORY_START_RAMREGS8 && a < MEMORY_START_RAMREGS8 + MEMORY_SIZE_RAMREGS8) {
        var off=a-MEMORY_START_RAMREGS8;
        ramRegs8Uint8Array[off] = val>>24;ramRegs8Uint8Array[off+1] = val>>16;ramRegs8Uint8Array[off+2] = val>>8;ramRegs8Uint8Array[off+3] = val;
        return;
	}
    else if (a >= MEMORY_START_RAMREGS4 && a < MEMORY_START_RAMREGS4 + MEMORY_SIZE_RAMREGS4) {
        var off=a-MEMORY_START_RAMREGS4;
        ramRegs4Uint8Array[off] = val>>24;ramRegs4Uint8Array[off+1] = val>>16;ramRegs4Uint8Array[off+2] = val>>8;ramRegs4Uint8Array[off+3] = val;
        return;
    }
	else if(a >= MEMORY_START_RAMREGS0 && a < MEMORY_START_RAMREGS0 + MEMORY_SIZE_RAMREGS0) {
        var off=a-MEMORY_START_RAMREGS0;
        ramRegs0Uint8Array[off] = val>>24;ramRegs0Uint8Array[off+1] = val>>16;ramRegs0Uint8Array[off+2] = val>>8;ramRegs0Uint8Array[off+3] = val;
        return;
	}
    else if (a >= MEMORY_START_SPREG_1 && a < MEMORY_START_SPREG_1 + MEMORY_SIZE_SPREG_1) {
        var off=a-MEMORY_START_SPREG_1;
        writeSPReg1(off, val, pc, isDelaySlot);
        return;
    }
    else if (a >= MEMORY_START_PI && a < MEMORY_START_PI + MEMORY_SIZE_PI) {
        var off=a-MEMORY_START_PI;
        writePI(off, val, pc, isDelaySlot);
        return; 
    }
    else if (a >= MEMORY_START_SI && a < MEMORY_START_SI + MEMORY_SIZE_SI) {
        var off=a-MEMORY_START_SI;
        writeSI(off, val, pc, isDelaySlot);
        return;
    }
    else if (a >= MEMORY_START_AI && a < MEMORY_START_AI + MEMORY_SIZE_AI) {
        var off=a-MEMORY_START_AI;
        writeAI(off, val, pc, isDelaySlot);
        return;
    }
    else if (a >= MEMORY_START_VI && a < MEMORY_START_VI + MEMORY_SIZE_VI) {
        var off=a-MEMORY_START_VI;
        writeVI(off, val, pc, isDelaySlot);
        return;
    }
    else if (a >= MEMORY_START_SPREG_2 && a < MEMORY_START_SPREG_2 + MEMORY_SIZE_SPREG_2) {
        var off=a-MEMORY_START_SPREG_2;
        writeSPReg2(off, val, pc, isDelaySlot);
        return;
    }
    else if (a >= MEMORY_START_DPC && a < MEMORY_START_DPC + MEMORY_SIZE_DPC) {
        var off=a-MEMORY_START_DPC;
        writeDPC(off, val, pc, isDelaySlot);
        return;
    }
    else if (a >= MEMORY_START_DPS && a < MEMORY_START_DPS + MEMORY_SIZE_DPS) {
        var off=a-MEMORY_START_DPS;
        dpsUint8Array[off] = val>>24;dpsUint8Array[off+1] = val>>16;dpsUint8Array[off+2] = val>>8;dpsUint8Array[off+3] = val;
        return;
    }
    else if (a >= MEMORY_START_C2A1 && a < MEMORY_START_C2A1 + MEMORY_SIZE_C2A1) {
        var off=a-MEMORY_START_C2A1;
        c2a1Uint8Array[off] = val>>24;c2a1Uint8Array[off+1] = val>>16;c2a1Uint8Array[off+2] = val>>8;c2a1Uint8Array[off+3] = val;
        return;
    }
    else if (a >= MEMORY_START_C1A1 && a < MEMORY_START_C1A1 + MEMORY_SIZE_C1A1) {
        var off=a-MEMORY_START_C1A1;
        c1a1Uint8Array[off] = val>>24;c1a1Uint8Array[off+1] = val>>16;c1a1Uint8Array[off+2] = val>>8;c1a1Uint8Array[off+3] = val;
        return;
    }
    else if (a >= MEMORY_START_C2A2 && a < MEMORY_START_C2A2 + MEMORY_SIZE_C2A2) {
        var off=a-MEMORY_START_C2A2;
        c2a2Uint8Array[off] = val>>24;c2a2Uint8Array[off+1] = val>>16;c2a2Uint8Array[off+2] = val>>8;c2a2Uint8Array[off+3] = val;
        return;
    }
    else if (a >= MEMORY_START_ROM_IMAGE && a < MEMORY_START_ROM_IMAGE + romLength) {
        alert('attempt to overwrite rom!');
        var off=a-MEMORY_START_ROM_IMAGE;
        romUint8Array[off] = val>>24;romUint8Array[off+1] = val>>16;romUint8Array[off+2] = val>>8;romUint8Array[off+3] = val;
        return;
    }
    else if (a >= MEMORY_START_C1A3 && a < MEMORY_START_C1A3 + MEMORY_SIZE_C1A3) {
        var off=a-MEMORY_START_C1A3;
        c1a3Uint8Array[off] = val>>24;c1a3Uint8Array[off+1] = val>>16;c1a3Uint8Array[off+2] = val>>8;c1a3Uint8Array[off+3] = val;
        return;
    }
    else if(a >= MEMORY_START_PIF && a < MEMORY_START_PIF + MEMORY_SIZE_PIF) {
        var off=a-MEMORY_START_PIF;
        pifUint8Array[off] = val>>24;pifUint8Array[off+1] = val>>16;pifUint8Array[off+2] = val>>8;pifUint8Array[off+3] = val;
        return;
	}
	else if(a >= MEMORY_START_GIO && a < MEMORY_START_GIO + MEMORY_SIZE_GIO_REG) {
        var off=a-MEMORY_START_GIO;
        gioUint8Array[off] = val>>24;gioUint8Array[off+1] = val>>16;gioUint8Array[off+2] = val>>8;gioUint8Array[off+3] = val;
        return;
	}
	else {
        throw('writing to invalid memory at ' + dec2hex(addr));
        //stopEmulator();
        var off=a&0x0000fffc;
        rdramUint8Array[off] = val>>24;rdramUint8Array[off+1] = val>>16;rdramUint8Array[off+2] = val>>8;rdramUint8Array[off+3] = val;
        return;
	}
}

/* same routine as storeWord, but store a byte */ 
function storeByte(val, addr, pc, isDelaySlot)
{
    var a = addr & 0x1FFFFFFF;

    if (a >= MEMORY_START_RDRAM && a < MEMORY_START_RDRAM + MEMORY_SIZE_RDRAM) {
        var off=a-MEMORY_START_RDRAM;
        rdramUint8Array[off] = val;
        return;    
    }
    else if (a >= MEMORY_START_SPMEM && a < MEMORY_START_SPMEM + MEMORY_SIZE_SPMEM) {
        var off=a-MEMORY_START_SPMEM;
        spMemUint8Array[off] = val;
        return;
    }
    else if (a >= MEMORY_START_RI && a < MEMORY_START_RI + MEMORY_SIZE_RI) {
        var off=a-MEMORY_START_RI;
        riUint8Array[off] = val;
        return;
    }
    else if (a >= MEMORY_START_MI && a < MEMORY_START_MI + MEMORY_SIZE_MI) {
        var off=a-MEMORY_START_MI;
        writeMI(off, val, pc, isDelaySlot);
        return;
    }
	else if(a >= MEMORY_START_RAMREGS8 && a < MEMORY_START_RAMREGS8 + MEMORY_SIZE_RAMREGS8) {
        var off=a-MEMORY_START_RAMREGS8;
        ramRegs8Uint8Array[off] = val;
        return;
	}
    else if (a >= MEMORY_START_RAMREGS4 && a < MEMORY_START_RAMREGS4 + MEMORY_SIZE_RAMREGS4) {
        var off=a-MEMORY_START_RAMREGS4;
        ramRegs4Uint8Array[off] = val;
        return;
    }
	else if(a >= MEMORY_START_RAMREGS0 && a < MEMORY_START_RAMREGS0 + MEMORY_SIZE_RAMREGS0) {
        var off=a-MEMORY_START_RAMREGS0;
        ramRegs0Uint8Array[off] = val;
        return;
	}
    else if (a >= MEMORY_START_SPREG_1 && a < MEMORY_START_SPREG_1 + MEMORY_SIZE_SPREG_1) {
        var off=a-MEMORY_START_SPREG_1;
        writeSPReg1(off, val, pc, isDelaySlot);
        return;
    }
    else if (a >= MEMORY_START_PI && a < MEMORY_START_PI + MEMORY_SIZE_PI) {
        var off=a-MEMORY_START_PI;
        writePI(off, val, pc, isDelaySlot);
        return; 
    }
    else if (a >= MEMORY_START_SI && a < MEMORY_START_SI + MEMORY_SIZE_SI) {
        var off=a-MEMORY_START_SI;
        writeSI(off, val, pc, isDelaySlot);
        return;
    }
    else if (a >= MEMORY_START_AI && a < MEMORY_START_AI + MEMORY_SIZE_AI) {
        var off=a-MEMORY_START_AI;
        writeAI(off, val, pc, isDelaySlot);
        return;
    }
    else if (a >= MEMORY_START_VI && a < MEMORY_START_VI + MEMORY_SIZE_VI) {
        var off=a-MEMORY_START_VI;
        writeVI(off, val, pc, isDelaySlot);
        return;
    }
    else if (a >= MEMORY_START_SPREG_2 && a < MEMORY_START_SPREG_2 + MEMORY_SIZE_SPREG_2) {
        var off=a-MEMORY_START_SPREG_2;
        writeSPReg2(off, val, pc, isDelaySlot);
        return;
    }
    else if (a >= MEMORY_START_DPC && a < MEMORY_START_DPC + MEMORY_SIZE_DPC) {
        var off=a-MEMORY_START_DPC;
        writeDPC(off, val, pc, isDelaySlot);
        return;
    }
    else if (a >= MEMORY_START_DPS && a < MEMORY_START_DPS + MEMORY_SIZE_DPS) {
        var off=a-MEMORY_START_DPS;
        dpsUint8Array[off] = val;
        return;
    }
    else if (a >= MEMORY_START_C2A1 && a < MEMORY_START_C2A1 + MEMORY_SIZE_C2A1) {
        var off=a-MEMORY_START_C2A1;
        c2a1Uint8Array[off] = val;
        return;
    }
    else if (a >= MEMORY_START_C1A1 && a < MEMORY_START_C1A1 + MEMORY_SIZE_C1A1) {
        var off=a-MEMORY_START_C1A1;
        c1a1Uint8Array[off] = val;
        return;
    }
    else if (a >= MEMORY_START_C2A2 && a < MEMORY_START_C2A2 + MEMORY_SIZE_C2A2) {
        var off=a-MEMORY_START_C2A2;
        c2a2Uint8Array[off] = val;
        return;
    }
    else if (a >= MEMORY_START_ROM_IMAGE && a < MEMORY_START_ROM_IMAGE + romLength) {
        alert('attempt to overwrite rom!');
        var off=a-MEMORY_START_ROM_IMAGE;
        romUint8Array[off] = val;
        return;
    }
    else if (a >= MEMORY_START_C1A3 && a < MEMORY_START_C1A3 + MEMORY_SIZE_C1A3) {
        var off=a-MEMORY_START_C1A3;
        c1a3Uint8Array[off] = val;
        return;
    }
    else if(a >= MEMORY_START_PIF && a < MEMORY_START_PIF + MEMORY_SIZE_PIF) {
        var off=a-MEMORY_START_PIF;
        pifUint8Array[off] = val;
        return;
	}
	else if(a >= MEMORY_START_GIO && a < MEMORY_START_GIO + MEMORY_SIZE_GIO_REG) {
        var off=a-MEMORY_START_GIO;
        gioUint8Array[off] = val;
        return;
	}
	else {
        throw('writing to invalid memory at ' + dec2hex(addr));
        //stopEmulator();
        var off=a&0x0000fffc;
        rdramUint8Array[off] = val;
        return;
	}
}

function storeHalf(val, addr, pc, isDelaySlot)
{
    var a = addr & 0x1FFFFFFF;

    if (a >= MEMORY_START_RDRAM && a < MEMORY_START_RDRAM + MEMORY_SIZE_RDRAM) {
        var off=a-MEMORY_START_RDRAM;
        rdramUint8Array[off] = val>>8;rdramUint8Array[off+1] = val;
        return;    
    }
    else if (a >= MEMORY_START_SPMEM && a < MEMORY_START_SPMEM + MEMORY_SIZE_SPMEM) {
        var off=a-MEMORY_START_SPMEM;
        spMemUint8Array[off] = val>>8;spMemUint8Array[off+1] = val;
        return;
    }
    else if (a >= MEMORY_START_RI && a < MEMORY_START_RI + MEMORY_SIZE_RI) {
        var off=a-MEMORY_START_RI;
        riUint8Array[off] = val>>8;riUint8Array[off+1] = val;
        return;
    }
    else if (a >= MEMORY_START_MI && a < MEMORY_START_MI + MEMORY_SIZE_MI) {
        var off=a-MEMORY_START_MI;
        writeMI(off, val, pc, isDelaySlot);
        return;
    }
	else if(a >= MEMORY_START_RAMREGS8 && a < MEMORY_START_RAMREGS8 + MEMORY_SIZE_RAMREGS8) {
        var off=a-MEMORY_START_RAMREGS8;
        ramRegs8Uint8Array[off] = val>>8;ramRegs8Uint8Array[off+1] = val;
        return;
	}
    else if (a >= MEMORY_START_RAMREGS4 && a < MEMORY_START_RAMREGS4 + MEMORY_SIZE_RAMREGS4) {
        var off=a-MEMORY_START_RAMREGS4;
        ramRegs4Uint8Array[off] = val>>8;ramRegs4Uint8Array[off+1] = val;
        return;
    }
	else if(a >= MEMORY_START_RAMREGS0 && a < MEMORY_START_RAMREGS0 + MEMORY_SIZE_RAMREGS0) {
        var off=a-MEMORY_START_RAMREGS0;
        ramRegs0Uint8Array[off] = val>>8;ramRegs0Uint8Array[off+1] = val;
        return;
	}
    else if (a >= MEMORY_START_SPREG_1 && a < MEMORY_START_SPREG_1 + MEMORY_SIZE_SPREG_1) {
        var off=a-MEMORY_START_SPREG_1;
        writeSPReg1(off, val, pc, isDelaySlot);
        return;
    }
    else if (a >= MEMORY_START_PI && a < MEMORY_START_PI + MEMORY_SIZE_PI) {
        var off=a-MEMORY_START_PI;
        writePI(off, val, pc, isDelaySlot);
        return; 
    }
    else if (a >= MEMORY_START_SI && a < MEMORY_START_SI + MEMORY_SIZE_SI) {
        var off=a-MEMORY_START_SI;
        writeSI(off, val, pc, isDelaySlot);
        return;
    }
    else if (a >= MEMORY_START_AI && a < MEMORY_START_AI + MEMORY_SIZE_AI) {
        var off=a-MEMORY_START_AI;
        writeAI(off, val, pc, isDelaySlot);
        return;
    }
    else if (a >= MEMORY_START_VI && a < MEMORY_START_VI + MEMORY_SIZE_VI) {
        var off=a-MEMORY_START_VI;
        writeVI(off, val, pc, isDelaySlot);
        return;
    }
    else if (a >= MEMORY_START_SPREG_2 && a < MEMORY_START_SPREG_2 + MEMORY_SIZE_SPREG_2) {
        var off=a-MEMORY_START_SPREG_2;
        writeSPReg2(off, val, pc, isDelaySlot);
        return;
    }
    else if (a >= MEMORY_START_DPC && a < MEMORY_START_DPC + MEMORY_SIZE_DPC) {
        var off=a-MEMORY_START_DPC;
        writeDPC(off, val, pc, isDelaySlot);
        return;
    }
    else if (a >= MEMORY_START_DPS && a < MEMORY_START_DPS + MEMORY_SIZE_DPS) {
        var off=a-MEMORY_START_DPS;
        dpsUint8Array[off] = val>>8;dpsUint8Array[off+1] = val;
        return;
    }
    else if (a >= MEMORY_START_C2A1 && a < MEMORY_START_C2A1 + MEMORY_SIZE_C2A1) {
        var off=a-MEMORY_START_C2A1;
        c2a1Uint8Array[off] = val>>8;c2a1Uint8Array[off+1] = val;
        return;
    }
    else if (a >= MEMORY_START_C1A1 && a < MEMORY_START_C1A1 + MEMORY_SIZE_C1A1) {
        var off=a-MEMORY_START_C1A1;
        c1a1Uint8Array[off] = val>>8;c1a1Uint8Array[off+1] = val;
        return;
    }
    else if (a >= MEMORY_START_C2A2 && a < MEMORY_START_C2A2 + MEMORY_SIZE_C2A2) {
        var off=a-MEMORY_START_C2A2;
        c2a2Uint8Array[off] = val>>8;c2a2Uint8Array[off+1] = val;
        return;
    }
    else if (a >= MEMORY_START_ROM_IMAGE && a < MEMORY_START_ROM_IMAGE + romLength) {
        alert('attempt to overwrite rom!');
        var off=a-MEMORY_START_ROM_IMAGE;
        romUint8Array[off] = val>>8;romUint8Array[off+1] = val;
        return;
    }
    else if (a >= MEMORY_START_C1A3 && a < MEMORY_START_C1A3 + MEMORY_SIZE_C1A3) {
        var off=a-MEMORY_START_C1A3;
        c1a3Uint8Array[off] = val>>8;c1a3Uint8Array[off+1] = val;
        return;
    }
    else if(a >= MEMORY_START_PIF && a < MEMORY_START_PIF + MEMORY_SIZE_PIF) {
        var off=a-MEMORY_START_PIF;
        pifUint8Array[off] = val>>8;pifUint8Array[off+1] = val;
        return;
	}
	else if(a >= MEMORY_START_GIO && a < MEMORY_START_GIO + MEMORY_SIZE_GIO_REG) {
        var off=a-MEMORY_START_GIO;
        gioUint8Array[off] = val>>8;gioUint8Array[off+1] = val;
        return;
	}
	else {
        throw('writing to invalid memory at ' + dec2hex(addr));
        //stopEmulator();
        var off=a&0x0000fffc;
        rdramUint8Array[off] = val>>8;rdramUint8Array[off+1] = val;
        return;
	}
}
