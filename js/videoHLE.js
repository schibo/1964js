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

gRSP.projectionMtxs = new Array(RICE_MATRIX_STACK);
gRSP.modelviewMtxs = new Array(RICE_MATRIX_STACK);
//todo: allocate on-demand
for (var i=0; i<RICE_MATRIX_STACK; i++)
{
    gRSP.projectionMtxs[i] = mat4.create();
    gRSP.modelviewMtxs[i] = mat4.create();
}

gRSP.vertexMult = 10;


function processDisplayList()
{
    showFB = false;

    dlParserProcess();

//    triggerDPInterrupt(0, false);
    triggerSPInterrupt(0, false);
}

var dlistStackPointer = 0;
var dlistStack = new Array(MAX_DL_STACK_SIZE);
for (var i=0; i<MAX_DL_STACK_SIZE; i++)
    dlistStack[i] = new Object();
var texImg = new Object();
var segments = new Array(16);
for (var i=0; i<segments.length; i++)
    segments[i] = 0;

//todo: different microcodes support
var currentMicrocodeMap = microcodeMap0;

function dlParserProcess()
{
    dlistStackPointer = 0;
    dlistStack[dlistStackPointer].pc = getInt32(spMemUint8Array, spMemUint8Array, TASK_DATA_PTR);
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
    renderReset();
    //TODO: render reset
    //TODO: begin rendering
    //TODO: set viewport
    //TODO: set fill mode

    while (dlistStackPointer >= 0)
    {
        var pc = dlistStack[dlistStackPointer].pc;
        var cmd = getCommand(pc);

        dlistStack[dlistStackPointer].pc += 8;

        var func = currentMicrocodeMap[cmd];
        
        window[func](pc);

        if (dlistStackPointer >= 0 && --dlistStack[dlistStackPointer].countdown < 0 )
            dlistStackPointer--;
    }
    
    log('finished dlist');
    
    triggerSPInterrupt(0, false);
    
    //TODO: end rendering
}

function RDP_GFX_PopDL()
{
    dlistStackPointer--;
}

function RSP_RDP_Nothing(pc)
{
    log('RSP RDP NOTHING');
    dlistStackPointer--;
}

function RSP_GBI1_MoveMem(pc)
{
    var type = getGbi1Type(pc);
    var length = getGbi1Length(pc);
    var addr = getGbi1RspSegmentAddr(pc);
    
    log('movemem type=' + type + ', length=' + length + ' addr=' + addr);
}

function RSP_GBI1_SpNoop(pc)
{
    log('RSP_GBI1_SpNoop');
}

function RSP_GBI1_Reserved(pc)
{
    log('RSP_GBI1_Reserved');
}

function setProjection(mat, bPush, bReplace) 
{
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

function setWorldView(mat, bPush, bReplace) {
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

function RSP_GBI0_Mtx(pc)
{
    var seg = getGbi0DlistAddr(pc);
    var addr = getRspSegmentAddr(seg);
    log('RSP_GBI0_Mtx addr: ' + dec2hex(addr));
    loadMatrix(addr);

    if (gbi0isProjectionMatrix(pc))
        setProjection(matToLoad, gbi0PushMatrix(pc), gbi0LoadMatrix(pc));
    else
        setWorldView(matToLoad, gbi0PushMatrix(pc), gbi0LoadMatrix(pc));
}

function loadMatrix(addr)
{
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
            var hi = (rdramUint8Array[a]<<8 | rdramUint8Array[a+1])<<16>>16; 
            var lo = (rdramUint8Array[a+32]<<8 | rdramUint8Array[a+32+1])&0x0000FFFF; 
			matToLoad[k++] = ((hi<<16) | lo)/ 65536.0;
		}
	}
}

function DLParser_SetTImg(pc)
{
    texImg.format = getTexImgFormat(pc);
    texImg.size = getTexImgSize(pc);
    texImg.width = getTexImgWidth(pc);
    texImg.addr = getRspSegmentAddr(pc);
    texImg.bpl = texImg.width << texImg.size >> 1;

    log('TODO: DLParser_SetTImg');
    //log('Texture: format=' + texImg.format + ' size=' + texImg.size + ' ' + 'width=' + texImg.width + ' addr=' + texImg.addr + ' bpl=' + texImg.bpl);
}

function RSP_GBI0_Vtx(pc)
{
    var num = getGbi0NumVertices(pc) + 1;
    var v0 = getGbi0Vertex0(pc);
    var seg = getGbi0DlistAddr(pc);
    var addr = getRspSegmentAddr(seg);

    if ((v0 + num) > 80)
        num = 32 - v0;

    //TODO: check that address is valid

    processVertexData(addr, v0, num);
}

