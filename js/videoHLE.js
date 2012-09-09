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

/*jslint todo: true, bitwise: true*/
/*globals window, mat4, C1964jsRenderer, consts, dec2hex, Float32Array*/

var C1964jsVideoHLE = function (core, glx) {
    "use strict";
    var i;

    this.core = core; //only needed for gfxHelpers prototypes to access.
    this.gl = glx;

    //todo: make gRSP a class object.
    this.RICE_MATRIX_STACK = 60;
    this.MAX_TEXTURES = 8;
    this.vtxTransformed = [];
    this.vtxNonTransformed = [];
    this.vecProjected = [];
    this.vtxProjected5 = [];
    this.gRSP = {};
    this.matToLoad = mat4.create();
    this.gRSPworldProject = mat4.create();
    this.triangleVertexPositionBuffer = undefined;
    this.dlistStackPointer = 0;
    this.dlistStack = [];
    this.renderer = new C1964jsRenderer(this.core.settings, this.core.webGL.gl, this.core.webGL);
    this.texImg = {};
    this.segments = [];
    //todo: different microcodes support
    this.currentMicrocodeMap = this.microcodeMap0;

    for (i = 0; i < consts.MAX_DL_STACK_SIZE; i += 1) {
        this.dlistStack[i] = {};
    }

    for (i = 0; i < this.segments.length; i += 1) {
        this.segments[i] = 0;
    }

    this.gRSP.projectionMtxs = [];
    this.gRSP.modelviewMtxs = [];

    //todo: allocate on-demand
    for (i = 0; i < this.RICE_MATRIX_STACK; i += 1) {
        this.gRSP.projectionMtxs[i] = mat4.create();
        this.gRSP.modelviewMtxs[i] = mat4.create();
    }

    this.gRSP.vertexMult = 10;

    this.triangleVertexTextureCoordBuffer = undefined;
};

