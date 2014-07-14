//
//  TC_Interpretor.m
//  try
//
//  Created by tanshuo on 6/27/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//

// merge 'of'->merge function->fork->keyword control

#import "TC_Interpretor.h"

@implementation TC_Interpretor
@synthesize currentLine = _currentLine;
@synthesize line = _line;
@synthesize var_table = _var_table;
@synthesize func_table = _func_table;
@synthesize defines = _defines;
@synthesize input = _input;
@synthesize message = _message;
@synthesize instruction_table = _instruction_table;
@synthesize var_stack = _var_stack;




- (int) loadFile:(NSString *)file
{
    NSString* path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"script"];
    
    _input = fopen([path cStringUsingEncoding:NSASCIIStringEncoding], "r");
    if(_input < 0)
    {
        _message = [NSMutableString stringWithString:@"no such file"];
        return -1; // no file
    }
    else
        return 0;
}
- (int) readLine
{
    char c;
    NSMutableString* linecache = [NSMutableString stringWithCapacity:10];
    char buff[2];
    
    while(true)
    {
        c = getc(_input);
        if(c != EOF && c != ';')
        {
            if(c == '\n' || c == '\t')
            {
                if(c == '\n')
                {
                    _currentLine++;
                }
                c = ' ';
            }
            buff[0] = c;
            buff[1] = 0;
            [linecache appendString: [NSMutableString stringWithCString:buff encoding:NSASCIIStringEncoding]];
            //index ++;
        }
        else if(c == EOF)
        {
            _line = linecache;
            return -1;
        }
        else
        {
            _line = linecache;
            return 1;
        }
        
    }
}
- (int) genTree
{
    [_root removeAllObjects];
    int i;
    int j;
    for(i = 0; i < [_defines count]; i++)
    {
        if([[_defines objectAtIndex:i] explain] == TC_IGNORE)
        {
            [_defines removeObject:[_defines objectAtIndex:i]];
        }
    }
    //define statement
    int head = [[_defines objectAtIndex:0] explain];
    if(head == TC_DEFINE)
    {
        if([_defines count] < 2)
        {
            _message = [NSMutableString stringWithString:@"define statement format error"];
            return -1;
        }
        //find name
        NSString* name = nil;
        int rm = 0;//right match
        NSMutableArray* params = [NSMutableArray arrayWithCapacity:10];
        for(j = 1; j < [_defines count]; j++)
        {
            if([[_defines objectAtIndex:j] explain] == TC_FUNCTION)
            {
                name = [[_defines objectAtIndex:j] word];
                rm = [[_defines objectAtIndex:j] right_match];
            }
            else if([[_defines objectAtIndex:j] explain]  == TC_VAR)
            {
                TC_WORD_LAYER* temp = [TC_WORD_LAYER alloc];
                temp.word = [[_defines objectAtIndex:j] word];
                temp.next_layer = nil;
                [params addObject: temp];
            }
            else if([[_defines objectAtIndex:j] explain] == TC_IGNORE)
            {
                
            }
            else
            {
                _message = [NSMutableString stringWithString:@"define statement format error"];
                return -1;
            }
        }
        if(name == nil)
        {
            _message = [NSMutableString stringWithString:@"define can not locate the function name"];
            return -1;
        }
        
        TC_Function_Layer* temp = [TC_Function_Layer alloc];
        temp.right_match = rm;
        temp.name = name;
        
        TC_INS_FUNCTION* result;
        result = [self searchFunction:temp];
        if(result == nil)
        {
            _message = [NSMutableString stringWithString:@"function has not been declared: "];
            [_message appendString:temp.name];
            return -1;
        }
        else if(result.location == FUN_BIND)
        {
            _message = [NSMutableString stringWithString:@"function has been binded: "];
            [_message appendString:temp.name];
            return -1;
        }
        else if(result.solved == YES)
        {
            _message = [NSMutableString stringWithString:@"function has been defined: "];
            [_message appendString:temp.name];
            return -1;
        }
        else
        {
            result.solved = YES;
            result.location = FUN_DEFINE;
            result.offset = _current_ins_count;
            
            TC_INS_VARIABLE* arg;
            for(i = 0; i < [params count]; i++)
            {
                arg = [TC_INS_VARIABLE alloc];
                arg.solved = YES;
                arg.location = VAR_STACK;
                arg.addr = nil;
                arg.obj = nil;
                arg.type = VAR_UNKNOWN;
                arg.argoffset = i;
                arg.borrow = NO;
                arg.var = [params objectAtIndex:i];
                [_var_stack addObject:arg];
            }
        }
        return 0;
    }
    else if(head == TC_END_DEF)
    {
        if([_defines count] != 1)
        {
            _message = [NSMutableString stringWithString:@"enddef statement format error"];
            return -1;
        }
        
        TC_Instruction* A;
        A = [TC_Instruction alloc];
        A.instruct = ins_rtn;
        A.params = nil;
        A.src = nil;
        A.des = nil;
        [_instruction_table addObject:A];
        _current_ins_count ++;
        
        [_var_stack removeAllObjects];
        return 0;
    }
    else if(head == TC_PUSH)
    {
        if([_defines count] != 2)
        {
            _message = [NSMutableString stringWithString:@"push statement error, should be push VAR"];
            return -1;
        }
        else
        {
            TC_WORD_LAYER* l;
            l = [TC_WORD_LAYER alloc];
            l.word = [[_defines objectAtIndex:1] word];
            l.type = 0;
            TC_INS_VARIABLE* var;
            var = [TC_INS_VARIABLE alloc];
            var.solved = NO;
            var.location = VAR_STACK;
            var.argoffset = 0;
            var.borrow = NO;
            var.type = VAR_UNKNOWN;
            var.addr = nil;
            var.obj = nil;
            var.var = l;
            TC_Instruction* A;
            A = [TC_Instruction alloc];
            A.instruct = ins_push;
            A.params = nil;
            A.src = var;
            A.des = nil;
            [_instruction_table addObject:A];
            _current_ins_count ++;
            return 0;
        }
    }
    else if(head == TC_RETURN)
    {
        if([_defines count] != 1)
        {
            _message = [NSMutableString stringWithString:@"return statement error"];
            return -1;
        }
        else
        {
            TC_Instruction* A;
            A = [TC_Instruction alloc];
            A.instruct = ins_rtn;
            A.params = nil;
            A.src = nil;
            A.des = nil;
            [_instruction_table addObject:A];
            _current_ins_count ++;
            return 0;
        }
    }
    //control

    int type;
    for(i = 0;i < [_defines count];i ++)//gen logical layer
    {
        type = [[_defines objectAtIndex:i] explain];
        if(type ==  TC_IF || type ==  TC_AFTER || type ==  TC_WHILE || type == TC_THEN || type == TC_END || type == TC_BREAK || type == TC_RETURN)
        {
            TC_Conrol_Layer* newlayer;
            newlayer = [TC_Conrol_Layer alloc];
            newlayer.type = type;
            newlayer.word_count = 0;
            newlayer.logical = [NSMutableArray arrayWithCapacity:10];
            for(j = i + 1; j < [_defines count]; j ++)
            {
                int type;
                type = [[_defines objectAtIndex:j] explain];
                if(type ==  TC_IF || type ==  TC_AFTER || type ==  TC_WHILE || type == TC_THEN || type == TC_END ||type == TC_BREAK||type == TC_RETURN)
                {
                    i = j - 1;
                    break;
                }
                else
                {
                    [newlayer.logical addObject:[_defines objectAtIndex:j]];
                }
            }
            if([newlayer.logical count] == 0)
            {
                newlayer.logical = nil;
                [_root addObject:newlayer];
            }
            else
            {
                newlayer.logical = [self genLogical:newlayer.logical];
                if(newlayer.logical == nil)
                {
                    _root = nil;//gramma error
                    return -1;
                }
                [_root addObject:newlayer];
            }
        }
    }
    if([_root count] == 0) // -1 if no control statement
    {
        TC_Conrol_Layer* newlayer;
        newlayer = [TC_Conrol_Layer alloc];
        newlayer.type = -1;
        newlayer.word_count = 0;
        newlayer.logical = [NSMutableArray arrayWithCapacity:10];
        for(i = 0;i < [_defines count];i ++)
        {
            [newlayer.logical addObject:[_defines objectAtIndex:i]];
        }
        newlayer.logical = [self genLogical:newlayer.logical];
        if(newlayer.logical == nil)
        {
            _root = nil;//gramma error
            return -1;
        }
        [_root addObject:newlayer];
    }
    return 0;
}
- (void)start
{
    _current_ins_count = 0;
    _currentLine = 0;
    _defines = [NSMutableArray arrayWithCapacity:10];
    _dictionary = [NSMutableArray arrayWithCapacity:10];
    _root = [NSMutableArray arrayWithCapacity:10];
    _message = [NSMutableString stringWithString:@""];
    _instruction_table = [NSMutableArray arrayWithCapacity:10];
    _func_table = [NSMutableArray arrayWithCapacity:10];
    _var_table = [NSMutableArray arrayWithCapacity:10];
    _var_stack = [NSMutableArray arrayWithCapacity:10];
    [self initDictionary];
    [self initFunction];
}

