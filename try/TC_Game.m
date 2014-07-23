//
//  TC_Game.m
//  try
//
//  Created by tanshuo on 6/24/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//

#import "TC_Game.h"

@implementation TC_Game
+ (void) gameStart
{
    _timer = 0.0;
    _global = [NSMutableArray arrayWithCapacity:10];
    _it = [TC_Interpretor alloc];
    [_it start];
    //[_it readScript: @"test"];
    //NSString* mss = [_it debug];
    ///////////
    int i;
    txtlist = [NSMutableArray arrayWithCapacity:10];
    shaderlist = [NSMutableArray arrayWithCapacity:10];
    gameObjectList = [NSMutableArray arrayWithCapacity:10];
    scriptlist = [NSMutableArray arrayWithCapacity:10];
    control = [TC_Control alloc];
    control.x = 0;
    control.y = 0;
    control.count = 0;
    
    initList();
    for(i = 0; i < CAMERA_NUM; i ++)
    {
        camera[0] = [TC_Camera alloc];
        [camera[0] InitCamera];
    }
    [self sceneInit];
    for(i = 0; i < [gameObjectList count]; i ++)
    {
        if([[gameObjectList objectAtIndex:i] getGroup] >= CAMERA_NUM)
            return;
        else
        {
            [camera[ [[gameObjectList objectAtIndex:i] getGroup] ] addChild:[gameObjectList objectAtIndex:i]];
        }
    }
}
+ (void) sceneInit
{
    //[[TC_Layer alloc] InitialWithName:@"hello" WithX:10 WithY:10 WithZ:0 WithHeight:10 WithWidth:10 WithScript:nil WithShader:@"Shader" WithTexture:@"test" WithGroup:0];
    TC_Sprite* s = [TC_Sprite alloc];
    [s born:@"prefab1" atGroup:0];
    [s setRelativePositionWithX:20 WithY:20];
    [s adjust:1];
    
    [[TC_Sprite alloc] born:@"prefab1" atGroup:0];
    
   // [[TC_Sprite alloc] born:@"prefab1" atGroup:0];
}
+ (void) upateWithleft: (float)left Right:(float)right Bottom:(float) bottom Top:(float)top
{
    int i;
    int num;
    num = [gameObjectList count];
    for(i = 0; i < num; i ++)
    {
        [[gameObjectList objectAtIndex:i] selfUpateWithleft:left Right:right Bottom:bottom Top:top];
        if([[gameObjectList objectAtIndex:i] lonely])
        {
            [[gameObjectList objectAtIndex:i] kill];
        }
    }
    num = [gameObjectList count];
    for(; i < num; i ++)
    {
        if([gameObjectList objectAtIndex:i])
        {
            if([[gameObjectList objectAtIndex:i] lonely])
            {
                [[gameObjectList objectAtIndex:i] kill];
            }
        }
    }
    for(i = 0; i < num; i ++)
    {
        if([[gameObjectList objectAtIndex:i] alive] == NO)
        {
            [gameObjectList removeObject:[gameObjectList objectAtIndex:i]];
            i --;
            num --;
        }
    }
    if(control.count > 0)
    {
        control.count --;
    }
}
+ (void) display
{
    int i;
    for(i = 0; i < [gameObjectList count]; i ++)
    {
        if([gameObjectList objectAtIndex:i])
        {
            [[gameObjectList objectAtIndex:i] drawSelf];
        }
    }
}
@end
