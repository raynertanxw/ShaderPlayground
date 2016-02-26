Shader "_Custom/CGCookie Tutorials/Intro To Shaders/Diffuse Texture" {

	Properties {
		// varName("Display Name", Type) = Starting value {}
		_MainTex("Diffuse Texture", 2D) = "white" {}
//		_BumpTex("Normal Map", 2D) = "bump" {}
//		_ColorTint("Color Tint", Color) = (1,1,1,1)
//		_TintValue("Tint Intensity", Range(0.0, 1.0)) = 0.4
		_Darkness("Darkness", Range(0.0, 1.0)) = 0
//		_Coord("Vector Coord", Vector) = (1,1,1,1)
//		_Cube("Cube Map", Cube) = "" {}
	}

	SubShader {
		Tags { "Rendertype" = "Opaque" }
		CGPROGRAM
		#pragma surface surf Lambert

		struct Input {
			float2 uv_MainTex;
		};
		float _Darkness;
		sampler2D _MainTex;
//		float4 _ColorTint;

		void surf (Input IN, inout SurfaceOutput o) {
			o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb * (1-_Darkness);
		}

		ENDCG
	}
	Fallback "Diffuse"
}