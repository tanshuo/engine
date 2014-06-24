//
//  TC_TextureInfo.h
//  try
//
//  Created by tanshuo on 6/24/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "types.h"

@interface TC_TextureInfo : NSObject{
    GLuint name;
    GLuint width;
    GLuint height;
};
@property GLuint name;
@property GLuint width;
@property GLuint height;
@end