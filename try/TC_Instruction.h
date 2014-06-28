//
//  TC_Instruction.h
//  try
//
//  Created by tanshuo on 6/27/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "types.h"

@interface TC_Instruction : NSObject
@property TC_ID instruction_id;
@property (strong,nonatomic) NSMutableArray* branchs;

@end
