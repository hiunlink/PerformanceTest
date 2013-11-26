Shader "Lines/Colored Blended On Top" {
	SubShader { 
		Pass { 
			Blend SrcAlpha OneMinusSrcAlpha 
			ZWrite Off 
			Cull Off 
			ZTest Always
			Fog { Mode Off } 
			BindChannels {
			   Bind "vertex", vertex Bind "color", color 
			}
		}
	  
	} 
}