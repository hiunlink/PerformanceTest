Shader "CharacterPortraitShader"
{
   Properties
	{
		_Color ("Main Color", Color) = (1,1,1,1)
		_MainTex ("Base (RGB) Gloss (A)", 2D) = "white" {}
		_MaskTex ("Mask", 2D) = "white" {}
		_Illum ("Illumin (A)", 2D) = "white" {}
		_EmissionLM ("Emission (Lightmapper)", Float) = 0
		_Cutoff ("Alpha cutoff", float) = 0.5
		_EdgeLength ("Edge length", Range(3,50)) = 6
		_Smoothness ("Smoothness", Range(0,1)) = 0.5
	}
	CGINCLUDE
	sampler2D _MainTex;
	sampler2D _MaskTex;
	sampler2D _Illum;
	fixed4 _Color;
	float Cutoff;
	float _Brightness;
	
	struct Input {
		float2 uv_MainTex;
		float2 uv_MaskTex;
		float2 uv_Illum;
	};

	void surf (Input IN, inout SurfaceOutput o)
	{
		fixed4 tex = tex2D(_MainTex, IN.uv_MainTex);
		fixed4 texAlpha = tex2D(_MaskTex, IN.uv_MaskTex);
		
		fixed4 c = tex;
		o.Albedo = c.rgb;
                    
		o.Emission = c.rgb * tex2D(_Illum, IN.uv_Illum).a;
		o.Alpha = texAlpha.a;
		if(c.b < 0.1 && c.g < 0.1 && c.r < 0.1)
		   o.Alpha = 0;
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
			"Queue"="AlphaTest" 
			//"IgnoreProjector"="True" 
			"RenderType"="TransparentCutout"
		}
		LOD 200
		cull off //Double Side
  
		CGPROGRAM
		#pragma surface surf NoLight noambient alphatest:_Cutoff

		
		ENDCG

	}

	//FallBack "Self-Illumin/VertexLit"
	//FallBack "Transparent/Cutout/Diffuse"
}

