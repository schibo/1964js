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

//1964cpp treats MI_INTR_MASK_REG_R as a separate memory location. Not sure that's right.

function setException(exception, causeFlag, pc, isFromDelaySlot)
{
  //  log('set exception');
    cp0[CAUSE] |= exception;
    cp0[CAUSE] |= causeFlag;
}

function processException(pc, isFromDelaySlot)
{
    if ((cp0[STATUS] & IE)===0)
        return false;

    if ((cp0[STATUS] & EXL) !== 0)
    { 
        log("nested exception");
        return false;
    }
    else
    {
        cp0[CAUSE] &= 0xFFFFFF83; //Clear exception code flags
        cp0[STATUS] |= EXL;

        if(isFromDelaySlot === true)
        {
            log("Exception happens in CPU delay slot, pc=" + pc);
            cp0[CAUSE] |= BD;
            cp0[EPC] = pc - 4;
           // throw 'interrupt';
        }
        else
        {
            cp0[CAUSE] &= ~BD;
            cp0[EPC] = pc;
            //throw 'interrupt';
        }
        
        if (doOnce === 0)
            flushDynaCache();
                
        doOnce = 1;

        programCounter = 0x80000180;
    }
    
    return true;
}

function triggerCompareInterrupt(pc, isFromDelaySlot)
{
	setException(EXC_INT, CAUSE_IP8, pc, isFromDelaySlot);
}

function triggerPIInterrupt(pc, isFromDelaySlot)
{
    setFlag(miUint8Array, MI_INTR_REG, MI_INTR_PI);
    
    var value = miUint8Array[MI_INTR_MASK_REG]<<24 | miUint8Array[MI_INTR_MASK_REG+1]<<16 | miUint8Array[MI_INTR_MASK_REG+2]<<8 | miUint8Array[MI_INTR_MASK_REG+3];
    if ((value & MI_INTR_MASK_PI) !== 0)
        setException(EXC_INT, CAUSE_IP3, pc, isFromDelaySlot);
}

function triggerSPInterrupt(pc, isFromDelaySlot)
{
    setFlag(miUint8Array, MI_INTR_REG, MI_INTR_SP);

    var value = miUint8Array[MI_INTR_MASK_REG]<<24 | miUint8Array[MI_INTR_MASK_REG+1]<<16 | miUint8Array[MI_INTR_MASK_REG+2]<<8 | miUint8Array[MI_INTR_MASK_REG+3];
    if ((value & MI_INTR_MASK_SP) !== 0)
        setException(EXC_INT, CAUSE_IP3, pc, isFromDelaySlot);
}

function triggerVIInterrupt(pc, isFromDelaySlot)
{
    setFlag(miUint8Array, MI_INTR_REG, MI_INTR_VI);

    var value = miUint8Array[MI_INTR_MASK_REG]<<24 | miUint8Array[MI_INTR_MASK_REG+1]<<16 | miUint8Array[MI_INTR_MASK_REG+2]<<8 | miUint8Array[MI_INTR_MASK_REG+3];
    if ((value & MI_INTR_MASK_VI) !== 0)
        setException(EXC_INT, CAUSE_IP3, pc, isFromDelaySlot);
}

function triggerSIInterrupt(pc, isFromDelaySlot)
{
    //setFlag(siUint8Array, SI_STATUS_REG, SI_STATUS_INTERRUPT);
    
    setFlag(miUint8Array, MI_INTR_REG, MI_INTR_SI);

    var value = miUint8Array[MI_INTR_MASK_REG]<<24 | miUint8Array[MI_INTR_MASK_REG+1]<<16 | miUint8Array[MI_INTR_MASK_REG+2]<<8 | miUint8Array[MI_INTR_MASK_REG+3];
    if ((value & MI_INTR_MASK_SI) !== 0)
        setException(EXC_INT, CAUSE_IP3, pc, isFromDelaySlot);
}

