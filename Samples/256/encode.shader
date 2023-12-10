﻿Shader "Hidden/ShaderValueIO/Example/encode"
{
    Properties
    {
        [MaterialToggle] _Color ("Color", Float) = 0
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

            float _Color;

            #define SVIO_NO_TEXTURE
            #define SVIO_TEXTURE_TEXELSIZE float4(1.0 / 16, 1.0 / 16, 16, 16)

            #define SVIO_COMPONENT_COUNT 4
            #define SVIO_DATABITS 8
            #define SVIO_DATABLOCK_SIZE 4
            #define SVIO_DATABLOCK_X 1
            #define SVIO_COMPONENT_COUNT_PER_COMPONENTBLOCK_PIXEL 2
            #define SVIO_COMPONENTBLOCK_X 2
            #include "../../ShaderValueIO.cginc"

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                uint2 px = uint2(i.uv * uint2(16, 16));
                 uint4 color = uint4((px.x + px.y * 16), 0, (px.x * 16 + px.y), 1);
                if (_Color > 0.5)
                {
                    return color / 255.0;
                }
                return ShaderValueIO::EncodeFromUint(color, i.uv);
            }
            ENDCG
        }
    }
}
