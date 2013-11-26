Shader "Custom/TextureAnimation" {
	Properties
	{
		_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
		_MainTex ("Particle Texture", 2D) = "white" {}
		_MaskTex("Mask Texture (Alpha)", 2D) = "white" {}
		_ThirdSpeed("Mask Animation Speed", float) = 30
		uvAnimationTileX ("uvAnimationTileX ", float) = 8
		uvAnimationTileY("uvAnimationTileY", float) = 8
	}
	Category
	{
		Tags
		{
			"RenderType" = "Tranparent"//透明
			"Queue" = "Transparent"//透明
			"IgnoreProjector" = "True"//忽略投影
		} 
		LOD 200
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
				float _ThirdSpeed;//遮罩圖替換速度
		      	sampler2D _MaskTex;//遮罩圖
		      	float uvAnimationTileX; 
		        float uvAnimationTileY;
		        float uIndex;
                float vIndex;
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
					float4 texcoord : TEXCOORD0;
				};
				float4 _MainTex_ST;
				float4 _MaskTex_ST;
				v2f vert (appdata_t v)
				{
					v2f o;
					o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
					o.color = v.color; 
					o.texcoord.xy = TRANSFORM_TEX(v.texcoord,_MainTex);
                    o.texcoord.zw = TRANSFORM_TEX(v.texcoord,_MaskTex);
                    
                    float index = fmod(floor(_Time*_ThirdSpeed),uvAnimationTileX*uvAnimationTileY);
		             uIndex = fmod(index,uvAnimationTileX);
		             vIndex = -1*(floor(index / uvAnimationTileY));
		             
		             o.texcoord.z = ((o.texcoord.z) + uIndex) / uvAnimationTileX;
			        o.texcoord.w = ((o.texcoord.w) + vIndex) / uvAnimationTileY;
                    
					return o;
				}
				half4 frag (v2f i) : COLOR
				{
					//return 2.0f * i.color * _TintColor * tex2D(_MainTex, i.texcoord.xy);
					float4 mask=tex2D(_MaskTex,i.texcoord.zw);
					
					return mask*tex2D(_MainTex, i.texcoord.xy);
				}
				ENDCG
			}
		}
	}
	FallBack "Unlit/Transparent"
}
