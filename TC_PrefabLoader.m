//
//  prefabLoader.m
//  try
//
//  Created by tanshuo on 6/25/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//
/*
 #name:
 <sample>
 #position:
 <10.0>
 <10.0>
 <-90.0>
 #end
 #script
 <?>
 #end
 #shader:
 <Shader>
 #end
 #frame:
 <test> %first
 <test> %second
 #end
 #group:
 <0>
 #end
 */
#import "TC_PrefabLoader.h"

int prefab_cmd(FILE* input)
{
    PRE_CMD cmd= 0;
    char c;
    char s[50];
    int index = 0;
    c = getc(input);
    if(c == '<')
        return SUB_BEGIN;
    else if(c == '>')
        return SUB_END;
    else if(c == '?')
        return UNKNOWN;
    else if(c == '#')
    {
        c = 0;
        while(true)
        {
            if(c!=' '&&c!='\n'&&c!=EOF)
            {
                s[index] = c;
                index++;
                if(index >= 50)
                {
                    return EOF;
                }
            }
            else
            {
                s[index] = 0;
                if(!strcmp("name", s))
                {
                    return NAME;
                }
                if(!strcmp("shader", s))
                {
                    return SHADER;
                }
                if(!strcmp("script", s))
                {
                    return SCRIPT;
                }
                if(!strcmp("frame", s))
                {
                    return FRAME;
                }
                if(!strcmp("group", s))
                {
                    return GROUP;
                }
                return 0;
            }
        }
    }
    else if(c == EOF)
    {
        return EOF;
    }
    return cmd;
}

int readData(char* buff,FILE* input)
{
    char c;
    int index = 0;
    while(true)
    {
        c = getc(input);
        if(c == EOF || c == '>' || c == ' '||c == '\n')
        {
            buff[index] = 0;
            return 0;
        }
        buff[index] = c;
        index++;
        if(index == 50)
        {
            return EOF;
        }
    }
}

@implementation TC_PrefabLoader
+ (TC_PrefabInfo*)loadPrefab: (NSString*)prefab WithName:(NSString*) name
{
    TC_PrefabInfo* result = nil;
    FILE* input = nil;
    int state = 0;
    int flag = 0;
    int cmp = 0;
    char buffer[50];
    input = fopen([prefab cStringUsingEncoding:NSASCIIStringEncoding], "r");
    if(input == NULL)
    {
        return nil;
    }
    result = [TC_PrefabInfo alloc];
    result.name = nil;
   
    result.shader = nil;
    result.script = nil;
    result.frame_txt = [NSMutableArray arrayWithCapacity:10];
    
    while(true)
    {
        if(flag == 1)
        {
            switch(state)
            {
                case EOF:
                    return nil;
                case NAME:
                    readData(buffer,input);
                    result.name = [NSString stringWithCString:buffer encoding:NSASCIIStringEncoding];
                    flag = 0;
                    break;
                case SHADER:
                    readData(buffer,input);
                    result.shader = [NSString stringWithCString:buffer encoding:NSASCIIStringEncoding];
                    flag = 0;
                    break;
                case SCRIPT:
                    readData(buffer,input);
                    result.script = [NSString stringWithCString:buffer encoding:NSASCIIStringEncoding];
                    flag = 0;
                    break;
                case FRAME:
                    readData(buffer,input);
                    [result.frame_txt addObject: [NSString stringWithCString:buffer encoding:NSASCIIStringEncoding]];
                    flag = 0;
                    break;
            }
            
    }
        
        cmp = prefab_cmd(input);
        if(cmp == NAME)
        {
            state = NAME;
            flag = 0;
        }
        else if(cmp == SHADER)
        {
            state = SHADER;
            flag = 0;
        }
        else if(cmp == FRAME)
        {
            state = FRAME;
            flag = 0;
        }
        else if(cmp == SCRIPT)
        {
            state = SCRIPT;
            flag = 0;
        }
        else if(cmp == SUB_BEGIN)
        {
            flag = 1;
        }
        else if(cmp == SUB_END)
        {
            flag = 0;
        }
        else if(cmp == EOF)
        {
            return result;
        }
    }
    return result;
}
@end


