Shader "GUI/3D Text Blood" { 

Properties { 
   _MainTex ("Font Texture", 2D) = "white" {} 
   _Color ("Text Color", Color) = (1,1,1,1) 

} 

SubShader {

		Tags { "Queue"="Transparent+1" "IgnoreProjector"="True" "RenderType"="Transparent" }
		Lighting Off Cull Off ZTest Always Fog { Mode Off }
		Blend SrcAlpha OneMinusSrcAlpha
		//AlphaTest Greater 0.1

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
				o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTex);

				return o;
			}

			half4 frag (v2f i) : COLOR
			{
				float4 col = tex2D(_MainTex, i.texcoord);
				col.rgb = col.rgb*_Color;
				//col.a = col.a * 1.75;
				col.a *= _Color.a;
				//col.rgb = tex2D(_MainTex, i.texcoord).rgb;//my custom line that did not have any result 
				return col;
			}
			ENDCG 
		}
	} 	
    
    FallBack "GUI/Text Shader"

}