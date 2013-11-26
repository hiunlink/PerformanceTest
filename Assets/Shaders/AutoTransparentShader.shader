Shader "Custom/AutoTransparentShader" {
Properties {
    _Color ("Main Color", Color) = (1,1,1,1)
    _EdgeColor ("Rim Color", Color) = (0,0,0,1)
    _MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
    _SelfLightFactor("Self Illumin Factor", float) = 0.8
    _RimPower ("Rim Power", float) = 3.0
    _RimWidth ("Rim Width", float) = 1.0
    _Alpha ("Alpha", float) = 1.0
    _AffectedByCameraFac ("Affected By Camera (0,1)", float) = 0
    _Cutoff ("Alpha cutoff", float) = 0.1
    _EdgeLength ("Edge length", Range(3,50)) = 6
	_Smoothness ("Smoothness", Range(0,1)) = 0.5
}
CGINCLUDE

sampler2D _MainTex;
fixed4 _Color;
float _Alpha;
float4 _EdgeColor;
float _RimPower;
float _RimWidth;
float _SelfLightFactor;
float _AffectedByCameraFac;

struct Input {
	float2 uv_MainTex;
	float3 viewDir;
};

void surf (Input IN, inout SurfaceOutput o) {
	
	fixed4 tex = tex2D(_MainTex, IN.uv_MainTex);
	o.Albedo = tex.rgb * _Color.rgb;
	half rim = _RimWidth - abs(dot (normalize(IN.viewDir), o.Normal));
	
	o.Emission = _SelfLightFactor*(_EdgeColor.rgb * pow (rim, _RimPower));
	o.Alpha = tex.a*_Alpha * pow (rim, _RimPower);
}
ENDCG

SubShader {
	Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
	LOD 450
	lighting on
	//Blend SrcAlpha OneMinusSrcAlpha
	AlphaTest Greater 0.1
	CGPROGRAM
	#pragma surface surf Lambert noambient alpha  vertex:vert tessellate:tessEdge tessphong:_Smoothness 
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
	Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
	LOD 200
	lighting on
	//Blend SrcAlpha OneMinusSrcAlpha
	AlphaTest Greater 0.1
CGPROGRAM
#pragma surface surf Lambert noambient alpha

ENDCG
}


FallBack "Transparent/Cutout/Diffuse"
}
