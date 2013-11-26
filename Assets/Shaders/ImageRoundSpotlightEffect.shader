Shader "Hidden/Image Round Spotlight Effect" {
Properties {
    _Color ("Main Color", Color) = (1,1,1,1)
	_MainTex ("Base (RGB)", 2D) = "white" {}
	_RampTex ("Base (RGB)", 2D) = "grayscaleRamp" {}
	_Radius ("Radius", float) = 50.0
	_PosX ("X Pos", float) = 0.0
	_PosY ("Y Pos", float) = 0.0
	_Width ("Width", float) = 0.0
	_Height ("Height", float) = 0.0
	_Left ("Left", float) = 0.0
	_Right ("Right", float) = 0.0
	_Upper ("Upper", float) = 0.0
	_Bottom ("Bottom", float) = 0.0
	_InnerLeft ("InnerLeft", float) = 0.0
	_InnerRight ("InnerRight", float) = 0.0
	_InnerUpper ("InnerUpper", float) = 0.0
	_InnerBottom ("InnerBottom", float) = 0.0
	_RoundRadius ("RpundRadius", float) = 0.0
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
#pragma target 3.0
#include "UnityCG.cginc"

uniform sampler2D _MainTex;
uniform sampler2D _RampTex;
uniform half _RampOffset;
fixed4 _Color;
float _PosX, _PosY, _Radius, _ScreenWidth, _ScreenHeight, _Width, _Height, _Left, _Right, _Upper, _Bottom, _RoundRadius, _InnerLeft, _InnerRight, _InnerUpper, _InnerBottom;

fixed4 frag (v2f_img i) : COLOR
{
	fixed4 original = tex2D(_MainTex, i.uv);
	fixed grayscale = Luminance(original.rgb);
	half2 remap = half2 (grayscale + _RampOffset, .5);
	fixed4 output = (original+tex2D(_RampTex, remap))*_Color;
	output.a = original.a;

	bool isOriginalColor = false;
	float2 screenPos = float2(i.uv.x * _ScreenWidth, i.uv.y * _ScreenHeight);
	if ((screenPos.x < _Right) && (screenPos.x > _Left) && (screenPos.y < _Upper) && (screenPos.y > _Bottom))
		isOriginalColor = true;
	
	// UpperLeft Corner
	if (screenPos.x < _InnerLeft && screenPos.y > _InnerUpper)
		isOriginalColor = distance(screenPos, float2(_InnerLeft, _InnerUpper)) < _RoundRadius;			
	// BottomLeft Corner
	if (screenPos.x < _InnerLeft && screenPos.y < _InnerBottom)
		isOriginalColor = distance(screenPos, float2(_InnerLeft, _InnerBottom)) < _RoundRadius;
	// UpperRight Corner
	if (screenPos.x > _InnerRight && screenPos.y > _InnerUpper)
		isOriginalColor = distance(screenPos, float2(_InnerRight, _InnerUpper)) < _RoundRadius;
	// BottomRight Corner
	if (screenPos.x > _InnerRight && screenPos.y < _InnerBottom )
		isOriginalColor = distance(screenPos, float2(_InnerRight, _InnerBottom)) < _RoundRadius;	
	
    //if (_Radius != 0 && (i.uv.x * _ScreenWidth - _PosX) *(i.uv.x * _ScreenWidth - _PosX) + (i.uv.y * _ScreenHeight -_PosY)* (i.uv.y * _ScreenHeight -_PosY) < _Radius*_Radius )
    //    output.rgb = original;
    if (isOriginalColor)
   		output = original;
   	return output;
}
ENDCG

	}
}

Fallback "Hidden/Image Spotlight Effect"

}