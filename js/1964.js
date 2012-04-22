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
 causing sinus, plasma, hardcoded, mandembrot zoomer, lightforce, and other demos to not work in 1964js.
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

var debug=false;

var writeToDom = true;
var code;
if (writeToDom == true)
    code = window;
else
    code = new Object();

var regBuffer = new ArrayBuffer(35*4);
var hRegBuffer = new ArrayBuffer(35*4);
var vAddrBuffer = new ArrayBuffer(4);
var cp0Buffer = new ArrayBuffer(32*4) 
var cp1Buffer = new ArrayBuffer(32*8);
var cp1ConBuffer = new ArrayBuffer(32*4);
var RDRAM = new ArrayBuffer(0x400000);
var EXRDRAM = new ArrayBuffer(0x400000);
var C2A1 = new ArrayBuffer(0x10000);
var C1A1 = new ArrayBuffer(0x10000);
var C2A2 = new ArrayBuffer(0x10000);
var GIO_REG = new ArrayBuffer(0x10000);
var C1A3 = new ArrayBuffer(0x10000);
var PIF = new ArrayBuffer(0x10000);
var dummyNoAccess = new ArrayBuffer(0x10000);
var dummyReadWrite = new ArrayBuffer(0x10000);
var dummyAllZero = new ArrayBuffer(0x10000);
var ramRegs0 = new ArrayBuffer(0x10000);
var ramRegs4 = new ArrayBuffer(0x10000);
var ramRegs8 = new ArrayBuffer(0x10000);
var SP_MEM = new ArrayBuffer(0x10000);
var SP_REG_1 = new ArrayBuffer(0x10000);
var SP_REG_2 = new ArrayBuffer(0x10000);
var DPC = new ArrayBuffer(0x10000);
var DPS = new ArrayBuffer(0x10000);
var MI = new ArrayBuffer(0x10000);
var VI = new ArrayBuffer(0x10000);
var AI = new ArrayBuffer(0x10000);
var PI = new ArrayBuffer(0x10000);
var RI = new ArrayBuffer(0x10000);
var SI = new ArrayBuffer(0x10000);

var r = new Int32Array(regBuffer);
var h = new Int32Array(hRegBuffer); //r hi
var vAddr = new Int32Array(vAddrBuffer);
var cp0 = new Int32Array(cp0Buffer);
var cp1_i = new Int32Array(cp1Buffer);
var cp1_f = new Float32Array(cp1Buffer);
var cp1_f64 = new Float64Array(cp1Buffer);
var rom; //will be assigned as new Uint8Array on init()
var romUint8Array;
var cp1Con = new Int32Array(cp1ConBuffer);
var LLbit=0;

var tlb = new Array(32);
for (var i=0; i<32; i++)
    tlb[i] = new Object();

var rdramUint8Array = new Uint8Array(RDRAM);
var exRdramUint8Array = new Uint8Array(EXRDRAM);
var spMemUint8Array = new Uint8Array(SP_MEM);
var spReg1Uint8Array = new Uint8Array(SP_REG_1);
var spReg2Uint8Array = new Uint8Array(SP_REG_2);
var dpcUint8Array = new Uint8Array(DPC);
var dpsUint8Array = new Uint8Array(DPS);
var miUint8Array = new Uint8Array(MI);
var viUint8Array = new Uint8Array(VI);
var aiUint8Array = new Uint8Array(AI);
var piUint8Array = new Uint8Array(PI);
var siUint8Array = new Uint8Array(SI);
var c2a1Uint8Array = new Uint8Array(C2A1);
var c1a1Uint8Array = new Uint8Array(C1A1);
var c2a2Uint8Array = new Uint8Array(C2A2);
var c1a3Uint8Array = new Uint8Array(C1A3);
var riUint8Array = new Uint8Array(RI);
var pifUint8Array = new Uint8Array(PIF);
var gioUint8Array = new Uint8Array(GIO_REG);
var ramRegs0Uint8Array = new Uint8Array(ramRegs0);
var ramRegs4Uint8Array = new Uint8Array(ramRegs4);
var ramRegs8Uint8Array = new Uint8Array(ramRegs8);
var dummyReadWriteUint8Array = new Uint8Array(dummyReadWrite);
var docElement,errorElement,g,s,interval,keepRunning,offset,programCounter, romLength, redrawDebug=0;
var terminate=false;

//window.onload = init;
var c,ctx, ImDat,ImDat2;

//todo: get from emulation
var NUM_CHANNELS = 1;
var NUM_SAMPLES = 40000;
var SAMPLE_RATE = 40000;
var audioContext;

var isLittleEndian = 0;
var isBigEndian = 0;

function init(buffer)
{
    endianTest();
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
    for (var y = 0; y < 240; y++){
        for (var x = 0; x < 320; x++) {
            ImDat.data[i] = 255;
            ImDat2.data[i] = 255;
            i+=4;
        }
    }

    stopCompiling = false;
    keepRunning = 0x1000;

    byteSwap(rom);
    //copy first 4096 bytes to sp_dmem and run from there.
    for (k=0; k<0x1000; k++)
    {
        spMemUint8Array[k] = rom[k];
    }

    r[20] = getTVSystem(romUint8Array[0x3D]);
    r[22] = getCIC();

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

    startEmulator();
}

function trace2(address, opcode)
{
    //comment this out for speed when not debugging
    console.log(address + ': ' + opcode);
}

//swap to 0x80371240
function byteSwap(rom)
{
    console.log('byte swapping...');
    
    var fmt = getUint32(romUint8Array, 0);//rom[0] << 24 | rom[1]<<16 | rom[2]<<8 | rom[3];
    switch(fmt>>>0)
    {
        case 0x37804012:
        if ((rom.byteLength % 2) != 0)
            alert('help: support odd byte lengths for this swap');
        for (k=0; k<rom.byteLength; k+=2)
        {
            var temp = rom[k];
            rom[k] = rom[k+1];
            rom[k+1] = temp;
        }
        break;
        case 0x80371240:
        break;
        default:
            log('Unhandled byte order: 0x' + dec2hex(fmt));
        break;
    }
    console.log('swap done');
}

var stats;
function endianTest()
{
    var ii = new ArrayBuffer(2);
    var iiSetView = new Uint8Array(ii);
    var iiView = new Uint16Array(ii);
    
    iiSetView[0] = 0xff;
    iiSetView[1] = 0x11;
    
    if (iiView[0] === 0x11FF)
    {
        log('You are on a little-endian system');
        isLittleEndian = 1;
        isBigEndian = 0;
    }
    else
    {
        log('You are on a big-endian system');
        isLittleEndian = 0;
        isBigEndian = 1;
    }
}

