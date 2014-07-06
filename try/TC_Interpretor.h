//
//  TC_Interpretor.h
//  try
//
//  Created by tanshuo on 6/27/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "TC_VirtualMachine.h"
#import "TC_Define.h"
#import "TC_Control_Layer.h"
#import "types.h"


@interface TC_Interpretor : NSObject
@property TC_ID currentLine;
@property (strong,nonatomic) NSMutableString* line;
@property (strong,nonatomic) TC_VirtualMachine* vm;
@property (strong,nonatomic) NSMutableArray* defines;
@property (strong,nonatomic) NSMutableArray* dictionary;
@property (strong,nonatomic) NSMutableArray* root;
@property FILE* input;

- (void) start;// create
- (int) readLine; // read a line into a buffer if 1 continue,-1 end,0 error
- (int) genTree; // create commandTree
- (TC_Logical_Layer*) genLogical:(NSMutableArray*) sentence;
- (int) read_a_tokens;// 0 can not find 1 success -1 error
- (int) loadFile: (NSString*) file;

- (void) attachTree: (TC_VirtualMachine*)vm;
- (void) die;
- (void) initDictionary;
- (void) dealloc;

- (TC_Define*) searchDictionary: (NSString*) word;
@end
