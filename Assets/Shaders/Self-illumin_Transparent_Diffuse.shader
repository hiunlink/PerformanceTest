// Self-illumin + Transparent + Specular

Shader "Custom/Self-illumin_Transparent_Diffuse"
{
	Properties {
		_Color ("Main Color", Color) = (1,1,1,1)
		_MainTex ("Base (RGB) TransGloss (A)", 2D) = "white" {}
		_LightAffectFactor("Light Affect Factor", float) = 1
		_SelfLight("Self Light Effect", float) = 1
		_Cutoff ("Alpha cutoff", float) = 0.1
		_EdgeLength ("Edge length", Range(3,50)) = 6
		_Smoothness ("Smoothness", Range(0,1)) = 0.5
	}
	CGINCLUDE
	
	sampler2D _MainTex;
	fixed4 _Color;
	float _SelfLight;
	float _LightAffectFactor;
	
	struct Input {
		float2 uv_MainTex;
	};
	
	void surf (Input IN, inout SurfaceOutput o) {
		fixed4 tex = tex2D(_MainTex, IN.uv_MainTex);
		o.Albedo = tex.rgb * _Color.rgb;
		o.Alpha = tex.a * _Color.a;
		//o.Emission = tex.rgb *  _SelfLight;//self-illumin
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
	
	
	SubShader {
		Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
		LOD 450
		cull off
		Blend SrcAlpha OneMinusSrcAlpha
		CGPROGRAM
		#pragma surface surf SimpleLambert alphatest:_Cutoff vertex:vert tessellate:tessEdge tessphong:_Smoothness 
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
		Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
		LOD 300
		cull off
		Blend SrcAlpha OneMinusSrcAlpha
	CGPROGRAM
	#pragma surface surf SimpleLambert alphatest:_Cutoff
	
	ENDCG
	}

	
	FallBack "Transparent/VertexLit"
}
