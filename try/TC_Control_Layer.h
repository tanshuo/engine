//
//  TC_Conrol_Layer.h
//  try
//
//  Created by tanshuo on 6/28/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "TC_Define.h"
#import "types.h"
#import "TC_WORD_LAYER.h"
#import "TC_Function_Layer.h"

@interface TC_Conrol_Layer : NSObject
@property int type;
@property TC_ID word_count;
@property (strong,nonatomic) id logical;
@end