function triggerAIInterrupt(pc, isFromDelaySlot)
{
    setFlag(miUint8Array, MI_INTR_REG, MI_INTR_AI);

    var value = miUint8Array[MI_INTR_MASK_REG]<<24 | miUint8Array[MI_INTR_MASK_REG+1]<<16 | miUint8Array[MI_INTR_MASK_REG+2]<<8 | miUint8Array[MI_INTR_MASK_REG+3];
    if ((value & MI_INTR_MASK_AI) !== 0)
        setException(EXC_INT, CAUSE_IP3, pc, isFromDelaySlot);
}

function triggerDPInterrupt(pc, isFromDelaySlot)
{
    setFlag(miUint8Array, MI_INTR_REG, MI_INTR_DP);

    var value = miUint8Array[MI_INTR_MASK_REG]<<24 | miUint8Array[MI_INTR_MASK_REG+1]<<16 | miUint8Array[MI_INTR_MASK_REG+2]<<8 | miUint8Array[MI_INTR_MASK_REG+3];
    if ((value & MI_INTR_MASK_DP) !== 0)
        setException(EXC_INT, CAUSE_IP3, pc, isFromDelaySlot);
}

function triggerRspBreak()
{
    setFlag(spReg1Uint8Array, SP_STATUS_REG, SP_STATUS_TASKDONE |SP_STATUS_BROKE | SP_STATUS_HALT);

    var value = spReg1Uint8Array[SP_STATUS_REG]<<24 | spReg1Uint8Array[SP_STATUS_REG+1]<<16 | spReg1Uint8Array[SP_STATUS_REG+2]<<8 | spReg1Uint8Array[SP_STATUS_REG+3];
    if ((value & SP_STATUS_INTR_BREAK) !== 0)
        triggerSPInterrupt(0, false);
}

function clearMIInterrupt(flag)
{
	clrFlag(miUint8Array, MI_INTR_REG, flag);

    var value = miUint8Array[MI_INTR_MASK_REG]<<24 | miUint8Array[MI_INTR_MASK_REG+1]<<16 | miUint8Array[MI_INTR_MASK_REG+2]<<8 | miUint8Array[MI_INTR_MASK_REG+3];
    if ((value & (getUint32(miUint8Array, MI_INTR_REG))) === 0)
	{
		cp0[CAUSE] &= ~CAUSE_IP3;
		//if((cp0[CAUSE] & cp0[STATUS] & SR_IMASK) == 0)
        //    CPUNeedToCheckInterrupt = FALSE;
	}
}

var currentHack = 0;
function readVI(offset)
{
    switch (offset)
    {
        case VI_CURRENT_REG:
            //hack for berney demo
            if (currentHack++ === 625)
            {
                currentHack = 0;
              //  triggerVIInterrupt(pc, isFromDelaySlot);
                //warning: need to refactor. triggerVIInterrupt
                //can service an interrupt immediately without setting rt[i]
            }
            //return currentHack;
            return ((getInt32(viUint8Array, viUint8Array, offset) & 0xfffffffe) + currentHack)|0;
        break;
        default:
            log('unhandled video interface for vi offset: ' + offset);
            return getInt32(viUint8Array, viUint8Array, offset);
        break;
    }
}

function writeVI(offset, value, pc, isFromDelaySlot)
{
    switch (offset)
    {
        case VI_ORIGIN_REG:
            setInt32(viUint8Array, offset, value);
           // var c = document.getElementById("Canvas");
           // var ctx = c.getContext("2d");
           // repaint(ctx,ImDat,value & 0x00FFFFFF);
           //alert('origin changed' + dec2hex(value));
        break;
        case VI_CURRENT_REG:
            clearMIInterrupt(MI_INTR_VI);
            setInt32(viUint8Array, offset, value);
        break;
        case VI_INTR_REG:
            setInt32(viUint8Array, offset, value);
        break;
        default:
            setInt32(viUint8Array, offset, value);
            //log('unhandled vi write: ' + offset);
        break;
    }
}

