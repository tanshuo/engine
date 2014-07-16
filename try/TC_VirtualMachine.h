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
@property int head; // ip to start
@property int update;// ip to update
@property int has_start;// head or update

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
- (TC_INS_VARIABLE*) solve_var:(TC_WORD_LAYER*) w In:(TC_VirtualMachine*)m; // -1 0
- (TC_INS_VARIABLE*) solve: (TC_INS_VARIABLE*) v;

- (TC_INS_VARIABLE*) genInstance:(NSString*) w;


//look for unsolved function and bind them with address
- (int) bind_function:(TC_INS_FUNCTION*)func To:(SEL*)addr;
- (SEL) seach_bind: (TC_INS_FUNCTION*)func;

//bind list
- (void) equal:(NSMutableArray*) params; //a equal b
- (void) greater:(NSMutableArray*) params;//...
- (void) smaller:(NSMutableArray*) params;//...
- (void) set:(NSMutableArray*) params;// a set <5 6 7>
- (void) is:(NSMutableArray*) params;// a is b

- (void) move:(NSMutableArray*) params;// a move <5 6 7>
- (void) rotate:(NSMutableArray*) params;// a rotate <90>
- (void) setSeq:(NSMutableArray*) params;// a set <3,4,5>

- (void) kill:(NSMutableArray*) params;// kill a
- (void) hide:(NSMutableArray*) params;// a hide
- (void) adopt:(NSMutableArray*) params;// adopt a
- (void) abandon:(NSMutableArray*) params;// abandon my child abondon a
- (void) search:(NSMutableArray*) params;// search string
- (void) creat:(NSMutableArray*) params;// create prefab position return reult
- (void) say:(NSMutableArray*) params;//say <"hello">
- (void) calculate:(NSMutableArray*) params;//calculate <"A->x + 4">;
- (void) push:(NSMutableArray*) params;// list push <5,6,7>
- (void) pop:(NSMutableArray*) params;// list pop <5,6,7>
- (void) has_size:(NSMutableArray*) params;// A hassize
- (void) getobject:(NSMutableArray*) params;// A get_object at 3
- (void) remove:(NSMutableArray*) params;//list remove at 4

@end
