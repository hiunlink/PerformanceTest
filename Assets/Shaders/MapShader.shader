Shader "MapShader"
{
  Properties {
	_Color ("Main Color", Color) = (1,1,1,1)
	_MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
	_MaskTex ("Mask", 2D) = "white" {}
	}

	SubShader
	{
		Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
		Lighting off
		Fog { mode off}
		blend srcalpha oneminussrcalpha
		pass
		{
		settexture[_MainTex] {constantcolor[_Color] combine constant * texture,texture}
		settexture[_MaskTex] {combine Previous,Previous * texture}
		}
	}

	FallBack "Transparent/Diffuse"
}