- (int) read_a_tokens
{
    char* wordbuff;
    wordbuff = (char*) malloc(MAX_LINE_SIZE);
    if(wordbuff == nil)
    {
        _message = [NSMutableString stringWithString:@"no enough mem"];
        return -1;
    }
    char c;
    int i = 0;
    int j = 0;
    BOOL flag = NO;
    BOOL stick = NO;
    BOOL stick2 = NO;
    BOOL last_word_is_data = NO;
    [_defines removeAllObjects];
    int length = [_line lengthOfBytesUsingEncoding:NSASCIIStringEncoding];
    
    while(true)
    {
        if(i >= length)
        {
            
            wordbuff[j] = 0;
            if(j == 0)
            {
                return 1;
            }
            TC_Define* token;
            token = [self searchDictionary:[NSString stringWithUTF8String:wordbuff]];
            if(!token)
            {
                _message = [NSMutableString stringWithString:@"no such period"];
                free(wordbuff);
                return 0;// no such ,
            }
            [_defines addObject:token];
            free(wordbuff);
            return 1;
        }
        
        c = [_line characterAtIndex:i];
        if(stick == NO && (c == ',' || c == ';'||c == '.'))
        {
           
            wordbuff[j] = 0;
            TC_Define* token = [self searchDictionary:[NSString stringWithUTF8String:wordbuff]];
            if(j == 0)
            {
                wordbuff[0] = c;
                wordbuff[1] = 0;
                TC_Define* token = [self searchDictionary:[NSString stringWithUTF8String:wordbuff]];
                if(!token)
                {
                    _message = [NSMutableString stringWithString:@"no such period"];
                    free(wordbuff);
                    return 0;// no such ,
                }
                [_defines addObject:token];
                j = 0;
                flag = NO;
            }
            else if(last_word_is_data == YES)
            {
                TC_Define* newdef;
                newdef = [TC_Define alloc];
                newdef.explain = TC_INSTANCE;
                newdef.word = [NSString stringWithUTF8String:wordbuff];
                newdef.right_match = 0;
                [_defines addObject:newdef];
                last_word_is_data = NO;
                wordbuff[0] = c;
                wordbuff[1] = 0;
                token = [self searchDictionary:[NSString stringWithUTF8String:wordbuff]];
                if(!token)
                {
                    _message = [NSMutableString stringWithString:@"no such period"];
                    free(wordbuff);
                    return 0;// no such ,
                }
                [_defines addObject:token];
                j = 0;
                flag = NO;
            }
            else if(token)
            {
                [_defines addObject:token];
                wordbuff[0] = c;
                wordbuff[1] = 0;
                token = [self searchDictionary:[NSString stringWithUTF8String:wordbuff]];
                if(!token)
                {
                    _message = [NSMutableString stringWithString:@"no such period"];
                    free(wordbuff);
                    return 0;// no such ,
                }
                [_defines addObject:token];
                j = 0;
                flag = NO;
                //return 2;
            }
            else
            {
                _message = [NSMutableString stringWithString:@"can not find the word: "];
                [_message appendString:[NSString stringWithUTF8String:wordbuff]];
                free(wordbuff);
                return 0;
            } // no such word
        }
        else if(c == '<')
        {
            if(stick == NO)
            {
                stick = YES;
                last_word_is_data = YES;
                wordbuff[j] = '#';
                j++;
            }
            else
            {
                _message = [NSMutableString stringWithString:@"double <"];
                free(wordbuff);
                return 0;
            }
        }
        else if(c == '>')
        {
            if(stick == YES && stick2 == NO)
            {
                stick = NO;
                //wordbuff[j] = 0;
            }
            else if(stick == YES && stick2 == YES)
            {
                wordbuff[j] = c;
                j++;
                i++;
                continue;
            }
            else
            {
                _message = [NSMutableString stringWithString:@"double >"];
                free(wordbuff);
                return 0;
            }
        }
        else if(flag && (c == ' ' || c == '\n' || c == '\t'))
        {
            if(stick == YES)
            {
                flag = YES;
                
                wordbuff[j] = c;
                i++;
                continue;
            }
            wordbuff[j] = 0;
            
            TC_Define* token = [self searchDictionary:[NSString stringWithUTF8String:wordbuff]];
            if(last_word_is_data == YES)
            {
                TC_Define* newdef;
                newdef = [TC_Define alloc];
                newdef.explain = TC_INSTANCE;
                newdef.word = [NSString stringWithUTF8String:wordbuff];
                newdef.right_match = 0;
                [_defines addObject:newdef];
                last_word_is_data = NO;
                j = 0;
                flag = 0;
            }
            else if(token)
            {
                [_defines addObject:token];
                j = 0;
                flag = NO;
                //return 1;
            }
            else
            {
                _message = [NSMutableString stringWithString:@"can not find the word: "];
                [_message appendString:[NSString stringWithUTF8String:wordbuff]];
                free(wordbuff);
                return 0;// no such word
            }
            
        }
        else if(!(c == EOF || c == ' ' || c == '\n' || c == '\t'))
        {
            flag = YES;
            if(c == '\"')
            {
                if(stick2 == NO)
                {
                    stick2 = YES;
                }
                else
                {
                    stick2 = NO;
                }
            }
            wordbuff[j] = c;
            
            if(j < MAX_LINE_SIZE - 1)
                j ++;
            else
            {
                _message = [NSMutableString stringWithString:@"over flow"];
                free(wordbuff);
                return -1;
            }
        }
        i ++;
    }
    return 1;
}

