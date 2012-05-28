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

function log(message) {
   // console.log(message);
}

function copyCartToDram(pc, isDelaySlot)
{
	var end = getInt32(piUint8Array, piUint8Array, PI_WR_LEN_REG);
	var to = getInt32(piUint8Array, piUint8Array, PI_DRAM_ADDR_REG);
    var from = getInt32(piUint8Array, piUint8Array, PI_CART_ADDR_REG);

    log('pi dma write ' + (end+1) + ' bytes from ' + dec2hex(from) + ' to ' + dec2hex(to));

    end &= 0x00ffffff;
    to &= 0x00ffffff;

    var transfer = end;
    var remaining = -1;
    
    //end+1 is how many bytes will be copied.
    
    if ((from & 0x10000000) !== 0)
    {
        from &= 0x0fffffff;

        //the ROM buffer size could be less than the amount requested
        //because the file is not padded with zeros.
        if (from+end+1 > rom.byteLength)
        {
            transfer = rom.byteLength-from-1;
            remaining = end - transfer;
        }

        for (; transfer>=0; --transfer)
        {
            rdramUint8Array[to] = romUint8Array[from];
            to++;
            from++;
        }
        
//        if (remaining !== -1)
//            alert('doh!' + remaining);
    }
    else
    { 
        alert('pi reading from somewhere other than cartridge domain');
    
        while (end-- >= 0)
        {
            rdramUint8Array[to] = loadByte(from);
            from++;
            to++;
        }
    }

   // clrFlag(spReg1Uint8Array, SP_STATUS_REG, SP_STATUS_HALT);

	clrFlag(piUint8Array, PI_STATUS_REG, PI_STATUS_IO_BUSY|PI_STATUS_DMA_BUSY);
    triggerPIInterrupt(pc, isDelaySlot);
}

function flushDynaCache()
{
    if (writeToDom === false)
    {
        for (var pc in code)
        {
            delete code[pc];
            //eval('code.'+ pc + '= function(r){alert("yo")}; delete code.' + pc + ';');
                if (code[pc])
                    alert('crap');
        }
        delete code;
        code = new Object;
    }
    else while (kk)
    {

        //log('cleanup');
        s = document.getElementsByTagName('script')[--kk];
        
        var splitResult = s.text.split('_');
        splitResult = splitResult[1].split('(');

        var pc = '_' + splitResult[0];
       // s.text = '';

        s.parentNode.removeChild(s);
 
        var splitResult = s.text.split('_');
       
        //allow deletion of this function
        eval(pc + '= function(r){}; delete ' + pc + ';');
        
       // log('now it is:' + s.text + '.');
        
        fnName = pc; 
        window[fnName] = null;
        //log(s.text);

        if (window[fnName])
            alert('blah');
    }
}

function copySiToDram(pc, isDelaySlot)
{
    var end = 63; //read 64 bytes. Is there an si_wr_len_reg?
    var to = getInt32(siUint8Array, siUint8Array, SI_DRAM_ADDR_REG);
    var from = getInt32(siUint8Array, siUint8Array, SI_DRAM_ADDR_RD64B_REG);
    
	if (from !== 0x1FC007C0 )
		throw 'Unhandled: SI_DRAM_ADDR_RD64B_REG = ' + from;
    
    log('si dma write ' + (end+1) + ' bytes from ' + dec2hex(from) + ' to ' + dec2hex(to));

    end &= 0x00ffffff;
    to &= 0x0fffffff;
    from &= 0x0000ffff;


    for (; end>=0; --end)
    {
        rdramUint8Array[to] = pifUint8Array[from];
        to++;
        from++;
    }

    triggerSIInterrupt(pc, isDelaySlot);
}

function copyDramToAi(pc, isDelaySlot)
{
    var length = getInt32(aiUint8Array, aiUint8Array, AI_LEN_REG);
    var from = getInt32(aiUint8Array, aiUint8Array, AI_DRAM_ADDR_REG);

    //log('ai dma write ' + length + ' bytes from ' + dec2hex(from));

    length &= 0x00ffffff;
    from &= 0x0fffffff;
    
    processAudio(from, length);

    clrFlag(aiUint8Array, AI_STATUS_REG, AI_STATUS_FIFO_FULL);
}

