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

/////////////////
//Operand helpers
/////////////////

/*jslint bitwise: true, devel: true, todo: true*/
/*global consts*/
/*global goog, BigInt, bigint_mul, bigint_div, bigint_mod*/

//print out a hex number
function dec2hex(u) {
    "use strict";
    var d, h, hD = '0123456789ABCDEF';
    d = u;
    h = hD.substr(d & 15, 1);

    do {
        d >>= 4;
        d &= 0x0fffffff;
        h = hD.substr(d & 15, 1) + h;
    } while (d > 15);

    return h;
}

var C1964jsHelpers = function (isLittleEndian) {
    "use strict";
    this.isLittleEndian = isLittleEndian;
    this.isBigEndian = (isLittleEndian === false);

    this.fs = function (i) {
        return i >> 11 & 0x1f;
    };

    this.ft = function (i) {
        return i >> 16 & 0x1f;
    };

    this.FS32ArrayView = function (i) {
        return ((i >> 11 & 0x1f) ^ this.isBigEndian);
    };

    this.FS32HIArrayView = function (i) {
        return ((i >> 11 & 0x1f) ^ this.isLittleEndian);
    };

    this.FT32ArrayView = function (i) {
        return ((i >> 16 & 0x1f) ^ this.isBigEndian);
    };

    this.FT32HIArrayView = function (i) {
        return ((i >> 16 & 0x1f) ^ this.isLittleEndian);
    };

    this.FD32ArrayView = function (i) {
        return ((i >> 6 & 0x1F) ^ this.isBigEndian);
    };

    this.FD32HIArrayView = function (i) {
        return ((i >> 6 & 0x1f) ^ this.isLittleEndian);
    };

    this.FS64ArrayView = function (i) {
        return (i >> 11 & 0x1f) >> 1;
    };

    this.FT64ArrayView = function (i) {
        return (i >> 16 & 0x1f) >> 1;
    };

    this.FD64ArrayView = function (i) {
        return (i >> 6 & 0x1F) >> 1;
    };

    this.rd = function (i) {
        return i >> 11 & 0x1f;
    };

    this.rs = function (i) {
        return i >> 21 & 0x1f;
    };

    this.RS = function (i) {
        var reg = (i >> 21 & 0x1f);
        if (reg === 0) {
            return '0';
        }

        return 'r[' + reg + ']';
    };

    this.RSH = function (i) {
        var reg = (i >> 21 & 0x1f);
        if (reg === 0) {
            return '0';
        }

        return 'h[' + reg + ']';
    };

    this.uRS = function (i) {
        var reg = (i >> 21 & 0x1f);
        if (reg === 0) {
            return '0';
        }

        return '(r[' + reg + ']>>>0)';
    };

    this.uRSH = function (i) {
        var reg = (i >> 21 & 0x1f);
        if (reg === 0) {
            return '0';
        }

        return '(h[' + reg + ']>>>0)';
    };

    this.tRS = function (i) {
        var reg = (i >> 21 & 0x1f);
        if (reg === 0) {
            return 'r[34]';
        }

        return 'r[' + reg + ']';
    };

    this.tRSH = function (i) {
        var reg = (i >> 21 & 0x1f);
        if (reg === 0) {
            return 'h[34]';
        }

        return 'h[' + reg + ']';
    };

    this.tRD = function (i) {
        var reg = (i >> 11 & 0x1f);
        if (reg === 0) {
            return 'r[34]';
        }

        return 'r[' + reg + ']';
    };

    this.tRDH = function (i) {
        var reg = (i >> 11 & 0x1f);
        if (reg === 0) {
            return 'h[34]';
        }

        return 'h[' + reg + ']';
    };

    this.tRT = function (i) {
        var reg = (i >> 16 & 0x1f);
        if (reg === 0) {
            return 'r[34]';
        }

        return 'r[' + reg + ']';
    };

    this.tRTH = function (i) {
        var reg = (i >> 16 & 0x1f);
        if (reg === 0) {
            return 'h[34]';
        }

        return 'h[' + reg + ']';
    };

    this.RD = function (i) {
        var reg = (i >> 11 & 0x1f);

        if (reg === 0) {
            return '0';
        }

        return 'r[' + reg + ']';
    };

    this.RDH = function (i) {
        var reg = (i >> 11 & 0x1f);

        if (reg === 0) {
            return '0';
        }

        return 'h[' + reg + ']';
    };

    this.uRD = function (i) {
        var reg = (i >> 11 & 0x1f);

        if (reg === 0) {
            return '0';
        }

        return '(r[' + reg + ']>>>0)';
    };

    this.uRDH = function (i) {
        var reg = (i >> 11 & 0x1f);

        if (reg === 0) {
            return '0';
        }

        return '(h[' + reg + ']>>>0)';
    };

    this.RT = function (i) {
        var reg = (i >> 16 & 0x1f);

        if (reg === 0) {
            return '0';
        }

        return 'r[' + reg + ']';
    };

    this.RTH = function (i) {
        var reg = (i >> 16 & 0x1f);

        if (reg === 0) {
            return '0';
        }

        return 'h[' + reg + ']';
    };

    this.uRT = function (i) {
        var reg = (i >> 16 & 0x1f);

        if (reg === 0) {
            return '0';
        }

        return '(r[' + reg + ']>>>0)';
    };

    this.uRTH = function (i) {
        var reg = (i >> 16 & 0x1f);

        if (reg === 0) {
            return '0';
        }

        return '(h[' + reg + ']>>>0)';
    };

    this.rt = function (i) {
        return i >> 16 & 0x1f;
    };

    this.offset_imm = function (i) {
        return i & 0x0000ffff;
    };

    this.soffset_imm = function (i) {
        return (((i & 0x0000ffff) << 16) >> 16);
    };

    this.setVAddr = function (i) {
        return 't.vAddr=' + this.se(this.RS(i) + '+' + this.soffset_imm(i));
    };

    this.fn = function (i) {
        return i & 0x3f;
    };

    this.sa = function (i) {
        return i >> 6 & 0x1F;
    };

    this.fd = function (i) {
        return i >> 6 & 0x1F;
    };

    ////////////////////
    //Expression helpers
    ////////////////////

    //sign-extend 32bit operation
    this.se = function (o) {
        return '(' + o + ')>>0;';
    };

    //zero-extend 32bit operation
    this.ze = function (o) {
        return '(' + o + ')>>>0;';
    };

    //////////////////////
    //Opcode logic helpers
    //////////////////////

    this.sLogic = function (i, n) {
        return '{' + this.tRD(i) + '=' + this.RS(i) + n + this.RT(i) + ';' + this.tRDH(i) + '=' + this.RD(i) + '>>31;}';
    };

    this.dLogic = function (i, n) {
        return '{' + this.tRD(i) + '=' + this.RS(i) + n + this.RT(i) + ';' + this.tRDH(i) + '=' + this.RSH(i) + n + this.RTH(i) + ';}';
    };

    ////////////////////////////
    //Interpreted opcode helpers
    ////////////////////////////

    //called function, not compiled
    this.inter_mtc0 = function (r, f, rt, isDelaySlot, pc, cp0, interrupts) {
        //incomplete:
        switch (f) {
        case consts.CAUSE:
            cp0[f] &= ~0x300;
            cp0[f] |= r[rt] & 0x300;
            if (r[rt] & 0x300) {
          //      if (((r[rt] & 1)===1) && (cp0[f] & 1)===0) //possible fix over 1964cpp?
                if ((cp0[consts.CAUSE] & cp0[consts.STATUS] & 0x0000FF00) !== 0) {
                    interrupts.setException(consts.EXC_INT, 0, pc, isDelaySlot);
                    //interrupts.processException(pc, isDelaySlot);
                }
            }
            break;
        case consts.COUNT:
            cp0[f] = r[rt];
            break;
        case consts.COMPARE:
            cp0[consts.CAUSE] &= ~consts.CAUSE_IP8;
            cp0[f] = r[rt];
            break;
        case consts.STATUS:
            if (((r[rt] & consts.EXL) === 0) && ((cp0[f] & consts.EXL) === 1)) {
                if ((cp0[consts.CAUSE] & cp0[consts.STATUS] & 0x0000FF00) !== 0) {
                    cp0[f] = r[rt];
                    interrupts.setException(consts.EXC_INT, 0, pc, isDelaySlot);
                    //interrupts.processException(pc, isDelaySlot);
                    return;
                }
            }

            if (((r[rt] & consts.IE) === 1) && ((cp0[f] & consts.IE) === 0)) {
                if ((cp0[consts.CAUSE] & cp0[consts.STATUS] & 0x0000FF00) !== 0) {
                    cp0[f] = r[rt];
                    interrupts.setException(consts.EXC_INT, 0, pc, isDelaySlot);
                    //interrupts.processException(pc, isDelaySlot);
                    return;
                }
            }

            cp0[f] = r[rt];
            break;
        //tlb:
        case consts.BADVADDR: //read-only
            break;
        case consts.PREVID: //read-only
            break;
        case consts.RANDOM: //read-only
            break;
        case consts.INDEX:
            cp0[f] = r[rt] & 0x8000003F;
            break;
        case consts.ENTRYLO0:
            cp0[f] = r[rt] & 0x3FFFFFFF;
            break;
        case consts.ENTRYLO1:
            cp0[f] = r[rt] & 0x3FFFFFFF;
            break;
        case consts.ENTRYHI:
            cp0[f] = r[rt] & 0xFFFFE0FF;
            break;
        case consts.PAGEMASK:
            cp0[f] = r[rt] & 0x01FFE000;
            break;
        case consts.WIRED:
            cp0[f] = r[rt] & 0x1f;
            cp0[consts.RANDOM] = 0x1f;
            break;
        default:
            cp0[f] = r[rt];
            break;
        }
    };

    this.inter_mult = function (r, h, i) {
        var res, r1, r2, rt32, rs32 = r[this.rs(i)];
        rt32 = r[this.rt(i)];
        r1 = goog.math.Long.fromBits(rs32, rs32 >> 31);
        r2 = goog.math.Long.fromBits(rt32, rt32 >> 31);
        res = r1.multiply(r2);

        r[32] = res.getLowBits(); //lo
        h[32] = r[32] >> 31;
        r[33] = res.getHighBits(); //hi
        h[33] = r[33] >> 31;
    };

    this.inter_multu = function (r, h, i) {
        var res, r1, r2, rt32, rs32 = r[this.rs(i)];
        rt32 = r[this.rt(i)];
        r1 = goog.math.Long.fromBits(rs32, 0);
        r2 = goog.math.Long.fromBits(rt32, 0);
        res = r1.multiply(r2);

        r[32] = res.getLowBits(); //lo
        h[32] = r[32] >> 31;
        r[33] = res.getHighBits(); //hi
        h[33] = r[33] >> 31;

    //    alert('multu: '+r[this.rs(i)]+'*'+r[this.rt(i)]+'='+dec2hex(h[33]) +' '+dec2hex(r[33])+' '+dec2hex(h[32])+' '+dec2hex(r[32]));
    };

    this.inter_daddi = function (r, h, i) {
        var rtres, imm, rs1 = goog.math.Long.fromBits(r[this.rs(i)], h[this.rs(i)]);
        imm = goog.math.Long.fromBits(this.soffset_imm(i), this.soffset_imm(i) >> 31);
        rtres = rs1.add(imm);

        r[this.rt(i)] = rtres.getLowBits(); //lo
        h[this.rt(i)] = rtres.getHighBits(); //hi
    };

    this.inter_daddiu = function (r, h, i) {
        var rtres, imm, rs1 = goog.math.Long.fromBits(r[this.rs(i)], h[this.rs(i)]);
        imm = goog.math.Long.fromBits(this.soffset_imm(i), this.soffset_imm(i) >> 31);
        rtres = rs1.add(imm);

        r[this.rt(i)] = rtres.getLowBits(); //lo
        h[this.rt(i)] = rtres.getHighBits(); //hi
    };

    this.inter_dadd = function (r, h, i) {
        var rdres, rt1, rs1 = goog.math.Long.fromBits(r[this.rs(i)], h[this.rs(i)]);
        rt1 = goog.math.Long.fromBits(r[this.rt(i)], h[this.rt(i)]);
        rdres = rs1.add(rt1);

        r[this.rd(i)] = rdres.getLowBits(); //lo
        h[this.rd(i)] = rdres.getHighBits(); //hi
    };

    this.inter_daddu = function (r, h, i) {
        var rdres, rt1, rs1 = goog.math.Long.fromBits(r[this.rs(i)], h[this.rs(i)]);
        rt1 = goog.math.Long.fromBits(r[this.rt(i)], h[this.rt(i)]);
        rdres = rs1.add(rt1);

        r[this.rd(i)] = rdres.getLowBits(); //lo
        h[this.rd(i)] = rdres.getHighBits(); //hi
    };

    this.inter_div = function (r, h, i) {
        if (r[this.rt(i)] === 0) {
            alert('divide by zero');
            return;
        }
        //todo: handle div by zero

        r[32] = r[this.rs(i)] / r[this.rt(i)]; //lo
        h[32] = r[32] >> 31; //hi

        r[33] = r[this.rs(i)] % r[this.rt(i)]; //lo
        h[33] = r[33] >> 31; //hi

    //    alert('div: '+r[this.rs(i)]+'/'+r[this.rt(i)]+'='+dec2hex(h[33]) +' '+dec2hex(r[33])+' '+dec2hex(h[32])+' '+dec2hex(r[32]));
    };

    this.inter_ddiv = function (r, h, i) {
        var res, mod, rsh32, rth32, r1, r2, rt32, rs32 = r[this.rs(i)];
        rt32 = r[this.rt(i)];
        rsh32 = h[this.rs(i)];
        rth32 = h[this.rt(i)];
        r1 = goog.math.Long.fromBits(rs32, rsh32);
        r2 = goog.math.Long.fromBits(rt32, rth32);

        if (r2 === 0) {
            alert('divide by zero');
            return;
        }

        res = r1.div(r2);
        mod = r1.modulo(r2);

        r[32] = res.getLowBits(); //lo
        h[32] = res.getHighBits(); //hi

        r[33] = mod.getLowBits(); //lo
        h[33] = mod.getHighBits(); //hi

    //    alert('ddiv: '+rs64+'/'+rt64+'='+dec2hex(h[33]) +' '+dec2hex(r[33])+' '+dec2hex(h[32])+' '+dec2hex(r[32]));
    };

    this.inter_divu = function (r, h, i) {

        if (r[this.rt(i)] === 0) {
            alert('divide by zero');
            return;
        }
        //todo: handle div by zero

        r[32] = (r[this.rs(i)] >>> 0) / (r[this.rt(i)] >>> 0); //lo
        h[32] = 0; //hi

        r[33] = (r[this.rs(i)] >>> 0) % (r[this.rt(i)] >>> 0); //lo
        h[33] = 0; //hi

    //    alert('divu: '+r[this.rs(i)]+'/'+r[this.rt(i)]+'='+dec2hex(h[33]) +' '+dec2hex(r[33])+' '+dec2hex(h[32])+' '+dec2hex(r[32]));
    };

    this.inter_dmult = function (r, h, i) {
        //this is wrong..i think BigInt it will treat hex as unsigned?
        var delim, x, y, z, num, rt64, rs64 = '0x' + String(dec2hex(h[this.rs(i)])) + String(dec2hex(r[this.rs(i)]));
        rt64 = '0x' + String(dec2hex(h[this.rt(i)])) + String(dec2hex(r[this.rt(i)]));

        x = new BigInt(rs64);
        y = new BigInt(rt64);
        z = bigint_mul(x, y);
        num = z.toStringBase(16);

        if (num[0] === '-') {
            alert('dmult:' + num);
        }

        if (num.length > 24) {
            delim = num.length - 24;
            h[33] = ('0x' + num.substr(0, delim)) >>> 0; // hi of HIREG
            r[33] = ('0x' + num.substr(delim, 8)) >>> 0; // lo of HIREG
            h[32] = ('0x' + num.substr(delim + 8, 8)) >>> 0; // hi of LOREG
            r[32] = ('0x' + num.substr(delim + 16, 8)) >>> 0; // lo of LOREG
        } else if (num.length > 16) {
            delim = num.length - 16;
            h[33] = 0; // hi of HIREG
            r[33] = ('0x' + num.substr(0, delim)) >>> 0; // lo of HIREG
            h[32] = ('0x' + num.substr(delim, 8)) >>> 0; // hi of LOREG
            r[32] = ('0x' + num.substr(delim + 8, 8)) >>> 0; // lo of LOREG
        } else if (num.length > 8) {
            delim = num.length - 8;
            h[33] = 0; // hi of HIREG
            r[33] = 0; // lo of HIREG
            h[32] = ('0x' + num.substr(0, delim)) >>> 0; // hi of LOREG
            r[32] = ('0x' + num.substr(delim, 8)) >>> 0; // lo of LOREG    
        } else {
            delim = num.length;
            h[33] = 0; // hi of HIREG
            r[33] = 0; // lo of HIREG
            h[32] = 0; // hi of LOREG
            r[32] = ('0x' + num.substr(0, delim)) >>> 0; // lo of LOREG        
        }

    //    alert('dmult: '+rs64+'*'+rt64+'='+dec2hex(h[33]) +' '+dec2hex(r[33])+' '+dec2hex(h[32])+' '+dec2hex(r[32]));
    };

    this.inter_dmultu = function (r, h, i) {
    //Attax demo
        var delim, x, y, z, num, rt64, rs64 = '0x0' + String(dec2hex(h[this.rs(i)])) + String(dec2hex(r[this.rs(i)]));
        rt64 = '0x0' + String(dec2hex(h[this.rt(i)])) + String(dec2hex(r[this.rt(i)]));

        x = new BigInt(rs64);
        y = new BigInt(rt64);

        z = bigint_mul(x, y);
        num = z.toStringBase(16);

        if (num[0] === '-') {
            alert('dmultu:' + num);
        }

        if (num.length > 24) {
            delim = num.length - 24;
            h[33] = ('0x' + num.substr(0, delim)) >>> 0; // hi of HIREG
            r[33] = ('0x' + num.substr(delim, 8)) >>> 0; // lo of HIREG
            h[32] = ('0x' + num.substr(delim + 8, 8)) >>> 0; // hi of LOREG
            r[32] = ('0x' + num.substr(delim + 16, 8)) >>> 0; // lo of LOREG
        } else if (num.length > 16) {
            delim = num.length - 16;
            h[33] = 0; // hi of HIREG
            r[33] = ('0x' + num.substr(0, delim)) >>> 0; // lo of HIREG
            h[32] = ('0x' + num.substr(delim, 8)) >>> 0; // hi of LOREG
            r[32] = ('0x' + num.substr(delim + 8, 8)) >>> 0; // lo of LOREG
        } else if (num.length > 8) {
            delim = num.length - 8;
            h[33] = 0; // hi of HIREG
            r[33] = 0; // lo of HIREG
            h[32] = ('0x' + num.substr(0, delim)) >>> 0; // hi of LOREG
            r[32] = ('0x' + num.substr(delim, 8)) >>> 0; // lo of LOREG    
        } else {
            delim = num.length;
            h[33] = 0; // hi of HIREG
            r[33] = 0; // lo of HIREG
            h[32] = 0; // hi of LOREG
            r[32] = ('0x' + num.substr(0, delim)) >>> 0; // lo of LOREG        
        }

    //    alert('dmultu: '+rs64+'*'+rt64+'='+dec2hex(h[33]) +' '+dec2hex(r[33])+' '+dec2hex(h[32])+' '+dec2hex(r[32]));
    };

    this.inter_ddivu = function (r, h, i) {
        var delim, x, y, z, num, rt64, rs64 = '0x0' + String(dec2hex(h[this.rs(i)])) + String(dec2hex(r[this.rs(i)]));
        rt64 = '0x0' + String(dec2hex(h[this.rt(i)])) + String(dec2hex(r[this.rt(i)]));

        x = new BigInt(rs64);
        y = new BigInt(rt64);

        z = bigint_div(x, y);

        if (!z) {
            r[32] = 0;
            h[32] = 0;
        } else {
            num = z.toStringBase(16);

            if (num[0] === '-') {
                alert('ddivu:' + num);
            }

            if (num.length > 8) {
                delim = num.length - 8;
                h[32] = ('0x' + num.substr(0, delim)) >>> 0; // hi of LOREG
                r[32] = ('0x' + num.substr(delim, 8)) >>> 0; // lo of LOREG
            } else {
                delim = num.length;
                h[32] = 0; // hi of LOREG
                r[32] = ('0x' + num.substr(0, delim)) >>> 0; // lo of LOREG        
            }
        }

    //mod

        z = bigint_mod(x, y);

        num = z.toStringBase(16);

        if (num.length > 8) {
            delim = num.length - 8;
            h[33] = ('0x' + num.substr(0, delim)) >>> 0; // hi of LOREG
            r[33] = ('0x' + num.substr(delim, 8)) >>> 0; // lo of LOREG
        } else {
            delim = num.length;
            h[33] = 0; // hi of LOREG
            r[33] = ('0x' + num.substr(0, delim)) >>> 0; // lo of LOREG        
        }
    //    alert('ddivu: '+rs64+'/'+rt64+'='+dec2hex(h[33]) +' '+dec2hex(r[33])+' '+dec2hex(h[32])+' '+dec2hex(r[32]));
    };

    this.inter_r4300i_C_cond_fmt_s = function (instruction, cp1Con, cp1_f) {
        var	fcFS32, fcFT32, less, equal, unordered, cond, cond0, cond1, cond2, cond3;

    //	CHK_ODD_FPR_2_REG(RD_FS, RT_FT);

        cond0 = (instruction) & 0x1;
        cond1 = (instruction >> 1) & 0x1;
        cond2 = (instruction >> 2) & 0x1;
        cond3 = (instruction >> 3) & 0x1;
        fcFS32 = cp1_f[this.FS32ArrayView(instruction)];
        fcFT32 = cp1_f[this.FT32ArrayView(instruction)];

        if (isNaN(fcFS32) || isNaN(fcFT32)) {
            less = false;
            equal = false;
            unordered = true;

            if (cond3 !== 0) {
                //Fire invalid operation exception
                return;
            }
        } else {
            less = (fcFS32 < fcFT32);
            equal = (fcFS32 === fcFT32);
            unordered = false;
        }

        cond = ((cond0 && unordered) || (cond1 && equal) || (cond2 && less));

        cp1Con[31] &= ~consts.COP1_CONDITION_BIT;

        if (cond) {
            cp1Con[31] |= consts.COP1_CONDITION_BIT;
        }
    };

    this.inter_r4300i_C_cond_fmt_d = function (instruction, cp1Con, cp1_f64) {
        var	fcFS64, fcFT64, less, equal, unordered, cond, cond0, cond1, cond2, cond3;

    //	CHK_ODD_FPR_2_REG(RD_FS, RT_FT);

        cond0 = (instruction) & 0x1;
        cond1 = (instruction >> 1) & 0x1;
        cond2 = (instruction >> 2) & 0x1;
        cond3 = (instruction >> 3) & 0x1;
        fcFS64 = cp1_f64[this.FS64ArrayView(instruction)];
        fcFT64 = cp1_f64[this.FT64ArrayView(instruction)];

        if (isNaN(fcFS64) || isNaN(fcFT64)) {
            less = false;
            equal = false;
            unordered = true;

            if (cond3 !== 0) {
                //Fire invalid operation exception
                return;
            }
        } else {
            less = (fcFS64 < fcFT64);
            equal = (fcFS64 === fcFT64);
            unordered = false;
        }

        cond = ((cond0 && unordered) || (cond1 && equal) || (cond2 && less));

        cp1Con[31] &= ~consts.COP1_CONDITION_BIT;

        if (cond) {
            cp1Con[31] |= consts.COP1_CONDITION_BIT;
        }
    };
};