- (TC_Define*) searchDictionary: (NSString*) word
{
    int i;
    for(i = 0; i < [_dictionary count]; i ++)
    {
        if([[[_dictionary objectAtIndex: i] word] isEqualToString: word])
        {
            return [_dictionary objectAtIndex: i];
        }
    }
    TC_Define* temp;
    temp = [TC_Define alloc];
    temp.explain = TC_VAR;
    temp.right_match = 0;
    temp.word = word;
    return temp;
}

//sentence is array of defines
- (TC_Logical_Layer*) genLogical:(NSMutableArray*) sentence
{
    if([sentence count] == 0)
    {
        return nil;
    }
    
    NSMutableArray* stack;
    NSMutableArray* operator;
    NSMutableArray* function_express;
    NSMutableArray* fc_array;
    function_express = [NSMutableArray arrayWithCapacity:10];
    stack = [NSMutableArray arrayWithCapacity:10];
    fc_array = [NSMutableArray arrayWithCapacity:10];
    operator = [NSMutableArray arrayWithCapacity:10];
    

    int i;
    for(i = 0; i < [sentence count]; i++)
    {
        
        if([[sentence objectAtIndex:i] explain] == TC_AND
           || [[sentence objectAtIndex:i] explain] == TC_OR)
        {
            if([function_express count] == 0)
            {
                 _message = [NSMutableString stringWithString:@"logical format error"];
                return nil;
            }
            [fc_array addObject: function_express];
            function_express = [NSMutableArray arrayWithCapacity:10];
            [operator addObject:[sentence objectAtIndex:i]];
        }
        else
            [function_express addObject: [sentence objectAtIndex:i]];
    }
    if([function_express count] == 0)
    {
         _message = [NSMutableString stringWithString:@"logical format error"];
        return nil;
    }
    [fc_array addObject: function_express];
    
    if([fc_array count] - 1 != [operator count])
    {
        _message = [NSMutableString stringWithString:@"logical format error"];
        return nil; //grammer error
    }
    
    if([fc_array count] == 1) // no logical
    {
        TC_Logical_Layer* newlayer = [TC_Logical_Layer alloc];
        newlayer.type = 0;
        newlayer.straight = [self genFun: function_express];
        if(newlayer.straight == nil)
        {
            return nil;
        }
        newlayer.left = nil;
        newlayer.right = nil;
        return newlayer;
    }
    
    TC_Logical_Layer* old = [TC_Logical_Layer alloc];
    old.straight = [self genFun:[fc_array objectAtIndex:0]];
    if(old.straight == nil)
    {
        return nil;
    }
    old.left = nil;
    old.right = nil;
    old.type = 0;
    
    for(i = 0;i < [operator count]; i ++)
    {
        int state = [[operator objectAtIndex:i] explain];
        if(state == TC_AND)
        {
            TC_Logical_Layer* newleaf = [TC_Logical_Layer alloc];
            TC_Logical_Layer* newroot = [TC_Logical_Layer alloc];
            newleaf.straight = [self genFun:[fc_array objectAtIndex:i + 1]];
            newleaf.type = 0;
            newleaf.left = nil;
            newleaf.right  = nil;
            newroot.right = newleaf;
            newroot.left = old;
            newroot.type = TC_AND;
            newroot.straight = nil;
            old = newroot;
        }
        else if(state == TC_OR)
        {
            [stack addObject:old];
            old = [TC_Logical_Layer alloc];
            old.straight = [self genFun:[fc_array objectAtIndex:i + 1]];
            if(old.straight == nil)
            {
                return nil;
            }
            old.left = nil;
            old.right = nil;
            old.type = 0;
        }
    }
    
    [stack addObject:old];
    
    //reorder stack
    NSMutableArray* temp = [NSMutableArray arrayWithCapacity:10];
    while([stack count] > 0)
    {
        [temp addObject:[stack lastObject]];
        [stack removeLastObject];
    }
    stack = temp;
    
    //if no or only and
    if([stack count] == 1)
    {
        old = [stack objectAtIndex:0];
        return old;
    }
    // popstack and get tree
    old = [TC_Logical_Layer alloc];
    old.straight = nil;
    old.right = [stack objectAtIndex:[stack count] - 1];
    old.left = [stack objectAtIndex:[stack count] - 2];
    old.type = TC_OR;
    [stack removeLastObject];
    [stack removeLastObject];
    while([stack count] > 0)
    {
        TC_Logical_Layer* newroot = [TC_Logical_Layer alloc];
        newroot.right = old;
        newroot.left = [stack lastObject];
        newroot.type = TC_OR;
        newroot.straight = nil;
        old = newroot;
        [stack removeLastObject];
    }
    return old;
}

