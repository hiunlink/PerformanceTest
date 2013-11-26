Shader "Custom/Anisotropic Specular" {
     Properties {
         _Color ("Main Color", Color) = (1,1,1,1)
         _MainTex ("Diffuse (RGB) Alpha (A)", 2D) = "white" {}
         _SpecularTex ("Specular (R) Gloss (G) Anisotropic Mask (B)", 2D) = "gray" {}
         _AnisoTex ("Anisotropic Direction (RGB)", 2D) = "bump" {}
         _AnisoOffset ("Anisotropic Highlight Offset", Range(-1,1)) = -0.2
         _GlossFactor ("Gloss Factor", float) = 1
         _LightAffectFactor("Light Affect Factor", float) = 1
         _SelfLight("Self Light Effect", float) = 1
         _Cutoff ("Alpha Cut-Off Threshold", float) = 0.1
         _EdgeLength ("Edge length", Range(3,50)) = 6
		 _Smoothness ("Smoothness", Range(0,1)) = 0.5
     }
	CGINCLUDE
	
             struct SurfaceOutputAniso {
                 fixed3 Albedo;
                 fixed3 Normal;
                 fixed4 AnisoDir;
                 fixed3 Emission;
                 half Specular;
                 fixed Gloss;
                 fixed Alpha;
             };

             float _AnisoOffset, _Cutoff, _LightAffectFactor, _GlossFactor;
             float _SelfLight;
             
             inline fixed4 LightingAniso (SurfaceOutputAniso s, fixed3 lightDir, fixed3 viewDir, fixed atten)
             {
                fixed3 h = normalize(normalize(lightDir) + normalize(viewDir));
                float NdotL = saturate(dot(s.Normal, lightDir));

                fixed HdotA = dot(normalize(s.Normal + s.AnisoDir.rgb), h);
                float aniso = max(0, sin(radians((HdotA + _AnisoOffset) * 180)));

                float spec = saturate(dot(s.Normal, h));
                spec = saturate(pow(lerp(spec, aniso, s.AnisoDir.a), s.Gloss * 128) * s.Specular);

                fixed4 c;
                c.rgb = _LightAffectFactor*((s.Albedo * _LightColor0.rgb * NdotL) + (_LightColor0.rgb * spec)) * (atten * 2);
                c.a = 1;
                clip(s.Alpha - _Cutoff);
                return c;
             }

            
             
             struct Input
             {
                 float2 uv_MainTex;
                 float2 uv_SpecularTex;
                 float2 uv_AnisoTex;
             };
             
             sampler2D _MainTex, _SpecularTex, _AnisoTex;
             fixed4 _Color;    
             void surf (Input IN, inout SurfaceOutputAniso o)
             {
                fixed4 albedo = tex2D(_MainTex, IN.uv_MainTex)*_Color;
                 o.Albedo = albedo.rgb;
                 o.Alpha = albedo.a;
                 o.Emission = _SelfLight*albedo.rgb;
                 fixed3 spec = tex2D(_SpecularTex, IN.uv_SpecularTex).rgb;
                 o.Specular = spec.r;
                 o.Gloss = _GlossFactor*spec.g;
                 o.AnisoDir = fixed4(tex2D(_AnisoTex, IN.uv_AnisoTex).rgb, spec.b);
             }
	ENDCG
	 
	 SubShader{
         Tags { "RenderType" = "Opaque" }
         LOD 450
         CGPROGRAM
			#pragma surface surf Aniso vertex:vert tessellate:tessEdge tessphong:_Smoothness 
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

     SubShader{
         Tags { "RenderType" = "Opaque" }
         LOD 400
         CGPROGRAM
          #pragma surface surf Aniso
          #pragma target 3.0
         ENDCG
     }

     FallBack "Transparent/Cutout/VertexLit"
}
