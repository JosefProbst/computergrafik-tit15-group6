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
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct v2f
			{
				float4 grabPos : TEXCOORD;
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
				i.grabPos.x = i.grabPos.x - 0.5;
				i.grabPos.y = i.grabPos.y - 0.5;

				float origX = i.grabPos.x;
				float origY = -(i.grabPos.y);
				float r2 = (origX * origX) + (origY * origY);
				i.grabPos.x = origX + origX * (_K1*r2 + _K2 * r2*r2) + (_P1*(r2 + 2 * origX*origX) + 2 * _P2*origX*origY);
				i.grabPos.y = -(origY + origY * (_K1*r2 + _K2 * r2*r2) + (_P1*(r2 + 2 * origY*origY) + 2 * _P2*origX*origY));

				//center coordinates int the bottom left corner again
				i.grabPos.x = i.grabPos.x + 0.5;
				i.grabPos.y = i.grabPos.y + 0.5;

				fixed4 bgcolor = tex2Dproj(_GrabTexture, UNITY_PROJ_COORD(i.grabPos));
				return bgcolor;
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
