// Double Side(Cull off) + alpha test + alpha blend + self-illumin + half-light + Specular
// Nic@atlantis

Shader "Custom/DoubleSideAlphaSpecular"
{
	Properties
	{
		_Color ("Main Color", Color) = (1,1,1,1)
		_SpecColor ("Specular Color", Color) = (0.5, 0.5, 0.5, 0)
		_Shininess ("Shininess", Range (0.01, 1)) = 0.078125
		_MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
		_Cutoff ("Alpha cutoff", float) = 0.5
		_SelfLight("Self Light Effect", float) = 0.5
		_LightEff ("Light Effect", float) = 0.5
	}

	CGINCLUDE
	sampler2D _MainTex;
	fixed4 _Color;
	float _LightEff;
	float _SelfLight;
	half _Shininess;
	//fixed4 _SpecColor;
	
	struct Input {
		float2 uv_MainTex;
	};
	
	void surf (Input IN, inout SurfaceOutput o)
	{
		half4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
		o.Albedo = c.rgb;
		o.Emission = c.rgb * _SelfLight;//self-illumin
		o.Alpha = c.a;
		o.Gloss = c.a;
		o.Specular = _Shininess;
	}
	
  	fixed4 LightingBlinnPhongPro (SurfaceOutput s, fixed3 lightDir, half3 viewDir, fixed atten)
	{
		half3 h = normalize (lightDir + viewDir);
		half NdotL = max (0,dot (s.Normal, lightDir));
		fixed diff = NdotL * _LightEff + (_LightEff );
		float nh = max (0, dot (s.Normal, h));
		float spec = pow (nh, s.Specular*128.0) * s.Gloss;	
		fixed4 c;
		c.rgb = (s.Albedo * _LightColor0.rgb * diff + _LightColor0.rgb * _SpecColor.rgb * spec) * (atten * 2);
		c.a = s.Alpha + _LightColor0.a * _SpecColor.a * spec * atten;
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
		#pragma surface surf BlinnPhongPro alphatest:_Cutoff vertex:vert tessellate:tessEdge tessphong:_Smoothness 
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
		#pragma surface surf BlinnPhongPro alphatest:_Cutoff

		
		ENDCG
	}

	FallBack "Transparent/Cutout/Specular" //改成這樣才會有正確的影子
	//FallBack "Diffuse"
}
