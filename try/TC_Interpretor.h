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
#import "TC_INS_OFFSET.h"
#import "TC_INS_FUNCTION.h"
#import "TC_INS_VARIABLE.h"
#import "TC_Instruction.h"
#define MAX_LINE_SIZE 16 * 1024


@interface TC_Interpretor : NSObject
@property TC_ID currentLine;
@property TC_ID current_ins_count;
@property (strong,nonatomic) NSMutableString* line;
@property (strong,nonatomic) NSMutableArray* defines;
@property (strong,nonatomic) NSMutableArray* dictionary;
@property (strong,nonatomic) NSMutableArray* root;
@property (strong,nonatomic) NSMutableString* message;
@property (strong,nonatomic) NSMutableArray* instruction_table;
@property (strong,nonatomic) NSMutableArray* func_table;
@property (strong,nonatomic) NSMutableArray* var_table;
@property (strong,nonatomic) NSMutableArray* var_stack;//arg stack
@property int self_dec;
@property int self_var;


@property FILE* input;

- (void) start;// create
- (int) readLine; // read a line into a buffer if 1 continue,-1 end,0 error
- (int) genTree; // create commandTree
- (TC_Logical_Layer*) genLogical:(NSMutableArray*) sentence;
- (NSMutableArray*) genWords: (NSMutableArray*) sentence;
- (TC_Function_Layer*) genFun: (NSMutableArray*) sentence;
- (int) read_a_tokens;// 0 can not find 1 success -1 error
- (int) loadFile: (NSString*) file;
- (int) genInstruction;

- (NSMutableArray*) readScript: (NSString*) file;


- (void) die;
- (void) dealloc;

- (void) initDictionary;
- (void) initFunction;
- (void) initVar;

- (TC_Define*) searchDictionary: (NSString*) word;
- (TC_INS_FUNCTION*) searchFunction: (TC_Function_Layer*) fun;
- (TC_INS_VARIABLE*) searchVariable: (TC_WORD_LAYER*) var;

- (BOOL) cmp_word_layer: (TC_WORD_LAYER*)a With: (TC_WORD_LAYER*)b;
- (NSMutableArray*) replace_word_layer: (TC_Function_Layer*)f;

- (void) clear_current;
- (NSMutableString*) debug;
@end
