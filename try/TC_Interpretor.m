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

- (int) readLine
{
    char c;
    int index = 0;
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
            if(index < 99)
                index ++;
            else
                return 0;
        }
        else  if(c == EOF)
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
                type = [[_defines objectAtIndex:i] explain];
                if(type ==  TC_IF || type ==  TC_AFTER || type ==  TC_WHILE || type == TC_THEN || type == TC_END)
                {
                    i = j;
                    break;
                }
                else
                {
                    [newlayer.logical addObject:[_defines objectAtIndex:i]];
                }
            }
        
            [_root addObject:newlayer];
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
        [_root addObject:newlayer];
    }
    //////
    //missing logical layer
   /* int index;
    for(i = 0; i < [_root count]; i ++) //create function layer
    {
        TC_Function_Layer* temp = [TC_Function_Layer alloc];
        for(j = 0; j < [[_root objectAtIndex:i] count]; j ++)
        {
            int e = [[[_root objectAtIndex:i] objectAtIndex:j] explain];
            if(e == TC_FUNCTION)
            {
                for(index = 0; index < j; index ++)
                {
                    [[temp inputs] addObject:[[_root objectAtIndex:i] objectAtIndex:j]];
                }
                for(index = j + 1; index < [[_root objectAtIndex:i] count]; index ++)
                {
                    if([[[_root objectAtIndex:i] objectAtIndex:j] explain] != TC_IGNORE)
                        [[temp params] addObject:[[_root objectAtIndex:i] objectAtIndex:j]];
                }
                [_root setObject:temp atIndexedSubscript:i];
                break;
            }
        }
    }
    */
    
    return 0;
}
- (void)start
{
    _defines = [NSMutableArray arrayWithCapacity:10];
    _dictionary = [NSMutableArray arrayWithCapacity:10];
    _root = [NSMutableArray arrayWithCapacity:10];
}

- (int) read_a_tokens
{
    char wordbuff[80];
    char c;
    int i = 0;
    int j = 0;
    BOOL flag = NO;
    BOOL stick = NO;
    [_defines removeAllObjects];
    
    while(true)
    {
        if(i >= [_defines count])
        {
            return 0;
        }
        
        c = [_line characterAtIndex:i];
        if(stick == NO && (c == ',' || c == ';'||c == '.'))
        {
            wordbuff[j] = 0;
            TC_Define* token = [self searchDictionary:[NSString stringWithUTF8String:wordbuff]];
            if(token)
            {
                [_defines addObject:token];
                wordbuff[0] = c;
                wordbuff[1] = 0;
                token = [self searchDictionary:[NSString stringWithUTF8String:wordbuff]];
                [_defines addObject:token];
                return 2;
            }
            else
                return 0;
        }
        else if(c == '<')
        {
            if(stick == NO)
            {
                stick = YES;
            }
            else
                return 0;
        }
        else if(c == '>')
        {
            if(stick == YES)
            {
                stick = NO;
            }
            else
                return 0;
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
            if(token)
            {
                [_defines addObject:token];
                return 1;
            }
            else
            {
                flag = YES;
                wordbuff[j] = c;
                if(j < 79)
                    j ++;
                else
                    return -1;
            }
            
        }
        else if(!(c == EOF || c == ' ' || c == '\n' || c == '\t'))
        {
            flag = YES;
            wordbuff[j] = c;
            if(j < 79)
                j ++;
            else
                return -1;
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
        [function_express addObject: [sentence objectAtIndex:i]];
        if([[sentence objectAtIndex:i] explain] == TC_AND
           || [[sentence objectAtIndex:i] explain] == TC_OR)
        {
            [fc_array addObject: function_express];
            function_express = [NSMutableArray arrayWithCapacity:10];
            [operator addObject:[sentence objectAtIndex:i]];
        }
    }
    [fc_array addObject: function_express];
    
    if([fc_array count] - 1 != [operator count])
    {
        return nil; //grammer error
    }
    
    if([fc_array count] == 1) // no logical
    {
        TC_Logical_Layer* newlayer = [TC_Logical_Layer alloc];
        newlayer.type = 0;
        newlayer.straight = [self genFun: function_express];
        newlayer.left = nil;
        newlayer.right = nil;
        return newlayer;
    }
    
    TC_Logical_Layer* old = [TC_Logical_Layer alloc];
    old.straight = [self genFun:[fc_array objectAtIndex:0]];
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
            old.left = nil;
            old.right = nil;
            old.type = 0;
        }
        
        // popstack and get tree
        old = [TC_Logical_Layer alloc];
        old.straight = nil;
        old.right = [stack objectAtIndex:[stack count] - 1];
        old.left = nil;
        old.type = TC_OR;
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
        
    }
    return old;
}

- (TC_WORD_LAYER*) genWord: (NSMutableArray*) sentence
{
    return nil;
}

- (TC_Function_Layer*) genFun: (NSMutableArray*) sentence
{
    int i,j;
    for(i = 0; i < [sentence count]; i ++)
    {
        int state = [[sentence objectAtIndex:i] explain];
        int match = [[sentence objectAtIndex:i] right_match];
        if(state == TC_FUNCTION)
        {
            
        }
    }
}
@end
