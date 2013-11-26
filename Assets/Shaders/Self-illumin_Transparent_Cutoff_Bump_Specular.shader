Shader "Custom/Self-illumin_Transparent_Cutoff_Bump_Specular"
{
	Properties
	{
		_Color ("Main Color", Color) = (1,1,1,1)
		_SpecColor ("Specular Color", Color) = (0.5, 0.5, 0.5, 1)
		_Shininess ("Shininess", Range (0.01, 1)) = 0.078125
		_RimColor ("Rim Color", Color) = (1,1,1,1)
		_MainTex ("Base (RGB) Gloss (A)", 2D) = "white" {}
		_BumpMap ("Normalmap", 2D) = "bump" {}
		_LightAffectFactor("Light Affect Factor", float) = 1
		_SelfLight("Self Light Effect", float) = 1
        _RimPower ("Rim Power", float) = 3.0
		_Cutoff ("Alpha cutoff", float) = 0.1
		_EdgeLength ("Edge length", Range(3,50)) = 6
		_Smoothness ("Smoothness", Range(0,1)) = 0.5
	}
	CGINCLUDE 
	#include "Tessellation.cginc"
	//#pragma exclude_renderers flash 
		sampler2D _MainTex;
		sampler2D _BumpMap;
		fixed4 _Color;        
         float4 _RimColor;
         float _RimPower;
		half _Shininess;
		float _LightAffectFactor;
		float _SelfLight;

		struct Input
		{
			float2 uv_MainTex;
			float2 uv_BumpMap;
			float3 viewDir;
		};

		void surf (Input IN, inout SurfaceOutput o)
		{
			fixed4 tex = tex2D(_MainTex, IN.uv_MainTex);
			fixed4 c = tex * _Color;
			#ifdef SHADER_API_D3D11
			clip(c.a-0.1);	
			#endif
			o.Albedo = c.rgb;
			o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
			half rim = 1.0 - abs(dot (normalize(IN.viewDir), o.Normal));
		    o.Emission = _SelfLight*(c.rgb+_RimColor.rgb * pow (rim, _RimPower));
			//o.Emission = c.rgb * tex2D(_Illum, IN.uv_Illum).a;
			o.Gloss = tex.a;
			o.Alpha = c.a;
			o.Specular = _Shininess;
			
		}
		
		inline fixed4 LightingSimpleBlinnPhong (SurfaceOutput s, fixed3 lightDir, half3 viewDir, fixed atten)
		{
			half3 h = normalize (lightDir + viewDir);
			
			fixed diff = max (0, dot (s.Normal, lightDir));
			
			float nh = max (0, dot (s.Normal, h));
			float spec = pow (nh, s.Specular*128.0) * s.Gloss;
			
			fixed4 c;
			c.rgb = _LightAffectFactor*(s.Albedo * _LightColor0.rgb * diff + _LightColor0.rgb * _SpecColor.rgb * spec) * (atten * 2);
			c.a = s.Alpha + _LightColor0.a * _SpecColor.a * spec * atten;
			return c;
		}
		
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
		#pragma surface surf SimpleBlinnPhong vertex:vert tessellate:tessEdge tessphong:_Smoothness 	
		
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
		LOD 400
		cull off //Double Side
		AlphaTest Greater 0.1
		CGPROGRAM
		#pragma surface surf SimpleBlinnPhong
		ENDCG
	}
	//FallBack "Self-Illumin/Specular"
	FallBack "Transparent/Cutout/Bumped Specular"
	//FallBack "Diffuse"
}

