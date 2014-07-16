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
    int i;
    TC_INS_VARIABLE* temp = nil;
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
            _ip++;
            break;
        case ins_jmp_true:
            if(_true_false == YES)
            {
                _ip = [[current src] offset];
            }
            _ip++;
            break;
        case ins_push:
            for(i = (int)_sp; i >= (int)_bp; i--)
            {
                if(i >= 0 && i < [_var_stack count])
                {
                    if([[[[_var_stack objectAtIndex:i] var] word] isEqualToString:[[[current src]var]word]])
                    {
                        temp = [_var_stack objectAtIndex:i];
                        break;
                    }
                }
            }
            if(temp)
            {
                [_var_stack setObject:[current src] atIndexedSubscript:i];
                _ip ++;
            }
            else
            {
                [_var_stack addObject:[current src]];
                _sp ++;
                _ip ++;
            }
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
    NSMutableArray* m = [NSMutableArray arrayWithCapacity:10];
    TC_INS_FUNCTION* current = (TC_INS_FUNCTION*)[t des];
    if([current solved] == NO && [current location] == FUN_BIND)
    {
        SEL sel;
        NSString* se = [NSString stringWithFormat:@"%@:",t.src];
        sel =  NSSelectorFromString(se);
        for(i = 0; i < [t.params count]; i++)
        {
            s = [self solve: [t.params objectAtIndex:i]];
            if(s == nil)
            {
                _message = [NSMutableString stringWithString:@"unsolved variable symbol"];
                NSLog(@"%@",_message); exit(1);
                return -1;
            }
            [m addObject:s];
        }
        if(sel <= 0)
        {
            _message = [NSMutableString stringWithString:@"unsolved function symbol"];
            NSLog(@"%@",_message); exit(1);
            return -1;
        }
        else
            [self performSelector:sel withObject:m];
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
        var = [TC_INS_VARIABLE alloc];
        for(i = 0; i  < [t.params count];i ++)
        {
            TC_INS_VARIABLE* new = [t.params objectAtIndex:i];
            // copy arguement;
            new = [self solve: new];
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
                    var.borrow = YES;
                    break;
                case VAR_LIST:
                    var.obj = new.obj;
                    var.borrow = YES;
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
                    var.borrow = YES;
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
    else
    {
        _message = [NSMutableString stringWithString:@"unsolved function symbol"];
        NSLog(@"%@",_message); exit(1);
        return -1;
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
            NSLog(@"%@",_message); exit(1);
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
        NSLog(@"%@",_message); exit(1);
        return -1;
    }
    int rtn_ip = var.argoffset;
    
    [_var_stack removeLastObject];
    _sp --;
    
    while((int)_sp >= (int)_bp)
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
    //check
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
            NSLog(@"%@",_message); exit(1);
            return nil;
        }
        new_m = m;
        new_w = w.next_layer;
        return [self solve_var:new_w In:new_m];
    }
    else if(w.next_layer == nil)
    {
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
                    NSLog(@"%@",_message); exit(1);
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
                    NSLog(@"%@",_message); exit(1);
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
        NSLog(@"%@",_message); exit(1);
        return nil;
    }
    w = [w substringFromIndex:1];
    if(w == nil)
    {
        return nil;
    }
    TC_INS_VARIABLE* result;
    result = [TC_INS_VARIABLE alloc];
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
            NSLog(@"%@",_message); exit(1);
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
                    NSLog(@"%@",_message); exit(1);
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
    result.local_var_list = nil;
    result.func_list = nil;
    result.ins_list = [NSMutableArray arrayWithCapacity:10];
    [_it start];
    [_it readScript:script];
    result.head = _it.self_dec;
    result.update = _it.self_var;
    result.local_var_list = _it.var_table;
    result.func_list = _it.func_table;
    result.ins_list = _it.instruction_table;
    result.message = _it.message;
    if([result.ins_list count] == 0)
    {
        NSLog(@"compiler error: %@",result.message);
    }
    [_it clear_current];
    result.target = nil;
    return result;
}

