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

 - Should handle exceptions in delay slots by catching thrown exceptions. 

 when loading/storing registers back into n64 memory,
 do so byte-by-byte since typed-arrays aren't endian-safe.
 It's easier to get your head around and it's plenty fast.
 The hope is that the compiler will optimimize the pattern
 with a swap or bswap.
*/

////////////globals that need to be refactored
    var debug=false;

    var writeToDom = true;
    var code;
    if (writeToDom === true)
        code = window;
    else
        code = new Object();

    var h = new Int32Array(35*4); //r hi
    var vAddr = new Int32Array(4);
    var cp0 = new Int32Array(32*4);
    var cp1Buffer = new ArrayBuffer(32*8);
    var cp1_i = new Int32Array(cp1Buffer);
    var cp1_f = new Float32Array(cp1Buffer);
    var cp1_f64 = new Float64Array(cp1Buffer);
    var rom; //will be assigned as new Uint8Array on init()
    var romUint8Array;
    var cp1Con = new Int32Array(32*4);
    var LLbit=0;

    var tlb = new Array(32);
    for (var i=0; i<32; i++)
        tlb[i] = new Object();

    var rdramUint8Array = new Uint8Array(0x800000);
    var spMemUint8Array = new Uint8Array(0x10000);
    var spReg1Uint8Array = new Uint8Array(0x10000);
    var spReg2Uint8Array = new Uint8Array(0x10000);
    var dpcUint8Array = new Uint8Array(0x10000);
    var dpsUint8Array = new Uint8Array(0x10000);
    var miUint8Array = new Uint8Array(0x10000);
    var viUint8Array = new Uint8Array(0x10000);
    var aiUint8Array = new Uint8Array(0x10000);
    var piUint8Array = new Uint8Array(0x10000);
    var siUint8Array = new Uint8Array(0x10000);
    var c2a1Uint8Array = new Uint8Array(0x10000);
    var c1a1Uint8Array = new Uint8Array(0x10000);
    var c2a2Uint8Array = new Uint8Array(0x10000);
    var c1a3Uint8Array = new Uint8Array(0x10000);
    var riUint8Array = new Uint8Array(0x10000);
    var pifUint8Array = new Uint8Array(0x10000);
    var gioUint8Array = new Uint8Array(0x10000);
    var ramRegs0Uint8Array = new Uint8Array(0x10000);
    var ramRegs4Uint8Array = new Uint8Array(0x10000);
    var ramRegs8Uint8Array = new Uint8Array(0x10000);
    var dummyReadWriteUint8Array = new Uint8Array(0x10000);
    var docElement,errorElement,g,s,interval,keepRunning,offset,programCounter, romLength, redrawDebug=0;
    var terminate=false;

    var c,ctx, ImDat,ImDat2, showFB;
    //todo: get from emulation
    var NUM_CHANNELS = 1;
    var NUM_SAMPLES = 40000;
    var SAMPLE_RATE = 40000;
    var audioContext;
    var isLittleEndian = 0;
    var isBigEndian = 0;
    var stats;
    var speed = 65535;
    var magic_number = -625000;
    var keepRunning;
    var forceRepaint = false; //presumably origin reg doesn't change because not double or triple-buffered (single-buffered)
    //main run loop
    var doOnce=0;

    var kk=0;
    var TV_SYSTEM_NTSC = 1;
    var TV_SYSTEM_PAL = 0;
    var startTime = 0;
    var audioBuffer;
    var currentHack = 0;
    var kfi=512;

    this.getFnName = function(pc) {
        return '_' + (pc>>>2);
    }

//////////////end globals that need to be refactored

window.onerror = function() {
    terminate = true;
}

var request;

