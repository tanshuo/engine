//
//  TC_TextureLoader.h
//  try
//
//  Created by tanshuo on 6/24/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "TC_TextureInfo.h"
#import "types.h"

int genNum2(int num);
NSData* ResizeTextureWith(CGImageRef im,GLuint* width,GLuint* height);


@interface TC_TextureLoader : NSObject
+ (TC_TextureInfo*)loadTexture: (NSString*)t;
@end
