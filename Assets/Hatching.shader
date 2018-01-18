﻿Shader "Unity Shaders Book/Chapter 14/Hatching"
{
	Properties
	{
		_Color("Color Tint", Color) = (1,1,1,1)
		_TileFactor("Tile Factor", float) = 1
		_Outline ("Outline", Range(0, 1)) = 1
		_OutlineColor ("Outline Color", Color) = (0,0,0,1)
		_Hatch0("Hatch 0", 2D) = "white" {}
		_Hatch1("Hatch 1", 2D) = "white" {}
		_Hatch2("Hatch 2", 2D) = "white" {}
		_Hatch3("Hatch 3", 2D) = "white" {}
		_Hatch4("Hatch 4", 2D) = "white" {}
		_Hatch5("Hatch 5", 2D) = "white" {}		
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "Queue"="Geometry"}
		LOD 100

		UsePass "Unity Shaders Book/Chapter 14/Toon Shading/OUTLINE"

		Pass
		{
			Tags { "LightMode"="ForwardBase" }
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;				
				float3 hatchWeights0 : TEXCOORD1;
				float3 hatchWeights1 : TEXCOORD2;
				float3 worldPos : TEXCOORD3;
				SHADOW_COORDS(4)
			};

			fixed4 _Color;
			fixed _Outline;	
			fixed4 _OutlineColor;		
			float _TileFactor;			
			sampler2D _Hatch0;
			sampler2D _Hatch1;
			sampler2D _Hatch2;
			sampler2D _Hatch3;
			sampler2D _Hatch4;
			sampler2D _Hatch5;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);

				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
				fixed3 worldLightDir = normalize(WorldSpaceLightDir(v.vertex));
				fixed diff = max(0, dot(worldLightDir, worldNormal));

				o.hatchWeights0 = fixed3(0,0,0);
				o.hatchWeights1 = fixed3(0,0,0);

				float hatchFactor = diff * 7.0;

				if(hatchFactor > 6.0)
				{
					;
				}
				else if(hatchFactor > 5.0)
				{
					o.hatchWeights0.x = hatchFactor - 5.0;
				}
				else if(hatchFactor > 4.0)
				{
					o.hatchWeights0.x = hatchFactor - 4.0;
					o.hatchWeights0.y = 1.0 - o.hatchWeights0.x;
				}
				else if(hatchFactor > 3.0)
				{
					o.hatchWeights0.y = hatchFactor - 3.0;
					o.hatchWeights0.z = 1.0 - o.hatchWeights0.y;
				}
				else if(hatchFactor > 2.0)
				{
					o.hatchWeights0.z = hatchFactor - 2.0;
					o.hatchWeights1.x = 1.0 - o.hatchWeights0.z;
				}
				else if(hatchFactor > 1.0)
				{
					o.hatchWeights1.x = hatchFactor - 1.0;
					o.hatchWeights1.y = 1.0 - o.hatchWeights1.x;
				}
				else
				{
					o.hatchWeights1.y = hatchFactor;
					o.hatchWeights1.z = 1.0 - o.hatchWeights1.y;
				}

				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				o.uv = v.uv * _TileFactor;

				TRANSFER_SHADOW(o);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 hatchTex0 = tex2D(_Hatch0, i.uv) * i.hatchWeights0.x;
				fixed4 hatchTex1 = tex2D(_Hatch1, i.uv) * i.hatchWeights0.y;
				fixed4 hatchTex2 = tex2D(_Hatch2, i.uv) * i.hatchWeights0.z;
				fixed4 hatchTex3 = tex2D(_Hatch3, i.uv) * i.hatchWeights1.x;
				fixed4 hatchTex4 = tex2D(_Hatch4, i.uv) * i.hatchWeights1.y;
				fixed4 hatchTex5 = tex2D(_Hatch5, i.uv) * i.hatchWeights1.z;

				fixed4 whiteColor = fixed4(1,1,1,1) * (1 - i.hatchWeights0.x - i.hatchWeights0.y - i.hatchWeights0.z - i.hatchWeights1.x - i.hatchWeights1.y - i.hatchWeights1.z);

				fixed4 hatchColor = hatchTex0 + hatchTex1 + hatchTex2 + hatchTex3 + hatchTex4 + hatchTex5 + whiteColor;

				UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

				return fixed4(hatchColor.rgb * _Color.rgb * atten, 1.0);;
			}
			ENDCG
		}
	}

	FallBack "Diffuse"
}
