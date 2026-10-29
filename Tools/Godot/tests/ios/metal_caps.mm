// Simulator capability diagnostic; --cube-array may intentionally abort on unsupported GPUs.
#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#include <cstdio>
#include <cstring>
#include <initializer_list>
int main(int argc,char **argv) {
 @autoreleasepool {
  id<MTLDevice> device=MTLCreateSystemDefaultDevice();
  if (!device) return 2;
  printf("DEVICE %s\n",device.name.UTF8String);
  for (int family=1001;family<=1009;++family) printf("FAMILY %d %d\n",family,int([device supportsFamily:(MTLGPUFamily)family]));
  for (int family: {2001,2002,3001,3002,3003,5001}) printf("FAMILY %d %d\n",family,int([device supportsFamily:(MTLGPUFamily)family]));
  printf("ARGUMENT_BUFFERS %lu\n",(unsigned long)device.argumentBuffersSupport);
  if (argc>1 && std::strcmp(argv[1],"--cube-array")==0) {
   MTLTextureDescriptor *desc=[MTLTextureDescriptor textureCubeDescriptorWithPixelFormat:MTLPixelFormatRGBA8Unorm size:16 mipmapped:NO];
   desc.textureType=MTLTextureTypeCubeArray;desc.arrayLength=2;desc.usage=MTLTextureUsageShaderRead|MTLTextureUsageRenderTarget;desc.storageMode=MTLStorageModePrivate;
   id<MTLTexture> texture=[device newTextureWithDescriptor:desc];
   printf("CUBE_ARRAY_ALLOCATED %d\n",int(texture!=nil));
   return texture?0:3;
  }
 }
 return 0;
}
