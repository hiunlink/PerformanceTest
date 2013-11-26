// Unlit alpha-blended shader.
// - no lighting
// - no lightmap support

Shader "Custom/UnlitTransparentColored" {
Properties {
    _Color ("Text Color", Color) = (1,1,1,1)
	_MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
}

SubShader {
	Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="TransparentCutout"}
	LOD 100
	
	ZWrite Off Fog { Mode Off }
	Blend SrcAlpha OneMinusSrcAlpha 

	Pass {
		Lighting Off
		SetTexture [_MainTex] { constantColor[_Color] combine constant, texture alpha } 
	}
}
}

