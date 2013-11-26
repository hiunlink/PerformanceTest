Shader "Custom/BossFlash" {
	Properties {
		_Color ("Main Color", Color) = (1,1,1,1)
		 _RimColor ("Rim Color", Color) = (1,1,1,1)
		_MainTex ("Texture", 2D) = "white" {}
		_LightAffectFactor("Light Affect Factor", float) = 1
		_SelfLightFactor("Self Illumin Factor", float) = 0.8
		_RimPower ("Rim Power", float) = 1.0
		_Frequency ("Flash Frequency", float) = 25.0
		_AffectedByCameraFac ("Affected By Camera (0,1)", float) = 1
		_GlowFactor("Glow Factor", float) = 1
		_Cutoff("Alpha cutoff", float) = 0.1
		_EdgeLength ("Edge length", Range(3,50)) = 6
		_Smoothness ("Smoothness", Range(0,1)) = 0.5
	}
	CGINCLUDE
		sampler2D _MainTex;
		fixed4 _Color;
		float _SelfLightFactor, _LightAffectFactor;
		float _GlowFactor;
		 float4 _RimColor;
         float _RimPower;
         float _Frequency;

		struct Input {
			float2 uv_MainTex;
			 float3 viewDir;
		};
		
		 inline fixed4 LightingCustomLambert (SurfaceOutput s, fixed3 lightDir, fixed atten)
		  {
				fixed diff = max (0, dot (s.Normal, lightDir));
				
				fixed4 c;
				c.rgb = _LightAffectFactor*s.Albedo * _LightColor0.rgb * (diff * atten * 2);
				c.a = s.Alpha;
				return c;
		  }

		void surf (Input IN, inout SurfaceOutput o) {
			half4 c = tex2D (_MainTex, IN.uv_MainTex)*_Color;
			#ifdef SHADER_API_D3D11
				clip(float4(1,1,1,c.a-0.1));	
			#endif	
			o.Albedo = c.rgb;
			half rim = 1.2 - abs(dot (normalize(IN.viewDir), o.Normal));
				
			_RimPower = sin(_Frequency * _Time)*0.3+0.8;

			o.Emission = _SelfLightFactor*(c.rgb+_RimColor * pow (rim, _RimPower));
			o.Alpha = c.a;
		}
	ENDCG
	
	SubShader {
		Tags {
		 "Queue"="Transparent"  
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
		 "Queue"="Transparent"  
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
