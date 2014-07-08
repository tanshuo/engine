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
#import "TC_WORD_LAYER.h"
#import "types.h"

@interface TC_Function_Layer : NSObject
@property (strong,nonatomic) NSString* name;
@property int right_match;
@property (strong,nonatomic) id target;//and keyword word_layer
@property (strong,nonatomic) NSMutableArray* params;//token lead by with on or nothing
@end