function updateCombinedMatrix() {
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

function processVertexData(addr, v0, num)
{    
    updateCombinedMatrix();
    
    for (var i=v0; i<v0+num; i++)
    {
        var a = addr + 16*(i-v0);
        vtxNonTransformed[i] = new Object();
        vtxNonTransformed[i].x = getFiddledVertexX(a);
        vtxNonTransformed[i].y = getFiddledVertexY(a);
        vtxNonTransformed[i].z = getFiddledVertexZ(a);

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

function DLParser_SetCImg(pc)
{
    log('TODO: DLParser_SetCImg');
}

//Gets new display list address
function RSP_GBI0_DL(pc)
{
    var seg = getGbi0DlistAddr(pc);
    var addr = getRspSegmentAddr(seg);
    log('dlist address = ' + dec2hex(addr));
    
    //TODO: address adjust
    
    var param = getGbi0DlistParam(pc);
    
    if (param === RSP_DLIST_PUSH)
        dlistStackPointer++;
        
    dlistStack[dlistStackPointer].pc = addr;
    dlistStack[dlistStackPointer].countdown = MAX_DL_COUNT;
}

function DLParser_SetCombine(pc)
{
    log('TODO: DLParser_SetCombine');
}

function RSP_GBI1_MoveWord(pc)
{
    log('RSP_GBI1_MoveWord');
    
    switch (getGbi0MoveWordType(pc))
	{
	case RSP_MOVE_WORD_MATRIX:
		RSP_RDP_InsertMatrix();
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
            var dwSegment = (getGbi0MoveWordOffset(pc) >> 2) & 0x0F;
            var dwBase = getGbi0MoveWordValue(pc)&0x00FFFFFF;
            segments[dwSegment] = dwBase;
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

function renderReset()
{
//	UpdateClipRectangle();
	resetMatrices();
//	SetZBias(0);
	gRSP.numVertices = 0;
	gRSP.curTile = 0;
	gRSP.fTexScaleX = 1/32.0;
	gRSP.fTexScaleY = 1/32.0;
}

function resetMatrices() {

	gRSP.projectionMtxTop = 0;
	gRSP.modelViewMtxTop = 0;
	gRSP.projectionMtxs[0] = mat4.create();
	gRSP.modelviewMtxs[0] = mat4.create();
    mat4.identity(gRSP.modelviewMtxs[0]);
    mat4.identity(gRSP.projectionMtxs[0]);

	gRSP.bMatrixIsUpdated = true;
	updateCombinedMatrix();
}

function RSP_RDP_InsertMatrix() {
	updateCombinedMatrix();
    
    gRSP.bMatrixIsUpdated = false;
	gRSP.bCombinedMatrixIsUpdated = true;
}

function DLParser_SetScissor(pc) {
    log('TODO: DLParser_SetScissor');
}

function RSP_GBI1_SetOtherModeH(pc) {
    log('TODO: DLParser_GBI1_SetOtherModeH');
}

function RSP_GBI1_SetOtherModeL(pc) {
    log('TODO: DLParser_GBI1_SetOtherModeL');
}

function RSP_GBI0_Sprite2DBase(pc) {
    log('TODO: RSP_GBI0_Sprite2DBase');
}

function RSP_GBI0_Tri4(pc) {
    log('TODO: RSP_GBI0_Tri4');
}

function RSP_GBI1_RDPHalf_Cont(pc) {
    log('TODO: RSP_GBI1_RDPHalf_Cont');
}

function RSP_GBI1_RDPHalf_2(pc) {
    log('TODO: RSP_GBI1_RDPHalf_2');
}

function RSP_GBI1_RDPHalf_1(pc) {
    log('TODO: RSP_GBI1_RDPHalf_1');
}

function RSP_GBI1_Line3D(pc) {
    log('TODO: RSP_GBI1_Line3D');
}

function RSP_GBI1_ClearGeometryMode(pc) {
    log('TODO: RSP_GBI1_ClearGeometryMode');
}

function RSP_GBI1_SetGeometryMode(pc) {
    log('TODO: RSP_GBI1_SetGeometryMode');
}

function RSP_GBI1_EndDL(pc) {
    log('RSP_GBI1_EndDL');
    RDP_GFX_PopDL();
}

function RSP_GBI1_Texture(pc) {
    log('TODO: RSP_GBI1_Texture');
}

function RSP_GBI1_PopMtx(pc) {
    log('TODO: RSP_GBI1_PopMtx');
}

function RSP_GBI1_CullDL(pc) {
    log('TODO: RSP_GBI1_CullDL');
}

function RSP_GBI1_Tri1(pc) {
    var v0 = getGbi0Tri1V0(pc) / gRSP.vertexMult;
    var v1 = getGbi0Tri1V1(pc) / gRSP.vertexMult;
    var v2 = getGbi0Tri1V2(pc) / gRSP.vertexMult;

    prepareTriangle(v0, v2, v1);
}

function RSP_GBI1_Noop(pc) {
    log('TODO: RSP_GBI1_Noop');
}

function RDP_TriFill(pc) {
    log('TODO: RDP_TriFill');
}

function RDP_TriFillZ(pc) {
    log('RDP_TriFillZ');
}

function RDP_TriTxtr(pc) {
    log('TODO: RDP_TriTxtr');
}

function RDP_TriTxtrZ(pc) {
    log('TODO: RDP_TriTxtrZ');
}

function RDP_TriShade(pc) {
    log('TODO: RDP_TriShade');
}

function RDP_TriShadeZ(pc) {
    log('TODO: RDP_TriShadeZ');
}

function RDP_TriShadeTxtr(pc) {
    log('TODO: RDP_TriShadeTxtr');
}

function RDP_TriShadeTxtrZ(pc) {
    log('TODO: RDP_TriShadeTxtrZ');
}

function DLParser_TexRect(pc) {
    log('TODO: DLParser_TexRect');
    
	var xh = getTexRectXh(pc);
	var yh = getTexRectYh(pc);
	var tileno = getTexRectTileNo(pc);
	var xl = getTexRectXl(pc);
	var yl = getTexRectYl(pc);
	var s = getTexRectS(pc);
	var t = getTexRectT(pc);
	var dsdx = getTexRectDsDx(pc);
	var dtdy = getTexRectDtDy(pc);
    
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

function DLParser_TexRectFlip(pc) {
    log('TODO: DLParser_TexRectFlip');
}

function DLParser_RDPLoadSync(pc) {
    log('TODO: DLParser_RDPLoadSync');
}

function DLParser_RDPPipeSync(pc) {
    log('TODO: DLParser_RDPPipeSync');
}

function DLParser_RDPTileSync(pc) {
    log('TODO: DLParser_RDPTileSync');
}

function DLParser_RDPFullSync(pc) {
    log('TODO: DLParser_RDPFullSync');
    triggerDPInterrupt(0, false);
        drawScene();


}

function DLParser_SetKeyGB(pc) {
    log('TODO: DLParser_SetKeyGB');
}

function DLParser_SetKeyR(pc) {
    log('TODO: DLParser_SetKeyR');
}

function DLParser_SetConvert(pc) {
    log('TODO: DLParser_SetConvert');
}

function DLParser_SetPrimDepth(pc) {
    log('TODO: DLParser_SetPrimDepth');
}

function DLParser_RDPSetOtherMode(pc) {
    log('TODO: DLParser_RDPSetOtherMode');
}

function DLParser_LoadTLut(pc) {
    log('TODO: DLParser_LoadTLut');
}

function DLParser_SetTileSize(pc) {
    log('TODO: DLParser_SetTileSize');
}

function DLParser_LoadBlock(pc) {
    log('TODO: DLParser_LoadBlock');
}

function DLParser_LoadTile(pc) {
    log('TODO: DLParser_LoadTile');
}

function DLParser_SetTile(pc) {
    log('TODO: DLParser_SetTile');
}

function DLParser_FillRect(pc) {
    log('TODO: DLParser_FillRect');
}

function DLParser_SetFillColor(pc) {
    log('TODO: DLParser_SetFillColor');
}

function DLParser_SetFogColor(pc) {
    log('TODO: DLParser_SetFogColor');
}

function DLParser_SetBlendColor(pc) {
    log('TODO: DLParser_SetBlendColor');
}

function DLParser_SetPrimColor(pc) {
    log('TODO: DLParser_SetPrimColor');
}

function DLParser_SetEnvColor(pc) {
    log('TODO: DLParser_SetEnvColor');
}

function DLParser_SetZImg(pc) {
    log('TODO: DLParser_SetZImg');
}

////////////////////////////

function prepareTriangle(dwV0, dwV1, dwV2) {
	//SP_Timing(SP_Each_Triangle);

	var textureFlag = false;//(CRender::g_pRender->IsTextureEnabled() || gRSP.ucode == 6 );

	var didSucceed = initVertex(dwV0, gRSP.numVertices, textureFlag);
	
    if (didSucceed)
        didSucceed = initVertex(dwV1, gRSP.numVertices+1, textureFlag);
	
    if (didSucceed)
        didSucceed = initVertex(dwV2, gRSP.numVertices+2, textureFlag);

    if (didSucceed)
        gRSP.numVertices += 3;
        
    return didSucceed;
}

function initVertex(dwV, vtxIndex, bTexture) {
    
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


////////////////////////////


    var triangleVertexPositionBuffer;
    var squareVertexPositionBuffer;

    function initBuffers() {
    
        triangleVertexPositionBuffer = gl.createBuffer();
        gl.bindBuffer(gl.ARRAY_BUFFER, triangleVertexPositionBuffer);
        this.trivertices = [
             0.0,  1.0,  0.0,
            -1.0, -1.0,  0.0,
             1.0, -1.0,  0.0
        ];
   //     gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(this.trivertices), gl.STATIC_DRAW);
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

function drawScene() {
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
        gl.drawArrays(gl.LINE_STRIP, 0, triangleVertexPositionBuffer.numItems);

        mvPopMatrix();

        gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(this.trivertices), gl.DYNAMIC_DRAW);
        gl.bindBuffer(gl.ARRAY_BUFFER, squareVertexPositionBuffer);
        gl.vertexAttribPointer(shaderProgram.vertexPositionAttribute, squareVertexPositionBuffer.itemSize, gl.FLOAT, false, 0, 0);
        setMatrixUniforms();
       gl.drawArrays(gl.LINE_STRIP, 0, squareVertexPositionBuffer.numItems);
       
    }