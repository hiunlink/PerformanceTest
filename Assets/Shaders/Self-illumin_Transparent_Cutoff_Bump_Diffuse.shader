Shader "Custom/Self-illumin_Transparent_Cutoff_Bump_Diffuse"
{
	Properties
	{
		_Color ("Main Color", Color) = (1,1,1,1)
		_MainTex ("Base (RGB) Gloss (A)", 2D) = "white" {}
		_Illum ("Illumin (A)", 2D) = "white" {}
		_BumpMap ("Normalmap", 2D) = "bump" {}
		_LightAffectFactor("Light Affect Factor", float) = 1
		_EmissionLM ("Emission (Lightmapper)", Float) = 0
		_Cutoff ("Alpha cutoff", float) = 0.5
		_EdgeLength ("Edge length", Range(3,50)) = 6
		_Smoothness ("Smoothness", Range(0,1)) = 0.5
	}
	
	CGINCLUDE
	sampler2D _MainTex;
	sampler2D _BumpMap;
	sampler2D _Illum;
	fixed4 _Color;
	float _LightAffectFactor;

	struct Input
	{
		float2 uv_MainTex;
		float2 uv_Illum;
		float2 uv_BumpMap;
	};

	void surf (Input IN, inout SurfaceOutput o)
	{
		fixed4 tex = tex2D(_MainTex, IN.uv_MainTex);
		fixed4 c = tex * _Color;
		#ifdef SHADER_API_D3D11
		clip(c.a-0.1);	
		#endif
		o.Albedo = c.rgb;
		o.Emission = c.rgb * tex2D(_Illum, IN.uv_Illum).a;
		o.Alpha = c.a;
		o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
	}
	
	inline fixed4 LightingSimpleLambert (SurfaceOutput s, fixed3 lightDir, fixed atten)
	{
		fixed diff = max (0, dot (s.Normal, lightDir));
		
		fixed4 c;
		c.rgb = _LightAffectFactor*s.Albedo * _LightColor0.rgb * (diff * atten * 2);
		c.a = s.Alpha;
		return c;
	}
	ENDCG
	SubShader
	{
		Tags
		{
			//"RenderType"="Opaque"
			"Queue"="AlphaTest" 
			//"IgnoreProjector"="True" 
			"RenderType"="TransparentCutout"
		}
		LOD 450
		cull off //Double Side
		AlphaTest Greater 0.1
		CGPROGRAM
		#pragma surface surf SimpleLambert vertex:vert tessellate:tessEdge tessphong:_Smoothness 
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
	SubShader
	{
		Tags
		{
			//"RenderType"="Opaque"
			"Queue"="AlphaTest" 
			//"IgnoreProjector"="True" 
			"RenderType"="TransparentCutout"
		}
		LOD 300
		cull off //Double Side
		AlphaTest Greater 0.1
		CGPROGRAM
		#pragma surface surf SimpleLambert

		ENDCG
	} 

	//FallBack "Self-Illumin/Diffuse"
	FallBack "Transparent/Cutout/Bumped Diffuse"
}
