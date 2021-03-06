//
//  TC_Sprite.h
//  try
//
//  Created by tanshuo on 6/25/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//

#import "TC_Layer.h"
#import "TC_PrefabInfo.h"
#import "TC_PrefabLoader.h"

@interface TC_Sprite : TC_Layer{
    TC_ID _currentFrame;
    TC_ID _currentSequence;
    TC_ID _totalSequence;
    TC_ID _frameSpeed;
    NSMutableArray* _anims;
    NSMutableArray* _totalFrame;
}
@property TC_ID currentFrame;
@property TC_ID currentSequence;
@property TC_ID totalSequence;
@property (strong,nonatomic) NSMutableArray* totalFrame;
@property TC_ID frameSpeed;

- (void) born: (NSString*)prefab atGroup: (TC_ID)g;
- (TC_ID) InitialWithName: (NSString*) name WithX: (GLfloat)x WithY: (GLfloat)y WithZ: (GLfloat)z WithHeight: (GLfloat)height WithWidth: (GLfloat)width WithScript: (NSString*) script  WithShader:(NSString*)shader WithFrame: (NSMutableArray*)frames WithGroup: (TC_ID)group;
- (void) drawSelf;
- (void) adjust: (TC_ID)seq;
@end
