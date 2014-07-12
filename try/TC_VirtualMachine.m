//
//  TC_VirtualMachine.m
//  try
//
//  Created by tanshuo on 6/22/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//

#import "TC_VirtualMachine.h"
@implementation TC_VirtualMachine
@synthesize ip = _ip;
@synthesize bp = _bp;
@synthesize sp = _sp;
@synthesize true_false = _true_false;
@synthesize result = _result;
@synthesize current_instruction = _current_instruction;
@synthesize var_stack = _var_stack;
@synthesize local_var_list = _local_var_list;
@synthesize func_list = _func_list;
@synthesize ins_list = _ins_list;

- (int) run_next_ins
{
    TC_Instruction* current = [_ins_list objectAtIndex:_ip];
    int ins = [current instruct];
    switch(ins)
    {
        case ins_call:
            [self call_fun: [_ins_list objectAtIndex:_ip]];
            break;
        case ins_jmp:
            _ip = [[current src] offset];
            break;
        case ins_jmp_false:
            if(_true_false == NO)
            {
                 _ip = [[current src] offset];
            }
            break;
        case ins_jmp_true:
            if(_true_false == YES)
            {
                _ip = [[current src] offset];
            }
            break;
        case ins_push:
        
            [_var_stack addObject:[current src]];
            _sp ++;
            break;
        case ins_rtn:
            [self return_fun:current];
            break;
    }
    return 0;
}

+ (TC_VirtualMachine*) initVM: (NSString*) script
{

}

@end
