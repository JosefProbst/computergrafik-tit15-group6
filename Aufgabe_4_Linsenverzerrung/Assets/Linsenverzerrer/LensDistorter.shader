// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/LensDistorter" {
	Properties {
		_K1("K1", Range(-5, 5)) = 0
		_K2("K2", Range(-5, 5)) = 0
		_P1("P1", Range(-5, 5)) = 0
		_P2("P2", Range(-5, 5)) = 0
	}
	SubShader{
	
	    ZTest Always
	    Zwrite Off
	
		Tags{ "Queue"="Transparent" }

		GrabPass { "_GrabTexture" }

		Pass
		{
			CGPROGRAM
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
				o.pos = UnityObjectToClipPos(v.vertex);
				o.grabPos = ComputeGrabScreenPos(o.pos);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				//center coordinates in the middle of the texture
				float xu = i.grabPos.x - 0.5;
				float yu = -(i.grabPos.y - 0.5);

				
				float r2 = (xu * xu) + (yu * yu);
				float xd = xu - xu * (_K1*r2 + _K2 * r2*r2) + (_P1*(r2 + 2 * xu*xu) + 2 * _P2*xu*yu);
				float yd = yu - yu * (_K1*r2 + _K2 * r2*r2) + (_P1*(r2 + 2 * yu*yu) + 2 * _P2*yu*yu);

				float2 distortedPosition;
				distortedPosition.x = xd + 0.5;
				distortedPosition.y = (-yd) + 0.5;

				return tex2D(_GrabTexture, distortedPosition);
            }
			ENDCG
		}
	}
	FallBack "Diffuse"
}