- (NSMutableArray*) genWords: (NSMutableArray*) sentence
{
    if([sentence count] == 0)
    {
        return nil;
    }
    int i = 0;
    int state;
    BOOL stick = NO;
    
    BOOL has_one = NO;
    TC_WORD_LAYER* newlayer;
    TC_WORD_LAYER* rootlayer;
    NSMutableArray* result = [NSMutableArray arrayWithCapacity:10];
    
    while(true)
    {
        state = [[sentence objectAtIndex:i] explain];
        if(state == TC_MY)
        {
            if(i >= [sentence count] - 1)
            {
                _message = [NSMutableString stringWithString:@"owner can not apear an the end"];
                return nil; //gramma error my is not the last
            }
            rootlayer = [TC_WORD_LAYER alloc];
            rootlayer.word = [[sentence objectAtIndex:i] word];
            newlayer = [TC_WORD_LAYER alloc];
            newlayer.word = [[sentence objectAtIndex:i + 1] word];
            newlayer.next_layer = nil;
            rootlayer.next_layer = newlayer;
            [result addObject:rootlayer];
            i ++;
        }
        else if(state == TC_OF)
        {
            if(i == 0 || i >= [sentence count] - 1)
            {
                _message = [NSMutableString stringWithString:@"of can not be at end or bigin"];
                return nil; //gramma error of is not the first or the last
            }
            if(stick == NO) // if it is the first of genarate root
            {
                rootlayer = [TC_WORD_LAYER alloc];
                rootlayer.word = [[sentence objectAtIndex:i + 1] word];
                newlayer = [TC_WORD_LAYER alloc];
                newlayer.word = [[sentence objectAtIndex:i - 1] word];
                newlayer.next_layer = nil;
                rootlayer.next_layer = newlayer;
                stick = YES;
            }
            else if(stick == YES)
            {
                if([[sentence objectAtIndex:i - 1] explain] == TC_OF)
                {
                    _message = [NSMutableString stringWithString:@"of can not be put together"];
                    return nil;
                }
                newlayer = rootlayer;
                rootlayer = [TC_WORD_LAYER alloc];
                rootlayer.word = [[sentence objectAtIndex:i + 1] word];
                rootlayer.next_layer = newlayer;
            }
        }
        else
        {
            if(stick == YES)
            {
                if(has_one == NO)
                {
                    has_one = YES;
                    [result addObject:rootlayer];
                    i++;
                    if(i >= [sentence count])
                    {
                        break;
                    }
                    continue;
                }
                else if(has_one == YES)
                {
                    has_one = NO;
                    stick = NO;
                    [result addObject:rootlayer];
                    i++;
                    if(i >= [sentence count])
                    {
                        break;
                    }
                    continue;
                    
                }
            }
           else if(stick == NO)
           {
               int state;
               if(i < [sentence count] - 1)
               {
                   state = [[sentence objectAtIndex:i+1] explain];
                   if(state == TC_OF)
                   {
                       i ++;
                       if(i >= [sentence count])
                       {
                           break;
                       }
                       continue;
                   }
               }
               if(i > 0)
               {
                   state = [[sentence objectAtIndex:i-1] explain];
                   if(state == TC_MY)
                   {
                       i ++;
                       if(i >= [sentence count])
                       {
                           break;
                       }
                       continue;
                   }
               }
               rootlayer = [TC_WORD_LAYER alloc];
               rootlayer.word = [[sentence objectAtIndex:i] word];
               rootlayer.next_layer = nil;
               [result addObject:rootlayer];
           }
        }
        
        i++;
        if(i >= [sentence count])
        {
            break;
        }
    }
    return result;
}

- (TC_Function_Layer*) genFun: (NSMutableArray*) sentence
{
    if([sentence count] == 0)
    {
        return nil;
    }
    int i,j;
    NSMutableArray* temp;
    TC_Function_Layer* result = [TC_Function_Layer alloc];
    for(i = 0; i < [sentence count]; i ++)
    {
        int state = [[sentence objectAtIndex:i] explain];
        int match = [[sentence objectAtIndex:i] right_match];
        if(state == TC_FUNCTION)
        {
            result.name = [[sentence objectAtIndex:i] word];
            result.right_match = match;
            break;
        }
    }
    temp = [NSMutableArray arrayWithCapacity:10];
    for(j = 0; j <= i - 1; j ++)
    {
        [temp addObject:[sentence objectAtIndex:j]];
    }
    if([temp count] == 0)
    {
        TC_Define* e;
        e = [TC_Define alloc];
        e.word = @"I";
        e.explain = TC_VAR;
        e.right_match = 0;
        [temp addObject:e];
    }
    result.target = [[self genWords: temp] objectAtIndex:0];
    [temp removeAllObjects];
    
    for(j = i + 1; j < [sentence count]; j ++)
    {
        [temp addObject:[sentence objectAtIndex:j]];
    }
    
    result.params = [self genWords: temp];
    
    if(result.right_match == [result.params count])
        return result;
    else
    {
        _message = [NSMutableString stringWithString: @"parameters do not match"];
        return nil;
    }
}

- (int) genInstruction
{
    //store the end offset
    NSMutableArray* stack = [NSMutableArray arrayWithCapacity:10];
   
    //check gramma. if first must be if while, last must be end, if while must be eual to end
    int i;
    int end_count = 0;
    int while_count = 0;
    
    for(i = 0; i < [_root count]; i ++)
    {
        int type = ((TC_Conrol_Layer*)[_root objectAtIndex:i]).type;
        if(type == TC_END)
        {
            end_count++;
        }
        else if(type == TC_WHILE || type == TC_IF)
        {
            while_count++;
        }
        if(i == 0)
        {
            if([_root count] > 1 && type == -1)
            {
                _message = [NSMutableString stringWithString: @"false branch control statement, more than one straight function"];
                return -1;
            }
            else if([_root count] == 1 && type != -1)
            {
                _message = [NSMutableString stringWithString: @"false branch control statement, no end state ment"];
                return -1;
            }
        }
        else if(i == 0)
        {
            if(type != TC_WHILE||type != TC_IF||type != -1)
            {
                _message = [NSMutableString stringWithString: @"false branch control statement, first word must be if or while"];
                return -1;
            }
        }
        else if([_root count] > 1 && i == [_root count] - 1)
        {
             if(type != TC_END)
             {
                 _message = [NSMutableString stringWithString: @"false branch control statement: last word must be end"];
                 return -1;
             }
        }
    }
    if(while_count != end_count)
    {
        _message = [NSMutableString stringWithString: @"false branch control statement: end mismatches"];
        return -1;
    }
    
    //read the _root and gen instructions
    if([_root count] == 1) //exactly one function
    {
        if([[_root objectAtIndex:0] logical] != nil)
            [self genLogicalInstructionsWith: [[_root objectAtIndex:0] logical] At: _current_ins_count To: _instruction_table];
    }
    //begin iterator
    for(i = 0; i < [_root count]; i ++)
    {
        int type = ((TC_Conrol_Layer*)[_root objectAtIndex:i]).type;
        if(type == TC_IF)
        {
            // calculate true or false
            [self genLogicalInstructionsWith: [[_root objectAtIndex:i] logical] At: _current_ins_count To: _instruction_table];
            
            // jump to the end if false
            TC_Instruction* A;
            TC_INS_OFFSET* offset;
            offset = [TC_INS_OFFSET alloc];
            offset.offset = 0;
            offset.solved = NO;
            offset.mark = MARK_IF_END;
            offset.extra = 0;
            
            A = [TC_Instruction alloc];
            A.instruct = ins_jmp_false;
            A.params = nil;
            A.src = offset;
            A.des = nil;
            [_instruction_table addObject:A];
            _current_ins_count ++;
            [stack addObject:offset];
        }
        else if(type == TC_RETURN)
        {
            TC_Instruction* A;
            A = [TC_Instruction alloc];
            A.instruct = ins_rtn;
            A.params = nil;
            A.src = nil;
            A.des = nil;
            [_instruction_table addObject:A];
            _current_ins_count ++;
        }
        else if(type == TC_BREAK)
        {
            if([stack count] == 0)
            {
                _message = [NSMutableString stringWithString: @"break is not in loop or if statement"];
                return -1;
            }
            else
            {
                int index;
                TC_Instruction* A;
                A = [TC_Instruction alloc];
                A.instruct = ins_jmp;
                A.params = nil;
                A.src = nil;
                for(index = [stack count] - 1;index >= 0; index--)
                {
                    if([[stack objectAtIndex:index]mark] == MARK_WHILE_END)
                    {
                        A.src = [stack objectAtIndex:index];
                    }
                }
                if(A.src == nil)
                {
                    _message = [NSMutableString stringWithString: @"break is not in loop or if statement"];
                    return -1;
                }
                A.des = nil;
                [_instruction_table addObject:A];
                _current_ins_count ++;
            }
        }
        else if(type == TC_WHILE)
        {
            int head = _current_ins_count;
            // calculate true or false
            [self genLogicalInstructionsWith: [[_root objectAtIndex:i] logical] At: _current_ins_count To: _instruction_table];
            
            // jump to the end if false
            TC_Instruction* A;
            TC_INS_OFFSET* offset;
            offset = [TC_INS_OFFSET alloc];
            offset.offset = 0;
            offset.solved = NO;
            offset.mark = MARK_WHILE_END;
            offset.extra = head;
            
            A = [TC_Instruction alloc];
            A.instruct = ins_jmp_false;
            A.params = nil;
            A.src = offset;
            A.des = nil;
            [_instruction_table addObject:A];
            _current_ins_count ++;
            [stack addObject:offset];
        }
        else if(type == TC_END)
        {
            TC_INS_OFFSET* last_match = [stack lastObject];
            [stack removeLastObject];
            if(last_match.mark == MARK_IF_END)
            {
                last_match.mark = MARK_LOGICAL_SOLVED;
                last_match.offset = _current_ins_count;
                last_match.solved = YES;
            }
            else if(last_match.mark == MARK_WHILE_END)
            {
                TC_INS_OFFSET* offset;
                offset = [TC_INS_OFFSET alloc];
                offset.offset = last_match.extra;
                offset.solved = YES;
                offset.mark = MARK_LOGICAL_SOLVED;
                offset.extra = 0;
                
                TC_Instruction* A = [TC_Instruction alloc];
                A.instruct = ins_jmp;
                A.params = nil;
                A.src = offset;
                A.des = nil;
                [_instruction_table addObject:A];
                _current_ins_count ++;
                
                last_match.mark = MARK_LOGICAL_SOLVED;
                last_match.offset = _current_ins_count;
                last_match.solved = YES;
            }
        }
        else if(type == TC_THEN)
        {
            [self genLogicalInstructionsWith: [[_root objectAtIndex:i] logical] At: _current_ins_count To: _instruction_table];
        }
    }
    return 0;
}