_1964jsEmulator = function() {

    this.log = function(message) {
      console.log(message);
    }

    this.init = function(buffer) {
        var r = new Int32Array(35*4);

        cancelAnimFrame(request);
        currentHack = 0;
        startTime = 0;
        kfi=512;
        doOnce = 0;
        magic_number = -625000;
        flushDynaCache();
        showFB = true;
        this.endianTest();
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

        rom = buffer;
        //rom = new Uint8Array(buffer);
        romUint8Array = buffer;
        docElement = document.getElementById("screen");
        errorElement = document.getElementById("error");

        //canvas
        c = document.getElementById("Canvas");
        ctx = c.getContext("2d");
        var c2 = document.getElementById("DebugCanvas");
        var ctx2 = c2.getContext("2d");

        ImDat=ctx.createImageData(320,240);
        ImDat2=ctx2.createImageData(320,240);

        //fill alpha
        var i=3;
        for (var y = 0; y < 240; y++) {
            for (var x = 0; x < 320; x++) {
                ImDat.data[i] = 255;
                ImDat2.data[i] = 255;
                i+=4;
            }
        }

        stopCompiling = false;
        keepRunning = 0x1000;

        this.byteSwap(rom);
        //copy first 4096 bytes to sp_dmem and run from there.
        for (k=0; k<0x1000; k++) {
            spMemUint8Array[k] = rom[k];
        }

        r[20] = this.getTVSystem(romUint8Array[0x3D]);
        r[22] = this.getCIC();

        cp0[STATUS] = 0x70400004;
        cp0[RANDOM] = 0x0000001f;
        cp0[CONFIG] = 0x0006e463;
        cp0[PREVID] = 0x00000b00;
        cp1Con[0] = 0x00000511;

        //set programCounter to start of SP_MEM and after the 64 byte ROM header.
        programCounter = 0xA4000040;

        setInt32(miUint8Array, MI_VERSION_REG, 0x01010101);
        setInt32(riUint8Array, RI_CONFIG_REG, 0x00000001);
        setInt32(viUint8Array, VI_INTR_REG, 0x000003FF);
        setInt32(viUint8Array, VI_V_SYNC_REG, 0x000000D1);
        setInt32(viUint8Array, VI_H_SYNC_REG, 0x000D2047);

        //setInt32(spReg1Uint8Array, SP_STATUS_REG, SP_STATUS_HALT);
        //1964cpp sets this then clears it in RCP_Reset() ! 

        //set hi vals
        var i=0;
        for (i=0; i<35; i++)
            h[i] = r[i]>>31;

        this.startEmulator(r);
    }

    this.trace2 = function(address, opcode) {
        //comment this out for speed when not debugging
        console.log(address + ': ' + opcode);
    }

    //swap to 0x80371240
    this.byteSwap = function(rom) {
        console.log('byte swapping...');
        
        var fmt = getUint32(rom, 0);
        switch(fmt>>>0) {
            case 0x37804012:
            if ((rom.byteLength % 2) != 0)
                alert('help: support odd byte lengths for this swap');
            for (k=0; k<rom.byteLength; k+=2) {
                var temp = rom[k];
                rom[k] = rom[k+1];
                rom[k+1] = temp;
            }
            break;
            case 0x80371240:
            break;
            default:
                this.log('Unhandled byte order: 0x' + dec2hex(fmt));
            break;
        }
        console.log('swap done');
    }

    this.endianTest = function() {
        var ii = new ArrayBuffer(2);
        var iiSetView = new Uint8Array(ii);
        var iiView = new Uint16Array(ii);
        
        iiSetView[0] = 0xff;
        iiSetView[1] = 0x11;
        
        if (iiView[0] === 0x11FF) {
            this.log('You are on a little-endian system');
            isLittleEndian = 1;
            isBigEndian = 0;
        } else {
            this.log('You are on a big-endian system');
            isLittleEndian = 0;
            isBigEndian = 1;
        }
    }

    this.repaint = function(ctx, ImDat, origin) {
        if (!showFB)
            return;

        if (!stats) {
            stats = new Stats();

            // Align top-left
            stats.getDomElement().style.position = 'relative';
            stats.getDomElement().style.left = '0px';
            stats.getDomElement().style.top = '0px';
           // document.getElementById('error').appendChild( stats.getDomElement() );
        }

        stats.update();
        var out = ImDat.data;

        var k=origin;
        var i=0;

        //endian-safe blit    
        //rgba5551
        for (var y = -240*320; y !== 0; y++) {
            var hi = rdramUint8Array[k];
            var lo= rdramUint8Array[k+1];
                out[i] = (hi & 0xF8);
                k+=2;
                out[i+1] = (((hi<<5) | (lo>>>3)) & 0xF8);
                out[i+2] = (lo << 2 & 0xF8);
                i+=4;
        }
        ctx.putImageData(ImDat,0,0);
    }

    this.testHi = function() {    
        var w = new Int32Array(34);
        for (var i=0; i<34; i++) {
            w[i] = r[i]>>31;
            if (w[i] !== h[i])
                alert(dec2hex(programCounter) + ' ' + h[i] + ' ' + w[i]);
        }
    }

    this.changeSpeed = function(s) {
        if (s > 131072)
            s = 131072;
        if (s < 0)
            s = 0;

        speed = s;
    }

    this.runLoop = function(r) {
        
        if (terminate === false)
            request = requestAnimFrame(this.runLoop.bind(this, r));
        
        keepRunning = speed;
        var pc, fnName, fn;

        pc = programCounter >>> 2;
        fnName = '_' + pc; 
        fn = code[fnName];

        while (keepRunning-- > 0) {
            if (!fn)
                fn = this.decompileBlock(programCounter);    
        
            fn = fn(r);
        
            if (magic_number >= 0) {
                this.repaintWrapper();
                magic_number = -625000;
                cp0[COUNT] += 625000;
                if (cp0[COUNT] >= cp0[COMPARE]) {
                    triggerCompareInterrupt(0, false);
                    if (processException(programCounter)) {
    //                  return;
                    }
                    cp0[COUNT] = 0;
                    cp0[COMPARE] = 625000*99;
                }
                triggerVIInterrupt(0, false);
                checkInterrupts();
                if((cp0[CAUSE] & cp0[STATUS] & 0x0000FF00) !== 0) {
                    setException(EXC_INT, 0, programCounter, false);
                    if (processException(programCounter));
                }
            }
        }
        
        return this;
    }

    this.repaintWrapper = function() {
        this.repaint(ctx, ImDat, getInt32(viUint8Array, viUint8Array, VI_ORIGIN_REG) & 0x00FFFFFF)
    }

    this.startEmulator = function(r) {
        terminate = false;
        this.log('startEmulator');
        
        var speedScrubber = document.getElementById("speedScrubber");
        if (speedScrubber != undefined) {
            speedScrubber.value = 65535;
            this.changeSpeed(speedScrubber.value);
            speedScrubber.style.opacity = 1.0;
        }
        this.runLoop(r);
        //interval = setInterval(runLoop, 0);
    }

    this.stopEmulator = function() {
        stopCompiling = true;
        terminate = true;
        
        this.log('stopEmulator');
        //clearInterval(interval);
    }

    this.decompileBlock = function(pc) {
        offset = 0;
        var string;

        fnName = '_' + (pc>>>2); 

        if (writeToDom === true)
            string = 'function ' + fnName + '(r){';
        else
            string = 'code.' + fnName + '=function(r){';

        while (!stopCompiling) {
            var instruction = loadWord(pc+offset);
            var opcode = this[CPU_instruction[instruction>>26 & 0x3f]](instruction);

            string += 'magic_number+=1.5;';
            string += opcode;
            offset+=4;
            if (offset > 10000) {
                throw 'too many instructions! bailing.';
            }
        }
        stopCompiling = false;
        
        //close out the function
        string += 'programCounter='+((pc+offset)>>0);
        string += ';return code["'+getFnName((pc+offset)>>0)+'"];}';

        if (writeToDom === true) {
            g = document.createElement('script');
            s = document.getElementsByTagName('script')[kk++];
            s.parentNode.insertBefore(g, s);
            g.text = string;
        }
        else
            eval(string);
            
        return code[fnName];
    }

    this.r4300i_add = function(i) {
        return sLogic(i, '+');
    }

    this.r4300i_addu = function(i) {
        return sLogic(i, '+');
    }

    this.r4300i_sub = function(i) {
        return sLogic(i, '-');
    }

    this.r4300i_subu = function(i) {
        return sLogic(i, '-');
    }

    this.r4300i_or = function(i) {
        return dLogic(i, '|');
    }

    this.r4300i_xor = function(i) {
        return dLogic(i, '^');
    }

    this.r4300i_nor = function(i) {
        return '{'+_RD(i)+'=~('+RS(i)+'|'+RT(i)+');'+_RDH(i)+'=~('+RSH(i)+'|'+RTH(i)+');}';
    }

    this.r4300i_and = function(i) {
        return dLogic(i, '&');
    }

    this.r4300i_lui = function(i) {
        var temp = ((i&0x0000ffff)<<16);
        return '{'+_RT(i)+'='+temp+';'+_RTH(i)+'='+(temp>>31)+';}';
    }

    this.r4300i_lw = function(i) {
        return '{'+setVAddr(i)+_RT(i)+'=loadWord(vAddr);'+_RTH(i)+'='+RT(i)+'>>31}';
    }

    this.r4300i_lwu = function(i) {
        return '{'+setVAddr(i)+_RT(i)+'=loadWord(vAddr);'+_RTH(i)+'=0}';
    }

    this.r4300i_sw = function(i, isDelaySlot) {
        var string = '{'+setVAddr(i)+'storeWord('+RT(i)+',vAddr'; 

        //So we can process exceptions
        if (isDelaySlot === true) {
            var a = (programCounter+offset+4)|0;
            string += ', ' + a + ', true)}';
        } else {
            var a = (programCounter+offset)|0;
            string += ', ' + a + ')}';
        }   

        return string;
    }
    
    this.delaySlot = function(i, likely) {
        //delay slot
        var pc = (programCounter+offset+4 + (soffset_imm(i)<< 2))|0;
        var instruction = loadWord((programCounter+offset+4)|0);
        var opcode = this[CPU_instruction[instruction>>26 & 0x3f]](instruction, true);
        var string = opcode;

        string += 'magic_number+=1.5;programCounter='+pc+';return code["'+getFnName(pc)+'"];}';

        //if likely and if branch not taken, skip delay slot
        if (likely === false) {
            string += opcode;
            string += 'magic_number+=1.5;';
        }

        offset+=4;
        return string;
    }

    this.r4300i_bne = function(i) {
        stopCompiling = true;
        var string= 'if (('+RS(i)+'!=='+RT(i)+')||('+RSH(i)+'!=='+RTH(i)+')){';
        
        string += this.delaySlot(i, false);
        return string;
    }

    this.r4300i_beq = function(i) {
        stopCompiling = true;
        var string= 'if (('+RS(i)+'==='+RT(i)+')&&('+RSH(i)+'==='+RTH(i)+')){';

        string += this.delaySlot(i, false);
        return string;
    }

    this.r4300i_bnel = function(i) {
        stopCompiling = true;
        var string= 'if (('+RS(i)+'!=='+RT(i)+')||(' +RSH(i)+'!=='+RTH(i)+')){';
        
        string += this.delaySlot(i, true);
        return string;
    }

    this.r4300i_blez = function(i) {
        stopCompiling = true;
        var string= 'if (('+RSH(i)+'<0)||(('+RSH(i)+'===0)&&('+RS(i)+'===0))){';

        string += this.delaySlot(i, false);
        return string;
    }

    this.r4300i_blezl = function(i) {
        stopCompiling = true;
        var string= 'if (('+RSH(i)+'<0)||(('+RSH(i)+'===0)&&('+RS(i)+'===0))){';

        string += this.delaySlot(i, true);
        return string;
    }

    this.r4300i_bgez = function(i) {
        stopCompiling = true;
        var string= 'if ('+RSH(i)+'>=0){';

        string += this.delaySlot(i, false);
        return string;
    }

    this.r4300i_bgezl = function(i) {
        stopCompiling = true;
        var string= 'if ('+RSH(i)+'>=0){';

        string += this.delaySlot(i, true);
        return string;
    }

    this.r4300i_bgtzl = function(i) {
        stopCompiling = true;
        var string= 'if (('+RSH(i)+'>0)||(('+RSH(i)+'===0)&&('+RS(i)+'!==0))){';

        string += this.delaySlot(i, true);
        return string;
    }

    this.r4300i_bltzl = function(i) {
        stopCompiling = true;
        var string= 'if ('+RSH(i)+'<0){';

        string += this.delaySlot(i, true);
        return string;
    }

    this.r4300i_bgezal = function(i) {
        stopCompiling = true;    
        var string= 'if ('+RSH(i)+'>=0){';

        var link = (programCounter+offset+8)>>0;
        string += 'r[31]=' + link + ';';
        string += 'h[31]=' + (link>>31) + ';';

        string += this.delaySlot(i, false);
        return string;
    }

    this.r4300i_bgezall = function(i) {
        stopCompiling = true;    
        var string= 'if ('+RSH(i)+'>=0){';

        var link = (programCounter+offset+8)>>0;
        string += 'r[31]=' + link + ';';
        string += 'h[31]=' + (link>>31) + ';';

        string += this.delaySlot(i, true);
        return string;
    }

    this.r4300i_bltz = function(i) {
        stopCompiling = true;
        var string= 'if ('+RSH(i)+'<0){';

        string += this.delaySlot(i, false);
        return string;
    }

    this.r4300i_bgtz = function(i) {
        stopCompiling = true;
        var string= 'if (('+RSH(i)+'>0)||(('+RSH(i)+'===0)&&('+RS(i)+'!==0))){';

        string += this.delaySlot(i, false);
        return string;
    }

    this.r4300i_beql = function(i) {
        stopCompiling = true;
        var string= 'if (('+RS(i)+'==='+RT(i)+')&&('+RSH(i)+'==='+RTH(i)+')){';

        string += this.delaySlot(i, true);
        return string;
    }

    this.r4300i_COP1_bc1f = function(i) {
        stopCompiling = true;
        var string = 'if((cp1Con[31]&0x00800000)===0){';        

        string += this.delaySlot(i, false);
        return string;
    }

    this.r4300i_COP1_bc1t = function(i) {
        stopCompiling = true;
        var string = 'if((cp1Con[31]&0x00800000)!==0){';
        
        string += this.delaySlot(i, false);
        return string;
    }

    this.r4300i_COP1_bc1tl = function(i) {
        stopCompiling = true;
        var string = 'if((cp1Con[31]&0x00800000)!==0){';
        
        string += this.delaySlot(i, true);
        return string;
    }

    this.r4300i_COP1_bc1fl = function(i) {
        stopCompiling = true;
        var string = 'if((cp1Con[31]&0x00800000)===0){';

        string += this.delaySlot(i, true);
        return string;
    }

    this.r4300i_j = function(i) {
        stopCompiling = true;

        var instr_index = (((((programCounter+offset+4) & 0xF0000000)) | ((i & 0x03FFFFFF) << 2))|0);
        var string = '{';

        //delay slot
        var instruction = loadWord((programCounter+offset+4)|0);

        string += 'magic_number+=1.5;';
        if (((instr_index>>0) === (programCounter+offset)>>0) && (instruction === 0)) {
            string+= 'magic_number=0;keepRunning=0;'
        }

        var opcode = this[CPU_instruction[instruction>>26 & 0x3f]](instruction, true);
        string += opcode;
        string += 'programCounter='+instr_index+';return code["'+getFnName(instr_index)+'"];}';

        return string;
    }

    this.r4300i_jal = function(i) {
        stopCompiling = true;

        var instr_index = (((((programCounter+offset+4) & 0xF0000000)) | ((i & 0x03FFFFFF) << 2))|0);
        var string = '{';
        //delay slot
        var instruction = loadWord((programCounter+offset+4)|0);
        var opcode = this[CPU_instruction[instruction>>26 & 0x3f]](instruction, true);
        string += opcode;
        var pc = (programCounter+offset+8)|0;
        string += 'magic_number+=1.5;';
        string += 'programCounter='+instr_index+';r[31]='+pc+';h[31]='+(pc>>31)+';return code["'+getFnName(instr_index)+'"];}';

        return string;
    }

    //should we set the programCounter after the delay slot or before it?
    this.r4300i_jalr = function(i) {
        stopCompiling = true;

        var string = '{var temp='+RS(i)+';'; 
        var link = (programCounter + offset + 8)>>0;
        string += _RD(i)+'='+link+';'+_RDH(i)+'='+(link>>31)+';';
         
        //delay slot
        var instruction = loadWord((programCounter+offset+4)|0);
        var opcode = this[CPU_instruction[instruction>>26 & 0x3f]](instruction, true);
        string += opcode;
        string += 'magic_number+=1.5;';
        string += 'programCounter=temp;return code[getFnName(temp)];}';
        
        return string;
    }

    this.r4300i_jr = function(i) {
        stopCompiling = true;

        var string = '{var temp='+RS(i)+';'; 
        //delay slot
        var instruction = loadWord((programCounter+offset+4)|0);
        var opcode = this[CPU_instruction[instruction>>26 & 0x3f]](instruction, true);
        string += opcode;
        string += 'magic_number+=1.5;';
        string += 'programCounter=temp;return code[getFnName(temp)];}';
        
        return string;
    }

    this.UNUSED = function(i) {
        this.log('warning: UNUSED');
        return('');
    }

    this.r4300i_COP0_eret = function(i) {
        stopCompiling = true;

        var string = '{if((cp0['+STATUS+']&'+ERL+')!==0){alert("error epc");programCounter=cp0['+ERROREPC+'];';
        string += 'cp0['+STATUS+']&=~'+ERL+';}else{programCounter=cp0['+EPC+'];cp0['+STATUS+']&=~'+EXL+';}';
        string += 'LLbit=0;return code[getFnName(programCounter)];}';

        return string;
    }

    this.r4300i_COP0_mtc0 = function(i, isDelaySlot) {
        var delaySlot;
        if (isDelaySlot === true) {
            pc = (programCounter + offset + 4)|0;
            delaySlot = "true";
        } else {
            pc = (programCounter + offset)|0;
            delaySlot = "false";
        }

        return '_1964Helpers.prototype.inter_mtc0(r,'+fs(i)+','+rt(i)+','+delaySlot+','+pc+');';
    }

    this.r4300i_sll = function(i) {
        if ((i&0x001FFFFF) === 0) return '';

        return '{'+_RD(i)+'='+RT(i)+'<<'+sa(i)+';'+_RDH(i)+'='+RD(i)+'>>31}';
    }

    this.r4300i_srl = function(i) {
        return '{'+_RD(i)+'='+RT(i)+'>>>'+sa(i)+';'+_RDH(i)+'='+RD(i)+'>>31}';
    }

    this.r4300i_ori = function(i) {
        return '{'+_RT(i)+'='+RS(i)+'|'+offset_imm(i)+';'+_RTH(i)+'='+RSH(i)+';}';
    }

    this.r4300i_xori = function(i) {
        return '{'+_RT(i)+'='+RS(i)+'^'+offset_imm(i)+';'+_RTH(i)+'='+RSH(i)+'^0;}';
    }

    this.r4300i_andi = function(i) {
        return '{'+_RT(i)+'='+RS(i)+'&'+offset_imm(i)+';'+_RTH(i)+'=0;}';
    }

    this.r4300i_addi = function(i) {
        return '{'+_RT(i)+'='+RS(i)+'+'+soffset_imm(i)+';'+_RTH(i)+'='+RT(i)+'>>31;}';
    }

    this.r4300i_addiu = function(i) {
        return '{'+_RT(i)+'='+RS(i)+'+'+soffset_imm(i)+';'+_RTH(i)+'='+RT(i)+'>>31;}'; 
    }

    this.r4300i_slt = function(i) {
        return '{if('+RSH(i)+'>'+RTH(i)+')'+_RD(i)+'=0;'
        +'else if('+RSH(i)+'<'+RTH(i)+')'+_RD(i)+'=1;'
        +'else if('+uRS(i)+'<'+uRT(i)+')'+_RD(i)+'=1;'
        +'else '+_RD(i)+'=0;'+_RDH(i)+'=0;}';
    }

    this.r4300i_sltu = function(i) {
        return '{if('+uRSH(i)+'>'+uRTH(i)+')'+_RD(i)+'=0;'
        +'else if('+uRSH(i)+'<'+uRTH(i)+')'+_RD(i)+'=1;'
        +'else if('+uRS(i)+'<'+uRT(i)+')'+_RD(i)+'=1;'
        +'else '+_RD(i)+'=0;'+_RDH(i)+'=0;}';
    }

    this.r4300i_slti = function(i) {
        var soffset_imm_hi = (soffset_imm(i))>>31;
        var uoffset_imm_lo = (soffset_imm(i))>>>0;

        return '{if('+RSH(i)+'>'+soffset_imm_hi+')'+_RT(i)+'=0;'
        +'else if('+RSH(i)+'<'+soffset_imm_hi+')'+_RT(i)+'=1;'
        +'else if('+uRS(i)+'<'+uoffset_imm_lo+')'+_RT(i)+'=1;'
        +'else '+_RT(i)+'=0;'+_RTH(i)+'=0;}';
    }

    this.r4300i_sltiu = function(i) {
        var uoffset_imm_hi = (soffset_imm(i)>>31)>>>0;
        var uoffset_imm_lo = (soffset_imm(i))>>>0;

        return '{if('+uRSH(i)+'>'+uoffset_imm_hi+')'+_RT(i)+'=0;'
        +'else if('+uRSH(i)+'<'+uoffset_imm_hi+')'+_RT(i)+'=1;'
        +'else if('+uRS(i)+'<'+uoffset_imm_lo+')'+_RT(i)+'=1;'
        +'else '+_RT(i)+'=0;'+_RTH(i)+'=0;}';
    }

    this.r4300i_cache = function(i) {
        this.log('todo: r4300i_cache');
        return('');
    }

    this.r4300i_multu = function(i) {
        return '_1964Helpers.prototype.inter_multu(r,'+i+');';
    }

    this.r4300i_mult = function(i) {
        return '_1964Helpers.prototype.inter_mult(r,'+i+');'; 
    }

    this.r4300i_mflo = function(i) {
         return '{'+_RD(i)+'=r[32];'+_RDH(i)+'=h[32];}'; 
    }

    this.r4300i_mfhi = function(i) {
         return '{'+_RD(i)+'=r[33];'+_RDH(i)+'=h[33];}'; 
    }

    this.r4300i_mtlo = function(i) {
         return '{r[32]='+RS(i)+';h[32]='+RSH(i)+';}';
    }

    this.r4300i_mthi = function(i) {
         return '{r[33]='+RS(i)+';h[33]='+RSH(i)+';}';
    }

    //todo: timing
    this.getCountRegister = function() {
        return 1;
    }

    this.r4300i_COP0_mfc0 = function(i) {
        var string = '{';

        switch (fs(i)) {
            case RANDOM:
                alert('RANDOM');
            break;
            case COUNT:
                
                //string += 'cp0['+fs(i)+']=getCountRegister();';
            break;
            default:
            break;
        }
        string += _RT(i)+'=cp0['+fs(i)+'];'+_RTH(i)+'=cp0['+fs(i)+']>>31;}';
        return string;
    }

    this.r4300i_lb = function(i) {
        return '{'+setVAddr(i)+_RT(i)+'=(loadByte(vAddr)<<24)>>24;'+_RTH(i)+'='+RT(i)+'>>31}';
    }

    this.r4300i_lbu = function(i) {
        return '{'+setVAddr(i)+_RT(i)+'=(loadByte(vAddr))&0x000000ff;'+_RTH(i)+'=0;}';
    }

    this.r4300i_lh = function(i) {
        return '{'+setVAddr(i)+_RT(i)+'=(loadHalf(vAddr)<<16)>>16;'+_RTH(i)+'='+RT(i)+'>>31}';
    }

    this.r4300i_lhu = function(i) {
        return '{'+setVAddr(i)+_RT(i)+'=(loadHalf(vAddr))&0x0000ffff;'+_RTH(i)+'=0;}';
    }

    this.r4300i_sb = function(i) {
        return '{'+setVAddr(i)+'storeByte('+RT(i)+',vAddr);}'; 
    }

    this.r4300i_sh = function(i) {
        return '{'+setVAddr(i)+'storeHalf('+RT(i)+',vAddr);}'; 
    }

    this.r4300i_srlv = function(i) {
        return '{'+_RD(i)+'='+RT(i)+'>>>('+RS(i)+'&0x1f);'+_RDH(i)+'='+RD(i)+'>>31;}';
    }

    this.r4300i_sllv = function(i) {
        return '{'+_RD(i)+'='+RT(i)+'<<('+RS(i)+'&0x1f);'+_RDH(i)+'='+RD(i)+'>>31;}'; 
    }

    this.r4300i_srav = function(i) {
        //optimization: r[hi] can safely right-shift rt
        return '{'+_RD(i)+'='+RT(i)+'>>('+RS(i)+'&0x1f);'+_RDH(i)+'='+RT(i)+'>>31;}'; 
    }

    this.r4300i_COP1_cfc1 = function(i) {
        if(fs(i) === 0 || fs(i) === 31) {
            return '{'+_RT(i)+'=cp1Con['+fs(i)+'];'+_RTH(i)+'=cp1Con['+fs(i)+']>>31;}';
        }
    }

    this.r4300i_COP1_ctc1 = function(i) {
        //incomplete:
        if (fs(i) === 31) {
            return 'cp1Con[31]='+RT(i)+';'
        }
    }

    this.r4300i_ld = function(i) {
        var string = '{'+setVAddr(i)+_RT(i)+'=loadWord((vAddr+4)|0);'+_RTH(i)+'=loadWord(vAddr);}';

        return string;
    }

    this.r4300i_lld = function(i) {
        var string = '{'+setVAddr(i)+_RT(i)+'=loadWord((vAddr+4)|0);'+_RTH(i)+'=loadWord(vAddr);LLbit=1;}';

        return string;
    }

    //address error exceptions in ld and sd are weird since this is split up 
    //into 2 reads or writes. i guess they're fatal exceptions, so
    //doesn't matter. 
    this.r4300i_sd = function(i, isDelaySlot) {
        //lo
        var string = '{'+setVAddr(i)+'storeWord('+RT(i)+',(vAddr+4)|0'; 

        //So we can process exceptions
        if (isDelaySlot === true) {
            var a = (programCounter+offset+4)|0;
            string += ', ' + a + ', true);';
        } else {
            var a = (programCounter+offset)|0;
            string += ', ' + a + ');';
        }   

        //hi
        string += 'storeWord('+RTH(i)+',vAddr'; 

        //So we can process exceptions
        if (isDelaySlot === true) {
            var a = (programCounter+offset+4)|0;
            string += ', ' + a + ', true);';
        } else {
            var a = (programCounter+offset)|0;
            string += ', ' + a + ');';
        }

        string += '}';

        return string;
    }

    this.r4300i_dmultu = function(i) {
        return '_1964Helpers.prototype.inter_dmultu(r,'+i+');';
    }

    this.r4300i_dsll32 = function(i) {
        return '{'+_RDH(i)+'='+RT(i)+'<<'+sa(i)+';'+_RD(i)+'=0;}';
    }

    this.r4300i_dsra32 = function(i) {
        return '{'+_RD(i)+'='+RTH(i)+'>>'+sa(i)+';'+_RDH(i)+'='+RTH(i)+'>>31;}';
    }

    this.r4300i_ddivu = function(i) {
        return '_1964Helpers.prototype.inter_ddivu(r,'+i+');'
    }

    this.r4300i_ddiv = function(i) {
        alert('ddiv');

        return '_1964Helpers.prototype.inter_ddiv(r,'+i+');'
    }

    this.r4300i_dadd = function(i) {
        this.log('todo: dadd');

        return r4300i_dadd(i);
    }

    this.r4300i_break = function(i) {
        this.log('todo: break');
        return('');
    }

    this.r4300i_COP0_tlbwi = function(i) {
        //var index = cp0[INDEX] & NTLBENTRIES;
        this.log('todo: tlbwi');
        return('');
    }

    this.r4300i_div = function(i) {
        return '_1964Helpers.prototype.inter_div(r,'+i+');'; 
    }

    this.r4300i_divu = function(i) {
        return '_1964Helpers.prototype.inter_divu(r,'+i+');'; 
    }

    this.r4300i_sra = function(i) {
        //optimization: sra's r[hi] can safely right-shift RT.
        return '{'+_RD(i)+'='+RT(i)+'>>'+sa(i)+';'+_RDH(i)+'='+RT(i)+'>>31}';
    }

    this.r4300i_COP0_tlbp = function(i) {
        this.log('todo: tlbp');
        return('');
    }

    this.r4300i_COP0_tlbr = function(i) {
        this.log('todo: tlbr');
        return('');
    }

    this.r4300i_lwl = function(i) {
        var string = '{'+setVAddr(i);

        string += 'var vAddrAligned=(vAddr&0xfffffffc)|0;var value=loadWord(vAddrAligned);';
        string += 'switch(vAddr&3){case 0:'+_RT(i)+'=value;break;';
        string += 'case 1:'+_RT(i)+'=('+RT(i)+'&0x000000ff)|((value<<8)>>>0);break;';
        string += 'case 2:'+_RT(i)+'=('+RT(i)+'&0x0000ffff)|((value<<16)>>>0);break;';
        string += 'case 3:'+_RT(i)+'=('+RT(i)+'&0x00ffffff)|((value<<24)>>>0);break;}';
        string += _RTH(i)+'='+RT(i)+'>>31;}';

        return string;
    }

    this.r4300i_lwr = function(i) {
        var string = '{'+setVAddr(i);
        
        string += 'var vAddrAligned=(vAddr&0xfffffffc)|0;var value=loadWord(vAddrAligned);';
        string += 'switch(vAddr&3){case 3:'+_RT(i)+'=value;break;';
        string += 'case 2:'+_RT(i)+'=('+RT(i)+'&0xff000000)|(value>>>8);break;';
        string += 'case 1:'+_RT(i)+'=('+RT(i)+'&0xffff0000)|(value>>>16);break;';
        string += 'case 0:'+_RT(i)+'=('+RT(i)+'&0xffffff00)|(value>>>24);break;}';
        string += _RTH(i)+'='+RT(i)+'>>31;}';
        
        return string;
    }

    this.r4300i_swl = function(i) {
        var string = '{'+setVAddr(i);
        
        string += 'var vAddrAligned=(vAddr&0xfffffffc)|0;var value=loadWord(vAddrAligned);';
        string += 'switch(vAddr&3){case 0:value='+RT(i)+';break;';
        string += 'case 1:value=((value&0xff000000)|('+RT(i)+'>>>8));break;';
        string += 'case 2:value=((value&0xffff0000)|('+RT(i)+'>>>16));break;';
        string += 'case 3:value=((value&0xffffff00)|('+RT(i)+'>>>24));break;}';
        string += 'storeWord(value,vAddrAligned,false);}';

        return string;
    }

    this.r4300i_swr = function(i) {
        var string = '{'+setVAddr(i);
        
        string += 'var vAddrAligned=(vAddr&0xfffffffc)|0;var value=loadWord(vAddrAligned);';
        string += 'switch(vAddr&3){case 3:value='+RT(i)+';break;';
        string += 'case 2:value=((value & 0x000000FF)|(('+RT(i)+'<<8)>>>0));break;';
        string += 'case 1:value=((value & 0x0000FFFF)|(('+RT(i)+'<<16)>>>0));break;';
        string += 'case 0:value=((value & 0x00FFFFFF)|(('+RT(i)+'<<24)>>>0));break;}';        
        string += 'storeWord(value,vAddrAligned,false);}'

        return string;
    }

    this.r4300i_lwc1 = function(i) {
        return '{'+setVAddr(i)+'cp1_i['+FT32ArrayView(i)+']=loadWord(vAddr);}';
    }

    this.r4300i_ldc1 = function(i) {
        var string = '{'+setVAddr(i)+'cp1_i['+FT32ArrayView(i)+']=loadWord((vAddr+4)|0);'; 
        string += 'cp1_i['+FT32HIArrayView(i)+']=loadWord((vAddr)|0);}'; 

        return string;
    }

    this.r4300i_swc1 = function(i, isDelaySlot) {
        var string = '{'+setVAddr(i)+'storeWord(cp1_i['+FT32ArrayView(i)+'],vAddr'; 

        //So we can process exceptions
        if (isDelaySlot === true) {
            var a = (programCounter+offset+4)|0;
            string += ', ' + a + ', true)}';
        } else {
            var a = (programCounter+offset)|0;
            string += ', ' + a + ')}';
        }   

        return string;
    }

    this.r4300i_sdc1 = function(i, isDelaySlot) {
        var string = '{'+setVAddr(i)+'storeWord(cp1_i['+FT32ArrayView(i)+'],(vAddr+4)|0'; 

        //So we can process exceptions
        if (isDelaySlot === true) {
            var a = (programCounter+offset+4)|0;
            string += ', ' + a + ', true);';
        } else {
            var a = (programCounter+offset)|0;
            string += ', ' + a + ');';
        }   

        string += 'storeWord(cp1_i['+FT32HIArrayView(i)+'],(vAddr)|0'; 

        //So we can process exceptions
        if (isDelaySlot === true) {
            var a = (programCounter+offset+4)|0;
            string += ', ' + a + ', true);';
        } else {
            var a = (programCounter+offset)|0;
            string += ', ' + a + ');';
        }

        string += '}';

        return string;
    }

    this.r4300i_COP1_mtc1 = function(i) {
      return 'cp1_i['+FS32ArrayView(i)+']='+RT(i)+';';
    }

    this.r4300i_COP1_mfc1 = function(i) {
        return '{'+_RT(i)+'=cp1_i['+FS32ArrayView(i)+'];'+_RTH(i)+'='+RT(i)+'>>31;}';
    }

    this.r4300i_COP1_cvts_w = function(i) {
        return 'cp1_f['+FD32ArrayView(i)+']=cp1_i['+FS32ArrayView(i)+'];';
    }

    this.r4300i_COP1_cvtw_s = function(i) {
        return 'cp1_i['+FD32ArrayView(i)+']=cp1_f['+FS32ArrayView(i)+'];';
    }

    this.r4300i_COP1_div_s = function(i) {
        return 'cp1_f['+FD32ArrayView(i)+']=cp1_f['+FS32ArrayView(i)+']/cp1_f['+FT32ArrayView(i)+'];';
    }

    this.r4300i_COP1_div_d = function(i) {
        return 'cp1_f64['+FD64ArrayView(i)+']=cp1_f64['+FS64ArrayView(i)+']/cp1_f64['+FT64ArrayView(i)+'];';
    }

    this.r4300i_COP1_mul_s = function(i) {
        return 'cp1_f['+FD32ArrayView(i)+']=cp1_f['+FS32ArrayView(i)+']*cp1_f['+FT32ArrayView(i)+'];';
    }

    this.r4300i_COP1_mul_d = function(i) {
        return 'cp1_f64['+FD64ArrayView(i)+']=cp1_f64['+FS64ArrayView(i)+']*cp1_f64['+FT64ArrayView(i)+'];';
    }

    this.r4300i_COP1_mov_s = function(i) {
        return 'cp1_i['+FD32ArrayView(i)+']=cp1_i['+FS32ArrayView(i)+'];';
    }

    this.r4300i_COP1_mov_d = function(i) {
        return 'cp1_f64['+FD32ArrayView(i)+']=cp1_f64['+FS32ArrayView(i)+'];';
    }

    this.r4300i_COP1_add_s = function(i) {
        return 'cp1_f['+FD32ArrayView(i)+']=cp1_f['+FS32ArrayView(i)+']+cp1_f['+FT32ArrayView(i)+'];';
    }

    this.r4300i_COP1_sub_s = function(i) {
        return 'cp1_f['+FD32ArrayView(i)+']=cp1_f['+FS32ArrayView(i)+']-cp1_f['+FT32ArrayView(i)+'];';
    }

    this.r4300i_COP1_cvtd_s = function(i) {
        return 'cp1_f64['+FD64ArrayView(i)+']=cp1_f['+FS32ArrayView(i)+'];';
    }

    this.r4300i_COP1_cvtd_w = function(i) {
        return 'cp1_f64['+FD64ArrayView(i)+']=cp1_i['+FS32ArrayView(i)+'];';
    }

    this.r4300i_COP1_cvts_d = function(i) {
        return 'cp1_f['+FD32ArrayView(i)+']=cp1_f64['+FS64ArrayView(i)+'];';
    }

    this.r4300i_COP1_cvtw_d = function(i) {
        return 'cp1_i['+FD32ArrayView(i)+']=cp1_f64['+FS64ArrayView(i)+'];';
    }

    this.r4300i_COP1_add_d = function(i) {
        return 'cp1_f64['+FD64ArrayView(i)+']=cp1_f64['+FS64ArrayView(i)+']+cp1_f64['+FT64ArrayView(i)+'];';
    }

    this.r4300i_COP1_sub_d = function(i) {
        return 'cp1_f64['+FD64ArrayView(i)+']=cp1_f64['+FS64ArrayView(i)+']-cp1_f64['+FT64ArrayView(i)+'];';
    }

    //todo:rounding
    this.r4300i_COP1_truncw_d = function(i) {
        return 'cp1_i['+FD32ArrayView(i)+']=cp1_f64['+FS64ArrayView(i)+'];';
    }

    this.r4300i_COP1_truncw_s = function(i) {
        return 'cp1_i['+FD32ArrayView(i)+']=cp1_f['+FS32ArrayView(i)+'];';
    }

    this.r4300i_COP1_neg_s = function(i) {
        return 'cp1_i['+FD32ArrayView(i)+']=cp1_i['+FS32ArrayView(i)+']^0x80000000;';
    }

    this.r4300i_COP1_neg_d = function(i) {
        return 'cp1_i['+FD32HIArrayView(i)+']=cp1_i['+FS32HIArrayView(i)+']^0x80000000;';
    }

    this.r4300i_COP1_sqrt_s = function(i) {
        return 'cp1_f['+FD32ArrayView(i)+']=Math.sqrt(cp1_f['+FS32ArrayView(i)+']);';
    }

    this.r4300i_sync = function(i) {
        this.log('todo: sync');
        return('');
    }

    this.r4300i_sdr = function(i) {
        this.log('todo: sdr');
        return('');
    }

    this.r4300i_ldr = function(i) {
        this.log('todo: ldr');
        return('');
    }
    
    this.r4300i_sdl = function(i) {
        this.log('todo: sdl');
        return('');
    }

    this.r4300i_ldl = function(i) {
        this.log('todo: ldl');
        return('');
    }

    this.r4300i_sc = function(i) {
        this.log('todo: sc');
        return('');
    }
    
    this.r4300i_scd = function(i) {
        this.log('todo: scd');
        return('');
    }
    

    this.r4300i_daddi = function(i) {
        return '_1964Helpers.prototype.inter_daddi(r,'+i+');';
    }

    this.r4300i_teq = function(i) {
        this.log('todo: r4300i_teq');
        return ('');
    }

    this.r4300i_tgeu = function(i) {
        this.log('todo: r4300i_tgeu');
        return ('');
    }

    this.r4300i_tlt = function(i) {
        this.log('todo: r4300i_tlt');
        return ('');
    }

    this.r4300i_tltu = function(i) {
        this.log('todo: r4300i_tltu');
        return ('');
    }

    this.r4300i_tne = function(i) {
        this.log('todo: r4300i_tne');
        return ('');
    }

    //using same as daddi
    this.r4300i_daddiu = function(i) {
        return '_1964Helpers.prototype.inter_daddiu(r,'+i+');';
    }

    this.r4300i_daddu = function(i) {
        return '_1964Helpers.prototype.inter_daddu(r,'+i+');';
    }

    this.r4300i_C_EQ_D = function(i) {
        return '_1964Helpers.prototype.inter_r4300i_C_cond_fmt_d('+i+');';
    }

    this.r4300i_C_EQ_S = function(i) {
        return '_1964Helpers.prototype.inter_r4300i_C_cond_fmt_s('+i+');';
    }

    this.r4300i_C_LT_S = function(i) {
        return '_1964Helpers.prototype.inter_r4300i_C_cond_fmt_s('+i+');';
    }

    this.r4300i_C_LT_D = function(i) {
        return '_1964Helpers.prototype.inter_r4300i_C_cond_fmt_d('+i+');';
    }

    this.r4300i_C_LE_S = function(i) {
        return '_1964Helpers.prototype.inter_r4300i_C_cond_fmt_s('+i+');';
    }

    this.r4300i_C_LE_D = function(i) {
        return '_1964Helpers.prototype.inter_r4300i_C_cond_fmt_d('+i+');';
    }
}
