precision mediump float;
varying highp vec4 vColor;
varying mediump vec2 vTextureCoord;
uniform sampler2D uSampler;

uniform int uWireframe;
uniform int uCombineA0, uCombineB0, uCombineC0, uCombineD0;
uniform int uCombineA0a, uCombineB0a, uCombineC0a, uCombineD0a;
uniform int uCombineA1, uCombineB1, uCombineC1, uCombineD1;
uniform int uCombineA1a, uCombineB1a, uCombineC1a, uCombineD1a;
uniform vec4 uPrimColor, uFillColor, uEnvColor;
vec4 A0Factor, B0Factor, C0Factor, D0Factor;

void main(void) {
    //if (uWireframe == 1) {gl_FragColor = green; return; } 
	
    A0Factor = B0Factor = C0Factor = D0Factor = uPrimColor;

    if (uCombineA0 == 1 || uCombineA0 == 4)
    	A0Factor = vec4(vColor.rgb, 1.0);
    if (uCombineB0 == 1 || uCombineB0 == 4)
    	B0Factor = vec4(vColor.rgb, 1.0);
    if (uCombineC0 == 1 || uCombineC0 == 4)
    	C0Factor = vec4(vColor.rgb, 1.0);
    if (uCombineD0 == 1 || uCombineD0 == 4)
    	D0Factor = vec4(vColor.rgb, 1.0);

		gl_FragColor = vec4(((A0Factor.rgb-B0Factor.rgb)*C0Factor.rgb)+D0Factor.rgb, 1.0) * vec4(texture2D(uSampler, vec2(vTextureCoord.st) ).rgb, 1.0);
}