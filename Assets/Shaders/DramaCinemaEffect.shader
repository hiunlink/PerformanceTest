Shader "Drama/Cinema Effect" {
Properties {
    _Color ("Main Color", Color) = (1,1,1,1)
	_MainTex ("Base (RGB)", 2D) = "white" {}
	_RampTex ("Base (RGB)", 2D) = "grayscaleRamp" {}
}

SubShader {
	Pass {
		ZTest Always Cull Off ZWrite Off
		Fog { Mode off }

CGPROGRAM
#pragma vertex vert_img
#pragma fragment frag
#pragma fragmentoption ARB_precision_hint_fastest
#include "UnityCG.cginc"

uniform sampler2D _MainTex;
uniform sampler2D _RampTex;
uniform half _RampOffset;
uniform half _ScreenHeight;
fixed4 _Color;

fixed4 frag (v2f_img i) : COLOR
{
	fixed4 original = tex2D(_MainTex, i.uv);
	fixed grayscale = Luminance(original.rgb);
	half2 remap = half2 (grayscale + _RampOffset, .5);
	fixed4 output = (original+tex2D(_RampTex, remap))*_Color;
	if(i.uv.y*_ScreenHeight > 0.1*_ScreenHeight && i.uv.y*_ScreenHeight < 0.9*_ScreenHeight)
	    output.rgb = original;
	output.a = original.a;
	return output;
}
ENDCG

	}
}

Fallback "Unlit/Texture"

}