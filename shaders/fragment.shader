precision mediump float;
varying highp vec4 vColor;
varying mediump vec2 vTextureCoord;
uniform sampler2D uSampler;

uniform int uWireframe;
uniform int otherModeL, otherModeH;
uniform int uCombineA0, uCombineB0, uCombineC0, uCombineD0;
uniform int uCombineA0a, uCombineB0a, uCombineC0a, uCombineD0a;
uniform int uCombineA1, uCombineB1, uCombineC1, uCombineD1;
uniform int uCombineA1a, uCombineB1a, uCombineC1a, uCombineD1a;
uniform vec4 uPrimColor, uFillColor, uEnvColor, uBlendColor;
vec4 green = vec4(0.0, 1.0, 0.0, 1.0);
vec4 a, p, b, m;

int tex0=1;
int tex1=4;
int env=5;
int blend=7;
int prim=31;
int shade=15;

//tex0=3;
//tex1=4;
//env=7;
//blend=2;
//prim=5;
//shade=6;



void main(void) {
    if (uWireframe == 1) {gl_FragColor = green; return; } 
		a = p = b = m = vec4(0.0, 0.0, 0.0, 0.0);

		if (otherModeL == 0) 
		{

	    if (uCombineA0 == tex0)
	    	p = vec4(vec4(texture2D(uSampler, vec2(vTextureCoord.st) )).rgb, 1.0);
	    if (uCombineA0a == tex0)
	    	p.a = vec4(texture2D(uSampler, vec2(vTextureCoord.st) )).a;
	    if (uCombineB0 == tex0)
	    	a = vec4(vec4(texture2D(uSampler, vec2(vTextureCoord.st) )).rgb, 1.0);
	    if (uCombineB0a == tex0)
	    	a.a = vec4(texture2D(uSampler, vec2(vTextureCoord.st) )).a;
	    if (uCombineC0 == tex0)
	    	b = vec4(vec4(texture2D(uSampler, vec2(vTextureCoord.st) )).rgb, 0.0);
	    if (uCombineC0a == tex0)
	    	b.a = vec4(texture2D(uSampler, vec2(vTextureCoord.st) )).a;
	    if (uCombineD0 == tex0)
	    	m = vec4(vec4(texture2D(uSampler, vec2(vTextureCoord.st) )).rgb, 1.0);
	    if (uCombineD0a == tex0)
	    	m.a = vec4(texture2D(uSampler, vec2(vTextureCoord.st) )).a;

	    if (uCombineA0 == tex1)
	    	p = vec4(vec4(texture2D(uSampler, vec2(vTextureCoord.st) )).rgb, 1.0);
	    if (uCombineA0a == tex1)
	    	p.a = vec4(texture2D(uSampler, vec2(vTextureCoord.st) )).a;
	    if (uCombineB0 == tex1)
	    	a = vec4(vec4(texture2D(uSampler, vec2(vTextureCoord.st) )).rgb, 1.0);
	    if (uCombineB0a == tex1)
	    	a.a = vec4(texture2D(uSampler, vec2(vTextureCoord.st) )).a;
	    if (uCombineC0 == tex1)
	    	b = vec4(vec4(texture2D(uSampler, vec2(vTextureCoord.st) )).rgb, 0.0);
	    if (uCombineC0a == tex1)
	    	b.a = vec4(texture2D(uSampler, vec2(vTextureCoord.st) )).a;
	    if (uCombineD0 == tex1)
	    	m = vec4(vec4(texture2D(uSampler, vec2(vTextureCoord.st) )).rgb, 1.0);
	    if (uCombineD0a == tex1)
	    	m.a = vec4(texture2D(uSampler, vec2(vTextureCoord.st) )).a;

	    if (uCombineA0 == env)
	    	p = vec4(uEnvColor.rgb, 1.0);
	    if (uCombineA0a == env)
	    	p.a = uEnvColor.a;
	    if (uCombineB0 == env)
	    	a = vec4(uEnvColor.rgb, 1.0);
	    if (uCombineB0a == env)
	    	a.a = uEnvColor.a;
	    if (uCombineC0 == env)
	    	b = vec4(uEnvColor.rgb, 1.0);
	    if (uCombineC0a == env)
	    	b.a = uEnvColor.a;
	    if (uCombineD0 == env)
	    	m = vec4(uEnvColor.rgb, 1.0);
	    if (uCombineD0a == env)
	    	m.a = uEnvColor.a;

	    if (uCombineA0 == blend)
	    	p = vec4(uBlendColor.rgb, 1.0);
	  //  if (uCombineA0a == blend)
	  //  	p.a = uBlendColor.a;
	    if (uCombineB0 == blend)
	    	a = vec4(uBlendColor.rgb, 1.0);
	  //  if (uCombineB0a == blend)
	  // 		a.a = uBlendColor.a;
	    if (uCombineC0 == blend)
	    	b = vec4(uBlendColor.rgb, 1.0);
	  //  if (uCombineC0a == blend)
	  //  	b.a = uBlendColor.a;
	    if (uCombineD0 == blend)
	    	m = vec4(uBlendColor.rgb, 1.0);
	  //  if (uCombineD0a == blend)
	  //  	m.a = uBlendColor.a;

	    if (uCombineA0 == shade)
	    	p = vec4(vColor.rgb, 1.0);
	    if (uCombineA0a == shade)
	    	p.a = vColor.a;
	    if (uCombineB0 == shade)
	    	a = vec4(vColor.rgb, 1.0);
	    if (uCombineB0a == shade)
	    	a.a = vColor.a;
	    if (uCombineC0 == shade)
	    	b = vec4(vColor.rgb, 1.0);
	    if (uCombineC0a == shade)
	    	b.a = vColor.a;
	    if (uCombineD0 == shade)
	    	m = vec4(vColor.rgb, 1.0);
	    if (uCombineD0a == shade)
	    	m.a = vColor.a;

	    if (uCombineA0 == prim)
	    	p = vec4(uPrimColor.rgb, 1.0);
	    if (uCombineA0a == prim)
	    	p.a = uPrimColor.a;
	    if (uCombineB0 == prim)
	    	a = vec4(uPrimColor.rgb, 1.0);
	    if (uCombineB0a == prim)
	    	a.a = uPrimColor.a;
	    if (uCombineC0 == prim)
	    	b = vec4(uPrimColor.rgb, 1.0);
	    if (uCombineC0a == prim)
	    	b.a = uPrimColor.a;
	    if (uCombineD0 == prim)
	    	m = vec4(uPrimColor.rgb, 1.0);
	    if (uCombineD0a == prim)
	    	m.a = uPrimColor.a;
			
			gl_FragColor = (a*p + b*m)/(a+b);
		}

		if (otherModeH == 0) 
		{
	    if (uCombineA1 == tex0)
	    	p = vec4(vec4(texture2D(uSampler, vec2(vTextureCoord.st) )).rgb, 1.0);
	    if (uCombineA1a == tex0)
	    	p.a = vec4(texture2D(uSampler, vec2(vTextureCoord.st) )).a;
	    if (uCombineB1 == tex0)
	    	a = vec4(vec4(texture2D(uSampler, vec2(vTextureCoord.st) )).rgb, 1.0);
	    if (uCombineB1a == tex0)
	    	a.a = vec4(texture2D(uSampler, vec2(vTextureCoord.st) )).a;
	    if (uCombineC1 == tex0)
	    	b = vec4(vec4(texture2D(uSampler, vec2(vTextureCoord.st) )).rgb, 0.0);
	    if (uCombineC1a == tex0)
	    	b.a = vec4(texture2D(uSampler, vec2(vTextureCoord.st) )).a;
	    if (uCombineD1 == tex0)
	    	m = vec4(vec4(texture2D(uSampler, vec2(vTextureCoord.st) )).rgb, 1.0);
	    if (uCombineD1a == tex0)
	    	m.a = vec4(texture2D(uSampler, vec2(vTextureCoord.st) )).a;

	    if (uCombineA1 == tex1)
	    	p = vec4(vec4(texture2D(uSampler, vec2(vTextureCoord.st) )).rgb, 1.0);
	    if (uCombineA1a == tex1)
	    	p.a = vec4(texture2D(uSampler, vec2(vTextureCoord.st) )).a;
	    if (uCombineB1 == tex1)
	    	a = vec4(vec4(texture2D(uSampler, vec2(vTextureCoord.st) )).rgb, 1.0);
	    if (uCombineB1a == tex1)
	    	a.a = vec4(texture2D(uSampler, vec2(vTextureCoord.st) )).a;
	    if (uCombineC1 == tex1)
	    	b = vec4(vec4(texture2D(uSampler, vec2(vTextureCoord.st) )).rgb, 0.0);
	    if (uCombineC1a == tex1)
	    	b.a = vec4(texture2D(uSampler, vec2(vTextureCoord.st) )).a;
	    if (uCombineD1 == tex1)
	    	m = vec4(vec4(texture2D(uSampler, vec2(vTextureCoord.st) )).rgb, 1.0);
	    if (uCombineD1a == tex1)
	    	m.a = vec4(texture2D(uSampler, vec2(vTextureCoord.st) )).a;

	    if (uCombineA1 == env)
	    	p = vec4(uEnvColor.rgb, 1.0);
	    if (uCombineA1a == env)
	    	p.a = uEnvColor.a;
	    if (uCombineB1 == env)
	    	a = vec4(uEnvColor.rgb, 1.0);
	    if (uCombineB1a == env)
	    	a.a = uEnvColor.a;
	    if (uCombineC1 == env)
	    	b = vec4(uEnvColor.rgb, 1.0);
	    if (uCombineC1a == env)
	    	b.a = uEnvColor.a;
	    if (uCombineD1 == env)
	    	m = vec4(uEnvColor.rgb, 1.0);
	    if (uCombineD1a == env)
	    	m.a = uEnvColor.a;

	    if (uCombineA1 == blend)
	    	p = vec4(uBlendColor.rgb, 1.0);
	 //   if (uCombineA1a == blend)
	 //   	p.a = uBlendColor.a;
	    if (uCombineB1 == blend)
	    	a = vec4(uBlendColor.rgb, 1.0);
	 //   if (uCombineB1a == blend)
	 //   	a.a = uBlendColor.a;
	    if (uCombineC1 == blend)
	    	b = vec4(uBlendColor.rgb, 1.0);
	 //   if (uCombineC1a == blend)
	 //   	b.a = uBlendColor.a;
	    if (uCombineD1 == blend)
	    	m = vec4(uBlendColor.rgb, 1.0);
	 //   if (uCombineD1a == blend)
	 //   	m.a = uBlendColor.a;

	    if (uCombineA1 == shade)
	    	p = vec4(vColor.rgb, 1.0);
	    if (uCombineA1a == shade)
	    	p.a = vColor.a;
	    if (uCombineB1 == shade)
	    	a = vec4(vColor.rgb, 1.0);
	    if (uCombineB1a == shade)
	    	a.a = vColor.a;
	    if (uCombineC1 == shade)
	    	b = vec4(vColor.rgb, 1.0);
	    if (uCombineC1a == shade)
	    	b.a = vColor.a;
	    if (uCombineD1 == shade)
	    	m = vec4(vColor.rgb, 1.0);
	    if (uCombineD1a == shade)
	    	m.a = vColor.a;

	    if (uCombineA1 == prim)
	    	p = vec4(uPrimColor.rgb, 1.0);
	    if (uCombineA1a == prim)
	    	p.a = uPrimColor.a;
	    if (uCombineB1 == prim)
	    	a = vec4(uPrimColor.rgb, 1.0);
	    if (uCombineB1a == prim)
	    	a.a = uPrimColor.a;
	    if (uCombineC1 == prim)
	    	b = vec4(uPrimColor.rgb, 1.0);
	    if (uCombineC1a == prim)
	    	b.a = uPrimColor.a;
	    if (uCombineD1 == prim)
	    	m = vec4(uPrimColor.rgb, 1.0);
	    if (uCombineD1a == prim)
	    	m.a = uPrimColor.a;
			
			gl_FragColor *= (a*p + b*m)/(a+b);
		}



}
