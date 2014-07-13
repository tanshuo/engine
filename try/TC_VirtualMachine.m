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
@synthesize check_call = _check_call;
@synthesize result = _result;
@synthesize current_instruction = _current_instruction;
@synthesize var_stack = _var_stack;
@synthesize local_var_list = _local_var_list;
@synthesize func_list = _func_list;
@synthesize ins_list = _ins_list;
@synthesize target = _target;

- (int) run_next_ins
{
    TC_Instruction* current = [_ins_list objectAtIndex:_ip];
    int ins = [current instruct];
    int re;
    switch(ins)
    {
        case ins_call:
            re = [self call_fun: [_ins_list objectAtIndex:_ip]];
            if(re == -1)
            {
                return -1;
            }
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
            _ip ++;
            break;
        case ins_rtn:
            re = [self return_fun:current];
            if(re == -1)
            {
                return -1;
            }
            break;
    }
    return 0;
}

- (int) call_fun:(TC_Instruction*) t
{
    int i;
    TC_INS_FUNCTION* current = (TC_INS_FUNCTION*)[t des];
    if([current solved] == NO && [current location] == FUN_BIND)
    {
        SEL sel;
        sel =  NSSelectorFromString(t.src);
        for(i = 0; i < [t.params count]; i++)
        {
            int re;
            re = [self solve_var: [t.params objectAtIndex:i]];
            if(re == -1)
            {
                _message = [NSMutableString stringWithString:@"unsolved variable symbol"];
                return -1;
            }
        }
        if(sel <= 0)
        {
            _message = [NSMutableString stringWithString:@"unsolved function symbol"];
            return -1;
        }
        else
            [_target performSelector:sel withObject:[t params]];
        _ip++;
        //how to call it?
        //..
    }
    else if(current.solved == YES && current.location == FUN_DEFINE)
    {
        int oldbp = _bp;
        int oldip = _ip + 1;
        _bp = _sp + 1;
        _sp = _bp;
        TC_INS_VARIABLE* var;
        for(i = 0; i  < [t.params count];i ++)
        {
            TC_INS_VARIABLE* new = [t.params objectAtIndex:i];
            // copy arguement;
            if(new.solved == NO)//may wrong
            {
                int re = [self solve_var:new];
                if(re == -1)
                {
                    _message = [NSMutableString stringWithString:@"unsolved variable symbol"];
                    return -1;
                }
            }
            else if(new.solved == YES && new.location == VAR_SELF)
            {
                new.addr = (__bridge void*)_target;
            }
            else if(new.solved == YES && new.location == VAR_STACK)
            {
                new = [_var_stack objectAtIndex: (_bp + [new argoffset])];
            }
            var = [TC_INS_VARIABLE alloc];
            var.solved = YES;
            var.type = new.type;
            var.var = new.var;
            var.location = VAR_STACK;
            switch(var.type)
            {
                case VAR_INT:
                    var.addr = (int*)malloc(sizeof(int));
                    *((int*)(var.addr)) = *((int*)(new.addr));
                    break;
                case VAR_FLOAT:
                    var.addr = (float*)malloc(sizeof(float));
                    *((float*)(var.addr)) = *((float*)(new.addr));
                    break;
                    
                case VAR_STRING:
                    var.addr = new.addr;
                    break;
                case VAR_VECTOR2:
                    var.addr = (TC_Position2d*)malloc(sizeof(TC_Position2d));
                    *((TC_Position2d*)(var.addr)) = *((TC_Position2d*)(new.addr));
                    break;
                case VAR_VECTOR3:
                    var.addr = (TC_Position*)malloc(sizeof(TC_Position));
                    *((TC_Position*)(var.addr)) = *((TC_Position*)(new.addr));
                    break;
                case VAR_UNKNOWN:
                    var.addr = nil;
                    break;
                case VAR_OFF_SET:
                    var.addr = nil;
                    break;
                case VAR_OBJECT:
                    var.addr = new.addr;// reference only
                    break;
            }
            var.argoffset = i;
            [_var_stack addObject:var];
            _sp++;
        }
        var = [TC_INS_VARIABLE alloc];
        var.solved = YES;
        var.type = VAR_OFF_SET;
        var.var = nil;
        var.location = VAR_STACK;
        var.addr = nil;
        var.argoffset = oldip;// return offset
        [_var_stack addObject:var];
        _sp ++;
        
        var = [TC_INS_VARIABLE alloc];
        var.solved = YES;
        var.type = VAR_OFF_SET;
        var.var = nil;
        var.location = VAR_STACK;
        var.addr = nil;
        var.argoffset = oldbp;// old frame pointer
        [_var_stack addObject:var];
        _ip = [current offset];
    }
    return 0;
}

- (int) return_fun:(TC_Instruction*) t// -1 0
{
    TC_INS_VARIABLE* var;
    var = [_var_stack lastObject];
    while(var.type != VAR_OFF_SET)
    {
        if([_var_stack count] > 0)
        {
            [_var_stack removeLastObject];
            _sp --;
            var = [_var_stack lastObject];
        }
        else
        {
            _message = [NSMutableString stringWithString:@"stack cracked"];
            return -1;
        }
        
    }
    int rtn_bp = var.argoffset;
    [_var_stack removeLastObject];
    _sp --;
    if([_var_stack count] > 0)
        var = [_var_stack lastObject];
    else
    {
        _message = [NSMutableString stringWithString:@"stack cracked"];
        return -1;
    }
    int rtn_ip = var.argoffset;
    
    [_var_stack removeLastObject];
    _sp --;
    
    while(_sp >= _bp)
    {
        [_var_stack removeLastObject];
        _sp --;
    }
    _bp = rtn_bp;
    _ip = rtn_ip;
    return 0;
}
+ (TC_VirtualMachine*) initVM: (NSString*) script
{
    return nil;
}

@end
