//
//  TC_VirtualMachine.h
//  try
//
//  Created by tanshuo on 6/22/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//

// contain instructions and variables. load a script file and compile it.
#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "TC_Interpretor.h"
#import "TC_Instruction.h"
#import "TC_INS_VARIABLE.h"
#import "TC_INS_OFFSET.h"
#import "TC_INS_FUNCTION.h"

#import "types.h"

@interface TC_VirtualMachine : NSObject
@property TC_ID ip; // instruction position
@property TC_ID bp; // stack base
@property BOOL true_false; // logical result
@property (strong,nonatomic) TC_INS_VARIABLE* result; //calculated value
@property (strong,nonatomic) TC_Instruction* current_instruction;//the instruction need to process

@property (strong,nonatomic) NSMutableArray* var_stack; //function arg stackc and local, pop back to bp and pop out return.
@property (strong,nonatomic) NSMutableArray* local_var_table;// local variable table
@property (strong,nonatomic) NSMutableArray* func_list;

- (void) initVM;

@end
