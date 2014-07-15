//
//  TC_ScriptLoader.m
//  try
//
//  Created by tanshuo on 6/23/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//

#import "TC_ScriptLoader.h"

@implementation TC_ScriptLoader
+ (TC_VirtualMachine*)loadScriptWith: (NSString*)name
{
    TC_VirtualMachine* result;
    TC_VirtualMachine* copy;
    copy = [self lookscript: name];
    if(copy == nil)
    {
        result = [TC_VirtualMachine initVM:name];
    }
    else
    {
        result = [TC_VirtualMachine alloc];
        result.ip = 0;
        result.bp = -1;
        result.sp = -1;
        result.has_start = NO;
        result.head = -1;
        result.update = -1;
        result.true_false = NO;
        result.check_call = NO;
        TC_INS_VARIABLE* temp;
        temp.solved = NO;
        temp.borrow = NO;
        temp.addr = nil;
        temp.obj = nil;
        temp.argoffset = 0;
        temp.type = VAR_UNKNOWN;
        temp.location = VAR_STACK;
        result.result = temp;
        result.current_instruction = nil;
        result.var_stack = [NSMutableArray arrayWithCapacity:10];
        result.ins_list = copy.ins_list;
        result.head = copy.head;
        result.update = copy.update;
        result.target = nil;
        result.local_var_list = copy.local_var_list;
        result.func_list = copy.func_list;
        return result;
    }
    return result;
};

+ (TC_VirtualMachine*) lookscript: (NSString*) name
{
    int i;
    for(i = 0; i < [scriptlist count]; i++)
    {
        if([[scriptlist objectAtIndex:i] isEqualToString:name])
        {
            return [[scriptlist objectAtIndex:i] vm];
        }
    }
    return nil;
}
@end
