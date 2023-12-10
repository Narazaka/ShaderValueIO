#ifndef SVIO_SHADERVALUEIO
#define SVIO_SHADERVALUEIO

namespace ShaderValueIO
{

#ifndef SVIO_TEXTURE
#ifndef SVIO_NO_TEXTURE
#define SVIO_TEXTURE _MainTex
#endif
#endif
#ifndef SVIO_TEXTURE_TEXELSIZE
#define SVIO_TEXTURE_TEXELSIZE _MainTex_TexelSize
#endif

// input value bit
// ex. UInt16 -> 16
#ifndef SVIO_DATABITS
#define SVIO_DATABITS 16
#endif
// value separate block
// must be divisor of SVIO_DATABITS
// ex 2x2 -> 4
#ifndef SVIO_DATABLOCK_SIZE
#define SVIO_DATABLOCK_SIZE 4
#endif
// value separate block col(x) count
// 2x2 -> 2, 1x4 -> 1
#ifndef SVIO_DATABLOCK_X
#define SVIO_DATABLOCK_X 2
#endif
// input value count
// ex. uint4 -> 4, float3 -> 3
#ifndef SVIO_COMPONENT_COUNT
#define SVIO_COMPONENT_COUNT 4
#endif
// 1px contains N value components
// must be divisor of SVIO_COMPONENT_COUNT
// ex. uint3/SVIO_RGB => 3, uint4/SVIO_RG => 2, uint4/R => 1
#ifndef SVIO_COMPONENT_COUNT_PER_COMPONENTBLOCK_PIXEL
#if SVIO_COMPONENT_COUNT == 1
#define SVIO_COMPONENT_COUNT_PER_COMPONENTBLOCK_PIXEL 1
#elif SVIO_COMPONENT_COUNT == 2
#define SVIO_COMPONENT_COUNT_PER_COMPONENTBLOCK_PIXEL 2
#elif SVIO_COMPONENT_COUNT == 3
#define SVIO_COMPONENT_COUNT_PER_COMPONENTBLOCK_PIXEL 3
#elif SVIO_COMPONENT_COUNT == 4
#define SVIO_COMPONENT_COUNT_PER_COMPONENTBLOCK_PIXEL 4
#endif
#endif
// value components separate block col(x) count
#ifndef SVIO_COMPONENTBLOCK_X
#define SVIO_COMPONENTBLOCK_X 1
#endif

#define SVIO_DATABLOCK_Y (SVIO_DATABLOCK_SIZE / SVIO_DATABLOCK_X)
#define SVIO_DATABLOCK uint2(SVIO_DATABLOCK_X, SVIO_DATABLOCK_Y)
#define SVIO_BIT_PER_DATABLOCK_PIXEL (SVIO_DATABITS / SVIO_DATABLOCK_SIZE)
#define SVIO_DATA_MAXVALUE ((2 << (SVIO_DATABITS - 1)) - 1)
#define SVIO_DATABLOCK_PIXEL_MAXVALUE ((2 << (SVIO_BIT_PER_DATABLOCK_PIXEL - 1)) - 1)
#define SVIO_COMPONENTBLOCK_SIZE (SVIO_COMPONENT_COUNT / SVIO_COMPONENT_COUNT_PER_COMPONENTBLOCK_PIXEL)
#define SVIO_COMPONENTBLOCK_Y (SVIO_COMPONENTBLOCK_SIZE / SVIO_COMPONENTBLOCK_X)
#define SVIO_COMPONENTBLOCK uint2(SVIO_COMPONENTBLOCK_X, SVIO_COMPONENTBLOCK_Y)

#if SVIO_COMPONENT_COUNT == 1
#define SVIO_UINTVALUE uint1
#elif SVIO_COMPONENT_COUNT == 2
#define SVIO_UINTVALUE uint2
#elif SVIO_COMPONENT_COUNT == 3
#define SVIO_UINTVALUE uint3
#elif SVIO_COMPONENT_COUNT == 4
#define SVIO_UINTVALUE uint4
#endif

#if SVIO_COMPONENT_COUNT == 1
#define SVIO_FLOATVALUE float1
#elif SVIO_COMPONENT_COUNT == 2
#define SVIO_FLOATVALUE float2
#elif SVIO_COMPONENT_COUNT == 3
#define SVIO_FLOATVALUE float3
#elif SVIO_COMPONENT_COUNT == 4
#define SVIO_FLOATVALUE float4
#endif

// # UVCoord: pixelCoord -> uv

