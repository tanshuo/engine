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
#import "types.h"


@interface TC_Interpretor : NSObject
@property TC_ID currentLine;
@property (strong,nonatomic) NSString* line;
@property (strong,nonatomic) TC_VirtualMachine* vm;
@property (strong,nonatomic) NSMutableArray* defines;
@property (strong,nonatomic) NSMutableArray* dictionary;
@property FILE* input;

- (void) start;// create
- (int) readLine; // read a line into a buffer
- (int) genTree; // create commandTree
- (int) read_a_tokens;
- (int) loadFile: (NSString*) file;
- (void) attachTree: (TC_VirtualMachine*)vm;
- (void) die;
- (void) initDictionary;
- (void) dealloc;
- (TC_Define*) searchDictionary: (NSString*) word;
@end
