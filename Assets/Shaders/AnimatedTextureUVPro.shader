//動態TextureUV 變換, 支援alpha blend
//Nic@atlantis
Shader "Custom/AnimatedTextureUVPro" {
	Properties {
		//_MainColor ("Main Color", Color) = (1,1,1,1)
		_MainTex("Main Texture (RGB)", 2D) = "white" {}
		//_MainSpeed("Animation Speed", Range(-1,1)) = 0.5
		_Amount ("Extrusion Amount", Range(-1,1)) = 0.5

		//_DirectionUv("Texture scroll direction", Vector) = (1,1,0,0)	
		_EdgeLength ("Edge length", Range(3,50)) = 6
		_Smoothness ("Smoothness", Range(0,1)) = 0.5	
	}
	CGINCLUDE
	#include "UnityCG.cginc"
	//uniform sampler2D _MainTex;//主材質
	sampler2D _MainTex;
	float _Amount;
	//float4 _MainColor;//主材質顏色
	//uniform float _xy = 0;
	//float _MainSpeed;//主材質 X軸旋轉速度
	//float _MainSpeedY;//主材質 Y軸旋轉速度
	//vec4 _DirectionUv;
	//uniform float _pu = 0;
	//uniform float _pv = 0;
	struct appdata {
			float4 vertex : POSITION;
			float4 tangent : TANGENT;
			float3 normal : NORMAL;
			float2 texcoord : TEXCOORD0;
			float2 texcoord1 : TEXCOORD1;
	};
	struct Input {
		float2 uv_MainTex;//主材質 UV
		//float2 mm;
		//float3 worldPos;
	};
  	void vert (inout appdata v)
  	{
    	//v.vertex.xyz += v.normal * _MainSpeed;
    	v.vertex.x += v.normal.x * _Amount*10;
  	}

	void surf (Input IN, inout SurfaceOutput o)
	{
		//_pu = IN.uv_MainTex.x ;
		//_pv = IN.uv_MainTex.y ;
		//IN.uv_MainTex.x = _MainSpeed * _Time;
		//IN.uv_MainTex.xy = (IN.uv_MainTex.xy / _MainSpeed) * _Time.xx;// * _Time;
		//half4 ctex1 = tex2D (_MainTex, IN.mm);
		//_xy = _xy + (IN.uv_MainTex / 8);
		//IN.mm.xy = IN.mm.xy;
		//clip (frac((IN.worldPos.y+IN.worldPos.z*0.1) * 5) - 0.5);
		//clip (0);
		
		//IN.mm.x = _pu;//*_Time;
		//IN.mm.x += _CosTime;
		//IN.mm.y = _pv;// *_Time;
		//IN.mm.y = IN.mm.y + _xx;
		//half4 ctex1 = tex2D (_MainTex,IN.mm);
		//ctex1 = ctex1 + tex2D (_MainTex, (IN.mm.x + 0.03));
		//IN.uv_MainTex.y = (IN.uv_MainTex.y / _MainSpeed);//* _Time;// * _Time;
		//IN.uv_MainTex.y = _MainSpeedY * _Time;
		//half4 ctex1 = tex2D (_MainTex, IN.mm);
		//half4 cres1 = ctex1 * _MainColor;//作混色
		//o.Albedo = ctex1.rgb;
		//o.Albedo = tex2D (_MainTex, IN.uv_MainTex).rgb;
		o.Albedo = tex2D (_MainTex, IN.uv_MainTex).rgb;
		o.Alpha = 1;//輸出的alpha
		//o.Alpha = ctex1.a;//輸出的alpha
		//_xy = _xy + (IN.uv_MainTex / 8);
		//o.Alpha = _MainColor.a;//輸出的alpha
		//if (_xy < 8)
		//  _xy += 1;
		//else
		//  _xy = 0;
		//_xx = _xx + (IN.uv_MainTex.x / 8);
	}
	ENDCG
	
	SubShader {
		//Tags { "RenderType"="Opaque" }//Opaque 不透明
		Tags
		{
			"RenderType" = "Opaque" 
			//"RenderType" = "Tranparent"//透明
			//"Queue" = "Transparent"//透明

		}
		LOD 450//level of detail
		
		CGPROGRAM
		#pragma surface surf Lambert vertex:vert vertex:vert tessellate:tessEdge tessphong:_Smoothness 
		#include "Tessellation.cginc"

		float _Smoothness;
		float _EdgeLength;
		
		float4 tessEdge (appdata v0, appdata v1, appdata v2)
		{

		if(_EdgeLength < 50)
			return UnityEdgeLengthBasedTessCull (v0.vertex, v1.vertex, v2.vertex, _EdgeLength, 0.0);
		else
			return 1;
		
		}
		ENDCG
	} 
	SubShader {
		//Tags { "RenderType"="Opaque" }//Opaque 不透明
		Tags
		{
			"RenderType" = "Opaque" 
			//"RenderType" = "Tranparent"//透明
			//"Queue" = "Transparent"//透明

		}
		LOD 200//level of detail
		
		CGPROGRAM
		#pragma surface surf Lambert vertex:vert
		
		ENDCG
	} 

	FallBack "Diffuse"
}