function writePI(offset, value, pc, isFromDelaySlot)
{
    switch (offset)
    {
        case PI_WR_LEN_REG:
            setInt32(piUint8Array, offset, value);
            copyCartToDram(pc, isFromDelaySlot);
        break;
        case PI_RD_LEN_REG:
            setInt32(piUint8Array, offset, value);
            alert('write to PI_RD_LEN_REG');
            copyDramToCart(pc, isFromDelaySlot);
        break;
        case PI_DRAM_ADDR_REG:
            setInt32(piUint8Array, offset, value);
        break;
        case PI_CART_ADDR_REG:
            setInt32(piUint8Array, offset, value);
        break;
        case PI_STATUS_REG:
            writePIStatusReg(value, pc, isFromDelaySlot);
        break;
        default:
            setInt32(piUint8Array, offset, value);
            log('unhandled pi write: ' + offset);
        break;
    }
}

function writeSI(offset, value, pc, isFromDelaySlot)
{
    switch (offset)
    {
        case SI_DRAM_ADDR_REG:
            setInt32(siUint8Array, offset, value);
        break;
        case SI_STATUS_REG:
            writeSIStatusReg(value, pc, isFromDelaySlot);
        break;
        case 4: //unknown
            setInt32(siUint8Array, offset, value);
        break;
        case SI_PIF_ADDR_RD64B_REG:
            setInt32(siUint8Array, offset, value);
            copySiToDram(pc, isFromDelaySlot);
        break;
        case SI_PIF_ADDR_WR64B_REG:
            setInt32(siUint8Array, offset, value);
            copyDramToSi(pc, isFromDelaySlot);
        break;
        default:
            setInt32(siUint8Array, offset, value);
            log('unhandled si write: ' + offset);
        break;
    }
}

function readSI(offset)
{
    switch (offset)
    {
        case SI_STATUS_REG:
            readSIStatusReg();
            return getInt32(siUint8Array, siUint8Array, offset);
        break;
        default:
            log('unhandled si read: ' + offset);
            return getInt32(siUint8Array, siUint8Array, offset);
        break;
    }
}

function readSIStatusReg()
{
    if ((getUint32(miUint8Array, MI_INTR_REG) & MI_INTR_SI) !== 0)
        setFlag(siUint8Array, SI_STATUS_REG, SI_STATUS_INTERRUPT);
    else
        clrFlag(siUint8Array, SI_STATUS_REG, SI_STATUS_INTERRUPT);
}

function readAI(offset)
{
    switch (offset)
    {
        case AI_LEN_REG:
            //todo: implement AI_LEN_REG -- how many bytes unconsumed..
            if (--kfi===0)
            {
                kfi=512;
                setFlag(aiUint8Array, AI_STATUS_REG, AI_STATUS_FIFO_FULL);
                triggerAIInterrupt(0, false);
                //checkInterrupts();
                return 0;
                
            }
            return 0;
            return kfi;   
        
            return getInt32(aiUint8Array, aiUint8Array, offset);
        break;
        case AI_STATUS_REG:
            return getInt32(aiUint8Array, aiUint8Array, offset);
        break;
        default:
            log('unhandled read ai reg ' + offset);
            return getInt32(aiUint8Array, aiUint8Array, offset);
        break;
    }
}

function writeAI(offset, value, pc, isFromDelaySlot)
{
    switch (offset)
    {
        case AI_DRAM_ADDR_REG:
            setInt32(aiUint8Array, offset, value);
        break;
        case AI_LEN_REG:
            setInt32(aiUint8Array, offset, value);
            copyDramToAi(pc, isFromDelaySlot);
        break;
        case AI_STATUS_REG:
            clearMIInterrupt(MI_INTR_AI);
        break;
        case AI_DACRATE_REG:
           // log("todo: write AI_DACRATE_REG");
            setInt32(aiUint8Array, offset, value);
        break;
        case AI_CONTROL_REG:
            setInt32(aiUint8Array, offset, value&1);
        break;
        default:
            //log('unhandled write ai reg ' + offset);
            setInt32(aiUint8Array, offset, value);
        return;
        break;
    }
}

