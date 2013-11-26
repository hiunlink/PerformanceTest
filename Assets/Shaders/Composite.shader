Shader "Hidden/Composite" {
	Properties 
	{ 
		_MainTex ("", 2D) = "" {} 
		_BlurTex ("", 2D) = "" {} 
		_StencilTex ("", 2D) = "" {} 
		_Cutoff ("Alpha cutoff", Range(0,1)) = 0.1
	}
	SubShader
	{
		Pass
		{
			ZTest Always Cull Off ZWrite Off Lighting Off 
			Fog { Mode off }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			sampler2D _MainTex;
			sampler2D _BlurTex;
			sampler2D _StencilTex;
			uniform float4 _MainTex_TexelSize;
			
			struct appdata_t {
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
				float2 texcoord1 : TEXCOORD1;
			};

			struct v2f {
				float4 vertex : POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
				float2 texcoord1 : TEXCOORD1;
			};

			v2f vert (appdata_t v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.texcoord = v.texcoord;
				
				o.texcoord1 = v.texcoord1;
				#if UNITY_UV_STARTS_AT_TOP
				if(_MainTex_TexelSize.y < 0)
					o.texcoord1.y = 1-o.texcoord1.y;
				#endif
				return o;
			}

			fixed4 frag (v2f i) : COLOR
			{
				fixed4 col = tex2D(_StencilTex, i.texcoord1);
				col = (1-col) * tex2D(_BlurTex, i.texcoord1);
				col =  col + tex2D(_MainTex, i.texcoord);
				return col;
			}
			ENDCG
		}
	}
	SubShader 
	{
		Pass 
		{
			ZTest Always Cull Off ZWrite Off Lighting Off 
			Fog { Mode off }
			//Alphatest Greater [_Cutoff]
			SetTexture [_StencilTex] {combine texture}
			SetTexture [_BlurTex] { combine texture * one - previous  }
			SetTexture [_MainTex] { combine previous + texture }
		}
	}
	Fallback Off
}
