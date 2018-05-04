Shader "GrabPassInvert"
{
	SubShader
	{
		// Draw ourselves after all opaque geometry
		Tags{ "Queue" = "Transparent" }

		// Grab the screen behind the object into _BackgroundTexture
		GrabPass
	{
		"_BackgroundTexture"
	}

		// Render the object with the texture generated above, and invert the colors
		Pass
	{
		CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"

		struct v2f
	{
		float4 grabPos : TEXCOORD0;
		float4 pos : SV_POSITION;
	};

	v2f vert(appdata_base v) {
		v2f o;
		// use UnityObjectToClipPos from UnityCG.cginc to calculate 
		// the clip-space of the vertex
		o.pos = UnityObjectToClipPos(v.vertex);
		// use ComputeGrabScreenPos function from UnityCG.cginc
		// to get the correct texture coordinate
		o.grabPos = ComputeGrabScreenPos(o.pos);
		return o;
	}

	sampler2D _BackgroundTexture;

	half4 frag(v2f i) : SV_Target
	{
		half4 bgcolor = tex2Dproj(_BackgroundTexture, i.grabPos);

		float tr = 0.393 * bgcolor.r + 0.769 * bgcolor.g + 0.189 * bgcolor.b;
		float tg = 0.349 * bgcolor.r + 0.686 * bgcolor.g + 0.168 * bgcolor.b;
		float tb = 0.272 * bgcolor.r + 0.534 * bgcolor.g + 0.131 * bgcolor.b;

		if(tr > 1) {
			bgcolor.r = 1;
		}
		else {
			bgcolor.r = tr;
		}

		if(tg > 1) {
			bgcolor.g = 1;
		}
		else {
			bgcolor.g = tg;
		}

		if(tb > 1) {
			bgcolor.b = 1;
		}
		else {
			bgcolor.b = tb;
		}
		


		return bgcolor;
	}
		ENDCG
	}

	}
}