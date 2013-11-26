//流光效果 單張材質shader 
//Nic@atlantis

Shader "Custom/DragLight3"
{
	Properties
	{
		_MainColor ("Main Color", Color) = (0.5,0.5,0.5,0.5)
		_MainTex("Main Texture (RGB)", 2D) = "white" {}
		_MainSpeedX("Main Texture Speed X", Range(-30,30)) = 0
		_MainSpeedY("Main Texture Speed Y", Range(-30,30)) = 0
		
		_MaskTex("Mask Texture (Alpha)", 2D) = "white" {}
		
		_EdgeLength ("Edge length", Range(3,50)) = 6
		_Smoothness ("Smoothness", Range(0,1)) = 0.5
	}
	CGINCLUDE	
	sampler2D _MainTex;//主材質
	float4 _MainColor;//主材質顏色
	float _MainSpeedX;//主材質 X軸旋轉速度
	float _MainSpeedY;//主材質 Y軸旋轉速度
	
	sampler2D _MaskTex;//遮罩圖

	struct Input
	{
		float2 uv_MainTex;//主材質 UV
		float2 uv_MaskTex;//遮罩圖 UV
	};
	void surf (Input IN, inout SurfaceOutput o)
	{
		float alpha;
		//根據時間變更uv位置
		IN.uv_MainTex.x += _MainSpeedX * _Time;
		IN.uv_MainTex.y += _MainSpeedY * _Time;
		
		//取uv 位置上的顏色
		float4 ctex1 = tex2D (_MainTex, IN.uv_MainTex);//主材質uv
		float4 ctex3 = tex2D (_MaskTex, IN.uv_MaskTex);//灰階uv
		
		alpha = _MainColor.a * ctex1.a * ctex3.rgb;//*_MainColor.a;// * ctex3.rgb;
		float4 cres1 = 10.0 * ctex1 * _MainColor;//作主材質混色
		
		o.Albedo = cres1.rgb;//輸出的rgb
		//o.Alpha = 1;//輸出的alpha
		o.Alpha = alpha;//輸出的alpha
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
		#pragma surface surf Lambert alpha alphatest:_Cutoff vertex:vert tessellate:tessEdge tessphong:_Smoothness 
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
		#pragma surface surf Lambert alpha alphatest:_Cutoff
		
		ENDCG
		
	}

	FallBack "Diffuse"
}
