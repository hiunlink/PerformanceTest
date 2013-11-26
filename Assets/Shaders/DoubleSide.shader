Shader "Custom/DoubleSide"
{
	Properties
	{
		_Color ("Main Color", Color) = (1,1,1,1) 
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_EdgeLength ("Edge length", Range(3,50)) = 6
		_Smoothness ("Smoothness", Range(0,1)) = 0.5
	}
	
	CGINCLUDE
	sampler2D _MainTex;
		
	struct Input {
		float2 uv_MainTex;
	};
	
	void surf (Input IN, inout SurfaceOutput o)
	{
		half4 c = tex2D (_MainTex, IN.uv_MainTex);
		o.Albedo = c.rgb;
		o.Alpha = c.a;
	}
	
	half4 LightingSimpleLambert (SurfaceOutput s, half3 lightDir, half atten)
	{
		half NdotL = dot (s.Normal, lightDir);
		half diff = NdotL * 0.2 + 0.2;
		half4 c;
		c.rgb = s.Albedo * _LightColor0.rgb * (diff * atten * 2);
		c.a = s.Alpha;
		return c;
  	}
	ENDCG
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 450
		
		Cull Off
		
		CGPROGRAM
		#pragma surface surf SimpleLambert  vertex:vert tessellate:tessEdge tessphong:_Smoothness 
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
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		Cull Off
		
		CGPROGRAM
		#pragma surface surf SimpleLambert
		
		ENDCG
	} 

	FallBack "Diffuse"
}
