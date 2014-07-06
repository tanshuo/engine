//
//  TC_Function_Layer.h
//  try
//
//  Created by tanshuo on 6/28/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "TC_Define.h"
#import "TC_Logical_Layer.h"
#import "types.h"

@interface TC_Function_Layer : NSObject
@property (strong,nonatomic) NSMutableArray* inputs;//and keyword word_layer
@property (strong,nonatomic) NSMutableArray* params;//token lead by with on or nothing
@end