//line is the offset of the first instruction
-(void) genLogicalInstructionsWith:(TC_Logical_Layer* )l At:(int)line To:(NSMutableArray*) table
{
    if(l.straight != nil)
    {
        TC_Instruction* A;
        A = [TC_Instruction alloc];
        A.instruct = ins_call;
        A.params = [self replace_word_layer: l.straight];
        A.src = l.straight.name;
        A.des = [self searchFunction:l.straight];
        [table addObject:A];
        _current_ins_count ++;
        return;
    }
    else if(l.right.straight != nil && l.left.straight != nil)
    {
        if(l.type == TC_OR)
        {
            TC_Instruction* A;
            A = [TC_Instruction alloc];
            A.instruct = ins_call;
            A.params = [self replace_word_layer: l.right.straight];
            A.src = l.right.straight.name;
            A.des = [self searchFunction:l.right.straight];
            TC_Instruction* B;
            B = [TC_Instruction alloc];
            B.instruct = ins_call;
            B.params = [self replace_word_layer: l.right.straight];
            B.src = l.right.straight.name;
            B.des = [self searchFunction:l.right.straight];
            [table addObject:A];
            [table addObject:B];
            _current_ins_count += 2;
        }
        else if(l.type == TC_AND)
        {
            TC_Instruction* A;
            A = [TC_Instruction alloc];
            A.instruct = ins_call;
            A.params = [self replace_word_layer: l.right.straight];
            A.src = l.right.straight.name;
            A.des = [self searchFunction:l.right.straight];
            
            TC_Instruction* B;
            B = [TC_Instruction alloc];
            B.instruct = ins_call;
            B.params = [self replace_word_layer: l.left.straight];
            B.src = l.left.straight.name;
            B.des = [self searchFunction:l.left.straight];
            
            TC_Instruction* C;
            C = [TC_Instruction alloc];
            C.instruct = ins_jmp_false;
            TC_INS_OFFSET* offset;
            offset = [TC_INS_OFFSET alloc];
            offset.offset = _current_ins_count + 3;
            offset.solved = YES;
            offset.mark = MARK_LOGICAL_SOLVED;
            C.src = offset;
            C.params = nil;
            C.des = nil;
            
            [table addObject:A];
            [table addObject:C];
            [table addObject:B];
            _current_ins_count += 3;
        }
        return;
    }
    else if(l.right && l.left && l.right.straight == nil && l.left.straight == nil)
    {
        [self genLogicalInstructionsWith:l.right At:_current_ins_count To:table];
        if(l.type == TC_AND)
        {
            TC_Instruction* C;
            C = [TC_Instruction alloc];
            C.instruct = ins_jmp_false;
            TC_INS_OFFSET* offset;
            offset = [TC_INS_OFFSET alloc];
            offset.offset = 0;
            offset.solved = NO;
            offset.mark = MARK_LOGICAL_END;
            offset.extra = 0;
            C.src = offset;
            C.params = nil;
            C.des = nil;
            
            [table addObject:C];
            _current_ins_count ++;
            [self genLogicalInstructionsWith:l.left At:_current_ins_count To:table];
            offset.offset = _current_ins_count;
            offset.solved = YES;
            offset.mark = MARK_LOGICAL_SOLVED;
            offset.extra = 0;
        }
        else if(l.type == TC_OR)
        {
            [self genLogicalInstructionsWith:l.left At:_current_ins_count To:
             table];
        }
        return;
    }
    else if(l.right.straight != nil)
    {
        [self genLogicalInstructionsWith:l.left At:_current_ins_count To:table];
        if(l.type == TC_AND)
        {
            TC_Instruction* C;
            C = [TC_Instruction alloc];
            C.instruct = ins_jmp_false;
            TC_INS_OFFSET* offset;
            offset = [TC_INS_OFFSET alloc];
            offset.offset = line + 2;
            offset.solved = YES;
            offset.mark = MARK_LOGICAL_SOLVED;
            C.src = offset;
            C.params = nil;
            C.des = nil;
            
            TC_Instruction* A;
            A = [TC_Instruction alloc];
            A.instruct = ins_call;
            A.params = [self replace_word_layer: l.right.straight];
            A.src = l.right.straight.name;
            A.des = [self searchFunction:l.right.straight];
            
            [table addObject:C];
            [table addObject:A];
            _current_ins_count += 2;
            return;
        }
        else if(l.type == TC_OR)
        {
            TC_Instruction* A;
            A = [TC_Instruction alloc];
            A.instruct = ins_call;
            A.params = [self replace_word_layer: l.right.straight];
            A.src = l.right.straight.name;
            A.des = [self searchFunction:l.right.straight];
            
            [table addObject:A];
            _current_ins_count += 1;
            return;
        }
    }
    
    else if(l.left.straight != nil)
    {
        [self genLogicalInstructionsWith:l.right At:_current_ins_count To:table];
        if(l.type == TC_AND)
        {
            TC_Instruction* C;
            C = [TC_Instruction alloc];
            C.instruct = ins_jmp_false;
            TC_INS_OFFSET* offset;
            offset = [TC_INS_OFFSET alloc];
            offset.offset = line + 2;
            offset.solved = YES;
            offset.mark = MARK_LOGICAL_SOLVED;
            C.src = offset;
            C.params = nil;
            C.des = nil;
            
            TC_Instruction* B;
            B = [TC_Instruction alloc];
            B.instruct = ins_call;
            B.params = [self replace_word_layer: l.left.straight];
            B.src = l.left.straight.name;
            B.des = [self searchFunction:l.left.straight];;
            
            [table addObject:C];
            [table addObject:B];
            _current_ins_count += 2;
            return;
        }
        else if(l.type == TC_OR)
        {
            TC_Instruction* B;
            B = [TC_Instruction alloc];
            B.instruct = ins_call;
            B.params = [self replace_word_layer: l.left.straight];
            B.src = l.left.straight.name;
            B.des = [self searchFunction:l.left.straight];
            
            [table addObject:B];
            _current_ins_count += 1;
            return;
        }
    }
}

