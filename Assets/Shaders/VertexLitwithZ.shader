Shader "Custom/VertexLitwithZ"
{
	Properties
	{
    	_Color ("Main Color", Color) = (1,1,1,1)
    	_MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
	}

	SubShader
	{
    	Tags
    	{
    		//"RenderType"="Transparent"
    		//"Queue"="Transparent"
    		"Queue"="Transparent"
			//"IgnoreProjector"="True"
			"RenderType"="TransparentCutout"
    	}
    	LOD 200
		cull off
    	// Render into depth buffer only
    	//Pass
    	//{
        //	ColorMask 0
    	//}
    	// Render normally
    	Pass
    	{
    		//Cull off
        	//ZWrite Off
        	//Blend One OneMinusSrcAlpha
        	Blend SrcAlpha OneMinusSrcAlpha
        	//Blend SrcAlpha SrcAlpha
        	//Blend SrcAlpha One
        	//Blend One One
        	ColorMask RGB
        	AlphaTest Greater 0.5
        	Material
        	{
            	Diffuse [_Color]
            	Ambient [_Color]
            	Emission [_Color]
        	}
        	//Lighting On
        	//SetTexture [_MainTex]
        	//{
            //	Combine texture * primary DOUBLE, texture * primary	
        	//}
        	SetTexture[_MainTex]
        	{
        		//Combine texture * constant ConstantColor[_Color]
        		//Combine texture, texture;
        	}
    	}
	}
}
