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

/*jslint bitwise: true*/

var C1964jsConstants = function () {
    "use strict";

    //mem map
    this.MEMORY_START_RDRAM = 0x00000000;
    this.MEMORY_START_RAMREGS0 = 0x03F00000;
    this.MEMORY_START_RAMREGS4 = 0x03F04000;
    this.MEMORY_START_RAMREGS8 = 0x03F80000;
    this.MEMORY_START_SPMEM = 0x04000000;
    this.MEMORY_START_SPREG_1 = 0x04040000;
    this.MEMORY_START_SPREG_2 = 0x04080000;
    this.MEMORY_START_DPC = 0x04100000;
    this.MEMORY_START_DPS = 0x04200000;
    this.MEMORY_START_MI = 0x04300000;
    this.MEMORY_START_VI = 0x04400000;
    this.MEMORY_START_AI = 0x04500000;
    this.MEMORY_START_PI = 0x04600000;
    this.MEMORY_START_RI = 0x04700000;
    this.MEMORY_START_SI = 0x04800000;
    this.MEMORY_START_C2A1 = 0x05000000;
    this.MEMORY_START_C1A1 = 0x06000000;
    this.MEMORY_START_C2A2 = 0x08000000;
    this.MEMORY_START_ROM_IMAGE = 0x10000000;
    this.MEMORY_START_GIO = 0x18000000;
    this.MEMORY_START_PIF = 0x1FC00000;
    this.MEMORY_START_PIF_RAM = 0x1FC007C0;
    this.MEMORY_START_C1A3 = 0x1FD00000;
    this.MEMORY_START_DUMMY = 0x1FFF0000;

    this.MEMORY_SIZE_RDRAM = 0x800000; //4MB RDRAM + 4MB Expansion = 8MB
    this.MEMORY_SIZE_RAMREGS0 = 0x10000;
    this.MEMORY_SIZE_RAMREGS4 = 0x10000;
    this.MEMORY_SIZE_RAMREGS8 = 0x10000;
    this.MEMORY_SIZE_SPMEM = 0x2000;
    this.MEMORY_SIZE_SPREG_1 = 0x10000;
    this.MEMORY_SIZE_SPREG_2 = 0x10000;
    this.MEMORY_SIZE_DPC = 0x10000;
    this.MEMORY_SIZE_DPS = 0x10000;
    this.MEMORY_SIZE_MI = 0x10000;
    this.MEMORY_SIZE_VI = 0x10000;
    this.MEMORY_SIZE_AI = 0x10000;
    this.MEMORY_SIZE_PI = 0x10000;
    this.MEMORY_SIZE_RI = 0x10000;
    this.MEMORY_SIZE_SI = 0x10000;
    this.MEMORY_SIZE_C2A1 = 0x8000;
    this.MEMORY_SIZE_C1A1 = 0x8000;
    this.MEMORY_SIZE_C2A2 = 0x20000;
    this.MEMORY_SIZE_GIO_REG = 0x10000;
    this.MEMORY_SIZE_C1A3 = 0x8000;
    this.MEMORY_SIZE_PIF = 0x10000;
    this.MEMORY_SIZE_DUMMY = 0x10000;

    //cp0
    this.INDEX = 0;
    this.RANDOM = 1;
    this.ENTRYLO0 = 2;
    this.ENTRYLO1 = 3;
    this.CONTEXT = 4;
    this.PAGEMASK = 5;
    this.WIRED = 6;
    this.RESERVED0 = 7;
    this.BADVADDR = 8;
    this.COUNT = 9;
    this.ENTRYHI = 10;
    this.COMPARE = 11;
    this.STATUS = 12;
    this.CAUSE = 13;
    this.EPC = 14;
    this.PREVID = 15;
    this.CONFIG = 16;
    this.LLADDR = 17;
    this.WATCHLO = 18;
    this.WATCHHI = 19;
    this.XCONTEXT = 20;
    this.RESERVED1 = 21;
    this.RESERVED2 = 22;
    this.RESERVED3 = 23;
    this.RESERVED4 = 24;
    this.RESERVED5 = 25;
    this.PERR = 26;
    this.CACHEERR = 27;
    this.TAGLO = 28;
    this.TAGHI = 29;
    this.ERROREPC = 30;
    this.RESERVED6 = 31;

    //sp_dmem
    this.SP_DMEM_TASK = 0x00000FC0;

    //sp_reg_1
    this.SP_MEM_ADDR_REG = 0;
    this.SP_DRAM_ADDR_REG = 4;
    this.SP_RD_LEN_REG = 8;
    this.SP_WR_LEN_REG = 12;
    this.SP_STATUS_REG = 16;
    this.SP_DMA_FULL_REG = 20;
    this.SP_DMA_BUSY_REG = 24;
    this.SP_SEMAPHORE_REG = 28;

    //sp_reg_2
    this.SP_PC_REG = 0;
    this.SP_IBIST_REG = 4;

    //vi
    this.VI_STATUS_REG = 0;
    this.VI_ORIGIN_REG = 4;
    this.VI_WIDTH_REG = 8;
    this.VI_INTR_REG = 12;
    this.VI_CURRENT_REG = 16;
    this.VI_BURST_REG = 20;
    this.VI_V_SYNC_REG = 24;
    this.VI_H_SYNC_REG = 28;
    this.VI_LEAP_REG = 32;
    this.VI_H_START_REG = 36;
    this.VI_V_START_REG = 40;
    this.VI_V_BURST_REG = 44;
    this.VI_X_SCALE_REG = 48;
    this.VI_Y_SCALE_REG = 52;

    //ai
    this.AI_DRAM_ADDR_REG = 0;
    this.AI_LEN_REG = 4;
    this.AI_CONTROL_REG = 8;
    this.AI_STATUS_REG = 12;
    this.AI_DACRATE_REG = 16;
    this.AI_BITRATE_REG = 20;

    //pi
    this.PI_DRAM_ADDR_REG = 0;
    this.PI_CART_ADDR_REG = 4;
    this.PI_RD_LEN_REG = 8;
    this.PI_WR_LEN_REG = 12;
    this.PI_STATUS_REG = 16;
    this.PI_BSD_DOM1_LAT_REG = 20;
    this.PI_BSD_DOM1_PWD_REG = 24;
    this.PI_BSD_DOM1_PGS_REG = 28;
    this.PI_BSD_DOM1_RLS_REG = 32;
    this.PI_BSD_DOM2_LAT_REG = 36;
    this.PI_BSD_DOM2_PWD_REG = 40;
    this.PI_BSD_DOM2_PGS_REG = 44;
    this.PI_BSD_DOM2_RLS_REG = 48;

    //ri
    this.RI_MODE_REG = 0;
    this.RI_CONFIG_REG = 4;
    this.RI_CURRENT_LOAD_REG = 8;
    this.RI_SELECT_REG = 12;
    this.RI_REFRESH_REG = 16;
    this.RI_LATENCY_REG = 20;
    this.RI_RERROR_REG = 24;
    this.RI_WERROR_REG = 28;

    //mi
    this.MI_INIT_MODE_REG = 0;
    this.MI_VERSION_REG = 4;
    this.MI_INTR_REG = 8;
    this.MI_INTR_MASK_REG = 12;

    //si
    this.SI_DRAM_ADDR_REG = 0;
    this.SI_PIF_ADDR_RD64B_REG = 4;
    this.SI_PIF_ADDR_WR64B_REG = 16;
    this.SI_STATUS_REG = 24;

    //flags
    this.SI_STATUS_DMA_BUSY = 0x0001;
    this.SI_STATUS_RD_BUSY = 0x0002;
    this.SI_STATUS_DMA_ERROR = 0x0008;
    this.SI_STATUS_INTERRUPT = 0x1000;
    this.AI_STATUS_FIFO_FULL = 0x80000000;
    this.AI_STATUS_DMA_BUSY = 0x40000000;
    this.PI_STATUS_RESET = 0x01;
    this.PI_STATUS_CLR_INTR = 0x02;
    this.PI_STATUS_ERROR = 0x04;
    this.PI_STATUS_IO_BUSY = 0x02;
    this.PI_STATUS_DMA_BUSY = 0x01;

    this.MI_INTR_SP = 0x00000001;
    this.MI_INTR_SI = 0x00000002;
    this.MI_INTR_AI = 0x00000004;
    this.MI_INTR_VI = 0x00000008;
    this.MI_INTR_PI = 0x00000010;
    this.MI_INTR_DP = 0x00000020;
    this.MI_INTR_MASK_SP = 0x01; //Bit 0: SP intr mask
    this.MI_INTR_MASK_SI = 0x02; //Bit 1: SI intr mask
    this.MI_INTR_MASK_AI = 0x04; //Bit 2: AI intr mask
    this.MI_INTR_MASK_VI = 0x08; //Bit 3: VI intr mask
    this.MI_INTR_MASK_PI = 0x10; //Bit 4: PI intr mask
    this.MI_INTR_MASK_DP = 0x20; //Bit 5: DP intr mask
    this.MI_INTR_MASK_SP_CLR = 0x01;
    this.MI_INTR_MASK_SP_SET = 0x02;
    this.MI_INTR_MASK_SI_CLR = 0x04;
    this.MI_INTR_MASK_SI_SET = 0x08;
    this.MI_INTR_MASK_AI_CLR = 0x10;
    this.MI_INTR_MASK_AI_SET = 0x20;
    this.MI_INTR_MASK_VI_CLR = 0x40;
    this.MI_INTR_MASK_VI_SET = 0x80;
    this.MI_INTR_MASK_PI_CLR = 0x100;
    this.MI_INTR_MASK_PI_SET = 0x200;
    this.MI_INTR_MASK_DP_CLR = 0x400;
    this.MI_INTR_MASK_DP_SET = 0x800;

    //MI mode register read flags
    this.MI_MODE_INIT = 0x0080;
    this.MI_MODE_EBUS = 0x0100;
    this.MI_MODE_RDRAM = 0x0200;

    //MI mode register write flags
    this.MI_CLR_INIT = 0x0080;
    this.MI_SET_INIT = 0x0100;
    this.MI_CLR_EBUS = 0x0200;
    this.MI_SET_EBUS = 0x0400;
    this.MI_CLR_DP_INTR = 0x0800;
    this.MI_CLR_RDRAM = 0x1000;
    this.MI_SET_RDRAM = 0x2000;

    //DPC registers
    this.DPC_START_REG = 0;
    this.DPC_END_REG = 4;
    this.DPC_CURRENT_REG = 8;
    this.DPC_STATUS_REG = 12;
    this.DPC_CLOCK_REG = 16;
    this.DPC_BUFBUSY_REG = 20;
    this.DPC_PIPEBUSY_REG = 24;
    this.DPC_TMEM_REG = 28;

    //SP_STATUS_REG read flags
    this.SP_STATUS_HALT = 0x0001;
    this.SP_STATUS_BROKE = 0x0002;
    this.SP_STATUS_DMA_BUSY = 0x0004;
    this.SP_STATUS_DMA_FULL = 0x0008;
    this.SP_STATUS_IO_FULL = 0x0010;
    this.SP_STATUS_SSTEP = 0x0020;
    this.SP_STATUS_INTR_BREAK = 0x0040;
    this.SP_STATUS_YIELD = 0x0080;
    this.SP_STATUS_YIELDED = 0x0100;
    this.SP_STATUS_TASKDONE = 0x0200;
    this.SP_STATUS_SIG3 = 0x0400;
    this.SP_STATUS_SIG4 = 0x0800;
    this.SP_STATUS_SIG5 = 0x1000;
    this.SP_STATUS_SIG6 = 0x2000;
    this.SP_STATUS_SIG7 = 0x4000;

    //SP_STATUS_REG write flags
    this.SP_CLR_HALT = 0x0000001;
    this.SP_SET_HALT = 0x0000002;
    this.SP_CLR_BROKE = 0x0000004;
    this.SP_CLR_INTR = 0x0000008;
    this.SP_SET_INTR = 0x0000010;
    this.SP_CLR_SSTEP = 0x0000020;
    this.SP_SET_SSTEP = 0x0000040;
    this.SP_CLR_INTR_BREAK = 0x0000080;
    this.SP_SET_INTR_BREAK = 0x0000100;
    this.SP_CLR_YIELD = 0x0000200;
    this.SP_SET_YIELD = 0x0000400;
    this.SP_CLR_YIELDED = 0x0000800;
    this.SP_SET_YIELDED = 0x0001000;
    this.SP_CLR_TASKDONE = 0x0002000;
    this.SP_SET_TASKDONE = 0x0004000;
    this.SP_CLR_SIG3 = 0x0008000;
    this.SP_SET_SIG3 = 0x0010000;
    this.SP_CLR_SIG4 = 0x0020000;
    this.SP_SET_SIG4 = 0x0040000;
    this.SP_CLR_SIG5 = 0x0080000;
    this.SP_SET_SIG5 = 0x0100000;
    this.SP_CLR_SIG6 = 0x0200000;
    this.SP_SET_SIG6 = 0x0400000;
    this.SP_CLR_SIG7 = 0x0800000;
    this.SP_SET_SIG7 = 0x1000000;

    //DPC_STATUS_REG read flags
    this.DPC_STATUS_XBUS_DMEM_DMA = 0x0000001;
    this.DPC_STATUS_FREEZE = 0x0000002;
    this.DPC_STATUS_FLUSH = 0x0000004;
    this.DPC_STATUS_START_GCLK = 0x008; //Bit 3: start gclk
    this.DPC_STATUS_TMEM_BUSY = 0x010; //Bit 4: tmem busy
    this.DPC_STATUS_PIPE_BUSY = 0x020; //Bit 5: pipe busy
    this.DPC_STATUS_CMD_BUSY = 0x040; //Bit 6: cmd busy
    this.DPC_STATUS_CBUF_READY = 0x080; //Bit 7: cbuf ready
    this.DPC_STATUS_DMA_BUSY = 0x100; //Bit 8: dma busy
    this.DPC_STATUS_END_VALID = 0x200; //Bit 9: end valid
    this.DPC_STATUS_START_VALID = 0x400; //Bit 10: start valid

    //DPC_STATUS_REG write flags
    this.DPC_CLR_XBUS_DMEM_DMA = 0x0000001;
    this.DPC_SET_XBUS_DMEM_DMA = 0x0000002;
    this.DPC_CLR_FREEZE = 0x0000004;
    this.DPC_SET_FREEZE = 0x0000008;
    this.DPC_CLR_FLUSH = 0x0000010;
    this.DPC_SET_FLUSH = 0x0000020;
    this.DPC_CLR_TMEM_REG = 0x0000040;
    this.DPC_CLR_PIPEBUSY_REG = 0x0000080;
    this.DPC_CLR_BUFBUSY_REG = 0x0000100;
    this.DPC_CLR_CLOCK_REG = 0x0000200;

    this.IE = 0x00000001;
    this.EXL = 0x00000002;
    this.ERL = 0x00000004;
    this.BD = 0x80000000;
    this.BEV = 0x00400000;

    //CAUSE register exception codes
    this.EXC_INT = 0;
    this.EXC_MOD = 4;
    this.EXC_RMISS = 8;
    this.TLBL_Miss = 8;
    this.EXC_WMISS = 12;
    this.TLBS_Miss = 12;
    this.EXC_RADE = 16;
    this.EXC_WADE = 20;
    this.EXC_IBE = 24;
    this.EXC_DBE = 28;
    this.EXC_SYSCALL = 32;
    this.EXC_BREAK = 36;
    this.EXC_II = 40;
    this.EXC_CPU = 44;
    this.EXC_OV = 48;
    this.EXC_TRAP = 52;
    this.EXC_VCEI = 56;
    this.EXC_FPE = 60;
    this.EXC_WATCH = 92;
    this.EXC_VCED = 124;

    //Pending interrupt flags
    this.CAUSE_IP8 = 0x00008000; //External level 8 pending - COMPARE
    this.CAUSE_IP7 = 0x00004000; //External level 7 pending - INT4
    this.CAUSE_IP6 = 0x00002000; //External level 6 pending - INT3
    this.CAUSE_IP5 = 0x00001000; //External level 5 pending - INT2
    this.CAUSE_IP4 = 0x00000800; //External level 4 pending - INT1
    this.CAUSE_IP3 = 0x00000400; //External level 3 pending - INT0
    this.CAUSE_SW2 = 0x00000200; /* Software level 2 pending */
    this.CAUSE_SW1	= 0x00000100; /* Software level 1 pending */
    this.CAUSE_BD = 0x80000000;


    this.COP1_CONDITION_BIT = 0x00800000;

    //TLB
    this.NTLBENTRIES = 31; //Entry 31 is reserved by rdb
    this.TLBHI_VPN2MASK = 0xffffe000;
    this.TLBHI_VPN2SHIFT = 13;
    this.TLBHI_PIDMASK = 0xff;
    this.TLBHI_PIDSHIFT = 0;
    this.TLBHI_NPID = 255; //255 to fit in 8 bits
    this.TLBLO_PFNMASK = 0x3fffffc0;
    this.TLBLO_PFNSHIFT = 6;
    this.TLBLO_CACHMASK = 0x38; //Cache coherency algorithm
    this.TLBLO_CACHSHIFT = 3;
    this.TLBLO_UNCACHED = 0x10; //Not cached
    this.TLBLO_NONCOHRNT = 0x18; //Cacheable non-coherent
    this.TLBLO_EXLWR = 0x28; //Exclusive write
    this.TLBLO_D = 0x4; //Writeable
    this.TLBLO_V = 0x2; //Valid bit
    this.TLBLO_G = 0x1; //global access bit
    this.TLBINX_PROBE = 0x80000000;
    this.TLBINX_INXMASK = 0x3f;
    this.TLBINX_INXSHIFT = 0;
    this.TLBRAND_RANDMASK = 0x3f;
    this.TLBRAND_RANDSHIFT = 0;
    this.TLBWIRED_WIREDMASK = 0x3f;
    this.TLBCTXT_BASEMASK = 0xff800000;
    this.TLBCTXT_BASESHIFT = 23;
    this.TLBCTXT_BASEBITS = 9;
    this.TLBCTXT_VPNMASK = 0x7ffff0;
    this.TLBCTXT_VPNSHIFT = 4;
    this.TLBPGMASK_4K = 0x0;
    this.TLBPGMASK_16K = 0x6000;
    this.TLBPGMASK_64K = 0x1e000;

    // sp dmem tasks
    this.BAD_TASK = 0;
    this.GFX_TASK = 1;
    this.SND_TASK = 2;
    this.JPG_TASK = 4;

    //os task
    this.TASK_TYPE = 0x00000FC0;
    this.TASK_FLAGS = 0x00000FC4;
    this.TASK_MICROCODE_BOOT = 0x00000FC8;
    this.TASK_MICROCODE_BOOT_SIZE = 0x00000FCC;
    this.TASK_MICROCODE = 0x00000FD0;
    this.TASK_MICROCODE_SIZE = 0x00000FD4;
    this.TASK_MICROCODE_DATA = 0x00000FD8;
    this.TASK_MICROCODE_DATA_SIZE = 0x00000FDC;
    this.TASK_DRAM_STACK = 0x00000FE0;
    this.TASK_DRAM_STACK_SIZE = 0x00000FE4;
    this.TASK_OUTPUT_BUFF = 0x00000FE8;
    this.TASK_OUTPUT_BUFF_SIZE = 0x00000FEC;
    this.TASK_DATA_PTR = 0x00000FF0;
    this.TASK_DATA_SIZE = 0x00000FF4;
    this.TASK_YIELD_DATA_PTR = 0x00000FF8;
    this.TASK_YIELD_DATA_SIZE = 0x00000FFC;

    //custom
    this.MAX_DL_STACK_SIZE = 32;
    this.MAX_DL_COUNT = 1000000;
    this.MAX_VERTS = 80;

    this.RSP_SPNOOP = 0; // handle 0 gracefully 
    this.RSP_MTX = 1;
    this.RSP_RESERVED0 = 2;	// unknown 
    this.RSP_MOVEMEM = 3;	// move a block of memory (up to 4 words) to dmem 
    this.RSP_VTX = 4;
    this.RSP_RESERVED1 = 5;	// unknown 
    this.RSP_DL = 6;
    this.RSP_RESERVED2 = 7;	// unknown 
    this.RSP_RESERVED3 = 8;	// unknown 
    this.RSP_SPRITE2D = 9;	// sprite command 
    this.RSP_SPRITE2D_BASE = 9; // sprite command

    this.RSP_1ST = 0xBF;
    this.RSP_TRI1 = this.RSP_1ST;
    this.RSP_CULLDL = this.RSP_1ST - 1;
    this.RSP_POPMTX = this.RSP_1ST - 2;
    this.RSP_MOVEWORD = this.RSP_1ST - 3;
    this.RSP_TEXTURE = this.RSP_1ST - 4;
    this.RSP_SETOTHERMODE_H = this.RSP_1ST - 5;
    this.RSP_SETOTHERMODE_L = this.RSP_1ST - 6;
    this.RSP_ENDDL = this.RSP_1ST - 7;
    this.RSP_SETGEOMETRYMODE = this.RSP_1ST - 8;
    this.RSP_CLEARGEOMETRYMODE = this.RSP_1ST - 9;
    this.RSP_LINE3D = this.RSP_1ST - 10;
    this.RSP_RDPHALF_1 = this.RSP_1ST - 11;
    this.RSP_RDPHALF_2 = this.RSP_1ST - 12;
    this.RSP_RDPHALF_CONT = this.RSP_1ST - 13;

    this.RSP_MODIFYVTX = this.RSP_1ST - 13;
    this.RSP_TRI2 = this.RSP_1ST - 14;
    this.RSP_BRANCH_Z = this.RSP_1ST - 15;
    this.RSP_LOAD_UCODE = this.RSP_1ST - 16;

    this.RSP_SPRITE2D_SCALEFLIP = this.RSP_1ST - 1;
    this.RSP_SPRITE2D_DRAW = this.RSP_1ST - 2;

    this.RSP_ZELDAVTX = 1;
    this.RSP_ZELDAMODIFYVTX = 2;
    this.RSP_ZELDACULLDL = 3;
    this.RSP_ZELDABRANCHZ = 4;
    this.RSP_ZELDATRI1 = 5;
    this.RSP_ZELDATRI2 = 6;
    this.RSP_ZELDALINE3D = 7;
    this.RSP_ZELDARDPHALF_2 = 0xf1;
    this.RSP_ZELDASETOTHERMODE_H = 0xe3;
    this.RSP_ZELDASETOTHERMODE_L = 0xe2;
    this.RSP_ZELDARDPHALF_1 = 0xe1;
    this.RSP_ZELDASPNOOP = 0xe0;
    this.RSP_ZELDAENDDL = 0xdf;
    this.RSP_ZELDADL = 0xde;
    this.RSP_ZELDALOAD_UCODE = 0xdd;
    this.RSP_ZELDAMOVEMEM = 0xdc;
    this.RSP_ZELDAMOVEWORD = 0xdb;
    this.RSP_ZELDAMTX = 0xda;
    this.RSP_ZELDAGEOMETRYMODE = 0xd9;
    this.RSP_ZELDAPOPMTX = 0xd8;
    this.RSP_ZELDATEXTURE = 0xd7;
    this.RSP_ZELDASUBMODULE = 0xd6;

    // 4 is something like a conditional DL
    this.RSP_DMATRI = 0x05;
    this.G_DLINMEM = 0x07;

    // RDP commands:
    this.RDP_NOOP = 0xc0;
    this.RDP_SETCIMG = 0xff;
    this.RDP_SETZIMG = 0xfe;
    this.RDP_SETTIMG = 0xfd;
    this.RDP_SETCOMBINE = 0xfc;
    this.RDP_SETENVCOLOR = 0xfb;
    this.RDP_SETPRIMCOLOR = 0xfa;
    this.RDP_SETBLENDCOLOR = 0xf9;
    this.RDP_SETFOGCOLOR = 0xf8;
    this.RDP_SETFILLCOLOR = 0xf7;
    this.RDP_FILLRECT = 0xf6;
    this.RDP_SETTILE = 0xf5;
    this.RDP_LOADTILE = 0xf4;
    this.RDP_LOADBLOCK = 0xf3;
    this.RDP_SETTILESIZE = 0xf2;
    this.RDP_LOADTLUT = 0xf0;
    this.RDP_RDPSETOTHERMODE = 0xef;
    this.RDP_SETPRIMDEPTH = 0xee;
    this.RDP_SETSCISSOR = 0xed;
    this.RDP_SETCONVERT = 0xec;
    this.RDP_SETKEYR = 0xeb;
    this.RDP_SETKEYGB = 0xea;
    this.RDP_FULLSYNC = 0xe9;
    this.RDP_TILESYNC = 0xe8;
    this.RDP_PIPESYNC = 0xe7;
    this.RDP_LOADSYNC = 0xe6;
    this.RDP_TEXRECT_FLIP = 0xe5;
    this.RDP_TEXRECT = 0xe4;

    this.RSP_ZELDA_MTX_MODELVIEW = 0x00;
    this.RSP_ZELDA_MTX_PROJECTION = 0x04;
    this.RSP_ZELDA_MTX_MUL = 0x00;
    this.RSP_ZELDA_MTX_LOAD = 0x02;
    this.RSP_ZELDA_MTX_PUSH = 0x00;
    this.RSP_ZELDA_MTX_NOPUSH = 0x01;

    // RSP_SETOTHERMODE_L sft: shift count
    this.RSP_SETOTHERMODE_SHIFT_ALPHACOMPARE = 0;
    this.RSP_SETOTHERMODE_SHIFT_ZSRCSEL = 2;
    this.RSP_SETOTHERMODE_SHIFT_RENDERMODE = 3;
    this.RSP_SETOTHERMODE_SHIFT_BLENDER = 16;

    // RSP_SETOTHERMODE_H sft: shift count
    this.RSP_SETOTHERMODE_SHIFT_BLENDMASK = 0; // unsupported 
    this.RSP_SETOTHERMODE_SHIFT_ALPHADITHER = 4;
    this.RSP_SETOTHERMODE_SHIFT_RGBDITHER = 6;

    this.RSP_SETOTHERMODE_SHIFT_COMBKEY = 8;
    this.RSP_SETOTHERMODE_SHIFT_TEXTCONV = 9;
    this.RSP_SETOTHERMODE_SHIFT_TEXTFILT = 12;
    this.RSP_SETOTHERMODE_SHIFT_TEXTLUT = 14;
    this.RSP_SETOTHERMODE_SHIFT_TEXTLOD = 16;
    this.RSP_SETOTHERMODE_SHIFT_TEXTDETAIL = 17;
    this.RSP_SETOTHERMODE_SHIFT_TEXTPERSP = 19;
    this.RSP_SETOTHERMODE_SHIFT_CYCLETYPE = 20;
    this.RSP_SETOTHERMODE_SHIFT_COLORDITHER = 22;	// unsupported in HW 2.0 
    this.RSP_SETOTHERMODE_SHIFT_PIPELINE = 23;

    // RSP_SETOTHERMODE_H gPipelineMode 
    this.RSP_PIPELINE_MODE_1PRIMITIVE = 1 << this.RSP_SETOTHERMODE_SHIFT_PIPELINE;
    this.RSP_PIPELINE_MODE_NPRIMITIVE = 0 << this.RSP_SETOTHERMODE_SHIFT_PIPELINE;

    // RSP_SETOTHERMODE_H gSetCycleType 
    this.CYCLE_TYPE_1 = 0;
    this.CYCLE_TYPE_2 = 1;
    this.CYCLE_TYPE_COPY = 2;
    this.CYCLE_TYPE_FILL = 3;

    // RSP_SETOTHERMODE_H gSetTextureLUT 
    this.TLUT_FMT_NONE = 0 << this.RSP_SETOTHERMODE_SHIFT_TEXTLUT;
    this.TLUT_FMT_UNKNOWN = 1 << this.RSP_SETOTHERMODE_SHIFT_TEXTLUT;
    this.TLUT_FMT_RGBA16 = 2 << this.RSP_SETOTHERMODE_SHIFT_TEXTLUT;
    this.TLUT_FMT_IA16 = 3 << this.RSP_SETOTHERMODE_SHIFT_TEXTLUT;

    // RSP_SETOTHERMODE_H gSetTextureFilter 
    this.RDP_TFILTER_POINT = 0 << this.RSP_SETOTHERMODE_SHIFT_TEXTFILT;
    this.RDP_TFILTER_AVERAGE = 3 << this.RSP_SETOTHERMODE_SHIFT_TEXTFILT;
    this.RDP_TFILTER_BILERP = 2 << this.RSP_SETOTHERMODE_SHIFT_TEXTFILT;

    // RSP_SETOTHERMODE_L gSetAlphaCompare
    this.RDP_ALPHA_COMPARE_NONE = 0 << this.RSP_SETOTHERMODE_SHIFT_ALPHACOMPARE;
    this.RDP_ALPHA_COMPARE_THRESHOLD = 1 << this.RSP_SETOTHERMODE_SHIFT_ALPHACOMPARE;
    this.RDP_ALPHA_COMPARE_DITHER = 3 << this.RSP_SETOTHERMODE_SHIFT_ALPHACOMPARE;

    // RSP_SETOTHERMODE_L gSetRenderMode 
    this.Z_COMPARE = 0x0010;
    this.Z_UPDATE = 0x0020;
    this.ZMODE_DEC = 0x0c00;

    // flags for RSP_SETGEOMETRYMODE
    this.G_ZBUFFER = 0x00000001;
    this.G_TEXTURE_ENABLE = 0x00000002;	// Microcode use only 
    this.G_SHADE = 0x00000004;	// enable Gouraud interp 
    this.G_SHADING_SMOOTH = 0x00000200;	// flat or smooth shaded 
    this.G_CULL_FRONT = 0x00001000;
    this.G_CULL_BACK = 0x00002000;
    this.G_CULL_BOTH = 0x00003000;	// To make code cleaner 
    this.G_FOG = 0x00010000;
    this.G_LIGHTING = 0x00020000;
    this.G_TEXTURE_GEN = 0x00040000;
    this.G_TEXTURE_GEN_LINEAR = 0x00080000;
    this.G_LOD = 0x00100000;	// NOT IMPLEMENTED 

    // G_SETIMG fmt: set image formats
    this.TXT_FMT_RGBA = 0;
    this.TXT_FMT_YUV = 1;
    this.TXT_FMT_CI = 2;
    this.TXT_FMT_IA = 3;
    this.TXT_FMT_I = 4;

    // G_SETIMG size: set image pixel size
    this.TXT_SIZE_4b = 0;
    this.TXT_SIZE_8b = 1;
    this.TXT_SIZE_16b = 2;
    this.TXT_SIZE_32b = 3;

    // Texturing macros
    this.RDP_TXT_LOADTILE = 7;
    this.RDP_TXT_RENDERTILE = 0;
    this.RDP_TXT_NOMIRROR = 0;
    this.RDP_TXT_WRAP = 0;
    this.RDP_TXT_MIRROR = 0x1;
    this.RDP_TXT_CLAMP = 0x2;
    this.RDP_TXT_NOMASK = 0;
    this.RDP_TXT_NOLOD = 0;

    // MOVEMEM indices
    // Each of these indexes an entry in a dmem table
    // which points to a 1-4 word block of dmem in
    // which to store a 1-4 word DMA.
    this.RSP_GBI1_MV_MEM_VIEWPORT = 0x80;
    this.RSP_GBI1_MV_MEM_LOOKATY = 0x82;
    this.RSP_GBI1_MV_MEM_LOOKATX = 0x84;
    this.RSP_GBI1_MV_MEM_L0 = 0x86;
    this.RSP_GBI1_MV_MEM_L1 = 0x88;
    this.RSP_GBI1_MV_MEM_L2 = 0x8a;
    this.RSP_GBI1_MV_MEM_L3 = 0x8c;
    this.RSP_GBI1_MV_MEM_L4 = 0x8e;
    this.RSP_GBI1_MV_MEM_L5 = 0x90;
    this.RSP_GBI1_MV_MEM_L6 = 0x92;
    this.RSP_GBI1_MV_MEM_L7 = 0x94;
    this.RSP_GBI1_MV_MEM_TXTATT = 0x96;
    this.RSP_GBI1_MV_MEM_MATRIX_1 = 0x9e; //NOTE: this is in moveword table 
    this.RSP_GBI1_MV_MEM_MATRIX_2 = 0x98;
    this.RSP_GBI1_MV_MEM_MATRIX_3 = 0x9a;
    this.RSP_GBI1_MV_MEM_MATRIX_4 = 0x9c;

    this.RSP_GBI2_MV_MEM__VIEWPORT = 8;
    this.RSP_GBI2_MV_MEM__LIGHT = 10;
    this.RSP_GBI2_MV_MEM__POINT = 12;
    this.RSP_GBI2_MV_MEM__MATRIX = 14; //NOTE: this is in moveword table
    this.RSP_GBI2_MV_MEM_O_LOOKATX = (0);
    this.RSP_GBI2_MV_MEM_O_LOOKATY = (24);
    this.RSP_GBI2_MV_MEM_O_L0 = (2 * 24);
    this.RSP_GBI2_MV_MEM_O_L1 = (3 * 24);
    this.RSP_GBI2_MV_MEM_O_L2 = (4 * 24);
    this.RSP_GBI2_MV_MEM_O_L3 = (5 * 24);
    this.RSP_GBI2_MV_MEM_O_L4 = (6 * 24);
    this.RSP_GBI2_MV_MEM_O_L5 = (7 * 24);
    this.RSP_GBI2_MV_MEM_O_L6 = (8 * 24);
    this.RSP_GBI2_MV_MEM_O_L7 = (9 * 24);

    // MOVEWORD indices
    // Each of these indexes an entry in a dmem table
    // which points to a word in dmem in dmem where
    // an immediate word will be stored.
    this.RSP_MOVE_WORD_MATRIX = 0x00;	// NOTE: also used by movemem 
    this.RSP_MOVE_WORD_NUMLIGHT = 0x02;
    this.RSP_MOVE_WORD_CLIP = 0x04;
    this.RSP_MOVE_WORD_SEGMENT = 0x06;
    this.RSP_MOVE_WORD_FOG = 0x08;
    this.RSP_MOVE_WORD_LIGHTCOL = 0x0a;
    this.RSP_MOVE_WORD_POINTS = 0x0c;
    this.RSP_MOVE_WORD_PERSPNORM = 0x0e;

    // These are offsets from the address in the dmem table
    this.RSP_MV_WORD_OFFSET_NUMLIGHT = 0x00;
    this.RSP_MV_WORD_OFFSET_CLIP_RNX = 0x04;
    this.RSP_MV_WORD_OFFSET_CLIP_RNY = 0x0c;
    this.RSP_MV_WORD_OFFSET_CLIP_RPX = 0x14;
    this.RSP_MV_WORD_OFFSET_CLIP_RPY = 0x1c;
    this.RSP_MV_WORD_OFFSET_FOG = 0x00;
    this.RSP_MV_WORD_OFFSET_POINT_RGBA = 0x10;
    this.RSP_MV_WORD_OFFSET_POINT_ST = 0x14;
    this.RSP_MV_WORD_OFFSET_POINT_XYSCREEN = 0x18;
    this.RSP_MV_WORD_OFFSET_POINT_ZSCREEN = 0x1c;

    // flags to inhibit pushing of the display list (on branch)
    this.RSP_DLIST_PUSH = 0x00;
    this.RSP_DLIST_NOPUSH = 0x01;
};