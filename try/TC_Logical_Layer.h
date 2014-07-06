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
#import "TC_WORD_LAYER.h"
#import "types.h"

@interface TC_Logical_Layer : NSObject
@property(strong,nonatomic) id left;
@property(strong,nonatomic) id right;
@property(strong,nonatomic) id straight;
@property int type;//0 is no logical, tcand tcor
@end
