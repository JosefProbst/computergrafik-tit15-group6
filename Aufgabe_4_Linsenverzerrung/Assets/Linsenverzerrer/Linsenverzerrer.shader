Shader "Custom/Linsenverzerrer" {
	Properties {
		_K1("K1", Float) = 1.0
		_K2("K2", Float) = 1.0
		_P1("P1", Float) = 1.0
		_P2("P2", Float) = 1.0
	}
	SubShader{
			Tags{ "RenderType" = "Opaque" }
		LOD 100

		GrabPass { "_GrabTexture" }

		Pass
		{
			CGPROGRAM
            // Upgrade NOTE: excluded shader from DX11; has structs without semantics (struct v2f members grabPos)
            #pragma exclude_renderers d3d11
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct v2f
			{
				float4 grabPos : TEXCOORD0;
				//float4 grabPosDistorted : TEXCOORD1;
				float4 pos : SV_POSITION;
			};

			sampler2D _GrabTexture;
			float _K1;
			float _K2;
			float _P1;
			float _P2;

			v2f vert(appdata_base v) {
				v2f o;
				float4 camSpace = mul(UNITY_MATRIX_MV, v.vertex); 
				
				float origX = camSpace.x;
				float origY = -camSpace.y; // change direction of y-axle for the equation
				float r2 = (origX * origX) + (origY * origY);
				
				camSpace.x = origX + origX * (_K1*r2 + _K2 * r2*r2) + (_P1*(r2 + 2 * origX*origX) + 2 * _P2*origX*origY);
				camSpace.y = origY + origY * (_K1*r2 + _K2 * r2*r2) + (_P1*(r2 + 2 * origY*origY) + 2 * _P2*origX*origY);
				
				camSpace.y = -camSpace.y; // undo direction change of y-axle
			    
			    
				o.pos = mul(UNITY_MATRIX_P, camSpace);
				o.grabPos = ComputeGrabScreenPos(UnityObjectToClipPos(v.vertex));

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 bgcolor = tex2Dproj(_GrabTexture, UNITY_PROJ_COORD(i.grabPos));
				return bgcolor;
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
