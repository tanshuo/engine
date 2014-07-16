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
    
    int i;
    copy = [self lookscript: name];
    if(copy == nil)
    {
        result = [TC_VirtualMachine initVM:name];
        TC_ScriptListInfo* info;
        info = [TC_ScriptListInfo alloc];
        info.name = name;
        info.vm = result;
        info.owrner = 0;
        [scriptlist addObject:info];
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
        temp = [TC_INS_VARIABLE  alloc];
        temp.solved = NO;
        temp.borrow = NO;
        temp.addr = nil;
        temp.obj = nil;
        temp.argoffset = 0;
        temp.type = VAR_UNKNOWN;
        temp.location = VAR_BIND;
        result.result = temp;
        result.current_instruction = nil;
        result.var_stack = [NSMutableArray arrayWithCapacity:10];
        result.ins_list = copy.ins_list;
        result.head = copy.head;
        result.update = copy.update;
        result.target = nil;
        result.local_var_list = [NSMutableArray arrayWithCapacity:10];
        for(i = 0;i < [copy.local_var_list count];i ++)
        {
            TC_INS_VARIABLE* t;
            TC_INS_VARIABLE* temp;
            temp = [TC_INS_VARIABLE  alloc];
            temp.solved = t.solved;
            temp.borrow = t.borrow;
            temp.addr = nil;
            temp.obj = nil;
            temp.argoffset = t.argoffset;
            temp.type = t.type;
            temp.location = t.location;
            [result.local_var_list addObject:temp];
        }
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
        if([[(TC_ScriptListInfo*)[scriptlist objectAtIndex:i] name] isEqualToString:name])
        {
            return [[scriptlist objectAtIndex:i] vm];
        }
    }
    return nil;
}
@end
