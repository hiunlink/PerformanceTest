Shader "Custom/EdgeLightingSpecularHighlighted"
{
	Properties
	{
		_Color ("Main Color", Color) = (1,1,1,1)
		_SpecColor ("Specular Color", Color) = (0.5, 0.5, 0.5, 1)
		_Shininess ("Shininess", float) = 0.078125
		_RimColor ("Rim Color", Color) = (1,1,1,1)
		_MainTex ("Base (RGB) Gloss (A)", 2D) = "white" {}
		_Outline ("Outline", Color) = (1,1,1,1)
		_MaskTex ("Mask (B)", 2D) = "gray" {}
		_BumpMap ("Normalmap", 2D) = "bump" {}
		_GlossFactor ("Gloss Factor", float) = 2
		_LightAffectFactor("Light Affect Factor", float) = 1
		_SelfLightFactor("Self Illumin Factor", float) = 0.8
        _RimPower ("Rim Power", float) = 3.0
        _RimWidth ("Rim Width", float) = 1.0
        _AffectedByCameraFac ("Affected By Camera (0,1)", float) = 0
		_Cutoff ("Alpha cutoff", float) = 0.1
		_EdgeLength ("Edge length", Range(3,50)) = 6
		_Smoothness ("Smoothness", Range(0,1)) = 0.5
	}
	CGINCLUDE 
	#include "Tessellation.cginc"
		
	struct SurfaceOutputSpec {
             fixed3 Albedo;
             fixed3 Normal;
             fixed4 Mask;
             fixed3 Emission;
             half Specular;
             fixed Gloss;
             fixed Alpha;
         };
	struct appdata {
			float4 vertex : POSITION;
			float4 tangent : TANGENT;
			float3 normal : NORMAL;
			float2 texcoord : TEXCOORD0;
			float2 texcoord1 : TEXCOORD1;
		};
	sampler2D _MainTex, _MaskTex;
	sampler2D _BumpMap;
	fixed4 _Color;        
	float4 _RimColor;
	float _RimPower;
	float _RimWidth;
	half _Shininess;
	float _LightAffectFactor;
	float _SelfLightFactor, _GlossFactor;
	float _AffectedByCameraFac;

	struct Input
	{
		float2 uv_MainTex;
		float2 uv_MaskTex;
		float2 uv_BumpMap;
		float3 viewDir;
		float3 screenPos;
	};
	void vert (inout appdata v) {
		//UNITY_INITIALIZE_OUTPUT(Input,o);

	   // Transform to camera space
	 }

	void surf (Input IN, inout SurfaceOutputSpec o)
	{
		fixed4 tex = tex2D(_MainTex, IN.uv_MainTex);
		fixed4 c = tex * _Color;
		#ifdef SHADER_API_D3D11
		clip(c.a-0.1);	
		#endif
		o.Albedo = c.rgb;
		o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
		half rim = _RimWidth - abs(dot (normalize(IN.viewDir), o.Normal));

		//根據鏡頭遠鏡調整rim lighting
		float distance = (1- IN.screenPos.z * 0.075);
        if(distance < 0)
           distance = 0;
		_RimColor.rgb = _RimColor.rgb*(_AffectedByCameraFac+distance);
		
	    o.Emission = _SelfLightFactor*(c.rgb+_RimColor.rgb * pow (rim, _RimPower));
		//o.Emission = c.rgb * tex2D(_Illum, IN.uv_Illum).a;
		o.Gloss = tex.a;
		o.Alpha = c.a;
		fixed4 mask = tex2D(_MaskTex, IN.uv_MaskTex);
        o.Mask = mask;
		o.Specular = _Shininess;
		
	}
	
	inline fixed4 LightingSimpleBlinnPhong (SurfaceOutputSpec s, fixed3 lightDir, half3 viewDir, fixed atten)
	{
		half3 h = normalize (lightDir + viewDir);
		
		fixed diff = max (0, dot (s.Normal, lightDir));
		
		float nh = max (0, dot (s.Normal, h));
		float spec = _GlossFactor*s.Mask*pow (nh, s.Specular*128.0) * s.Gloss;
		
		fixed4 c;
		c.rgb = _LightAffectFactor*(s.Albedo * _LightColor0.rgb * diff + _LightColor0.rgb * _SpecColor.rgb * spec) * (atten * 2);
		c.a = s.Alpha + _LightColor0.a * _SpecColor.a * spec * atten;
		return c;
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
	ENDCG
	SubShader
	{
		Tags 
		{
			//"RenderType"="Opaque"
			"Queue"="AlphaTest" 
			//"IgnoreProjector"="True" 
			"RenderType"="TransparentCutout"
			"RenderEffect"="TessellateHighlighted"
		}
		LOD 450
        cull off
		//AlphaTest Greater 0.1
		CGPROGRAM
		#pragma surface surf SimpleBlinnPhong noambient vertex:vert  tessellate:tessEdge tessphong:_Smoothness 

		ENDCG
	}
	SubShader
	{
		Tags 
		{
			//"RenderType"="Opaque"
			"Queue"="AlphaTest" 
			//"IgnoreProjector"="True" 
			"RenderType"="TransparentCutout"
			"RenderEffect"="Highlighted"
		}
		LOD 400
        cull off
		AlphaTest Greater 0.1
		CGPROGRAM
		#pragma surface surf SimpleBlinnPhong noambient vertex:vert

		ENDCG
	}

	//FallBack "Self-Illumin/Specular"
	FallBack "Transparent/Cutout/Specular"
	//FallBack "Diffuse"
}
