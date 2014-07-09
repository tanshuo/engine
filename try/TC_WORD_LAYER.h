//
//  TC_WORD_LAYER.h
//  try
//
//  Created by tanshuo on 6/28/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "TC_Define.h"
#import "types.h"

@interface TC_WORD_LAYER : NSObject
@property int type;// TC_VAR TC_INSTANCE
@property (strong,nonatomic) NSString* word;
@property (strong,nonatomic) TC_WORD_LAYER* next_layer;
@end
