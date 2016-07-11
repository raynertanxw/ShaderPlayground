﻿Shader "_Custom/CGCookie Tutorials/Intermediate/3a - Cubemap Reflections" {

	Properties {
		_Cube ("Cube Map", Cube) = "" {}
	}

	SubShader {
		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			// user defined variables
			uniform samplerCUBE _Cube;

			// Base input structs
			struct vertexInput {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
			struct vertexOutput {
				float4 pos : SV_POSITION;
				float3 normalDir : TEXCOORD0;
				float3 viewDir : TEXCOORD1;
			};

			// vertex function
			vertexOutput vert(vertexInput v) {
				vertexOutput o;

				o.normalDir = normalize( mul( float4(v.normal, 0.0), _World2Object) ).xyz;
				o.viewDir = float3(mul(_Object2World, v.vertex) - _WorldSpaceCameraPos.xyz);

				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				return o;
			}

			float4 frag(vertexOutput i) : COLOR {

				// reflect the ray based on the normals to get the cub coordinates
				float3 reflectDir = reflect(i.viewDir, i.normalDir);

				// texture maps
				float4 texC = texCUBE(_Cube, reflectDir);

				return texC;
			}

			ENDCG
		}
	}

	//Fallback "Diffuse"
}