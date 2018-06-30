// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

/*
    Shader to perform vertex deformation on collision impact
    
*/
Shader "Unlit/ForceDeformationShader"
{
    //Shader parameters
	Properties
	{
        _CollisionSourcePoint ("Collision source point",Vector) = (0,0,0)
        _lastCollisionTime ("Last collision time (in sec)", float) = 0
        _CollisionDirectionNormal ("Collision direction normal",Vector) = (0,0,0)
        _DeformationFactor("The material's deformation factor", float ) = 0
		_MainTex ("Texture", 2D) = "white" {}
		
		
		_DiffuseTint ( "Diffuse Tint", Color) = (1, 1, 1, 1)
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }

		Pass
		{
    		Tags {"LightMode" = "ForwardBase"}
	
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
            #pragma multi_compile_fwdbase
            
            #include "AutoLight.cginc"
			#include "UnityCG.cginc"
			
			
			
			struct v2f
			{
				float4 pos : SV_POSITION;
                float3 lightDir : TEXCOORD0;
				float3 normal : TEXCOORD1;
				float2 uv : TEXCOORD2;
				LIGHTING_COORDS(3, 4)
                
			};

            /*
                Deformation logic
            */
			float4 _CollisionSourcePoint;
			float4 _CollisionDirectionNormal;
			float _lastCollisionTime;
			float _DeformationFactor;
			
			
		    /*
		        lighting stuff
		    */	
            sampler2D _MainTex;
			float4 _MainTex_ST;            
			float4 _DiffuseTint;
			float4 _LightColor0;
			
			
			v2f vert (appdata_full v)
			{
				v2f o;
                float4 worldVertex = mul(unity_ObjectToWorld, v.vertex);
				float4 newWorldVertex = worldVertex;
				
				//process deformation only if projectile radius is sufficient - 0 size = no deformation seems quite natural - prevents processing when default value. 
                if(_DeformationFactor > 0){
                    //check if we still calculate the deformation
                    if(_Time.y < ( _lastCollisionTime + 5 ) ){
                        //calculate the distance vector between the collision point and the currently processed vertice
                        float4 distanceVector = worldVertex - _CollisionSourcePoint;
                        //get length scalar of distance
                        float distance = length(distanceVector);
                        //using gaussian normal distribution to simulate harmonic deformation arround collision source point
                        float force = _DeformationFactor*exp(-(distance*distance));
                        //prepare new deformation vertice with the calculated force in the direction the collision impact took place
                        newWorldVertex = newWorldVertex - (force)*_CollisionDirectionNormal;
                    }
				}
				//calculate position in objectspace
                o.pos = mul(UNITY_MATRIX_VP, newWorldVertex);
                //apply the provided texture
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				
				
				/*
				    Following code section is from: https://gamasutra.com/blogs/JoeyFladderak/20140416/215612/Let_there_be_shadow.php    
                */
				o.lightDir = normalize(ObjSpaceLightDir(v.vertex));
				o.normal = normalize(v.normal).xyz;
				TRANSFER_VERTEX_TO_FRAGMENT(o);
				return o;
			}
			
			fixed4 frag (v2f i) : Color
			{
				/*
				    Following code section is from: https://gamasutra.com/blogs/JoeyFladderak/20140416/215612/Let_there_be_shadow.php    
                */
                float3 L = normalize(i.lightDir);
				float3 N = normalize(i.normal);	 
				float attenuation = LIGHT_ATTENUATION(i) * 2;
				float4 ambient = UNITY_LIGHTMODEL_AMBIENT * 2;
				float NdotL = saturate(dot(N, L));
				float4 diffuseTerm = NdotL * _LightColor0 * _DiffuseTint * attenuation;
			
				float4 diffuse = tex2D(_MainTex, i.uv);
				return (ambient + diffuseTerm) * diffuse;
			}
        
			ENDCG
		}
	}
	//use shadow casting from diffuse shader passes
    FallBack "Diffuse"
}
