Shader "_Custom/Toon No Alpha"
{
    Properties 
    {
	    [Header(Common Properties)]
        _MainTex ("Base (RGB) Alpha (A)", 2D) = "white" {}
        _Color ("Lit Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_UnlitColor ("Unlit Color", Color) = (0.5, 0.5, 0.5, 1.0)
		_DiffuseThreshold ("Lighting Threshold", Range(0, 1)) = 0.15
		_Diffusion ("Diffusion", Range(0, 0.99)) = 0.4

		[Header(Specular Properties)]
		_SpecColor ("Specular Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_Shininess ("Shininess", Range(0.5, 0.99)) = 0.8
		_SpecDiffusion ("Specular Diffusion", Range(0, 0.99)) = 0.0

        [Header(Outline Properties)]
		_OutlineColor ("Outline Color", Color) = (0.0, 0.0, 0.0, 1.0)
		_OutlineThickness ("Outline Thickness", Range(0.0, 0.1)) = 0.03
    }
    SubShader 
    {
    	// Drawing of the outline.
		Pass {
			Tags {"RenderType" = "Opaque"}
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

				fixed4 newVertex = v.vertex + fixed4(v.normal * _OutlineThickness, 0.0);
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


    
        Tags {"Queue" = "Geometry" "RenderType" = "Opaque"}
        Pass 
        {
            Tags {"LightMode" = "ForwardBase"}                      // This Pass tag is important or Unity may not give it the correct light information.
           		CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                
                #include "UnityCG.cginc"
                #include "AutoLight.cginc"
               
               	struct vertex_input
               	{
               		float4 vertex : POSITION;
               		float3 normal : NORMAL;
               		float2 texcoord : TEXCOORD0;
               	};
                
                struct vertex_output
                {
                    float4  pos         : SV_POSITION;
                    float2  uv          : TEXCOORD0;
                    float3  lightDir    : TEXCOORD1;
                    float3  normal		: TEXCOORD2;
                    LIGHTING_COORDS(3,4)                            // Macro to send shadow & attenuation to the vertex shader.
                	float3  vertexLighting : TEXCOORD5;
                	float3	viewDir		: TEXCOORD6;
                };
                
                sampler2D _MainTex;
                float4 _MainTex_ST;
                fixed4 _Color;
                uniform fixed4 _UnlitColor;
				uniform fixed _DiffuseThreshold;
				uniform fixed _Diffusion;
				uniform fixed4 _SpecColor;
				uniform fixed _Shininess;
				uniform fixed _SpecDiffusion;

                fixed4 _LightColor0; 
                
                vertex_output vert (vertex_input v)
                {
                    vertex_output o;
                    o.pos = mul( UNITY_MATRIX_MVP, v.vertex);
                    o.uv = v.texcoord.xy;
					
					o.lightDir = ObjSpaceLightDir(v.vertex);
					
					o.normal = v.normal;

					o.viewDir = normalize( _WorldSpaceCameraPos.xyz - mul(_Object2World, v.vertex).xyz );
                    
                    TRANSFER_VERTEX_TO_FRAGMENT(o);                 // Macro to send shadow & attenuation to the fragment shader.
                    
                    o.vertexLighting = float3(0.0, 0.0, 0.0);
		            
		            #ifdef VERTEXLIGHT_ON
  					
  					float3 worldN = mul((float3x3)_Object2World, SCALED_NORMAL);
		          	float4 worldPos = mul(_Object2World, v.vertex);
		            
		            for (int index = 0; index < 4; index++)
		            {    
		               float4 lightPosition = float4(unity_4LightPosX0[index], 
		                  unity_4LightPosY0[index], 
		                  unity_4LightPosZ0[index], 1.0);
		 
		               float3 vertexToLightSource = float3(lightPosition - worldPos);        
		               
		               float3 lightDirection = normalize(vertexToLightSource);
		               
		               float squaredDistance = dot(vertexToLightSource, vertexToLightSource);
		               
		               float attenuation = 1.0 / (1.0  + unity_4LightAtten0[index] * squaredDistance);
		               
		               float3 diffuseReflection = attenuation * float3(unity_LightColor[index]) 
		                  * float3(_Color) * max(0.0, dot(worldN, lightDirection));         
		 
		               o.vertexLighting = o.vertexLighting + diffuseReflection * 2;
		            }
		                  
		         
		            #endif
                    
                    return o;
                }
                
                fixed4 frag(vertex_output i) : COLOR
                {
                    i.lightDir = normalize(i.lightDir);
                    fixed atten = LIGHT_ATTENUATION(i); // Macro to get you the combined shadow & attenuation value.
                    
                    fixed4 tex = tex2D(_MainTex, i.uv);
                    tex *= _Color + fixed4(i.vertexLighting, 1.0);

                    fixed nDotL = saturate(dot(i.normal, i.lightDir.xyz));

                    fixed diffuseCutoff = saturate( ( max(_DiffuseThreshold, nDotL) - _DiffuseThreshold ) * pow( (2 - _Diffusion), 10 ) );
                    fixed specularCutoff = saturate( (max(_Shininess, dot(reflect(-i.lightDir.xyz, i.normal), i.viewDir)) - _Shininess ) * pow((2 - _SpecDiffusion), 10));

                    fixed3 diffuseReflection = (1 - specularCutoff) * _Color.xyz * diffuseCutoff;
                    fixed3 specularReflection = _SpecColor.xyz * specularCutoff;

                    fixed3 ambientLight = (1 - diffuseCutoff) * _UnlitColor.xyz;

                    fixed3 lightFinal = (ambientLight + diffuseReflection) + specularReflection;
                                            
                    fixed4 c;
                    c.rgb = (tex.rgb * _LightColor0.rgb * lightFinal) * (atten); // Diffuse and specular.
                    c.rgb += (specularCutoff * (_Shininess - 0.5));
                    c.a = tex.a + _LightColor0.a * atten;
                    return c;
                }
            ENDCG
        }
    }
    //FallBack "VertexLit"    // Use VertexLit's shadow caster/receiver passes.
}