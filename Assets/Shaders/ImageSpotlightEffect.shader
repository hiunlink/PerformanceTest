Shader "Hidden/Image Spotlight Effect" {
Properties {
    _Color ("Main Color", Color) = (1,1,1,1)
	_MainTex ("Base (RGB)", 2D) = "white" {}
	_RampTex ("Base (RGB)", 2D) = "grayscaleRamp" {}
	_Radius ("Radius", float) = 50.0
	_PosX ("X Pos", float) = 0.0
	_PosY ("Y Pos", float) = 0.0
	_Width ("Width", float) = 0.0
	_Height ("Height", float) = 0.0
	_ScreenWidth ("Screen Width", float) = 1024.0
	_ScreenHeight ("Screen Height", float) = 768.0
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
fixed4 _Color;
float _PosX, _PosY, _Radius, _ScreenWidth, _ScreenHeight, _Width, _Height;

fixed4 frag (v2f_img i) : COLOR
{
	fixed4 original = tex2D(_MainTex, i.uv);
	fixed grayscale = Luminance(original.rgb);
	half2 remap = half2 (grayscale + _RampOffset, .5);
	fixed4 output = (original+tex2D(_RampTex, remap))*_Color;
	output.a = original.a;

	if (_Width != 0 && (i.uv.x * _ScreenWidth < _PosX + _Width / 2) && (i.uv.x * _ScreenWidth > _PosX - _Width / 2) && (i.uv.y * _ScreenHeight < _PosY + _Height / 2) && (i.uv.y * _ScreenHeight > _PosY - _Height / 2))
	    output.rgb = original;
	
    if (_Radius != 0 && (i.uv.x * _ScreenWidth - _PosX) *(i.uv.x * _ScreenWidth - _PosX) + (i.uv.y * _ScreenHeight -_PosY)* (i.uv.y * _ScreenHeight -_PosY) < _Radius*_Radius )
        output.rgb = original;
	
	
	return output;
}
ENDCG

	}
}

Fallback "Unlit/Texture"

}