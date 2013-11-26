//流光效果 shader 
//Nic@atlantis

Shader "Custom/DragLight5"
{
	Properties
	{
		_MainColor ("Main Color", Color) = (0.5,0.5,0.5,0.5)
		_MainTex("Main Texture (RGB)", 2D) = "white" {}
		_MainTexAlpha("Main Texture Alpha", Range(0.0,1.0)) = 1.0
		_MainSpeedX("Main Texture Speed X", float) = 0
		_MainSpeedY("Main Texture Speed Y", float) = 0
		
		_SecColor ("Second Color", Color) = (0.5,0.5,0.5,0.5)
		_SecTex("Second Texture(RGB)", 2D) = "white" {}
		_SecTexAlpha("Second Texture Alpha", Range(0.0,1.0)) = 1.0
		_SecSpeedX("Second Texture Speed X", float) = 0
		_SecSpeedY("Second Texture Speed Y", float) = 0
		
		_MaskTex("Mask Texture (Alpha)", 2D) = "white" {}
		_ThirdSpeed("Mask Animation Speed", float) = 30
		uvAnimationTileX ("uvAnimationTileX ", float) = 8
		uvAnimationTileY("uvAnimationTileY", float) = 8
		_Cutoff ("Alpha cutoff", float) = 0.1
		
		_EdgeLength ("Edge length", Range(3,50)) = 6
		_Smoothness ("Smoothness", Range(0,1)) = 0.5
	}
	CGINCLUDE
	
		sampler2D _MainTex;//主材質
		float4 _MainColor;//主材質顏色
		sampler2D _SecTex;//流光材質
		
		float4 _SecColor;//流光材質顏色
		float _MainSpeedX;//主材質 X軸旋轉速度
		float _MainSpeedY;//主材質 Y軸旋轉速度
		float _SecSpeedX;//流光材質 X軸旋轉速度
		float _SecSpeedY;//流光材質 Y軸旋轉速度
		float _ThirdSpeed;//遮罩圖替換速度
      	sampler2D _MaskTex;//遮罩圖
      	float uvAnimationTileX; 
        float uvAnimationTileY;
      	float uIndex;
        float vIndex;
        float _MainTexAlpha;
        float _SecTexAlpha;
        
        fixed4 LightingBlinnPhongPro (SurfaceOutput s, fixed3 lightDir, fixed atten)
		{
		   // fixed diff = max (0, dot (s.Normal, lightDir));
			fixed4 c;
			c.rgb = 0;
			c.a = 0;
			return c;
		}
 
		struct Input
		{
			float2 uv_MainTex;//主材質 UV
			float2 uv_SecTex;//流光材質 UV
			float2 uv_MaskTex;//遮罩圖 UV
		};
		void surf (Input IN, inout SurfaceOutput o)
		{
			float alpha;
			//根據時間變更uv位置
			IN.uv_MainTex.x += _MainSpeedX * _Time;
			IN.uv_MainTex.y += _MainSpeedY * _Time;
			IN.uv_SecTex.x += _SecSpeedX * _Time;
			IN.uv_SecTex.y += _SecSpeedY * _Time;
			
			float index = fmod(floor(_Time*_ThirdSpeed),uvAnimationTileX*uvAnimationTileY);
             uIndex = fmod(index,uvAnimationTileX);
             vIndex = -1*(floor(index / uvAnimationTileY));
		    
		    IN.uv_MaskTex.x = ((IN.uv_MaskTex.x) + uIndex) / uvAnimationTileX;
			IN.uv_MaskTex.y = ((IN.uv_MaskTex.y) + vIndex) / uvAnimationTileY;
			
			//取uv 位置上的顏色
			half4 ctex1 = tex2D (_MainTex, IN.uv_MainTex);//主材質uv
			half4 ctex2 = tex2D (_SecTex, IN.uv_SecTex);//流光材質uv
			half4 ctex3 = tex2D (_MaskTex, IN.uv_MaskTex);//灰階uv
			
			ctex1.a = _MainTexAlpha;
			ctex2.a = _SecTexAlpha;
			
			alpha = _MainColor.a * ctex1.a * ctex3.rgb;
			//alpha = 1-alpha;
			//half4 cres = lerp(_MainColor,ctex1,_MainColor.a);//作混色
			//half4 cres1 = 10.0 * ctex1 * _MainColor;//作主材質混色
			float4 cres1 = 5.0 * ctex1 * _MainColor;//作主材質混色
			//cres1 = cres1 * (1-cres1);
			//cres1 = cres1 * ctex3;//再加上灰階
			float4 cres2 = 5.0 * ctex2 * _SecColor;//作流光材質混色
			
			o.Albedo = cres1.rgb;//輸出的rgb
			o.Alpha = alpha;//輸出的alpha
			//o.Alpha = 0.5;
			//o.Specular = cres2.rgb;//流光的rgb
			//o.Gloss = cres2.a;
			o.Emission = cres2.rgb * ctex2.a;//流光的rgb
			//o.Emission = cres2.a; 
		}
	ENDCG
	SubShader
	{
		//Tags { "RenderType"="Opaque" }//Opaque 不透明
		Tags
		{
			"RenderType" = "Tranparent"//透明
			"Queue" = "Transparent"//透明
			"IgnoreProjector" = "True"//忽略投影
		}
		LOD 450//level of detail
		//Blend SrcAlpha OneMinusSrcAlpha     // Alpha blending
		//Blend One One                       // Additive
		//Blend One OneMinusDstColor          // Soft Additive
		//Blend DstColor Zero                 // Multiplicative
		//Blend DstColor SrcColor             // 2x Multiplicative
		//Blend One One
		//Blend SrcAlpha One
		Blend SrcAlpha One
		ColorMask RGB
		Cull Off
     	ZWrite Off
     	Lighting Off
		
		CGPROGRAM
		#pragma surface surf BlinnPhongPro alpha alphatest:_Cutoff vertex:vert tessellate:tessEdge tessphong:_Smoothness 
		#include "Tessellation.cginc"	
		struct appdata {
			float4 vertex : POSITION;
			float4 tangent : TANGENT;
			float3 normal : NORMAL;
			float2 texcoord : TEXCOORD0;
			float2 texcoord1 : TEXCOORD1;
		};
		float _Smoothness;
		float _EdgeLength;
		void vert (inout appdata v) {
		}
		float4 tessEdge (appdata v0, appdata v1, appdata v2)
		{

		if(_EdgeLength < 50)
			return UnityEdgeLengthBasedTessCull (v0.vertex, v1.vertex, v2.vertex, _EdgeLength, 0.0);
		else
			return 1;
		
		}
		ENDCG
		
	}

	SubShader
	{
		//Tags { "RenderType"="Opaque" }//Opaque 不透明
		Tags
		{
			"RenderType" = "Tranparent"//透明
			"Queue" = "Transparent"//透明
			"IgnoreProjector" = "True"//忽略投影
		}
		LOD 200//level of detail
		//Blend SrcAlpha OneMinusSrcAlpha     // Alpha blending
		//Blend One One                       // Additive
		//Blend One OneMinusDstColor          // Soft Additive
		//Blend DstColor Zero                 // Multiplicative
		//Blend DstColor SrcColor             // 2x Multiplicative
		//Blend One One
		//Blend SrcAlpha One
		Blend SrcAlpha One
		ColorMask RGB
		Cull Off
     	ZWrite Off
     	Lighting Off
		
		CGPROGRAM
		#pragma surface surf BlinnPhongPro alpha alphatest:_Cutoff
		
		ENDCG
		
	}

	FallBack "Transparent/Cutout/Diffuse"
}
