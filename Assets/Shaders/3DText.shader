Shader "GUI/3D Text Shader" { 

Properties { 
   _MainTex ("Font Texture", 2D) = "white" {} 
   _Color ("Text Color", Color) = (1,1,1,1) 
} 

SubShader {

		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
		LOD 200
		
		Lighting Off Cull Off ZWrite Off Fog { Mode Off }
		Offset 0, -3
		Blend SrcAlpha OneMinusSrcAlpha     

		Pass {	
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest

			#include "UnityCG.cginc"

			struct v2f {
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
			};

			sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform float4 _Color;

			v2f vert (appdata_base v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
			#ifdef SHADER_API_D3D11
				o.vertex.xy += float2(1,-1) / _ScreenParams.xy;
			#endif
				o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTex);

				return o;
			}

			half4 frag (v2f i) : COLOR
			{
				float4 col = _Color;
				col.a *= tex2D(_MainTex, i.texcoord ).a * 1.75;
				//col.a = col.a + 0.05;
				//col.rgb = tex2D(_MainTex, i.texcoord).rgb;//my custom line that did not have any result 
				return col;
			}
			ENDCG 
		}
	} 	
    
    FallBack "Custom/UnlitTransparentColored"

}


