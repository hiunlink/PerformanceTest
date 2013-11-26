Shader "Custom/HitFlash" {
	Properties {
		_Color ("Main Color", Color) = (1,1,1,1)
		 _EdgeColor ("Rim Color", Color) = (1,1,1,1)
		_MainTex ("Texture", 2D) = "white" {}
		_EdgePower ("Rim Power", float) = 1.0
		_GlowFactor("Glow Factor", float) = 1
		_Cutoff ("Alpha cutoff", float) = 0.1
		_EdgeLength ("Edge length", Range(3,50)) = 6
		_Smoothness ("Smoothness", Range(0,1)) = 0.5
	}
	
	CGINCLUDE
	sampler2D _MainTex;
	fixed4 _Color;
	float _GlowFactor;
	 float4 _EdgeColor;
     float _EdgePower;

	struct Input {
		float2 uv_MainTex;
		 float3 viewDir;
	};
	
	 inline fixed4 LightingCustomLambert (SurfaceOutput s, fixed3 lightDir, fixed atten)
	  {
			fixed diff = max (0, dot (s.Normal, lightDir));
			
			fixed4 c;
			c.rgb = s.Albedo * _LightColor0.rgb * (diff * atten * 2);
			c.a = s.Alpha;
			return c;
	  }

	void surf (Input IN, inout SurfaceOutput o) {
		half4 tex = tex2D (_MainTex, IN.uv_MainTex);
		fixed4 c = tex * _Color;
		#ifdef SHADER_API_D3D11
		clip(c.a-0.1);	
		#endif
		o.Albedo = c.rgb;
		half rim = 1.0 - abs(dot (normalize(IN.viewDir), o.Normal));
		
		o.Emission = _EdgeColor * pow (rim, _EdgePower);
		o.Alpha = c.a;
	}
	ENDCG
	
	SubShader {
		Tags {
		 "Queue"="AlphaTest"  
         "RenderType" = "TransparentCutout"
         }
		LOD 450
		cull off
        AlphaTest Greater 0.1
		CGPROGRAM
		#pragma surface surf CustomLambert vertex:vert tessellate:tessEdge tessphong:_Smoothness 
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
		Tags {
		 "Queue"="AlphaTest"  
         "RenderType" = "TransparentCutout"
         }
		LOD 200
		cull off
        AlphaTest Greater 0.1
		CGPROGRAM
		#pragma surface surf CustomLambert

		
		ENDCG
	} 

	FallBack "Transparent/Cutout/Diffuse"
}
