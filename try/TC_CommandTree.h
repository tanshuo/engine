//
//  TC_CommandTree.h
//  try
//
//  Created by tanshuo on 6/27/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//

#import "TC_Instruction.h"

@interface TC_CommandTree : NSObject
@property (strong,nonatomic) NSMutableArray* trees;
@property TC_ID tree_count;
@property NSMutableArray* globols;
@end
