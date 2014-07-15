//
//  TC_VirtualMachine.m
//  try
//
//  Created by tanshuo on 6/22/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//

#import "TC_OBJ_VIRTUAL.h"
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
    if(_ip >= [_ins_list count])
    {
        _message = [NSMutableString stringWithString:@"no more instruction"];
        return -1;
    }
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
    TC_INS_VARIABLE* s;
    TC_INS_FUNCTION* current = (TC_INS_FUNCTION*)[t des];
    if([current solved] == NO && [current location] == FUN_BIND)
    {
        SEL sel;
        sel =  NSSelectorFromString(t.src);
        for(i = 0; i < [t.params count]; i++)
        {
            s = [self solve_var: [[t.params objectAtIndex:i] var] In:self];
            if(s == nil)
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
        _ip ++;
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
                new = [self solve_var:[new var] In:self];
                if(new == nil)
                {
                    _message = [NSMutableString stringWithString:@"unsolved variable symbol"];
                    return -1;
                }
            }
            else if(new.solved == YES && new.location == VAR_SELF)
            {
                new.obj = _target;
                new.type = VAR_OBJECT;
            }
            else if(new.solved == YES && new.location == VAR_STACK)
            {
                new = [_var_stack objectAtIndex: (_bp + [new argoffset])];
            }
            var.type = new.type;
            var.addr = nil;
            var.obj = nil;
            var.location = VAR_STACK;
            switch(var.type)
            {
                case VAR_INT:
                    var.addr = (int*)malloc(sizeof(int));
                    var.borrow = NO;
                    *((int*)(var.addr)) = *((int*)(new.addr));
                    break;
                case VAR_FLOAT:
                    var.addr = (float*)malloc(sizeof(float));
                    *((float*)(var.addr)) = *((float*)(new.addr));
                    var.borrow = NO;
                    break;
                    
                case VAR_STRING:
                    var.obj = new.obj;
                    var.borrow = NO;
                    break;
                case VAR_VECTOR2:
                    var.addr = (TC_Position2d*)malloc(sizeof(TC_Position2d));
                    var.borrow = NO;
                    *((TC_Position2d*)(var.addr)) = *((TC_Position2d*)(new.addr));
                    break;
                case VAR_VECTOR3:
                    var.addr = (TC_Position*)malloc(sizeof(TC_Position));
                    var.borrow = NO;
                    *((TC_Position*)(var.addr)) = *((TC_Position*)(new.addr));
                    break;
                case VAR_UNKNOWN:
                    var.addr = nil;
                    var.borrow = NO;
                    break;
                case VAR_OFF_SET:
                    var.addr = nil;
                    var.borrow = NO;
                    break;
                case VAR_OBJECT:
                    var.obj = new.obj;// reference only
                    var.borrow = NO;
                    break;
            }
            var.solved = YES;
            var.argoffset = i;
            [_var_stack addObject:var];
            _sp++;
        }
        var = [TC_INS_VARIABLE alloc];
        var.solved = YES;
        var.borrow = NO;
        var.type = VAR_OFF_SET;
        var.var = nil;
        var.location = VAR_STACK;
        var.addr = nil;
        var.obj = nil;
        var.argoffset = oldip;// return offset
        [_var_stack addObject:var];
        _sp ++;
        
        var = [TC_INS_VARIABLE alloc];
        var.solved = YES;
        var.borrow = NO;
        var.type = VAR_OFF_SET;
        var.var = nil;
        var.location = VAR_STACK;
        var.addr = nil;
        var.obj = nil;
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