function processAudio(from, length)
{
    try 
    {
        if (audioContext == undefined)
        {
            audioContext = new webkitAudioContext();

        }
    }
    catch(error)
    {
        log("Your browser doesn't support Web Audio.");
        clrFlag(aiUint8Array, AI_STATUS_REG, AI_STATUS_FIFO_FULL);
        return;
    }

    var PI_2_400 = 1.0/(Math.PI * 2 * 400);
    {
        // Create/set audio buffer for each chunk
        var source = audioContext.createBufferSource();
        if (length < 4)
            return;

        if (audioBuffer === undefined)
            audioBuffer = audioContext.createBuffer(2, length/2/2, 44100);
        var left = audioBuffer.getChannelData(0);
        var right = audioBuffer.getChannelData(1);

        var i=from,k=0;
        for (k=0; k<length; i+=4, k++)
        {
            left[k]= ((rdramUint8Array[i]<<8 | rdramUint8Array[i+1])<<16>>16)*PI_2_400;
            right[k] = ((rdramUint8Array[i+2]<<8 | rdramUint8Array[i+3])<<16>>16)*PI_2_400;
        }

        source.buffer = audioBuffer;
        startTime += audioBuffer.duration;
        source.connect(audioContext.destination);
        source.loop = false;
        source.noteOn(startTime);
    }    
}


function copyDramToSi(pc, isDelaySlot)
{
    var end = 63; //read 64 bytes. Is there an si_rd_len_reg?
    var to = getInt32(siUint8Array, siUint8Array, SI_PIF_ADDR_WR64B_REG);
    var from = getInt32(siUint8Array, siUint8Array, SI_DRAM_ADDR_REG);
    
	if (to !== 0x1FC007C0 )
		throw 'Unhandled: SI_DRAM_ADDR_RD64B_REG = ' + from;

    log('si dma read ' + (end+1) + ' bytes from ' + dec2hex(from) + ' to ' + dec2hex(to));

    end &= 0x00ffffff;
    to &= 0x0000ffff;
    from &= 0x0fffffff;

    for (; end>=0; --end)
    {
        pifUint8Array[to] = rdramUint8Array[from];
        to++;
        from++;
    }

    processPif();

    triggerSIInterrupt(pc, isDelaySlot);
}

function copySpToDram(pc, isDelaySlot)
{
    alert('todo: copySpToDram');
}

function copyDramToSp(pc, isDelaySlot)
{
    var end = getInt32(spReg1Uint8Array, spReg1Uint8Array, SP_RD_LEN_REG);
    var to = getInt32(spReg1Uint8Array, spReg1Uint8Array, SP_MEM_ADDR_REG);
    var from = getInt32(spReg1Uint8Array, spReg1Uint8Array, SP_DRAM_ADDR_REG);

    log('sp dma read ' + (end+1) + ' bytes from ' + dec2hex(from) + ' to ' + dec2hex(to));

    end &= 0x00000FFF;
    to &= 0x00001fff;
    from &= 0x00ffffff;

    for (; end>=0; --end)
    {
        spMemUint8Array[to] = rdramUint8Array[from];
        to++;
        from++;
    }

    setInt32(spReg1Uint8Array, SP_DMA_BUSY_REG, 0);
    if (getInt32(spReg1Uint8Array, spReg1Uint8Array, SP_STATUS_REG) & (SP_STATUS_DMA_BUSY|SP_STATUS_IO_FULL|SP_STATUS_DMA_FULL))
        alert('hmm..todo: an sp fp status flag is blockinging from continuing');
    clrFlag(spReg1Uint8Array, SP_STATUS_REG, SP_STATUS_DMA_BUSY);
    setFlag(spReg1Uint8Array, SP_STATUS_REG, SP_STATUS_HALT);
    
    //hack for now
    //triggerDPInterrupt(0, false);
}
