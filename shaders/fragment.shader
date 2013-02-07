precision mediump float;

varying lowp vec4 vColor;
//varying mediump float v_Dot;
//varying mediump vec2 vTextureCoord;

uniform int uWireframe;

vec4 pink = vec4(1.0, 0.5, 0.5, 0.5);
vec4 green = vec4(0.5, 1.0, 0.5, 1.0);
      
      void main(void) {
         if (uWireframe == 1) {
         	// gl_FragColor = vec4(color.xyz, color.a);
			gl_FragColor = green;
         } else {
            // gl_FragColor = vColor;
			gl_FragColor = pink;
         } 
      }