//search variable deal with the first layer: if no solved: seach stack from top to bot, if no, search local list, search globol list. then process of statement. If it is an instance, gen a TC_INS_VARIABLE. if the word layer of seach target is nil, jump over;  *** if the first layer is my, return target's atrribute(refer in addr)
- (TC_INS_VARIABLE*) solve_var:(TC_WORD_LAYER*) w In:(TC_VirtualMachine*)m// nil
{
    int i;

    TC_WORD_LAYER* new_w;
    TC_VirtualMachine* new_m;
    if([w.word characterAtIndex:0] == '#')
    {
        return [self genInstance:w.word];
    }
    else if([w.word isEqualToString:@"my"])
    {
        if(w.next_layer == nil)
        {
            _message = [NSMutableString stringWithString:@"no indicated attribite for current object"];
            return nil;
        }
        new_m = m;
        new_w = w.next_layer;
        return [self solve_var:new_w In:new_m];
    }
    else if(w.next_layer == nil)
    {
        for(i = m.sp; i >= 0; i --)
        {
            TC_INS_VARIABLE* nv = [m.var_stack objectAtIndex:i];
            if([[[nv var] word] isEqualToString:w.word])
            {
                return nv;
            }
        }
        for(i = 0; i < [m.local_var_list count]; i ++)
        {
            TC_INS_VARIABLE* nv = [m.local_var_list objectAtIndex:i];
            if([[[nv var] word] isEqualToString:w.word])
            {
                return nv;
            }
        }
        for(i = 0; i < [_global count]; i ++)
        {
            TC_INS_VARIABLE* nv = [_global objectAtIndex:i];
            if([[[nv var] word] isEqualToString:w.word])
            {
                return nv;
            }
        }
    }
    else
    {
        for(i = m.sp; i >= 0; i --)
        {
            TC_INS_VARIABLE* nv = [m.var_stack objectAtIndex:i];
            if([[[nv var] word] isEqualToString:w.word])
            {
                if(nv.type == VAR_OBJECT)
                {
                    new_w = w.next_layer;
                    new_m = [[nv obj] virtual];
                    return [self solve_var: new_w In:new_m];
                }
                else
                {
                    _message = [NSMutableString stringWithString:@"try to get an attribute of a non-object variable"];
                    return nil;
                }
            }
        }
        //if not in the stack
        for(i = 0; i < [m.local_var_list count]; i ++)
        {
            TC_INS_VARIABLE* nv = [m.local_var_list objectAtIndex:i];
            if([[[nv var] word] isEqualToString:w.word])
            {
                if(nv.type == VAR_OBJECT)
                {
                    new_w = w.next_layer;
                    new_m = [[nv obj] virtual];
                    return [self solve_var: new_w In:new_m];
                }
                else
                {
                    _message = [NSMutableString stringWithString:@"try to get an attribute of a non-object variable"];
                    return nil;
                }
            }
        }
        
        //in globol
        for(i = 0; i < [_global count]; i ++)
        {
            TC_INS_VARIABLE* nv = [m.local_var_list objectAtIndex:i];
            if([[[nv var] word] isEqualToString:w.word])
            {
                if(nv.type == VAR_OBJECT)
                {
                    new_w = w.next_layer;
                    new_m = [[nv obj] virtual];
                    return [self solve_var: new_w In:new_m];
                }
                else
                {
                    _message = [NSMutableString stringWithString:@"try to get an attribute of a non-object variable"];
                    return nil;
                }
            }
        }
    }
    return nil;
}

