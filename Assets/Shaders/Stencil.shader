Shader "Hidden/Stencil" {
	Properties 
	{ 
	    _Outline ("Outline", Color) = (1,1,1,1) 
	    _InnerTint ("Inner Tint Value", Range (0, 1)) = 1 
	    _MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
	    _Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
	    _EdgeLength ("Edge length", Range(3,50)) = 6
		_Smoothness ("Smoothness", Range(0,1)) = 0.5
	}
	CGINCLUDE 
	#include "Tessellation.cginc"
		
	struct appdata {
			float4 vertex : POSITION;
			float4 tangent : TANGENT;
			float3 normal : NORMAL;
			float2 texcoord : TEXCOORD0;
			float2 texcoord1 : TEXCOORD1;
		};
	sampler2D _MainTex;
	fixed4 _Outline;        


	struct Input
	{
		float2 uv_MainTex;
	};

	void vert (inout appdata v) {
	}

	void surf (Input IN, inout SurfaceOutput o)
	{	
		//UNITY_INITIALIZE_OUTPUT(SurfaceOutput,o);
		//o.Albedo = _Outline.rgb;	
		o.Alpha  = tex2D(_MainTex, IN.uv_MainTex).a;
	}
	float _Smoothness;
	float _EdgeLength;
	float4 tessEdge (appdata v0, appdata v1, appdata v2)
	{

		if(_EdgeLength < 50)
			return UnityEdgeLengthBasedTessCull (v0.vertex, v1.vertex, v2.vertex, _EdgeLength, 0.0);
		else
			return 1;
		
	}
	void OutlineColor (Input IN, SurfaceOutput o, inout fixed4 color)
	{
		
		color.rgb = _Outline.rgb;
		//color.a= 0;
	}
      inline fixed4 LightingNolight (SurfaceOutput s, fixed3 lightDir, fixed atten)
	  {
			fixed4 c;
			c.rgb = s.Albedo;
			c.a = s.Alpha;
			return c;
	  }

	ENDCG 
	
	SubShader 
	{
		
		Tags { "RenderType"="TransparentCutout" "RenderEffect"="TessellateHighlighted" }
		LOD 450
        cull off 
		//ZWrite Off 
		//Lighting Off 
		ColorMask RGBA
		Fog { Mode Off }
		CGPROGRAM
		#pragma surface surf Nolight noambient finalcolor:OutlineColor vertex:vert tessellate:tessEdge tessphong:_Smoothness alphatest:_Cutoff
		ENDCG
	}
	SubShader 
	{
		Tags { "RenderType"="TransparentCutout" "RenderEffect"="Highlighted" }
        cull off 
		//ZWrite Off 
		//Lighting Off 
		LOD 400
		ColorMask RGBA
		Fog { Mode Off }
		Pass 
		{
			Alphatest GEqual [_Cutoff]
			//SetTexture [_MainTex] { combine texture } 
			SetTexture [_MainTex] { constantColor [_Outline] combine constant, texture alpha}
			//SetTexture [_MainTex] { constantColor (0,0,0,[_InnerTint]) combine previous, texture alpha }
		}
	}
	SubShader 
	{
		Tags { }
        ColorMask RGBA
        Fog { Mode Off }
		Pass 
		{
			
			//SetTexture [_MainTex] { constantColor (1,1,1,1) combine constant, texture alpha}
 			Color(0,0,0,0)
		}
	}
	Fallback "Transparent/Cutout/VertexLit"
}
