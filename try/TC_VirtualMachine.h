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
//#import "TC_Sprite.h"


#import "types.h"
/***********************************************/
/*   bp  bp+1 bp+2 bp+3  bp+4..           sp   */
/*  arg1 arg2 arg3 rtn   ebp    local1  local2 */
/***********************************************/

@interface TC_VirtualMachine : NSObject
@property TC_ID ip; // instruction position
@property TC_ID bp; // stack base
@property TC_ID sp; // stack top
@property BOOL true_false; // logical result
@property BOOL check_call;
@property (strong,nonatomic) id target;
@property (strong,nonatomic) TC_INS_VARIABLE* result; //calculated value
@property (strong,nonatomic) TC_Instruction* current_instruction;//the instruction need to process
//@property (strong,nonatomic) TC_INS_VARIABLE* target;
@property (strong,nonatomic) NSMutableArray* var_stack; //function arg stackc and local, pop back to bp and pop out return.
@property (strong,nonatomic) NSMutableArray* local_var_list;// local variable list
@property (strong,nonatomic) NSMutableArray* func_list;//get from the interprator
@property (strong,nonatomic) NSMutableArray* ins_list;//instructionlist
@property (strong,nonatomic) NSMutableArray* bind_list;

@property (strong,nonatomic) NSMutableString* message;

+ (TC_VirtualMachine*) initVM: (NSString*) script;

- (int) run_next_ins;// -1 0
- (int) call_fun:(TC_Instruction*) t;// -1 0
- (int) return_fun:(TC_Instruction*) t;// -1 0

//search variable deal with the first layer: if no solved: seach stack from top to bot, if no, search local list, search globol list. then process of statement. If it is an instance, gen a TC_INS_VARIABLE. if the word layer of seach target is nil, jump over;  *** if the first layer is my, return target's atrribute(refer in addr)
- (int) solve_var:(TC_INS_VARIABLE*) w; // -1 0




//look for unsolved function and bind them with address
- (int) bind_function:(TC_INS_FUNCTION*)func To:(SEL*)addr;
- (SEL) seach_bind: (TC_INS_FUNCTION*)func;

//bind list
- (void) equal:(NSMutableArray*) params; //a equal b
- (void) greater:(NSMutableArray*) params;//...
- (void) smaller:(NSMutableArray*) params;//...
- (void) set:(NSMutableArray*) params;// a set <5 6 7>
- (void) is:(NSMutableArray*) params;// a is b

- (void) move:(NSMutableArray*) params;// a move <5 6 >
- (void) rotate:(NSMutableArray*) params;// a rotate <90>
- (void) setSeq:(NSMutableArray*) params;// a set <3,4,5>

- (void) kill:(NSMutableArray*) params;// kill a
- (void) hide:(NSMutableArray*) params;// a hide
- (void) adopt:(NSMutableArray*) params;// adopt a
- (void) abandon:(NSMutableArray*) params;// abandon my child abondon a
- (void) search:(NSMutableArray*) params;// search string
- (void) creat:(NSMutableArray*) params;// create game object



@end