function writeMI(offset, value, pc, isFromDelaySlot)
{
    switch (offset)
    {
        case MI_INIT_MODE_REG:
            writeMIModeReg(value);
        break;
        case MI_INTR_MASK_REG:
            writeMIIntrMaskReg(value, pc, isFromDelaySlot);
        break;
        case MI_VERSION_REG:
        case MI_INTR_REG:
            //do nothing. read-only
        break;
        default:
            setInt32(miUint8Array, offset, value);
            log('unhandled mips interface for mi offset: ' + offset);
        break;
    }
}

function readSPReg1(offset)
{
    switch (offset)
    {
        case SP_STATUS_REG:
            return getInt32(spReg1Uint8Array, spReg1Uint8Array, offset);
        break;
        case SP_SEMAPHORE_REG:
            var temp = getInt32(aiUint8Array, aiUint8Array, offset);
            setInt32(spReg1Uint8Array, offset, 1);
            return temp;
        break;
        default:
            log('unhandled read sp reg1 ' + offset);
            return getInt32(spReg1Uint8Array, spReg1Uint8Array, offset);
        break;
    }
}

function writeSPReg1(offset, value, pc, isFromDelaySlot)
{
    switch (offset)
    {
        case SP_STATUS_REG:
            writeSPStatusReg(value, pc, isFromDelaySlot);
        break;
        case SP_SEMAPHORE_REG:
            setInt32(spReg1Uint8Array, offset, 0);
        break;
        case SP_WR_LEN_REG:
            setInt32(spReg1Uint8Array, offset, value);
            copySpToDram(pc, isDelaySlot);
        break;
        case SP_RD_LEN_REG:
            setInt32(spReg1Uint8Array, offset, value);
            copyDramToSp(pc, isFromDelaySlot);
        break;
        default:
            setInt32(spReg1Uint8Array, offset, value);
            log('unhandled sp reg1 write: ' + offset);        
        break;
    }
}

function writeSPReg2(offset, value, pc, isFromDelaySlot)
{
    switch (offset)
    {
        case SP_PC_REG:
            log('writing sp pc: ' + value);
            setInt32(spReg2Uint8Array, offset, value & 0x00000FFC);
        break;
        default:
            setInt32(spReg2Uint8Array, offset, value);
            log('unhandled sp reg2 write: ' + offset);        
        break;
    }
}

//Set flag for memory register
function setFlag(where, offset, flag) {
    var value = getUint32(where, offset);
    value |= flag;
    setInt32(where, offset, value);
}

//Clear flag for memory register
function clrFlag(where, offset, flag) {
    var value = getUint32(where, offset);
    value &= ~flag;
    setInt32(where, offset, value);
}

function writeMIModeReg(value) {
	if (value & MI_SET_RDRAM) setFlag(miUint8Array, MI_INIT_MODE_REG, MI_MODE_RDRAM);
	else if (value & MI_CLR_RDRAM) clrFlag(miUint8Array, MI_INIT_MODE_REG, MI_MODE_RDRAM);

	if (value & MI_SET_INIT) setFlag(miUint8Array, MI_INIT_MODE_REG, MI_MODE_INIT);
    else if (value & MI_CLR_INIT) clrFlag(miUint8Array, MI_INIT_MODE_REG, MI_MODE_INIT);

	if (value & MI_SET_EBUS) setFlag(miUint8Array, MI_INIT_MODE_REG,MI_MODE_EBUS);
    else if (value & MI_CLR_EBUS) clrFlag(miUint8Array, MI_INIT_MODE_REG, MI_MODE_EBUS);

	if(value & MI_CLR_DP_INTR)
    { 
        //clrFlag(miUint8Array, MI_INTR_REG, MI_INTR_DP);
        //setInt32(miUint8Array, MI_INIT_MODE_REG, getUint32(miUint8Array, MI_INIT_MODE_REG)|(value&0x7f)); 
        clearMIInterrupt(MI_INTR_DP);
    }
}

