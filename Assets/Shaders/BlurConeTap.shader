Shader "Hidden/BlurConeTap" {
	Properties 
	{ 
		_MainTex ("", any) = "" {} 
		_Cutoff ("Alpha cutoff", Range(0,1)) = 0.1
	}
	SubShader 
	{
		Pass 
		{
			ZTest Always Cull Off ZWrite Off Lighting Off 
			Fog { Mode Off}
			//Alphatest Greater [_Cutoff]
			SetTexture [_MainTex] {constantColor (0,0,0,0.25) combine texture * constant alpha}
			SetTexture [_MainTex] {constantColor (0,0,0,0.25) combine texture * constant + previous}
			SetTexture [_MainTex] {constantColor (0,0,0,0.25) combine texture * constant + previous}
			SetTexture [_MainTex] {constantColor (0,0,0,0.25) combine texture * constant + previous}
		}
	}
	Fallback off
}
