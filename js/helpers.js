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

function fs(i) {
    return i >> 11 & 0x1f;
}

function ft(i) {
    return i >> 16 & 0x1f;
}

function FS32ArrayView(i) {
    return ((i >> 11 & 0x1f)^isBigEndian);
}

function FS32HIArrayView(i) {
    return ((i >> 11 & 0x1f)^isLittleEndian);
}

function FT32ArrayView(i) {
    return ((i >> 16 & 0x1f)^isBigEndian);
}

function FT32HIArrayView(i) {
    return ((i >> 16 & 0x1f)^isLittleEndian);
}

function FD32ArrayView(i) {
    return ((i >> 6 & 0x1F)^isBigEndian);
}

function FD32HIArrayView(i) {
    return ((i >> 6 & 0x1f)^isLittleEndian);
}

function FS64ArrayView(i) {
    return (i >> 11 & 0x1f)>>1;
}

function FT64ArrayView(i) {
    return (i >> 16 & 0x1f)>>1;
}

function FD64ArrayView(i) {
    return (i >> 6 & 0x1F)>>1;
}

function rd(i) {
    return i >> 11 & 0x1f;
}

function rs(i) {
    return i >> 21 & 0x1f;
}

function RS(i) {
    var reg=(i >> 21 & 0x1f);
    if (reg===0)
        return '0';
    else
        return 'r[' + reg + ']';
}

function RSH(i)
{
    var reg=(i >> 21 & 0x1f);
    if (reg===0)
        return '0';
    else
        return 'h[' + reg + ']';
}

function uRS(i)
{
    var reg=(i >> 21 & 0x1f);
    if (reg===0)
        return '0';
    else
        return '(r[' + reg + ']>>>0)';
}

function uRSH(i)
{
    var reg=(i >> 21 & 0x1f);
    if (reg===0)
        return '0';
    else
        return '(h[' + reg + ']>>>0)';
}

function _RS(i)
{
    var reg=(i >> 21 & 0x1f);
    if (reg===0)
        return 'r[34]';
    else
        return 'r[' + reg + ']';
}

function _RSH(i)
{
    var reg=(i >> 21 & 0x1f);
    if (reg===0)
        return 'h[34]';
    else
        return 'h[' + reg + ']';
}

function _RD(i)
{
    var reg=(i >> 11 & 0x1f);
    if (reg===0)
        return 'r[34]';
    else
        return 'r[' + reg + ']';
}

function _RDH(i)
{
    var reg=(i >> 11 & 0x1f);
    if (reg===0)
        return 'h[34]';
    else
        return 'h[' + reg + ']';
}

function _RT(i)
{
    var reg=(i >> 16 & 0x1f);
    if (reg===0)
        return 'r[34]';
    else
        return 'r[' + reg + ']';
}

function _RTH(i)
{
    var reg=(i >> 16 & 0x1f);
    if (reg===0)
        return 'h[34]';
    else
        return 'h[' + reg + ']';
}

function RD(i)
{
    var reg=(i >> 11 & 0x1f);
    
    if (reg===0)
        return '0';
    else
        return 'r[' + reg + ']';
}

function RDH(i)
{
    var reg=(i >> 11 & 0x1f);
    
    if (reg===0)
        return '0';
    else
        return 'h[' + reg + ']';
}

function uRD(i)
{
    var reg=(i >> 11 & 0x1f);
    
    if (reg===0)
        return '0';
    else
        return '(r[' + reg + ']>>>0)';
}

function uRDH(i)
{
    var reg=(i >> 11 & 0x1f);
    
    if (reg===0)
        return '0';
    else
        return '(h[' + reg + ']>>>0)';
}

function RT(i)
{
    var reg=(i >> 16 & 0x1f);
    
    if (reg===0)
        return '0';
    else
        return 'r[' + reg + ']';
}

function RTH(i)
{
    var reg=(i >> 16 & 0x1f);
    
    if (reg===0)
        return '0';
    else
        return 'h[' + reg + ']';
}

function uRT(i)
{
    var reg=(i >> 16 & 0x1f);
    
    if (reg===0)
        return '0';
    else
        return '(r[' + reg + ']>>>0)';
}

function uRTH(i)
{
    var reg=(i >> 16 & 0x1f);
    
    if (reg===0)
        return '0';
    else
        return '(h[' + reg + ']>>>0)';
}

