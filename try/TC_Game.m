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
    TC_Interpretor* _test = [TC_Interpretor alloc];
    [_test start];
    TC_Define* temp = [TC_Define alloc];
    temp.word = @"if";
    temp.explain = TC_IF;
    temp.right_match = 0;
    [_test.dictionary addObject: temp];
    
    temp = [TC_Define alloc];
    temp.word = @"is";
    temp.explain = TC_FUNCTION;
    temp.right_match = 1;
    temp = [TC_Define alloc];
    [_test.dictionary addObject: temp];
    
    temp.word = @"A";
    temp.explain = TC_INT;
    temp.right_match = 0;
    [_test.dictionary addObject: temp];
    
    temp.word = @"B";
    temp.explain = TC_INT;
    temp.right_match = 0;
    [_test.dictionary addObject: temp];
    
    temp.word = @";";
    temp.explain = TC_END;
    temp.right_match = 0;
    [_test.dictionary addObject: temp];
    
    temp.word = @",";
    temp.explain = TC_THEN;
    temp.right_match = 0;
    [_test.dictionary addObject: temp];
    
    temp.word = @",";
    temp.explain = TC_IGNORE;
    temp.right_match = 0;
    [_test.dictionary addObject: temp];
    ///////////
    int i;
    txtlist = [NSMutableArray arrayWithCapacity:10];
    shaderlist = [NSMutableArray arrayWithCapacity:10];
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
    //[[TC_Layer alloc] InitialWithName:@"hello" WithX:10 WithY:10 WithZ:0 WithHeight:10 WithWidth:10 WithScript:nil WithShader:@"Shader" WithTexture:@"test" WithGroup:0];
    TC_Sprite* s = [TC_Sprite alloc];
    [s born:@"prefab1" atGroup:0];
    [s setRelativePositionWithX:20 WithY:20];
    [s adjust:1];
    [[TC_Sprite alloc] born:@"prefab1" atGroup:0];
   // [[TC_Sprite alloc] born:@"prefab1" atGroup:0];
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
