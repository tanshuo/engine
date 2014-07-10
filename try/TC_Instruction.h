//
//  TC_Instruction.h
//  try
//
//  Created by tanshuo on 6/27/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "TC_Control_Layer.h"
#import "types.h"

@interface TC_Instruction : NSObject
@property (strong,nonatomic) NSString* instruct;
@property (strong,nonatomic) id src;
@property (strong,nonatomic) id des;
@property (strong,nonatomic) NSMutableArray* params;
@end