- (TC_INS_VARIABLE*) genInstance:(NSString*) w
{
    int i;
    int j = 0;
    int seg = 1;
    BOOL end = NO;
    NSString* s;
    NSMutableArray* args = [NSMutableArray arrayWithCapacity:10];
    char* cache;
    cache = (char*)malloc(1024*1024*1);
    if(cache == nil)
    {
        _message = [NSMutableString stringWithString:@"no enough memory"];
        return nil;
    }
    w = [w substringFromIndex:1];
    if(w == nil)
    {
        return nil;
    }
    TC_INS_VARIABLE* result;
    result.solved = NO;
    result.borrow = NO;
    result.obj = nil;
    result.addr = nil;
    result.type = VAR_UNKNOWN;
    result.argoffset = 0;
    if([w lengthOfBytesUsingEncoding:NSASCIIStringEncoding] > 0)
    {
        if([w characterAtIndex:0] == '\"')
        {
            for(i = 0; i < [w lengthOfBytesUsingEncoding:NSASCIIStringEncoding]; i++)
            {
                if([w characterAtIndex:i] == '\"')
                {
                    end = YES;
                    cache[j] = 0;
                    s = [NSString stringWithCString:cache encoding:NSASCIIStringEncoding];
                    result.obj = s;
                    result.solved = YES;
                    result.borrow = NO;
                    result.type = VAR_STRING;
                    free(cache);
                    return result;
                }
                else
                {
                    cache[j] = [w characterAtIndex:i];
                    j++;
                }
            }
            _message = [NSMutableString stringWithString:@"can not find end of string"];
            free(cache);
            return nil;
        }
        else
        {
            for(i = 0; i < [w lengthOfBytesUsingEncoding:NSASCIIStringEncoding]; i++)
            {
                char c = [w characterAtIndex:i];
                if(c  == ',')
                {
                    cache[j] = 0;
                    s = [NSString stringWithCString:cache encoding:NSASCIIStringEncoding];
                    [args addObject:s];
                    j = 0;
                    seg ++;
                }
                else if(c == ' '||c == '\t'||c=='\n')
                {
                    continue;
                }
                else
                {
                    cache[j] = c;
                    j++;
                }
            }
            cache[j] = 0;
            s = [NSString stringWithCString:cache encoding:NSASCIIStringEncoding];
            [args addObject:s];
            
            if(seg > 1)
            {
                if(seg == 2)
                {
                    TC_Position2d* data;
                    data = (TC_Position2d*)malloc(sizeof(TC_Position2d));
                    data->x = [[args objectAtIndex:0] floatValue];
                    data->y = [[args objectAtIndex:1] floatValue];
                    //bug
                    result.addr = data;
                    result.solved = YES;
                    result.borrow = NO;
                    result.type = VAR_VECTOR2;
                    free(cache);
                    return result;
                }
                else if(seg == 3)
                {
                    TC_Position* data;
                    data = (TC_Position*)malloc(sizeof(TC_Position));
                    data->x = [[args objectAtIndex:0] floatValue];
                    data->y = [[args objectAtIndex:1] floatValue];
                    data->z = [[args objectAtIndex:2] floatValue];
                    //bug
                    result.addr = data;
                    result.solved = YES;
                    result.borrow = NO;
                    result.type = VAR_VECTOR3;
                    free(cache);
                    return result;
                }
                else
                {
                    _message = [NSMutableString stringWithString:@"arg can not over 3"];
                    free(cache);
                    return nil;
                }
            }
            else
            {
                NSString* num = [args objectAtIndex:0];
                for(i = 0; i < [num lengthOfBytesUsingEncoding:NSASCIIStringEncoding]; i ++)
                {
                    if([num characterAtIndex:i] == '.')
                    {
                        float* data;
                        data = (float*)malloc(sizeof(float));
                        *data = [[args objectAtIndex:0] floatValue];
                        //bug
                        result.addr = data;
                        result.solved = YES;
                        result.borrow = NO;
                        result.type = VAR_FLOAT;
                        free(cache);
                        return result;
                    }
                }
                int* data;
                data = (int*)malloc(sizeof(int));
                *data = [[args objectAtIndex:0] intValue];
                //bug
                result.addr = data;
                result.solved = YES;
                result.borrow = NO;
                result.type = VAR_INT;
                free(cache);
                return result;
            }
        }
    }
    else
    {
        free(cache);
        return result;
    }
    free(cache);
    return result;
}

+ (TC_VirtualMachine*) initVM: (NSString*) script
{
    TC_VirtualMachine* result;
    result = [TC_VirtualMachine alloc];
    result.ip = 0;
    result.bp = 0;
    result.sp = 0;
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
    result.local_var_list = nil;
    result.func_list = nil;
    result.ins_list = [NSMutableArray arrayWithCapacity:10];
    [_it readScript:script];
    result.local_var_list = _it.var_table;
    result.func_list = _it.func_table;
    [_it clear_current];
    result.target = nil;
    return result;
}



@end

