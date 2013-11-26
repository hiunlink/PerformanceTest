Shader "Hidden/DetectFragmentPrograms" {
SubShader {
	Pass {
			
CGPROGRAM
// Upgrade NOTE: excluded shader from OpenGL ES 2.0 because it does not contain a surface program or both vertex and fragment programs.
#pragma exclude_renderers gles
#pragma fragment frag
half4 frag() : COLOR { return 0; }
ENDCG

	}
} 
Fallback Off
}
