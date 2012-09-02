/*jslint bitwise: true, evil: true, undef: false, todo: true, browser: true, devel: true*/
/*globals Int32Array, ArrayBuffer, Float32Array, C1964jsMemory, C1964jsInterrupts */
/*globals C1964jsConstants, C1964jsPif, C1964jsDMA, Float64Array, C1964jsWebGL, cancelAnimFrame, C1964jsHelpers*/
/*globals dec2hex, Uint8Array, Uint16Array*/
/*globals CPU_instruction, requestAnimFrame*/

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

 Project started March 4, 2012
 For fastest results, use Chrome.

 NOTES:
 fixed bgtz bgtzl
 improved ldc1,sdc1 ..could still be bugged.
 Make sure if an opcode has multiple javascript lines that they are enclosed in {} because the opcode could be a delay slot.

 possible BUGS in original 1964cpp?:
 - JAL & JALR instr_index: upper 4 bits are from the pc's delay slot, not the current pc!
 write to si_status reg was clearing MI_INTR_SI unconditionally! this was
 causing sinus, plasma, hardcoded, mandelbrot zoomer, lightforce, and other demos to not work in 1964js.
 - mtc0 index should be cp0[index] & 0x80000000 | r[n] & 0x3f?
 - aValue is not applicable in jalr (dynabranch.h)
 - shift amounts of 0 truncate 64bit registers to 32bit. This is a possible bug in the original 1964cpp.
 1964 Masked loads and store addresses to make them aligned in load/store opcodes.
 Check_SW, setting DPC_END_REG equal to DPC_START_REG is risky initialization:
 setInt32(spReg1Uint8Array, SP_STATUS_REG, SP_STATUS_HALT);
 1964cpp's init sets SP_STATUS_REG to SP_STATUS_HALT but then clears it in RCP_Reset() ! 

 Use a typed-array but access it a byte at a time for endian-safety.
 Do not use the DataView .getInt16, getInt32, etc functions. These will ensure endian
 safety but they are a lot slower than accessing an Int8Array() by its index with the [] notation,
 presumably because Chrome (currently) doesn't compile anything other than nodes in the root DOM.
 DataView is also only supported in Chrome.

TODO:
 Long-term: more opcodes/timers/WinGL
 Short-term:
  - sdr, sdl, etc..
 AI_LEN_REG so SP Goldeneye Crap demo can work.
 dmult, and ddiv don't handle negative correctly. BigInt.js
 - Where are dadd and dmult?

 - Should handle exceptions in delay slots by catching thrown exceptions. 

Convention:
 When loading/storing registers back into n64 memory,
 do so byte-by-byte since typed-arrays aren't endian-safe.
 It's easier to get your head around and it's plenty fast.
 The hope is that the compiler will optimimize the pattern
 with a swap or bswap.
*/

var consts = new C1964jsConstants();

