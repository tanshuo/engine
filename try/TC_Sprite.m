//
//  TC_Sprite.m
//  try
//
//  Created by tanshuo on 6/25/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//

#import "TC_Sprite.h"

@implementation TC_Sprite
- (void) born: (NSString*)prefab atGroup:(TC_ID)g
{
    TC_PrefabInfo* info = [TC_PrefabLoader loadPrefab:prefab WithName:@"test"];
    [self InitialWithName:info.name WithX:0 WithY:0 WithZ:-90 WithHeight:10 WithWidth:10 WithScript:info.script WithShader:info.shader WithFrame:info.frame_txt WithGroup:0];
    
};

- (TC_ID) InitialWithName: (NSString*) name WithX: (GLfloat)x WithY: (GLfloat)y WithZ: (GLfloat)z WithHeight: (GLfloat)height WithWidth: (GLfloat)width WithScript: (NSString*) script  WithShader:(NSString*)shader WithFrame: (NSMutableArray*)frames WithGroup: (TC_ID)group
{
    TC_ID mid = [self InitialWithName:name WithX:x WithY:y WithZ:z WithHeight:10 WithWidth:10 WithScript:script WithShader:shader WithTexture:nil WithGroup:group];
    frame_texs = [NSMutableArray arrayWithCapacity:10];
    while([frames count])
    {
        [frame_texs addObject: [frames lastObject]];
        [frames removeLastObject];
    }
    return mid;
}
@end