    // dec
    float2 UVCoord(uint2 pixelCoord)
    {
    // +0.5 = center point of the pixel
        return (pixelCoord + 0.5) * SVIO_TEXTURE_TEXELSIZE.xy;
    }

    float2 ScaledUVCoord(uint2 pixelCoord, uint2 scale)
    {
    // +0.5 = center point of the pixel
        return (pixelCoord + 0.5) * SVIO_TEXTURE_TEXELSIZE.xy / scale;
    }

// # PixelCoord: uv -> pixelCoord

    uint2 PixelCoord(float2 uv)
    {
        return uint2(uv * SVIO_TEXTURE_TEXELSIZE.zw);
    }

    uint2 ScaledPixelCoord(float2 uv, uint2 scale)
    {
        return uint2(uv * SVIO_TEXTURE_TEXELSIZE.zw * scale);
    }

    // enc
    uint2 DataBlockPixelCoord(float2 uv)
    {
        return uint2(uv * SVIO_TEXTURE_TEXELSIZE.zw * SVIO_DATABLOCK);
    }

    // enc
    uint2 ComponentBlockPixelCoord(float2 uv)
    {
        return uint2(uv * SVIO_TEXTURE_TEXELSIZE.zw * SVIO_DATABLOCK * SVIO_COMPONENTBLOCK);
    }

    // dec
    uint2 EncodedDataBlockPixelCoord(float2 uv)
    {
        return uint2(uv * SVIO_TEXTURE_TEXELSIZE.zw / SVIO_COMPONENTBLOCK);
    }

// # BlockCoord: pixelCoord -> block begin coord

    uint2 BlockCoord(uint2 pixelCoord, uint2 blockSize)
    {
        return (pixelCoord / blockSize) * blockSize;
    }

    // dec
    uint2 DataBlockCoord(uint2 pixelCoord)
    {
        return uint2(pixelCoord / SVIO_DATABLOCK) * SVIO_DATABLOCK;
    }

    // dec
    uint2 EncodedComponentBlockCoordFromDataBlockCoord(uint2 blockCoord)
    {
        return blockCoord * SVIO_COMPONENTBLOCK;
    }

// # SubPixelCoord: pixelCoord -> block sub pixel coord

    uint2 SubPixelCoord(uint2 pixelCoord, uint2 blockSize)
    {
        return pixelCoord % blockSize;
    }

    // enc
    uint2 DataBlockSubPixelCoord(uint2 pixelCoord)
    {
        return pixelCoord % SVIO_DATABLOCK;
    }

    // enc
    uint2 ComponentBlockSubPixelCoord(uint2 outPixelBlockCoord)
    {
        return outPixelBlockCoord % SVIO_COMPONENTBLOCK;
    }

// # UVColor: uv -> get color

#ifndef SVIO_NO_TEXTURE
    // dec
    float4 UVColor(float2 uv)
    {
        return tex2Dlod(SVIO_TEXTURE, float4(uv, 0, 0));
    }

// # PixelColor: pixelCoord -> get color

    // dec
    float4 PixelColor(uint2 pixelCoord)
    {
        return UVColor(UVCoord(pixelCoord));
    }

    float4 ScaledPixelColor(uint2 pixelCoord, uint2 scale)
    {
        return UVColor(ScaledUVCoord(pixelCoord, scale));
    }
#endif

