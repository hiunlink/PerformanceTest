Shader "Custom/ReflectiveBumpedSpecular" {
Properties {
	_Color ("Main Color", Color) = (1,1,1,1)
	_SpecColor ("Specular Color", Color) = (0.5,0.5,0.5,1)
	_Shininess ("Shininess", Range (0.01, 1)) = 0.078125
	_ReflectColor ("Reflection Color", Color) = (1,1,1,0.5)
	_RimColor ("Rim Color", Color) = (1,1,1,1)
	_MainTex ("Base (RGB) RefStrGloss (A)", 2D) = "white" {}
	_Cube ("Reflection Cubemap", Cube) = "" { TexGen CubeReflect }
	_BumpMap ("Normalmap", 2D) = "bump" {}
	_MaskTex("Mask Texture(RGB)", 2D) = "white" {}
	_LightAffectFactor("Light Affect Factor", float) = 0.6
	_SelfLightFactor("Self Illumin Factor", float) = 0.8
	_RimPower ("Rim Power", float) = 3.0
	_AffectedByCamera ("Affected By Camera", float) = 1
	_Cutoff ("Alpha cutoff", float) = 0.1
	_EdgeLength ("Edge length", Range(3,50)) = 6
	_Smoothness ("Smoothness", Range(0,1)) = 0.5
}

CGINCLUDE

struct SurfaceOutputSpec {
         fixed3 Albedo;
         fixed3 Normal;
         fixed4 Mask;
         fixed3 Emission;
         half Specular;
         fixed Gloss;
         fixed Alpha;
     };


sampler2D _MainTex;
sampler2D _MaskTex;
sampler2D _BumpMap;
samplerCUBE _Cube;

fixed4 _Color;
fixed4 _ReflectColor;
half _Shininess;
float _SelfLightFactor;
float _LightAffectFactor;
float4 _RimColor;
float _RimPower;

struct Input {
	float2 uv_MainTex;
	float2 uv_MaskTex;
	float2 uv_BumpMap;
	float3 worldRefl;
	float3 viewDir;
	INTERNAL_DATA
};

void surf (Input IN, inout SurfaceOutputSpec o) {
	fixed4 tex = tex2D(_MainTex, IN.uv_MainTex);
	fixed4 c = tex * _Color;
	#ifdef SHADER_API_D3D11
	clip(c.a-0.1);	
	#endif
	fixed4 mask = tex2D(_MaskTex, IN.uv_BumpMap);
	o.Albedo = c.rgb;

	o.Gloss = tex.a;
	o.Specular = _Shininess;
	
	o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
	half rim = 1.0 - abs(dot (normalize(IN.viewDir), o.Normal));
	
	float3 worldRefl = WorldReflectionVector (IN, o.Normal);
	fixed4 reflcol = mask.a*texCUBE (_Cube, worldRefl);
	o.Mask = mask;
	reflcol *= tex.a;
	o.Emission = _SelfLightFactor*c.rgb+reflcol.rgb * _ReflectColor.rgb + _RimColor.rgb * pow (rim, _RimPower);
	o.Alpha = tex.a * _ReflectColor.a;
}

inline fixed4 LightingSimpleBlinnPhong (SurfaceOutputSpec s, fixed3 lightDir, half3 viewDir, fixed atten)
{
	half3 h = normalize (lightDir + viewDir);
	
	fixed diff = max (0, dot (s.Normal, lightDir));
	
	float nh = max (0, dot (s.Normal, h));
	float spec = s.Mask.a * pow (nh, s.Specular*128.0) * s.Gloss;
	
	fixed4 c;
	c.rgb = _LightAffectFactor*(s.Albedo * _LightColor0.rgb * diff + _LightColor0.rgb * _SpecColor.rgb * spec) * (atten * 2);
	c.a = s.Alpha + _LightColor0.a * _SpecColor.a * spec * atten;
	return c;
}
ENDCG

SubShader {
	Tags { "RenderType"="TransparentCutout" }
	LOD 450
	Cull Off
    AlphaTest Greater 0.1
	CGPROGRAM
	#pragma surface surf SimpleBlinnPhong noambient vertex:vert tessellate:tessEdge tessphong:_Smoothness 
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
	Tags { "RenderType"="TransparentCutout" }
	LOD 400
	Cull Off
    AlphaTest Greater 0.1
CGPROGRAM
#pragma surface surf SimpleBlinnPhong noambient
#pragma target 3.0

ENDCG
}


FallBack "Transparent/Cutout/Specular"
}
