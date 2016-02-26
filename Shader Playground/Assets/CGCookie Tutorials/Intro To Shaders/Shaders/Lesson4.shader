Shader "_Custom/CGCookie Tutorials/Intro To Shaders/Bumped Diffuse" {

	Properties {
		// varName("Display Name", Type) = Starting value {}
		_MainTex("Diffuse Texture", 2D) = "white" {}
		_BumpTex("Normal Map", 2D) = "bump" {}
//		_ColorTint("Color Tint", Color) = (1,1,1,1)
//		_TintValue("Tint Intensity", Range(0.0, 1.0)) = 0.4
//		_Darkness("Darkness", Range(0.0, 1.0)) = 0
//		_Coord("Vector Coord", Vector) = (1,1,1,1)
//		_Cube("Cube Map", Cube) = "" {}
	}

	SubShader {
		Tags { "Rendertype" = "Opaque" }
		CGPROGRAM
		#pragma surface surf Lambert

		struct Input {
			float2 uv_MainTex;
			float2 uv_BumpTex;
		};

		sampler2D _MainTex;
		sampler2D _BumpTex;

		void surf (Input IN, inout SurfaceOutput o) {
			o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb;
			o.Normal = UnpackNormal(tex2D(_BumpTex, IN.uv_BumpTex));
		}

		ENDCG
	}
	Fallback "Diffuse"
}