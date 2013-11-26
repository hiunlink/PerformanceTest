// Double Side(Cull off) + alpha test + alpha blend + self-illumin + half-light + Diffuse
// Nic@atlantis

Shader "Custom/OneSidedAlpha"
{
	Properties
	{
		_Color ("Main Color", Color) = (1,1,1,1)
		_MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
		_Cutoff ("Alpha cutoff", float) = 0.5
		_SelfLight("Self Light Effect", float) = 0.5
		_LightEff ("Light Effect", float) = 0.5
	}

	SubShader
	{
		Tags
		{
			//alpha test 
			"Queue"="AlphaTest" 
			//"IgnoreProjector"="True"
			"RenderType"="TransparentCutout"
		}
		LOD 200
		//cull off //Double Side
		
		CGPROGRAM
		#pragma surface surf SimpleLambert alphatest:_Cutoff

		sampler2D _MainTex;
		fixed4 _Color;
		float _LightEff;
		float _SelfLight;
		
		struct Input {
			float2 uv_MainTex;
		};
		
		void surf (Input IN, inout SurfaceOutput o)
		{
			half4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			o.Emission = c.rgb * _SelfLight;//self-illumin
			o.Alpha = c.a;
		}
      	
		half4 LightingSimpleLambert (SurfaceOutput s, half3 lightDir, half atten)
		{
			half NdotL = dot (s.Normal, lightDir);
			half diffu = NdotL * _LightEff + (_LightEff );
			half4 c;
			c.rgb = s.Albedo * _LightColor0.rgb * (diffu * atten * 2);
			c.a = s.Alpha;
			return c;
      	}


		
		ENDCG
	}
	//FallBack "Custom/Transparent Cutout"
	FallBack "Transparent/Cutout/Diffuse" //改成這樣才會有正確的影子
	//FallBack "Diffuse"
}