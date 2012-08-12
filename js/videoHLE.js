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

var _1964jsVideoHLE = function(core) {

    this.core = core; //only needed for gfxHelpers prototypes to access.

    //todo: make gRSP a class object.
    var RICE_MATRIX_STACK = 60
    var MAX_TEXTURES = 8
    var vtxTransformed = new Array(MAX_VERTS);
    var vtxNonTransformed = new Array(MAX_VERTS);
    var vecProjected = new Array(MAX_VERTS);
    var	vtxProjected5 = new Array(1000);
    var gRSP = new Object();
    var matToLoad = mat4.create();
    var gRSPworldProject = mat4.create();
    var triangleVertexPositionBuffer;
    var squareVertexPositionBuffer;
    var dlistStackPointer = 0;
    var dlistStack = new Array(MAX_DL_STACK_SIZE);
    var texImg = new Object();
    this.segments = new Array(16);
    //todo: different microcodes support
    var currentMicrocodeMap = microcodeMap0;

    for (var i=0; i<MAX_DL_STACK_SIZE; i++)
        dlistStack[i] = new Object();
    for (var i=0; i<this.segments.length; i++)
        this.segments[i] = 0;


    gRSP.projectionMtxs = new Array(RICE_MATRIX_STACK);
    gRSP.modelviewMtxs = new Array(RICE_MATRIX_STACK);
 
    //todo: allocate on-demand
    for (var i=0; i<RICE_MATRIX_STACK; i++) {
        gRSP.projectionMtxs[i] = mat4.create();
        gRSP.modelviewMtxs[i] = mat4.create();
    }

    gRSP.vertexMult = 10;

    this.processDisplayList = function() {
        if (core.showFB === true) {
            webGLStart(this);
            show3D();
            core.showFB = false;
        }

        this.dlParserProcess();

        //core.interrupts.triggerDPInterrupt(0, false);
        core.interrupts.triggerSPInterrupt(0, false);
    }

    this.videoLog = function() {
    }

    this.dlParserProcess = function() {
        dlistStackPointer = 0;
        dlistStack[dlistStackPointer].pc = core.memory.getInt32(core.memory.spMemUint8Array, core.memory.spMemUint8Array, TASK_DATA_PTR);
        dlistStack[dlistStackPointer].countdown = MAX_DL_COUNT;

        this.vertices = [];
        this.trivertices = [];
        squareVertexPositionBuffer.numItems = 0;
        triangleVertexPositionBuffer.numItems = 0;
        gRSP.numVertices = 0;

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

        while (dlistStackPointer >= 0) {
            var pc = dlistStack[dlistStackPointer].pc;
            var cmd = this.getCommand(pc);

            dlistStack[dlistStackPointer].pc += 8;

            var func = currentMicrocodeMap[cmd];
            
            this[func](pc);

            if (dlistStackPointer >= 0 && --dlistStack[dlistStackPointer].countdown < 0 )
                dlistStackPointer--;
        }
        
        this.videoLog('finished dlist');
        
        core.interrupts.triggerSPInterrupt(0, false);
        
        //TODO: end rendering
    }

    this.RDP_GFX_PopDL = function() {
        dlistStackPointer--;
    }

    this.RSP_RDP_Nothing = function(pc) {
        this.videoLog('RSP RDP NOTHING');
        dlistStackPointer--;
    }

    this.RSP_GBI1_MoveMem = function(pc) {
        var type = this.getGbi1Type(pc);
        var length = this.getGbi1Length(pc);
        var addr = this.getGbi1RspSegmentAddr(pc);
        
        this.videoLog('movemem type=' + type + ', length=' + length + ' addr=' + addr);
    }

    this.RSP_GBI1_SpNoop = function(pc) {
        this.videoLog('RSP_GBI1_SpNoop');
    }

    this.RSP_GBI1_Reserved = function(pc) {
        this.videoLog('RSP_GBI1_Reserved');
    }

    this.setProjection = function(mat, bPush, bReplace) {
    	if (bPush) {
    		if (gRSP.projectionMtxTop >= (RICE_MATRIX_STACK-1)) {}
    		else
    			gRSP.projectionMtxTop++;

    		if (bReplace) {
    			// Load projection matrix
    			mat4.set(mat, gRSP.projectionMtxs[gRSP.projectionMtxTop]);
    		} else {
    			mat4.multiply(gRSP.projectionMtxs[gRSP.projectionMtxTop-1], mat, gRSP.projectionMtxs[gRSP.projectionMtxTop]);
    		}
    	} else {
    		if (bReplace) {
    			// Load projection matrix
    			mat4.set(mat, gRSP.projectionMtxs[gRSP.projectionMtxTop]);
    		} else {
    			mat4.multiply(gRSP.projectionMtxs[gRSP.projectionMtxTop], mat, gRSP.projectionMtxs[gRSP.projectionMtxTop]);
    		}
    	}
    	
    	gRSP.bMatrixIsUpdated = true;
    }

    this.setWorldView = function(mat, bPush, bReplace) {
    	if (bPush === true) {
    		if (gRSP.modelViewMtxTop >= (RICE_MATRIX_STACK-1)) ;
    		else
    			gRSP.modelViewMtxTop++;

    		// We should store the current projection matrix...
    		if (bReplace) {
    			// Load projection matrix
    			mat4.set(mat, gRSP.modelviewMtxs[gRSP.modelViewMtxTop]);
    		} else { // Multiply projection matrix
    			mat4.multiply(gRSP.modelviewMtxs[gRSP.modelViewMtxTop-1], mat, gRSP.modelviewMtxs[gRSP.modelViewMtxTop]);
              //  gRSP.modelviewMtxs[gRSP.modelViewMtxTop] = mat * gRSP.modelviewMtxs[gRSP.modelViewMtxTop-1];
    		}
    	} else { // NoPush
    		if (bReplace) {
    			// Load projection matrix
    			mat4.set(mat, gRSP.modelviewMtxs[gRSP.modelViewMtxTop]);
    		} else {
    			// Multiply projection matrix
    			mat4.multiply(gRSP.modelviewMtxs[gRSP.modelViewMtxTop], mat, gRSP.modelviewMtxs[gRSP.modelViewMtxTop]);
    			//gRSP.modelviewMtxs[gRSP.modelViewMtxTop] = mat * gRSP.modelviewMtxs[gRSP.modelViewMtxTop];
    		}
    	}

    	gRSPmodelViewTop = gRSP.modelviewMtxs[gRSP.modelViewMtxTop];
    	gRSP.bMatrixIsUpdated = true;
    }

    this.RSP_GBI0_Mtx = function(pc) {
        var seg = this.getGbi0DlistAddr(pc);
        var addr = this.getRspSegmentAddr(seg);
        this.videoLog('RSP_GBI0_Mtx addr: ' + dec2hex(addr));
        this.loadMatrix(addr);

        if (this.gbi0isProjectionMatrix(pc))
            this.setProjection(matToLoad, this.gbi0PushMatrix(pc), this.gbi0LoadMatrix(pc));
        else
            this.setWorldView(matToLoad, this.gbi0PushMatrix(pc), this.gbi0LoadMatrix(pc));
    }

    this.loadMatrix = function(addr) {
        //  todo: port and probably log warning message if true
        //	if (addr + 64 > g_dwRamSize)
        //	{
        //		return;
        //	}

    	var i, j, k;
        k = 0;

    	for (i=0; i<4; i++) {
    		for (j=0; j<4; j++) {
                var a = addr+(i<<3)+(j<<1);
                var hi = (core.memory.rdramUint8Array[a]<<8 | core.memory.rdramUint8Array[a+1])<<16>>16; 
                var lo = (core.memory.rdramUint8Array[a+32]<<8 | core.memory.rdramUint8Array[a+32+1])&0x0000FFFF; 
    			matToLoad[k++] = ((hi<<16) | lo)/ 65536.0;
    		}
    	}
    }

    this.DLParser_SetTImg = function(pc) {
        texImg.format = this.getTexImgFormat(pc);
        texImg.size = this.getTexImgSize(pc);
        texImg.width = this.getTexImgWidth(pc);
        texImg.addr = this.getRspSegmentAddr(pc);
        texImg.bpl = texImg.width << texImg.size >> 1;

        this.videoLog('TODO: DLParser_SetTImg');
        //this.videoLog('Texture: format=' + texImg.format + ' size=' + texImg.size + ' ' + 'width=' + texImg.width + ' addr=' + texImg.addr + ' bpl=' + texImg.bpl);
    }

    this.RSP_GBI0_Vtx = function(pc) {
        var num = this.getGbi0NumVertices(pc) + 1;
        var v0 = this.getGbi0Vertex0(pc);
        var seg = this.getGbi0DlistAddr(pc);
        var addr = this.getRspSegmentAddr(seg);

        if ((v0 + num) > 80)
            num = 32 - v0;

        //TODO: check that address is valid

        this.processVertexData(addr, v0, num);
    }

    this.updateCombinedMatrix = function() {
    	if(gRSP.bMatrixIsUpdated) {
    		var vmtx = gRSP.modelviewMtxs[gRSP.modelViewMtxTop];
            var pmtx = gRSP.projectionMtxs[gRSP.projectionMtxTop];
            
            mat4.multiply(pmtx, vmtx, gRSPworldProject); 
            
            //gRSPworldProject = gRSP.modelviewMtxs[gRSP.modelViewMtxTop] * gRSP.projectionMtxs[gRSP.projectionMtxTop];
    		gRSP.bMatrixIsUpdated = false;
    		gRSP.bCombinedMatrixIsUpdated = true;
    	}
        
        gRSP.bCombinedMatrixIsUpdated = false;
    }

    this.processVertexData = function(addr, v0, num)
    {    
        this.updateCombinedMatrix();
        
        for (var i=v0; i<v0+num; i++)
        {
            var a = addr + 16*(i-v0);
            vtxNonTransformed[i] = new Object();
            vtxNonTransformed[i].x = this.getFiddledVertexX(a);
            vtxNonTransformed[i].y = this.getFiddledVertexY(a);
            vtxNonTransformed[i].z = this.getFiddledVertexZ(a);

            vtxTransformed[i] = new Object();

            vtxTransformed[i].x = vtxNonTransformed[i].x*(gRSPworldProject[0]) + vtxNonTransformed[i].y*(gRSPworldProject[4]) + vtxNonTransformed[i].z*(gRSPworldProject[8]) + 1*(gRSPworldProject[12]);
            vtxTransformed[i].y = vtxNonTransformed[i].x*(gRSPworldProject[1]) + vtxNonTransformed[i].y*(gRSPworldProject[5]) + vtxNonTransformed[i].z*(gRSPworldProject[9]) + 1*(gRSPworldProject[13]);
            vtxTransformed[i].z = vtxNonTransformed[i].x*(gRSPworldProject[2]) + vtxNonTransformed[i].y*(gRSPworldProject[6]) + vtxNonTransformed[i].z*(gRSPworldProject[10]) + 1*(gRSPworldProject[14]);
            vtxTransformed[i].w = vtxNonTransformed[i].x*(gRSPworldProject[3]) + vtxNonTransformed[i].y*(gRSPworldProject[7]) + vtxNonTransformed[i].z*(gRSPworldProject[11]) + 1*(gRSPworldProject[15]);

        
        vecProjected[i] = new Object();
        vecProjected[i].w = 1.0 / vtxTransformed[i].w;
        vecProjected[i].x = vtxTransformed[i].x * vecProjected[i].w;
        vecProjected[i].y = vtxTransformed[i].y * vecProjected[i].w;
        vecProjected[i].z = vtxTransformed[i].z * vecProjected[i].w;

        //temp
        vtxTransformed[i].x = vecProjected[i].x;
        vtxTransformed[i].y = vecProjected[i].y;
        vtxTransformed[i].z = vecProjected[i].z;
        }
    }

    this.DLParser_SetCImg = function(pc)
    {
        this.videoLog('TODO: DLParser_SetCImg');
    }

    //Gets new display list address
    this.RSP_GBI0_DL = function(pc)
    {
        var seg = this.getGbi0DlistAddr(pc);
        var addr = this.getRspSegmentAddr(seg);
        this.videoLog('dlist address = ' + dec2hex(addr));
        
        //TODO: address adjust
        
        var param = this.getGbi0DlistParam(pc);
        
        if (param === RSP_DLIST_PUSH)
            dlistStackPointer++;
            
        dlistStack[dlistStackPointer].pc = addr;
        dlistStack[dlistStackPointer].countdown = MAX_DL_COUNT;
    }

    this.DLParser_SetCombine = function(pc)
    {
        this.videoLog('TODO: DLParser_SetCombine');
    }

    this.RSP_GBI1_MoveWord = function(pc)
    {
        this.videoLog('RSP_GBI1_MoveWord');
        
        switch (this.getGbi0MoveWordType(pc))
    	{
    	case RSP_MOVE_WORD_MATRIX:
    		this.RSP_RDP_InsertMatrix();
    		break;
    	case RSP_MOVE_WORD_NUMLIGHT:
    		{
    //			uint32 dwNumLights = (((gfx->gbi0moveword.value)-0x80000000)/32)-1;
    //			gRSP.ambientLightIndex = dwNumLights;
    //			SetNumLights(dwNumLights);
    		}
    		break;
    	case RSP_MOVE_WORD_CLIP:
    		{
    //			switch (gfx->gbi0moveword.offset)
    //			{
    //			case RSP_MV_WORD_OFFSET_CLIP_RNX:
    //			case RSP_MV_WORD_OFFSET_CLIP_RNY:
    //			case RSP_MV_WORD_OFFSET_CLIP_RPX:
    //			case RSP_MV_WORD_OFFSET_CLIP_RPY:
    //				CRender::g_pRender->SetClipRatio(gfx->gbi0moveword.offset, gfx->gbi0moveword.value);
    //				break;
    //			default:
    //				break;
    //			}
    		}
    		break;
    	case RSP_MOVE_WORD_SEGMENT:
    		{
                var dwSegment = (this.getGbi0MoveWordOffset(pc) >> 2) & 0x0F;
                var dwBase = this.getGbi0MoveWordValue(pc)&0x00FFFFFF;
                this.segments[dwSegment] = dwBase;
    		}
    		break;
    	case RSP_MOVE_WORD_FOG:
    //		{
    //			uint16 wMult = (uint16)(((gfx->gbi0moveword.value) >> 16) & 0xFFFF);
    //			uint16 wOff  = (uint16)(((gfx->gbi0moveword.value)      ) & 0xFFFF);

    //			float fMult = (float)(short)wMult;
    //			float fOff = (float)(short)wOff;

    //			float rng = 128000.0f / fMult;
    //			float fMin = 500.0f - (fOff*rng/256.0f);
    //			float fMax = rng + fMin;

    //			//if( fMult <= 0 || fMin > fMax || fMax < 0 || fMin > 1000 )
    //			if( fMult <= 0 || fMax < 0 )
    //			{
    //				// Hack
    //				fMin = 996;
    //				fMax = 1000;
    //				fMult = 0;
    //				fOff = 1;
    //			}

    //			SetFogMinMax(fMin, fMax, fMult, fOff);
    //		}
    		break;
    	case RSP_MOVE_WORD_LIGHTCOL:
    /*		{
    			uint32 dwLight = gfx->gbi0moveword.offset / 0x20;
    			uint32 dwField = (gfx->gbi0moveword.offset & 0x7);

    			switch (dwField)
    			{
    			case 0:
    				if (dwLight == gRSP.ambientLightIndex)
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
    */		break;
    	case RSP_MOVE_WORD_POINTS:
    /*		{
    			uint32 vtx = gfx->gbi0moveword.offset/40;
    			uint32 where = gfx->gbi0moveword.offset - vtx*40;
    			ModifyVertexInfo(where, vtx, gfx->gbi0moveword.value);
    		}
    */		break;
    	case RSP_MOVE_WORD_PERSPNORM:
    		break;
    	default:
    		break;
    	}
    }

    this.renderReset = function() {
    //	UpdateClipRectangle();
    	this.resetMatrices();
    //	SetZBias(0);
    	gRSP.numVertices = 0;
    	gRSP.curTile = 0;
    	gRSP.fTexScaleX = 1/32.0;
    	gRSP.fTexScaleY = 1/32.0;
    }

    this.resetMatrices  = function() {
    	gRSP.projectionMtxTop = 0;
    	gRSP.modelViewMtxTop = 0;
    	gRSP.projectionMtxs[0] = mat4.create();
    	gRSP.modelviewMtxs[0] = mat4.create();
        mat4.identity(gRSP.modelviewMtxs[0]);
        mat4.identity(gRSP.projectionMtxs[0]);

    	gRSP.bMatrixIsUpdated = true;
    	this.updateCombinedMatrix();
    }

    this.RSP_RDP_InsertMatrix = function() {
    	this.updateCombinedMatrix();
        
        gRSP.bMatrixIsUpdated = false;
    	gRSP.bCombinedMatrixIsUpdated = true;
    }

    this.DLParser_SetScissor = function(pc) {
        this.videoLog('TODO: DLParser_SetScissor');
    }

    this.RSP_GBI1_SetOtherModeH = function(pc) {
        this.videoLog('TODO: DLParser_GBI1_SetOtherModeH');
    }

    this.RSP_GBI1_SetOtherModeL = function(pc) {
        this.videoLog('TODO: DLParser_GBI1_SetOtherModeL');
    }

    this.RSP_GBI0_Sprite2DBase = function(pc) {
        this.videoLog('TODO: RSP_GBI0_Sprite2DBase');
    }

    this.RSP_GBI0_Tri4 = function(pc) {
        this.videoLog('TODO: RSP_GBI0_Tri4');
    }

    this.RSP_GBI1_RDPHalf_Cont = function(pc) {
        this.videoLog('TODO: RSP_GBI1_RDPHalf_Cont');
    }

    this.RSP_GBI1_RDPHalf_2 = function(pc) {
        this.videoLog('TODO: RSP_GBI1_RDPHalf_2');
    }

    this.RSP_GBI1_RDPHalf_1 = function(pc) {
        this.videoLog('TODO: RSP_GBI1_RDPHalf_1');
    }

    this.RSP_GBI1_Line3D = function(pc) {
        this.videoLog('TODO: RSP_GBI1_Line3D');
    }

    this.RSP_GBI1_ClearGeometryMode = function(pc) {
        this.videoLog('TODO: RSP_GBI1_ClearGeometryMode');
    }

    this.RSP_GBI1_SetGeometryMode = function(pc) {
        this.videoLog('TODO: RSP_GBI1_SetGeometryMode');
    }

    this.RSP_GBI1_EndDL = function(pc) {
        this.videoLog('RSP_GBI1_EndDL');
        this.RDP_GFX_PopDL();
    }

    this.RSP_GBI1_Texture = function(pc) {
        this.videoLog('TODO: RSP_GBI1_Texture');
    }

    this.RSP_GBI1_PopMtx = function(pc) {
        this.videoLog('TODO: RSP_GBI1_PopMtx');
    }

    this.RSP_GBI1_CullDL = function(pc) {
        this.videoLog('TODO: RSP_GBI1_CullDL');
    }

    this.RSP_GBI1_Tri1 = function(pc) {
        var v0 = this.getGbi0Tri1V0(pc) / gRSP.vertexMult;
        var v1 = this.getGbi0Tri1V1(pc) / gRSP.vertexMult;
        var v2 = this.getGbi0Tri1V2(pc) / gRSP.vertexMult;

        this.prepareTriangle(v0, v2, v1);
    }

    this.RSP_GBI1_Noop = function(pc) {
        this.videoLog('TODO: RSP_GBI1_Noop');
    }

    this.RDP_TriFill = function(pc) {
        this.videoLog('TODO: RDP_TriFill');
    }

    this.RDP_TriFillZ = function(pc) {
        this.videoLog('RDP_TriFillZ');
    }

    this.RDP_TriTxtr = function(pc) {
        this.videoLog('TODO: RDP_TriTxtr');
    }

    this.RDP_TriTxtrZ = function(pc) {
        this.videoLog('TODO: RDP_TriTxtrZ');
    }

    this.RDP_TriShade = function(pc) {
        this.videoLog('TODO: RDP_TriShade');
    }

    this.RDP_TriShadeZ = function(pc) {
        this.videoLog('TODO: RDP_TriShadeZ');
    }

    this.RDP_TriShadeTxtr = function(pc) {
        this.videoLog('TODO: RDP_TriShadeTxtr');
    }

    this.RDP_TriShadeTxtrZ = function(pc) {
        this.videoLog('TODO: RDP_TriShadeTxtrZ');
    }

    this.DLParser_TexRect = function(pc) {
        this.videoLog('TODO: DLParser_TexRect');
        
    	var xh = this.getTexRectXh(pc);
    	var yh = this.getTexRectYh(pc);
    	var tileno = this.getTexRectTileNo(pc);
    	var xl = this.getTexRectXl(pc);
    	var yl = this.getTexRectYl(pc);
    	var s = this.getTexRectS(pc);
    	var t = this.getTexRectT(pc);
    	var dsdx = this.getTexRectDsDx(pc);
    	var dtdy = this.getTexRectDtDy(pc);
        
        //temp: use 320x240. todo: ortho projection based on screen res
        xh -= 160; xh /= 160;
        xl -= 160; xl /= 160;
        yl -= 120; yl /= -120;
        yh -= 120; yh /= -120;
        
          //  gl.bindBuffer(gl.ARRAY_BUFFER, squareVertexPositionBuffer);


    //             1.0,  1.0,  0.0,
    //             1.0, -1.0,  0.0,
    //            -1.0, -1.0,  0.0,
    //            -1.0,  1.0,  0.0,
            
            var offset = 12*(squareVertexPositionBuffer.numItems/4);
            this.vertices[offset] = xh;
            this.vertices[offset+1] = yh;
            this.vertices[offset+2] = 0.0;
            this.vertices[offset+3] = xh;
            this.vertices[offset+4] = yl;
            this.vertices[offset+5] = 0.0;
            this.vertices[offset+6] = xl;
            this.vertices[offset+7] = yl;
            this.vertices[offset+8] = 0.0;
            this.vertices[offset+9] = xl;
            this.vertices[offset+10] = yh;
            this.vertices[offset+11] = 0.0;

            squareVertexPositionBuffer.itemSize = 3;
            squareVertexPositionBuffer.numItems += 4;
            
        dlistStack[dlistStackPointer].pc += 16;
    }

    this.DLParser_TexRectFlip = function(pc) {
        this.videoLog('TODO: DLParser_TexRectFlip');
    }

    this.DLParser_RDPLoadSync = function(pc) {
        this.videoLog('TODO: DLParser_RDPLoadSync');
    }

    this.DLParser_RDPPipeSync = function(pc) {
        this.videoLog('TODO: DLParser_RDPPipeSync');
    }

    this.DLParser_RDPTileSync = function(pc) {
        this.videoLog('TODO: DLParser_RDPTileSync');
    }

    this.DLParser_RDPFullSync = function(pc) {
        this.videoLog('TODO: DLParser_RDPFullSync');
        core.interrupts.triggerDPInterrupt(0, false);
        this.drawScene();
    }

    this.DLParser_SetKeyGB = function(pc) {
        this.videoLog('TODO: DLParser_SetKeyGB');
    }

    this.DLParser_SetKeyR = function(pc) {
        this.videoLog('TODO: DLParser_SetKeyR');
    }

    this.DLParser_SetConvert = function(pc) {
        this.videoLog('TODO: DLParser_SetConvert');
    }

    this.DLParser_SetPrimDepth = function(pc) {
        this.videoLog('TODO: DLParser_SetPrimDepth');
    }

    this.DLParser_RDPSetOtherMode = function(pc) {
        this.videoLog('TODO: DLParser_RDPSetOtherMode');
    }

    this.DLParser_LoadTLut = function(pc) {
        this.videoLog('TODO: DLParser_LoadTLut');
    }

    this.DLParser_SetTileSize = function(pc) {
        this.videoLog('TODO: DLParser_SetTileSize');
    }

    this.DLParser_LoadBlock = function(pc) {
        this.videoLog('TODO: DLParser_LoadBlock');
    }

    this.DLParser_LoadTile = function(pc) {
        this.videoLog('TODO: DLParser_LoadTile');
    }

    this.DLParser_SetTile = function(pc) {
        this.videoLog('TODO: DLParser_SetTile');
    }

    this.DLParser_FillRect = function(pc) {
        this.videoLog('TODO: DLParser_FillRect');
    }

    this.DLParser_SetFillColor = function(pc) {
        this.videoLog('TODO: DLParser_SetFillColor');
    }

    this.DLParser_SetFogColor = function(pc) {
        this.videoLog('TODO: DLParser_SetFogColor');
    }

    this.DLParser_SetBlendColor = function(pc) {
        this.videoLog('TODO: DLParser_SetBlendColor');
    }

    this.DLParser_SetPrimColor = function(pc) {
        this.videoLog('TODO: DLParser_SetPrimColor');
    }

    this.DLParser_SetEnvColor = function(pc) {
        this.videoLog('TODO: DLParser_SetEnvColor');
    }

    this.DLParser_SetZImg = function(pc) {
        this.videoLog('TODO: DLParser_SetZImg');
    }

    this.prepareTriangle = function(dwV0, dwV1, dwV2) {
    	//SP_Timing(SP_Each_Triangle);

    	var textureFlag = false;//(CRender::g_pRender->IsTextureEnabled() || gRSP.ucode == 6 );

    	var didSucceed = this.initVertex(dwV0, gRSP.numVertices, textureFlag);
    	
        if (didSucceed)
            didSucceed = this.initVertex(dwV1, gRSP.numVertices+1, textureFlag);
    	
        if (didSucceed)
            didSucceed = this.initVertex(dwV2, gRSP.numVertices+2, textureFlag);

        if (didSucceed)
            gRSP.numVertices += 3;
            
        return didSucceed;
    }

    this.initVertex = function(dwV, vtxIndex, bTexture) {
        
        if (vtxIndex >= MAX_VERTS)
            return false;
        
        if (vtxProjected5[vtxIndex] === undefined && vtxIndex < MAX_VERTS)
            vtxProjected5[vtxIndex] = new Array(4);
            
        if (vtxTransformed[dwV] === undefined)
            return false;
              
        vtxProjected5[vtxIndex][0] = vtxTransformed[dwV].x;
        vtxProjected5[vtxIndex][1] = vtxTransformed[dwV].y;
        vtxProjected5[vtxIndex][2] = vtxTransformed[dwV].z;
        vtxProjected5[vtxIndex][3] = vtxTransformed[dwV].w;
        vtxProjected5[vtxIndex][4] = vecProjected[dwV].z;
        if( vtxTransformed[dwV].w < 0 )	vtxProjected5[vtxIndex][4] = 0;
    		vtxIndex[vtxIndex] = vtxIndex;

            //gl.bindBuffer(gl.ARRAY_BUFFER, triangleVertexPositionBuffer);

        var offset = 3*(triangleVertexPositionBuffer.numItems);
        this.trivertices[offset] = vtxProjected5[vtxIndex][0];
        this.trivertices[offset+1] = vtxProjected5[vtxIndex][1];
        this.trivertices[offset+2] = vtxProjected5[vtxIndex][2];

        triangleVertexPositionBuffer.itemSize = 3;
        triangleVertexPositionBuffer.numItems += 1;

    //        this.vertices = [
    //             0.0,  1.0,  0.0,
    //            -1.0, -1.0,  0.0,
    //             1.0, -1.0,  0.0
    //        ];

        return true;
    }

    this.initBuffers = function() {
    
        triangleVertexPositionBuffer = gl.createBuffer();
        gl.bindBuffer(gl.ARRAY_BUFFER, triangleVertexPositionBuffer);
        this.trivertices = [
             0.0,  1.0,  0.0,
            -1.0, -1.0,  0.0,
             1.0, -1.0,  0.0
        ];
        //gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(this.trivertices), gl.STATIC_DRAW);
        triangleVertexPositionBuffer.itemSize = 3;
        triangleVertexPositionBuffer.numItems = this.trivertices.length/3;

        squareVertexPositionBuffer = gl.createBuffer();
        gl.bindBuffer(gl.ARRAY_BUFFER, squareVertexPositionBuffer);
        this.vertices = [
             1.0,  1.0,  0.0,
             1.0, -1.0,  0.0,
            -1.0, -1.0,  0.0,
            -1.0,  1.0,  0.0
        ];
     //   gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(this.vertices), gl.STATIC_DRAW);
        squareVertexPositionBuffer.itemSize = 3;
        squareVertexPositionBuffer.numItems = this.vertices.length/3;
    }

    this.drawScene = function() {
        gl.viewport(0, 0, gl.viewportWidth, gl.viewportHeight);
        gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);

        mat4.perspective(45, gl.viewportWidth / gl.viewportHeight, 0.1, 100.0, pMatrix);
        mat4.identity(mvMatrix);
        mat4.translate(mvMatrix, [0.0, 0.0, -2.4]);
        
        //simple lighting. Get the normal matrix of the model-view matrix
        mat4.set(mvMatrix, nMatrix);
        mat4.inverse(nMatrix, nMatrix);
        mat4.transpose(nMatrix);
                
        mvPushMatrix();
        mat4.translate(mvMatrix, [0.0, 0.0, -1.0]);
        
        gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(this.vertices), gl.DYNAMIC_DRAW);
        gl.bindBuffer(gl.ARRAY_BUFFER, triangleVertexPositionBuffer);
        gl.vertexAttribPointer(shaderProgram.vertexPositionAttribute, triangleVertexPositionBuffer.itemSize, gl.FLOAT, false, 0, 0);
        setMatrixUniforms();
        gl.drawArrays(gl.LINES, 0, triangleVertexPositionBuffer.numItems);

        mvPopMatrix();

        gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(this.trivertices), gl.DYNAMIC_DRAW);
        gl.bindBuffer(gl.ARRAY_BUFFER, squareVertexPositionBuffer);
        gl.vertexAttribPointer(shaderProgram.vertexPositionAttribute, squareVertexPositionBuffer.itemSize, gl.FLOAT, false, 0, 0);
        setMatrixUniforms();
       gl.drawArrays(gl.LINE_STRIP, 0, squareVertexPositionBuffer.numItems);
       
    }
}