function writeMIIntrMaskReg(value, pc, isFromDelaySlot) {
    if (value & MI_INTR_MASK_SP_SET) setFlag(miUint8Array, MI_INTR_MASK_REG, MI_INTR_SP);
	else if (value & MI_INTR_MASK_SP_CLR) clrFlag(miUint8Array, MI_INTR_MASK_REG, MI_INTR_SP);

    if (value & MI_INTR_MASK_SI_SET) setFlag(miUint8Array, MI_INTR_MASK_REG, MI_INTR_SI);
	else if (value & MI_INTR_MASK_SI_CLR) clrFlag(miUint8Array, MI_INTR_MASK_REG, MI_INTR_SI);

	if (value & MI_INTR_MASK_AI_SET) setFlag(miUint8Array, MI_INTR_MASK_REG, MI_INTR_AI);
    else if(value & MI_INTR_MASK_AI_CLR) clrFlag(miUint8Array, MI_INTR_MASK_REG, MI_INTR_AI);

	if (value & MI_INTR_MASK_VI_SET) setFlag(miUint8Array, MI_INTR_MASK_REG, MI_INTR_VI);
    else if (value & MI_INTR_MASK_VI_CLR) clrFlag(miUint8Array, MI_INTR_MASK_REG, MI_INTR_VI);

	if (value & MI_INTR_MASK_PI_SET) setFlag(miUint8Array, MI_INTR_MASK_REG, MI_INTR_PI);
    else if (value & MI_INTR_MASK_PI_CLR) clrFlag(miUint8Array, MI_INTR_MASK_REG, MI_INTR_PI);

	if (value & MI_INTR_MASK_DP_SET) setFlag(miUint8Array, MI_INTR_MASK_REG, MI_INTR_DP);
    else if (value & MI_INTR_MASK_DP_CLR) clrFlag(miUint8Array, MI_INTR_MASK_REG, MI_INTR_DP);

	//Check MI interrupt again. This is important, otherwise we will lose interrupts.
	if ((getUint32(miUint8Array, MI_INTR_MASK_REG) & 0x0000003F & getUint32(miUint8Array, MI_INTR_REG)) !== 0) {
		//Trigger an MI interrupt since we don't know what it is.
		setException(EXC_INT, CAUSE_IP3, pc, isFromDelaySlot);
	}
}

function writeSIStatusReg(value, pc, isFromDelaySlot)
{
    //Clear SI interrupt unconditionally
    //clearMIInterrupt(MI_INTR_SI); //wrong!
    clrFlag(siUint8Array, SI_STATUS_REG, SI_STATUS_INTERRUPT);
}

