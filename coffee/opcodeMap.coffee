###1964js - JavaScript/HTML5 port of 1964 - N64 emulator
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
#globals C1964jsEmulator
"use strict"
C1964jsEmulator::CPU_instruction = ["instr", "REGIMM_instr", "r4300i_j", "r4300i_jal", "r4300i_beq", "r4300i_bne", "r4300i_blez", "r4300i_bgtz", "r4300i_addi", "r4300i_addiu", "r4300i_slti", "r4300i_sltiu", "r4300i_andi", "r4300i_ori", "r4300i_xori", "r4300i_lui", "COP0_instr", "COP1_instr", "UNUSED", "UNUSED", "r4300i_beql", "r4300i_bnel", "r4300i_blezl", "r4300i_bgtzl", "r4300i_daddi", "r4300i_daddiu", "r4300i_ldl", "r4300i_ldr", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "r4300i_lb", "r4300i_lh", "r4300i_lwl", "r4300i_lw", "r4300i_lbu", "r4300i_lhu", "r4300i_lwr", "r4300i_lwu", "r4300i_sb", "r4300i_sh", "r4300i_swl", "r4300i_sw", "r4300i_sdl", "r4300i_sdr", "r4300i_swr", "r4300i_cache", "r4300i_ll", "r4300i_lwc1", "UNUSED", "UNUSED", "r4300i_lld", "r4300i_ldc1", "UNUSED", "r4300i_ld", "r4300i_sc", "r4300i_swc1", "UNUSED", "UNUSED", "r4300i_scd", "r4300i_sdc1", "UNUSED", "r4300i_sd"]
C1964jsEmulator::r4300i_Instruction = ["r4300i_sll", "UNUSED", "r4300i_srl", "r4300i_sra", "r4300i_sllv", "UNUSED", "r4300i_srlv", "r4300i_srav", "r4300i_jr", "r4300i_jalr", "UNUSED", "UNUSED", "r4300i_syscall", "r4300i_break", "UNUSED", "r4300i_sync", "r4300i_mfhi", "r4300i_mthi", "r4300i_mflo", "r4300i_mtlo", "r4300i_dsllv", "UNUSED", "r4300i_dsrlv", "r4300i_dsrav", "r4300i_mult", "r4300i_multu", "r4300i_div", "r4300i_divu", "r4300i_dmult", "r4300i_dmultu", "r4300i_ddiv", "r4300i_ddivu", "r4300i_add", "r4300i_addu", "r4300i_sub", "r4300i_subu", "r4300i_and", "r4300i_or", "r4300i_xor", "r4300i_nor", "UNUSED", "UNUSED", "r4300i_slt", "r4300i_sltu", "r4300i_dadd", "r4300i_daddu", "r4300i_dsub", "r4300i_dsubu", "r4300i_tge", "r4300i_tgeu", "r4300i_tlt", "r4300i_tltu", "r4300i_teq", "UNUSED", "r4300i_tne", "UNUSED", "r4300i_dsll", "UNUSED", "r4300i_dsrl", "r4300i_dsra", "r4300i_dsll32", "UNUSED", "r4300i_dsrl32", "r4300i_dsra32"]
C1964jsEmulator::REGIMM_Instruction = ["r4300i_bltz", "r4300i_bgez", "r4300i_bltzl", "r4300i_bgezl", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "r4300i_tgei", "r4300i_tgeiu", "r4300i_tlti", "r4300i_tltiu", "r4300i_teqi", "UNUSED", "r4300i_tnei", "UNUSED", "r4300i_bltzal", "r4300i_bgezal", "r4300i_bltzall", "r4300i_bgezall", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED"]
C1964jsEmulator::COP0_Instruction = ["r4300i_COP0_mfc0", "UNUSED", "UNUSED", "UNUSED", "r4300i_COP0_mtc0", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "TLB_instr", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED"]
C1964jsEmulator::TLB_Instruction = ["UNUSED", "r4300i_COP0_tlbr", "r4300i_COP0_tlbwi", "UNUSED", "UNUSED", "UNUSED", "r4300i_COP0_tlbwr", "UNUSED", "r4300i_COP0_tlbp", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "r4300i_COP0_eret", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED"]
C1964jsEmulator::COP1_Instruction = ["r4300i_COP1_mfc1", "r4300i_COP1_dmfc1", "r4300i_COP1_cfc1", "UNUSED", "r4300i_COP1_mtc1", "r4300i_COP1_dmtc1", "r4300i_COP1_ctc1", "UNUSED", "COP1_BC_instr", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "COP1_S_instr", "COP1_D_instr", "UNUSED", "UNUSED", "COP1_W_instr", "COP1_L_instr", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED"]
C1964jsEmulator::COP1_BC_Instruction = ["r4300i_COP1_bc1f", "r4300i_COP1_bc1t", "r4300i_COP1_bc1fl", "r4300i_COP1_bc1tl", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED"]
C1964jsEmulator::COP1_S_Instruction = ["r4300i_COP1_add_s", "r4300i_COP1_sub_s", "r4300i_COP1_mul_s", "r4300i_COP1_div_s", "r4300i_COP1_sqrt_s", "r4300i_COP1_abs_s", "r4300i_COP1_mov_s", "r4300i_COP1_neg_s", "r4300i_COP1_roundl_s", "r4300i_COP1_truncl_s", "r4300i_COP1_ceill_s", "r4300i_COP1_floorl_s", "r4300i_COP1_roundw_s", "r4300i_COP1_truncw_s", "r4300i_COP1_ceilw_s", "r4300i_COP1_floorw_s", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "r4300i_COP1_cvtd_s", "UNUSED", "UNUSED", "r4300i_COP1_cvtw_s", "r4300i_COP1_cvtl_s", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "r4300i_C_F_S", "r4300i_C_UN_S", "r4300i_C_EQ_S", "r4300i_C_UEQ_S", "r4300i_C_OLT_S", "r4300i_C_ULT_S", "r4300i_C_OLE_S", "r4300i_C_ULE_S", "r4300i_C_SF_S", "r4300i_C_NGLE_S", "r4300i_C_SEQ_S", "r4300i_C_NGL_S", "r4300i_C_LT_S", "r4300i_C_NGE_S", "r4300i_C_LE_S", "r4300i_C_NGT_S"]
C1964jsEmulator::COP1_D_Instruction = ["r4300i_COP1_add_d", "r4300i_COP1_sub_d", "r4300i_COP1_mul_d", "r4300i_COP1_div_d", "r4300i_COP1_sqrt_d", "r4300i_COP1_abs_d", "r4300i_COP1_mov_d", "r4300i_COP1_neg_d", "r4300i_COP1_roundl_d", "r4300i_COP1_truncl_d", "r4300i_COP1_ceill_d", "r4300i_COP1_floorl_d", "r4300i_COP1_roundw_d", "r4300i_COP1_truncw_d", "r4300i_COP1_ceilw_d", "r4300i_COP1_floorw_d", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "r4300i_COP1_cvts_d", "UNUSED", "UNUSED", "UNUSED", "r4300i_COP1_cvtw_d", "r4300i_COP1_cvtl_d", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "r4300i_C_F_D", "r4300i_C_UN_D", "r4300i_C_EQ_D", "r4300i_C_UEQ_D", "r4300i_C_OLT_D", "r4300i_C_ULT_D", "r4300i_C_OLE_D", "r4300i_C_ULE_D", "r4300i_C_SF_D", "r4300i_C_NGLE_D", "r4300i_C_SEQ_D", "r4300i_C_NGL_D", "r4300i_C_LT_D", "r4300i_C_NGE_D", "r4300i_C_LE_D", "r4300i_C_NGT_D"]
C1964jsEmulator::COP1_W_Instruction = ["UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "r4300i_COP1_cvts_w", "r4300i_COP1_cvtd_w", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED"]
C1964jsEmulator::COP1_L_Instruction = ["UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "r4300i_COP1_cvts_l", "r4300i_COP1_cvtd_l", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED", "UNUSED"]

C1964jsEmulator::instr = (i, isDelay) ->
  this[@r4300i_Instruction[@helpers.fn(i)]] i, isDelay

C1964jsEmulator::REGIMM_instr = (i, isDelay) ->
  this[@REGIMM_Instruction[@helpers.rt(i)]] i, isDelay

C1964jsEmulator::COP0_instr = (i, isDelay) ->
  this[@COP0_Instruction[@helpers.rs(i)]] i, isDelay

C1964jsEmulator::COP1_instr = (i, isDelay) ->
  this[@COP1_Instruction[@helpers.rs(i)]] i, isDelay

C1964jsEmulator::TLB_instr = (i, isDelay) ->
  this[@TLB_Instruction[@helpers.fn(i)]] i, isDelay

C1964jsEmulator::COP1_BC_instr = (i, isDelay) ->
  this[@COP1_BC_Instruction[@helpers.rt(i)]] i, isDelay

C1964jsEmulator::COP1_S_instr = (i, isDelay) ->
  this[@COP1_S_Instruction[@helpers.fn(i)]] i, isDelay

C1964jsEmulator::COP1_D_instr = (i, isDelay) ->
  this[@COP1_D_Instruction[@helpers.fn(i)]] i, isDelay

C1964jsEmulator::COP1_W_instr = (i, isDelay) ->
  this[@COP1_W_Instruction[@helpers.fn(i)]] i, isDelay

C1964jsEmulator::COP1_L_instr = (i, isDelay) ->
  this[@COP1_L_Instruction[@helpers.fn(i)]] i, isDelay