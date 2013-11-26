Shader "Custom/OutlinedDiffuse2" {
    Properties {
        _Color ("Main Color", Color) = (.5,.5,.5,1)
        _Outline ("Outline Color", Color) = (1,0,0,1)
        _OutlineWidth ("Outline width", Range (.002, 0.03)) = .002
        _RimColor ("Rim Color", Color) = (1,1,1,1)
        _MainTex ("Base (RGB)", 2D) = "white" { }
        _LightAffectFactor("Light Affect Factor", float) = 1
        _SelfLightFactor("Self Illumin Factor", float) = 0.8
         _RimPower ("Rim Power", float) = 3.0
        _RimWidth ("Rim Width", float) = 1.0
        _Frequency ("Flash Frequency", float) = 0.0
        _AffectedByCameraFac ("Affected By Camera (0,1)", float) = 0
        _Cutoff ("Alpha cutoff", float) = 0.1
    }
    
SubShader {

Tags 
		{
			"Queue"="AlphaTest" 
			//"IgnoreProjector"="True" 
			"RenderType"="TransparentCutout"
		}
		LOD 200
		cull off
		AlphaTest Greater 0.1

CGPROGRAM
#pragma surface surf SimpleLambert noambient vertex:vert

sampler2D _MainTex;
fixed4 _Color;
float _SelfLightFactor, _LightAffectFactor;
float4 _RimColor;
float _RimPower;
float _RimWidth;
float _AffectedByCameraFac, _Frequency;

inline fixed4 LightingSimpleLambert (SurfaceOutput s, fixed3 lightDir, fixed atten)
	{
		fixed diff = max (0, dot (s.Normal, lightDir));
		
		fixed4 c;
		c.rgb = _LightAffectFactor*s.Albedo * _LightColor0.rgb * (diff * atten * 2);
		c.a = s.Alpha;
		return c;
	}

struct Input {
    float2 uv_MainTex;
    float3 viewDir;
    float distanceFromCam;
};

 void vert (inout appdata_full v, out Input o) {
		   // Transform to camera space
		   UNITY_INITIALIZE_OUTPUT(Input,o);
		   float3 vPos = mul(UNITY_MATRIX_MVP, v.vertex);
		   o.distanceFromCam = vPos.z*0.075f;
		 }

void surf (Input IN, inout SurfaceOutput o) {
    fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
    o.Albedo = c.rgb;
    half rim = _RimWidth - abs(dot (normalize(IN.viewDir), o.Normal));
    
	  float distance = (1-IN.distanceFromCam);
	  if(distance < 0)
	      distance = 0;
	  _RimColor.rgb = _RimColor.rgb*(_AffectedByCameraFac+distance);
    
    if(_Frequency > 0)
    {
    	_RimPower = sin(_Frequency * _Time)*0.7+0.7;
    }
    
    o.Emission = _SelfLightFactor*(c.rgb+_RimColor.rgb * pow (rim, _RimPower));
    o.Alpha = c.a;
}
ENDCG



    Pass {
Blend SrcAlpha OneMinusSrcAlpha
cull front
AlphaTest Greater 0.1
CGPROGRAM
#pragma vertex vert
#pragma fragment frag

#include "UnityCG.cginc"

float4 _Color;
sampler2D _MainTex;
uniform float _OutlineWidth;
uniform float4 _Outline;
float _RimPower;

struct v2f {
    float4  pos : SV_POSITION;
    float2  uv : TEXCOORD0;
    float4 color : COLOR;
};

float4 _MainTex_ST;

v2f vert (appdata_base v)
{
    v2f o;
    UNITY_INITIALIZE_OUTPUT(v2f,o);
    o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
    o.uv = TRANSFORM_TEX (v.texcoord, _MainTex);
    float3 norm   = mul ((float3x3)UNITY_MATRIX_IT_MV, v.normal);
    float2 offset = TransformViewToProjection(norm.xy);
    
 //   float edge = dot(norm,float3(0,0,1));

    o.pos.xy += offset * o.pos.z * _OutlineWidth;
    o.color = _Outline;
 //   o.color.a = pow (edge, _RimPower);
    return o;
}

half4 frag (v2f i) : COLOR
{
    half4 texcol = tex2D (_MainTex, i.uv);
    return texcol.a * i.color;
}
ENDCG

    }
}

    Fallback "Transparent/Cutout/Diffuse"
}
