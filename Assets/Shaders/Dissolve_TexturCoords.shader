Shader "Custom/Dissolve_TexturCoords" {
Properties {
	_Color ("Main Color", Color) = (1,1,1,1)
	_Alpha ("Amount", Range (0, 1)) = 1
	_StartAmount("StartAmount", float) = 0.1
	_Illuminate ("Illuminate", Range (0, 1)) = 0.5
	_Tile("Tile", float) = 1
	_DissColor ("DissColor", Color) = (1,1,1,1)
	_ColorAnimate ("ColorAnimate", vector) = (1,1,1,1)
	_MainTex ("Base (RGB) Gloss (A)", 2D) = "white" {}
	_DissolveSrc ("DissolveSrc", 2D) = "white" {}
	_Cutoff ("Alpha cutoff", float) = 0.1
	_EdgeLength ("Edge length", Range(3,50)) = 6
	_Smoothness ("Smoothness", Range(0,1)) = 0.5
}
CGINCLUDE
sampler2D _MainTex;

sampler2D _DissolveSrc;

fixed4 _Color;
half4 _DissColor;

half _Alpha;
static half3 Color = float3(1,1,1);
half4 _ColorAnimate;
half _Illuminate;
half _Tile;
half _StartAmount;

struct Input {
	float2 uv_MainTex;
	float2 uvDissolveSrc;
};

void surf (Input IN, inout SurfaceOutput o) {
	fixed4 tex = tex2D(_MainTex, IN.uv_MainTex);
	o.Albedo = tex.rgb * _Color.rgb;
	
	float ClipTex = tex2D (_DissolveSrc, IN.uv_MainTex/_Tile).r ;
	float ClipAmount = ClipTex - _Alpha;
	float Clip = 0;

if (_Alpha > 0)
{
	if (ClipAmount <0)
	{
		Clip = 1; //clip(-0.1);
	
	}
	 else
	 {
	
		if (ClipAmount < _StartAmount)
		{
			if (_ColorAnimate.x == 0)
				Color.x = _DissColor.x;
			else
				Color.x = ClipAmount/_StartAmount;
          
			if (_ColorAnimate.y == 0)
				Color.y = _DissColor.y;
			else
				Color.y = ClipAmount/_StartAmount;
          
			if (_ColorAnimate.z == 0)
				Color.z = _DissColor.z;
			else
				Color.z = ClipAmount/_StartAmount;

			o.Albedo  = (o.Albedo *((Color.x+Color.y+Color.z))* Color*((Color.x+Color.y+Color.z)))/(1 - _Illuminate);
		
		}
	 }
 }

 
if (Clip == 1)
{
clip(-0.1);
}

   
	//////////////////////////////////
	//
	o.Alpha = tex.a * _Color.a;
	#ifdef SHADER_API_D3D11
	clip(o.Alpha-0.1);	
	#endif
	o.Emission = tex.rgb * _Color.rgb;
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
	#pragma surface surf Lambert addshadow vertex:vert tessellate:tessEdge tessphong:_Smoothness 
	#include "Tessellation.cginc"
	#pragma exclude_renderers flash
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
	#pragma surface surf Lambert addshadow
	#pragma exclude_renderers flash
	ENDCG
}

FallBack "Transparent/Cutout/Diffuse"
}
