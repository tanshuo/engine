//
//  TC_Logical_Layer.h
//  try
//
//  Created by tanshuo on 7/5/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "TC_Define.h"
#import "TC_Function_Layer.h"
#import "types.h"

@interface TC_Logical_Layer : NSObject
@property int type;//0 is no logical, tcand tcor
@property(strong,nonatomic) TC_Logical_Layer* left;
@property(strong,nonatomic) TC_Logical_Layer* right;
@property(strong,nonatomic) TC_Function_Layer* straight;
@end
