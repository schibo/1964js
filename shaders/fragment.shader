precision mediump float;
// 4
varying highp vec4 vColor;
varying mediump vec2 vTextureCoord;
uniform sampler2D uSampler;

uniform int uWireframe;
uniform int uCombineA0, uCombineB0, uCombineC0, uCombineD0;
uniform int uCombineA0a, uCombineB0a, uCombineC0a, uCombineD0a;
uniform int uCombineA1, uCombineB1, uCombineC1, uCombineD1;
uniform int uCombineA1a, uCombineB1a, uCombineC1a, uCombineD1a;
uniform vec4 uPrimColor;

vec4 pink = vec4(1.0, 0.5, 0.5, 0.5);
vec4 green = vec4(0.5, 1.0, 0.5, 1.0);
vec4 blue = vec4(0.5, 0.5, 1.0, 0.5);
vec4 gray = vec4(0.1, 0.1, 0.1, 1.0);
vec4 A0Factor, B0Factor, C0Factor, D0Factor;
      
      void main(void) {
         if (uWireframe == 1) {	gl_FragColor = green; return; } 
		 
		if (uCombineA0 == 1) {
			A0Factor = vec4(texture2D(uSampler, vec2(vTextureCoord.st) ).rgba);
		} else if (uCombineA0 == 3) {
			A0Factor = vec4(uPrimColor.rgba);
		} else if (uCombineA0 == 2) {
			A0Factor = pink;		
		} else if (uCombineA0 == 4) {
			A0Factor = gray;
		} else {
			A0Factor = gray;
		}
		if (uCombineB0 == 1) {
			B0Factor = vec4(texture2D(uSampler, vec2(vTextureCoord.st) ).rgba);
		} else if (uCombineB0 == 3) {
			B0Factor = vec4(uPrimColor.rgba);
		} else if (uCombineB0 == 2) {
			B0Factor = pink;		
		} else if (uCombineB0 == 4) {
			B0Factor = gray;
		} else {
			B0Factor = gray;
		}
		if (uCombineC0 == 1) {
			C0Factor = vec4(texture2D(uSampler, vec2(vTextureCoord.st) ).rgba);
		} else if (uCombineC0 == 3) {
			C0Factor = vec4(uPrimColor.rgba);
		} else if (uCombineC0 == 2) {
			C0Factor = pink;		
		} else if (uCombineC0 == 4) {
			C0Factor = gray;		
		} else {
			C0Factor = gray;
		}
		if (uCombineD0 == 1) {
			D0Factor = vec4(texture2D(uSampler, vec2(vTextureCoord.st) ).rgba);
		} else if (uCombineD0 == 3) {
			D0Factor = vec4(uPrimColor.rgba);
		} else if (uCombineD0 == 2) {
			D0Factor = pink;		
		} else if (uCombineD0 == 4) {
			D0Factor = gray;		
		} else {
		    D0Factor = gray;
		}
		
		gl_FragColor = vec4(((A0Factor.rgba-B0Factor.rgba)*C0Factor.rgba)+D0Factor.rgba);
		// gl_FragColor = blue;
		// gl_FragColor = uPrimColor;
       
      }