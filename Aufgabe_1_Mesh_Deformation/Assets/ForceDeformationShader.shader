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
        _CollisionSourcePoint ("CollisionSourcePoint",Vector) = (0,0,0)
        _lastCollisionTime ("_lastCollisionTime", float) = 0
        _CollisionDirectionNormal ("Collision Direction Normal",Vector) = (0,0,0)
        _Force("Impact force", float ) = 0
		_MainTex ("Texture", 2D) = "white" {}
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

			#include "UnityCG.cginc"
			
			struct v2f
			{
                float2 uv : TEXCOORD0;
				float4 pos : SV_POSITION;
			};

			float4 _CollisionSourcePoint;
			float4 _CollisionDirectionNormal;
			float _lastCollisionTime;
			float _Force;
			
            sampler2D _MainTex;
			float4 _MainTex_ST;

			
			v2f vert (appdata_full v)
			{
				v2f o;
                float4 worldVertex = mul(unity_ObjectToWorld, v.vertex);
				float4 newWorldVertex = worldVertex;
				
				//process deformation only if projectile radius is sufficient
                if(_Force > 0){
                    if(_Time.y < ( _lastCollisionTime + 5 ) ){
                        float4 diff = worldVertex - _CollisionSourcePoint;
                        
                        float distance = length(diff);
                        //using gaussian normal distribution to simulate harmonic deformation arround collision source point
                        float force = _Force*exp(-(distance*distance));
                        newWorldVertex = newWorldVertex - (force)*_CollisionDirectionNormal;
                    }
				}
                o.pos = mul(UNITY_MATRIX_VP, newWorldVertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
				// apply fog
				//UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
        
			ENDCG
		}
	}

}