- (NSMutableString*) debug
{
    int i;
    int offset;
    NSString* temp;
    NSMutableString* result;
    NSString* tw;
    result = [NSMutableString stringWithString:@""];
    
    for(i = 0; i < [_instruction_table count]; i++)
    {
        temp = [NSString stringWithFormat:@"%d",i];
        [result appendString:temp];
        
        switch([[_instruction_table objectAtIndex:i] instruct])
        {
            case ins_call:
                [result appendString:@" call"];
                [result appendString:@" "];
                [result appendString: [[_instruction_table objectAtIndex:i] src]];
                break;
            case ins_jmp:
                [result appendString:@" jmp"];
                [result appendString:@" "];
                offset = [[[_instruction_table objectAtIndex:i] src]offset];
                temp = [NSString stringWithFormat:@"%d",offset];
                [result appendString:temp];
                break;
            case ins_jmp_false:
                [result appendString:@" jmp_false"];
                [result appendString:@" "];
                offset = [[[_instruction_table objectAtIndex:i] src]offset];
                temp = [NSString stringWithFormat:@"%d",offset];
                [result appendString:temp];
                break;
            case ins_jmp_true:
                [result appendString:@" jmp_true"];
                [result appendString:@" "];
                offset = [[[_instruction_table objectAtIndex:i] src]offset];
                temp = [NSString stringWithFormat:@"%d",offset];
                [result appendString:temp];
                break;
            case ins_push:
                [result appendString:@" push"];
                [result appendString:@" "];
                
                tw = [[[[_instruction_table objectAtIndex:i] src]var] word];
                [result appendString:tw];
                break;
            case ins_rtn:
                [result appendString:@" rtn"];
                break;
        }
        
        [result appendString:@"\n"];
    }
    return result;
}

- (NSMutableArray*) readScript: (NSString*) file
{
    int result;
    int i;
    [self loadFile:file];
    while([self readLine] > 0)
    {
        result = [self read_a_tokens];
        if(result == 0)
        {
            [self clear_current];
            return nil;
        }
        for(i = [_defines count] - 1; i >= 0; i --)
        {
            int state = [[_defines objectAtIndex:i] explain];
            if(i != 0 && (state == TC_END_DEF || state == TC_DEFINE ||state == TC_PUSH))
            {
                _message = [NSMutableString stringWithString: @"define or enddef,push is inside the statement"];
                [self clear_current];
                return nil;
            }
        }
        result = [self genTree];
        if(result < 0)
        {
            [self clear_current];
            return nil;
        }
        if([_root count] == 0)
        {
            continue;
        }
        [self genInstruction];
        if([_message lengthOfBytesUsingEncoding:NSASCIIStringEncoding] > 0)
        {
            [self clear_current];
            return nil;
        }
    }
    return _instruction_table;
}