- (TC_INS_VARIABLE*) solve: (TC_INS_VARIABLE*) v
{
    TC_INS_VARIABLE* result = nil;
    int i;
    if(v.solved == NO)//may wrong
    {
        if([v.var.word characterAtIndex:0] == '#')
        {
            result = [self solve_var:[v var]  In:self];
        }
        else if([v.var.word isEqualToString:@"my"])
        {
            result = [self solve_var:[v var]  In:self];
        }
        else
        {
            for(i = 0;i < [_var_stack count];i++)
            {
                if([[_var_stack objectAtIndex:i] var] == nil)
                {
                    continue;
                }
                if([[[_var_stack objectAtIndex:i] var].word isEqualToString:v.var.word])
                {
                    result = [_var_stack objectAtIndex:i];
                    if([result type] == VAR_OBJECT && result.var.next_layer!=nil)
                    {
                        result = [self solve_var:[[result var] next_layer]  In:[((TC_DisplayObject*)(result.obj)) virtual]];
                    }
                }
            }
            if(result == nil)
            {
                _message = [NSMutableString stringWithString:@"unsolved variable symbol"];
                NSLog(@"%@",_message); exit(1);
                return nil;
            }
        }
    }
    else if(v.solved == YES && v.location == VAR_SELF)
    {
        result = [TC_INS_VARIABLE alloc];
        result.obj = _target;
        result.type = VAR_OBJECT;
        result.solved = YES;
        result.argoffset = 0;
        result.borrow = YES;
        result.var = nil;
        result.addr = nil;
    }
    else if(v.solved == YES && v.location == VAR_STACK)
    {
        result = [_var_stack objectAtIndex: (_bp + [v argoffset])];
        if([result type] == VAR_OBJECT && [[result var] next_layer]!=nil)
        {
            result = [self solve_var:[[result var] next_layer]  In:[((TC_DisplayObject*)(result.obj)) virtual]];
            if(result == nil)
            {
                _message = [NSMutableString stringWithFormat:@"unsolved variable symbol"];
                NSLog(@"%@",_message); exit(1);
                return nil;
            }
        }
        //here and there
    }
    else if(v.solved == YES && v.location == VAR_BIND)
    {
        result = [_local_var_list objectAtIndex: [v argoffset]];
        if([result type] == VAR_OBJECT && [[result var] next_layer]!=nil)
        {
            result = [self solve_var:[[result var] next_layer]  In:[((TC_DisplayObject*)(result.obj)) virtual]];
            if(result == nil)
            {
                _message = [NSMutableString stringWithFormat:@"unsolved variable symbol"];
                NSLog(@"%@",_message); exit(1);
                return nil;
            }
        }
    }
    return result;
}

///////////////////////////////////////////////////////////////////

- (void) equal:(NSMutableArray*) params //a equal b
{
    _check_call = YES;
    TC_INS_VARIABLE* A;
    TC_INS_VARIABLE* B;
    BOOL result = NO;
    if([params count] != 2)
    {
        _check_call = NO;
        return;
    }
    A = [params objectAtIndex:0];
    B = [params objectAtIndex:1];
    if(A.type == VAR_VECTOR2 && B.type == VAR_VECTOR2)
    {
        float x1 = ((TC_Position2d*)(A.addr))->x;
        float y1 = ((TC_Position2d*)(A.addr))->y;
        float x2 = ((TC_Position2d*)(B.addr))->x;
        float y2 = ((TC_Position2d*)(B.addr))->y;
        if((y1 - y2 < 0.0000000001 || y2 - y1 < 0.0000000001) && (x1 - x2 < 0.0000000001 || x2 - x1 < 0.0000000001))
        {
            result = YES;
        }
    }
    else if(A.type == VAR_VECTOR3 && B.type == VAR_VECTOR3)
    {
        float x1 = ((TC_Position*)(A.addr))->x;
        float y1 = ((TC_Position*)(A.addr))->y;
        float z1 = ((TC_Position*)(A.addr))->z;
        float x2 = ((TC_Position*)(B.addr))->x;
        float y2 = ((TC_Position*)(B.addr))->y;
        float z2 = ((TC_Position*)(B.addr))->z;
        if((z1 - z2 < 0.0000000001 || z2 - z1 < 0.0000000001) && (y1 - y2 < 0.0000000001 || y2 - y1 < 0.0000000001) && (x1 - x2 < 0.0000000001 || x2 - x1 < 0.0000000001))
        {
            result = YES;
        }
    }
    else if(A.type == VAR_INT && B.type == VAR_INT)
    {
        int a = *((int*)(A.addr));
        int b = *((int*)(B.addr));
        if(a == b)
        {
            result = YES;
        }
    }
    else if(A.type == VAR_FLOAT && B.type == VAR_FLOAT)
    {
        float a = *((float*)(A.addr));
        float b = *((float*)(B.addr));
        if((b - a < 0.000000001)||(a - b < 0.000000001))
        {
            result = YES;
        }
    }
    else if(A.type == VAR_STRING && B.type == VAR_STRING)
    {
        if([(NSString*)A.obj isEqualToString:(NSString*)B.obj])
        {
            result = YES;
        }
    }
    else
    {
        _check_call = NO;
        return;
    }
    _true_false = _true_false || result;
}

