// Unlit alpha-blended shader.
// - no lighting
// - no lightmap support
// - no per-material color

Shader "Custom/UnlitTransparentNoFog (Z)" {
Properties {
	_MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
}

SubShader {
	Tags {"Queue"="Overlay" "IgnoreProjector"="True" "RenderType"="Opaque"}
	LOD 100
	
	ZWrite Off Fog { Mode Off }
	Blend SrcAlpha OneMinusSrcAlpha 

	Pass {
		Lighting Off
		SetTexture [_MainTex] { combine texture } 
	}
}
}
