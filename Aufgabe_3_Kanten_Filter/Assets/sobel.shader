Shader "Unlit/BlurShader2D"
{
		SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		// "Queue"="Transparent": Draw ourselves after all opaque geometry
		// "IgnoreProjector"="True": Don't be affected by any Projectors
		// "RenderType"="Transparent": Declare RenderType as transparent
		Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }

		// Grab the screen behind the object into Default _GrabTexture
		// https://docs.unity3d.com/Manual/SL-GrabPass.html
		GrabPass
	{
	}

	Pass
	{
		CGPROGRAM
#pragma vertex vert
#pragma fragment frag

#include "UnityCG.cginc"

		struct appdata
	{
		float4 vertex : POSITION;
		float2 uv : TEXCOORD0;
	};

	struct v2f
	{
		float4 pos : SV_POSITION;
		float4 grabPosUV : TEXCOORD0;
	};

	// VERTEX SHADER
	v2f vert(appdata v)
	{
		v2f o;

		// use UnityObjectToClipPos from UnityCG.cginc to calculate 
		// the clip-space of the vertex
		o.pos = UnityObjectToClipPos(v.vertex);

		// use ComputeGrabScreenPos function from UnityCG.cginc
		// to get the correct texture coordinate
		o.grabPosUV = ComputeGrabScreenPos(o.pos);
		return o;
	}

	// define effect variables to use in Fragement Shader
	sampler2D _GrabTexture;

	// Size information needed to access the pixels of the texture 
	// https://docs.unity3d.com/Manual/SL-PropertiesInPrograms.html
	float4 _GrabTexture_TexelSize;


	// FRAGMENT SHADER
	half4 frag(v2f i) : SV_Target
	{

		// Method to accumulate pixels in x direction
		// x-Texture-Coord + Texel-Size * Kernel-Offset * Factor
#define ADDPIXEL(weight, kernelX, kernelY) tex2D(_GrabTexture, float2(i.grabPosUV.x + _GrabTexture_TexelSize.x * kernelX, \
                											 		  i.grabPosUV.y + _GrabTexture_TexelSize.y * kernelY)) * weight

		// https://www.taylorpetrick.com/portfolio/webgl/convolution?preset=2&mode=1

		half4 pixelColX = half4(0, 0, 0, 0);

		// row 1
		pixelColX += ADDPIXEL(1, -1.0, -1.0);
		//pixelColX += ADDPIXEL(0, 0.0, -1.0);
		pixelColX += ADDPIXEL(-1, 1.0, -1.0);

		// row 2
		pixelColX += ADDPIXEL(2, -1.0, 0.0);
		//pixelColX += ADDPIXEL(0, 0.0, 0.0);
		pixelColX += ADDPIXEL(-2, 1.0, 0.0);


		// row 3
		pixelColX += ADDPIXEL(1, -1.0, 1.0);
		//pixelColX += ADDPIXEL(0, 0.0, 1.0);
		pixelColX += ADDPIXEL(-1, 1.0, 1.0);

		
		//----------------------------------

		half4 pixelColY = half4(0, 0, 0, 0);

		// row 1
		pixelColY += ADDPIXEL(1, -1.0, -1.0);
		pixelColY += ADDPIXEL(2, 0.0, -1.0);
		pixelColY += ADDPIXEL(1, 1.0, -1.0);

		// row 2
		//pixelColY += ADDPIXEL(0, -1.0, 0.0);
		//pixelColY += ADDPIXEL(0, 0.0, 0.0);
		//pixelColY += ADDPIXEL(0, 1.0, 0.0);

		// row 3
		pixelColY += ADDPIXEL(-1, -1.0, 1.0);
		pixelColY += ADDPIXEL(-2, 0.0, 1.0);
		pixelColY += ADDPIXEL(-1, 1.0, 1.0);


		float cX = (pixelColX[0] + pixelColX[1] + pixelColX[2]) / 3;
		float cY = (pixelColY[0] + pixelColY[1] + pixelColY[2]) / 3;
		
		float c = sqrt(cX * cX + cY * cY);
		half4 pixelCol = half4(c, c, c, 0);

		return pixelCol;
	}
		ENDCG
	}
	}
}