function writeSPStatusReg(value, pc, isFromDelaySlot) {
    if(value & SP_CLR_BROKE)
        clrFlag(spReg1Uint8Array, SP_STATUS_REG, SP_STATUS_BROKE);

    if(value & SP_SET_INTR)
        triggerSPInterrupt(pc, isFromDelaySlot);
    //to use else if here is a possible bux fix (what is this?..this looks weird)
    else if(value & SP_CLR_INTR)
        clearMIInterrupt(MI_INTR_SP);

    if (value & SP_SET_SSTEP) setFlag(spReg1Uint8Array, SP_STATUS_REG, SP_STATUS_SSTEP);
    else if (value & SP_CLR_SSTEP) clrFlag(spReg1Uint8Array, SP_STATUS_REG, SP_STATUS_SSTEP);

	if (value & SP_SET_INTR_BREAK) setFlag(spReg1Uint8Array, SP_STATUS_REG, SP_STATUS_INTR_BREAK);
	else if (value & SP_CLR_INTR_BREAK) clrFlag(spReg1Uint8Array, SP_STATUS_REG, SP_STATUS_INTR_BREAK);

	if (value & SP_SET_YIELD) setFlag(spReg1Uint8Array, SP_STATUS_REG, SP_STATUS_YIELD);
    else if (value & SP_CLR_YIELD) clrFlag(spReg1Uint8Array, SP_STATUS_REG, SP_STATUS_YIELD);
	
	if (value & SP_SET_YIELDED) setFlag(spReg1Uint8Array, SP_STATUS_REG, SP_STATUS_YIELDED);
    else if(value & SP_CLR_YIELDED) clrFlag(spReg1Uint8Array, SP_STATUS_REG, SP_STATUS_YIELDED);
	
	if (value & SP_SET_TASKDONE) setFlag(spReg1Uint8Array, SP_STATUS_REG, SP_STATUS_TASKDONE);
    else if(value & SP_CLR_YIELDED) clrFlag(spReg1Uint8Array, SP_STATUS_REG, SP_STATUS_YIELDED);
	
	if (value & SP_SET_SIG3) setFlag(spReg1Uint8Array, SP_STATUS_REG, SP_STATUS_SIG3);
    else if (value & SP_CLR_SIG3) clrFlag(spReg1Uint8Array, SP_STATUS_REG, SP_STATUS_SIG3);
	
	if (value & SP_SET_SIG4) setFlag(spReg1Uint8Array, SP_STATUS_REG, SP_STATUS_SIG4);
    else if(value & SP_CLR_SIG4) clrFlag(spReg1Uint8Array, SP_STATUS_REG, SP_STATUS_SIG4);
	
	if (value & SP_SET_SIG5) setFlag(spReg1Uint8Array, SP_STATUS_REG, SP_STATUS_SIG5);
    else if(value & SP_CLR_SIG5) clrFlag(spReg1Uint8Array, SP_STATUS_REG, SP_STATUS_SIG5);
	
	if (value & SP_SET_SIG6) setFlag(spReg1Uint8Array, SP_STATUS_REG, SP_STATUS_SIG6);
    else if(value & SP_CLR_SIG6) clrFlag(spReg1Uint8Array, SP_STATUS_REG, SP_STATUS_SIG6);

	if (value & SP_SET_SIG7) setFlag(spReg1Uint8Array, SP_STATUS_REG, SP_STATUS_SIG7);
    else if (value & SP_CLR_SIG7) setFlag(spReg1Uint8Array, SP_STATUS_REG, SP_STATUS_SIG7);

	if (value & SP_SET_HALT) setFlag(spReg1Uint8Array, SP_STATUS_REG, SP_STATUS_HALT);
    else if(value & SP_CLR_HALT) {
		if ((getUint32(spReg1Uint8Array, SP_STATUS_REG) & SP_STATUS_BROKE) === 0) { //bugfix.
			clrFlag(spReg1Uint8Array, SP_STATUS_REG, SP_STATUS_HALT);
			var spDmemTask = getUint32(spMemUint8Array, SP_DMEM_TASK);
			log("SP Task triggered. SP_DMEM_TASK=" + spDmemTask);
			runSPTask(spDmemTask);
		}
    }

	//Added by Rice, 2001.08.10
	//SP_STATUS_REG |= SP_STATUS_HALT;  //why?
   // setFlag(spReg1Uint8Array, SP_STATUS_REG, SP_STATUS_HALT); //why?
}

function writeDPCStatusReg(value, pc, isFromDelaySlot)
{
    if (value & DPC_CLR_XBUS_DMEM_DMA) clrFlag(dpcUint8Array, DPC_STATUS_REG, DPC_STATUS_XBUS_DMEM_DMA);
    if (value & DPC_SET_XBUS_DMEM_DMA) setFlag(dpcUint8Array, DPC_STATUS_REG, DPC_STATUS_XBUS_DMEM_DMA);

	if (value & DPC_CLR_FREEZE) clrFlag(dpcUint8Array, DPC_STATUS_REG, DPC_STATUS_FREEZE);
	if (value & DPC_SET_FREEZE) setFlag(dpcUint8Array, DPC_STATUS_REG, DPC_STATUS_FREEZE);

	if (value & DPC_CLR_FLUSH) clrFlag(dpcUint8Array, DPC_STATUS_REG, DPC_STATUS_FLUSH);
	if (value & DPC_SET_FLUSH) setFlag(dpcUint8Array, DPC_STATUS_REG, DPC_STATUS_FLUSH);
	
	/*
    if(value & DPC_CLR_TMEM_REG) (DPC_TMEM_REG) = 0;
	if(value & DPC_CLR_PIPEBUSY_REG) (DPC_PIPEBUSY_REG) = 0;
	if(value & DPC_CLR_BUFBUSY_REG) (DPC_BUFBUSY_REG) = 0;
	if(value & DPC_CLR_CLOCK_REG) (DPC_CLOCK_REG) = 0;
	*/
}

