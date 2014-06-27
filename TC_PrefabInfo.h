//
//  TC_PrefabInfo.h
//  try
//
//  Created by tanshuo on 6/25/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "types.h"

@interface TC_PrefabInfo : NSObject
@property (strong,atomic) NSString* name;
@property (strong,atomic) NSString* script;
@property (strong,atomic) NSString* shader;
@property (strong,atomic) NSMutableArray* frame_txt;

@end
