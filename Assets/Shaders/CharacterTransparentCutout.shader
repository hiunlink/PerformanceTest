// Unlit alpha-cutout shader.
// - no lighting
// - no lightmap support
// - no per-material color

Shader "Custom/CharacterTransparentCutout" {
Properties {
	_MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
	_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
	_EdgeLength ("Edge length", Range(3,50)) = 6
	_Smoothness ("Smoothness", Range(0,1)) = 0.5
}
CGINCLUDE
sampler2D _MainTex;
float Cutoff;

struct Input {
	float2 uv_MainTex;
};

void surf (Input IN, inout SurfaceOutput o)
{
	fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
	o.Albedo = c.rgb;
	o.Alpha = c.a;
}

half4 LightingNoLight(SurfaceOutput s, half3 lightDir, half atten)
{
	fixed4 c;
	c.rgb = s.Albedo;
	c.a = s.Alpha;
	return c;
}
ENDCG
SubShader {
	Tags {"Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout"}
	LOD 450
	
	CGPROGRAM
	#pragma surface surf NoLight noambient alphatest:_Cutoff addshadow vertex:vert tessellate:tessEdge tessphong:_Smoothness 
	#include "Tessellation.cginc"

	float _Smoothness;
	float _EdgeLength;
	struct appdata {
		float4 vertex : POSITION;
		float4 tangent : TANGENT;
		float3 normal : NORMAL;
		float2 texcoord : TEXCOORD0;
		float2 texcoord1 : TEXCOORD1;
	};
	float4 tessEdge (appdata v0, appdata v1, appdata v2)
	{

		if(_EdgeLength < 50)
			return UnityEdgeLengthBasedTessCull (v0.vertex, v1.vertex, v2.vertex, _EdgeLength, 0.0);
		else
			return 1;
		
	}
	void vert (inout appdata v)
	{ 
	}
	ENDCG
}
SubShader {
	Tags {"Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout"}
	LOD 100
	
	Pass {
		Lighting Off
		Alphatest Greater [_Cutoff]
		SetTexture [_MainTex] { combine texture } 
	}
}
}