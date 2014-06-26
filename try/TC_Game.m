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
    int i;
    txtlist = [NSMutableArray arrayWithCapacity:10];
    gameObjectList = [NSMutableArray arrayWithCapacity:10];
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
    [[TC_Layer alloc] InitialWithName:@"act1" WithX:0 WithY:50 WithZ:-90 WithHeight:30.0f WithWidth:30.0f WithScript:@"no" WithShader:@"Shader" WithTexture:@"test" WithGroup: 0];
    [[TC_Layer alloc] InitialWithName:@"act2" WithX:20 WithY:0 WithZ:-90 WithHeight:30.0f WithWidth:30.0f WithScript:@"no" WithShader:@"Shader" WithTexture:@"test" WithGroup: 0];
    [[TC_Layer alloc] InitialWithName:@"act3" WithX:30 WithY:0 WithZ:-90 WithHeight:30.0f WithWidth:30.0f WithScript:@"no" WithShader:@"Shader" WithTexture:@"test" WithGroup: 0];
    [[gameObjectList objectAtIndex:0] addChild:[gameObjectList objectAtIndex:1]];
    //[[gameObjectList objectAtIndex:0] kill];
}
+ (void) updateWithAspect: (float)aspect;
{
    int i;
    for(i = 0; i < [gameObjectList count]; i ++)
    {
        if([gameObjectList objectAtIndex:i])
        {
            if([[gameObjectList objectAtIndex:i] lonely])
            {
                [[gameObjectList objectAtIndex:i] kill];
            }
            [[gameObjectList objectAtIndex:i] selfUpateWithAspect:aspect];
        }
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