- (void) greater:(NSMutableArray*) params//...
{
    _check_call = YES;
    TC_INS_VARIABLE* A;
    TC_INS_VARIABLE* B;
    BOOL result = NO;
    if([params count] != 2)
    {
        _check_call = NO;
        return;
    }
    A = [params objectAtIndex:0];
    B = [params objectAtIndex:1];
    if(A.type == VAR_INT && B.type == VAR_INT)
    {
        int a = *((int*)(A.addr));
        int b = *((int*)(B.addr));
        if(a > b)
        {
            result = YES;
        }
    }
    else if(A.type == VAR_FLOAT && B.type == VAR_FLOAT)
    {
        float a = *((float*)(A.addr));
        float b = *((float*)(B.addr));
        if(a > b)
        {
            result = YES;
        }
    }
    else
    {
        _check_call = NO;
        return;
    }
    _true_false = _true_false || result;
}

- (void) smaller:(NSMutableArray*) params//...
{
    TC_INS_VARIABLE* A;
    TC_INS_VARIABLE* B;
    BOOL result = NO;
    if([params count] != 2)
    {
        _check_call = NO;
        return;
    }
    A = [params objectAtIndex:0];
    B = [params objectAtIndex:1];
    if(A.type == VAR_INT && B.type == VAR_INT)
    {
        int a = *((int*)(A.addr));
        int b = *((int*)(B.addr));
        if(a < b)
        {
            result = YES;
        }
    }
    else if(A.type == VAR_FLOAT && B.type == VAR_FLOAT)
    {
        float a = *((float*)(A.addr));
        float b = *((float*)(B.addr));
        if(a < b)
        {
            result = YES;
        }
    }
    else
    {
        _check_call = NO;
        return;
    }
    _true_false = _true_false || result;
}
- (void) set:(NSMutableArray*) params// a set <5 6 7>
{
    TC_INS_VARIABLE* A;
    TC_INS_VARIABLE* B;
    if([params count] != 2)
    {
        _check_call = NO;
        return;
    }
    A = [params objectAtIndex:0];
    B = [params objectAtIndex:1];
    if(B.type == VAR_VECTOR2)
    {
        A.type = B.type;
        A.obj = nil;
        A.addr = malloc(sizeof(TC_Position2d));
        ((TC_Position2d*)(A.addr))->x = ((TC_Position2d*)(B.addr))->x;
        ((TC_Position2d*)(A.addr))->y = ((TC_Position2d*)(B.addr))->y;
    }
    else if(B.type == VAR_VECTOR3)
    {
        A.type = B.type;
        A.obj = nil;
        A.addr = malloc(sizeof(TC_Position));
        ((TC_Position*)(A.addr))->x = ((TC_Position*)(B.addr))->x;
        ((TC_Position*)(A.addr))->y = ((TC_Position*)(B.addr))->y;
        ((TC_Position*)(A.addr))->z = ((TC_Position*)(B.addr))->z;
    }
    else if(B.type == VAR_STRING || B.type == VAR_OBJECT||B.type == VAR_LIST)
    {
        A.type = B.type;
        free(A.addr);
        A.addr = nil;
        A.obj = B.obj;
    }
    else if(B.type == VAR_INT)
    {
        A.type = B.type;
        A.obj = nil;
        A.addr = malloc(sizeof(int));
        *((int*)(A.addr)) = *((int*)(B.addr));
    }
    else if(B.type == VAR_FLOAT)
    {
        A.type = B.type;
        A.obj = nil;
        A.addr = malloc(sizeof(float));
        *((float*)(A.addr)) = *((float*)(B.addr));
    }
}
- (void) is:(NSMutableArray*) params// a is b
{
    [self equal:params];
}
- (void) move:(NSMutableArray*) params// a move <5 6 7>
{
    _check_call = YES;
    TC_INS_VARIABLE* A;
    TC_INS_VARIABLE* B;
    if([params count] != 2)
    {
        _check_call = NO;
        return;
    }
    B = [params objectAtIndex:1];
    A = [params objectAtIndex:0];
    if(A.type != VAR_OBJECT || (B.type != VAR_VECTOR2 && B.type != VAR_VECTOR3))
    {
        _check_call = NO;
        return;
    }
    else
    {
        if([((TC_DisplayObject*)(A.obj)) type] == OBJDISPLAY)
        {
            _check_call = NO;
            return;
        }
    }
    
    float x = [((TC_Layer*)(A.obj)) relativePosition].x;
    float y = [((TC_Layer*)(A.obj)) relativePosition].y;
    float z = [((TC_Layer*)(A.obj)) relativePosition].z;
    TC_Position p;
    p.x = x;
    p.y = y;
    p.z = z;

    if(B.type == VAR_VECTOR2)
    {
        
        p.x += ((TC_Position2d*)(B.addr))->x;
        p.y += ((TC_Position2d*)(B.addr))->y;
        ((TC_Layer*)(A.obj)).relativePosition = p;
    }
    else if(B.type == VAR_VECTOR3)
    {
        p.x += ((TC_Position*)(B.addr))->x;
        p.y += ((TC_Position*)(B.addr))->y;
        p.z += ((TC_Position*)(B.addr))->z;
        ((TC_Layer*)(A.obj)).relativePosition = p;
    }
    else
    {
        _check_call = NO;
    }
}
- (void) rotate:(NSMutableArray*) params// a rotate <90>
{
    _check_call = YES;
    TC_INS_VARIABLE* A;
    TC_INS_VARIABLE* B;
    if([params count] != 2)
    {
        _check_call = NO;
        return;
    }
    B = [params objectAtIndex:1];
    A = [params objectAtIndex:0];
    if(A.type != VAR_OBJECT || (B.type != VAR_INT && B.type != VAR_FLOAT))
    {
        _check_call = NO;
        return;
    }
    else
    {
        if([((TC_DisplayObject*)(A.obj)) type] == OBJDISPLAY)
        {
            _check_call = NO;
            return;
        }
    }
    float d = [((TC_Layer*)(A.obj)) relativeRotation];
    if(B.type == VAR_INT)
    {
        d += *((int*)(B.addr));
    }
    else if(B.type == VAR_FLOAT)
    {
        d += *((float*)(B.addr));
    }
    ((TC_Layer*)(A.obj)).relativeRotation = d;
}