(function () {
    "use strict";
    C1964jsVideoHLE.prototype.processDisplayList = function () {
        if (this.core.showFB === true) {
            this.initBuffers();
            this.core.webGL.show3D();
            this.core.showFB = false;
        }

        this.core.webGL.beginDList();

        this.dlParserProcess();

        //this.core.interrupts.triggerDPInterrupt(0, false);
        this.core.interrupts.triggerSPInterrupt(0, false);
    };

    C1964jsVideoHLE.prototype.videoLog = function (msg) {
        //alert(msg);
    };

    C1964jsVideoHLE.prototype.dlParserProcess = function () {
        this.dlistStackPointer = 0;
        this.dlistStack[this.dlistStackPointer].pc = this.core.memory.getInt32(this.core.memory.spMemUint8Array, this.core.memory.spMemUint8Array, consts.TASK_DATA_PTR);
        this.dlistStack[this.dlistStackPointer].countdown = consts.MAX_DL_COUNT;

        this.vertices = [];
        this.trivertices = [];
        this.triangleVertexPositionBuffer.numItems = 0;
        this.gRSP.numVertices = 0;

        //see RSP_Parser.cpp
        //TODO: purge old textures
        //TODO: stats
        //TODO: force screen clear
        //TODO: set vi scales
        this.renderReset();
        //TODO: render reset
        //TODO: begin rendering
        //TODO: set viewport
        //TODO: set fill mode

        while (this.dlistStackPointer >= 0) {
            var func, cmd, pc = this.dlistStack[this.dlistStackPointer].pc;
            cmd = this.getCommand(pc);

            this.dlistStack[this.dlistStackPointer].pc += 8;

            func = this.currentMicrocodeMap[cmd];

            this[func](pc);

            if (this.dlistStackPointer >= 0) {
                this.dlistStack[this.dlistStackPointer].countdown -= 1;
                if (this.dlistStack[this.dlistStackPointer].countdown < 0) {
                    this.dlistStackPointer -= 1;
                }
            }
        }

        this.videoLog('finished dlist');

        this.core.interrupts.triggerSPInterrupt(0, false);

        //TODO: end rendering
    };

    C1964jsVideoHLE.prototype.RDP_GFX_PopDL = function () {
        this.dlistStackPointer -= 1;
    };

    C1964jsVideoHLE.prototype.RSP_RDP_Nothing = function (pc) {
        this.videoLog('RSP RDP NOTHING');
        this.dlistStackPointer -= 1;
    };

    C1964jsVideoHLE.prototype.RSP_GBI1_MoveMem = function (pc) {
        var addr, length, type = this.getGbi1Type(pc);
        length = this.getGbi1Length(pc);
        addr = this.getGbi1RspSegmentAddr(pc);

        this.videoLog('movemem type=' + type + ', length=' + length + ' addr=' + addr);
    };

    C1964jsVideoHLE.prototype.RSP_GBI1_SpNoop = function (pc) {
        this.videoLog('RSP_GBI1_SpNoop');
    };

    C1964jsVideoHLE.prototype.RSP_GBI1_Reserved = function (pc) {
        this.videoLog('RSP_GBI1_Reserved');
    };

    C1964jsVideoHLE.prototype.setProjection = function (mat, bPush, bReplace) {
        if (bPush) {
            if (this.gRSP.projectionMtxTop < (this.RICE_MATRIX_STACK - 1)) {
                this.gRSP.projectionMtxTop += 1;
            }

            if (bReplace) {
                // Load projection matrix
                mat4.set(mat, this.gRSP.projectionMtxs[this.gRSP.projectionMtxTop]);
            } else {
                mat4.multiply(this.gRSP.projectionMtxs[this.gRSP.projectionMtxTop - 1], mat, this.gRSP.projectionMtxs[this.gRSP.projectionMtxTop]);
            }
        } else {
            if (bReplace) {
                // Load projection matrix
                mat4.set(mat, this.gRSP.projectionMtxs[this.gRSP.projectionMtxTop]);
            } else {
                mat4.multiply(this.gRSP.projectionMtxs[this.gRSP.projectionMtxTop], mat, this.gRSP.projectionMtxs[this.gRSP.projectionMtxTop]);
            }
        }

        this.gRSP.bMatrixIsUpdated = true;
    };

    C1964jsVideoHLE.prototype.setWorldView = function (mat, bPush, bReplace) {
        if (bPush === true) {
            if (this.gRSP.modelViewMtxTop < (this.RICE_MATRIX_STACK - 1)) {
                this.gRSP.modelViewMtxTop += 1;
            }

            // We should store the current projection matrix...
            if (bReplace) {
                // Load projection matrix
                mat4.set(mat, this.gRSP.modelviewMtxs[this.gRSP.modelViewMtxTop]);
            } else { // Multiply projection matrix
                mat4.multiply(this.gRSP.modelviewMtxs[this.gRSP.modelViewMtxTop - 1], mat, this.gRSP.modelviewMtxs[this.gRSP.modelViewMtxTop]);
                //  this.gRSP.modelviewMtxs[this.gRSP.modelViewMtxTop] = mat * this.gRSP.modelviewMtxs[this.gRSP.modelViewMtxTop-1];
            }
        } else { // NoPush
            if (bReplace) {
                // Load projection matrix
                mat4.set(mat, this.gRSP.modelviewMtxs[this.gRSP.modelViewMtxTop]);
            } else {
                // Multiply projection matrix
                mat4.multiply(this.gRSP.modelviewMtxs[this.gRSP.modelViewMtxTop], mat, this.gRSP.modelviewMtxs[this.gRSP.modelViewMtxTop]);
                //this.gRSP.modelviewMtxs[this.gRSP.modelViewMtxTop] = mat * this.gRSP.modelviewMtxs[this.gRSP.modelViewMtxTop];
            }
        }

        //gRSPmodelViewTop = this.gRSP.modelviewMtxs[this.gRSP.modelViewMtxTop];
        this.gRSP.bMatrixIsUpdated = true;
    };

    C1964jsVideoHLE.prototype.RSP_GBI0_Mtx = function (pc) {
        var addr, seg = this.getGbi0DlistAddr(pc);
        addr = this.getRspSegmentAddr(seg);

        this.videoLog('RSP_GBI0_Mtx addr: ' + dec2hex(addr));
        this.loadMatrix(addr);

        if (this.gbi0isProjectionMatrix(pc)) {
            this.setProjection(this.matToLoad, this.gbi0PushMatrix(pc), this.gbi0LoadMatrix(pc));
        } else {
            this.setWorldView(this.matToLoad, this.gbi0PushMatrix(pc), this.gbi0LoadMatrix(pc));
        }
    };

    C1964jsVideoHLE.prototype.loadMatrix = function (addr) {
        //  todo: port and probably log warning message if true
        //    if (addr + 64 > g_dwRamSize)
        //    {
        //        return;
        //    }

        var i, j, lo, hi, a, k = 0;

        for (i = 0; i < 4; i += 1) {
            for (j = 0; j < 4; j += 1) {
                a = addr + (i << 3) + (j << 1);
                hi = (this.core.memory.rdramUint8Array[a] << 8 | this.core.memory.rdramUint8Array[a + 1]) << 16 >> 16;
                lo = (this.core.memory.rdramUint8Array[a + 32] << 8 | this.core.memory.rdramUint8Array[a + 32 + 1]) & 0x0000FFFF;
                this.matToLoad[k] = ((hi << 16) | lo) / 65536.0;
                k += 1;
            }
        }
    };

    //tile info.
    C1964jsVideoHLE.prototype.DLParser_SetTImg = function (pc) {
        this.texImg.format = this.getTImgFormat(pc);
        this.texImg.size = this.getTImgSize(pc);
        this.texImg.width = this.getTImgWidth(pc);
        this.texImg.addr = this.getTImgAddr(pc);
        this.texImg.bpl = this.texImg.width << this.texImg.size >> 1;

        this.texImg.changed = true; //no texture cache

        this.videoLog('TODO: DLParser_SetTImg');
        //this.videoLog('Texture: format=' + this.texImg.format + ' size=' + this.texImg.size + ' ' + 'width=' + this.texImg.width + ' addr=' + this.texImg.addr + ' bpl=' + this.texImg.bpl);
    };

    C1964jsVideoHLE.prototype.RSP_GBI0_Vtx = function (pc) {
        var v0, seg, addr, num = this.getGbi0NumVertices(pc) + 1;
        v0 = this.getGbi0Vertex0(pc);
        seg = this.getGbi0DlistAddr(pc);
        addr = this.getRspSegmentAddr(seg);

        if ((v0 + num) > 80) {
            num = 32 - v0;
        }

        //TODO: check that address is valid
        this.processVertexData(addr, v0, num);
    };

    C1964jsVideoHLE.prototype.updateCombinedMatrix = function () {
        if (this.gRSP.bMatrixIsUpdated) {
            var pmtx, vmtx = this.gRSP.modelviewMtxs[this.gRSP.modelViewMtxTop];
            pmtx = this.gRSP.projectionMtxs[this.gRSP.projectionMtxTop];

            mat4.multiply(pmtx, vmtx, this.gRSPworldProject);

            //this.gRSPworldProject = this.gRSP.modelviewMtxs[this.gRSP.modelViewMtxTop] * this.gRSP.projectionMtxs[this.gRSP.projectionMtxTop];
            this.gRSP.bMatrixIsUpdated = false;
            this.gRSP.bCombinedMatrixIsUpdated = true;
        }

        this.gRSP.bCombinedMatrixIsUpdated = false;
    };

    C1964jsVideoHLE.prototype.processVertexData = function (addr, v0, num) {
        var a, i = v0;
        this.updateCombinedMatrix();

        for (i = v0; i < v0 + num; i += 1) {
            a = addr + 16 * (i - v0);
            this.vtxNonTransformed[i] = {};
            this.vtxNonTransformed[i].x = this.getFiddledVertexX(a);
            this.vtxNonTransformed[i].y = this.getFiddledVertexY(a);
            this.vtxNonTransformed[i].z = this.getFiddledVertexZ(a);

            this.vtxTransformed[i] = {};
            this.vtxTransformed[i].x = this.vtxNonTransformed[i].x * this.gRSPworldProject[0] + this.vtxNonTransformed[i].y * this.gRSPworldProject[4] + this.vtxNonTransformed[i].z * this.gRSPworldProject[8] + this.gRSPworldProject[12];
            this.vtxTransformed[i].y = this.vtxNonTransformed[i].x * this.gRSPworldProject[1] + this.vtxNonTransformed[i].y * this.gRSPworldProject[5] + this.vtxNonTransformed[i].z * this.gRSPworldProject[9] + this.gRSPworldProject[13];
            this.vtxTransformed[i].z = this.vtxNonTransformed[i].x * this.gRSPworldProject[2] + this.vtxNonTransformed[i].y * this.gRSPworldProject[6] + this.vtxNonTransformed[i].z * this.gRSPworldProject[10] + this.gRSPworldProject[14];
            this.vtxTransformed[i].w = this.vtxNonTransformed[i].x * this.gRSPworldProject[3] + this.vtxNonTransformed[i].y * this.gRSPworldProject[7] + this.vtxNonTransformed[i].z * this.gRSPworldProject[11] + this.gRSPworldProject[15];

            this.vecProjected[i] = {};
            this.vecProjected[i].w = 1.0 / this.vtxTransformed[i].w;
            this.vecProjected[i].x = this.vtxTransformed[i].x * this.vecProjected[i].w;
            this.vecProjected[i].y = this.vtxTransformed[i].y * this.vecProjected[i].w;
            this.vecProjected[i].z = this.vtxTransformed[i].z * this.vecProjected[i].w;

            //temp
            this.vtxTransformed[i].x = this.vecProjected[i].x;
            this.vtxTransformed[i].y = this.vecProjected[i].y;
            this.vtxTransformed[i].z = this.vecProjected[i].z;
        }
    };

    C1964jsVideoHLE.prototype.DLParser_SetCImg = function (pc) {
        this.videoLog('TODO: DLParser_SetCImg');
    };

    //Gets new display list address
    C1964jsVideoHLE.prototype.RSP_GBI0_DL = function (pc) {
        var param, addr, seg = this.getGbi0DlistAddr(pc);
        addr = this.getRspSegmentAddr(seg);
        this.videoLog('dlist address = ' + dec2hex(addr));

        //TODO: address adjust

        param = this.getGbi0DlistParam(pc);

        if (param === consts.RSP_DLIST_PUSH) {
            this.dlistStackPointer += 1;
        }

        this.dlistStack[this.dlistStackPointer].pc = addr;
        this.dlistStack[this.dlistStackPointer].countdown = consts.MAX_DL_COUNT;
    };

    C1964jsVideoHLE.prototype.DLParser_SetCombine = function (pc) {
        this.videoLog('TODO: DLParser_SetCombine');
    };

    C1964jsVideoHLE.prototype.RSP_GBI1_MoveWord = function (pc) {
        this.videoLog('RSP_GBI1_MoveWord');

        switch (this.getGbi0MoveWordType(pc)) {
        case consts.RSP_MOVE_WORD_MATRIX:
            this.RSP_RDP_InsertMatrix();
            break;
        case consts.RSP_MOVE_WORD_NUMLIGHT:
            //uint32 dwNumLights = (((gfx->gbi0moveword.value)-0x80000000)/32)-1;
            //this.gRSP.ambientLightIndex = dwNumLights;
            //SetNumLights(dwNumLights);
            break;
        case consts.RSP_MOVE_WORD_CLIP:
            //switch (gfx->gbi0moveword.offset)
            //{
            //case RSP_MV_WORD_OFFSET_CLIP_RNX:
            //case RSP_MV_WORD_OFFSET_CLIP_RNY:
            //case RSP_MV_WORD_OFFSET_CLIP_RPX:
            //case RSP_MV_WORD_OFFSET_CLIP_RPY:
                //CRender::g_pRender->SetClipRatio(gfx->gbi0moveword.offset, gfx->gbi0moveword.value);
                //break;
            //default:
                //break;
            //}
            break;
        case consts.RSP_MOVE_WORD_SEGMENT:
            var dwBase, dwSegment = (this.getGbi0MoveWordOffset(pc) >> 2) & 0x0F;
            dwBase = this.getGbi0MoveWordValue(pc) & 0x00FFFFFF;
            this.segments[dwSegment] = dwBase;
            break;
        case consts.RSP_MOVE_WORD_FOG:
    //        {
    //            uint16 wMult = (uint16)(((gfx->gbi0moveword.value) >> 16) & 0xFFFF);
    //            uint16 wOff  = (uint16)(((gfx->gbi0moveword.value)      ) & 0xFFFF);

    //            float fMult = (float)(short)wMult;
    //            float fOff = (float)(short)wOff;

    //            float rng = 128000.0f / fMult;
    //            float fMin = 500.0f - (fOff*rng/256.0f);
    //            float fMax = rng + fMin;

    //            //if( fMult <= 0 || fMin > fMax || fMax < 0 || fMin > 1000 )
    //            if( fMult <= 0 || fMax < 0 )
    //            {
    //                // Hack
    //                fMin = 996;
    //                fMax = 1000;
    //                fMult = 0;
    //                fOff = 1;
    //            }

    //            SetFogMinMax(fMin, fMax, fMult, fOff);
    //        }
            break;
        case consts.RSP_MOVE_WORD_LIGHTCOL:
    /*        {
                uint32 dwLight = gfx->gbi0moveword.offset / 0x20;
                uint32 dwField = (gfx->gbi0moveword.offset & 0x7);

                switch (dwField)
                {
                case 0:
                    if (dwLight == this.gRSP.ambientLightIndex)
                    {
                        SetAmbientLight( ((gfx->gbi0moveword.value)>>8) );
                    }
                    else
                    {
                        SetLightCol(dwLight, gfx->gbi0moveword.value);
                    }
                    break;

                case 4:
                    break;

                default:
                    break;
                }
            }
    */
            break;
        case consts.RSP_MOVE_WORD_POINTS:
    /*        {
                uint32 vtx = gfx->gbi0moveword.offset/40;
                uint32 where = gfx->gbi0moveword.offset - vtx*40;
                ModifyVertexInfo(where, vtx, gfx->gbi0moveword.value);
            }
    */
            break;
        case consts.RSP_MOVE_WORD_PERSPNORM:
            break;
        default:
            break;
        }
    };

    C1964jsVideoHLE.prototype.renderReset = function () {
    //    UpdateClipRectangle();
        this.resetMatrices();
    //    SetZBias(0);
        this.gRSP.numVertices = 0;
        this.gRSP.curTile = 0;
        this.gRSP.fTexScaleX = 1 / 32.0;
        this.gRSP.fTexScaleY = 1 / 32.0;
    };

    C1964jsVideoHLE.prototype.resetMatrices  = function () {
        this.gRSP.projectionMtxTop = 0;
        this.gRSP.modelViewMtxTop = 0;
        this.gRSP.projectionMtxs[0] = mat4.create();
        this.gRSP.modelviewMtxs[0] = mat4.create();
        mat4.identity(this.gRSP.modelviewMtxs[0]);
        mat4.identity(this.gRSP.projectionMtxs[0]);

        this.gRSP.bMatrixIsUpdated = true;
        this.updateCombinedMatrix();
    };

    C1964jsVideoHLE.prototype.RSP_RDP_InsertMatrix = function () {
        this.updateCombinedMatrix();

        this.gRSP.bMatrixIsUpdated = false;
        this.gRSP.bCombinedMatrixIsUpdated = true;
    };

    C1964jsVideoHLE.prototype.DLParser_SetScissor = function (pc) {
        this.videoLog('TODO: DLParser_SetScissor');
    };

    C1964jsVideoHLE.prototype.RSP_GBI1_SetOtherModeH = function (pc) {
        this.videoLog('TODO: DLParser_GBI1_SetOtherModeH');
    };

    C1964jsVideoHLE.prototype.RSP_GBI1_SetOtherModeL = function (pc) {
        this.videoLog('TODO: DLParser_GBI1_SetOtherModeL');
    };

    C1964jsVideoHLE.prototype.RSP_GBI0_Sprite2DBase = function (pc) {
        this.videoLog('TODO: RSP_GBI0_Sprite2DBase');
    };

    C1964jsVideoHLE.prototype.RSP_GBI0_Tri4 = function (pc) {
        this.videoLog('TODO: RSP_GBI0_Tri4');
    };

    C1964jsVideoHLE.prototype.RSP_GBI1_RDPHalf_Cont = function (pc) {
        this.videoLog('TODO: RSP_GBI1_RDPHalf_Cont');
    };

    C1964jsVideoHLE.prototype.RSP_GBI1_RDPHalf_2 = function (pc) {
        this.videoLog('TODO: RSP_GBI1_RDPHalf_2');
    };

    C1964jsVideoHLE.prototype.RSP_GBI1_RDPHalf_1 = function (pc) {
        this.videoLog('TODO: RSP_GBI1_RDPHalf_1');
    };

    C1964jsVideoHLE.prototype.RSP_GBI1_Line3D = function (pc) {
        this.videoLog('TODO: RSP_GBI1_Line3D');
    };

    C1964jsVideoHLE.prototype.RSP_GBI1_ClearGeometryMode = function (pc) {
        this.videoLog('TODO: RSP_GBI1_ClearGeometryMode');
    };

    C1964jsVideoHLE.prototype.RSP_GBI1_SetGeometryMode = function (pc) {
        this.videoLog('TODO: RSP_GBI1_SetGeometryMode');
    };

    C1964jsVideoHLE.prototype.RSP_GBI1_EndDL = function (pc) {
        this.videoLog('RSP_GBI1_EndDL');
        this.RDP_GFX_PopDL();
    };

    C1964jsVideoHLE.prototype.RSP_GBI1_Texture = function (pc) {
        //hack: experimenting.

        this.texImg.format = this.getTImgFormat(pc);
        this.texImg.size = this.getTImgSize(pc);
        this.texImg.width = this.getTImgWidth(pc);
        this.texImg.addr = this.getTImgAddr(pc + 4);
        this.texImg.changed = true;
        //this.texImg.addr = 0;
        this.renderer.texTri(0, 0, 256, 256, 0, 0, 0, 0, 7, this.core.memory.rdramUint8Array, this.texImg);
        this.videoLog('TODO: RSP_GBI1_Texture');
    };

//test for dummy gray textures

    //create a heap of dummy texture mem.
    var testTextureMem = new Array(256*256*4);
    testTextureMem = new Uint8Array(testTextureMem);
    for (var k=0; k<1024*1024; k++)
        testTextureMem[k] = 128;

   C1964jsVideoHLE.prototype.RSP_GBI1_Texture = function (pc) {
        //hack: experimenting.

        this.texImg.format = this.getTImgFormat(pc+4);
        this.texImg.size = this.getTImgSize(pc+4);
        this.texImg.width = this.getTImgWidth(pc+4);
        this.texImg.addr = 0;
        this.renderer.texTri(0, 0, 256, 256, 0, 0, 0, 0, 7, testTextureMem, this.texImg);
        this.videoLog('TODO: RSP_GBI1_Texture');
    };


    C1964jsVideoHLE.prototype.RSP_GBI1_PopMtx = function (pc) {
        this.videoLog('TODO: RSP_GBI1_PopMtx');
    };

    C1964jsVideoHLE.prototype.RSP_GBI1_CullDL = function (pc) {
        this.videoLog('TODO: RSP_GBI1_CullDL');
    };

    C1964jsVideoHLE.prototype.RSP_GBI1_Tri1 = function (pc) {
        var v2, v1, v0 = this.getGbi0Tri1V0(pc) / this.gRSP.vertexMult;
        v1 = this.getGbi0Tri1V1(pc) / this.gRSP.vertexMult;
        v2 = this.getGbi0Tri1V2(pc) / this.gRSP.vertexMult;

        this.prepareTriangle(v2, v1, v0);

        this.drawScene(true, 7);

        //clear vertices for another shape
        this.vertices = [];
        this.trivertices = [];
        this.triangleVertexPositionBuffer.numItems = 0;
        this.gRSP.numVertices = 0;
    };

    C1964jsVideoHLE.prototype.RSP_GBI1_Noop = function (pc) {
        this.videoLog('TODO: RSP_GBI1_Noop');
    };

    C1964jsVideoHLE.prototype.RDP_TriFill = function (pc) {
        this.videoLog('TODO: RDP_TriFill');
    };

    C1964jsVideoHLE.prototype.RDP_TriFillZ = function (pc) {
        this.videoLog('RDP_TriFillZ');
    };

    C1964jsVideoHLE.prototype.RDP_TriTxtr = function (pc) {
        this.videoLog('TODO: RDP_TriTxtr');
    };

    C1964jsVideoHLE.prototype.RDP_TriTxtrZ = function (pc) {
        this.videoLog('TODO: RDP_TriTxtrZ');
    };

    C1964jsVideoHLE.prototype.RDP_TriShade = function (pc) {
        this.videoLog('TODO: RDP_TriShade');
    };

    C1964jsVideoHLE.prototype.RDP_TriShadeZ = function (pc) {
        this.videoLog('TODO: RDP_TriShadeZ');
    };

    C1964jsVideoHLE.prototype.RDP_TriShadeTxtr = function (pc) {
        this.videoLog('TODO: RDP_TriShadeTxtr');
    };

    C1964jsVideoHLE.prototype.RDP_TriShadeTxtrZ = function (pc) {
        this.videoLog('TODO: RDP_TriShadeTxtrZ');
    };

    C1964jsVideoHLE.prototype.DLParser_TexRect = function (pc) {
        this.videoLog('TODO: DLParser_TexRect');

        var xl, yl, s, t, dsdx, dtdy, yh, tileno, xh = this.getTexRectXh(pc);
        yh = this.getTexRectYh(pc);
        tileno = this.getTexRectTileNo(pc);
        xl = this.getTexRectXl(pc);
        yl = this.getTexRectYl(pc);
        s = this.getTexRectS(pc);
        t = this.getTexRectT(pc);
        dsdx = this.getTexRectDsDx(pc);
        dtdy = this.getTexRectDtDy(pc);

        this.renderer.texRect(xl, yl, xh, yh, s, t, dsdx, dtdy, tileno, this.core.memory.rdramUint8Array, this.texImg);

        this.dlistStack[this.dlistStackPointer].pc += 8;
    };

    C1964jsVideoHLE.prototype.DLParser_TexRectFlip = function (pc) {
        this.dlistStack[this.dlistStackPointer].pc += 8;
        this.videoLog('TODO: DLParser_TexRectFlip');
    };

    C1964jsVideoHLE.prototype.DLParser_RDPLoadSynch = function (pc) {
        this.videoLog('TODO: DLParser_RDPLoadSynch');
    };

    C1964jsVideoHLE.prototype.DLParser_RDPPipeSynch = function (pc) {
        this.videoLog('TODO: DLParser_RDPPipeSynch');
    };

    C1964jsVideoHLE.prototype.DLParser_RDPTileSynch = function (pc) {
        this.videoLog('TODO: DLParser_RDPTileSynch');
    };

    C1964jsVideoHLE.prototype.DLParser_RDPFullSynch = function (pc) {
        this.videoLog('TODO: DLParser_RDPFullSynch');
        this.core.interrupts.triggerDPInterrupt(0, false);
    };

    C1964jsVideoHLE.prototype.DLParser_SetKeyGB = function (pc) {
        this.videoLog('TODO: DLParser_SetKeyGB');
    };

    C1964jsVideoHLE.prototype.DLParser_SetKeyR = function (pc) {
        this.videoLog('TODO: DLParser_SetKeyR');
    };

    C1964jsVideoHLE.prototype.DLParser_SetConvert = function (pc) {
        this.videoLog('TODO: DLParser_SetConvert');
    };

    C1964jsVideoHLE.prototype.DLParser_SetPrimDepth = function (pc) {
        this.videoLog('TODO: DLParser_SetPrimDepth');
    };

    C1964jsVideoHLE.prototype.DLParser_RDPSetOtherMode = function (pc) {
        this.videoLog('TODO: DLParser_RDPSetOtherMode');
    };

    C1964jsVideoHLE.prototype.DLParser_LoadTLut = function (pc) {
        this.videoLog('TODO: DLParser_LoadTLut');
    };

    C1964jsVideoHLE.prototype.DLParser_SetTileSize = function (pc) {
        this.videoLog('TODO: DLParser_SetTileSize');
    };

    C1964jsVideoHLE.prototype.DLParser_LoadBlock = function (pc) {
       // this.texImg.changed = true;      
        this.videoLog('TODO: DLParser_LoadBlock');
    };

    C1964jsVideoHLE.prototype.DLParser_LoadTile = function (pc) {

        this.videoLog('TODO: DLParser_LoadTile');
    };

    C1964jsVideoHLE.prototype.DLParser_SetTile = function (pc) {
        this.videoLog('TODO: DLParser_SetTile');
    };

    C1964jsVideoHLE.prototype.DLParser_FillRect = function (pc) {
        this.videoLog('TODO: DLParser_FillRect');
    };

    C1964jsVideoHLE.prototype.DLParser_SetFillColor = function (pc) {
        this.videoLog('TODO: DLParser_SetFillColor');
    };

    C1964jsVideoHLE.prototype.DLParser_SetFogColor = function (pc) {
        this.videoLog('TODO: DLParser_SetFogColor');
    };

    C1964jsVideoHLE.prototype.DLParser_SetBlendColor = function (pc) {
        this.videoLog('TODO: DLParser_SetBlendColor');
    };

    C1964jsVideoHLE.prototype.DLParser_SetPrimColor = function (pc) {
        this.videoLog('TODO: DLParser_SetPrimColor');
    };

    C1964jsVideoHLE.prototype.DLParser_SetEnvColor = function (pc) {
        this.videoLog('TODO: DLParser_SetEnvColor');
    };

    C1964jsVideoHLE.prototype.DLParser_SetZImg = function (pc) {
        this.videoLog('TODO: DLParser_SetZImg');
    };

    C1964jsVideoHLE.prototype.prepareTriangle = function (dwV0, dwV1, dwV2) {
        //SP_Timing(SP_Each_Triangle);
        var didSucceed, textureFlag = false;//(CRender::g_pRender->IsTextureEnabled() || this.gRSP.ucode == 6 );

        didSucceed = this.initVertex(dwV0, this.gRSP.numVertices, textureFlag);

        if (didSucceed) {
            didSucceed = this.initVertex(dwV1, this.gRSP.numVertices + 1, textureFlag);
        }

        if (didSucceed) {
            didSucceed = this.initVertex(dwV2, this.gRSP.numVertices + 2, textureFlag);
        }

        if (didSucceed) {
            this.gRSP.numVertices += 3;
        }

        return didSucceed;
    };

    C1964jsVideoHLE.prototype.initVertex = function (dwV, vtxIndex, bTexture) {
        if (vtxIndex >= consts.MAX_VERTS) {
            return false;
        }

        if (this.vtxProjected5[vtxIndex] === undefined && vtxIndex < consts.MAX_VERTS) {
            this.vtxProjected5[vtxIndex] = [];
        }

        if (this.vtxTransformed[dwV] === undefined) {
            return false;
        }

        this.vtxProjected5[vtxIndex][0] = this.vtxTransformed[dwV].x;
        this.vtxProjected5[vtxIndex][1] = this.vtxTransformed[dwV].y;
        this.vtxProjected5[vtxIndex][2] = this.vtxTransformed[dwV].z;
        this.vtxProjected5[vtxIndex][3] = this.vtxTransformed[dwV].w;
        this.vtxProjected5[vtxIndex][4] = this.vecProjected[dwV].z;
        if (this.vtxTransformed[dwV].w < 0) {
            this.vtxProjected5[vtxIndex][4] = 0;
        }

        vtxIndex[vtxIndex] = vtxIndex;

        //this.gl.bindBuffer(this.gl.ARRAY_BUFFER, this.triangleVertexPositionBuffer);

        var offset = 3 * (this.triangleVertexPositionBuffer.numItems);
        this.trivertices[offset] = this.vtxProjected5[vtxIndex][0];
        this.trivertices[offset + 1] = this.vtxProjected5[vtxIndex][1];
        this.trivertices[offset + 2] = this.vtxProjected5[vtxIndex][2];

        this.triangleVertexPositionBuffer.itemSize = 3;
        this.triangleVertexPositionBuffer.numItems += 1;

        return true;
    };

    C1964jsVideoHLE.prototype.drawScene = function (useTexture, tileno) {

        this.core.webGL.switchShader(this.core.webGL.triangleShaderProgram);
        this.gl.disable(this.gl.DEPTH_TEST);
        this.gl.enable(this.gl.BLEND);
        this.gl.blendFunc(this.gl.SRC_ALPHA, this.gl.ONE);
        //simple lighting. Get the normal matrix of the model-view matrix

        this.gl.bindBuffer(this.gl.ARRAY_BUFFER, this.triangleVertexPositionBuffer);
        this.gl.bufferData(this.gl.ARRAY_BUFFER, new Float32Array(this.trivertices), this.gl.STATIC_DRAW);
        this.gl.vertexAttribPointer(this.core.webGL.triangleShaderProgram.vertexPositionAttribute, this.triangleVertexPositionBuffer.itemSize, this.gl.FLOAT, false, 0, 0);

        if (useTexture === true) {
            this.gl.bindBuffer(this.gl.ARRAY_BUFFER, this.triangleVertexTextureCoordBuffer);
            this.gl.vertexAttribPointer(this.core.webGL.triangleShaderProgram.textureCoordAttribute, this.triangleVertexTextureCoordBuffer.itemSize, this.gl.FLOAT, false, 0, 0);

            this.gl.activeTexture(this.gl.TEXTURE0);
            this.gl.bindTexture(this.gl.TEXTURE_2D, window['neheTexture' + tileno]);
            this.gl.uniform1i(this.core.webGL.triangleShaderProgram.samplerUniform, 0);
        }
      //  this.gl.bindBuffer(this.gl.ELEMENT_ARRAY_BUFFER, cubeVertexIndexBuffer);

        this.core.webGL.setMatrixUniforms(this.core.webGL.triangleShaderProgram);

        if (this.core.settings.wireframe === true) {
            this.gl.drawArrays(this.gl.LINE_LOOP, 0, this.triangleVertexPositionBuffer.numItems);
        } else {
            this.gl.drawArrays(this.gl.TRIANGLES, 0, this.triangleVertexPositionBuffer.numItems);
        }
      //  mvPopMatrix();
    };

    C1964jsVideoHLE.prototype.initBuffers = function () {
        this.triangleVertexPositionBuffer = this.gl.createBuffer();
        this.gl.bindBuffer(this.gl.ARRAY_BUFFER, this.triangleVertexPositionBuffer);
        this.trivertices = [
            0.0, 1.0, 0.0,
            -1.0, -1.0, 0.0,
            1.0, -1.0, 0.0
        ];
        this.triangleVertexPositionBuffer.itemSize = 3;
        this.triangleVertexPositionBuffer.numItems = this.trivertices.length / 3;

        this.triangleVertexTextureCoordBuffer = this.gl.createBuffer();
        this.gl.bindBuffer(this.gl.ARRAY_BUFFER, this.triangleVertexTextureCoordBuffer);
        this.triTextureCoords = [
        //front face
            1.0, 0.0, 1.0,
            0.0, 1.0, 1.0,
            0.0, 0.0, 1.0
        ];
        this.gl.bufferData(this.gl.ARRAY_BUFFER, new Float32Array(this.triTextureCoords), this.gl.STATIC_DRAW);
        this.gl.vertexAttribPointer(this.core.webGL.triangleShaderProgram.vertexPositionAttribute, this.triangleVertexPositionBuffer.itemSize, this.gl.FLOAT, false, 0, 0);
        this.triangleVertexTextureCoordBuffer.itemSize = 3;
        this.triangleVertexTextureCoordBuffer.numItems = this.triTextureCoords.length / 3;
    };
}());