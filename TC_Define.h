//
//  TC_Dictionary.h
//  try
//
//  Created by tanshuo on 6/27/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "types.h"

@interface TC_Define : NSObject
@property (strong,nonatomic)NSString* word;
@property TC_Explain explain;
@property TC_ID right_match;
@end
