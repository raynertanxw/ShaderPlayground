Shader "_Custom/CGCookie Tutorials/Intro To Shaders/Basic Diffuse" {
	SubShader {
		Tags { "Rendertype" = "Opaque" }
		CGPROGRAM
		#pragma surface surf Lambert

		struct Input {
			float4 color : COLOR;
		};

		void surf (Input IN, inout SurfaceOutput o) {
			o.Albedo = 0.5;
		}

		ENDCG
	}
	Fallback "Diffuse"
}