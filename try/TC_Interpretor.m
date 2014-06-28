//
//  TC_Interpretor.m
//  try
//
//  Created by tanshuo on 6/27/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//

#import "TC_Interpretor.h"

@implementation TC_Interpretor
@synthesize currentLine = _currentLine;
@synthesize line = _line;
@synthesize vm = _vm;
@synthesize defines = _defines;
@synthesize input = _input;

- (int) readLine
{
    return 0;
}
- (int) genTree
{
    return 0;
}
- (void)start
{
    _defines = [NSMutableArray arrayWithCapacity:10];
    _dictionary = [NSMutableArray arrayWithCapacity:10];
}

- (int) read_a_tokens
{
    char wordbuff[20];
    char c;
    int i = 0;
    int j = 0;
    BOOL flag = NO;
    [_defines removeAllObjects];
    
    while(true)
    {
        c = [_line characterAtIndex:i];
        if(flag && (c == EOF || c == ' ' || c == '\n' || c == '\t'))
        {
            wordbuff[j] = 0;
            TC_Define* token = [self searchDictionary:[NSString stringWithUTF8String:wordbuff]];
            if(token)
                [_defines addObject:token];
           
        }
        else if(!(c == EOF || c == ' ' || c == '\n' || c == '\t'))
        {
            flag = YES;
            wordbuff[j] = c;
            if(j < 18)
                j ++;
        }
        i ++;
    }
    return 0;
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
@end
