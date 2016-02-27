Shader "_Custom/CGCookie Tutorials/Intro To Shaders/Bumped Specular" {

	Properties {
		// varName("Display Name", Type) = Starting value {}
		_MainTex("Diffuse Texture", 2D) = "white" {}
		_BumpTex("Normal Map", 2D) = "bump" {}
		_SpecColor("Specular Color", Color) = (1,1,1,1)
		_SpecPower("Specular Power", Range(0,2)) = 0.5
//		_ColorTint("Color Tint", Color) = (1,1,1,1)
//		_TintValue("Tint Intensity", Range(0.0, 1.0)) = 0.4
//		_Darkness("Darkness", Range(0.0, 1.0)) = 0
//		_Coord("Vector Coord", Vector) = (1,1,1,1)
//		_Cube("Cube Map", Cube) = "" {}
	}

	SubShader {
		Tags { "Rendertype" = "Opaque" }
		CGPROGRAM
		#pragma surface surf BlinnPhong

		struct Input {
			float2 uv_MainTex;
			float2 uv_BumpTex;
			INTERNAL_DATA
		};

		sampler2D _MainTex;
		sampler2D _BumpTex;
		float _SpecPower;

		void surf (Input IN, inout SurfaceOutput o) {
			fixed4 tex = tex2D(_MainTex, IN.uv_MainTex);
			o.Albedo = tex.rgb;
			o.Normal = UnpackNormal(tex2D(_BumpTex, IN.uv_BumpTex));
			o.Specular = _SpecPower;
			o.Gloss = tex.a;
		}

		ENDCG
	}
	Fallback "Diffuse"
}