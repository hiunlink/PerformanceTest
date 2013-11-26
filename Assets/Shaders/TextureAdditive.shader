Shader "Custom/TextureAdditive" {
	Properties {
        _Color ("Main Color, Alpha", Color) = (1,1,1,1)
        _MainTex ("Base (RGB)", 2D) = "white" {}
    }
    Category {
        ZWrite Off
        Lighting On
        Tags {Queue=Transparent}
        Blend One One
        SubShader {
            Pass {
            Cull Back
            Material {
                Emission [_Color]
            }
            SetTexture [_MainTex] {
                Combine texture * primary, texture + primary 
            } 
        }
    }
 } 
}


