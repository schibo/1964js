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

//1964cpp treats consts.MI_INTR_MASK_REG_R as a separate memory location. Not sure that's right.

/*jslint bitwise: true, devel: true, todo: true*/
/*globals consts, log, C1964jsVideoHLE*/

var currentHack = 0;

var C1964jsInterrupts = function (core, cp0) {
    "use strict";
    this.setException = function (exception, causeFlag, pc, isFromDelaySlot) {
      //  log('set exception');
        cp0[consts.CAUSE] |= exception;
        cp0[consts.CAUSE] |= causeFlag;
    };

    this.processException = function (pc, isFromDelaySlot) {
        if ((cp0[consts.STATUS] & consts.IE) === 0) {
            return false;
        }

        if ((cp0[consts.STATUS] & consts.EXL) !== 0) {
            log("nested exception");
            return false;
        }

        cp0[consts.CAUSE] &= 0xFFFFFF83; //Clear exception code flags
        cp0[consts.STATUS] |= consts.EXL;

        if (isFromDelaySlot === true) {
            log("Exception happens in CPU delay slot, pc=" + pc);
            cp0[consts.CAUSE] |= consts.BD;
            cp0[consts.EPC] = pc - 4;
           // throw 'interrupt';
        } else {
            cp0[consts.CAUSE] &= ~consts.BD;
            cp0[consts.EPC] = pc;
            //throw 'interrupt';
        }

        if (core.doOnce === 0) {
            core.flushDynaCache();
        }

        core.doOnce = 1;
        core.programCounter = 0x80000180;

        return true;
    };

    this.triggerCompareInterrupt = function (pc, isFromDelaySlot) {
        this.setException(consts.EXC_INT, consts.CAUSE_IP8, pc, isFromDelaySlot);
    };

    this.triggerPIInterrupt = function (pc, isFromDelaySlot) {
        this.setFlag(core.memory.miUint8Array, consts.MI_INTR_REG, consts.MI_INTR_PI);

        var value = core.memory.miUint8Array[consts.MI_INTR_MASK_REG] << 24 | core.memory.miUint8Array[consts.MI_INTR_MASK_REG + 1] << 16 | core.memory.miUint8Array[consts.MI_INTR_MASK_REG + 2] << 8 | core.memory.miUint8Array[consts.MI_INTR_MASK_REG + 3];
        if ((value & consts.MI_INTR_MASK_PI) !== 0) {
            this.setException(consts.EXC_INT, consts.CAUSE_IP3, pc, isFromDelaySlot);
        }
    };

    this.triggerSPInterrupt = function (pc, isFromDelaySlot) {
        this.setFlag(core.memory.miUint8Array, consts.MI_INTR_REG, consts.MI_INTR_SP);

        var value = core.memory.miUint8Array[consts.MI_INTR_MASK_REG] << 24 | core.memory.miUint8Array[consts.MI_INTR_MASK_REG + 1] << 16 | core.memory.miUint8Array[consts.MI_INTR_MASK_REG + 2] << 8 | core.memory.miUint8Array[consts.MI_INTR_MASK_REG + 3];
        if ((value & consts.MI_INTR_MASK_SP) !== 0) {
            this.setException(consts.EXC_INT, consts.CAUSE_IP3, pc, isFromDelaySlot);
        }
    };

    this.triggerVIInterrupt = function (pc, isFromDelaySlot) {
        this.setFlag(core.memory.miUint8Array, consts.MI_INTR_REG, consts.MI_INTR_VI);

        var value = core.memory.miUint8Array[consts.MI_INTR_MASK_REG] << 24 | core.memory.miUint8Array[consts.MI_INTR_MASK_REG + 1] << 16 | core.memory.miUint8Array[consts.MI_INTR_MASK_REG + 2] << 8 | core.memory.miUint8Array[consts.MI_INTR_MASK_REG + 3];
        if ((value & consts.MI_INTR_MASK_VI) !== 0) {
            this.setException(consts.EXC_INT, consts.CAUSE_IP3, pc, isFromDelaySlot);
        }
    };

    this.triggerSIInterrupt = function (pc, isFromDelaySlot) {
        this.setFlag(core.memory.miUint8Array, consts.MI_INTR_REG, consts.MI_INTR_SI);

        var value = core.memory.miUint8Array[consts.MI_INTR_MASK_REG] << 24 | core.memory.miUint8Array[consts.MI_INTR_MASK_REG + 1] << 16 | core.memory.miUint8Array[consts.MI_INTR_MASK_REG + 2] << 8 | core.memory.miUint8Array[consts.MI_INTR_MASK_REG + 3];
        if ((value & consts.MI_INTR_MASK_SI) !== 0) {
            this.setException(consts.EXC_INT, consts.CAUSE_IP3, pc, isFromDelaySlot);
        }
    };

    this.triggerAIInterrupt = function (pc, isFromDelaySlot) {
        this.setFlag(core.memory.miUint8Array, consts.MI_INTR_REG, consts.MI_INTR_AI);

        var value = core.memory.miUint8Array[consts.MI_INTR_MASK_REG] << 24 | core.memory.miUint8Array[consts.MI_INTR_MASK_REG + 1] << 16 | core.memory.miUint8Array[consts.MI_INTR_MASK_REG + 2] << 8 | core.memory.miUint8Array[consts.MI_INTR_MASK_REG + 3];
        if ((value & consts.MI_INTR_MASK_AI) !== 0) {
            this.setException(consts.EXC_INT, consts.CAUSE_IP3, pc, isFromDelaySlot);
        }
    };

    this.triggerDPInterrupt = function (pc, isFromDelaySlot) {
        this.setFlag(core.memory.miUint8Array, consts.MI_INTR_REG, consts.MI_INTR_DP);

        var value = core.memory.miUint8Array[consts.MI_INTR_MASK_REG] << 24 | core.memory.miUint8Array[consts.MI_INTR_MASK_REG + 1] << 16 | core.memory.miUint8Array[consts.MI_INTR_MASK_REG + 2] << 8 | core.memory.miUint8Array[consts.MI_INTR_MASK_REG + 3];
        if ((value & consts.MI_INTR_MASK_DP) !== 0) {
            this.setException(consts.EXC_INT, consts.CAUSE_IP3, pc, isFromDelaySlot);
        }
    };

    this.triggerRspBreak = function () {
        this.setFlag(core.memory.spReg1Uint8Array, consts.SP_STATUS_REG, consts.SP_STATUS_TASKDONE | consts.SP_STATUS_BROKE | consts.SP_STATUS_HALT);

        var value = core.memory.spReg1Uint8Array[consts.SP_STATUS_REG] << 24 | core.memory.spReg1Uint8Array[consts.SP_STATUS_REG + 1] << 16 | core.memory.spReg1Uint8Array[consts.SP_STATUS_REG + 2] << 8 | core.memory.spReg1Uint8Array[consts.SP_STATUS_REG + 3];
        if ((value & consts.SP_STATUS_INTR_BREAK) !== 0) {
            this.triggerSPInterrupt(0, false);
        }
    };

    this.clearMIInterrupt = function (flag) {
        this.clrFlag(core.memory.miUint8Array, consts.MI_INTR_REG, flag);

        var value = core.memory.miUint8Array[consts.MI_INTR_MASK_REG] << 24 | core.memory.miUint8Array[consts.MI_INTR_MASK_REG + 1] << 16 | core.memory.miUint8Array[consts.MI_INTR_MASK_REG + 2] << 8 | core.memory.miUint8Array[consts.MI_INTR_MASK_REG + 3];
        if ((value & (core.memory.getUint32(core.memory.miUint8Array, consts.MI_INTR_REG))) === 0) {
            cp0[consts.CAUSE] &= ~consts.CAUSE_IP3;
            //if((cp0[CAUSE] & cp0[STATUS] & SR_IMASK) == 0)
            //    CPUNeedToCheckInterrupt = FALSE;
        }
    };

    this.readVI = function (offset) {
        switch (offset) {
        case consts.VI_CURRENT_REG:
            //hack for berney demo
            if ((currentHack += 1) === 625) {
                currentHack = 0;
              //  triggerVIInterrupt(pc, isFromDelaySlot);
                //warning: need to refactor. triggerVIInterrupt
                //can service an interrupt immediately without setting rt[i]
            }
            //return currentHack;
            return ((core.memory.getInt32(core.memory.viUint8Array, core.memory.viUint8Array, offset) & 0xfffffffe) + currentHack) | 0;
        default:
            log('unhandled video interface for vi offset: ' + offset);
            return core.memory.getInt32(core.memory.viUint8Array, core.memory.viUint8Array, offset);
        }
    };

    this.writeVI = function (offset, value, pc, isFromDelaySlot) {
        switch (offset) {
        case consts.VI_ORIGIN_REG:
            core.memory.setInt32(core.memory.viUint8Array, offset, value);
           // var c = document.getElementById("Canvas");
           // var ctx = c.getContext("2d");
           // repaint(ctx,ImDat,value & 0x00FFFFFF);
           //alert('origin changed' + dec2hex(value));
            break;
        case consts.VI_CURRENT_REG:
            this.clearMIInterrupt(consts.MI_INTR_VI);
            core.memory.setInt32(core.memory.viUint8Array, offset, value);
            break;
        case consts.VI_INTR_REG:
            core.memory.setInt32(core.memory.viUint8Array, offset, value);
            break;
        default:
            core.memory.setInt32(core.memory.viUint8Array, offset, value);
            //log('unhandled vi write: ' + offset);
            break;
        }
    };

    this.writePI = function (offset, value, pc, isFromDelaySlot) {
        switch (offset) {
        case consts.PI_WR_LEN_REG:
            core.memory.setInt32(core.memory.piUint8Array, offset, value);
            core.dma.copyCartToDram(pc, isFromDelaySlot);
            break;
        case consts.PI_RD_LEN_REG:
            core.memory.setInt32(core.memory.piUint8Array, offset, value);
            alert('write to PI_RD_LEN_REG');
            core.dma.copyDramToCart(pc, isFromDelaySlot);
            break;
        case consts.PI_DRAM_ADDR_REG:
            core.memory.setInt32(core.memory.piUint8Array, offset, value);
            break;
        case consts.PI_CART_ADDR_REG:
            core.memory.setInt32(core.memory.piUint8Array, offset, value);
            break;
        case consts.PI_STATUS_REG:
            this.writePIStatusReg(value, pc, isFromDelaySlot);
            break;
        default:
            core.memory.setInt32(core.memory.piUint8Array, offset, value);
            log('unhandled pi write: ' + offset);
            break;
        }
    };

    this.writeSI = function (offset, value, pc, isFromDelaySlot) {
        switch (offset) {
        case consts.SI_DRAM_ADDR_REG:
            core.memory.setInt32(core.memory.siUint8Array, offset, value);
            break;
        case consts.SI_STATUS_REG:
            this.writeSIStatusReg(value, pc, isFromDelaySlot);
            break;
        case consts.SI_PIF_ADDR_RD64B_REG:
            core.memory.setInt32(core.memory.siUint8Array, offset, value);
            core.dma.copySiToDram(pc, isFromDelaySlot);
            break;
        case consts.SI_PIF_ADDR_WR64B_REG:
            core.memory.setInt32(core.memory.siUint8Array, offset, value);
            core.dma.copyDramToSi(pc, isFromDelaySlot);
            break;
        default:
            core.memory.setInt32(core.memory.siUint8Array, offset, value);
            log('unhandled si write: ' + offset);
            break;
        }
    };

    this.readSI = function (offset) {
        switch (offset) {
        case consts.SI_STATUS_REG:
            this.readSIStatusReg();
            return core.memory.getInt32(core.memory.siUint8Array, core.memory.siUint8Array, offset);
        default:
            log('unhandled si read: ' + offset);
            return core.memory.getInt32(core.memory.siUint8Array, core.memory.siUint8Array, offset);
        }
    };

    this.readSIStatusReg = function () {
        if ((core.memory.getUint32(core.memory.miUint8Array, consts.MI_INTR_REG) & consts.MI_INTR_SI) !== 0) {
            this.setFlag(core.memory.siUint8Array, consts.SI_STATUS_REG, consts.SI_STATUS_INTERRUPT);
        } else {
            this.clrFlag(core.memory.siUint8Array, consts.SI_STATUS_REG, consts.SI_STATUS_INTERRUPT);
        }
    };

    this.readAI = function (offset) {
        switch (offset) {
        case consts.AI_LEN_REG:
            //todo: implement AI_LEN_REG -- how many bytes unconsumed..
            core.kfi -= 1;
            if (core.kfi === 0) {
                core.kfi = 512;
                this.setFlag(core.memory.aiUint8Array, consts.AI_STATUS_REG, consts.AI_STATUS_FIFO_FULL);
                this.triggerAIInterrupt(0, false);
                //checkInterrupts();
                return 0;
            }
            return 0;
            //return kfi;
            //return getInt32(aiUint8Array, aiUint8Array, offset);
        case consts.AI_STATUS_REG:
            return core.memory.getInt32(core.memory.aiUint8Array, core.memory.aiUint8Array, offset);
        default:
            log('unhandled read ai reg ' + offset);
            return core.memory.getInt32(core.memory.aiUint8Array, core.memory.aiUint8Array, offset);
        }
    };

    this.writeAI = function (offset, value, pc, isFromDelaySlot) {
        switch (offset) {
        case consts.AI_DRAM_ADDR_REG:
            core.memory.setInt32(core.memory.aiUint8Array, offset, value);
            break;
        case consts.AI_LEN_REG:
            core.memory.setInt32(core.memory.aiUint8Array, offset, value);
            core.dma.copyDramToAi(pc, isFromDelaySlot);
            break;
        case consts.AI_STATUS_REG:
            this.clearMIInterrupt(consts.MI_INTR_AI);
            break;
        case consts.AI_DACRATE_REG:
           // log("todo: write AI_DACRATE_REG");
            core.memory.setInt32(core.memory.aiUint8Array, offset, value);
            break;
        case consts.AI_CONTROL_REG:
            core.memory.setInt32(core.memory.aiUint8Array, offset, value & 1);
            break;
        default:
            //log('unhandled write ai reg ' + offset);
            core.memory.setInt32(core.memory.aiUint8Array, offset, value);
            return;
        }
    };

    this.writeMI = function (offset, value, pc, isFromDelaySlot) {
        switch (offset) {
        case consts.MI_INIT_MODE_REG:
            this.writeMIModeReg(value);
            break;
        case consts.MI_INTR_MASK_REG:
            this.writeMIIntrMaskReg(value, pc, isFromDelaySlot);
            break;
        case consts.MI_VERSION_REG:
        case consts.MI_INTR_REG:
            //do nothing. read-only
            break;
        default:
            core.memory.setInt32(core.memory.miUint8Array, offset, value);
            log('unhandled mips interface for mi offset: ' + offset);
            break;
        }
    };

    this.readSPReg1 = function (offset) {
        switch (offset) {
        case consts.SP_STATUS_REG:
            return core.memory.getInt32(core.memory.spReg1Uint8Array, core.memory.spReg1Uint8Array, offset);
        case consts.SP_SEMAPHORE_REG:
            var temp = core.memory.getInt32(core.memory.aiUint8Array, core.memory.aiUint8Array, offset);
            core.memory.setInt32(core.memory.spReg1Uint8Array, offset, 1);
            return temp;
        default:
            log('unhandled read sp reg1 ' + offset);
            return core.memory.getInt32(core.memory.spReg1Uint8Array, core.memory.spReg1Uint8Array, offset);
        }
    };

    this.writeSPReg1 = function (offset, value, pc, isFromDelaySlot) {
        switch (offset) {
        case consts.SP_STATUS_REG:
            this.writeSPStatusReg(value, pc, isFromDelaySlot);
            break;
        case consts.SP_SEMAPHORE_REG:
            core.memory.setInt32(core.memory.spReg1Uint8Array, offset, 0);
            break;
        case consts.SP_WR_LEN_REG:
            core.memory.setInt32(core.memory.spReg1Uint8Array, offset, value);
            core.dma.copySpToDram(pc, isFromDelaySlot);
            break;
        case consts.SP_RD_LEN_REG:
            core.memory.setInt32(core.memory.spReg1Uint8Array, offset, value);
            core.dma.copyDramToSp(pc, isFromDelaySlot);
            break;
        default:
            core.memory.setInt32(core.memory.spReg1Uint8Array, offset, value);
            log('unhandled sp reg1 write: ' + offset);
            break;
        }
    };

    this.writeSPReg2 = function (offset, value, pc, isFromDelaySlot) {
        switch (offset) {
        case consts.SP_PC_REG:
            log('writing sp pc: ' + value);
            core.memory.setInt32(core.memory.spReg2Uint8Array, offset, value & 0x00000FFC);
            break;
        default:
            core.memory.setInt32(core.memory.spReg2Uint8Array, offset, value);
            log('unhandled sp reg2 write: ' + offset);
            break;
        }
    };

    //Set flag for memory register
    this.setFlag = function (where, offset, flag) {
        var value = core.memory.getUint32(where, offset);
        value |= flag;
        core.memory.setInt32(where, offset, value);
    };

    //Clear flag for memory register
    this.clrFlag = function (where, offset, flag) {
        var value = core.memory.getUint32(where, offset);
        value &= ~flag;
        core.memory.setInt32(where, offset, value);
    };

    this.writeMIModeReg = function (value) {
        if (value & consts.MI_SET_RDRAM) {
            this.setFlag(core.memory.miUint8Array, consts.MI_INIT_MODE_REG, consts.MI_MODE_RDRAM);
        } else if (value & consts.MI_CLR_RDRAM) {
            this.clrFlag(core.memory.miUint8Array, consts.MI_INIT_MODE_REG, consts.MI_MODE_RDRAM);
        }

        if (value & consts.MI_SET_INIT) {
            this.setFlag(core.memory.miUint8Array, consts.MI_INIT_MODE_REG, consts.MI_MODE_INIT);
        } else if (value & consts.MI_CLR_INIT) {
            this.clrFlag(core.memory.miUint8Array, consts.MI_INIT_MODE_REG, consts.MI_MODE_INIT);
        }

        if (value & consts.MI_SET_EBUS) {
            this.setFlag(core.memory.miUint8Array, consts.MI_INIT_MODE_REG, consts.MI_MODE_EBUS);
        } else if (value & consts.MI_CLR_EBUS) {
            this.clrFlag(core.memory.miUint8Array, consts.MI_INIT_MODE_REG, consts.MI_MODE_EBUS);
        }

        if (value & consts.MI_CLR_DP_INTR) {
            //this.clrFlag(miUint8Array, consts.MI_INTR_REG, consts.MI_INTR_DP);
            //setInt32(miUint8Array, MI_INIT_MODE_REG, core.memory.getUint32(miUint8Array, MI_INIT_MODE_REG)|(value&0x7f)); 
            this.clearMIInterrupt(consts.MI_INTR_DP);
        }
    };

    this.writeMIIntrMaskReg = function (value, pc, isFromDelaySlot) {
        if (value & consts.MI_INTR_MASK_SP_SET) {
            this.setFlag(core.memory.miUint8Array, consts.MI_INTR_MASK_REG, consts.MI_INTR_SP);
        } else if (value & consts.MI_INTR_MASK_SP_CLR) {
            this.clrFlag(core.memory.miUint8Array, consts.MI_INTR_MASK_REG, consts.MI_INTR_SP);
        }

        if (value & consts.MI_INTR_MASK_SI_SET) {
            this.setFlag(core.memory.miUint8Array, consts.MI_INTR_MASK_REG, consts.MI_INTR_SI);
        } else if (value & consts.MI_INTR_MASK_SI_CLR) {
            this.clrFlag(core.memory.miUint8Array, consts.MI_INTR_MASK_REG, consts.MI_INTR_SI);
        }

        if (value & consts.MI_INTR_MASK_AI_SET) {
            this.setFlag(core.memory.miUint8Array, consts.MI_INTR_MASK_REG, consts.MI_INTR_AI);
        } else if (value & consts.MI_INTR_MASK_AI_CLR) {
            this.clrFlag(core.memory.miUint8Array, consts.MI_INTR_MASK_REG, consts.MI_INTR_AI);
        }

        if (value & consts.MI_INTR_MASK_VI_SET) {
            this.setFlag(core.memory.miUint8Array, consts.MI_INTR_MASK_REG, consts.MI_INTR_VI);
        } else if (value & consts.MI_INTR_MASK_VI_CLR) {
            this.clrFlag(core.memory.miUint8Array, consts.MI_INTR_MASK_REG, consts.MI_INTR_VI);
        }

        if (value & consts.MI_INTR_MASK_PI_SET) {
            this.setFlag(core.memory.miUint8Array, consts.MI_INTR_MASK_REG, consts.MI_INTR_PI);
        } else if (value & consts.MI_INTR_MASK_PI_CLR) {
            this.clrFlag(core.memory.miUint8Array, consts.MI_INTR_MASK_REG, consts.MI_INTR_PI);
        }

        if (value & consts.MI_INTR_MASK_DP_SET) {
            this.setFlag(core.memory.miUint8Array, consts.MI_INTR_MASK_REG, consts.MI_INTR_DP);
        } else if (value & consts.MI_INTR_MASK_DP_CLR) {
            this.clrFlag(core.memory.miUint8Array, consts.MI_INTR_MASK_REG, consts.MI_INTR_DP);
        }

        //Check MI interrupt again. This is important, otherwise we will lose interrupts.
        if ((core.memory.getUint32(core.memory.miUint8Array, consts.MI_INTR_MASK_REG) & 0x0000003F & core.memory.getUint32(core.memory.miUint8Array, consts.MI_INTR_REG)) !== 0) {
            //Trigger an MI interrupt since we don't know what it is.
            this.setException(consts.EXC_INT, consts.CAUSE_IP3, pc, isFromDelaySlot);
        }
    };

    this.writeSIStatusReg = function (value, pc, isFromDelaySlot) {
        //Clear SI interrupt unconditionally
        //clearMIInterrupt(consts.MI_INTR_SI); //wrong!
        this.clrFlag(core.memory.siUint8Array, consts.SI_STATUS_REG, consts.SI_STATUS_INTERRUPT);
    };

    this.writeSPStatusReg = function (value, pc, isFromDelaySlot) {
        if (value & consts.SP_CLR_BROKE) {
            this.clrFlag(core.memory.spReg1Uint8Array, consts.SP_STATUS_REG, consts.SP_STATUS_BROKE);
        }

        if (value & consts.SP_SET_INTR) {
            this.triggerSPInterrupt(pc, isFromDelaySlot);
        //to use else if here is a possible bux fix (what is this?..this looks weird)
        } else if (value & consts.SP_CLR_INTR) {
            this.clearMIInterrupt(consts.MI_INTR_SP);
        }

        if (value & consts.SP_SET_SSTEP) {
            this.setFlag(core.memory.spReg1Uint8Array, consts.SP_STATUS_REG, consts.SP_STATUS_SSTEP);
        } else if (value & consts.SP_CLR_SSTEP) {
            this.clrFlag(core.memory.spReg1Uint8Array, consts.SP_STATUS_REG, consts.SP_STATUS_SSTEP);
        }

        if (value & consts.SP_SET_INTR_BREAK) {
            this.setFlag(core.memory.spReg1Uint8Array, consts.SP_STATUS_REG, consts.SP_STATUS_INTR_BREAK);
        } else if (value & consts.SP_CLR_INTR_BREAK) {
            this.clrFlag(core.memory.spReg1Uint8Array, consts.SP_STATUS_REG, consts.SP_STATUS_INTR_BREAK);
        }

        if (value & consts.SP_SET_YIELD) {
            this.setFlag(core.memory.spReg1Uint8Array, consts.SP_STATUS_REG, consts.SP_STATUS_YIELD);
        } else if (value & consts.SP_CLR_YIELD) {
            this.clrFlag(core.memory.spReg1Uint8Array, consts.SP_STATUS_REG, consts.SP_STATUS_YIELD);
        }

        if (value & consts.SP_SET_YIELDED) {
            this.setFlag(core.memory.spReg1Uint8Array, consts.SP_STATUS_REG, consts.SP_STATUS_YIELDED);
        } else if (value & consts.SP_CLR_YIELDED) {
            this.clrFlag(core.memory.spReg1Uint8Array, consts.SP_STATUS_REG, consts.SP_STATUS_YIELDED);
        }

        if (value & consts.SP_SET_TASKDONE) {
            this.setFlag(core.memory.spReg1Uint8Array, consts.SP_STATUS_REG, consts.SP_STATUS_TASKDONE);
        } else if (value & consts.SP_CLR_YIELDED) {
            this.clrFlag(core.memory.spReg1Uint8Array, consts.SP_STATUS_REG, consts.SP_STATUS_YIELDED);
        }

        if (value & consts.SP_SET_SIG3) {
            this.setFlag(core.memory.spReg1Uint8Array, consts.SP_STATUS_REG, consts.SP_STATUS_SIG3);
        } else if (value & consts.SP_CLR_SIG3) {
            this.clrFlag(core.memory.spReg1Uint8Array, consts.SP_STATUS_REG, consts.SP_STATUS_SIG3);
        }

        if (value & consts.SP_SET_SIG4) {
            this.setFlag(core.memory.spReg1Uint8Array, consts.SP_STATUS_REG, consts.SP_STATUS_SIG4);
        } else if (value & consts.SP_CLR_SIG4) {
            this.clrFlag(core.memory.spReg1Uint8Array, consts.SP_STATUS_REG, consts.SP_STATUS_SIG4);
        }

        if (value & consts.SP_SET_SIG5) {
            this.setFlag(core.memory.spReg1Uint8Array, consts.SP_STATUS_REG, consts.SP_STATUS_SIG5);
        } else if (value & consts.SP_CLR_SIG5) {
            this.clrFlag(core.memory.spReg1Uint8Array, consts.SP_STATUS_REG, consts.SP_STATUS_SIG5);
        }

        if (value & consts.SP_SET_SIG6) {
            this.setFlag(core.memory.spReg1Uint8Array, consts.SP_STATUS_REG, consts.SP_STATUS_SIG6);
        } else if (value & consts.SP_CLR_SIG6) {
            this.clrFlag(core.memory.spReg1Uint8Array, consts.SP_STATUS_REG, consts.SP_STATUS_SIG6);
        }

        if (value & consts.SP_SET_SIG7) {
            this.setFlag(core.memory.spReg1Uint8Array, consts.SP_STATUS_REG, consts.SP_STATUS_SIG7);
        } else if (value & consts.SP_CLR_SIG7) {
            this.setFlag(core.memory.spReg1Uint8Array, consts.SP_STATUS_REG, consts.SP_STATUS_SIG7);
        }

        if (value & consts.SP_SET_HALT) {
            this.setFlag(core.memory.spReg1Uint8Array, consts.SP_STATUS_REG, consts.SP_STATUS_HALT);
        } else if (value & consts.SP_CLR_HALT) {
            if ((core.memory.getUint32(core.memory.spReg1Uint8Array, consts.SP_STATUS_REG) & consts.SP_STATUS_BROKE) === 0) { //bugfix.
                this.clrFlag(core.memory.spReg1Uint8Array, consts.SP_STATUS_REG, consts.SP_STATUS_HALT);
                var spDmemTask = core.memory.getUint32(core.memory.spMemUint8Array, consts.SP_DMEM_TASK);
                log("SP Task triggered. SP_DMEM_TASK=" + spDmemTask);
                this.runSPTask(spDmemTask);
            }
        }

        //Added by Rice, 2001.08.10
        //SP_STATUS_REG |= SP_STATUS_HALT;  //why?
        // this.setFlag(spReg1Uint8Array, consts.SP_STATUS_REG, consts.SP_STATUS_HALT); //why?
    };

    this.writeDPCStatusReg = function (value, pc, isFromDelaySlot) {
        if (value & consts.DPC_CLR_XBUS_DMEM_DMA) {
            this.clrFlag(core.memory.dpcUint8Array, consts.DPC_STATUS_REG, consts.DPC_STATUS_XBUS_DMEM_DMA);
        }

        if (value & consts.DPC_SET_XBUS_DMEM_DMA) {
            this.setFlag(core.memory.dpcUint8Array, consts.DPC_STATUS_REG, consts.DPC_STATUS_XBUS_DMEM_DMA);
        }

        if (value & consts.DPC_CLR_FREEZE) {
            this.clrFlag(core.memory.dpcUint8Array, consts.DPC_STATUS_REG, consts.DPC_STATUS_FREEZE);
        }

        if (value & consts.DPC_SET_FREEZE) {
            this.setFlag(core.memory.dpcUint8Array, consts.DPC_STATUS_REG, consts.DPC_STATUS_FREEZE);
        }

        if (value & consts.DPC_CLR_FLUSH) {
            this.clrFlag(core.memory.dpcUint8Array, consts.DPC_STATUS_REG, consts.DPC_STATUS_FLUSH);
        }

        if (value & consts.DPC_SET_FLUSH) {
            this.setFlag(core.memory.dpcUint8Array, consts.DPC_STATUS_REG, consts.DPC_STATUS_FLUSH);
        }

        /*
        if(value & DPC_CLR_TMEM_REG) (DPC_TMEM_REG) = 0;
        if(value & DPC_CLR_PIPEBUSY_REG) (DPC_PIPEBUSY_REG) = 0;
        if(value & DPC_CLR_BUFBUSY_REG) (DPC_BUFBUSY_REG) = 0;
        if(value & DPC_CLR_CLOCK_REG) (DPC_CLOCK_REG) = 0;
        */
    };

    this.writeDPC = function (offset, value, pc, isFromDelaySlot) {
        switch (offset) {
        case consts.DPC_STATUS_REG:
            this.writeDPCStatusReg(value, pc, isFromDelaySlot);
            break;
        case consts.DPC_START_REG:
            core.memory.setInt32(core.memory.dpcUint8Array, offset, value);
            break;
        case consts.DPC_END_REG:
            core.memory.setInt32(core.memory.dpcUint8Array, offset, value);
            this.processRDPList();
            break;
        case consts.DPC_CLOCK_REG:
            break;
        case consts.DPC_BUFBUSY_REG:
            break;
        case consts.DPC_PIPEBUSY_REG:
            break;
        case consts.DPC_TMEM_REG:
            break;
        default:
            core.memory.setInt32(core.memory.dpcUint8Array, offset, value);
            log('unhandled dpc write: ' + offset);
            break;
        }
    };

    this.writePIStatusReg = function (value, pc, isFromDelaySlot) {
        if (value & consts.PI_STATUS_CLR_INTR) {
            this.clearMIInterrupt(consts.MI_INTR_PI);
        }

        if (value & consts.PI_STATUS_RESET) {
            //When PIC is reset, if PIC happens to be busy, an interrupt will be generated
            //as PIC returns to idle. Otherwise, no interrupt will be generated and PIC
            //remains idle.
            if (core.memory.getUint32(core.memory.piUint8Array, consts.PI_STATUS_REG) & (consts.PI_STATUS_IO_BUSY | consts.PI_STATUS_DMA_BUSY)) { //Is PI busy?
                //Reset the PIC
                core.memory.setInt32(core.memory.piUint8Array, consts.PI_STATUS_REG, 0);

                //Reset finished, set PI Interrupt
                this.triggerPIInterrupt(pc, isFromDelaySlot);
            } else {
                //Reset the PIC
                core.memory.setInt32(core.memory.piUint8Array, consts.PI_STATUS_REG, 0);
            }
        }
        //Does not actually write into the PI_STATUS_REG
    };

    this.runSPTask = function (spDmemTask) {
      //  throw 'todo: run hle task';
        switch (spDmemTask) {
        case consts.BAD_TASK:
            log('bad sp task');
            break;
        case consts.GFX_TASK:
            if (core.videoHLE === null || core.videoHLE === undefined) {
                core.videoHLE = new C1964jsVideoHLE(core, core.webGL.gl);
            }
            core.videoHLE.processDisplayList();
            break;
        case consts.SND_TASK:
            this.processAudioList();
            break;
        case consts.JPG_TASK:
            this.processJpegTask();
            break;
        default:
            log('unhandled sp task: ' + spDmemTask);
            break;
        }

        this.checkInterrupts();
        this.triggerRspBreak();
    };

    this.processAudioList = function () {
        log('todo: process Audio List');
        //just clear flags now to get the gfx tasks :)
        //see UpdateFifoFlag in 1964cpp's AudioLLE main.cpp.
        this.clrFlag(core.memory.aiUint8Array, consts.AI_STATUS_REG, consts.AI_STATUS_FIFO_FULL);
    };

    this.processJpegTask = function () {
        log('todo: processJpegTask');
    };

    this.processRDPList = function () {
        log('todo: process rdp list');
    };

    this.checkInterrupts = function () {
        if ((core.memory.getUint32(core.memory.miUint8Array, consts.MI_INTR_REG) & consts.MI_INTR_DP) !== 0) {
            this.triggerDPInterrupt(0, false);
        }

        if ((core.memory.getUint32(core.memory.miUint8Array, consts.MI_INTR_REG) & consts.MI_INTR_AI) !== 0) {
            this.triggerAIInterrupt(0, false);
        }

        if ((core.memory.getUint32(core.memory.miUint8Array, consts.MI_INTR_REG) & consts.MI_INTR_SI) !== 0) {
            this.triggerSIInterrupt(0, false);
        }

        //if ((core.memory.getUint32(miUint8Array, consts.MI_INTR_REG) & consts.MI_INTR_VI) !== 0)
        //    this.triggerVIInterrupt(0, false);

        if ((cp0[consts.CAUSE] & cp0[consts.STATUS] & 0x0000FF00) !== 0) {
            this.setException(consts.EXC_INT, 0, core.programCounter, false);
            //do not process interrupts here as we don't have support for
            //interrupts in delay slots. processs them in the main runLoop.
        }
    };
};