//動態TextureUV 變換, 支援alpha blend
//Nic@atlantis
Shader "Custom/AnimatedUV2" {
	Properties {
		_MainColor ("Main Color", Color) = (1,1,1,1)
		_MainTex("Main Texture (RGB)", 2D) = "white" {}
		_MainSpeedX("Main Texture Speed X", Range(-10,10)) = 0
		_MainSpeedY("Main Texture Speed Y", Range(-10,10)) = 0
		uvAnimationTileX ("uvAnimationTileX ", float) = 8
		uvAnimationTileY("uvAnimationTileY", float) = 8
		Speed("Speed", float) = 60
		uIndex("uIndex",float) = 0
		vIndex("vIndex",float) = 0
		_EdgeLength ("Edge length", Range(3,50)) = 6
		_Smoothness ("Smoothness", Range(0,1)) = 0.5
	}
	CGINCLUDE
	#include "UnityCG.cginc"
	#include "UnityCG.glslinc"
	sampler2D _MainTex;//主材質
	float4 _MainColor;//主材質顏色
	float _MainSpeedX;//主材質 X軸旋轉速度
	float _MainSpeedY;//主材質 Y軸旋轉速度
    float uvAnimationTileX; 
    float uvAnimationTileY;
    float Speed;
    float uIndex;
    float vIndex;

    
    // round-to-nearest even profiles
	float round(float a)
	{
	  return floor(a);
	}

    
	struct Input {
		float2 uv_MainTex;//主材質 UV
	};

	void surf (Input IN, inout SurfaceOutput o) {
	     float index = fmod(round(_Time*300),64);
         uIndex = 1+fmod(index,8);
         vIndex = -1*(round(index / 8));
	    
	    IN.uv_MainTex.x = (-1*(IN.uv_MainTex.x) + uIndex) / uvAnimationTileX;
		IN.uv_MainTex.y = (1*(IN.uv_MainTex.y) + vIndex) / uvAnimationTileY;

		//IN.uv_MainTex.x += 3* _Time;
		//IN.uv_MainTex.y += 3* _Time;
		half4 ctex1 = tex2D (_MainTex, IN.uv_MainTex);
		half4 cres1 = ctex1 * _MainColor;//作混色
		o.Albedo = cres1.rgb;
		o.Alpha = ctex1.a;//輸出的alpha
		//o.Alpha = _MainColor.a;//輸出的alpha
		

	}
	ENDCG
	
	SubShader {
		Tags { "RenderType"="Opaque" }//Opaque 不透明
		Tags
		{
			"RenderType" = "Tranparent"//透明
			"Queue" = "Transparent"//透明
		}
		LOD 450//level of detail
		
		CGPROGRAM
		#pragma surface surf Lambert alpha vertex:vert tessellate:tessEdge tessphong:_Smoothness 
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
		Tags { "RenderType"="Opaque" }//Opaque 不透明
		Tags
		{
			"RenderType" = "Tranparent"//透明
			"Queue" = "Transparent"//透明
		}
		LOD 200//level of detail
		
		CGPROGRAM
		#pragma surface surf Lambert alpha
		
		ENDCG
	} 

	FallBack "Diffuse"
}