- (void) initDictionary
{
    TC_Define* temp = [TC_Define alloc];
    temp.word = @"if";
    temp.explain = TC_IF;
    temp.right_match = 0;
    [self.dictionary addObject: temp];
    
    temp = [TC_Define alloc];
    temp.word = @"is";
    temp.explain = TC_FUNCTION;
    temp.right_match = 1;
    [self.dictionary addObject: temp];
    
    temp = [TC_Define alloc];
    temp.word = @"are";
    temp.explain = TC_FUNCTION;
    temp.right_match = 1;
    [self.dictionary addObject: temp];
    
    temp = [TC_Define alloc];
    temp.word = @"equal";
    temp.explain = TC_FUNCTION;
    temp.right_match = 1;
    [self.dictionary addObject: temp];
    
    temp = [TC_Define alloc];
    temp.word = @"define";
    temp.explain = TC_DEFINE;
    temp.right_match = 2;
    [self.dictionary addObject: temp];
    
    temp = [TC_Define alloc];
    temp.word = @"enddef";
    temp.explain = TC_END_DEF;
    temp.right_match = 0;
    [self.dictionary addObject: temp];
    
    temp = [TC_Define alloc];
    temp.word = @"greater";
    temp.explain = TC_FUNCTION;
    temp.right_match = 1;
    [self.dictionary addObject: temp];
    
    temp = [TC_Define alloc];
    temp.word = @"smaller";
    temp.explain = TC_FUNCTION;
    temp.right_match = 1;
    [self.dictionary addObject: temp];
    
    temp = [TC_Define alloc];
    temp.word = @"set";
    temp.explain = TC_FUNCTION;
    temp.right_match = 1;
    [self.dictionary addObject: temp];
    
    temp = [TC_Define alloc];
    temp.word = @"my";
    temp.explain = TC_MY;
    temp.right_match = 0;
    [self.dictionary addObject: temp];
    
    
    temp = [TC_Define alloc];
    temp.word = @"end";
    temp.explain = TC_END;
    temp.right_match = 0;
    [self.dictionary addObject: temp];
    
    temp = [TC_Define alloc];
    temp.word = @"while";
    temp.explain = TC_WHILE;
    temp.right_match = 0;
    [self.dictionary addObject: temp];
    
    temp = [TC_Define alloc];
    temp.word = @"return";
    temp.explain = TC_RETURN;
    temp.right_match = 0;
    [self.dictionary addObject: temp];
    
    temp = [TC_Define alloc];
    temp.word = @",";
    temp.explain = TC_THEN;
    temp.right_match = 0;
    [self.dictionary addObject: temp];
    
    temp = [TC_Define alloc];
    temp.word = @"then";
    temp.explain = TC_THEN;
    temp.right_match = 0;
    [self.dictionary addObject: temp];
    
    temp = [TC_Define alloc];
    temp.word = @"break";
    temp.explain = TC_BREAK;
    temp.right_match = 0;
    [self.dictionary addObject: temp];
    
    temp = [TC_Define alloc];
    temp.word = @"on";
    temp.explain = TC_IGNORE;
    temp.right_match = 0;
    [self.dictionary addObject: temp];
    
    temp = [TC_Define alloc];
    temp.word = @"with";
    temp.explain = TC_IGNORE;
    temp.right_match = 0;
    [self.dictionary addObject: temp];
    
    temp = [TC_Define alloc];
    temp.word = @"at";
    temp.explain = TC_IGNORE;
    temp.right_match = 0;
    [self.dictionary addObject: temp];
    
    temp = [TC_Define alloc];
    temp.word = @"in";
    temp.explain = TC_IGNORE;
    temp.right_match = 0;
    [self.dictionary addObject: temp];
    
    temp = [TC_Define alloc];
    temp.word = @"on";
    temp.explain = TC_IGNORE;
    temp.right_match = 0;
    [self.dictionary addObject: temp];
    
    temp = [TC_Define alloc];
    temp.word = @"than";
    temp.explain = TC_IGNORE;
    temp.right_match = 0;
    [self.dictionary addObject: temp];
    
    temp = [TC_Define alloc];
    temp.word = @"gen";
    temp.explain = TC_PUSH;
    temp.right_match = 0;
    [self.dictionary addObject: temp];
    
    temp = [TC_Define alloc];
    temp.word = @"by";
    temp.explain = TC_MY;
    temp.right_match = 0;
    [self.dictionary addObject: temp];
    
    temp = [TC_Define alloc];
    temp.word = @"to";
    temp.explain = TC_MY;
    temp.right_match = 0;
    [self.dictionary addObject: temp];
    
    temp = [TC_Define alloc];
    temp.word = @"or";
    temp.explain = TC_OR;
    temp.right_match = 0;
    [self.dictionary addObject: temp];
    
    temp = [TC_Define alloc];
    temp.word = @"and";
    temp.explain = TC_AND;
    temp.right_match = 0;
    [self.dictionary addObject: temp];
    
    temp = [TC_Define alloc];
    temp.word = @"of";
    temp.explain = TC_OF;
    temp.right_match = 0;
    [self.dictionary addObject: temp];
    
    temp = [TC_Define alloc];
    temp.word = @"return";
    temp.explain = TC_FUNCTION;
    temp.right_match = 0;
    [self.dictionary addObject: temp];
    
    temp = [TC_Define alloc];
    temp.word = @"move";
    temp.explain = TC_FUNCTION;
    temp.right_match = 1;
    [self.dictionary addObject: temp];
    
    temp = [TC_Define alloc];
    temp.word = @"rotate";
    temp.explain = TC_FUNCTION;
    temp.right_match = 1;
    [self.dictionary addObject: temp];
    
    temp = [TC_Define alloc];
    temp.word = @"kill";
    temp.explain = TC_FUNCTION;
    temp.right_match = 1;
    [self.dictionary addObject: temp];
    
    temp = [TC_Define alloc];
    temp.word = @"hide";
    temp.explain = TC_FUNCTION;
    temp.right_match = 0;
    [self.dictionary addObject: temp];
    
    temp = [TC_Define alloc];
    temp.word = @"setSeq";
    temp.explain = TC_FUNCTION;
    temp.right_match = 1;
    [self.dictionary addObject: temp];
    
    temp = [TC_Define alloc];
    temp.word = @"search";
    temp.explain = TC_FUNCTION;
    temp.right_match = 1;
    [self.dictionary addObject: temp];
    
    temp = [TC_Define alloc];
    temp.word = @"say";
    temp.explain = TC_FUNCTION;
    temp.right_match = 1;
    [self.dictionary addObject: temp];
    
    temp = [TC_Define alloc];
    temp.word = @"creat";
    temp.explain = TC_FUNCTION;
    temp.right_match = 2;
    [self.dictionary addObject: temp];
    
    temp = [TC_Define alloc];
    temp.word = @"adopt";
    temp.explain = TC_FUNCTION;
    temp.right_match = 1;
    [self.dictionary addObject: temp];
    
    temp = [TC_Define alloc];
    temp.word = @"abandon";
    temp.explain = TC_FUNCTION;
    temp.right_match = 1;
    [self.dictionary addObject: temp];
    
    
    temp = [TC_Define alloc];
    temp.word = @"fun1";
    temp.explain = TC_FUNCTION;
    temp.right_match = 1;
    [self.dictionary addObject: temp];
    
    temp = [TC_Define alloc];
    temp.word = @"fun2";
    temp.explain = TC_FUNCTION;
    temp.right_match = 0;
    [self.dictionary addObject: temp];
}

- (TC_INS_FUNCTION*) searchFunction: (TC_Function_Layer*) fun
{
    int i;
    for(i = 0; i < [_func_table count]; i ++)
    {
        if(
           [[(TC_INS_FUNCTION*)[_func_table objectAtIndex:i] name] isEqualToString:[fun name]]
           )
        {
            return [_func_table objectAtIndex:i];
        }
    }
    _message = [NSMutableString stringWithString: @"can not find the symbol: "];
    [_message appendString:fun.name];
    return nil;
}

- (TC_INS_VARIABLE*) searchVariable: (TC_WORD_LAYER*) var
{
    int i;
    for(i = 0; i < [_var_stack count]; i++)
    {
        if([self cmp_word_layer: [[_var_stack objectAtIndex:i] var] With:var])
        {
            return [_var_stack objectAtIndex:i];
        }
    }
    return nil;
}

- (BOOL) cmp_word_layer: (TC_WORD_LAYER*)a With: (TC_WORD_LAYER*)b;
{
    TC_WORD_LAYER* itera = a;
    TC_WORD_LAYER* iterb = b;
    while(itera!=nil&&iterb!=nil)
    {
        if([itera.word isEqualToString:iterb.word])
        {
            itera = itera.next_layer;
            iterb = iterb.next_layer;
        }
        else
        {
            return NO;
        }
    }
    if(itera!=nil || iterb!=nil)
    {
        return NO;
    }
    return YES;
}

- (void)clear_current
{
    _defines = [NSMutableArray arrayWithCapacity:10];
    _root = [NSMutableArray arrayWithCapacity:10];;
    _instruction_table = [NSMutableArray arrayWithCapacity:10];
    _func_table = [NSMutableArray arrayWithCapacity:10];
    _var_table = [NSMutableArray arrayWithCapacity:10];
    _var_stack = [NSMutableArray arrayWithCapacity:10];
}