function rt(i)
{
    return i >> 16 & 0x1f;
}

function offset_imm(i)
{
    return i & 0x0000ffff;
}

function soffset_imm(i)
{
    return (((i&0x0000ffff)<<16)>>16);
}

function setVAddr(i)
{
    return 'vAddr='+se(RS(i)+'+'+soffset_imm(i));
}

function fn(i)
{
    return i & 0x3f;
}

function sa(i)
{
    return i >> 6 & 0x1F;
}

function fd(i)
{
    return i >> 6 & 0x1F;
}

////////////////////
//Expression helpers
////////////////////

//sign-extend 32bit operation
function se(o)
{
    return '(' + o + ')>>0;';
}

//zero-extend 32bit operation
function ze(o)
{
    return '(' + o + ')>>>0;';
}

//////////////////////
//Opcode logic helpers
//////////////////////

function sLogic(i, n) {
    return '{'+_RD(i)+'='+RS(i)+n+RT(i)+';'+_RDH(i)+'='+RD(i)+'>>31;}';
}

function dLogic(i, n) {
    return '{'+_RD(i)+'='+RS(i)+n+RT(i)+';'+_RDH(i)+'='+RSH(i)+n+RTH(i)+';}';
}

////////////////////////////
//Interpreted opcode helpers
////////////////////////////

_1964Helpers = function(){}

    //called function, not compiled
