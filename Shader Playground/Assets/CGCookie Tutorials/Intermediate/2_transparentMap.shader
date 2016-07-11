﻿Shader "_Custom/CGCookie Tutorials/Intermediate/2 - Transparent Map" {

	Properties {
		_Color ("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_transMap ("Transparency (A)", 2D) = "white" {}
		_AlphaScale ("Alpha Sclae", Range(0.0, 1.0)) = 1.0
	}

	SubShader {
		Tags {"Queue" = "Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha
		Pass {
			Cull Off
			zWrite Off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			// user defined variables
			uniform float4 _Color;
			uniform sampler2D _transMap;
			uniform float4 _transMap_ST;
			uniform float _AlphaScale;

			// base input structs
			struct vertexInput {
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
			};
			struct vertexOutput {
				float4 pos : SV_POSITION;
				float4 tex : TEXCOORD1;
			};

			// vertex function
			vertexOutput vert(vertexInput v) {
				vertexOutput o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.tex = v.texcoord;
				return o;
			}

			// fragment function
			float4 frag(vertexOutput i) : COLOR {
				// texture Maps
				float4 tex = tex2D(_transMap, _transMap_ST.xy * i.tex.xy + _transMap_ST.zw);
				float alpha = tex.a * _Color.a * _AlphaScale;

				return float4(_Color.xyz, alpha);
			}


			ENDCG
		}
	}

	//Fallback "Diffuse"
}