var C1964jsEmulator = function (userSettings) {

    "use strict";

//private:
    var offset = 0, i;

//public:
    this.settings = userSettings;

    this.request = undefined;
    this.debug = false;

    this.writeToDom = true;

    if (this.writeToDom === true) {
        this.code = window;
    } else {
        this.code = {};
    }

    this.vAddr = new Int32Array(4);
    this.cp0 = new Int32Array(32 * 4);
    this.cp1Buffer = new ArrayBuffer(32 * 4);
    this.cp1_i = new Int32Array(this.cp1Buffer);
    this.cp1_f = new Float32Array(this.cp1Buffer);
    this.cp1_f64 = new Float64Array(this.cp1Buffer);
    this.cp1Con = new Int32Array(32 * 4);
    this.LLbit = 0;
    this.tlb = new Array(32);
    for (i = 0; i < 32; i += 1) {
        this.tlb[i] = {};
    }

    //var docElement, errorElement, g, s, interval, keepRunning, stopCompiling, offset, programCounter, romLength, redrawDebug=0;
    this.terminate = false;

    this.NUM_CHANNELS = 1;
    this.NUM_SAMPLES = 40000;
    this.SAMPLE_RATE = 40000;
    this.isLittleEndian = 0;
    this.isBigEndian = 0;
    this.magic_number = -625000;
    this.forceRepaint = false; //presumably origin reg doesn't change because not double or triple-buffered (single-buffered)
    //main run loop
    this.doOnce = 0;
    this.kk = 0;
    this.TV_SYSTEM_NTSC = 1;
    this.TV_SYSTEM_PAL = 0;
    this.currentHack = 0;
    this.kfi = 512;

    //hook-up system objects
    this.memory = new C1964jsMemory(this);
    this.interrupts = new C1964jsInterrupts(this, this.cp0);
    this.pif = new C1964jsPif(this.memory.pifUint8Array);
    this.dma = new C1964jsDMA(this.memory, this.interrupts, this.pif);

    this.webGL = new C1964jsWebGL();

    this.log = function (message) {
        console.log(message);
    };

    this.init = function (buffer) {
        var k, x, i, y, r = new Int32Array(35 * 4), h = new Int32Array(35 * 4);

        cancelAnimFrame(this.request);
        this.currentHack = 0;
        this.dma.startTime = 0;
        this.kfi = 512;
        this.doOnce = 0;
        this.magic_number = -625000;
        this.flushDynaCache();
        this.showFB = true;
        this.webGL.hide3D();
        this.endianTest();
        this.helpers = new C1964jsHelpers(this.isLittleEndian);

        //runTest();

        r[0] = 0;
        r[1] = 0;
        r[2] = 0xd1731be9;
        r[3] = 0xd1731be9;
        r[4] = 0x001be9;
        r[5] = 0xf45231e5;
        r[6] = 0xa4001f0c;
        r[7] = 0xa4001f08;
        r[8] = 0x070; //check
        r[9] = 0;
        r[10] = 0x040;
        r[11] = 0xA4000040;
        r[12] = 0xd1330bc3;
        r[13] = 0xd1330bc3;
        r[14] = 0x025613a26;
        r[15] = 0x02ea04317;
        r[16] = 0;
        r[17] = 0;
        r[18] = 0;
        r[19] = 0;
        r[20] = 0;//TV System
        r[21] = 0;
        r[22] = 0;//CIC
        r[23] = 0x06;
        r[24] = 0;
        r[25] = 0xd73f2993;
        r[26] = 0;
        r[27] = 0;
        r[28] = 0;
        r[29] = 0xa4001ff0;
        r[30] = 0;
        r[31] = 0xa4001554;
        r[32] = 0; //LO for mult
        r[33] = 0; //HI for mult
        r[34] = 0; //to protect r0, write here. (r[34])

        this.memory.rom = buffer;
        //rom = new Uint8Array(buffer);
        this.memory.romUint8Array = buffer;
        this.docElement = document.getElementById("screen");
        this.errorElement = document.getElementById("error");

        //canvas
        this.c = document.getElementById("Canvas");
        this.ctx = this.c.getContext("2d");

        this.ImDat = this.ctx.createImageData(320, 240);

        //fill alpha
        i = 3;
        for (y = 0; y < 240; y += 1) {
            for (x = 0; x < 320; x += 1) {
                this.ImDat.data[i] = 255;
                i += 4;
            }
        }

        this.stopCompiling = false;
        this.keepRunning = 65535;

        this.byteSwap(this.memory.rom);
        //copy first 4096 bytes to sp_dmem and run from there.
        for (k = 0; k < 0x1000; k += 1) {
            this.memory.spMemUint8Array[k] = this.memory.rom[k];
        }

        r[20] = this.getTVSystem(this.memory.romUint8Array[0x3D]);
        r[22] = this.getCIC();

        this.cp0[consts.STATUS] = 0x70400004;
        this.cp0[consts.RANDOM] = 0x0000001f;
        this.cp0[consts.CONFIG] = 0x0006e463;
        this.cp0[consts.PREVID] = 0x00000b00;
        this.cp1Con[0] = 0x00000511;

        //set programCounter to start of SP_MEM and after the 64 byte ROM header.
        this.programCounter = 0xA4000040;

        this.memory.setInt32(this.memory.miUint8Array, consts.MI_VERSION_REG, 0x01010101);
        this.memory.setInt32(this.memory.riUint8Array, consts.RI_CONFIG_REG, 0x00000001);
        this.memory.setInt32(this.memory.viUint8Array, consts.VI_INTR_REG, 0x000003FF);
        this.memory.setInt32(this.memory.viUint8Array, consts.VI_V_SYNC_REG, 0x000000D1);
        this.memory.setInt32(this.memory.viUint8Array, consts.VI_H_SYNC_REG, 0x000D2047);

        //this.memory.setInt32(this.memory.spReg1Uint8Array, SP_STATUS_REG, SP_STATUS_HALT);
        //1964cpp sets this then clears it in RCP_Reset() ! 

        //set hi vals
        for (i = 0; i < 35; i += 1) {
            h[i] = r[i] >> 31;
        }

        this.startEmulator(r, h);
    };

    this.trace2 = function (address, opcode) {
        //comment this out for speed when not debugging
        console.log(address + ': ' + opcode);
    };

    //swap to 0x80371240
    this.byteSwap = function (rom) {
        var k, fmt, temp;

        console.log('byte swapping...');

        fmt = this.memory.getUint32(rom, 0);
        switch (fmt >>> 0) {
        case 0x37804012:
            if ((rom.byteLength % 2) !== 0) {
                alert('help: support odd byte lengths for this swap');
            }
            for (k = 0; k < rom.byteLength; k += 2) {
                temp = rom[k];
                rom[k] = rom[k + 1];
                rom[k + 1] = temp;
            }
            break;
        case 0x80371240:
            break;
        default:
            this.log('Unhandled byte order: 0x' + dec2hex(fmt));
            break;
        }
        console.log('swap done');
    };

    this.endianTest = function () {
        var ii = new ArrayBuffer(2), iiSetView = new Uint8Array(ii), iiView = new Uint16Array(ii);

        iiSetView[0] = 0xff;
        iiSetView[1] = 0x11;

        if (iiView[0] === 0x11FF) {
            this.log('You are on a little-endian system');
            this.isLittleEndian = 1;
            this.isBigEndian = 0;
        } else {
            this.log('You are on a big-endian system');
            this.isLittleEndian = 0;
            this.isBigEndian = 1;
        }
    };

    this.repaint = function (ctx, ImDat, origin) {
        var out, k = origin, i = 0, y, hi, lo;

        if (!this.showFB) {
            return;
        }

        out = ImDat.data;

        //endian-safe blit: rgba5551
        for (y = -240 * 320; y !== 0; y += 1) {
            hi = this.memory.rdramUint8Array[k];
            lo = this.memory.rdramUint8Array[k + 1];
            out[i] = (hi & 0xF8);
            k += 2;
            out[i + 1] = (((hi << 5) | (lo >>> 3)) & 0xF8);
            out[i + 2] = (lo << 2 & 0xF8);
            i += 4;
        }
        ctx.putImageData(ImDat, 0, 0);
    };

    this.runLoop = function (r, h) {

        if (this.terminate === false) {
            this.request = requestAnimFrame(this.runLoop.bind(this, r, h));
        }

        this.keepRunning = 180000;
        var pc, fnName, fn;

        this.interrupts.checkInterrupts();
        if (this.magic_number >= 0) {
            this.repaintWrapper();
            this.magic_number = -625000;
            this.cp0[consts.COUNT] += 625000;
            this.interrupts.triggerCompareInterrupt(0, false);
            this.interrupts.triggerVIInterrupt(0, false);
            this.interrupts.processException(this.programCounter);
        } else if ((this.cp0[consts.CAUSE] & this.cp0[consts.STATUS] & 0x0000FF00) !== 0) {
            this.interrupts.setException(consts.EXC_INT, 0, this.programCounter, false);
            this.interrupts.processException(this.programCounter);
        }

        pc = this.programCounter >>> 2;
        fnName = '_' + pc;
        fn = this.code[fnName];

        while (this.keepRunning > 0) {
            this.keepRunning -= 1;
            if (!fn) {
                fn = this.decompileBlock(this.programCounter);
            }
            fn = fn(r, h, this.memory, this);

            if (this.magic_number >= 0) {
                break;
            }
        }

        return this;
    };

    this.repaintWrapper = function () {
        this.repaint(this.ctx, this.ImDat, this.memory.getInt32(this.memory.viUint8Array, this.memory.viUint8Array, consts.VI_ORIGIN_REG) & 0x00FFFFFF);
    };

    this.startEmulator = function (r, h) {
        this.terminate = false;
        this.log('startEmulator');
        this.runLoop(r, h);
    };

    this.stopEmulator = function () {
        this.stopCompiling = true;
        this.terminate = true;
        this.log('stopEmulator');
        //clearInterval(interval);
    };

    this.getFnName = function (pc) {
        return '_' + (pc >>> 2);
    };

    this.decompileBlock = function (pc) {
        offset = 0;
        var g, s, instruction, opcode, string, fnName = '_' + (pc >>> 2);

        //Syntax: function(register, hiRegister, this.memory, this)
        if (this.writeToDom === true) {
            string = 'function ' + fnName + '(r, h, m, t){';
        } else {
            string = 'i1964js.code.' + fnName + '=function(r, h, m, t){';
        }

        while (!this.stopCompiling) {
            instruction = this.memory.loadWord(pc + offset);
            opcode = this[CPU_instruction[instruction >> 26 & 0x3f]](instruction);

            string += 't.magic_number+=1.0;';
            string += opcode;
            offset += 4;
            if (offset > 10000) {
                throw 'too many instructions! bailing.';
            }
        }
        this.stopCompiling = false;

        //close out the function
        string += 't.programCounter=' + ((pc + offset) >> 0);
        string += ';return t.code["' + this.getFnName((pc + offset) >> 0) + '"];}';

        if (this.writeToDom === true) {
            g = document.createElement('script');
            s = document.getElementsByTagName('script')[this.kk];
            this.kk += 1;
            s.parentNode.insertBefore(g, s);
            g.text = string;
        } else {
            eval(string);
        }

        return this.code[fnName];
    };

    this.r4300i_add = function (i) {
        return this.helpers.sLogic(i, '+');
    };

    this.r4300i_addu = function (i) {
        return this.helpers.sLogic(i, '+');
    };

    this.r4300i_sub = function (i) {
        return this.helpers.sLogic(i, '-');
    };

    this.r4300i_subu = function (i) {
        return this.helpers.sLogic(i, '-');
    };

    this.r4300i_or = function (i) {
        return this.helpers.dLogic(i, '|');
    };

    this.r4300i_xor = function (i) {
        return this.helpers.dLogic(i, '^');
    };

    this.r4300i_nor = function (i) {
        return '{' + this.helpers.tRD(i) + '=~(' + this.helpers.RS(i) + '|' + this.helpers.RT(i) + ');' + this.helpers.tRDH(i) + '=~(' + this.helpers.RSH(i) + '|' + this.helpers.RTH(i) + ');}';
    };

    this.r4300i_and = function (i) {
        return this.helpers.dLogic(i, '&');
    };

    this.r4300i_lui = function (i) {
        var temp = ((i & 0x0000ffff) << 16);
        return '{' + this.helpers.tRT(i) + '=' + temp + ';' + this.helpers.tRTH(i) + '=' + (temp >> 31) + ';}';
    };

    this.r4300i_lw = function (i) {
        return '{' + this.helpers.setVAddr(i) + this.helpers.tRT(i) + '=m.loadWord(t.vAddr);' + this.helpers.tRTH(i) + '=' + this.helpers.RT(i) + '>>31}';
    };

    this.r4300i_lwu = function (i) {
        return '{' + this.helpers.setVAddr(i) + this.helpers.tRT(i) + '=m.loadWord(t.vAddr);' + this.helpers.tRTH(i) + '=0}';
    };

    this.r4300i_sw = function (i, isDelaySlot) {
        var a, string = '{' + this.helpers.setVAddr(i) + 'm.storeWord(' + this.helpers.RT(i) + ',t.vAddr';

        //So we can process exceptions
        if (isDelaySlot === true) {
            a = (this.programCounter + offset + 4) | 0;
            string += ', ' + a + ', true)}';
        } else {
            a = (this.programCounter + offset) | 0;
            string += ', ' + a + ')}';
        }

        return string;
    };

    this.delaySlot = function (i, likely) {
        var pc, instruction, opcode, string;

        pc = (this.programCounter + offset + 4 + (this.helpers.soffset_imm(i) << 2)) | 0;
        instruction = this.memory.loadWord((this.programCounter + offset + 4) | 0);
        opcode = this[CPU_instruction[instruction >> 26 & 0x3f]](instruction, true);
        string = opcode;

        string += 't.magic_number+=1.0;t.programCounter=' + pc + ';return t.code["' + this.getFnName(pc) + '"];}';

        //if likely and if branch not taken, skip delay slot
        if (likely === false) {
            string += opcode;
            string += 't.magic_number+=1.0;';
        }

        offset += 4;
        return string;
    };

    this.r4300i_bne = function (i) {
        this.stopCompiling = true;
        var string = 'if ((' + this.helpers.RS(i) + '!==' + this.helpers.RT(i) + ')||(' + this.helpers.RSH(i) + '!==' + this.helpers.RTH(i) + ')){';

        string += this.delaySlot(i, false);
        return string;
    };

    this.r4300i_beq = function (i) {
        this.stopCompiling = true;
        var string = 'if ((' + this.helpers.RS(i) + '===' + this.helpers.RT(i) + ')&&(' + this.helpers.RSH(i) + '===' + this.helpers.RTH(i) + ')){';

        string += this.delaySlot(i, false);
        return string;
    };

    this.r4300i_bnel = function (i) {
        this.stopCompiling = true;
        var string = 'if ((' + this.helpers.RS(i) + '!==' + this.helpers.RT(i) + ')||(' + this.helpers.RSH(i) + '!==' + this.helpers.RTH(i) + ')){';

        string += this.delaySlot(i, true);
        return string;
    };

    this.r4300i_blez = function (i) {
        this.stopCompiling = true;
        var string = 'if ((' + this.helpers.RSH(i) + '<0)||((' + this.helpers.RSH(i) + '===0)&&(' + this.helpers.RS(i) + '===0))){';

        string += this.delaySlot(i, false);
        return string;
    };

    this.r4300i_blezl = function (i) {
        this.stopCompiling = true;
        var string = 'if ((' + this.helpers.RSH(i) + '<0)||((' + this.helpers.RSH(i) + '===0)&&(' + this.helpers.RS(i) + '===0))){';

        string += this.delaySlot(i, true);
        return string;
    };

    this.r4300i_bgez = function (i) {
        this.stopCompiling = true;
        var string = 'if (' + this.helpers.RSH(i) + '>=0){';

        string += this.delaySlot(i, false);
        return string;
    };

    this.r4300i_bgezl = function (i) {
        this.stopCompiling = true;
        var string = 'if (' + this.helpers.RSH(i) + '>=0){';

        string += this.delaySlot(i, true);
        return string;
    };

    this.r4300i_bgtzl = function (i) {
        this.stopCompiling = true;
        var string = 'if ((' + this.helpers.RSH(i) + '>0)||((' + this.helpers.RSH(i) + '===0)&&(' + this.helpers.RS(i) + '!==0))){';

        string += this.delaySlot(i, true);
        return string;
    };

    this.r4300i_bltzl = function (i) {
        this.stopCompiling = true;
        var string = 'if (' + this.helpers.RSH(i) + '<0){';

        string += this.delaySlot(i, true);
        return string;
    };

    this.r4300i_bgezal = function (i) {
        this.stopCompiling = true;
        var link, string = 'if (' + this.helpers.RSH(i) + '>=0){';

        link = (this.programCounter + offset + 8) >> 0;
        string += 'r[31]=' + link + ';';
        string += 'h[31]=' + (link >> 31) + ';';

        string += this.delaySlot(i, false);
        return string;
    };

    this.r4300i_bgezall = function (i) {
        this.stopCompiling = true;
        var link, string = 'if (' + this.helpers.RSH(i) + '>=0){';

        link = (this.programCounter + offset + 8) >> 0;
        string += 'r[31]=' + link + ';';
        string += 'h[31]=' + (link >> 31) + ';';

        string += this.delaySlot(i, true);
        return string;
    };

    this.r4300i_bltz = function (i) {
        this.stopCompiling = true;
        var string = 'if (' + this.helpers.RSH(i) + '<0){';

        string += this.delaySlot(i, false);
        return string;
    };

    this.r4300i_bgtz = function (i) {
        this.stopCompiling = true;
        var string = 'if ((' + this.helpers.RSH(i) + '>0)||((' + this.helpers.RSH(i) + '===0)&&(' + this.helpers.RS(i) + '!==0))){';

        string += this.delaySlot(i, false);
        return string;
    };

    this.r4300i_beql = function (i) {
        this.stopCompiling = true;
        var string = 'if ((' + this.helpers.RS(i) + '===' + this.helpers.RT(i) + ')&&(' + this.helpers.RSH(i) + '===' + this.helpers.RTH(i) + ')){';

        string += this.delaySlot(i, true);
        return string;
    };

    this.r4300i_COP1_bc1f = function (i) {
        this.stopCompiling = true;
        var string = 'if((t.cp1Con[31]&0x00800000)===0){';

        string += this.delaySlot(i, false);
        return string;
    };

    this.r4300i_COP1_bc1t = function (i) {
        this.stopCompiling = true;
        var string = 'if((t.cp1Con[31]&0x00800000)!==0){';

        string += this.delaySlot(i, false);
        return string;
    };

    this.r4300i_COP1_bc1tl = function (i) {
        this.stopCompiling = true;
        var string = 'if((t.cp1Con[31]&0x00800000)!==0){';

        string += this.delaySlot(i, true);
        return string;
    };

    this.r4300i_COP1_bc1fl = function (i) {
        this.stopCompiling = true;
        var string = 'if((t.cp1Con[31]&0x00800000)===0){';

        string += this.delaySlot(i, true);
        return string;
    };

    this.r4300i_j = function (i) {
        this.stopCompiling = true;

        var opcode, instruction, string = '{', instr_index = (((((this.programCounter + offset + 4) & 0xF0000000)) | ((i & 0x03FFFFFF) << 2)) | 0);

        //delay slot
        instruction = this.memory.loadWord((this.programCounter + offset + 4) | 0);

        string += 't.magic_number+=1.0;';
        if (((instr_index >> 0) === (this.programCounter + offset) >> 0) && (instruction === 0)) {
            string += 't.magic_number=0;t.keepRunning=0;';
        }

        opcode = this[CPU_instruction[instruction >> 26 & 0x3f]](instruction, true);
        string += opcode;
        string += 't.programCounter=' + instr_index + ';return t.code["' + this.getFnName(instr_index) + '"];}';

        return string;
    };

    this.r4300i_jal = function (i) {
        this.stopCompiling = true;

        var pc, opcode, instruction, string = '{', instr_index = (((((this.programCounter + offset + 4) & 0xF0000000)) | ((i & 0x03FFFFFF) << 2)) | 0);
        //delay slot
        instruction = this.memory.loadWord((this.programCounter + offset + 4) | 0);
        opcode = this[CPU_instruction[instruction >> 26 & 0x3f]](instruction, true);
        string += opcode;
        pc = (this.programCounter + offset + 8) | 0;
        string += 't.magic_number+=1.0;';
        string += 't.programCounter=' + instr_index + ';r[31]=' + pc + ';h[31]=' + (pc >> 31) + ';return t.code["' + this.getFnName(instr_index) + '"];}';

        return string;
    };

    //should we set the programCounter after the delay slot or before it?
    this.r4300i_jalr = function (i) {
        this.stopCompiling = true;

        var instruction, opcode, link, string = '{var temp=' + this.helpers.RS(i) + ';';
        link = (this.programCounter + offset + 8) >> 0;
        string += this.helpers.tRD(i) + '=' + link + ';' + this.helpers.tRDH(i) + '=' + (link >> 31) + ';';

        //delay slot
        instruction = this.memory.loadWord((this.programCounter + offset + 4) | 0);
        opcode = this[CPU_instruction[instruction >> 26 & 0x3f]](instruction, true);
        string += opcode;
        string += 't.magic_number+=1.0;';
        string += 't.programCounter=temp;return t.code[t.getFnName(temp)];}';

        return string;
    };

    this.r4300i_jr = function (i) {
        this.stopCompiling = true;

        var instruction, opcode, string = '{var temp=' + this.helpers.RS(i) + ';';
        //delay slot
        instruction = this.memory.loadWord((this.programCounter + offset + 4) | 0);
        opcode = this[CPU_instruction[instruction >> 26 & 0x3f]](instruction, true);
        string += opcode;
        string += 't.magic_number+=1.0;';
        string += 't.programCounter=temp;return t.code[t.getFnName(temp)];}';

        return string;
    };

    this.UNUSED = function (i) {
        this.log('warning: UNUSED');
        return '';
    };

    this.r4300i_COP0_eret = function (i) {
        this.stopCompiling = true;

        var string = '{if((t.cp0[' + consts.STATUS + ']&' + consts.ERL + ')!==0){alert("error epc");t.programCounter=t.cp0[' + consts.ERROREPC + '];';
        string += 't.cp0[' + consts.STATUS + ']&=~' + consts.ERL + ';}else{t.programCounter=t.cp0[' + consts.EPC + '];t.cp0[' + consts.STATUS + ']&=~' + consts.EXL + ';}';
        string += 't.LLbit=0;return t.code[t.getFnName(t.programCounter)];}';

        return string;
    };

    this.r4300i_COP0_mtc0 = function (i, isDelaySlot) {
        var delaySlot, lpc;

        if (isDelaySlot === true) {
            lpc = (this.programCounter + offset + 4) | 0;
            delaySlot = "true";
        } else {
            lpc = (this.programCounter + offset) | 0;
            delaySlot = "false";
        }

        return 't.helpers.inter_mtc0(r,' + this.helpers.fs(i) + ',' + this.helpers.rt(i) + ',' + delaySlot + ',' + lpc + ',t.cp0,t.interrupts);';
    };

    this.r4300i_sll = function (i) {
        if ((i & 0x001FFFFF) === 0) {
            return '';
        }

        return '{' + this.helpers.tRD(i) + '=' + this.helpers.RT(i) + '<<' + this.helpers.sa(i) + ';' + this.helpers.tRDH(i) + '=' + this.helpers.RD(i) + '>>31}';
    };

    this.r4300i_srl = function (i) {
        return '{' + this.helpers.tRD(i) + '=' + this.helpers.RT(i) + '>>>' + this.helpers.sa(i) + ';' + this.helpers.tRDH(i) + '=' + this.helpers.RD(i) + '>>31}';
    };

    this.r4300i_ori = function (i) {
        return '{' + this.helpers.tRT(i) + '=' + this.helpers.RS(i) + '|' + this.helpers.offset_imm(i) + ';' + this.helpers.tRTH(i) + '=' + this.helpers.RSH(i) + ';}';
    };

    this.r4300i_xori = function (i) {
        return '{' + this.helpers.tRT(i) + '=' + this.helpers.RS(i) + '^' + this.helpers.offset_imm(i) + ';' + this.helpers.tRTH(i) + '=' + this.helpers.RSH(i) + '^0;}';
    };

    this.r4300i_andi = function (i) {
        return '{' + this.helpers.tRT(i) + '=' + this.helpers.RS(i) + '&' + this.helpers.offset_imm(i) + ';' + this.helpers.tRTH(i) + '=0;}';
    };

    this.r4300i_addi = function (i) {
        return '{' + this.helpers.tRT(i) + '=' + this.helpers.RS(i) + '+' + this.helpers.soffset_imm(i) + ';' + this.helpers.tRTH(i) + '=' + this.helpers.RT(i) + '>>31;}';
    };

    this.r4300i_addiu = function (i) {
        return '{' + this.helpers.tRT(i) + '=' + this.helpers.RS(i) + '+' + this.helpers.soffset_imm(i) + ';' + this.helpers.tRTH(i) + '=' + this.helpers.RT(i) + '>>31;}';
    };

    this.r4300i_slt = function (i) {
        return '{if(' + this.helpers.RSH(i) + '>' + this.helpers.RTH(i) + ')' + this.helpers.tRD(i) + '=0;'
            + 'else if(' + this.helpers.RSH(i) + '<' + this.helpers.RTH(i) + ')' + this.helpers.tRD(i) + '=1;'
            + 'else if(' + this.helpers.uRS(i) + '<' + this.helpers.uRT(i) + ')' + this.helpers.tRD(i) + '=1;'
            + 'else ' + this.helpers.tRD(i) + '=0;' + this.helpers.tRDH(i) + '=0;}';
    };

    this.r4300i_sltu = function (i) {
        return '{if(' + this.helpers.uRSH(i) + '>' + this.helpers.uRTH(i) + ')' + this.helpers.tRD(i) + '=0;'
            + 'else if(' + this.helpers.uRSH(i) + '<' + this.helpers.uRTH(i) + ')' + this.helpers.tRD(i) + '=1;'
            + 'else if(' + this.helpers.uRS(i) + '<' + this.helpers.uRT(i) + ')' + this.helpers.tRD(i) + '=1;'
            + 'else ' + this.helpers.tRD(i) + '=0;' + this.helpers.tRDH(i) + '=0;}';
    };

    this.r4300i_slti = function (i) {
        var uoffset_imm_lo, soffset_imm_hi = (this.helpers.soffset_imm(i)) >> 31;
        uoffset_imm_lo = (this.helpers.soffset_imm(i)) >>> 0;

        return '{if(' + this.helpers.RSH(i) + '>' + soffset_imm_hi + ')' + this.helpers.tRT(i) + '=0;'
            + 'else if(' + this.helpers.RSH(i) + '<' + soffset_imm_hi + ')' + this.helpers.tRT(i) + '=1;'
            + 'else if(' + this.helpers.uRS(i) + '<' + uoffset_imm_lo + ')' + this.helpers.tRT(i) + '=1;'
            + 'else ' + this.helpers.tRT(i) + '=0;' + this.helpers.tRTH(i) + '=0;}';
    };

    this.r4300i_sltiu = function (i) {
        var uoffset_imm_lo, uoffset_imm_hi = (this.helpers.soffset_imm(i) >> 31) >>> 0;
        uoffset_imm_lo = (this.helpers.soffset_imm(i)) >>> 0;

        return '{if(' + this.helpers.uRSH(i) + '>' + uoffset_imm_hi + ')' + this.helpers.tRT(i) + '=0;'
            + 'else if(' + this.helpers.uRSH(i) + '<' + uoffset_imm_hi + ')' + this.helpers.tRT(i) + '=1;'
            + 'else if(' + this.helpers.uRS(i) + '<' + uoffset_imm_lo + ')' + this.helpers.tRT(i) + '=1;'
            + 'else ' + this.helpers.tRT(i) + '=0;' + this.helpers.tRTH(i) + '=0;}';
    };

    this.r4300i_cache = function (i) {
        this.log('todo: r4300i_cache');
        return '';
    };

    this.r4300i_multu = function (i) {
        return 't.helpers.inter_multu(r,h,' + i + ');';
    };

    this.r4300i_mult = function (i) {
        return 't.helpers.inter_mult(r,h,' + i + ');';
    };

    this.r4300i_mflo = function (i) {
        return '{' + this.helpers.tRD(i) + '=r[32];' + this.helpers.tRDH(i) + '=h[32];}';
    };

    this.r4300i_mfhi = function (i) {
        return '{' + this.helpers.tRD(i) + '=r[33];' + this.helpers.tRDH(i) + '=h[33];}';
    };

    this.r4300i_mtlo = function (i) {
        return '{r[32]=' + this.helpers.RS(i) + ';h[32]=' + this.helpers.RSH(i) + ';}';
    };

    this.r4300i_mthi = function (i) {
        return '{r[33]=' + this.helpers.RS(i) + ';h[33]=' + this.helpers.RSH(i) + ';}';
    };

    //todo: timing
    this.getCountRegister = function () {
        return 1;
    };

    this.r4300i_COP0_mfc0 = function (i) {
        var string = '{';

        switch (this.helpers.fs(i)) {
        case consts.RANDOM:
            alert('RANDOM');
            break;
        case consts.COUNT:
            //string += 't.cp0[' + this.helpers.fs(i) + ']=getCountRegister();';
            break;
        default:
            break;
        }
        string += this.helpers.tRT(i) + '=t.cp0[' + this.helpers.fs(i) + '];' + this.helpers.tRTH(i) + '=t.cp0[' + this.helpers.fs(i) + ']>>31;}';
        return string;
    };

    this.r4300i_lb = function (i) {
        return '{' + this.helpers.setVAddr(i) + this.helpers.tRT(i) + '=(m.loadByte(t.vAddr)<<24)>>24;' + this.helpers.tRTH(i) + '=' + this.helpers.RT(i) + '>>31}';
    };

    this.r4300i_lbu = function (i) {
        return '{' + this.helpers.setVAddr(i) + this.helpers.tRT(i) + '=(m.loadByte(t.vAddr))&0x000000ff;' + this.helpers.tRTH(i) + '=0;}';
    };

    this.r4300i_lh = function (i) {
        return '{' + this.helpers.setVAddr(i) + this.helpers.tRT(i) + '=(m.loadHalf(t.vAddr)<<16)>>16;' + this.helpers.tRTH(i) + '=' + this.helpers.RT(i) + '>>31}';
    };

    this.r4300i_lhu = function (i) {
        return '{' + this.helpers.setVAddr(i) + this.helpers.tRT(i) + '=(m.loadHalf(t.vAddr))&0x0000ffff;' + this.helpers.tRTH(i) + '=0;}';
    };

    this.r4300i_sb = function (i) {
        return '{' + this.helpers.setVAddr(i) + 'm.storeByte(' + this.helpers.RT(i) + ',t.vAddr);}';
    };

    this.r4300i_sh = function (i) {
        return '{' + this.helpers.setVAddr(i) + 'm.storeHalf(' + this.helpers.RT(i) + ',t.vAddr);}';
    };

    this.r4300i_srlv = function (i) {
        return '{' + this.helpers.tRD(i) + '=' + this.helpers.RT(i) + '>>>(' + this.helpers.RS(i) + '&0x1f);' + this.helpers.tRDH(i) + '=' + this.helpers.RD(i) + '>>31;}';
    };

    this.r4300i_sllv = function (i) {
        return '{' + this.helpers.tRD(i) + '=' + this.helpers.RT(i) + '<<(' + this.helpers.RS(i) + '&0x1f);' + this.helpers.tRDH(i) + '=' + this.helpers.RD(i) + '>>31;}';
    };

    this.r4300i_srav = function (i) {
        //optimization: r[hi] can safely right-shift rt
        return '{' + this.helpers.tRD(i) + '=' + this.helpers.RT(i) + '>>(' + this.helpers.RS(i) + '&0x1f);' + this.helpers.tRDH(i) + '=' + this.helpers.RT(i) + '>>31;}';
    };

    this.r4300i_COP1_cfc1 = function (i) {
        if (this.helpers.fs(i) === 0 || this.helpers.fs(i) === 31) {
            return '{' + this.helpers.tRT(i) + '=t.cp1Con[' + this.helpers.fs(i) + '];' + this.helpers.tRTH(i) + '=t.cp1Con[' + this.helpers.fs(i) + ']>>31;}';
        }
    };

    this.r4300i_COP1_ctc1 = function (i) {
        //incomplete:
        if (this.helpers.fs(i) === 31) {
            return 't.cp1Con[31]=' + this.helpers.RT(i) + ';';
        }
    };

    this.r4300i_ld = function (i) {
        var string = '{' + this.helpers.setVAddr(i) + this.helpers.tRT(i) + '=m.loadWord((t.vAddr+4)|0);' + this.helpers.tRTH(i) + '=m.loadWord(t.vAddr);}';

        return string;
    };

    this.r4300i_lld = function (i) {
        var string = '{' + this.helpers.setVAddr(i) + this.helpers.tRT(i) + '=m.loadWord((t.vAddr+4)|0);' + this.helpers.tRTH(i) + '=m.loadWord(t.vAddr);t.LLbit=1;}';

        return string;
    };

    //address error exceptions in ld and sd are weird since this is split up 
    //into 2 reads or writes. i guess they're fatal exceptions, so
    //doesn't matter. 
    this.r4300i_sd = function (i, isDelaySlot) {
        //lo
        var a, string = '{' + this.helpers.setVAddr(i) + 'm.storeWord(' + this.helpers.RT(i) + ',(t.vAddr+4)|0';

        //So we can process exceptions
        if (isDelaySlot === true) {
            a = (this.programCounter + offset + 4) | 0;
            string += ', ' + a + ', true);';
        } else {
            a = (this.programCounter + offset) | 0;
            string += ', ' + a + ');';
        }

        //hi
        string += 'm.storeWord(' + this.helpers.RTH(i) + ',t.vAddr';

        //So we can process exceptions
        if (isDelaySlot === true) {
            a = (this.programCounter + offset + 4) | 0;
            string += ', ' + a + ', true);';
        } else {
            a = (this.programCounter + offset) | 0;
            string += ', ' + a + ');';
        }

        string += '}';

        return string;
    };

    this.r4300i_dmultu = function (i) {
        return 't.helpers.inter_dmultu(r,h,' + i + ');';
    };

    this.r4300i_dsll32 = function (i) {
        return '{' + this.helpers.tRDH(i) + '=' + this.helpers.RT(i) + '<<' + this.helpers.sa(i) + ';' + this.helpers.tRD(i) + '=0;}';
    };

    this.r4300i_dsra32 = function (i) {
        return '{' + this.helpers.tRD(i) + '=' + this.helpers.RTH(i) + '>>' + this.helpers.sa(i) + ';' + this.helpers.tRDH(i) + '=' + this.helpers.RTH(i) + '>>31;}';
    };

    this.r4300i_ddivu = function (i) {
        return 't.helpers.inter_ddivu(r,h,' + i + ');';
    };

    this.r4300i_ddiv = function (i) {
        return 't.helpers.inter_ddiv(r,h,' + i + ');';
    };

    this.r4300i_dadd = function (i) {
        this.log('todo: dadd');

        return '';
    };

    this.r4300i_break = function (i) {
        this.log('todo: break');
        return '';
    };

    this.r4300i_COP0_tlbwi = function (i) {
        //var index = t.cp0[INDEX] & NTLBENTRIES;
        this.log('todo: tlbwi');
        return '';
    };

    this.r4300i_div = function (i) {
        return 't.helpers.inter_div(r,h,' + i + ');';
    };

    this.r4300i_divu = function (i) {
        return 't.helpers.inter_divu(r,h,' + i + ');';
    };

    this.r4300i_sra = function (i) {
        //optimization: sra's r[hi] can safely right-shift RT.
        return '{' + this.helpers.tRD(i) + '=' + this.helpers.RT(i) + '>>' + this.helpers.sa(i) + ';' + this.helpers.tRDH(i) + '=' + this.helpers.RT(i) + '>>31;}';
    };

    this.r4300i_COP0_tlbp = function (i) {
        this.log('todo: tlbp');
        return '';
    };

    this.r4300i_COP0_tlbr = function (i) {
        this.log('todo: tlbr');
        return '';
    };

    this.r4300i_lwl = function (i) {
        var string = '{' + this.helpers.setVAddr(i);

        string += 'var vAddrAligned=(t.vAddr&0xfffffffc)|0;var value=m.loadWord(vAddrAligned);';
        string += 'switch(t.vAddr&3){case 0:' + this.helpers.tRT(i) + '=value;break;';
        string += 'case 1:' + this.helpers.tRT(i) + '=(' + this.helpers.RT(i) + '&0x000000ff)|((value<<8)>>>0);break;';
        string += 'case 2:' + this.helpers.tRT(i) + '=(' + this.helpers.RT(i) + '&0x0000ffff)|((value<<16)>>>0);break;';
        string += 'case 3:' + this.helpers.tRT(i) + '=(' + this.helpers.RT(i) + '&0x00ffffff)|((value<<24)>>>0);break;}';
        string += this.helpers.tRTH(i) + '=' + this.helpers.RT(i) + '>>31;}';

        return string;
    };

    this.r4300i_lwr = function (i) {
        var string = '{' + this.helpers.setVAddr(i);

        string += 'var vAddrAligned=(t.vAddr&0xfffffffc)|0;var value=m.loadWord(vAddrAligned);';
        string += 'switch(t.vAddr&3){case 3:' + this.helpers.tRT(i) + '=value;break;';
        string += 'case 2:' + this.helpers.tRT(i) + '=(' + this.helpers.RT(i) + '&0xff000000)|(value>>>8);break;';
        string += 'case 1:' + this.helpers.tRT(i) + '=(' + this.helpers.RT(i) + '&0xffff0000)|(value>>>16);break;';
        string += 'case 0:' + this.helpers.tRT(i) + '=(' + this.helpers.RT(i) + '&0xffffff00)|(value>>>24);break;}';
        string += this.helpers.tRTH(i) + '=' + this.helpers.RT(i) + '>>31;}';

        return string;
    };

    this.r4300i_swl = function (i) {
        var string = '{' + this.helpers.setVAddr(i);

        string += 'var vAddrAligned=(t.vAddr&0xfffffffc)|0;var value=m.loadWord(vAddrAligned);';
        string += 'switch(t.vAddr&3){case 0:value=' + this.helpers.RT(i) + ';break;';
        string += 'case 1:value=((value&0xff000000)|(' + this.helpers.RT(i) + '>>>8));break;';
        string += 'case 2:value=((value&0xffff0000)|(' + this.helpers.RT(i) + '>>>16));break;';
        string += 'case 3:value=((value&0xffffff00)|(' + this.helpers.RT(i) + '>>>24));break;}';
        string += 'm.storeWord(value,vAddrAligned,false);}';

        return string;
    };

    this.r4300i_swr = function (i) {
        var string = '{' + this.helpers.setVAddr(i);

        string += 'var vAddrAligned=(t.vAddr&0xfffffffc)|0;var value=m.loadWord(vAddrAligned);';
        string += 'switch(t.vAddr&3){case 3:value=' + this.helpers.RT(i) + ';break;';
        string += 'case 2:value=((value & 0x000000FF)|((' + this.helpers.RT(i) + '<<8)>>>0));break;';
        string += 'case 1:value=((value & 0x0000FFFF)|((' + this.helpers.RT(i) + '<<16)>>>0));break;';
        string += 'case 0:value=((value & 0x00FFFFFF)|((' + this.helpers.RT(i) + '<<24)>>>0));break;}';
        string += 'm.storeWord(value,vAddrAligned,false);}';

        return string;
    };

    this.r4300i_lwc1 = function (i) {
        return '{' + this.helpers.setVAddr(i) + 't.cp1_i[' + this.helpers.FT32ArrayView(i) + ']=m.loadWord(t.vAddr);}';
    };

    this.r4300i_ldc1 = function (i) {
        var string = '{' + this.helpers.setVAddr(i) + 't.cp1_i[' + this.helpers.FT32ArrayView(i) + ']=m.loadWord((t.vAddr+4)|0);';
        string += 't.cp1_i[' + this.helpers.FT32HIArrayView(i) + ']=m.loadWord((t.vAddr)|0);}';

        return string;
    };

    this.r4300i_swc1 = function (i, isDelaySlot) {
        var a, string = '{' + this.helpers.setVAddr(i) + 'm.storeWord(t.cp1_i[' + this.helpers.FT32ArrayView(i) + '],t.vAddr';

        //So we can process exceptions
        if (isDelaySlot === true) {
            a = (this.programCounter + offset + 4) | 0;
            string += ', ' + a + ', true)}';
        } else {
            a = (this.programCounter + offset) | 0;
            string += ', ' + a + ')}';
        }

        return string;
    };

    this.r4300i_sdc1 = function (i, isDelaySlot) {
        var a, string = '{' + this.helpers.setVAddr(i) + 'm.storeWord(t.cp1_i[' + this.helpers.FT32ArrayView(i) + '],(t.vAddr+4)|0';

        //So we can process exceptions
        if (isDelaySlot === true) {
            a = (this.programCounter + offset + 4) | 0;
            string += ', ' + a + ', true);';
        } else {
            a = (this.programCounter + offset) | 0;
            string += ', ' + a + ');';
        }

        string += 'm.storeWord(t.cp1_i[' + this.helpers.FT32HIArrayView(i) + '],(t.vAddr)|0';

        //So we can process exceptions
        if (isDelaySlot === true) {
            a = (this.programCounter + offset + 4) | 0;
            string += ', ' + a + ', true);';
        } else {
            a = (this.programCounter + offset) | 0;
            string += ', ' + a + ');';
        }

        string += '}';

        return string;
    };

    this.r4300i_COP1_mtc1 = function (i) {
        return 't.cp1_i[' + this.helpers.FS32ArrayView(i) + ']=' + this.helpers.RT(i) + ';';
    };

    this.r4300i_COP1_mfc1 = function (i) {
        return '{' + this.helpers.tRT(i) + '=t.cp1_i[' + this.helpers.FS32ArrayView(i) + '];' + this.helpers.tRTH(i) + '=' + this.helpers.RT(i) + '>>31;}';
    };

    this.r4300i_COP1_cvts_w = function (i) {
        return 't.cp1_f[' + this.helpers.FD32ArrayView(i) + ']=t.cp1_i[' + this.helpers.FS32ArrayView(i) + '];';
    };

    this.r4300i_COP1_cvtw_s = function (i) {
        return 't.cp1_i[' + this.helpers.FD32ArrayView(i) + ']=t.cp1_f[' + this.helpers.FS32ArrayView(i) + '];';
    };

    this.r4300i_COP1_div_s = function (i) {
        return 't.cp1_f[' + this.helpers.FD32ArrayView(i) + ']=t.cp1_f[' + this.helpers.FS32ArrayView(i) + ']/t.cp1_f[' + this.helpers.FT32ArrayView(i) + '];';
    };

    this.r4300i_COP1_div_d = function (i) {
        return 't.cp1_f64[' + this.helpers.FD64ArrayView(i) + ']=t.cp1_f64[' + this.helpers.FS64ArrayView(i) + ']/t.cp1_f64[' + this.helpers.FT64ArrayView(i) + '];';
    };

    this.r4300i_COP1_mul_s = function (i) {
        return 't.cp1_f[' + this.helpers.FD32ArrayView(i) + ']=t.cp1_f[' + this.helpers.FS32ArrayView(i) + ']*t.cp1_f[' + this.helpers.FT32ArrayView(i) + '];';
    };

    this.r4300i_COP1_mul_d = function (i) {
        return 't.cp1_f64[' + this.helpers.FD64ArrayView(i) + ']=t.cp1_f64[' + this.helpers.FS64ArrayView(i) + ']*t.cp1_f64[' + this.helpers.FT64ArrayView(i) + '];';
    };

    this.r4300i_COP1_mov_s = function (i) {
        return 't.cp1_i[' + this.helpers.FD32ArrayView(i) + ']=t.cp1_i[' + this.helpers.FS32ArrayView(i) + '];';
    };

    this.r4300i_COP1_mov_d = function (i) {
        return 't.cp1_f64[' + this.helpers.FD32ArrayView(i) + ']=t.cp1_f64[' + this.helpers.FS32ArrayView(i) + '];';
    };

    this.r4300i_COP1_add_s = function (i) {
        return 't.cp1_f[' + this.helpers.FD32ArrayView(i) + ']=t.cp1_f[' + this.helpers.FS32ArrayView(i) + ']+t.cp1_f[' + this.helpers.FT32ArrayView(i) + '];';
    };

    this.r4300i_COP1_sub_s = function (i) {
        return 't.cp1_f[' + this.helpers.FD32ArrayView(i) + ']=t.cp1_f[' + this.helpers.FS32ArrayView(i) + ']-t.cp1_f[' + this.helpers.FT32ArrayView(i) + '];';
    };

    this.r4300i_COP1_cvtd_s = function (i) {
        return 't.cp1_f64[' + this.helpers.FD64ArrayView(i) + ']=t.cp1_f[' + this.helpers.FS32ArrayView(i) + '];';
    };

    this.r4300i_COP1_cvtd_w = function (i) {
        return 't.cp1_f64[' + this.helpers.FD64ArrayView(i) + ']=t.cp1_i[' + this.helpers.FS32ArrayView(i) + '];';
    };

    this.r4300i_COP1_cvts_d = function (i) {
        return 't.cp1_f[' + this.helpers.FD32ArrayView(i) + ']=t.cp1_f64[' + this.helpers.FS64ArrayView(i) + '];';
    };

    this.r4300i_COP1_cvtw_d = function (i) {
        return 't.cp1_i[' + this.helpers.FD32ArrayView(i) + ']=t.cp1_f64[' + this.helpers.FS64ArrayView(i) + '];';
    };

    this.r4300i_COP1_add_d = function (i) {
        return 't.cp1_f64[' + this.helpers.FD64ArrayView(i) + ']=t.cp1_f64[' + this.helpers.FS64ArrayView(i) + ']+t.cp1_f64[' + this.helpers.FT64ArrayView(i) + '];';
    };

    this.r4300i_COP1_sub_d = function (i) {
        return 't.cp1_f64[' + this.helpers.FD64ArrayView(i) + ']=t.cp1_f64[' + this.helpers.FS64ArrayView(i) + ']-t.cp1_f64[' + this.helpers.FT64ArrayView(i) + '];';
    };

    //todo:rounding
    this.r4300i_COP1_truncw_d = function (i) {
        return 't.cp1_i[' + this.helpers.FD32ArrayView(i) + ']=t.cp1_f64[' + this.helpers.FS64ArrayView(i) + '];';
    };

    this.r4300i_COP1_truncw_s = function (i) {
        return 't.cp1_i[' + this.helpers.FD32ArrayView(i) + ']=t.cp1_f[' + this.helpers.FS32ArrayView(i) + '];';
    };

    this.r4300i_COP1_neg_s = function (i) {
        return 't.cp1_i[' + this.helpers.FD32ArrayView(i) + ']=t.cp1_i[' + this.helpers.FS32ArrayView(i) + ']^0x80000000;';
    };

    this.r4300i_COP1_neg_d = function (i) {
        return 't.cp1_i[' + this.helpers.FD32HIArrayView(i) + ']=t.cp1_i[' + this.helpers.FS32HIArrayView(i) + ']^0x80000000;';
    };

    this.r4300i_COP1_abs_s = function (i) {
        return 't.cp1_i[' + this.helpers.FD32ArrayView(i) + ']=t.cp1_i[' + this.helpers.FS32ArrayView(i) + ']&0x7fffffff;';
    };

    this.r4300i_COP1_abs_d = function (i) {
        return 't.cp1_i[' + this.helpers.FD32HIArrayView(i) + ']=t.cp1_i[' + this.helpers.FS32HIArrayView(i) + ']&0x7fffffff;';
    };

    this.r4300i_COP1_sqrt_s = function (i) {
        return 't.cp1_f[' + this.helpers.FD32ArrayView(i) + ']=Math.sqrt(t.cp1_f[' + this.helpers.FS32ArrayView(i) + ']);';
    };

    this.r4300i_COP1_sqrt_d = function (i) {
        return 't.cp1_f64[' + this.helpers.FD64ArrayView(i) + ']=Math.sqrt(t.cp1_f64[' + this.helpers.FS64ArrayView(i) + ']);';
    };

    this.r4300i_sync = function (i) {
        this.log('todo: sync');
        return '';
    };

    this.r4300i_sdr = function (i) {
        this.log('todo: sdr');
        return '';
    };

    this.r4300i_ldr = function (i) {
        this.log('todo: ldr');
        return '';
    };

    this.r4300i_sdl = function (i) {
        this.log('todo: sdl');
        return '';
    };

    this.r4300i_ldl = function (i) {
        this.log('todo: ldl');
        return '';
    };

    this.r4300i_sc = function (i) {
        this.log('todo: sc');
        return '';
    };

    this.r4300i_scd = function (i) {
        this.log('todo: scd');
        return '';
    };

    this.r4300i_daddi = function (i) {
        return 't.helpers.inter_daddi(r,h,' + i + ');';
    };

    this.r4300i_teq = function (i) {
        this.log('todo: r4300i_teq');
        return '';
    };

    this.r4300i_tgeu = function (i) {
        this.log('todo: r4300i_tgeu');
        return '';
    };

    this.r4300i_tlt = function (i) {
        this.log('todo: r4300i_tlt');
        return '';
    };

    this.r4300i_tltu = function (i) {
        this.log('todo: r4300i_tltu');
        return '';
    };

    this.r4300i_tne = function (i) {
        this.log('todo: r4300i_tne');
        return '';
    };

    //using same as daddi
    this.r4300i_daddiu = function (i) {
        return 't.helpers.inter_daddiu(r,h,' + i + ');';
    };

    this.r4300i_daddu = function (i) {
        return 't.helpers.inter_daddu(r,h,' + i + ');';
    };

	this.r4300i_C_F_S = function (i) {
        return 't.helpers.inter_r4300i_C_cond_fmt_s(' + i + ',t.cp1Con,t.cp1_f);';
    };

	this.r4300i_C_UN_S = function (i) {
        return 't.helpers.inter_r4300i_C_cond_fmt_s(' + i + ',t.cp1Con,t.cp1_f);';
    };

	this.r4300i_C_EQ_S = function (i) {
        return 't.helpers.inter_r4300i_C_cond_fmt_s(' + i + ',t.cp1Con,t.cp1_f);';
    };

	this.r4300i_C_UEQ_S = function (i) {
        return 't.helpers.inter_r4300i_C_cond_fmt_s(' + i + ',t.cp1Con,t.cp1_f);';
    };

	this.r4300i_C_OLT_S = function (i) {
        return 't.helpers.inter_r4300i_C_cond_fmt_s(' + i + ',t.cp1Con,t.cp1_f);';
    };

	this.r4300i_C_ULT_S = function (i) {
        return 't.helpers.inter_r4300i_C_cond_fmt_s(' + i + ',t.cp1Con,t.cp1_f);';
    };

	this.r4300i_C_OLE_S = function (i) {
        return 't.helpers.inter_r4300i_C_cond_fmt_s(' + i + ',t.cp1Con,t.cp1_f);';
    };

	this.r4300i_C_ULE_S = function (i) {
        return 't.helpers.inter_r4300i_C_cond_fmt_s(' + i + ',t.cp1Con,t.cp1_f);';
    };

	this.r4300i_C_SF_S = function (i) {
        return 't.helpers.inter_r4300i_C_cond_fmt_s(' + i + ',t.cp1Con,t.cp1_f);';
    };

	this.r4300i_C_NGLE_S = function (i) {
        return 't.helpers.inter_r4300i_C_cond_fmt_s(' + i + ',t.cp1Con,t.cp1_f);';
    };

	this.r4300i_C_SEQ_S = function (i) {
        return 't.helpers.inter_r4300i_C_cond_fmt_s(' + i + ',t.cp1Con,t.cp1_f);';
    };

	this.r4300i_C_NGL_S = function (i) {
        return 't.helpers.inter_r4300i_C_cond_fmt_s(' + i + ',t.cp1Con,t.cp1_f);';
    };

	this.r4300i_C_LT_S = function (i) {
        return 't.helpers.inter_r4300i_C_cond_fmt_s(' + i + ',t.cp1Con,t.cp1_f);';
    };

	this.r4300i_C_NGE_S = function (i) {
        return 't.helpers.inter_r4300i_C_cond_fmt_s(' + i + ',t.cp1Con,t.cp1_f);';
    };

	this.r4300i_C_LE_S = function (i) {
        return 't.helpers.inter_r4300i_C_cond_fmt_s(' + i + ',t.cp1Con,t.cp1_f);';
    };

	this.r4300i_C_NGT_S = function (i) {
        return 't.helpers.inter_r4300i_C_cond_fmt_s(' + i + ',t.cp1Con,t.cp1_f);';
    };

	this.r4300i_C_F_D = function (i) {
        return 't.helpers.inter_r4300i_C_cond_fmt_d(' + i + ',t.cp1Con,t.cp1_f64);';
    };

	this.r4300i_C_UN_D = function (i) {
        return 't.helpers.inter_r4300i_C_cond_fmt_d(' + i + ',t.cp1Con,t.cp1_f64);';
    };

	this.r4300i_C_EQ_D = function (i) {
        return 't.helpers.inter_r4300i_C_cond_fmt_d(' + i + ',t.cp1Con,t.cp1_f64);';
    };

	this.r4300i_C_UEQ_D = function (i) {
        return 't.helpers.inter_r4300i_C_cond_fmt_d(' + i + ',t.cp1Con,t.cp1_f64);';
    };

	this.r4300i_C_OLT_D = function (i) {
        return 't.helpers.inter_r4300i_C_cond_fmt_d(' + i + ',t.cp1Con,t.cp1_f64);';
    };

	this.r4300i_C_ULT_D = function (i) {
        return 't.helpers.inter_r4300i_C_cond_fmt_d(' + i + ',t.cp1Con,t.cp1_f64);';
    };

	this.r4300i_C_OLE_D = function (i) {
        return 't.helpers.inter_r4300i_C_cond_fmt_d(' + i + ',t.cp1Con,t.cp1_f64);';
    };

	this.r4300i_C_ULE_D = function (i) {
        return 't.helpers.inter_r4300i_C_cond_fmt_d(' + i + ',t.cp1Con,t.cp1_f64);';
    };

	this.r4300i_C_SF_D = function (i) {
        return 't.helpers.inter_r4300i_C_cond_fmt_d(' + i + ',t.cp1Con,t.cp1_f64);';
    };

	this.r4300i_C_NGLE_D = function (i) {
        return 't.helpers.inter_r4300i_C_cond_fmt_d(' + i + ',t.cp1Con,t.cp1_f64);';
    };

	this.r4300i_C_SEQ_D = function (i) {
        return 't.helpers.inter_r4300i_C_cond_fmt_d(' + i + ',t.cp1Con,t.cp1_f64);';
    };

	this.r4300i_C_NGL_D = function (i) {
        return 't.helpers.inter_r4300i_C_cond_fmt_d(' + i + ',t.cp1Con,t.cp1_f64);';
    };

	this.r4300i_C_LT_D = function (i) {
        return 't.helpers.inter_r4300i_C_cond_fmt_d(' + i + ',t.cp1Con,t.cp1_f64);';
    };

	this.r4300i_C_NGE_D = function (i) {
        return 't.helpers.inter_r4300i_C_cond_fmt_d(' + i + ',t.cp1Con,t.cp1_f64);';
    };

	this.r4300i_C_LE_D = function (i) {
        return 't.helpers.inter_r4300i_C_cond_fmt_d(' + i + ',t.cp1Con,t.cp1_f64);';
    };

	this.r4300i_C_NGT_D = function (i) {
        return 't.helpers.inter_r4300i_C_cond_fmt_d(' + i + ',t.cp1Con,t.cp1_f64);';
    };
};