function repaint(ctx, ImDat, origin)
{
    if (!stats)
    {
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
    for (var y = -240*320; y !== 0; y++){
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

var doOnce=0;

//#define NTSC_MAX_VI_LINE		525
//#define PAL_MAX_VI_LINE			625
//#define NTSC_VI_MAGIC_NUMBER	625000
//#define PAL_VI_MAGIC_NUMBER		777809				/* 750000 //777809 */

function testHi()
{    
    var w = new Int32Array(34);
    for (var i=0; i<34; i++)
    {
        w[i] = r[i]>>31;
        if (w[i] !== h[i])
            alert(dec2hex(programCounter) + ' ' + h[i] + ' ' + w[i]);
    }
}

function changeSpeed(s) {
    speed = s;
}

var speed = 65535;
var magic_number = -625000;
var keepRunning;
var forceRepaint = false; //presumably origin reg doesn't change because not double or triple-buffered (single-buffered)
//main run loop
var fnName; //todo: pass locally.
function runLoop()
{
    if (terminate === false)
        requestAnimFrame(runLoop);
    keepRunning = speed;
    var pc, fnName, fn;
    var lr=r;

    pc = programCounter >>> 2;
    fnName = '_' + pc; 
    fn = code[fnName];

    while (keepRunning-- > 0)
    {

        if (!fn)
            fn = decompileBlock(programCounter);    
    
        fn = fn(lr);
    
        if (magic_number >= 0)
        {
            repaintWrapper();
            magic_number = -625000;
            cp0[COUNT] += 625000;
            if (cp0[COUNT] >= cp0[COMPARE])
            {
                triggerCompareInterrupt(0, false);
                if (processException(programCounter))
                {
//                  return;
                }
                cp0[COUNT] = 0;
                cp0[COMPARE] = 625000*99;
            }
            triggerVIInterrupt(0, false);
            checkInterrupts();
            if((cp0[CAUSE] & cp0[STATUS] & 0x0000FF00) !== 0)
            {
                setException(EXC_INT, 0, programCounter, false);
                if (processException(programCounter));
            }
        }
    }
}

function repaintWrapper()
{
repaint(ctx, ImDat, getInt32(viUint8Array, viUint8Array, VI_ORIGIN_REG) & 0x00FFFFFF)
}

function startEmulator()
{
    terminate = false;
    log('startEmulator');
    
    var speedScrubber = document.getElementById("speedScrubber");
    if (speedScrubber != undefined)
    {
        speedScrubber.value = 65535;
        changeSpeed(speedScrubber.value);
        speedScrubber.style.opacity = 1.0;
    }
    if (terminate === false)
       runLoop();
         //interval = setInterval(runLoop, 0);
}

function stopEmulator()
{
    stopCompiling = true;
    terminate = true;
    
    log('stopEmulator');
    clearInterval(interval);
}

var kk=0;

function getFnName(pc)
{
    return '_' + (pc>>>2);
}

function decompileBlock(pc)
{
    offset = 0;
    var string;
    
    fnName = '_' + (pc>>>2); 

    if (writeToDom === true)
        string = 'function ' + fnName + '(r){';
    else
        string = 'code.' + fnName + '=function(r){';

    while (!stopCompiling)
    {
        var instruction = loadWord(pc+offset);
        var opcode = window[CPU_instruction[instruction>>26 & 0x3f]](instruction);
        //trace2(programCounter+offset, opcode);
        string += 'magic_number++;';
        string += opcode;
        offset+=4;
        if (offset > 10000)
        {
            throw 'too many instructions! bailing.';
        }
    }
    stopCompiling = false;
    
    //close out the function
    string += 'programCounter='+((pc+offset)>>0);
    string += ';return code["'+getFnName((pc+offset)>>0)+'"];}';

    if (writeToDom === true)
    {
        g = document.createElement('script');
        s = document.getElementsByTagName('script')[kk++];
        s.parentNode.insertBefore(g, s);
        g.text = string;
    }
    else
        eval(string);
        
    return code[fnName];
}

function r4300i_add(i) {
    return sLogic(i, '+');
}

function r4300i_addu(i) {
    return sLogic(i, '+');
}

function r4300i_sub(i) {
    return sLogic(i, '-');
}

function r4300i_subu(i) {
    return sLogic(i, '-');
}

function r4300i_or(i) {
    return dLogic(i, '|');
}

function r4300i_xor(i) {
    return dLogic(i, '^');
}

function r4300i_nor(i) {
    return '{'+_RD(i)+'=~('+RS(i)+'|'+RT(i)+');'+_RDH(i)+'=~('+RSH(i)+'|'+RTH(i)+');}';
}

function r4300i_and(i) {
    return dLogic(i, '&');
}

function r4300i_lui(i) {
    var temp = ((i&0x0000ffff)<<16);
    return '{'+_RT(i)+'='+temp+';'+_RTH(i)+'='+(temp>>31)+';}';
}

function r4300i_lw(i) {
    return '{'+setVAddr(i)+_RT(i)+'=loadWord(vAddr);'+_RTH(i)+'='+RT(i)+'>>31}';
}

function r4300i_lwu(i) {
    return '{'+setVAddr(i)+_RT(i)+'=loadWord(vAddr);'+_RTH(i)+'=0}';
}

function r4300i_sw(i, isDelaySlot)
{
    var string = '{'+setVAddr(i)+'storeWord('+RT(i)+',vAddr'; 

    //So we can process exceptions
    if (isDelaySlot === true)
    {
        var a = (programCounter+offset+4)|0;
        string += ', ' + a + ', true)}';
    }
    else
    {
        var a = (programCounter+offset)|0;
        string += ', ' + a + ')}';
    }   

    return string;
}

function r4300i_bne(i)
{
    stopCompiling = true;

    var string= 'if (('+RS(i)+'!=='+RT(i)+')||('+RSH(i)+'!=='+RTH(i)+')){';
    var pc = (programCounter+offset+4 + (soffset_imm(i)<< 2))|0;

    //delay slot
    var instruction = loadWord((programCounter+offset+4)|0);
    var opcode = window[CPU_instruction[instruction>>26 & 0x3f]](instruction, true);
    string += opcode;
    string += 'magic_number++;';

    string += 'programCounter='+pc+';return code["' + getFnName(pc) + '"];}';

    //delay slot
    string += opcode;
    string += 'magic_number++;';
    offset+=4;

    return string;
}

function r4300i_beq(i)
{
    stopCompiling = true;

    var string= 'if (('+RS(i)+'==='+RT(i)+')&&('+RSH(i)+'==='+RTH(i)+')){';
    var pc = (programCounter+offset+4 + (soffset_imm(i)<< 2))|0;
    
    //delay slot
    var instruction = loadWord((programCounter+offset+4)|0);
    var opcode = window[CPU_instruction[instruction>>26 & 0x3f]](instruction, true);
    string += opcode;
    string += 'magic_number++;';
    string += 'programCounter='+pc+';return code["'+getFnName(pc)+'"];}';

    //delay slot
    string += 'magic_number++;';
    string+=opcode;offset+=4;

    return string;
}

function r4300i_bnel(i)
{
    stopCompiling = true;

    var string= 'if (('+RS(i)+'!=='+RT(i)+')||(' +RSH(i)+'!=='+RTH(i)+')){';
    var pc = (programCounter+offset+4 + (soffset_imm(i)<< 2))|0;
    
    //delay slot
    var instruction = loadWord((programCounter+offset+4)|0);
    var opcode = window[CPU_instruction[instruction>>26 & 0x3f]](instruction, true);
    string += opcode;
    string += 'magic_number++;';
    string += 'programCounter='+pc+';return code["'+getFnName(pc)+'"];}';

    offset+=4; //skip delay slot if branch is not taken
    return string;
}

function r4300i_blez(i)
{
    stopCompiling = true;

    var string= 'if (('+RSH(i)+'<0)||(('+RSH(i)+'===0)&&('+RS(i)+'===0))){';
    var pc = (programCounter+offset+4 + (soffset_imm(i)<< 2))|0;
    
    //delay slot
    var instruction = loadWord((programCounter+offset+4)|0);
    var opcode = window[CPU_instruction[instruction>>26 & 0x3f]](instruction, true);
    string += opcode;
    string += 'magic_number++;';
    string += 'programCounter='+pc+';return code["'+getFnName(pc)+'"];}';

    //delay slot
    string += 'magic_number++;';
    string+=opcode;offset+=4;

    return string;
}

function r4300i_blezl(i)
{
    stopCompiling = true;

    var string= 'if (('+RSH(i)+'<0)||(('+RSH(i)+'===0)&&('+RS(i)+'===0))){';
    var pc = (programCounter+offset+4 + (soffset_imm(i)<< 2))|0;
    
    //delay slot
    var instruction = loadWord((programCounter+offset+4)|0);
    var opcode = window[CPU_instruction[instruction>>26 & 0x3f]](instruction, true);
    string += opcode;
    string += 'magic_number++;';
    string += 'programCounter='+pc+';return code["'+getFnName(pc)+'"];}';

    offset+=4; //skip delay slot if branch is not taken
    return string;
}

function r4300i_bgez(i)
{
    stopCompiling = true;

    var string= 'if ('+RSH(i)+'>=0){';
    var pc = (programCounter+offset+4 + (soffset_imm(i)<< 2))|0;
    
    //delay slot
    var instruction = loadWord((programCounter+offset+4)|0);
    var opcode = window[CPU_instruction[instruction>>26 & 0x3f]](instruction, true);
    string += opcode;
    string += 'magic_number++;';
    string += 'programCounter='+pc+';return code["'+getFnName(pc)+'"];}';

    string += 'magic_number++;';
    string+=opcode;offset+=4; //delay slot

    return string;
}

function r4300i_bgezl(i)
{
    stopCompiling = true;

    var string= 'if ('+RSH(i)+'>=0){';
    var pc = (programCounter+offset+4 + (soffset_imm(i)<< 2))|0;
    
    //delay slot
    var instruction = loadWord((programCounter+offset+4)|0);
    var opcode = window[CPU_instruction[instruction>>26 & 0x3f]](instruction, true);
    string += opcode;
    string += 'magic_number++;';
    string += 'programCounter='+pc+';return code["'+getFnName(pc)+'"];}';

    offset+=4; //skip delay slot if branch is not taken
    return string;
}

function r4300i_bgtzl(i) // 2 blokes demo
{
    stopCompiling = true;

    var string= 'if (('+RSH(i)+'>0)||(('+RSH(i)+'===0)&&('+RS(i)+'!==0))){';

    var pc = (programCounter+offset+4 + (soffset_imm(i)<< 2))|0;
    
    //delay slot
    var instruction = loadWord((programCounter+offset+4)|0);
    var opcode = window[CPU_instruction[instruction>>26 & 0x3f]](instruction, true);
    string += opcode;
    string += 'magic_number++;';
    string += 'programCounter='+pc+';return code["'+getFnName(pc)+'"];}';

    offset+=4; //skip delay slot if branch is not taken
    return string;
}

function r4300i_bltzl(i) //2 blokes demo
{
    stopCompiling = true;

    var string= 'if ('+RSH(i)+'<0){';
    var pc = (programCounter+offset+4 + (soffset_imm(i)<< 2))|0;
    
    //delay slot
    var instruction = loadWord((programCounter+offset+4)|0);
    var opcode = window[CPU_instruction[instruction>>26 & 0x3f]](instruction, true);
    string += opcode;
    string += 'magic_number++;';
    string += 'programCounter='+pc+';return code["'+getFnName(pc)+'"];}';

    offset+=4; //skip delay slot if branch is not taken
    return string;
}

function r4300i_bgezal(i)
{
    stopCompiling = true;    

    var string= 'if ('+RSH(i)+'>=0){';
    var pc = (programCounter+offset+4 + (soffset_imm(i)<< 2))|0;

    var link = (programCounter+offset+8)>>0;
    string += 'r[31]=' + link + ';';
    string += 'h[31]=' + (link>>31) + ';';
    //delay slot
    var instruction = loadWord((programCounter+offset+4)|0);
    var opcode = window[CPU_instruction[instruction>>26 & 0x3f]](instruction, true);
    string += opcode;
    string += 'magic_number++;';
    string += 'programCounter='+pc+';return code["'+getFnName(pc)+'"];}';

    //delay slot
    string += 'magic_number++;';
    string+=opcode;offset+=4;

    return string;
}

function r4300i_bgezall(i)
{
    stopCompiling = true;    

    var string= 'if ('+RSH(i)+'>=0){';
    var pc = (programCounter+offset+4 + (soffset_imm(i)<< 2))|0;

    var link = (programCounter+offset+8)>>0;
    string += 'r[31]=' + link + ';';
    string += 'h[31]=' + (link>>31) + ';';
    //delay slot
    var instruction = loadWord((programCounter+offset+4)|0);
    var opcode = window[CPU_instruction[instruction>>26 & 0x3f]](instruction, true);
    string += opcode;
    string += 'magic_number++;';
    string += 'programCounter='+pc+';return code["'+getFnName(pc)+'"];}';

    offset+=4; //skip delay slot if branch is not taken
    return string;
}

function r4300i_bltz(i)
{
    stopCompiling = true;

    var string= 'if ('+RSH(i)+'<0){';
    var pc = (programCounter+offset+4 + (soffset_imm(i)<< 2))|0;

    //delay slot
    var instruction = loadWord((programCounter+offset+4)|0);
    var opcode = window[CPU_instruction[instruction>>26 & 0x3f]](instruction, true);
    string += opcode;
    string += 'magic_number++;';
    string += 'programCounter='+pc+';return code["'+getFnName(pc)+'"];}';

    //delay slot
    string += 'magic_number++;';
    string+=opcode;offset+=4;

    return string;
}

function r4300i_bgtz(i)
{
    stopCompiling = true;

    var string= 'if (('+RSH(i)+'>0)||(('+RSH(i)+'===0)&&('+RS(i)+'!==0))){';
    var pc = (programCounter+offset+4 + (soffset_imm(i)<< 2))|0;

    //delay slot
    var instruction = loadWord((programCounter+offset+4)|0);
    var opcode = window[CPU_instruction[instruction>>26 & 0x3f]](instruction, true);
    string += opcode;
    string += 'magic_number++;';
    string += 'programCounter='+pc+';return code["'+getFnName(pc)+'"];}';

    //delay slot
    string += 'magic_number++;';
    string+=opcode;offset+=4;

    return string;
}

function r4300i_beql(i)
{
    stopCompiling = true;

    var string= 'if (('+RS(i)+'==='+RT(i)+')&&('+RSH(i)+'==='+RTH(i)+')){';
    var pc = (programCounter+offset+4 + (soffset_imm(i)<< 2))|0;

    //delay slot
    var instruction = loadWord((programCounter+offset+4)|0);
    var opcode = window[CPU_instruction[instruction>>26 & 0x3f]](instruction, true);
    string += opcode;
    string += 'magic_number++;';
    string += 'programCounter='+pc+';return code["'+getFnName(pc)+'"];}';

    offset+=4; //skip delay slot if branch is not taken
    return string;
}

function r4300i_j(i)
{
    stopCompiling = true;

    var instr_index = (((((programCounter+offset+4) & 0xF0000000)) | ((i & 0x03FFFFFF) << 2))|0);
    var string = '{';

    //delay slot
    var instruction = loadWord((programCounter+offset+4)|0);

    string += 'magic_number++;';
    if (((instr_index>>0) === (programCounter+offset)>>0) && (instruction === 0))
    {
        string+= 'magic_number=0;keepRunning=0;'
    }

    var opcode = window[CPU_instruction[instruction>>26 & 0x3f]](instruction, true);
    string += opcode;
    string += 'programCounter='+instr_index+';return code["'+getFnName(instr_index)+'"];}';

    return string;
}

function r4300i_jal(i)
{
    stopCompiling = true;

    var instr_index = (((((programCounter+offset+4) & 0xF0000000)) | ((i & 0x03FFFFFF) << 2))|0);
    var string = '{';
    //delay slot
    var instruction = loadWord((programCounter+offset+4)|0);
    var opcode = window[CPU_instruction[instruction>>26 & 0x3f]](instruction, true);
    string += opcode;
    var pc = (programCounter+offset+8)|0;
    string += 'magic_number++;';
    string += 'programCounter='+instr_index+';r[31]='+pc+';h[31]='+(pc>>31)+';return code["'+getFnName(instr_index)+'"];}';

    return string;
}

//should we set the programCounter after the delay slot or before it?
function r4300i_jalr(i)
{
    stopCompiling = true;

    var string = '{var temp='+RS(i)+';'; 
    var link = (programCounter + offset + 8)>>0;
    string += _RD(i)+'='+link+';'+_RDH(i)+'='+(link>>31)+';';
     
    //delay slot
    var instruction = loadWord((programCounter+offset+4)|0);
    var opcode = window[CPU_instruction[instruction>>26 & 0x3f]](instruction, true);
    string += opcode;
    string += 'magic_number++;';
    string += 'programCounter=temp;return code[getFnName(temp)];}';
    
    return string;
}

function r4300i_jr(i)
{
    stopCompiling = true;

    var string = '{var temp='+RS(i)+';'; 
    //delay slot
    var instruction = loadWord((programCounter+offset+4)|0);
    var opcode = window[CPU_instruction[instruction>>26 & 0x3f]](instruction, true);
    string += opcode;
    string += 'magic_number++;';
    string += 'programCounter=temp;return code[getFnName(temp)];}';
    
    return string;
}

function UNUSED(i)
{
    log('warning: UNUSED');
    return('');
}

function r4300i_COP0_mtc0(i, isDelaySlot)
{
    var delaySlot;
    if (isDelaySlot === true)
    {
        pc = (programCounter + offset + 4)|0;
        delaySlot = "true";
    }
    else
    {
        pc = (programCounter + offset)|0;
        delaySlot = "false";
    }
        
    return 'mtc0('+fs(i)+','+rt(i)+','+delaySlot+','+pc+');';
}

//called function, not compiled
function mtc0(f, rt, isDelaySlot, pc)
{
    //incomplete:
	switch (f)
    {
        case CAUSE:
            cp0[f] &= ~0x300;
            cp0[f] |= r[rt] & 0x300;
            if(r[rt] & 0x300)
            {
          //      if (((r[rt] & 1)===1) && (cp0[f] & 1)===0) //possible fix over 1964cpp?
                if((cp0[CAUSE] & cp0[STATUS] & 0x0000FF00) !== 0)
                {
                    setException(EXC_INT, 0, pc, isDelaySlot);
                    //processException(pc, isDelaySlot);
                }
            }
		break;
        case COUNT:
            cp0[f] = r[rt];
        break;
        case COMPARE:
            cp0[CAUSE] &= ~CAUSE_IP8;
            cp0[f] = r[rt];
            break;
        break;
        case STATUS:
            if (((r[rt] & EXL)===0) && ((cp0[f] & EXL)===1))
            {
                if((cp0[CAUSE] & cp0[STATUS] & 0x0000FF00) !== 0)
                {
                    cp0[f] = r[rt];
                    setException(EXC_INT, 0, pc, isDelaySlot);
                    //processException(pc, isDelaySlot);
                    return;
                }
            }
            
            if (((r[rt] & IE)===1) && ((cp0[f] & IE)===0))
            {
                if((cp0[CAUSE] & cp0[STATUS] & 0x0000FF00) !== 0)
                {
                    cp0[f] = r[rt];
                    setException(EXC_INT, 0, pc, isDelaySlot);
                    //processException(pc, isDelaySlot);
                    return;
                }
            }

            cp0[f] = r[rt];
        break;
        //tlb:
        case BADVADDR: //read-only
        case PREVID: //read-only
        case RANDOM: //read-only
        break;
        case INDEX:
            cp0[f] = r[rt] & 0x8000003F;
        break;
        case ENTRYLO0:
            cp0[f] = r[rt] & 0x3FFFFFFF;
        break;
        case ENTRYLO1:
            cp0[f] = r[rt] & 0x3FFFFFFF;
        break;
        case ENTRYHI:
            cp0[f] = r[rt] & 0xFFFFE0FF;
        break;
        case PAGEMASK:
            cp0[f] = r[rt] & 0x01FFE000;
        break;
        case WIRED:
            cp0[f] = r[rt] & 0x1f;
            cp0[RANDOM] = 0x1f;
        break;
        default:
            cp0[f] = r[rt];
        break;
    }
}

function r4300i_sll(i) {
    if ((i&0x001FFFFF) === 0) return '';

    return '{'+_RD(i)+'='+RT(i)+'<<'+sa(i)+';'+_RDH(i)+'='+RD(i)+'>>31}';
}

function r4300i_srl(i) {
    return '{'+_RD(i)+'='+RT(i)+'>>>'+sa(i)+';'+_RDH(i)+'='+RD(i)+'>>31}';
}

function r4300i_ori(i) {
    return '{'+_RT(i)+'='+RS(i)+'|'+offset_imm(i)+';'+_RTH(i)+'='+RSH(i)+';}';
}

function r4300i_xori(i) {
    return '{'+_RT(i)+'='+RS(i)+'^'+offset_imm(i)+';'+_RTH(i)+'='+RSH(i)+'^0;}';
}

function r4300i_andi(i) {
    return '{'+_RT(i)+'='+RS(i)+'&'+offset_imm(i)+';'+_RTH(i)+'=0;}';
}

function r4300i_addi(i) {
    return '{'+_RT(i)+'='+RS(i)+'+'+soffset_imm(i)+';'+_RTH(i)+'='+RT(i)+'>>31;}';
}

function r4300i_addiu(i) {
    return '{'+_RT(i)+'='+RS(i)+'+'+soffset_imm(i)+';'+_RTH(i)+'='+RT(i)+'>>31;}'; 
}

function r4300i_slt(i)
{
	return '{if('+RSH(i)+'>'+RTH(i)+')'+_RD(i)+'=0;'
    +'else if('+RSH(i)+'<'+RTH(i)+')'+_RD(i)+'=1;'
    +'else if('+uRS(i)+'<'+uRT(i)+')'+_RD(i)+'=1;'
    +'else '+_RD(i)+'=0;'+_RDH(i)+'=0;}';
}

function r4300i_sltu(i)
{
	return '{if('+uRSH(i)+'>'+uRTH(i)+')'+_RD(i)+'=0;'
    +'else if('+uRSH(i)+'<'+uRTH(i)+')'+_RD(i)+'=1;'
    +'else if('+uRS(i)+'<'+uRT(i)+')'+_RD(i)+'=1;'
    +'else '+_RD(i)+'=0;'+_RDH(i)+'=0;}';
}

function r4300i_slti(i)
{
    var soffset_imm_hi = (soffset_imm(i))>>31;
    var uoffset_imm_lo = (soffset_imm(i))>>>0;

	return '{if('+RSH(i)+'>'+soffset_imm_hi+')'+_RT(i)+'=0;'
    +'else if('+RSH(i)+'<'+soffset_imm_hi+')'+_RT(i)+'=1;'
    +'else if('+uRS(i)+'<'+uoffset_imm_lo+')'+_RT(i)+'=1;'
    +'else '+_RT(i)+'=0;'+_RTH(i)+'=0;}';
}

function r4300i_sltiu(i)
{
    var uoffset_imm_hi = (soffset_imm(i)>>31)>>>0;
    var uoffset_imm_lo = (soffset_imm(i))>>>0;

	return '{if('+uRSH(i)+'>'+uoffset_imm_hi+')'+_RT(i)+'=0;'
    +'else if('+uRSH(i)+'<'+uoffset_imm_hi+')'+_RT(i)+'=1;'
    +'else if('+uRS(i)+'<'+uoffset_imm_lo+')'+_RT(i)+'=1;'
    +'else '+_RT(i)+'=0;'+_RTH(i)+'=0;}';
}

function r4300i_cache(i)
{
    log('todo: r4300i_cache');
    return('');
}

function r4300i_multu(i) {
    return 'inter_multu('+i+');';
}

function r4300i_mult(i) {
    return 'inter_mult('+i+');'; 
}

function r4300i_mflo(i) {
     return '{'+_RD(i)+'=r[32];'+_RDH(i)+'=h[32];}'; 
}

function r4300i_mfhi(i) {
     return '{'+_RD(i)+'=r[33];'+_RDH(i)+'=h[33];}'; 
}

function r4300i_mtlo(i) {
     return '{r[32]='+RS(i)+';h[32]='+RSH(i)+';}';
}

function r4300i_mthi(i) {
     return '{r[33]='+RS(i)+';h[33]='+RSH(i)+';}';
}

//todo: timing
function getCountRegister()
{
    return 1;
}

function r4300i_COP0_mfc0(i) {
    var string = '{';

    switch (fs(i))
    {
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

function r4300i_lb(i) {
    return '{'+setVAddr(i)+_RT(i)+'=(loadByte(vAddr)<<24)>>24;'+_RTH(i)+'='+RT(i)+'>>31}';
}

function r4300i_lbu(i) {
    return '{'+setVAddr(i)+_RT(i)+'=(loadByte(vAddr))&0x000000ff;'+_RTH(i)+'=0;}';
}

function r4300i_lh(i) {
    return '{'+setVAddr(i)+_RT(i)+'=(loadHalf(vAddr)<<16)>>16;'+_RTH(i)+'='+RT(i)+'>>31}';
}

function r4300i_lhu(i) {
    return '{'+setVAddr(i)+_RT(i)+'=(loadHalf(vAddr))&0x0000ffff;'+_RTH(i)+'=0;}';
}

function r4300i_sb(i) {
    return '{'+setVAddr(i)+'storeByte('+RT(i)+',vAddr);}'; 
}

function r4300i_sh(i) {
    return '{'+setVAddr(i)+'storeHalf('+RT(i)+',vAddr);}'; 
}

function r4300i_srlv(i) {
    return '{'+_RD(i)+'='+RT(i)+'>>>('+RS(i)+'&0x1f);'+_RDH(i)+'='+RD(i)+'>>31;}';
}

function r4300i_sllv(i) {
    return '{'+_RD(i)+'='+RT(i)+'<<('+RS(i)+'&0x1f);'+_RDH(i)+'='+RD(i)+'>>31;}'; 
}

function r4300i_srav(i) {
    //optimization: r[hi] can safely right-shift rt
    return '{'+_RD(i)+'='+RT(i)+'>>('+RS(i)+'&0x1f);'+_RDH(i)+'='+RT(i)+'>>31;}'; 
}

function r4300i_COP1_cfc1(i)
{
	if(fs(i) === 0 || fs(i) === 31)
	{
		return '{'+_RT(i)+'=cp1Con['+fs(i)+'];'+_RTH(i)+'=cp1Con['+fs(i)+']>>31;}';
	}
}

function r4300i_COP1_ctc1(i)
{
    //incomplete:
    if (fs(i) === 31)
    {
        return 'cp1Con[31]='+RT(i)+';'
    }
}

function r4300i_ld(i)
{
    var string = '{'+setVAddr(i)+_RT(i)+'=loadWord((vAddr+4)|0);'+_RTH(i)+'=loadWord(vAddr);}';

    return string;
}

function r4300i_lld(i)
{
    var string = '{'+setVAddr(i)+_RT(i)+'=loadWord((vAddr+4)|0);'+_RTH(i)+'=loadWord(vAddr);LLbit=1;}';

    return string;
}

//address error exceptions in ld and sd are weird since this is split up 
//into 2 reads or writes. i guess they're fatal exceptions, so
//doesn't matter. 
function r4300i_sd(i, isDelaySlot)
{
//lo

    var string = '{'+setVAddr(i)+'storeWord('+RT(i)+',(vAddr+4)|0'; 

    //So we can process exceptions
    if (isDelaySlot === true)
    {
        var a = (programCounter+offset+4)|0;
        string += ', ' + a + ', true);';
    }
    else
    {
        var a = (programCounter+offset)|0;
        string += ', ' + a + ');';
    }   

//hi
    string += 'storeWord('+RTH(i)+',vAddr'; 

    //So we can process exceptions
    if (isDelaySlot === true)
    {
        var a = (programCounter+offset+4)|0;
        string += ', ' + a + ', true);';
    }
    else
    {
        var a = (programCounter+offset)|0;
        string += ', ' + a + ');';
    }

    string += '}';

    return string;
}

function r4300i_dmultu(i) {
    return 'inter_dmultu('+i+');';
}

function r4300i_dsll32(i) {
    return '{'+_RDH(i)+'='+RT(i)+'<<'+sa(i)+';'+_RD(i)+'=0;}';
}

function r4300i_dsra32(i) {
    return '{'+_RD(i)+'='+RTH(i)+'>>'+sa(i)+';'+_RDH(i)+'='+RTH(i)+'>>31;}';
}

function r4300i_ddivu(i) {
    return 'inter_ddivu('+i+');'
}

function r4300i_ddiv(i) {
    alert('ddiv');

    return 'inter_ddiv('+i+');'
}

function r4300i_dadd(i) {
    log('todo: dadd');

    return r4300i_dadd(i);
}

function r4300i_break(i)
{
    log('todo: break');
    return('');
}

function r4300i_COP0_tlbwi(i)
{
	//var index = cp0[INDEX] & NTLBENTRIES;
        
    log('todo: tlbwi');
    return('');
}

function r4300i_div(i) {
    return 'inter_div('+i+');'; 
}

function r4300i_divu(i) {
    return 'inter_divu('+i+');'; 
}

function r4300i_sra(i) {
    //optimization: sra's r[hi] can safely right-shift RT.
    return '{'+_RD(i)+'='+RT(i)+'>>'+sa(i)+';'+_RDH(i)+'='+RT(i)+'>>31}';
}

//not compiled
function eret()
{
    if((cp0[STATUS] & ERL) !== 0)
	{
		alert('error epc');
        programCounter = cp0[ERROREPC];
		cp0[STATUS] &= ~ERL;
	}
	else
	{
		programCounter = cp0[EPC];
		cp0[STATUS] &= ~EXL;
    }

	LLbit = 0;
}

function r4300i_COP0_eret(i)
{
    stopCompiling = true;
    
	return '{eret(); return code[getFnName(programCounter)];}';
}

function r4300i_COP0_tlbp(i)
{
    log('todo: tlbp');
    return('');
}

function r4300i_COP0_tlbr(i)
{
    log('todo: tlbr');
    return('');
}

function inter_lwl(i, vAddr)
{
    var vAddrAligned = (vAddr&0xfffffffc)|0;
    var value = loadWord(vAddrAligned);

	switch(vAddr & 3)
	{
	case 0: r[rt(i)] = value; break;
	case 1: r[rt(i)] = (r[rt(i)] & 0x000000ff) | ((value << 8)>>>0); break;
	case 2: r[rt(i)] = (r[rt(i)] & 0x0000ffff) | ((value << 16)>>>0); break;
	case 3: r[rt(i)] = (r[rt(i)] & 0x00ffffff) | ((value << 24)>>>0); break;
	}

    h[rt(i)] = r[rt(i)]>>31;
}

function inter_lwr(i, vAddr)
{
    var vAddrAligned = (vAddr&0xfffffffc)|0;    
    var value = loadWord(vAddrAligned);

	switch(vAddr & 3)
	{
	case 3: r[rt(i)] = value; break;
	case 2: r[rt(i)] = (r[rt(i)] & 0xff000000) | (value >>> 8); break;
	case 1: r[rt(i)] = (r[rt(i)] & 0xffff0000) | (value >>> 16); break;
	case 0: r[rt(i)] = (r[rt(i)] & 0xffffff00) | (value >>> 24); break;
	}

    h[rt(i)] = r[rt(i)]>>31;
}

function inter_swl(i, vAddr)
{
    var vAddrAligned = (vAddr&0xfffffffc)|0;
    var value = loadWord(vAddrAligned);

	switch(vAddr & 3)
	{
	case 0: value = r[rt(i)]; break;
	case 1: value = ((value & 0xff000000) | (r[rt(i)] >>> 8) ); break;
	case 2: value = ((value & 0xffff0000) | (r[rt(i)] >>> 16) ); break;
	case 3: value = ((value & 0xffffff00) | (r[rt(i)] >>> 24) ); break;
    }

    storeWord(value, vAddrAligned, false);
}

function inter_swr(i, vAddr)
{
    var vAddrAligned = (vAddr&0xfffffffc)|0;
    var value = loadWord(vAddrAligned);

	switch(vAddr & 3)
	{
	case 3: value = r[rt(i)]; break;
	case 2: value = ((value & 0x000000FF) | ((r[rt(i)] << 8)>>>0 ) ); break;
	case 1: value = ((value & 0x0000FFFF) | ((r[rt(i)] << 16)>>>0) ); break;
	case 0: value = ((value & 0x00FFFFFF) | ((r[rt(i)] << 24)>>>0) ); break;
	}
    
    storeWord(value, vAddrAligned, false);
}

function r4300i_lwl(i)
{
    var string = '{'+setVAddr(i);
    string += 'inter_lwl('+i+', vAddr);}';
    
    return string;
}

function r4300i_lwr(i)
{
    var string = '{'+setVAddr(i);
    string += 'inter_lwr('+i+', vAddr);}';
    
    return string;
}

function r4300i_swl(i)
{
    var string = '{'+setVAddr(i);
    string += 'inter_swl('+i+', vAddr);}';
    
    return string;
}

function r4300i_swr(i)
{
    var string = '{'+setVAddr(i);
    string += 'inter_swr('+i+', vAddr);}';
    
    return string;
}

function r4300i_lwc1(i)
{
    return '{'+setVAddr(i)+'cp1_i['+FT32ArrayView(i)+']=loadWord(vAddr);}';
}

function r4300i_ldc1(i)
{
    var string = '{'+setVAddr(i)+'cp1_i['+FT32ArrayView(i)+']=loadWord((vAddr+4)|0);'; 
    string += 'cp1_i['+FT32HIArrayView(i)+']=loadWord((vAddr)|0);}'; 

    return string;
}

function r4300i_swc1(i, isDelaySlot)
{
    var string = '{'+setVAddr(i)+'storeWord(cp1_i['+FT32ArrayView(i)+'],vAddr'; 

    //So we can process exceptions
    if (isDelaySlot === true)
    {
        var a = (programCounter+offset+4)|0;
        string += ', ' + a + ', true)}';
    }
    else
    {
        var a = (programCounter+offset)|0;
        string += ', ' + a + ')}';
    }   

    return string;
}

function r4300i_sdc1(i, isDelaySlot)
{
    var string = '{'+setVAddr(i)+'storeWord(cp1_i['+FT32ArrayView(i)+'],(vAddr+4)|0'; 

    //So we can process exceptions
    if (isDelaySlot === true)
    {
        var a = (programCounter+offset+4)|0;
        string += ', ' + a + ', true);';
    }
    else
    {
        var a = (programCounter+offset)|0;
        string += ', ' + a + ');';
    }   

    string += 'storeWord(cp1_i['+FT32HIArrayView(i)+'],(vAddr)|0'; 

    //So we can process exceptions
    if (isDelaySlot === true)
    {
        var a = (programCounter+offset+4)|0;
        string += ', ' + a + ', true);';
    }
    else
    {
        var a = (programCounter+offset)|0;
        string += ', ' + a + ');';
    }

    string += '}';

    return string;
}

function r4300i_COP1_mtc1(i) {
  return 'cp1_i['+FS32ArrayView(i)+']='+RT(i)+';';
}

function r4300i_COP1_mfc1(i) {
    return '{'+_RT(i)+'=cp1_i['+FS32ArrayView(i)+'];'+_RTH(i)+'='+RT(i)+'>>31;}';
}

function r4300i_COP1_cvts_w(i) {
    return 'cp1_f['+FD32ArrayView(i)+']=cp1_i['+FS32ArrayView(i)+'];';
}

function r4300i_COP1_cvtw_s(i) {
    return 'cp1_i['+FD32ArrayView(i)+']=cp1_f['+FS32ArrayView(i)+'];';
}

function r4300i_COP1_div_s(i) {
    return 'cp1_f['+FD32ArrayView(i)+']=cp1_f['+FS32ArrayView(i)+']/cp1_f['+FT32ArrayView(i)+'];';
}

function r4300i_COP1_div_d(i) {
    return 'cp1_f64['+FD64ArrayView(i)+']=cp1_f64['+FS64ArrayView(i)+']/cp1_f64['+FT64ArrayView(i)+'];';
}

function r4300i_COP1_mul_s(i) {
    return 'cp1_f['+FD32ArrayView(i)+']=cp1_f['+FS32ArrayView(i)+']*cp1_f['+FT32ArrayView(i)+'];';
}

function r4300i_COP1_mul_d(i) {
    return 'cp1_f64['+FD64ArrayView(i)+']=cp1_f64['+FS64ArrayView(i)+']*cp1_f64['+FT64ArrayView(i)+'];';
}

function r4300i_COP1_mov_s(i) {
    return 'cp1_i['+FD32ArrayView(i)+']=cp1_i['+FS32ArrayView(i)+'];';
}

function r4300i_COP1_mov_d(i) {
    return 'cp1_f64['+FD32ArrayView(i)+']=cp1_f64['+FS32ArrayView(i)+'];';
}

function r4300i_COP1_add_s(i) {
    return 'cp1_f['+FD32ArrayView(i)+']=cp1_f['+FS32ArrayView(i)+']+cp1_f['+FT32ArrayView(i)+'];';
}

function r4300i_COP1_sub_s(i) {
    return 'cp1_f['+FD32ArrayView(i)+']=cp1_f['+FS32ArrayView(i)+']-cp1_f['+FT32ArrayView(i)+'];';
}

function r4300i_COP1_cvtd_s(i) {
    return 'cp1_f64['+FD64ArrayView(i)+']=cp1_f['+FS32ArrayView(i)+'];';
}

function r4300i_COP1_cvtd_w(i)
{
    return 'cp1_f64['+FD64ArrayView(i)+']=cp1_i['+FS32ArrayView(i)+'];';
}

function r4300i_COP1_cvts_d(i) {
    return 'cp1_f['+FD32ArrayView(i)+']=cp1_f64['+FS64ArrayView(i)+'];';
}

function r4300i_COP1_cvtw_d(i) {
    return 'cp1_i['+FD32ArrayView(i)+']=cp1_f64['+FS64ArrayView(i)+'];';
}

function r4300i_COP1_add_d(i) {
    return 'cp1_f64['+FD64ArrayView(i)+']=cp1_f64['+FS64ArrayView(i)+']+cp1_f64['+FT64ArrayView(i)+'];';
}

function r4300i_COP1_sub_d(i) {
    return 'cp1_f64['+FD64ArrayView(i)+']=cp1_f64['+FS64ArrayView(i)+']-cp1_f64['+FT64ArrayView(i)+'];';
}

//todo:rounding
function r4300i_COP1_truncw_d(i) {
    return 'cp1_i['+FD32ArrayView(i)+']=cp1_f64['+FS64ArrayView(i)+'];';
}

function r4300i_COP1_truncw_s(i) {
    return 'cp1_i['+FD32ArrayView(i)+']=cp1_f['+FS32ArrayView(i)+'];';
}

function r4300i_COP1_neg_s(i)
{
    return 'cp1_i['+FD32ArrayView(i)+']=cp1_i['+FS32ArrayView(i)+']^0x80000000;';
}

function r4300i_COP1_neg_d(i)
{
    return 'cp1_i['+FD32HIArrayView(i)+']=cp1_i['+FS32HIArrayView(i)+']^0x80000000;';
}

function r4300i_COP1_sqrt_s(i)
{
	return 'cp1_f['+FD32ArrayView(i)+']=Math.sqrt(cp1_f['+FS32ArrayView(i)+']);';
}

function r4300i_sync(i)
{
    log('todo: sync');
    return('');
}

function r4300i_sdr(i)
{
    log('todo: sdr');
    return('');
}

function r4300i_ldl(i)
{
    log('todo: sdr');
    return('');
}

function r4300i_daddi(i)
{
    return 'inter_daddi('+i+');';
}

function r4300i_teq(i)
{
    log('todo: r4300i_teq');
    return ('');
}

function r4300i_tgeu(i)
{
    log('todo: r4300i_tgeu');
    return ('');
}

function r4300i_tlt(i)
{
    log('todo: r4300i_tlt');
    return ('');
}

function r4300i_tltu(i)
{
    log('todo: r4300i_tltu');
    return ('');
}

function r4300i_tne(i)
{
    log('todo: r4300i_tne');
    return ('');
}

//using same as daddi
function r4300i_daddiu(i)
{
    return 'inter_daddiu('+i+');';
}

function r4300i_daddu(i)
{
    return 'inter_daddu('+i+');';
}

function r4300i_C_EQ_D(i)
{
    return 'inter_r4300i_C_cond_fmt_d('+i+');';
}

function r4300i_C_EQ_S(i)
{
    return 'inter_r4300i_C_cond_fmt_s('+i+');';
}

function r4300i_C_LT_S(i)
{
    return 'inter_r4300i_C_cond_fmt_s('+i+');';
}

function r4300i_C_LT_D(i)
{
    return 'inter_r4300i_C_cond_fmt_d('+i+');';
}

function r4300i_C_LE_S(i)
{
    return 'inter_r4300i_C_cond_fmt_s('+i+');';
}

function r4300i_C_LE_D(i)
{
    return 'inter_r4300i_C_cond_fmt_d('+i+');';
}

function r4300i_COP1_bc1f(i)
{
    stopCompiling = true;

    var string = 'if((cp1Con[31]&0x00800000)===0)';
    
    var pc = (programCounter+offset+4 + (soffset_imm(i)<< 2))|0;
    string += '{programCounter=' + pc + ';';
    
    //delay slot
    var instruction = loadWord((programCounter+offset+4)|0);
    var opcode = window[CPU_instruction[instruction>>26 & 0x3f]](instruction, true);
    string += opcode;
    string += 'magic_number++;';
    string += 'return code["'+getFnName(pc)+'"];}';

    //delay slot
    string += 'magic_number++;';
    string+=opcode;offset+=4;

    return string;
}

function r4300i_COP1_bc1t(i)
{
    stopCompiling = true;

    var string = 'if((cp1Con[31]&0x00800000)!==0)';
    
    var pc = (programCounter+offset+4 + (soffset_imm(i)<< 2))|0;
    string += '{programCounter=' + pc + ';';
    
    //delay slot
    var instruction = loadWord((programCounter+offset+4)|0);
    var opcode = window[CPU_instruction[instruction>>26 & 0x3f]](instruction, true);
    string += opcode;
    string += 'magic_number++;';
    string += 'return code["'+getFnName(pc)+'"];}';

    //delay slot
    string += 'magic_number++;';
    string+=opcode;offset+=4;

    return string;
}


function r4300i_COP1_bc1tl(i)
{
    stopCompiling = true;

    var string = 'if((cp1Con[31]&0x00800000)!==0)';
    
    var pc = (programCounter+offset+4 + (soffset_imm(i)<< 2))|0;
    string += '{programCounter=' + pc + ';';

    //delay slot
    var instruction = loadWord((programCounter+offset+4)|0);
    var opcode = window[CPU_instruction[instruction>>26 & 0x3f]](instruction, true);
    string += opcode;
    string += 'magic_number++;';
    string += 'return code["'+getFnName(pc)+'"];}';

    offset+=4; //skip delay slot if branch is not taken
    return string;
}

function r4300i_COP1_bc1fl(i)
{
    stopCompiling = true;

    var string = 'if((cp1Con[31]&0x00800000)===0)';
    
    var pc = (programCounter+offset+4 + (soffset_imm(i)<< 2))|0;
    string += '{programCounter=' + pc + ';';
    
    //delay slot
    var instruction = loadWord((programCounter+offset+4)|0);
    var opcode = window[CPU_instruction[instruction>>26 & 0x3f]](instruction, true);
    string += opcode;
    string += 'magic_number++;';
    string += 'return code["'+getFnName(pc)+'"];}';

    offset+=4; //skip delay slot if branch is not taken
    return string;
}