_1964Helpers.prototype.inter_mtc0 = function(r, f, rt, isDelaySlot, pc) {
        //incomplete:
        switch (f) {
            case CAUSE:
                cp0[f] &= ~0x300;
                cp0[f] |= r[rt] & 0x300;
                if(r[rt] & 0x300) {
              //      if (((r[rt] & 1)===1) && (cp0[f] & 1)===0) //possible fix over 1964cpp?
                    if((cp0[CAUSE] & cp0[STATUS] & 0x0000FF00) !== 0) {
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
                if (((r[rt] & EXL)===0) && ((cp0[f] & EXL)===1)) {
                    if((cp0[CAUSE] & cp0[STATUS] & 0x0000FF00) !== 0) {
                        cp0[f] = r[rt];
                        setException(EXC_INT, 0, pc, isDelaySlot);
                        //processException(pc, isDelaySlot);
                        return;
                    }
                }
                
                if (((r[rt] & IE)===1) && ((cp0[f] & IE)===0)) {
                    if((cp0[CAUSE] & cp0[STATUS] & 0x0000FF00) !== 0) {
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


_1964Helpers.prototype.inter_mult = function(r, i)
{
    var rs32 = r[rs(i)];
    var rt32 = r[rt(i)];
    
    var r1 = gg.math.Long.fromBits(rs32, rs32>>31);
    var r2 = gg.math.Long.fromBits(rt32, rt32>>31);
    
    var res = r1.multiply(r2);
    
    r[32]=res.getLowBits(); //lo
    h[32]=r[32]>>31;
    r[33]=res.getHighBits(); //hi
    h[33]=r[33]>>31;
}

_1964Helpers.prototype.inter_multu = function(r, i)
{
    var rs32 = r[rs(i)];
    var rt32 = r[rt(i)];

    var r1 = gg.math.Long.fromBits(rs32, 0);
    var r2 = gg.math.Long.fromBits(rt32, 0);
    
    var res = r1.multiply(r2);
    
    r[32]=res.getLowBits(); //lo
    h[32]=r[32]>>31;
    r[33]=res.getHighBits(); //hi
    h[33]=r[33]>>31;

//    alert('multu: '+r[rs(i)]+'*'+r[rt(i)]+'='+dec2hex(h[33]) +' '+dec2hex(r[33])+' '+dec2hex(h[32])+' '+dec2hex(r[32]));
}

_1964Helpers.prototype.inter_daddi = function(r, i)
{    
    var rs1 = gg.math.Long.fromBits(r[rs(i)], h[rs(i)]);
    var imm = gg.math.Long.fromBits(soffset_imm(i), soffset_imm(i)>>31);

    var rtres = rs1.add(imm);
    
    r[rt(i)]=rtres.getLowBits(); //lo
    h[rt(i)]=rtres.getHighBits(); //hi
}

_1964Helpers.prototype.inter_daddiu = function(r, i)
{    
    var rs1 = gg.math.Long.fromBits(r[rs(i)], h[rs(i)]);
    var imm = gg.math.Long.fromBits(soffset_imm(i), soffset_imm(i)>>31);

    var rtres = rs1.add(imm);
    
    r[rt(i)]=rtres.getLowBits(); //lo
    h[rt(i)]=rtres.getHighBits(); //hi
}

_1964Helpers.prototype.inter_dadd = function(r, i)
{    
    var rs1 = gg.math.Long.fromBits(r[rs(i)], h[rs(i)]);
    var rt1 = gg.math.Long.fromBits(r[rt(i)], h[rt(i)]);

    var rdres = rs1.add(rt1);
    
    r[rd(i)]=rdres.getLowBits(); //lo
    h[rd(i)]=rdres.getHighBits(); //hi
}

_1964Helpers.prototype.inter_daddu = function(r, i)
{    
    var rs1 = gg.math.Long.fromBits(r[rs(i)], h[rs(i)]);
    var rt1 = gg.math.Long.fromBits(r[rt(i)], h[rt(i)]);

    var rdres = rs1.add(rt1);
    
    r[rd(i)]=rdres.getLowBits(); //lo
    h[rd(i)]=rdres.getHighBits(); //hi
}

_1964Helpers.prototype.inter_div = function(r, i)
{
    if (r[rt(i)] === 0)
    {
        alert('divide by zero');
        return;
    }
    //todo: handle div by zero
    

    r[32]=r[rs(i)]/r[rt(i)]; //lo
    h[32]=r[32]>>31; //hi

    r[33]=r[rs(i)]%r[rt(i)]; //lo
    h[33]=r[33]>>31; //hi

//    alert('div: '+r[rs(i)]+'/'+r[rt(i)]+'='+dec2hex(h[33]) +' '+dec2hex(r[33])+' '+dec2hex(h[32])+' '+dec2hex(r[32]));

}

_1964Helpers.prototype.inter_ddiv = function(r, i)
{
    var rs32 = r[rs(i)];
    var rt32 = r[rt(i)];
    var rsh32 = h[rs(i)];
    var rth32 = h[rt(i)];

    var r1 = gg.math.Long.fromBits(rs32, rsh32);
    var r2 = gg.math.Long.fromBits(rt32, rth32);

    if (r2 === 0)
    {
        alert('divide by zero');
        return;
    }

    var res = r1.div(r2);
    var mod = r1.modulo(r2);

    r[32]=res.getLowBits(); //lo
    h[32]=res.getHighBits(); //hi

    r[33]=mod.getLowBits(); //lo
    h[33]=mod.getHighBits(); //hi

//    alert('ddiv: '+rs64+'/'+rt64+'='+dec2hex(h[33]) +' '+dec2hex(r[33])+' '+dec2hex(h[32])+' '+dec2hex(r[32]));
}


_1964Helpers.prototype.inter_divu = function(r, i)
{

    if (r[rt(i)] === 0)
    {
        alert('divide by zero');
        return;
    }
    //todo: handle div by zero
    

    r[32]=(r[rs(i)]>>>0)/(r[rt(i)]>>>0); //lo
    h[32]=0; //hi

    r[33]=(r[rs(i)]>>>0)%(r[rt(i)]>>>0); //lo
    h[33]=0; //hi

//    alert('divu: '+r[rs(i)]+'/'+r[rt(i)]+'='+dec2hex(h[33]) +' '+dec2hex(r[33])+' '+dec2hex(h[32])+' '+dec2hex(r[32]));
}

_1964Helpers.prototype.inter_dmult = function(r, i)
{
    //this is wrong..i think BigInt it will treat hex as unsigned? 
    var rs64 = '0x' + dec2hex(h[rs(i)]) + '' + dec2hex(r[rs(i)]);
    var rt64 = '0x' + dec2hex(h[rt(i)]) + '' + dec2hex(r[rt(i)]);

    var x = new BigInt(rs64);
    var y = new BigInt(rt64);

    var z = bigint_mul(x, y);
    var num = z.toStringBase(16);
    
    if (num[0] === '-')
        alert('dmult:' + num);
        
    if (num.length > 24)
    {
        var delim = num.length-24;
        h[33] = ('0x' + num.substr(0, delim)) >>> 0; // hi of HIREG
        r[33] = ('0x' + num.substr(delim, 8)) >>> 0; // lo of HIREG
        h[32] = ('0x' + num.substr(delim+8, 8)) >>> 0; // hi of LOREG
        r[32] = ('0x' + num.substr(delim+16, 8)) >>> 0; // lo of LOREG
    }
    else if (num.length > 16)
    {
        var delim=num.length-16;
        h[33] = 0; // hi of HIREG
        r[33] = ('0x' + num.substr(0, delim)) >>> 0; // lo of HIREG
        h[32] = ('0x' + num.substr(delim, 8)) >>> 0; // hi of LOREG
        r[32] = ('0x' + num.substr(delim+8, 8)) >>> 0; // lo of LOREG
    }
    else if (num.length > 8)
    {
        var delim=num.length-8;
        h[33] = 0; // hi of HIREG
        r[33] = 0; // lo of HIREG
        h[32] = ('0x' + num.substr(0, delim)) >>> 0; // hi of LOREG
        r[32] = ('0x' + num.substr(delim, 8)) >>> 0; // lo of LOREG    
    }
    else
    {
        var delim=num.length;
        h[33] = 0; // hi of HIREG
        r[33] = 0; // lo of HIREG
        h[32] = 0; // hi of LOREG
        r[32] = ('0x' + num.substr(0, delim)) >>> 0; // lo of LOREG        
    }
    
//    alert('dmult: '+rs64+'*'+rt64+'='+dec2hex(h[33]) +' '+dec2hex(r[33])+' '+dec2hex(h[32])+' '+dec2hex(r[32]));
}

_1964Helpers.prototype.inter_dmultu = function(r, i)
{
//Attax demo
    var rs64 = '0x0' + dec2hex(h[rs(i)]) + '' + dec2hex(r[rs(i)]);
    var rt64 = '0x0' + dec2hex(h[rt(i)]) + '' + dec2hex(r[rt(i)]);

    var x = new BigInt(rs64);
    var y = new BigInt(rt64);

    var z = bigint_mul(x, y);
    var num = z.toStringBase(16);
    
    if (num[0] === '-')
        alert('dmultu:' + num);
    
    if (num.length > 24)
    {
        var delim = num.length-24;
        h[33] = ('0x' + num.substr(0, delim)) >>> 0; // hi of HIREG
        r[33] = ('0x' + num.substr(delim, 8)) >>> 0; // lo of HIREG
        h[32] = ('0x' + num.substr(delim+8, 8)) >>> 0; // hi of LOREG
        r[32] = ('0x' + num.substr(delim+16, 8)) >>> 0; // lo of LOREG
    }
    else if (num.length > 16)
    {
        var delim=num.length-16;
        h[33] = 0; // hi of HIREG
        r[33] = ('0x' + num.substr(0, delim)) >>> 0; // lo of HIREG
        h[32] = ('0x' + num.substr(delim, 8)) >>> 0; // hi of LOREG
        r[32] = ('0x' + num.substr(delim+8, 8)) >>> 0; // lo of LOREG
    }
    else if (num.length > 8)
    {
        var delim=num.length-8;
        h[33] = 0; // hi of HIREG
        r[33] = 0; // lo of HIREG
        h[32] = ('0x' + num.substr(0, delim)) >>> 0; // hi of LOREG
        r[32] = ('0x' + num.substr(delim, 8)) >>> 0; // lo of LOREG    
    }
    else
    {
        var delim=num.length;
        h[33] = 0; // hi of HIREG
        r[33] = 0; // lo of HIREG
        h[32] = 0; // hi of LOREG
        r[32] = ('0x' + num.substr(0, delim)) >>> 0; // lo of LOREG        
    }
    
//    alert('dmultu: '+rs64+'*'+rt64+'='+dec2hex(h[33]) +' '+dec2hex(r[33])+' '+dec2hex(h[32])+' '+dec2hex(r[32]));
}


_1964Helpers.prototype.inter_ddivu = function(r, i)
{
    var rs64 = '0x0' + dec2hex(h[rs(i)]) + '' + dec2hex(r[rs(i)]);
    var rt64 = '0x0' + dec2hex(h[rt(i)]) + '' + dec2hex(r[rt(i)]);

    var x = new BigInt(rs64);
    var y = new BigInt(rt64);

    var z = bigint_div(x, y);
    
    if (!z)
    {
        alert('zero!!');
        r[32] = 0;
        h[32] = 0;
    }
    else
    {
        var num = z.toStringBase(16);
        
        if (num[0] === '-')
            alert('ddivu:' + num);


        if (num.length > 8)
        {
            var delim=num.length-8;
            h[32] = ('0x' + num.substr(0, delim)) >>> 0; // hi of LOREG
            r[32] = ('0x' + num.substr(delim, 8)) >>> 0; // lo of LOREG
        }
        else
        {
            var delim=num.length;
            h[32] = 0; // hi of LOREG
            r[32] = ('0x' + num.substr(0, delim)) >>> 0; // lo of LOREG        
        }
    }

//mod

    z = bigint_mod(x, y);

    num = z.toStringBase(16);

    if (num.length > 8)
    {
        var delim=num.length-8;
        h[33] = ('0x' + num.substr(0, delim)) >>> 0; // hi of LOREG
        r[33] = ('0x' + num.substr(delim, 8)) >>> 0; // lo of LOREG
    }
    else
    {
        var delim=num.length;
        h[33] = 0; // hi of LOREG
        r[33] = ('0x' + num.substr(0, delim)) >>> 0; // lo of LOREG        
    }
//    alert('ddivu: '+rs64+'/'+rt64+'='+dec2hex(h[33]) +' '+dec2hex(r[33])+' '+dec2hex(h[32])+' '+dec2hex(r[32]));

}

_1964Helpers.prototype.inter_r4300i_C_cond_fmt_s = function(instruction)
{
	var	fcFS32, fcFT32;
	var	less, equal, unordered, cond, cond0, cond1, cond2, cond3;

//	CHK_ODD_FPR_2_REG(RD_FS, RT_FT);

	cond0 = (instruction) & 0x1;
	cond1 = (instruction >> 1) & 0x1;
	cond2 = (instruction >> 2) & 0x1;
	cond3 = (instruction >> 3) & 0x1;
	fcFS32 = cp1_f[FS32ArrayView(instruction)];
	fcFT32 = cp1_f[FT32ArrayView(instruction)];

	if(isNaN(fcFS32) || isNaN(fcFT32))
	{
		less = false;
		equal = false;
		unordered = true;

		if(cond3 !== 0)
		{
			//Fire invalid operation exception
			return;
		}
	}
	else
	{
		less = (fcFS32 < fcFT32);
		equal = (fcFS32 === fcFT32);
		unordered = false;
	}

	cond = ((cond0 && unordered) || (cond1 && equal) || (cond2 && less));

    cp1Con[31] &= ~COP1_CONDITION_BIT;

	if(cond)
		cp1Con[31] |= COP1_CONDITION_BIT;
}

_1964Helpers.prototype.inter_r4300i_C_cond_fmt_d = function(instruction)
{
	var	fcFS64, fcFT64;
	var	less, equal, unordered, cond, cond0, cond1, cond2, cond3;

//	CHK_ODD_FPR_2_REG(RD_FS, RT_FT);

	cond0 = (instruction) & 0x1;
	cond1 = (instruction >> 1) & 0x1;
	cond2 = (instruction >> 2) & 0x1;
	cond3 = (instruction >> 3) & 0x1;
	fcFS64 = cp1_f64[FS64ArrayView(instruction)];
	fcFT64 = cp1_f64[FT64ArrayView(instruction)];

	if(isNaN(fcFS64) || isNaN(fcFT64))
	{
		less = false;
		equal = false;
		unordered = true;

		if(cond3 !== 0)
		{
			//Fire invalid operation exception
			return;
		}
	}
	else
	{
		less = (fcFS64 < fcFT64);
		equal = (fcFS64 === fcFT64);
		unordered = false;
	}

	cond = ((cond0 && unordered) || (cond1 && equal) || (cond2 && less));

    cp1Con[31] &= ~COP1_CONDITION_BIT;

	if(cond === true)
		cp1Con[31] |= COP1_CONDITION_BIT;
}

//print out a hex number
function dec2hex(u)
{
    var hD='0123456789ABCDEF';
    var d=u;
    var h = hD.substr(d&15,1);
    
    do
    {
        d >>= 4;
        d&=0x0fffffff;
        h=hD.substr(d&15,1)+h;
    }
    while (d > 15);

    return h;
}