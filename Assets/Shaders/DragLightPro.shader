//流光效果 shader 
//Nic@atlantis
Shader "Custom/DragLightPro"
{
	Properties
	{
		_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
		_MainTex ("Particle Texture", 2D) = "white" {}
	}
	Category
	{
		Tags
		{
			"RenderType" = "Tranparent"//透明
			"Queue" = "Transparent"//透明
			"IgnoreProjector" = "True"//忽略投影
		} 
		Blend SrcAlpha One 
		//Blend One One
		AlphaTest Greater 0.1
		ColorMask RGBA 	
		Cull Off
		Lighting Off
		ZWrite Off
		
			
		// ---- Fragment program cards 	
		SubShader
		{
			Pass
			{ 		 			
				CGPROGRAM 			
				#pragma vertex vert 			
				#pragma fragment frag 			
				#pragma fragmentoption ARB_precision_hint_fastest
				//#pragma multi_compile_particles  			
				#include "UnityCG.cginc"  			
				sampler2D _MainTex;
				float4 _TintColor;
				struct appdata_t
				{
					float4 vertex : POSITION;
					float4 color : COLOR;
					float2 texcoord : TEXCOORD0;
				}; 
				struct v2f
				{
					float4 vertex : POSITION;
					float4 color : COLOR;
					float2 texcoord : TEXCOORD0;
				};
				float4 _MainTex_ST;
				v2f vert (appdata_t v)
				{
					v2f o;
					o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
					o.color = v.color; 
					o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTex);
					return o;
				}
				half4 frag (v2f i) : COLOR
				{
					//return 2.0f * i.color * _TintColor * tex2D(_MainTex, i.texcoord);
					return tex2D(_MainTex, i.texcoord);
				}
				ENDCG
			}
		}
	}
} 