function writeDPC(offset, value, pc, isFromDelaySlot)
{
    switch (offset)
    {
        case DPC_STATUS_REG:
            writeDPCStatusReg(value, pc, isFromDelaySlot);
        break;
        case DPC_START_REG:
            setInt32(dpcUint8Array, offset, value);
        break;
        case DPC_END_REG:
            setInt32(dpcUint8Array, offset, value);
            processRDPList();
        break;
        case DPC_CLOCK_REG:
        case DPC_BUFBUSY_REG:
        case DPC_PIPEBUSY_REG:
        case DPC_TMEM_REG:
        break;
        default:
            setInt32(dpcUint8Array, offset, value);
            log('unhandled dpc write: ' + offset);        
        break;
    }
}

function writePIStatusReg(value, pc, isFromDelaySlot)
{
    if (value & PI_STATUS_CLR_INTR)
        clearMIInterrupt(MI_INTR_PI);

    if (value & PI_STATUS_RESET)
    {
        //When PIC is reset, if PIC happens to be busy, an interrupt will be generated
        //as PIC returns to idle. Otherwise, no interrupt will be generated and PIC
        //remains idle.
        if (getUint32(piUint8Array, PI_STATUS_REG) & (PI_STATUS_IO_BUSY|PI_STATUS_DMA_BUSY)) //Is PI busy?
        {
            //Reset the PIC
            setInt32(piUint8Array, PI_STATUS_REG, 0);

            //Reset finished, set PI Interrupt
            triggerPIInterrupt(pc, isFromDelaySlot);
        }
        else
        {
            //Reset the PIC
            setInt32(piUint8Array, PI_STATUS_REG, 0);
        }
    }
    //Does not actually write into the PI_STATUS_REG
}

function runSPTask(spDmemTask)
{
  //  throw 'todo: run hle task';
    switch(spDmemTask)
    {
    case BAD_TASK:
        log('bad sp task');
    break;
    case GFX_TASK:
        processDisplayList();
    break;
    case SND_TASK:
        processAudioList();
    break;
    case JPG_TASK:
        processJpegTask();
    break;
    default:
        log('unhandled sp task: ' + spDmemTask);
    break;
    }

    checkInterrupts();
    triggerRspBreak();
}

function processAudioList()
{
    log('todo: process Audio List');
    //just clear flags now to get the gfx tasks :)
    //see UpdateFifoFlag in 1964cpp's AudioLLE main.cpp.
    clrFlag(aiUint8Array, AI_STATUS_REG, AI_STATUS_FIFO_FULL);
}

function processRDPList()
{
    log('todo: process rdp list');
}

function checkInterrupts()
{    
    if ((getUint32(miUint8Array, MI_INTR_REG) & MI_INTR_DP) !== 0)
        triggerDPInterrupt(0, false);

    if ((getUint32(miUint8Array, MI_INTR_REG) & MI_INTR_AI) !== 0)
        triggerAIInterrupt(0, false);

    if ((getUint32(miUint8Array, MI_INTR_REG) & MI_INTR_SI) !== 0)
        triggerSIInterrupt(0, false);

    //if ((getUint32(miUint8Array, MI_INTR_REG) & MI_INTR_VI) !== 0)
    //    triggerVIInterrupt(0, false);
        
    if((cp0[CAUSE] & cp0[STATUS] & 0x0000FF00) !== 0) {
        setException(EXC_INT, 0, programCounter, false);
        //do not process interrupts here as we don't have support for
        //interrupts in delay slots. processs them in the main runLoop.
    }
}

