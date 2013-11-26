Shader "Hidden/Image Dying Effect" {
Properties {
    _Color ("Main Color", Color) = (1,1,1,1)
	_MainTex ("Base (RGB)", 2D) = "white" {}
	_BlendTex ("Blend Texture (RGB)", 2D) = "white" {}
	_Frequency ("Flash Frequency", float) = 120.0
	_MaxAlpha ("Max Alpha", float) = 0.6
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
uniform sampler2D _BlendTex;
float _Frequency, _MaxAlpha;
fixed4 _Color;

fixed4 frag (v2f_img i) : COLOR
{
	fixed4 original = tex2D(_MainTex, i.uv);
	fixed4 bloodImg = tex2D(_BlendTex, i.uv);
	
	if(bloodImg.b > 0.8 && bloodImg.g > 0.8 && bloodImg.r > 0.8)
	    bloodImg.a = 0;
	
	float freq = (sin(_Frequency * _Time)+1)*0.5;
	float deltaAlpha = bloodImg.a*freq*_MaxAlpha;
	fixed4 output = (original*(1-deltaAlpha)+bloodImg*deltaAlpha*_Color);
	output.a = original.a;
	return output;
}
ENDCG

	}
}

Fallback "Unlit/Texture"

}