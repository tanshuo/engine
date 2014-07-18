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
@synthesize last_true = _last_true;

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
        case ins_jmp_last:
            if(_last_true == YES)
            {
                _ip = [[current src] offset];
                _last_true = YES;
            }
            else
            {
                _last_true = NO;
                _ip++;
            }
            break;
        case ins_jmp:
            _ip = [[current src] offset];
            _true_false = NO;
            break;
        case ins_jmp_false:
            if(_true_false == NO)
            {
                _ip = [[current src] offset];
                _last_true = _true_false;
                _true_false = NO;
            }
            else
            {
                _last_true = YES;
                _true_false = NO;
                _ip++;
            }
            break;
        case ins_jmp_true:
            if(_true_false == YES)
            {
                _last_true = YES;
                _ip = [[current src] offset];
                _true_false = NO;
            }
            else
            {
                _last_true = NO;
                _true_false = NO;
                _ip++;
            }
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
    _ip ++;
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
            //s.location = [(TC_INS_VARIABLE*)[t.params objectAtIndex:i] location];
            //s.argoffset = [(TC_INS_VARIABLE*)[t.params objectAtIndex:i] argoffset];
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
    if([w lengthOfBytesUsingEncoding:NSASCIIStringEncoding] >= 1)
    {
        if([w characterAtIndex:0] == '\"')
        {
            if([w lengthOfBytesUsingEncoding:NSASCIIStringEncoding] < 2)
            {
                _message = [NSMutableString stringWithString:@"\" missing"];
                free(cache);
                NSLog(@"%@",_message); exit(1);
                return nil;
            }
            for(i = 1; i < [w lengthOfBytesUsingEncoding:NSASCIIStringEncoding]; i++)
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
        result.var = v.var;
        result.addr = nil;
        if([[result var] next_layer]!=nil)
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
        if((a - b < 0.000000001  && a - b >= 0)||(b - a < 0.000000001  && b - a >= 0))
        {
            result = YES;
        }
    }
    else if(A.type == VAR_INT && B.type == VAR_FLOAT)
    {
        int a = *((int*)(A.addr));
        float b = *((float*)(B.addr));
        if((a - b < 0.000000001  && a - b >= 0)||(b - a < 0.000000001  && b - a >= 0))
        {
            result = YES;
        }
    }
    else if(A.type == VAR_FLOAT && B.type == VAR_INT)
    {
        float a = *((float*)(A.addr));
        int b = *((int*)(B.addr));
        if((a - b < 0.000000001  && a - b >= 0)||(b - a < 0.000000001  && b - a >= 0))
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
    else if(A.type == VAR_INT && B.type == VAR_FLOAT)
    {
        int a = *((int*)(A.addr));
        float b = *((float*)(B.addr));
        if(a > b)
        {
            result = YES;
        }
    }
    else if(A.type == VAR_FLOAT && B.type == VAR_INT)
    {
        float a = *((float*)(A.addr));
        int b = *((int*)(B.addr));
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
    else if(A.type == VAR_INT && B.type == VAR_FLOAT)
    {
        int a = *((int*)(A.addr));
        float b = *((float*)(B.addr));
        if(a < b)
        {
            result = YES;
        }
    }
    else if(A.type == VAR_FLOAT && B.type == VAR_INT)
    {
        float a = *((float*)(A.addr));
        int b = *((int*)(B.addr));
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
        if(A.addr != nil)
            free(A.addr);
        A.addr = malloc(sizeof(TC_Position2d));
        ((TC_Position2d*)(A.addr))->x = ((TC_Position2d*)(B.addr))->x;
        ((TC_Position2d*)(A.addr))->y = ((TC_Position2d*)(B.addr))->y;
    }
    else if(B.type == VAR_VECTOR3)
    {
        A.type = B.type;
        A.obj = nil;
        if(A.addr != nil)
            free(A.addr);
        A.addr = malloc(sizeof(TC_Position));
        ((TC_Position*)(A.addr))->x = ((TC_Position*)(B.addr))->x;
        ((TC_Position*)(A.addr))->y = ((TC_Position*)(B.addr))->y;
        ((TC_Position*)(A.addr))->z = ((TC_Position*)(B.addr))->z;
    }
    else if(B.type == VAR_STRING || B.type == VAR_OBJECT||B.type == VAR_LIST)
    {
        A.type = B.type;
        if(A.addr != nil)
            free(A.addr);
        A.addr = nil;
        A.obj = B.obj;
    }
    else if(B.type == VAR_INT)
    {
        A.type = B.type;
        A.obj = nil;
        if(A.addr != nil)
            free(A.addr);
        A.addr = malloc(sizeof(int));
        *((int*)(A.addr)) = *((int*)(B.addr));
    }
    else if(B.type == VAR_FLOAT)
    {
        A.type = B.type;
        A.obj = nil;
        if(A.addr != nil)
            free(A.addr);
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
    ((TC_Sprite*)(A.obj)).currentSequence = ((TC_Position*)(B.addr))->y;
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
    _check_call = YES;
    if([params count] != 2)
    {
        _check_call = NO;
        return;
    }
    TC_INS_VARIABLE* A;
    TC_INS_VARIABLE* B;
    B = [params objectAtIndex:1];
    A = [params objectAtIndex:0];
    if(A.type != VAR_OBJECT || B.type != VAR_OBJECT)
    {
        _check_call = NO;
        return;
    }
    else if(((TC_Layer*)A.obj).type == OBJDISPLAY || ((TC_Layer*)B.obj).type == OBJDISPLAY)
    {
        _check_call = NO;
        return;
    }
    [A.obj addChild:B.obj];
}
- (void) abandon:(NSMutableArray*) params// abandon my child abondon a
{
    _check_call = YES;
    if([params count] != 2)
    {
        _check_call = NO;
        return;
    }
    TC_INS_VARIABLE* A;
    TC_INS_VARIABLE* B;
    B = [params objectAtIndex:1];
    A = [params objectAtIndex:0];
    if(A.type != VAR_OBJECT || B.type != VAR_INT)
    {
        _check_call = NO;
        return;
    }
    else if(((TC_Layer*)A.obj).type == OBJDISPLAY)
    {
        _check_call = NO;
        return;
    }
    [A.obj removeChildByID:*((int*)(B.addr))];
}
- (void) search:(NSMutableArray*) params// search string
{
    _check_call = YES;
    if([params count] != 2)
    {
        _check_call = NO;
        return;
    }
    TC_INS_VARIABLE* B;
    B = [params objectAtIndex:1];
    if(B.type != VAR_STRING)
    {
        _check_call = NO;
        return;
    }
    int result = findIDByName((char*)[((NSString*)B.obj) cStringUsingEncoding:NSASCIIStringEncoding]);
    TC_INS_VARIABLE* v = [TC_INS_VARIABLE alloc];
    v.type = VAR_INT;
    v.location = VAR_BIND;
    v.addr = malloc(sizeof(int));
    v.obj = nil;
    v.solved = YES;
    v.borrow = YES;
    v.argoffset = 0;
    v.var = nil;
    *((int*)(v.addr)) = result;
    _result = v;
}
- (void) create:(NSMutableArray*) params// A create prefab position to B
{
    _check_call = YES;
    if([params count] != 4)
    {
        _check_call = NO;
        return;
    }
    TC_INS_VARIABLE* prefab;
    prefab = [params objectAtIndex:1];
    TC_INS_VARIABLE* position;
    position = [params objectAtIndex:2];
    TC_INS_VARIABLE* A;
    A = [params objectAtIndex:3];
    TC_INS_VARIABLE* parent;
    parent = [params objectAtIndex:0];
    TC_Position temp;
    
    if(prefab.type != VAR_STRING || position.type != VAR_VECTOR3 || parent.type != VAR_OBJECT)
    {
        _check_call = NO;
        return;
    }
    if(((TC_DisplayObject*)parent).type == OBJDISPLAY)
    {
        _check_call = NO;
        return;
    }
    
    TC_Sprite* result = [TC_Sprite alloc];
    [result born:prefab.obj atGroup:[_target group]];
    temp.x = ((TC_Position*)(position.addr))->x;
    temp.y = ((TC_Position*)(position.addr))->y;
    temp.z = ((TC_Position*)(position.addr))->z;
    result.relativePosition = temp;
    
    [((TC_Layer*)(parent.obj)) addChild:result];
    
    A.obj = result;
    if(A.addr != nil)
        free(A.addr);
    A.addr = nil;
    A.type = VAR_OBJECT;
}

- (void) getX:(NSMutableArray*) params// <1,2,3> getX to C .. <1,2,3> getX
{
    _check_call = YES;
    if([params count] != 2)
    {
        _check_call = NO;
        return;
    }
    
    TC_INS_VARIABLE* A;
    A = [params objectAtIndex:0];
    TC_INS_VARIABLE* B;
    B = [params objectAtIndex:1];
    if(A.type != VAR_VECTOR3 && A.type != VAR_VECTOR2)
    {
        _check_call = NO;
        return;
    }
    B.obj = nil;
    if(B.addr)
    {
        free(B.addr);
        B.addr = nil;
    }
    B.type = VAR_FLOAT;
    B.addr = malloc(sizeof(float));
    if(A.type == VAR_VECTOR3)
        *((float*)B.addr) = ((TC_Position*)A.addr)->x;
    else
        *((float*)B.addr) = ((TC_Position2d*)A.addr)->x;
}

- (void) getY:(NSMutableArray*) params// <1,2,3> gety to C .. <1,2,3> getY
{
    _check_call = YES;
    if([params count] != 2)
    {
        _check_call = NO;
        return;
    }
    
    TC_INS_VARIABLE* A;
    A = [params objectAtIndex:0];
    TC_INS_VARIABLE* B;
    B = [params objectAtIndex:1];
    if(A.type != VAR_VECTOR3 && A.type != VAR_VECTOR2)
    {
        _check_call = NO;
        return;
    }
    B.obj = nil;
    if(B.addr)
    {
        free(B.addr);
        B.addr = nil;
    }
    B.type = VAR_FLOAT;
    B.addr = malloc(sizeof(float));
    if(A.type == VAR_VECTOR3)
        *((float*)B.addr) = ((TC_Position*)A.addr)->y;
    else
        *((float*)B.addr) = ((TC_Position2d*)A.addr)->y;
}

- (void) getZ:(NSMutableArray*) params// <1,2,3> getz to C .. <1,2,3> getz
{
    _check_call = YES;
    if([params count] != 2)
    {
        _check_call = NO;
        return;
    }
    
    TC_INS_VARIABLE* A;
    A = [params objectAtIndex:0];
    TC_INS_VARIABLE* B;
    B = [params objectAtIndex:1];
    if(A.type != VAR_VECTOR3)
    {
        _check_call = NO;
        return;
    }
    B.obj = nil;
    if(B.addr)
    {
        free(B.addr);
        B.addr = nil;
    }
    B.type = VAR_FLOAT;
    B.addr = malloc(sizeof(float));
    *((float*)B.addr) = ((TC_Position*)A.addr)->z;
}

- (void) say:(NSMutableArray*) params//say <"hello">
{
    NSString* somebody;
    NSString* something;
    _check_call = YES;
    if([params count] != 2)
    {
        _check_call = NO;
        return;
    }
    TC_INS_VARIABLE* A;
    A = [params objectAtIndex:0];
    TC_INS_VARIABLE* B;
    B = [params objectAtIndex:1];
    if(A.type != VAR_OBJECT)
    {
        _check_call = NO;
        return;
    }
    somebody = ((TC_DisplayObject*)A.obj).name;
    
    switch(B.type)
    {
        case VAR_STRING:
            something = B.obj;
            break;
        
        case VAR_INT:
            something = [NSString stringWithFormat:@"%d",*((int*)(B.addr))];
            break;
        
        case VAR_FLOAT:
            something = [NSString stringWithFormat:@"%f",*((float*)(B.addr))];
            break;
        
        case VAR_VECTOR2:
            something = [NSString stringWithFormat:@"<%f, %f>",((TC_Position2d*)(B.addr))->x,((TC_Position2d*)(B.addr))->y];
            break;
            
        case VAR_VECTOR3:
            something = [NSString stringWithFormat:@"<%f, %f, %f>",((TC_Position*)(B.addr))->x,((TC_Position*)(B.addr))->y,((TC_Position*)(B.addr))->z];
            break;
            
        case VAR_OBJECT:
            something = ((TC_DisplayObject*)(B.obj)).name;
            break;
            
        case VAR_UNKNOWN:
            something = @"unknown";
            break;
            
        case VAR_LIST:
            something = [NSString stringWithFormat: @"list with %d objects",[((NSMutableArray*)(B.obj)) count]];
            break;
        case VAR_OFF_SET:
            break;
    }
    NSLog(@"%@ output: %@", somebody, something);
}

- (void) push:(NSMutableArray*) params// list push <5,6,7>
{
    _check_call = YES;
    if([params count] != 2)
    {
        _check_call = NO;
        return;
    }
    TC_INS_VARIABLE* A;
    A = [params objectAtIndex:0];
    TC_INS_VARIABLE* B;
    B = [params objectAtIndex:1];
    
    if(A.type != VAR_LIST)
    {
        _check_call = NO;
        return;
    }
    [((NSMutableArray*)(A.obj)) addObject:B.obj];
}

- (void) pop:(NSMutableArray*) params// list pop to A
{
    _check_call = YES;
    if([params count] != 2)
    {
        _check_call = NO;
        return;
    }
    TC_INS_VARIABLE* A;
    A = [params objectAtIndex:0];
    TC_INS_VARIABLE* B;
    B = [params objectAtIndex:1];
    TC_INS_VARIABLE* temp;
    NSMutableArray* a = [NSMutableArray arrayWithCapacity:10];
    
    if(A.type != VAR_LIST)
    {
        _check_call = NO;
        return;
    }
    temp = [((NSMutableArray*)(A.obj)) lastObject];
    [a addObject:B];
    [a addObject: temp];
    [self set: a];
    [((NSMutableArray*)(A.obj)) removeLastObject];
}


- (void) getSize:(NSMutableArray*) params// A getSize to B
{
    _check_call = YES;
    if([params count] != 2)
    {
        _check_call = NO;
        return;
    }
    TC_INS_VARIABLE* A;
    A = [params objectAtIndex:0];
    TC_INS_VARIABLE* B;
    B = [params objectAtIndex:1];

    if(A.type != VAR_LIST)
    {
        _check_call = NO;
        return;
    }
    
    B.type = VAR_INT;
    if(B.addr)
    {
        free(B.addr);
        B.addr = nil;
    }
    B.obj = nil;
    B.addr = malloc(sizeof(int));
    *((int*)B.addr) = [(NSMutableArray*)A.obj count];
}

- (void) getobject:(NSMutableArray*) params// A get_object at 3 to B
{
    _check_call = YES;
    if([params count] != 2)
    {
        _check_call = NO;
        return;
    }
    TC_INS_VARIABLE* A;
    A = [params objectAtIndex:0];
    TC_INS_VARIABLE* B;
    B = [params objectAtIndex:1];
    TC_INS_VARIABLE* C;
    C = [params objectAtIndex:2];
    TC_INS_VARIABLE* temp;
    NSMutableArray* a = [NSMutableArray arrayWithCapacity:10];
    
    if(A.type != VAR_LIST)
    {
        _check_call = NO;
        return;
    }
    if(B.type != VAR_INT)
    {
        _check_call = NO;
        return;
    }
    int index = *((int*)B.addr);
    int size = [(NSMutableArray*)A.obj count];
    if(index >= size)
    {
        _check_call = NO;
        return;
    }
    
    temp = [(NSMutableArray*)A.obj objectAtIndex:index];
    [a addObject:C];
    [a addObject:temp];
    [self set: a];
}

- (void) remove:(NSMutableArray*) params//list remove at 4
{
    _check_call = YES;
    if([params count] != 2)
    {
        _check_call = NO;
        return;
    }
    TC_INS_VARIABLE* A;
    A = [params objectAtIndex:0];
    TC_INS_VARIABLE* B;
    B = [params objectAtIndex:1];
    if(A.type != VAR_LIST)
    {
        _check_call = NO;
        return;
    }
    if(B.type != VAR_INT)
    {
        _check_call = NO;
        return;
    }
    int index = *((int*)(B.addr));
    int size = [(NSMutableArray*)A.obj count];
    if(index >= size)
    {
        _check_call = NO;
        return;
    }
    else
        [((NSMutableArray*)(A.obj)) removeObjectAtIndex:index];
}

- (void) change:(NSMutableArray*) params//<"x"> change to <4> in A
{
    _check_call = YES;
    if([params count] != 3)
    {
        _check_call = NO;
        return;
    }
    TC_INS_VARIABLE* A = nil;
    TC_INS_VARIABLE* B = nil;
    TC_INS_VARIABLE* C = nil;
    NSString* attribute;
    TC_Position temp;
    A = [params objectAtIndex:0];
    if(A.type != VAR_STRING)
    {
        _check_call = NO;
        return;
    }
    attribute = A.obj;
    B = [params objectAtIndex:1];
    C = [params objectAtIndex:2];
    
    if(C.type != VAR_OBJECT)
    {
        _check_call = NO;
        return;
    }
    
    TC_DisplayObject* target;
    target = C.obj;
    
    if([attribute isEqualToString:@"position"] && ((TC_DisplayObject*)target).type != OBJDISPLAY)
    {
        if(B.type == VAR_VECTOR2)
        {
            temp.x = ((TC_Position2d*)(B.addr))->x;
            temp.y = ((TC_Position2d*)(B.addr))->y;
            temp.z = ((TC_Layer*)target).relativePosition.z;
            ((TC_Layer*)target).relativePosition = temp;
        }
        else if(B.type == VAR_VECTOR3)
        {
            temp.x = ((TC_Position*)(B.addr))->x;
            temp.y = ((TC_Position*)(B.addr))->y;
            temp.z = ((TC_Position*)(B.addr))->z;
            ((TC_Layer*)target).relativePosition = temp;
        }
        else
        {
            _check_call = NO;
            return;
        }
    }
    else if([attribute isEqualToString:@"position"] && ((TC_DisplayObject*)target).type != OBJDISPLAY)
    {
        if(B.type == VAR_FLOAT)
        {
            ((TC_Layer*)target).relativeRotation = *((float*)(B.addr));
        }
        else if(B.type == VAR_INT)
        {
            ((TC_Layer*)target).relativeRotation = *((int*)(B.addr));
        }
        else
        {
            _check_call = NO;
            return;
        }
    }
    else if([attribute isEqualToString:@"scale"])
    {
        if(B.type == VAR_VECTOR2)
        {
            temp.x = ((TC_Position2d*)(B.addr))->x;
            temp.y = ((TC_Position2d*)(B.addr))->y;
            ((TC_DisplayObject*)target).h = temp.x;
            ((TC_DisplayObject*)target).w = temp.y;
        }
        else
        {
            _check_call = NO;
            return;
        }
    }
    else if([attribute isEqualToString:@"alive"]&& ((TC_DisplayObject*)target).type != OBJDISPLAY)
    {
        if(B.type == VAR_INT)
        {
            if(((int*)(B.addr)) == 0)
            {
                ((TC_Layer*)target).alive = NO;
            }
            else
            {
                ((TC_Layer*)target).alive = YES;
            }
        }
        else
        {
            _check_call = NO;
            return;
        }
    }
    else if([attribute isEqualToString:@"show"])
    {
        if(B.type == VAR_INT)
        {
            if(((int*)(B.addr)) == 0)
            {
                ((TC_DisplayObject*)target).show = NO;
            }
            else
            {
                ((TC_DisplayObject*)target).show = YES;
            }
        }
        else
        {
            _check_call = NO;
            return;
        }
    }
    else if([attribute isEqualToString:@"active"])
    {
        if(B.type == VAR_INT)
        {
            if(((int*)(B.addr)) == 0)
            {
                ((TC_DisplayObject*)target).active = NO;
            }
            else
            {
                ((TC_DisplayObject*)target).active = YES;
            }
        }
        else
        {
            _check_call = NO;
            return;
        }
    }
    else if([attribute isEqualToString:@"label"])
    {
        if(B.type == VAR_INT)
        {
            ((TC_DisplayObject*)target).label = *((int*)(B.addr));
        }
        else
        {
            _check_call = NO;
            return;
        }
    }
    else if([attribute isEqualToString:@"current_seq"] && ((TC_DisplayObject*)target).type == OBJSPRITE)
    {
        if(B.type == VAR_INT)
        {
            ((TC_Sprite*)target).currentSequence = *((int*)(B.addr));
        }
        else
        {
            _check_call = NO;
            return;
        }
    }
    else if([attribute isEqualToString:@"current_frame"] && ((TC_DisplayObject*)target).type == OBJSPRITE)
    {
        if(B.type == VAR_INT)
        {
            ((TC_Sprite*)target).currentFrame = *((int*)(B.addr));
        }
        else
        {
            _check_call = NO;
            return;
        }
    }
    else if([attribute isEqualToString:@"frame_speed"] && ((TC_DisplayObject*)target).type == OBJSPRITE)
    {
        if(B.type == VAR_INT)
        {
            ((TC_Sprite*)target).frameSpeed = *((int*)(B.addr));
        }
        else
        {
            _check_call = NO;
            return;
        }
    }
}

- (void) get:(NSMutableArray*) params//B get <"scale"> to A
{
    _check_call = YES;
    if([params count] != 3)
    {
        _check_call = NO;
        return;
    }
    TC_INS_VARIABLE* A = nil;
    TC_INS_VARIABLE* B = nil;
    TC_INS_VARIABLE* C = nil;
    TC_INS_VARIABLE* des = nil;
    
    NSString* attribute;
    TC_Position temp;
    TC_DisplayObject* target;
    A = [params objectAtIndex:0];
    B = [params objectAtIndex:1];
    C = [params objectAtIndex:2];
    
    if(A.type != VAR_OBJECT)
    {
        _check_call = NO;
        return;
    }
    if(B.type != VAR_STRING)
    {
        _check_call = NO;
        return;
    }
    attribute = B.obj;
    target = A.obj;
    des = C;
    
    if(target.type != OBJDISPLAY)
    {
        if([attribute isEqualToString:@"position"])
        {
            des.type = VAR_VECTOR3;
            des.obj = nil;
            if(des.addr)
            {
                free(des.addr);
                des.addr = nil;
            }
            temp = [(TC_Layer*)target relativePosition];
            des.addr = malloc(sizeof(TC_Position));
            *((TC_Position*)(des.addr)) = temp;
        }
        else if([attribute isEqualToString:@"alive"])
        {
            des.type = VAR_INT;
            des.obj = nil;
            if(des.addr)
            {
                free(des.addr);
                des.addr = nil;
            }
            des.addr = malloc(sizeof(int));
            *((int*)(des.addr)) = [(TC_Layer*)target alive];
        }
        else if([attribute isEqualToString:@"parent"])
        {
            des.type = VAR_OBJECT;
            if(des.addr)
            {
                free(des.addr);
                des.addr = nil;
            }
            des.obj = [((TC_Layer*)target) parent];
        }
        else if([attribute isEqualToString:@"childs"])
        {
            des.type = VAR_LIST;
            if(des.addr)
            {
                free(des.addr);
                des.addr = nil;
            }
            des.obj = [((TC_Layer*)target) child];
        }
        else if([attribute isEqualToString:@"rotation"])
        {
            des.type = VAR_FLOAT;
            des.obj = nil;
            if(des.addr)
            {
                free(des.addr);
                des.addr = nil;
            }
            des.addr = malloc(sizeof(float));
            *((float*)(des.addr)) = [(TC_Layer*)target relativeRotation];
        }
        
    }
    if(target.type == OBJSPRITE)
    {
        if([attribute isEqualToString:@"current_sequence"])
        {
            des.type = VAR_INT;
            des.obj = nil;
            if(des.addr)
            {
                free(des.addr);
                des.addr = nil;
            }
            des.addr = malloc(sizeof(int));
            *((int*)(des.addr)) = [(TC_Sprite*)target currentSequence];
        }
        else if([attribute isEqualToString:@"current_frame"])
        {
            des.type = VAR_INT;
            des.obj = nil;
            if(des.addr)
            {
                free(des.addr);
                des.addr = nil;
            }
            des.addr = malloc(sizeof(int));
            *((int*)(des.addr)) = [(TC_Sprite*)target currentFrame];
        }
        else if([attribute isEqualToString:@"frame_speed"])
        {
            des.type = VAR_INT;
            des.obj = nil;
            if(des.addr)
            {
                free(des.addr);
                des.addr = nil;
            }
            des.addr = malloc(sizeof(int));
            *((int*)(des.addr)) = [(TC_Sprite*)target frameSpeed];
        }
    }
    
    if([attribute isEqualToString:@"name"])
    {
        if(des.addr)
        {
            free(des.addr);
            des.addr = nil;
        }
        des.type = VAR_STRING;
        des.obj = target.name;
    }
    else if([attribute isEqualToString:@"id"])
    {
        des.type = VAR_INT;
        des.obj = nil;
        if(des.addr)
        {
            free(des.addr);
            des.addr = nil;
        }
        des.addr = malloc(sizeof(int));
        *((int*)(des.addr)) = [(TC_DisplayObject*)target oid];
    }
    else if([attribute isEqualToString:@"label"])
    {
        des.type = VAR_INT;
        des.obj = nil;
        if(des.addr)
        {
            free(des.addr);
            des.addr = nil;
        }
        des.addr = malloc(sizeof(int));
        *((int*)(des.addr)) = [target label];
    }
    else if([attribute isEqualToString:@"group"])
    {
        des.type = VAR_INT;
        des.obj = nil;
        if(des.addr)
        {
            free(des.addr);
            des.addr = nil;
        }
        des.addr = malloc(sizeof(int));
        *((int*)(des.addr)) = [(TC_Layer*)target group];
    }
    else if([attribute isEqualToString:@"active"])
    {
        des.type = VAR_INT;
        des.obj = nil;
        if(des.addr)
        {
            free(des.addr);
            des.addr = nil;
        }
        des.addr = malloc(sizeof(int));
        *((int*)(des.addr)) = [(TC_DisplayObject*)target active];
    }
    
    else if([attribute isEqualToString:@"screen_position"])
    {
        des.type = VAR_VECTOR3;
        des.obj = nil;
        if(des.addr)
        {
            free(des.addr);
            des.addr = nil;
        }
        temp = [target position];
        des.addr = malloc(sizeof(TC_Position));
        *((TC_Position*)(des.addr)) = temp;
    }
    
}
/////////////////////////////////////////////////////////////
@end
