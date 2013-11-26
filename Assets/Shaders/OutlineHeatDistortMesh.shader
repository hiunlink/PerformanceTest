// Per pixel bumped refraction.
// Uses a normal map to distort the image behind, and
// an additional texture to tint the color.

Shader "Custom/OutlineHeatDistortMesh" {
Properties {
	_Color ("Main Color", Color) = (1,1,1,1)
	_BumpAmt  ("Distortion", range (0,128)) = 10
	_MainTex ("Tint Color (RGB)", 2D) = "black" {}
	_Cutoff ("Alpha cutoff", float) = 0.1
	_FadeRate ("Color Fade Rate", Range(0,1)) = 1.0
	_Alpha ("Alpha", float) = 1.0
}

CGINCLUDE
// Upgrade NOTE: excluded shader from DX11 and Xbox360; has structs without semantics (struct v2f members norm)
#pragma fragmentoption ARB_precision_hint_fastest
#pragma fragmentoption ARB_fog_exp2
#include "UnityCG.cginc"
float4 _Color;
sampler2D _GrabTexture : register(s0);
float4 _GrabTexture_TexelSize;
sampler2D _MainTex : register(s2);

half _FadeRate;
half _Cutoff;
struct v2f {
	float4 vertex : POSITION;
	float4 uvgrab : TEXCOORD1; 
	float4 normal : TEXCOORD0;
	float2 uvmain : TEXCOORD2;
};

uniform float _BumpAmt;


half4 frag( v2f i ) : COLOR
{
	// calculate perturbed coordinates
	half3 bump = i.normal.xyz ; // we could optimize this by just reading the x & y without reconstructing the Z
	float2 offset = (bump.xy * bump.z) * _BumpAmt * _GrabTexture_TexelSize.xy;
	i.uvgrab.xy = offset * i.uvgrab.z + i.uvgrab.xy;
	
	half4 col = tex2Dproj( _GrabTexture,float4(i.uvgrab.xy,0,i.uvgrab.w) );
	half4 tint = tex2D( _MainTex, i.uvmain ) * _Color;
	return col;
	//tint *= _FadeTime;
	//return tint;
//	if(tint.a > _Cutoff)
		return lerp(tint,col,_FadeRate);
//	else
//		return col;
}
ENDCG

Category {

	// We must be transparent, so other objects are drawn before this one.
	Tags { "Queue"="Transparent+100" "RenderType"="Transparent" "RenderEffect"="Highlighted"}
	fog{Mode off}

	SubShader {
		cull off
		// This pass grabs the screen behind the object into a texture.
		// We can access the result in the next pass as _GrabTexture

		GrabPass {							
			Name "BASE"
			Tags { "LightMode" = "Always" }
 		}
 		
 		// Main pass: Take the texture grabbed above and use the bumpmap to perturb it
 		// on to the screen
		Pass {
		
			Name "BASE"
			Tags { "LightMode" = "Always" }
			
CGPROGRAM
#pragma vertex vert
#pragma fragment frag

struct appdata_t {
	float4 vertex : POSITION;
	float2 texcoord: TEXCOORD0;
	float3 normal: NORMAL;
};

v2f vert (appdata_t v)
{
	v2f o;
	o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
	#if UNITY_UV_STARTS_AT_TOP
	float scale = -1.0;
	#else
	float scale = 1.0;
	#endif
	o.uvgrab.xy = (float2(o.vertex.x, o.vertex.y*scale) + o.vertex.w) * 0.5;
	o.uvgrab.zw = o.vertex.zw;
	//o.uvmain = MultiplyUV( UNITY_MATRIX_TEXTURE0, v.texcoord );
	o.uvmain =v.texcoord;
	o.normal.xyz = mul((float3x3)UNITY_MATRIX_MVP , v.normal);
	return o;
}
ENDCG
		}
	}

}
subshader
{
	Tags {"Queue"="Transparent+100" "RenderType"="Transparent" "LightMode" = "Always" "RenderEffect"="Highlighted"}
	Pass
	{		
		alphatest greater 0.1
		Blend srcalpha oneminussrcalpha
		//ztest off
		cull off
		SetTexture [_MainTex] {
				constantcolor(0,0,0,0.11)
                combine constant
        }

	}
}
//FallBack "Transparent/Cutout/Diffuse"
}
