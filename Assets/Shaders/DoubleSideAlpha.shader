// Double Side(Cull off) + alpha test + alpha blend + self-illumin + half-light + Diffuse
// Nic@atlantis

Shader "Custom/DoubleSidedAlpha"
{
	Properties
	{
		_Color ("Main Color", Color) = (1,1,1,1)
		_MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
		_Cutoff ("Alpha cutoff", float) = 0.5
		_SelfLight("Self Light Effect", float) = 0.5
		_LightEff ("Light Effect", float) = 0.5
		_EdgeLength ("Edge length", Range(3,50)) = 6
		_Smoothness ("Smoothness", Range(0,1)) = 0.5
	}
	CGINCLUDE
	
	
		sampler2D _MainTex;
		fixed4 _Color;
		float _LightEff;
		float _SelfLight;
		
		struct Input {
			float2 uv_MainTex;
		};
		
		void surf (Input IN, inout SurfaceOutput o)
		{
			half4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			o.Emission = c.rgb * _SelfLight;//self-illumin
			o.Alpha = c.a;
		}
      	
		half4 LightingSimpleLambert (SurfaceOutput s, half3 lightDir, half atten)
		{
			half NdotL = dot (s.Normal, lightDir);
			half diffu = NdotL * _LightEff + (_LightEff );
			half4 c;
			c.rgb = s.Albedo * _LightColor0.rgb * (diffu * atten * 2);
			c.a = s.Alpha;
			return c;
      	}


		
	ENDCG
	
	SubShader
	{
		Tags
		{
			//alpha test 
			"Queue"="AlphaTest" 
			//"IgnoreProjector"="True"
			"RenderType"="TransparentCutout"
		}
		LOD 450
		cull off //Double Side
		
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

	SubShader
	{
		Tags
		{
			//alpha test 
			"Queue"="AlphaTest" 
			//"IgnoreProjector"="True"
			"RenderType"="TransparentCutout"
		}
		LOD 200
		cull off //Double Side
		
		CGPROGRAM
		#pragma surface surf SimpleLambert alphatest:_Cutoff

		ENDCG
	}

	FallBack "Transparent/Cutout/Diffuse" //改成這樣才會有正確的影子
	//FallBack "Diffuse"
}
