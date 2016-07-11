Shader "_Custom/SpecularOutline" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0

		[Header(Outline Properties)]
		_OutlineColor ("Outline Color", Color) = (0.0, 0.0, 0.0, 1.0)
		_OutlineThickness ("Outline Thickness", Range(0.0, 0.1)) = 0.03
	}
	SubShader {

		// Drawing of the outline.
		Pass {
			Tags {"RenderType"="Opaque"}
			Cull Front
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			//user defined variables
			uniform fixed4 _OutlineColor;
			uniform fixed _OutlineThickness;

			//base input structs
			struct vertexInput{
				half4 vertex : POSITION;
				fixed3 normal : NORMAL;
			};
			struct vertexOutput{
				half4 pos : SV_POSITION;
				fixed4 color : COLOR;
			};
			
			//vertex Function
			vertexOutput vert(vertexInput v){
				vertexOutput o;

				half4 newVertex = v.vertex + fixed4(v.normal * _OutlineThickness, 0.0);
				o.pos = mul(UNITY_MATRIX_MVP, newVertex);
				o.color = _OutlineColor;
				
				return o;
			}
			
			//fragment function
			fixed4 frag(vertexOutput i) : COLOR
			{
				return fixed4(i.color);
			}
			
			ENDCG
			
		}

		Pass {
			Tags {"LightMode" = "ForwardBase"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			// user defined variables
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform float4 _Color;
			uniform float4 _SpecColor;
			uniform float4 _RimColor;
			uniform float _Shininess;
			uniform float _RimPower;

			// unity defined variables
			uniform float4 _LightColor0;

			// base input structs
			struct vertexInput {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
			};
			struct vertexOutput {
				float4 pos : SV_POSITION;
				float4 tex : TEXCOORD0;
				float4 posWorld : TEXCOORD1;
				float3 normalDir : TEXCOORD2;
			};

			// vertex function
			vertexOutput vert(vertexInput v) {
				vertexOutput o;

				o.posWorld = mul(_Object2World, v.vertex);
				o.normalDir = normalize( mul( float4(v.normal, 0.0), _World2Object ).xyz );
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.tex = v.texcoord;

				return o;
			}

			// fragment function
			float4 frag(vertexOutput i) : COLOR {
				float3 normalDirection = i.normalDir;
				float3 viewDirection = normalize( _WorldSpaceCameraPos.xyz - i.posWorld.xyz );
				float3 lightDirection;
				float atten;

				if (_WorldSpaceLightPos0.w == 0.0) {
					atten = 1.0;
					lightDirection = normalize(_WorldSpaceLightPos0.xyz);
				}
				else {
					float3 fragmentToLightSource = _WorldSpaceLightPos0.xyz - i.posWorld.xyz;
					float distance = length(fragmentToLightSource);
					atten = 1.0/distance;
					lightDirection = normalize(fragmentToLightSource);
				}

				// Lighting
				float3 diffuseReflection = atten * _LightColor0.xyz * saturate(dot(normalDirection, lightDirection));
				float3 specularReflection = diffuseReflection * _SpecColor.xyz * pow( saturate( dot( reflect(-lightDirection, normalDirection), viewDirection)), _Shininess);

				// Rim Lighting
				float rim = 1 - saturate(dot(viewDirection, normalDirection));
				float3 rimLighting = saturate( dot(normalDirection, lightDirection) * _RimColor.xyz * _LightColor0.xyz * pow(rim, _RimPower) );

				float3 lightFinal = UNITY_LIGHTMODEL_AMBIENT.xyz + diffuseReflection + specularReflection + rimLighting;

				// Texture Maps
				float4 tex = tex2D(_MainTex, i.tex.xy * _MainTex_ST.xy + _MainTex_ST.zw);

				return float4(tex.xyz * lightFinal * _Color.xyz, 1.0);
			}

			ENDCG
		}

	}
	FallBack "Specular"
}
