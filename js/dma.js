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
    //console.log(message);
}

_1964jsEmulator.prototype.flushDynaCache = function()
{
    if (this.writeToDom === false)
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
    else while (this.kk)
        this.deleteFunction(--this.kk);
}

_1964jsEmulator.prototype.deleteFunction = function(k) {
    //log('cleanup');
    var s = document.getElementsByTagName('script')[k];
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

var _1964jsDMA = function(memory, interrupts, pif) {

    var audioContext;
    var audioBuffer;
    this.startTime = 0;

    this.memory = memory;
    this.interrupts = interrupts;

    this.copyCartToDram = function(pc, isDelaySlot) {
    	var end = this.memory.getInt32(this.memory.piUint8Array, this.memory.piUint8Array, PI_WR_LEN_REG);
    	var to = this.memory.getInt32(this.memory.piUint8Array, this.memory.piUint8Array, PI_DRAM_ADDR_REG);
        var from = this.memory.getInt32(this.memory.piUint8Array, this.memory.piUint8Array, PI_CART_ADDR_REG);

        log('pi dma write ' + (end+1) + ' bytes from ' + dec2hex(from) + ' to ' + dec2hex(to));

        end &= 0x00ffffff;
        to &= 0x00ffffff;

        var transfer = end;
        var remaining = -1;
        
        //end+1 is how many bytes will be copied.
        
        if ((from & 0x10000000) !== 0) {
            from &= 0x0fffffff;

            //the ROM buffer size could be less than the amount requested
            //because the file is not padded with zeros.
            if (from+end+1 > memory.rom.byteLength) {
                transfer = memory.rom.byteLength-from-1;
                remaining = end - transfer;
            }

            for (; transfer>=0; --transfer) {
                memory.rdramUint8Array[to] = memory.romUint8Array[from];
                to++;
                from++;
            }
            //if (remaining !== -1)
            //    alert('doh!' + remaining);
        } else { 
            alert('pi reading from somewhere other than cartridge domain');
        
            while (end-- >= 0) {
                memory.rdramUint8Array[to] = memory.loadByte(from);
                from++;
                to++;
            }
        }

       // clrFlag(spReg1Uint8Array, SP_STATUS_REG, SP_STATUS_HALT);

    	this.interrupts.clrFlag(this.memory.piUint8Array, PI_STATUS_REG, PI_STATUS_IO_BUSY|PI_STATUS_DMA_BUSY);
        this.interrupts.triggerPIInterrupt(pc, isDelaySlot);
    }

    this.copySiToDram = function(pc, isDelaySlot) {
        var end = 63; //read 64 bytes. Is there an si_wr_len_reg?
        var to = this.memory.getInt32(this.memory.siUint8Array, this.memory.siUint8Array, SI_DRAM_ADDR_REG);
        var from = this.memory.getInt32(this.memory.siUint8Array, this.memory.siUint8Array, SI_PIF_ADDR_RD64B_REG);

    	if (from !== 0x1FC007C0 )
    		throw 'Unhandled: SI_DRAM_ADDR_RD64B_REG = ' + from;
        
        log('si dma write ' + (end+1) + ' bytes from ' + dec2hex(from) + ' to ' + dec2hex(to));

        end &= 0x00ffffff;
        to &= 0x0fffffff;
        from &= 0x0000ffff;

        pif.processPif();

        for (; end>=0; --end) {
            this.memory.rdramUint8Array[to] = this.memory.pifUint8Array[from];
            to++;
            from++;
        }

        this.interrupts.setFlag(this.memory.siUint8Array, SI_STATUS_REG, SI_STATUS_INTERRUPT);
        this.interrupts.triggerSIInterrupt(pc, isDelaySlot);
    }

    this.copyDramToAi = function(pc, isDelaySlot)
    {
        var length = this.memory.getInt32(this.memory.aiUint8Array, this.memory.aiUint8Array, AI_LEN_REG);
        var from = this.memory.getInt32(this.memory.aiUint8Array, this.memory.aiUint8Array, AI_DRAM_ADDR_REG);

        //log('ai dma write ' + length + ' bytes from ' + dec2hex(from));

        length &= 0x00ffffff;
        from &= 0x0fffffff;
        
        this.processAudio(from, length);

        this.interrupts.clrFlag(this.memory.aiUint8Array, AI_STATUS_REG, AI_STATUS_FIFO_FULL);
    }

    //this function doesn't belong in dma
    this.processAudio = function(from, length) {
        try {
            if (audioContext === "unsupported")
                return;

            if (audioContext == undefined) {
                audioContext = new webkitAudioContext();
            }
        } catch(error) {
            log("Your browser doesn't support Web Audio.");
            audioContext = "unsupported";
            this.interrupts.clrFlag(this.memory.aiUint8Array, AI_STATUS_REG, AI_STATUS_FIFO_FULL);
            return;
        }

        var PI_2_400 = 1.0/(Math.PI * 2 * 400);

        // Create/set audio buffer for each chunk
        var source = audioContext.createBufferSource();
        if (length < 4)
            return;

        if (audioBuffer === undefined)
            audioBuffer = audioContext.createBuffer(2, length/2/2, 44100);
        var left = audioBuffer.getChannelData(0);
        var right = audioBuffer.getChannelData(1);

        var i=from,k=0;
        for (k=0; k<length; i+=4, k++) {
            left[k]= ((this.memory.rdramUint8Array[i]<<8 | this.memory.rdramUint8Array[i+1])<<16>>16)*PI_2_400;
            right[k] = ((this.memory.rdramUint8Array[i+2]<<8 | this.memory.rdramUint8Array[i+3])<<16>>16)*PI_2_400;
        }

        source.buffer = audioBuffer;
        this.startTime += audioBuffer.duration;
        source.connect(audioContext.destination);
        source.loop = false;
        source.noteOn(this.startTime);
    }

    this.copyDramToSi = function(pc, isDelaySlot) {
        var end = 63; //read 64 bytes. Is there an si_rd_len_reg?
        var to = this.memory.getInt32(this.memory.siUint8Array, this.memory.siUint8Array, SI_PIF_ADDR_WR64B_REG);
        var from = this.memory.getInt32(this.memory.siUint8Array, this.memory.siUint8Array, SI_DRAM_ADDR_REG);
        
    	if (to !== 0x1FC007C0 )
    		throw 'Unhandled: SI_DRAM_ADDR_RD64B_REG = ' + from;

        log('si dma read ' + (end+1) + ' bytes from ' + dec2hex(from) + ' to ' + dec2hex(to));

        end &= 0x00ffffff;
        to &= 0x0000ffff;
        from &= 0x0fffffff;

        for (; end>=0; --end) {
            this.memory.pifUint8Array[to] = this.memory.rdramUint8Array[from];
            to++;
            from++;
        }

        pif.processPif();
        this.interrupts.setFlag(this.memory.siUint8Array, SI_STATUS_REG, SI_STATUS_INTERRUPT);
        this.interrupts.triggerSIInterrupt(pc, isDelaySlot);
    }

    this.copySpToDram = function(pc, isDelaySlot) {
        alert('todo: copySpToDram');
    }

    this.copyDramToSp = function(pc, isDelaySlot) {
        var end = this.memory.getInt32(this.memory.spReg1Uint8Array, this.memory.spReg1Uint8Array, SP_RD_LEN_REG);
        var to = this.memory.getInt32(this.memory.spReg1Uint8Array, this.memory.spReg1Uint8Array, SP_MEM_ADDR_REG);
        var from = this.memory.getInt32(this.memory.spReg1Uint8Array, this.memory.spReg1Uint8Array, SP_DRAM_ADDR_REG);

        log('sp dma read ' + (end+1) + ' bytes from ' + dec2hex(from) + ' to ' + dec2hex(to));

        end &= 0x00000FFF;
        to &= 0x00001fff;
        from &= 0x00ffffff;

        for (; end>=0; --end) {
            this.memory.spMemUint8Array[to] = this.memory.rdramUint8Array[from];
            to++;
            from++;
        }

        this.memory.setInt32(this.memory.spReg1Uint8Array, SP_DMA_BUSY_REG, 0);
        if (this.memory.getInt32(this.memory.spReg1Uint8Array, this.memory.spReg1Uint8Array, SP_STATUS_REG) & (SP_STATUS_DMA_BUSY|SP_STATUS_IO_FULL|SP_STATUS_DMA_FULL))
            alert('hmm..todo: an sp fp status flag is blocking from continuing');
        this.interrupts.clrFlag(this.memory.spReg1Uint8Array, SP_STATUS_REG, SP_STATUS_DMA_BUSY);
        this.interrupts.setFlag(this.memory.spReg1Uint8Array, SP_STATUS_REG, SP_STATUS_HALT);

        //hack for now
        //triggerDPInterrupt(0, false);
    }
}
