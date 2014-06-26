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
 
};
@property GLuint name;
@property GLuint width;
@property GLuint height;
@property GLuint counter;
@property (strong,nonatomic) NSString* text;
- (void) die;
- (void) clearTexBuffer;
- (void) dealloc;
- (NSString*) getTxt;
- (GLuint) getTID;
@end

