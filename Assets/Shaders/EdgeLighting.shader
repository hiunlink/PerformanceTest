Shader "Custom/EdgeLighting" {
   Properties {
      _Color ("Main Color", Color) = (1,1,1,1)
      _RimColor ("Rim Color", Color) = (1,1,1,1)
      _MainTex ("Texture", 2D) = "white" {}
//      _BumpMap ("Bumpmap", 2D) = "bump" {}
      _LightAffectFactor("Light Affect Factor", float) = 0.6
      _SelfLightFactor("Self Illumin Factor", float) = 0.8
      _RimPower ("Rim Power", float) = 3.0
      _RimWidth ("Rim Width", float) = 1.0
      _AffectedByCameraFac ("Affected By Camera (0,1)", float) = 0
      _Cutoff ("Alpha cutoff", float) = 0.1
      _EdgeLength ("Edge length", Range(3,50)) = 6
	  _Smoothness ("Smoothness", Range(0,1)) = 0.5
    }
    
    CGINCLUDE
    #include "Tessellation.cginc"
    struct appdata {
			float4 vertex : POSITION;
			float4 tangent : TANGENT;
			float3 normal : NORMAL;
			float2 texcoord : TEXCOORD0;
			float2 texcoord1 : TEXCOORD1;
		};
		struct Input {
          float2 uv_MainTex;
//          float2 uv_BumpMap;
          float3 viewDir;
          //float3 screenPos;
      };
      sampler2D _MainTex;
//      sampler2D _BumpMap;
      float4 _RimColor;
      float _RimPower; 
      float _RimWidth;
      fixed4 _Color;
      float _LightAffectFactor;
      float _SelfLightFactor;
      float _AffectedByCameraFac;
      
      inline fixed4 LightingCustomLambert (SurfaceOutput s, fixed3 lightDir, fixed atten)
	  {
		  	fixed diff = max (0, dot (s.Normal, lightDir));
			fixed4 c;
			c.rgb = _LightAffectFactor*s.Albedo * _LightColor0.rgb * (diff * atten * 2);
			c.a = s.Alpha;
			return c;
	  }
	  
	   void vert (inout appdata v) {
		   // Transform to camera space
		   //UNITY_INITIALIZE_OUTPUT(Input,o);
		 }

      void surf (Input IN, inout SurfaceOutput o) {

          fixed4 tex = tex2D(_MainTex, IN.uv_MainTex);
		  fixed4 c = tex * _Color;
	  
		  o.Albedo = c.rgb;
//		  o.Normal = UnpackNormal (tex2D (_BumpMap, IN.uv_BumpMap));
		  half rim = _RimWidth - abs(dot (normalize(IN.viewDir), o.Normal));
		  
		  //根據鏡頭遠鏡調整rim lighting
	      float distance = (1);//- IN.screenPos.z * 0.075);
          //if(distance < 0)
          //    distance = 0;
		  _RimColor.rgb = _RimColor.rgb*(_AffectedByCameraFac+distance);

		  o.Emission = _SelfLightFactor*(c.rgb+_RimColor.rgb * pow (abs(rim), _RimPower));
		  o.Alpha = c.a;
		  
		  #ifdef SHADER_API_D3D11
		  clip(c.a-0.1);	
		  #endif	
      }
      float _Smoothness;
		float _EdgeLength;
		float4 tessEdge (appdata v0, appdata v1, appdata v2)
		{

		if(_EdgeLength < 50)
			return UnityEdgeLengthBasedTessCull (v0.vertex, v1.vertex, v2.vertex, _EdgeLength, 0.0);
		else
			return 1;
		
		}
    ENDCG

	SubShader {
      Tags 
      {  
         "Queue"="AlphaTest"  
         "RenderType" = "TransparentCutout" 
      }
      LOD 450
      cull off
      AlphaTest Greater 0.1
      //Blend SrcAlpha OneMinusSrcAlpha
      // Render into depth buffer only
//	    Pass {
//	        ColorMask 0
//	    }
      CGPROGRAM
      #pragma surface surf CustomLambert noambient vertex:vert tessellate:tessEdge tessphong:_Smoothness
      ENDCG
    } 

    SubShader {
      Tags 
      {  
         "Queue"="AlphaTest"  
         "RenderType" = "TransparentCutout" 
      }
      LOD 200
      cull off
      AlphaTest Greater 0.1
      //Blend SrcAlpha OneMinusSrcAlpha
      // Render into depth buffer only
//	    Pass {
//	        ColorMask 0
//	    }
      CGPROGRAM
      #pragma surface surf CustomLambert noambient vertex:vert
      ENDCG
    } 

    FallBack "Transparent/Cutout/Diffuse"
}