    // enc
    float4 ComponentSeparatedFromBits(SVIO_FLOATVALUE value, float2 uv)
    {
    #if SVIO_COMPONENT_COUNT_PER_COMPONENTBLOCK_PIXEL == SVIO_COMPONENT_COUNT
    #if SVIO_COMPONENT_COUNT == 1
        return float4(value, 0, 0, 1);
    #elif SVIO_COMPONENT_COUNT == 2
        return float4(value, 0, 1);
    #elif SVIO_COMPONENT_COUNT == 3
        return float4(value, 1);
    #elif SVIO_COMPONENT_COUNT == 4
        return value;
    #endif
    #else
        uint2 pixelCoord = ComponentBlockPixelCoord(uv);
        uint2 subPixelCoord = ComponentBlockSubPixelCoord(pixelCoord);
        uint pixelIndex = subPixelCoord.x + subPixelCoord.y * SVIO_COMPONENTBLOCK_X;
    #if SVIO_COMPONENT_COUNT_PER_COMPONENTBLOCK_PIXEL == 1
        return float4(value[pixelIndex], 0, 0, 1);
    #elif SVIO_COMPONENT_COUNT_PER_COMPONENTBLOCK_PIXEL == 2
        return float4(value[pixelIndex * 2], value[pixelIndex * 2 + 1], 0, 1);
    #endif
    #endif
    }

#ifndef SVIO_NO_TEXTURE
    SVIO_FLOATVALUE ComponentBlockPixelColor(uint2 dataBlockPixelCoord)
        {
    #if SVIO_COMPONENT_COUNT_PER_COMPONENTBLOCK_PIXEL == SVIO_COMPONENT_COUNT
    #if SVIO_COMPONENT_COUNT == 1
        // because always SVIO_COMPONENT_BLOCK == (1,1)
        return PixelColor(dataBlockPixelCoord).r;
    #elif SVIO_COMPONENT_COUNT == 2
        return PixelColor(dataBlockPixelCoord).rg;
    #elif SVIO_COMPONENT_COUNT == 3
        return PixelColor(dataBlockPixelCoord).rgb;
    #elif SVIO_COMPONENT_COUNT == 4
        return PixelColor(dataBlockPixelCoord);
    #endif
    #else
        uint2 blockCoord = EncodedComponentBlockCoordFromDataBlockCoord(dataBlockPixelCoord);
        SVIO_FLOATVALUE result = float4(0, 0, 0, 1);
        for (uint x = 0; x < SVIO_COMPONENTBLOCK_X; ++x)
        {
            for (uint y = 0; y < SVIO_COMPONENTBLOCK_Y; ++y)
            {
                uint2 subPixelCoord = uint2(x, y);
                uint index = x + y * SVIO_COMPONENTBLOCK_X;
                float4 color = PixelColor(blockCoord + subPixelCoord);
    #if SVIO_COMPONENT_COUNT_PER_COMPONENTBLOCK_PIXEL == 1
                result[index] = color.r;
    #elif SVIO_COMPONENT_COUNT_PER_COMPONENTBLOCK_PIXEL == 2
                result[index * 2] = color.r;
                result[index * 2 + 1] = color.g;
    #endif
            }
        }
        return result;
    #endif
    }
#endif

    SVIO_FLOATVALUE EncodeToBitsFromUint(SVIO_UINTVALUE value, float2 uv)
    {
        uint2 pixelCoord = DataBlockPixelCoord(uv);
        uint2 subPixelCoord = DataBlockSubPixelCoord(pixelCoord);
        uint bitIndex = (subPixelCoord.x + subPixelCoord.y * SVIO_DATABLOCK_X) * SVIO_BIT_PER_DATABLOCK_PIXEL;
        return SVIO_FLOATVALUE((value >> bitIndex) & SVIO_DATABLOCK_PIXEL_MAXVALUE) / SVIO_DATABLOCK_PIXEL_MAXVALUE;
    }

    SVIO_FLOATVALUE EncodeToBitsFromFloat(SVIO_FLOATVALUE value, float2 uv)
    {
        return EncodeToBitsFromUint(SVIO_UINTVALUE(value * SVIO_DATA_MAXVALUE + 0.5), uv);
    }

    float4 EncodeFromFloat(SVIO_FLOATVALUE value, float2 uv)
    {
        return ComponentSeparatedFromBits(EncodeToBitsFromFloat(value, uv), uv);
    }

    float4 EncodeFromUint(SVIO_UINTVALUE value, float2 uv)
    {
        return ComponentSeparatedFromBits(EncodeToBitsFromUint(value, uv), uv);
    }

#ifndef SVIO_NO_TEXTURE
    SVIO_UINTVALUE DecodeToUint(float2 uv)
    {
        uint2 pixelCoord = EncodedDataBlockPixelCoord(uv);
        uint2 blockCoord = DataBlockCoord(pixelCoord);
        SVIO_UINTVALUE value = uint4(0, 0, 0, 0);
        for (uint x = 0; x < SVIO_DATABLOCK_X; ++x)
        {
            for (uint y = 0; y < SVIO_DATABLOCK_Y; ++y)
            {
                uint2 subPixelCoord = uint2(x, y);
                uint bitIndex = (x + y * SVIO_DATABLOCK_X) * SVIO_BIT_PER_DATABLOCK_PIXEL;
                SVIO_FLOATVALUE color = ComponentBlockPixelColor(blockCoord + subPixelCoord);
                value = value | (SVIO_UINTVALUE(color * SVIO_DATABLOCK_PIXEL_MAXVALUE + 0.5) << bitIndex);
            }
        }
        return value;
    }

    SVIO_FLOATVALUE DecodeToFloat(float2 uv)
    {
        return SVIO_FLOATVALUE(DecodeToUint(uv)) / SVIO_DATA_MAXVALUE;
    }
#endif
    
}

#endif
