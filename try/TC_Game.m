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
    [[TC_Sprite alloc] born:@"prefab1" atGroup:0];
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
