###* @license 1964js - JavaScript/HTML5 port of 1964 - N64 emulator
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
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.###
#jslint bitwise: true
class C1964jsConstants
  "use strict"

  constructor: ->
    #mem map
    @MEMORY_START_PIF = 0x1FC00000
    @MEMORY_START_PIF_RAM = 0x1FC007C0
    @MEMORY_SIZE_PIF = 0x10000
    
    #cp0
    @INDEX = 0
    @RANDOM = 1
    @ENTRYLO0 = 2
    @ENTRYLO1 = 3
    @CONTEXT = 4
    @PAGEMASK = 5
    @WIRED = 6
    @RESERVED0 = 7
    @BADVADDR = 8
    @COUNT = 9
    @ENTRYHI = 10
    @COMPARE = 11
    @STATUS = 12
    @CAUSE = 13
    @EPC = 14
    @PREVID = 15
    @CONFIG = 16
    @LLADDR = 17
    @WATCHLO = 18
    @WATCHHI = 19
    @XCONTEXT = 20
    @RESERVED1 = 21
    @RESERVED2 = 22
    @RESERVED3 = 23
    @RESERVED4 = 24
    @RESERVED5 = 25
    @PERR = 26
    @CACHEERR = 27
    @TAGLO = 28
    @TAGHI = 29
    @ERROREPC = 30
    @RESERVED6 = 31
    
    #sp_dmem
    @SP_DMEM_TASK = 0x00000FC0
    
    #sp_reg_1
    @SP_MEM_ADDR_REG = 0
    @SP_DRAM_ADDR_REG = 4
    @SP_RD_LEN_REG = 8
    @SP_WR_LEN_REG = 12
    @SP_STATUS_REG = 16
    @SP_DMA_FULL_REG = 20
    @SP_DMA_BUSY_REG = 24
    @SP_SEMAPHORE_REG = 28
    
    #sp_reg_2
    @SP_PC_REG = 0
    @SP_IBIST_REG = 4
    
    #vi
    @VI_STATUS_REG = 0
    @VI_ORIGIN_REG = 4
    @VI_WIDTH_REG = 8
    @VI_INTR_REG = 12
    @VI_CURRENT_REG = 16
    @VI_BURST_REG = 20
    @VI_V_SYNC_REG = 24
    @VI_H_SYNC_REG = 28
    @VI_LEAP_REG = 32
    @VI_H_START_REG = 36
    @VI_V_START_REG = 40
    @VI_V_BURST_REG = 44
    @VI_X_SCALE_REG = 48
    @VI_Y_SCALE_REG = 52
    
    #ai
    @AI_DRAM_ADDR_REG = 0
    @AI_LEN_REG = 4
    @AI_CONTROL_REG = 8
    @AI_STATUS_REG = 12
    @AI_DACRATE_REG = 16
    @AI_BITRATE_REG = 20
    
    #pi
    @PI_DRAM_ADDR_REG = 0
    @PI_CART_ADDR_REG = 4
    @PI_RD_LEN_REG = 8
    @PI_WR_LEN_REG = 12
    @PI_STATUS_REG = 16
    @PI_BSD_DOM1_LAT_REG = 20
    @PI_BSD_DOM1_PWD_REG = 24
    @PI_BSD_DOM1_PGS_REG = 28
    @PI_BSD_DOM1_RLS_REG = 32
    @PI_BSD_DOM2_LAT_REG = 36
    @PI_BSD_DOM2_PWD_REG = 40
    @PI_BSD_DOM2_PGS_REG = 44
    @PI_BSD_DOM2_RLS_REG = 48
    
    #ri
    @RI_MODE_REG = 0
    @RI_CONFIG_REG = 4
    @RI_CURRENT_LOAD_REG = 8
    @RI_SELECT_REG = 12
    @RI_REFRESH_REG = 16
    @RI_LATENCY_REG = 20
    @RI_RERROR_REG = 24
    @RI_WERROR_REG = 28
    
    #mi
    @MI_INIT_MODE_REG = 0
    @MI_VERSION_REG = 4
    @MI_INTR_REG = 8
    @MI_INTR_MASK_REG = 12
    
    #si
    @SI_DRAM_ADDR_REG = 0
    @SI_PIF_ADDR_RD64B_REG = 4
    @SI_PIF_ADDR_WR64B_REG = 16
    @SI_STATUS_REG = 24
    
    #flags
    @SI_STATUS_DMA_BUSY = 0x0001
    @SI_STATUS_RD_BUSY = 0x0002
    @SI_STATUS_DMA_ERROR = 0x0008
    @SI_STATUS_INTERRUPT = 0x1000
    @AI_STATUS_FIFO_FULL = 0x80000000
    @AI_STATUS_DMA_BUSY = 0x40000000
    @PI_STATUS_RESET = 0x01
    @PI_STATUS_CLR_INTR = 0x02
    @PI_STATUS_ERROR = 0x04
    @PI_STATUS_IO_BUSY = 0x02
    @PI_STATUS_DMA_BUSY = 0x01
    @MI_INTR_SP = 0x00000001
    @MI_INTR_SI = 0x00000002
    @MI_INTR_AI = 0x00000004
    @MI_INTR_VI = 0x00000008
    @MI_INTR_PI = 0x00000010
    @MI_INTR_DP = 0x00000020
    @MI_INTR_MASK_SP = 0x01 #Bit 0: SP intr mask
    @MI_INTR_MASK_SI = 0x02 #Bit 1: SI intr mask
    @MI_INTR_MASK_AI = 0x04 #Bit 2: AI intr mask
    @MI_INTR_MASK_VI = 0x08 #Bit 3: VI intr mask
    @MI_INTR_MASK_PI = 0x10 #Bit 4: PI intr mask
    @MI_INTR_MASK_DP = 0x20 #Bit 5: DP intr mask
    @MI_INTR_MASK_SP_CLR = 0x01
    @MI_INTR_MASK_SP_SET = 0x02
    @MI_INTR_MASK_SI_CLR = 0x04
    @MI_INTR_MASK_SI_SET = 0x08
    @MI_INTR_MASK_AI_CLR = 0x10
    @MI_INTR_MASK_AI_SET = 0x20
    @MI_INTR_MASK_VI_CLR = 0x40
    @MI_INTR_MASK_VI_SET = 0x80
    @MI_INTR_MASK_PI_CLR = 0x100
    @MI_INTR_MASK_PI_SET = 0x200
    @MI_INTR_MASK_DP_CLR = 0x400
    @MI_INTR_MASK_DP_SET = 0x800
    
    #MI mode register read flags
    @MI_MODE_INIT = 0x0080
    @MI_MODE_EBUS = 0x0100
    @MI_MODE_RDRAM = 0x0200
    
    #MI mode register write flags
    @MI_CLR_INIT = 0x0080
    @MI_SET_INIT = 0x0100
    @MI_CLR_EBUS = 0x0200
    @MI_SET_EBUS = 0x0400
    @MI_CLR_DP_INTR = 0x0800
    @MI_CLR_RDRAM = 0x1000
    @MI_SET_RDRAM = 0x2000
    
    #DPC registers
    @DPC_START_REG = 0
    @DPC_END_REG = 4
    @DPC_CURRENT_REG = 8
    @DPC_STATUS_REG = 12
    @DPC_CLOCK_REG = 16
    @DPC_BUFBUSY_REG = 20
    @DPC_PIPEBUSY_REG = 24
    @DPC_TMEM_REG = 28
    
    #SP_STATUS_REG read flags
    @SP_STATUS_HALT = 0x0001
    @SP_STATUS_BROKE = 0x0002
    @SP_STATUS_DMA_BUSY = 0x0004
    @SP_STATUS_DMA_FULL = 0x0008
    @SP_STATUS_IO_FULL = 0x0010
    @SP_STATUS_SSTEP = 0x0020
    @SP_STATUS_INTR_BREAK = 0x0040
    @SP_STATUS_YIELD = 0x0080
    @SP_STATUS_YIELDED = 0x0100
    @SP_STATUS_TASKDONE = 0x0200
    @SP_STATUS_SIG3 = 0x0400
    @SP_STATUS_SIG4 = 0x0800
    @SP_STATUS_SIG5 = 0x1000
    @SP_STATUS_SIG6 = 0x2000
    @SP_STATUS_SIG7 = 0x4000

    
    #DPC_STATUS_REG read flags
    @DPC_STATUS_XBUS_DMEM_DMA = 0x0000001
    @DPC_STATUS_FREEZE = 0x0000002
    @DPC_STATUS_FLUSH = 0x0000004
    @DPC_STATUS_START_GCLK = 0x008 #Bit 3: start gclk
    @DPC_STATUS_TMEM_BUSY = 0x010 #Bit 4: tmem busy
    @DPC_STATUS_PIPE_BUSY = 0x020 #Bit 5: pipe busy
    @DPC_STATUS_CMD_BUSY = 0x040 #Bit 6: cmd busy
    @DPC_STATUS_CBUF_READY = 0x080 #Bit 7: cbuf ready
    @DPC_STATUS_DMA_BUSY = 0x100 #Bit 8: dma busy
    @DPC_STATUS_END_VALID = 0x200 #Bit 9: end valid
    @DPC_STATUS_START_VALID = 0x400 #Bit 10: start valid
    
    #DPC_STATUS_REG write flags
    @DPC_CLR_XBUS_DMEM_DMA = 0x0000001
    @DPC_SET_XBUS_DMEM_DMA = 0x0000002
    @DPC_CLR_FREEZE = 0x0000004
    @DPC_SET_FREEZE = 0x0000008
    @DPC_CLR_FLUSH = 0x0000010
    @DPC_SET_FLUSH = 0x0000020
    @DPC_CLR_TMEM_REG = 0x0000040
    @DPC_CLR_PIPEBUSY_REG = 0x0000080
    @DPC_CLR_BUFBUSY_REG = 0x0000100
    @DPC_CLR_CLOCK_REG = 0x0000200
    @IE = 0x00000001
    @EXL = 0x00000002
    @ERL = 0x00000004
    @BD = 0x80000000
    @BEV = 0x00400000
    
    #CAUSE register exception codes
    @EXC_INT = 0
    @EXC_MOD = 4
    @EXC_RMISS = 8
    @TLBL_Miss = 8
    @EXC_WMISS = 12
    @TLBS_Miss = 12
    @EXC_RADE = 16
    @EXC_WADE = 20
    @EXC_IBE = 24
    @EXC_DBE = 28
    @EXC_SYSCALL = 32
    @EXC_BREAK = 36
    @EXC_II = 40
    @EXC_CPU = 44
    @EXC_OV = 48
    @EXC_TRAP = 52
    @EXC_VCEI = 56
    @EXC_FPE = 60
    @EXC_WATCH = 92
    @EXC_VCED = 124
    
    #Pending interrupt flags
    @CAUSE_IP8 = 0x00008000 #External level 8 pending - COMPARE
    @CAUSE_IP7 = 0x00004000 #External level 7 pending - INT4
    @CAUSE_IP6 = 0x00002000 #External level 6 pending - INT3
    @CAUSE_IP5 = 0x00001000 #External level 5 pending - INT2
    @CAUSE_IP4 = 0x00000800 #External level 4 pending - INT1
    @CAUSE_IP3 = 0x00000400 #External level 3 pending - INT0
    @CAUSE_SW2 = 0x00000200 # Software level 2 pending
    @CAUSE_SW1 = 0x00000100 # Software level 1 pending
    @CAUSE_BD = 0x80000000
    @COP1_CONDITION_BIT = 0x00800000
    
    #TLB
    @NTLBENTRIES = 31 #Entry 31 is reserved by rdb
    @TLBHI_VPN2MASK = 0xffffe000
    @TLBHI_VPN2SHIFT = 13
    @TLBHI_PIDMASK = 0xff
    @TLBHI_PIDSHIFT = 0
    @TLBHI_NPID = 255 #255 to fit in 8 bits
    @TLBLO_PFNMASK = 0x3fffffc0
    @TLBLO_PFNSHIFT = 6
    @TLBLO_CACHMASK = 0x38 #Cache coherency algorithm
    @TLBLO_CACHSHIFT = 3
    @TLBLO_UNCACHED = 0x10 #Not cached
    @TLBLO_NONCOHRNT = 0x18 #Cacheable non-coherent
    @TLBLO_EXLWR = 0x28 #Exclusive write
    @TLBLO_D = 0x4 #Writeable
    @TLBLO_V = 0x2 #Valid bit
    @TLBLO_G = 0x1 #global access bit
    @TLBINX_PROBE = 0x80000000
    @TLBINX_INXMASK = 0x3f
    @TLBINX_INXSHIFT = 0
    @TLBRAND_RANDMASK = 0x3f
    @TLBRAND_RANDSHIFT = 0
    @TLBWIRED_WIREDMASK = 0x3f
    @TLBCTXT_BASEMASK = 0xff800000
    @TLBCTXT_BASESHIFT = 23
    @TLBCTXT_BASEBITS = 9
    @TLBCTXT_VPNMASK = 0x7ffff0
    @TLBCTXT_VPNSHIFT = 4
    @TLBPGMASK_4K = 0x0
    @TLBPGMASK_16K = 0x6000
    @TLBPGMASK_64K = 0x1e000
    
    # sp dmem tasks
    @BAD_TASK = 0
    @GFX_TASK = 1
    @SND_TASK = 2
    @JPG_TASK = 4
    
    #os task
    @TASK_TYPE = 0x00000FC0
    @TASK_FLAGS = 0x00000FC4
    @TASK_MICROCODE_BOOT = 0x00000FC8
    @TASK_MICROCODE_BOOT_SIZE = 0x00000FCC
    @TASK_MICROCODE = 0x00000FD0
    @TASK_MICROCODE_SIZE = 0x00000FD4
    @TASK_MICROCODE_DATA = 0x00000FD8
    @TASK_MICROCODE_DATA_SIZE = 0x00000FDC
    @TASK_DRAM_STACK = 0x00000FE0
    @TASK_DRAM_STACK_SIZE = 0x00000FE4
    @TASK_OUTPUT_BUFF = 0x00000FE8
    @TASK_OUTPUT_BUFF_SIZE = 0x00000FEC
    @TASK_DATA_PTR = 0x00000FF0
    @TASK_DATA_SIZE = 0x00000FF4
    @TASK_YIELD_DATA_PTR = 0x00000FF8
    @TASK_YIELD_DATA_SIZE = 0x00000FFC
    
    #custom
    @MAX_DL_STACK_SIZE = 32
    @MAX_DL_COUNT = 1000000
    @MAX_VERTS = 80
    @RSP_SPNOOP = 0 # handle 0 gracefully
    @RSP_MTX = 1
    @RSP_RESERVED0 = 2 # unknown
    @RSP_MOVEMEM = 3 # move a block of memory (up to 4 words) to dmem
    @RSP_VTX = 4
    @RSP_RESERVED1 = 5 # unknown
    @RSP_DL = 6
    @RSP_RESERVED2 = 7 # unknown
    @RSP_RESERVED3 = 8 # unknown
    @RSP_SPRITE2D = 9 # sprite command
    @RSP_SPRITE2D_BASE = 9 # sprite command
    @RSP_1ST = 0xBF
    @RSP_TRI1 = @RSP_1ST
    @RSP_CULLDL = @RSP_1ST - 1
    @RSP_POPMTX = @RSP_1ST - 2
    @RSP_MOVEWORD = @RSP_1ST - 3
    @RSP_TEXTURE = @RSP_1ST - 4
    @RSP_SETOTHERMODE_H = @RSP_1ST - 5
    @RSP_SETOTHERMODE_L = @RSP_1ST - 6
    @RSP_ENDDL = @RSP_1ST - 7
    @RSP_SETGEOMETRYMODE = @RSP_1ST - 8
    @RSP_CLEARGEOMETRYMODE = @RSP_1ST - 9
    @RSP_LINE3D = @RSP_1ST - 10
    @RSP_RDPHALF_1 = @RSP_1ST - 11
    @RSP_RDPHALF_2 = @RSP_1ST - 12
    @RSP_RDPHALF_CONT = @RSP_1ST - 13
    @RSP_MODIFYVTX = @RSP_1ST - 13
    @RSP_TRI2 = @RSP_1ST - 14
    @RSP_BRANCH_Z = @RSP_1ST - 15
    @RSP_LOAD_UCODE = @RSP_1ST - 16
    @RSP_SPRITE2D_SCALEFLIP = @RSP_1ST - 1
    @RSP_SPRITE2D_DRAW = @RSP_1ST - 2
    @RSP_ZELDAVTX = 1
    @RSP_ZELDAMODIFYVTX = 2
    @RSP_ZELDACULLDL = 3
    @RSP_ZELDABRANCHZ = 4
    @RSP_ZELDATRI1 = 5
    @RSP_ZELDATRI2 = 6
    @RSP_ZELDALINE3D = 7
    @RSP_ZELDARDPHALF_2 = 0xf1
    @RSP_ZELDASETOTHERMODE_H = 0xe3
    @RSP_ZELDASETOTHERMODE_L = 0xe2
    @RSP_ZELDARDPHALF_1 = 0xe1
    @RSP_ZELDASPNOOP = 0xe0
    @RSP_ZELDAENDDL = 0xdf
    @RSP_ZELDADL = 0xde
    @RSP_ZELDALOAD_UCODE = 0xdd
    @RSP_ZELDAMOVEMEM = 0xdc
    @RSP_ZELDAMOVEWORD = 0xdb
    @RSP_ZELDAMTX = 0xda
    @RSP_ZELDAGEOMETRYMODE = 0xd9
    @RSP_ZELDAPOPMTX = 0xd8
    @RSP_ZELDATEXTURE = 0xd7
    @RSP_ZELDASUBMODULE = 0xd6
    
    # 4 is something like a conditional DL
    @RSP_DMATRI = 0x05
    @G_DLINMEM = 0x07
    
    # RDP commands:
    @RDP_NOOP = 0xc0
    @RDP_SETCIMG = 0xff
    @RDP_SETZIMG = 0xfe
    @RDP_SETTIMG = 0xfd
    @RDP_SETCOMBINE = 0xfc
    @RDP_SETENVCOLOR = 0xfb
    @RDP_SETPRIMCOLOR = 0xfa
    @RDP_SETBLENDCOLOR = 0xf9
    @RDP_SETFOGCOLOR = 0xf8
    @RDP_SETFILLCOLOR = 0xf7
    @RDP_FILLRECT = 0xf6
    @RDP_SETTILE = 0xf5
    @RDP_LOADTILE = 0xf4
    @RDP_LOADBLOCK = 0xf3
    @RDP_SETTILESIZE = 0xf2
    @RDP_LOADTLUT = 0xf0
    @RDP_RDPSETOTHERMODE = 0xef
    @RDP_SETPRIMDEPTH = 0xee
    @RDP_SETSCISSOR = 0xed
    @RDP_SETCONVERT = 0xec
    @RDP_SETKEYR = 0xeb
    @RDP_SETKEYGB = 0xea
    @RDP_FULLSYNC = 0xe9
    @RDP_TILESYNC = 0xe8
    @RDP_PIPESYNC = 0xe7
    @RDP_LOADSYNC = 0xe6
    @RDP_TEXRECT_FLIP = 0xe5
    @RDP_TEXRECT = 0xe4
    @RSP_ZELDA_MTX_MODELVIEW = 0x00
    @RSP_ZELDA_MTX_PROJECTION = 0x04
    @RSP_ZELDA_MTX_MUL = 0x00
    @RSP_ZELDA_MTX_LOAD = 0x02
    @RSP_ZELDA_MTX_PUSH = 0x00
    @RSP_ZELDA_MTX_NOPUSH = 0x01
    
    # RSP_SETOTHERMODE_L sft: shift count
    @RSP_SETOTHERMODE_SHIFT_ALPHACOMPARE = 0
    @RSP_SETOTHERMODE_SHIFT_ZSRCSEL = 2
    @RSP_SETOTHERMODE_SHIFT_RENDERMODE = 3
    @RSP_SETOTHERMODE_SHIFT_BLENDER = 16
    
    # RSP_SETOTHERMODE_H sft: shift count
    @RSP_SETOTHERMODE_SHIFT_BLENDMASK = 0 # unsupported
    @RSP_SETOTHERMODE_SHIFT_ALPHADITHER = 4
    @RSP_SETOTHERMODE_SHIFT_RGBDITHER = 6
    @RSP_SETOTHERMODE_SHIFT_COMBKEY = 8
    @RSP_SETOTHERMODE_SHIFT_TEXTCONV = 9
    @RSP_SETOTHERMODE_SHIFT_TEXTFILT = 12
    @RSP_SETOTHERMODE_SHIFT_TEXTLUT = 14
    @RSP_SETOTHERMODE_SHIFT_TEXTLOD = 16
    @RSP_SETOTHERMODE_SHIFT_TEXTDETAIL = 17
    @RSP_SETOTHERMODE_SHIFT_TEXTPERSP = 19
    @RSP_SETOTHERMODE_SHIFT_CYCLETYPE = 20
    @RSP_SETOTHERMODE_SHIFT_COLORDITHER = 22 # unsupported in HW 2.0
    @RSP_SETOTHERMODE_SHIFT_PIPELINE = 23
    
    # RSP_SETOTHERMODE_H gPipelineMode
    @RSP_PIPELINE_MODE_1PRIMITIVE = 1 << @RSP_SETOTHERMODE_SHIFT_PIPELINE
    @RSP_PIPELINE_MODE_NPRIMITIVE = 0 << @RSP_SETOTHERMODE_SHIFT_PIPELINE
    
    # RSP_SETOTHERMODE_H gSetCycleType
    @CYCLE_TYPE_1 = 0
    @CYCLE_TYPE_2 = 1
    @CYCLE_TYPE_COPY = 2
    @CYCLE_TYPE_FILL = 3
    
    # RSP_SETOTHERMODE_H gSetTextureLUT
    @TLUT_FMT_NONE = 0 << @RSP_SETOTHERMODE_SHIFT_TEXTLUT
    @TLUT_FMT_UNKNOWN = 1 << @RSP_SETOTHERMODE_SHIFT_TEXTLUT
    @TLUT_FMT_RGBA16 = 2 << @RSP_SETOTHERMODE_SHIFT_TEXTLUT
    @TLUT_FMT_IA16 = 3 << @RSP_SETOTHERMODE_SHIFT_TEXTLUT
    
    # RSP_SETOTHERMODE_H gSetTextureFilter
    @RDP_TFILTER_POINT = 0 << @RSP_SETOTHERMODE_SHIFT_TEXTFILT
    @RDP_TFILTER_AVERAGE = 3 << @RSP_SETOTHERMODE_SHIFT_TEXTFILT
    @RDP_TFILTER_BILERP = 2 << @RSP_SETOTHERMODE_SHIFT_TEXTFILT
    
    # RSP_SETOTHERMODE_L gSetAlphaCompare
    @RDP_ALPHA_COMPARE_NONE = 0 << @RSP_SETOTHERMODE_SHIFT_ALPHACOMPARE
    @RDP_ALPHA_COMPARE_THRESHOLD = 1 << @RSP_SETOTHERMODE_SHIFT_ALPHACOMPARE
    @RDP_ALPHA_COMPARE_DITHER = 3 << @RSP_SETOTHERMODE_SHIFT_ALPHACOMPARE
    
    # RSP_SETOTHERMODE_L gSetRenderMode
    @Z_COMPARE = 0x0010
    @Z_UPDATE = 0x0020
    @ZMODE_DEC = 0x0c00
    
    # flags for RSP_SETGEOMETRYMODE
    @G_ZBUFFER = 0x00000001
    @G_TEXTURE_ENABLE = 0x00000002 # Microcode use only
    @G_SHADE = 0x00000004 # enable Gouraud interp
    @G_SHADING_SMOOTH = 0x00000200 # flat or smooth shaded
    @G_CULL_FRONT = 0x00001000
    @G_CULL_BACK = 0x00002000
    @G_CULL_BOTH = 0x00003000 # To make code cleaner
    @G_FOG = 0x00010000
    @G_LIGHTING = 0x00020000
    @G_TEXTURE_GEN = 0x00040000
    @G_TEXTURE_GEN_LINEAR = 0x00080000
    @G_LOD = 0x00100000 # NOT IMPLEMENTED
    
    # G_SETIMG fmt: set image formats
    @TXT_FMT_RGBA = 0
    @TXT_FMT_YUV = 1
    @TXT_FMT_CI = 2
    @TXT_FMT_IA = 3
    @TXT_FMT_I = 4
    
    # G_SETIMG size: set image pixel size
    @TXT_SIZE_4b = 0
    @TXT_SIZE_8b = 1
    @TXT_SIZE_16b = 2
    @TXT_SIZE_32b = 3
    
    # Texturing macros
    @RDP_TXT_LOADTILE = 7
    @RDP_TXT_RENDERTILE = 0
    @RDP_TXT_NOMIRROR = 0
    @RDP_TXT_WRAP = 0
    @RDP_TXT_MIRROR = 0x1
    @RDP_TXT_CLAMP = 0x2
    @RDP_TXT_NOMASK = 0
    @RDP_TXT_NOLOD = 0
    
    # MOVEMEM indices
    # Each of these indexes an entry in a dmem table
    # which points to a 1-4 word block of dmem in
    # which to store a 1-4 word DMA.
    @RSP_GBI1_MV_MEM_VIEWPORT = 0x80
    @RSP_GBI1_MV_MEM_LOOKATY = 0x82
    @RSP_GBI1_MV_MEM_LOOKATX = 0x84
    @RSP_GBI1_MV_MEM_L0 = 0x86
    @RSP_GBI1_MV_MEM_L1 = 0x88
    @RSP_GBI1_MV_MEM_L2 = 0x8a
    @RSP_GBI1_MV_MEM_L3 = 0x8c
    @RSP_GBI1_MV_MEM_L4 = 0x8e
    @RSP_GBI1_MV_MEM_L5 = 0x90
    @RSP_GBI1_MV_MEM_L6 = 0x92
    @RSP_GBI1_MV_MEM_L7 = 0x94
    @RSP_GBI1_MV_MEM_TXTATT = 0x96
    @RSP_GBI1_MV_MEM_MATRIX_1 = 0x9e #NOTE: this is in moveword table
    @RSP_GBI1_MV_MEM_MATRIX_2 = 0x98
    @RSP_GBI1_MV_MEM_MATRIX_3 = 0x9a
    @RSP_GBI1_MV_MEM_MATRIX_4 = 0x9c
    @RSP_GBI2_MV_MEM__VIEWPORT = 8
    @RSP_GBI2_MV_MEM__LIGHT = 10
    @RSP_GBI2_MV_MEM__POINT = 12
    @RSP_GBI2_MV_MEM__MATRIX = 14 #NOTE: this is in moveword table
    @RSP_GBI2_MV_MEM_O_LOOKATX = (0)
    @RSP_GBI2_MV_MEM_O_LOOKATY = (24)
    @RSP_GBI2_MV_MEM_O_L0 = (2 * 24)
    @RSP_GBI2_MV_MEM_O_L1 = (3 * 24)
    @RSP_GBI2_MV_MEM_O_L2 = (4 * 24)
    @RSP_GBI2_MV_MEM_O_L3 = (5 * 24)
    @RSP_GBI2_MV_MEM_O_L4 = (6 * 24)
    @RSP_GBI2_MV_MEM_O_L5 = (7 * 24)
    @RSP_GBI2_MV_MEM_O_L6 = (8 * 24)
    @RSP_GBI2_MV_MEM_O_L7 = (9 * 24)
    
    # MOVEWORD indices
    # Each of these indexes an entry in a dmem table
    # which points to a word in dmem in dmem where
    # an immediate word will be stored.
    @RSP_MOVE_WORD_MATRIX = 0x00 # NOTE: also used by movemem
    @RSP_MOVE_WORD_NUMLIGHT = 0x02
    @RSP_MOVE_WORD_CLIP = 0x04
    @RSP_MOVE_WORD_SEGMENT = 0x06
    @RSP_MOVE_WORD_FOG = 0x08
    @RSP_MOVE_WORD_LIGHTCOL = 0x0a
    @RSP_MOVE_WORD_POINTS = 0x0c
    @RSP_MOVE_WORD_PERSPNORM = 0x0e
    
    # These are offsets from the address in the dmem table
    @RSP_MV_WORD_OFFSET_NUMLIGHT = 0x00
    @RSP_MV_WORD_OFFSET_CLIP_RNX = 0x04
    @RSP_MV_WORD_OFFSET_CLIP_RNY = 0x0c
    @RSP_MV_WORD_OFFSET_CLIP_RPX = 0x14
    @RSP_MV_WORD_OFFSET_CLIP_RPY = 0x1c
    @RSP_MV_WORD_OFFSET_FOG = 0x00
    @RSP_MV_WORD_OFFSET_POINT_RGBA = 0x10
    @RSP_MV_WORD_OFFSET_POINT_ST = 0x14
    @RSP_MV_WORD_OFFSET_POINT_XYSCREEN = 0x18
    @RSP_MV_WORD_OFFSET_POINT_ZSCREEN = 0x1c
    
    # flags to inhibit pushing of the display list (on branch)
    @RSP_DLIST_PUSH = 0x00
    @RSP_DLIST_NOPUSH = 0x01

#hack global space until we export classes properly
#node.js uses exports; browser uses this (window)
root = exports ? self
root.C1964jsConstants = C1964jsConstants