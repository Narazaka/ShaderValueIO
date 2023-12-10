# ShaderValueIO

Shader value IO utility (cginc)

## Install

### OpenUPM

see [OpenUPM page](https://openupm.com/packages/net.narazaka.unity.shadervalueio/)

### VRChat Creaters Companion (VCC)

1. Press "Add to VCC" on https://vpm.narazaka.net/ to add Narazaka's repository to VCC.
2. Make sure that "Narazaka VPM Listing" is enabled in VCC -> Settings -> Packages -> Installed Repositories.
3. Install "ShaderValueIO" from your project's "Manage Project".

## Usage

```hlsl
#define SVIO_NO_TEXTURE
#define SVIO_TEXTURE_TEXELSIZE float4(1.0 / 16, 1.0 / 16, 16, 16)

#define SVIO_COMPONENT_COUNT 4
#define SVIO_DATABITS 8
#define SVIO_DATABLOCK_SIZE 4
#define SVIO_DATABLOCK_X 1
#define SVIO_COMPONENT_COUNT_PER_COMPONENTBLOCK_PIXEL 2
#define SVIO_COMPONENTBLOCK_X 2
#include "Packages/net.narazaka.unity.shadervalueio/ShaderValueIO.cginc"

ShaderValueIO::EncodeFromUint(MyValue(i.uv), i.uv);
```

## License

[Zlib License](LICENSE)