- (void) setSeq:(NSMutableArray*) params// a set <3,4,5>
{
    _check_call = YES;
    TC_INS_VARIABLE* A;
    TC_INS_VARIABLE* B;
    if([params count] != 2)
    {
        _check_call = NO;
        return;
    }
    B = [params objectAtIndex:1];
    A = [params objectAtIndex:0];
    if(B.type != VAR_VECTOR3)
    {
        _check_call = NO;
        return;
    }
    if(A.type != VAR_OBJECT)
    {
        _check_call = NO;
        return;
    }
    if(((TC_DisplayObject*)(A.obj)).type != OBJSPRITE)
    {
        _check_call = NO;
        return;
    }
    ((TC_Sprite*)(A.obj)).currentSequence = ((TC_Position*)(B.addr))->x;
    ((TC_Sprite*)(A.obj)).currentFrame = ((TC_Position*)(B.addr))->y;
    ((TC_Sprite*)(A.obj)).frameSpeed = ((TC_Position*)(B.addr))->z;
    
}
- (void) kill:(NSMutableArray*) params// kill a
{
    _check_call = YES;
    if([params count] != 2)
    {
        _check_call = NO;
        return;
    }
    TC_INS_VARIABLE* B;
    B = [params objectAtIndex:1];
    if([((TC_Layer*)(B.obj)) type] == OBJDISPLAY)
    {
        _check_call = NO;
        return;
    }
    ((TC_Layer*)(B.obj)).alive = NO;
}
- (void) hide:(NSMutableArray*) params// a hide
{
    _check_call = YES;
    if([params count] != 1)
    {
        _check_call = NO;
        return;
    }
    TC_INS_VARIABLE* B;
    B = [params objectAtIndex:0];
    if([((TC_Layer*)(B.obj)) type] == OBJDISPLAY)
    {
        _check_call = NO;
        return;
    }
    ((TC_Layer*)(B.obj)).show = NO;
}
- (void) adopt:(NSMutableArray*) params// adopt a
{

}
- (void) abandon:(NSMutableArray*) params// abandon my child abondon a
{

}
- (void) search:(NSMutableArray*) params// search string
{

}
- (void) creat:(NSMutableArray*) params// create prefab position return reult
{

}
- (void) say:(NSMutableArray*) params//say <"hello">
{

}

- (void) push:(NSMutableArray*) params// list push <5,6,7>
{

}

- (void) pop:(NSMutableArray*) params// list pop <5,6,7>
{

}

- (void) has_size:(NSMutableArray*) params// A hassize
{

}

- (void) getobject:(NSMutableArray*) params// A get_object at 3
{

}

- (void) remove:(NSMutableArray*) params//list remove at 4
{

}


/////////////////////////////////////////////////////////////
- (void) ref
{
    TC_INS_VARIABLE* iter;
    
    iter = [_local_var_list objectAtIndex:0];
    ((TC_Position*)iter.addr)->x = ((TC_DisplayObject*)_target).position.x;
    ((TC_Position*)iter.addr)->y = ((TC_DisplayObject*)_target).position.y;
    ((TC_Position*)iter.addr)->z = ((TC_DisplayObject*)_target).position.z;
    
    iter = [_local_var_list objectAtIndex:1];
    ((TC_Position*)iter.addr)->x = ((TC_Layer*)_target).relativePosition.x;
    ((TC_Position*)iter.addr)->y = ((TC_Layer*)_target).relativePosition.y;
    ((TC_Position*)iter.addr)->z = ((TC_Layer*)_target).relativePosition.z;
    
}

- (void) sync
{

}

@end

