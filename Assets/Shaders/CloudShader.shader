Shader "Custom/CloudShader" {
	  Properties {
	    _MainColor ("Main Color", Color) = (1,1,1,1)
        _MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
        cloudSpeedX("cloudSpeedX",float) = 0
        cloudSpeedY("cloudSpeedY",float) = 0
    }


    SubShader
    {
        Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
       
        Pass {
            ZWrite Off Fog { Mode Off }
            Blend SrcAlpha OneMinusSrcAlpha 
            Lighting Off

            
            CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			
			float4 _MainColor;
			sampler2D _MainTex;
            float cloudSpeedX;
            float cloudSpeedY;
            
			struct v2f {
			    float4 pos : SV_POSITION;
			    float3 color : COLOR0;
			    float2  uv : TEXCOORD0;

			};
			
			float4 _MainTex_ST;
	
			v2f vert (appdata_base v)
			{
			    v2f o;
			    o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
			    o.uv = TRANSFORM_TEX (v.texcoord, _MainTex);
                o.uv.x += _Time*cloudSpeedX;
                o.uv.y += _Time*cloudSpeedY;
                o.color = _MainColor;

			    return o;
			}
			
			half4 frag (v2f i) : COLOR
			{
			    half4 texcol = tex2D (_MainTex, i.uv);

			    return texcol* half4 (i.color, 1);;

			}
			ENDCG
            
        }

    }
    FallBack "Unlit/Transparent"
}
