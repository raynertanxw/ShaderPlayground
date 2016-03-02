﻿Shader "_Custom/CGCookie Tutorials/Beginner/4 - Rim Lighting" {

	Properties {
		_Color ("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_SpecColor ("Specular Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_Shininess ("Shininess", Float) = 10
		_RimColor ("Rim Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_RimPower ("Rim Power", Range(0.1, 10.0)) = 3.0
		_RimStrength ("Rim Strength", Range(0.1, 20.0)) = 1.0
	}

	SubShader {
	Tags { "LightMode" = "ForwardBase" }
		Pass {

			CGPROGRAM
			// pragmas
			#pragma vertex vert
			#pragma fragment frag

			// user defined variables
			uniform float4 _Color;
			uniform float4 _SpecColor;
			uniform float4 _RimColor;
			uniform float _Shininess;
			uniform float _RimPower;
			uniform float _RimStrength;

			// unity defined variables
			uniform float4 _LightColor0;

			// Base input structs
			struct vertexInput {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
			struct vertexOutput {
				float4 pos : SV_POSITION;
				float4 posWorld : TEXCOORD0;
				float3 normalDir : TEXCOORD1;
			};

			// vertex function
			vertexOutput vert(vertexInput v) {
				vertexOutput o;

				o.posWorld = mul(_Object2World, v.vertex);
				o.normalDir = normalize(mul(float4(v.normal, 0.0), _World2Object).xyz);
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);

				return o;
			}

			// fragment function
			float4 frag(vertexOutput i) : COLOR {
				float3 normalDirection = i.normalDir;
				float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
				float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
				float atten = 1.0;

				// lighting
				float diffuseReflection = atten * _LightColor0.xyz * saturate( dot( normalDirection, lightDirection ) );
				float specularReflection = atten * _LightColor0.xyz * saturate( dot( normalDirection, lightDirection ) ) * pow( saturate( dot( reflect(-lightDirection, normalDirection), viewDirection ) ), _Shininess );

				// Rim lighting
				float rim = 1 - saturate(dot(normalize(viewDirection), normalDirection));
				float3 rimLighting = atten * _LightColor0.xyz * _RimColor * saturate(dot(normalDirection, lightDirection)) * pow(rim, _RimPower);

				float3 lightFinal = rimLighting * _RimStrength + diffuseReflection + specularReflection + UNITY_LIGHTMODEL_AMBIENT.rgb;

				return float4(lightFinal * _Color.xyz, 1.0);
			}


			ENDCG
		}
	}

//	Fallback "Diffuse"
}