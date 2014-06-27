//
//  TC_ShaderLoader.h
//  try
//
//  Created by tanshuo on 6/23/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "types.h"
#include "TC_Shaderinfo.h"


NSMutableArray* shaderlist;

@interface TC_ShaderLoader : NSObject
+ (TC_Shaderinfo*)loadShaderWithVertexShader: (NSString*)vertex WithFragmentShader: (NSString*)frag;
+ (TC_Shaderinfo*) lookShd: (NSString*) name;

@end
