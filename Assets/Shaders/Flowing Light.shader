Shader "Flowing/Flowing Light" {
	Properties
	{
		_Color ("Main Color", Color) = (1,1,1,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_SelfLight("Self Light Effect", float) = 0
		
		_SecColor ("Second Color", Color) = (1,1,1,1)
		_SecTex("Second Texture(RGB)", 2D) = "white" {}
		_SecSpeedX("Second Texture Speed X", float) = 0
		_SecSpeedY("Second Texture Speed Y", float) = 0
		
		_MaskTex("Mask Texture(RGB)", 2D) = "white" {}
		
		_EdgeLength ("Edge length", Range(3,50)) = 6
		_Smoothness ("Smoothness", Range(0,1)) = 0.5
	}
CGINCLUDE
		sampler2D _MainTex;
		sampler2D _SecTex;
		sampler2D _MaskTex;//遮罩圖
		fixed4 _Color;
		float _SelfLight;
		
		float4 _SecColor;//流光材質顏色
		float _SecSpeedX;//流光材質 X軸旋轉速度
		float _SecSpeedY;//流光材質 Y軸旋轉速度

		struct Input {
			float2 uv_MainTex;
			float2 uv_SecTex;
			float2 uv_MaskTex;//遮罩圖 UV
		};
		
		void surf (Input IN, inout SurfaceOutput o)
		{
			//根據時間變更uv位置
			IN.uv_SecTex.x += _SecSpeedX * _Time;
			IN.uv_SecTex.y += _SecSpeedY * _Time;
			
			half4 c1 = tex2D(_MainTex, IN.uv_MainTex) * _Color;
            half4 c2 = tex2D(_SecTex, IN.uv_SecTex) * _SecColor;
            half4 c3 = tex2D(_MaskTex, IN.uv_MaskTex);
            
            c2 = c2 * c3;
            half4 blendColor = (c1+c2);
            
			o.Albedo = blendColor.rgb;
			o.Emission = blendColor.rgb * _SelfLight;//self-illumin

		}
      	
		half4 LightingNoLight(SurfaceOutput s, half3 lightDir, half atten)
		{
			fixed4 c;
			c.rgb = 0;
			c.a = 0;
			return c;
      	}
ENDCG
	SubShader
	{
		Tags
		{
			//"IgnoreProjector"="True"
			"RenderType"="Opaque"
		}
		LOD 450
		cull off //Double Side
		
		CGPROGRAM
		#pragma surface surf Lambert vertex:vert tessellate:tessEdge tessphong:_Smoothness 	
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
			//"IgnoreProjector"="True"
			"RenderType"="Opaque"
		}
		LOD 200
		cull off //Double Side
		
		CGPROGRAM
		#pragma surface surf Lambert
		
		ENDCG
	}

	FallBack "Transparent/Cutout/Diffuse" //改成這樣才會有正確的影子
	//FallBack "Diffuse"
}
