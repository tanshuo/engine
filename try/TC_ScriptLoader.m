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
    result = [self lookscript: name];
    if(result == nil)
    {
        result = [TC_VirtualMachine initVM:name];
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
