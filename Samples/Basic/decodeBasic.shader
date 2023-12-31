﻿Shader "Hidden/ShaderValueIO/Example/decodeBasic"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
#pragma enable_d3d11_debug_symbols

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _MainTex_TexelSize;
            #define SVIO_COMPONENT_COUNT 4
            #define SVIO_DATABITS 2
            #define SVIO_DATABLOCK_SIZE 2
            #define SVIO_DATABLOCK_X 2
            #define SVIO_COMPONENT_COUNT_PER_COMPONENTBLOCK_PIXEL 1
            #define SVIO_COMPONENTBLOCK_X 1
            #include "../../ShaderValueIO.cginc"

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float3 frag (v2f i) : SV_Target
            {
                return ShaderValueIO::DecodeToFloat(i.uv);
            }
            ENDCG
        }
    }
}
