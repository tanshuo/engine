//
//  TC_Shaderinfo.h
//  try
//
//  Created by tanshuo on 6/27/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "types.h"

@interface TC_Shaderinfo : NSObject
@property GLuint counter;
@property (strong,nonatomic) NSString* shader;
@property GLuint sid;
- (void) die;
- (void) dealloc;
- (NSString*) getShd;
- (GLuint) getSID;
@end
