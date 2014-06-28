//
//  TC_Interpretor.h
//  try
//
//  Created by tanshuo on 6/27/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "types.h"
#import "TC_CommandTree.h"

@interface TC_Interpretor : NSObject
@property TC_ID currentLine;
@property NSString* line;
@property TC_CommandTree* tree;
- (int) readLine;
- (int) genTree;

@end
