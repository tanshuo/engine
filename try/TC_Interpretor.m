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
@synthesize vm = _vm;
@synthesize defines = _defines;
@synthesize input = _input;
@synthesize message = _message;

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
    NSMutableString* linecache = [NSMutableString stringWithCapacity:10];//error
    char buff[2];
    _currentLine++;
    while(true)
    {
        c = getc(_input);
        if(c != EOF && c != ';')
        {
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
    int type;
    for(i = 0;i < [_defines count];i ++)//gen logical layer
    {
        type = [[_defines objectAtIndex:i] explain];
        if(type ==  TC_IF || type ==  TC_AFTER || type ==  TC_WHILE || type == TC_THEN || type == TC_END)
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
                if(type ==  TC_IF || type ==  TC_AFTER || type ==  TC_WHILE || type == TC_THEN || type == TC_END)
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
            if(stick == YES)
            {
                stick = NO;
                //wordbuff[j] = 0;
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
    return nil;
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
                }
                else if(has_one == YES)
                {
                    has_one = NO;
                    stick = NO;
                    [result addObject:rootlayer];
                }
            }
           else
           {
               int state;
               if(i < [sentence count] - 1)
               {
                   if(i == 0)
                   {
                       i ++;
                       continue;
                   }
                   state = [[sentence objectAtIndex:i+1] explain];
                   if(state == TC_OF)
                   {
                       _message = [NSMutableString stringWithString: @"possession discrimination is false around"];
                       [_message appendString: [[sentence objectAtIndex:i] word]];
                       return nil;// gramma error
                   }
               }
               if(i > 0)
               {
                   state = [[sentence objectAtIndex:i-1] explain];
                   if(state == TC_MY)
                   {
                       _message = [NSMutableString stringWithString: @"possession discrimination is false around"];
                       [_message appendString: [[sentence objectAtIndex:i] word]];
                       return nil;// gramma error
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
    result.target = [[self genWords: temp] objectAtIndex:0];
    
    temp = [NSMutableArray arrayWithCapacity:10];
    for(j = i + 1; j <= [sentence count] - 1; j ++)
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
    int count = 0;
    int head = _current_ins_count + 1;
    int control_end = 0;
    int logic_end = 0; // unknown
    
    
    
    
    _current_ins_count += count;
    return 0;
}

//line is the offset of the first instruction
-(void) genLogicalInstructionsWith:(TC_Logical_Layer* )l At:(int)line To:(NSMutableArray*) table
{
    if(l.right.straight != nil && l.left.straight != nil)
    {
        if(l.type == TC_OR)
        {
            TC_Instruction* A;
            A = [TC_Instruction alloc];
            A.instruct = @"call";
            A.params = l.right.straight.params;
            A.src = l.right.straight.name;
            A.des = nil;
            TC_Instruction* B;
            B = [TC_Instruction alloc];
            B.instruct = @"call";
            B.params = l.right.straight.params;
            B.src = l.right.straight.name;
            B.des = nil;
            [table addObject:A];
            [table addObject:B];
            _current_ins_count += 2;
        }
        else if(l.type == TC_AND)
        {
            TC_Instruction* A;
            A = [TC_Instruction alloc];
            A.instruct = @"call";
            A.params = l.right.straight.params;
            A.src = l.right.straight.name;
            A.des = nil;
            
            TC_Instruction* B;
            B = [TC_Instruction alloc];
            B.instruct = @"call";
            B.params = l.left.straight.params;
            B.src = l.left.straight.name;
            B.des = nil;
            
            TC_Instruction* C;
            C = [TC_Instruction alloc];
            C.instruct = @"jmp_flase";
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
    
    else if(l.right.straight != nil)
    {
        [self genLogicalInstructionsWith:l.left At:_current_ins_count To:table];
        if(l.type == TC_AND)
        {
            TC_Instruction* C;
            C = [TC_Instruction alloc];
            C.instruct = @"jmp_flase";
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
            A.instruct = @"call";
            A.params = l.right.straight.params;
            A.src = l.right.straight.name;
            A.des = nil;
            
            [table addObject:C];
            [table addObject:A];
            _current_ins_count += 2;
            return;
        }
        else if(l.type == TC_OR)
        {
            TC_Instruction* A;
            A = [TC_Instruction alloc];
            A.instruct = @"call";
            A.params = l.right.straight.params;
            A.src = l.right.straight.name;
            A.des = nil;
            
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
            C.instruct = @"jmp_flase";
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
            B.instruct = @"call";
            B.params = l.left.straight.params;
            B.src = l.left.straight.name;
            B.des = nil;
            
            [table addObject:C];
            [table addObject:B];
            _current_ins_count += 2;
            return;
        }
        else if(l.type == TC_OR)
        {
            TC_Instruction* B;
            B = [TC_Instruction alloc];
            B.instruct = @"call";
            B.params = l.left.straight.params;
            B.src = l.left.straight.name;
            B.des = nil;
            
            [table addObject:B];
            _current_ins_count += 1;
            return;
        }
    }
}

@end