- (NSMutableArray*) replace_word_layer: (TC_Function_Layer*)f
{
    int i;
    NSMutableArray* result = [NSMutableArray arrayWithCapacity:10];
    NSMutableArray* params = [NSMutableArray arrayWithCapacity:10];
    if(f.target != nil)
        [params addObject: f.target];
    else
    {
        TC_WORD_LAYER* me;
        me = [TC_WORD_LAYER alloc];
        me.word = @"I";
        me.type = 0;
        me.next_layer = nil;
        [params addObject: me];
    }
    
    for(i = 0;i < [f.params count];i ++)
    {
        [params addObject: [f.params objectAtIndex:i]];
    }
    
    TC_INS_VARIABLE* temp;
    
    for(i = 0;i < [params count];i ++)
    {
        if([[[params objectAtIndex:i] word] isEqualToString:@"I"])
        {
            temp = [TC_INS_VARIABLE alloc];
            temp.solved = YES;
            temp.argoffset = 0;
            temp.addr = nil;
            temp.obj = nil;
            temp.type = VAR_UNKNOWN;
            temp.borrow = NO;
            temp.location = VAR_SELF;
            temp.var = [params objectAtIndex:i];
            [result addObject:temp];
            continue;
        }
        
        temp = [self searchVariable: [params objectAtIndex:i]];
        
        if(temp == nil)
        {
            temp = [TC_INS_VARIABLE alloc];
            temp.solved = NO;
            temp.argoffset = 0;
            temp.addr = nil;
            temp.obj = nil;
            temp.type = VAR_UNKNOWN;
            temp.borrow = NO;
            temp.location = VAR_STACK;
            temp.var = [params objectAtIndex:i];
            [result addObject:temp];
        }
        else
        {
            [result addObject:temp];
        }
    }
    return result;
}

- (void) initFunction
{
   
    TC_INS_FUNCTION* fun;
    
    fun = [TC_INS_FUNCTION alloc];
    fun.solved = NO;
    fun.name = @"is";
    fun.func = nil;
    fun.offset = 0;
    fun.location = FUN_BIND;
    fun.right_match = 1;
    [_func_table addObject:fun];
    
    fun = [TC_INS_FUNCTION alloc];
    fun.solved = NO;
    fun.name = @"are";
    fun.func = nil;
    fun.offset = 0;
    fun.location = FUN_BIND;
    fun.right_match = 1;
    [_func_table addObject:fun];
    
    fun = [TC_INS_FUNCTION alloc];
    fun.solved = NO;
    fun.name = @"greater";
    fun.func = nil;
    fun.offset = 0;
    fun.location = FUN_BIND;
    fun.right_match = 1;
    [_func_table addObject:fun];
    
    
    fun = [TC_INS_FUNCTION alloc];
    fun.solved = NO;
    fun.name = @"smaller";
    fun.func = nil;
    fun.offset = 0;
    fun.location = FUN_BIND;
    fun.right_match = 1;
    [_func_table addObject:fun];
    
    fun = [TC_INS_FUNCTION alloc];
    fun.solved = NO;
    fun.name = @"equal";
    fun.func = nil;
    fun.offset = 0;
    fun.location = FUN_BIND;
    fun.right_match = 1;
    [_func_table addObject:fun];
    
    fun = [TC_INS_FUNCTION alloc];
    fun.solved = NO;
    fun.name = @"set";
    fun.func = nil;
    fun.offset = 0;
    fun.location = FUN_BIND;
    fun.right_match = 1;
    [_func_table addObject:fun];
    
    fun = [TC_INS_FUNCTION alloc];
    fun.solved = NO;
    fun.name = @"kill";
    fun.func = nil;
    fun.offset = 0;
    fun.location = FUN_BIND;
    fun.right_match = 1;
    [_func_table addObject:fun];
    
    fun = [TC_INS_FUNCTION alloc];
    fun.solved = NO;
    fun.name = @"adopt";
    fun.func = nil;
    fun.offset = 0;
    fun.location = FUN_BIND;
    fun.right_match = 1;
    [_func_table addObject:fun];
    
    fun = [TC_INS_FUNCTION alloc];
    fun.solved = NO;
    fun.name = @"abandon";
    fun.func = nil;
    fun.offset = 0;
    fun.location = FUN_BIND;
    fun.right_match = 1;
    [_func_table addObject:fun];
    
    fun = [TC_INS_FUNCTION alloc];
    fun.solved = NO;
    fun.name = @"hide";
    fun.func = nil;
    fun.offset = 0;
    fun.location = FUN_BIND;
    fun.right_match = 0;
    [_func_table addObject:fun];
    
    fun = [TC_INS_FUNCTION alloc];
    fun.solved = NO;
    fun.name = @"search";
    fun.func = nil;
    fun.offset = 0;
    fun.location = FUN_BIND;
    fun.right_match = 1;
    [_func_table addObject:fun];
    
    fun = [TC_INS_FUNCTION alloc];
    fun.solved = NO;
    fun.name = @"move";
    fun.func = nil;
    fun.offset = 0;
    fun.location = FUN_BIND;
    fun.right_match = 1;
    [_func_table addObject:fun];
    
    fun = [TC_INS_FUNCTION alloc];
    fun.solved = NO;
    fun.name = @"setSeq";
    fun.func = nil;
    fun.offset = 0;
    fun.location = FUN_BIND;
    fun.right_match = 1;
    [_func_table addObject:fun];
    
    fun = [TC_INS_FUNCTION alloc];
    fun.solved = NO;
    fun.name = @"rotate";
    fun.func = nil;
    fun.offset = 0;
    fun.location = FUN_BIND;
    fun.right_match = 1;
    [_func_table addObject:fun];
    
    fun = [TC_INS_FUNCTION alloc];
    fun.solved = NO;
    fun.name = @"creat";
    fun.func = nil;
    fun.offset = 0;
    fun.location = FUN_BIND;
    fun.right_match = 2;
    [_func_table addObject:fun];
    
    fun = [TC_INS_FUNCTION alloc];
    fun.solved = NO;
    fun.name = @"say";
    fun.func = nil;
    fun.offset = 0;
    fun.location = FUN_BIND;
    fun.right_match = 1;
    [_func_table addObject:fun];
    
    
    fun = [TC_INS_FUNCTION alloc];
    fun.solved = NO;
    fun.name = @"fun1";
    fun.func = nil;
    fun.offset = 0;
    fun.location = FUN_DEFINE;
    fun.right_match = 1;
    [_func_table addObject:fun];
    
    
    fun = [TC_INS_FUNCTION alloc];
    fun.solved = NO;
    fun.name = @"fun2";
    fun.func = nil;
    fun.offset = 0;
    fun.location = FUN_DEFINE;
    fun.right_match = 0;
    [_func_table addObject:fun];
}
@end
