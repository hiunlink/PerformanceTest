Shader "Custom/ReflectiveDiffuse" {
Properties {
	_Color ("Main Color", Color) = (1,1,1,1)
	_ReflectColor ("Reflection Color", Color) = (1,1,1,0.5)
	_RimColor ("Rim Color", Color) = (0,0,0,1)
	_MainTex ("Base (RGB) RefStrength (A)", 2D) = "white" {} 
	_Cube ("Reflection Cubemap", Cube) = "_Skybox" { TexGen CubeReflect }
	_MaskTex("Mask Texture(RGB)", 2D) = "white" {}
	_LightAffectFactor("Light Affect Factor", float) = 0.6
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
    struct appdata {
			float4 vertex : POSITION;
			float4 tangent : TANGENT;
			float3 normal : NORMAL;
			float2 texcoord : TEXCOORD0;
			float2 texcoord1 : TEXCOORD1;
		};
			
	sampler2D _MainTex;
	sampler2D _MaskTex;
	samplerCUBE _Cube;
	
	fixed4 _Color;
	fixed4 _ReflectColor;
	float _LightAffectFactor;
	float _SelfLightFactor;
	float4 _RimColor;
	float _RimPower;
	float _RimWidth;
	float _AffectedByCameraFac;
	
	inline fixed4 LightingCustomLambert (SurfaceOutput s, fixed3 lightDir, fixed atten)
	{
		fixed diff = max (0, dot (s.Normal, lightDir));
		
		fixed4 c;
		c.rgb = _LightAffectFactor*s.Albedo * _LightColor0.rgb * (diff * atten * 2);
		c.a = s.Alpha;
		return c;
	}
	
	struct Input {
		float2 uv_MainTex;
		float2 uv_MaskTex;
		float3 worldRefl;
		float3 viewDir;
		float3 screenPos;
	};
 	void vert (inout appdata v) {
	   // Transform to camera space
	   //UNITY_INITIALIZE_OUTPUT(Input,o);
	 }
	
	void surf (Input IN, inout SurfaceOutput o) {
		fixed4 tex = tex2D(_MainTex, IN.uv_MainTex);
		fixed4 c = tex * _Color;
		#ifdef SHADER_API_D3D11
			clip(float4(1,1,1,c.a-0.1));	
		#endif	
		fixed4 mask = tex2D(_MaskTex, IN.uv_MaskTex);
		o.Albedo = c.rgb;
		half rim = _RimWidth - abs(dot (normalize(IN.viewDir), o.Normal));
		
		fixed4 reflcol = mask*texCUBE (_Cube, IN.worldRefl);
		reflcol *= tex.a;
		
		  float distance = (1- IN.screenPos.z * 0.075);
	      if(distance < 0)
	          distance = 0;
		  _RimColor.rgb = _RimColor.rgb*(_AffectedByCameraFac+distance);
		  
		o.Emission = _SelfLightFactor*c.rgb+reflcol.rgb * _ReflectColor.rgb + _RimColor.rgb * pow (rim, _RimPower);
		o.Alpha =  tex.a * _ReflectColor.a;
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
    
    SubShader {
		LOD 450
		Tags { "RenderType"="TransparentCutout" }
		Cull Off
	    AlphaTest Greater 0.1
		CGPROGRAM
		#pragma surface surf CustomLambert noambient vertex:vert tessellate:tessEdge tessphong:_Smoothness 
		
		ENDCG
	}
	SubShader {
		LOD 200
		Tags { "RenderType"="TransparentCutout" }
		Cull Off
	    AlphaTest Greater 0.1
		CGPROGRAM
		#pragma surface surf CustomLambert noambient vertex:vert
		
		ENDCG
	}

	
FallBack "Transparent/Cutout/Diffuse"
} 
