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
    int i;
    TC_PrefabInfo* info = [TC_PrefabLoader loadPrefab:prefab WithName:@"test"];
    if(info == nil)
    {
        printf("cannot open prefab\n");
        return;
    }
    [self InitialWithName:info.name WithX:0 WithY:0 WithZ:-90 WithHeight:info.h WithWidth:info.w WithScript:info.script WithShader:info.shader WithFrame:info.frame_txt WithGroup:0];
    _currentFrame = 0;
    _currentSequence = 0;
    _totalFrame = [NSMutableArray arrayWithCapacity:10];
    _totalSequence = [_anims count];
    _frameSpeed = 1;
    for(i = 0;i < _totalSequence;i ++)
    {
        [_totalFrame addObject:[NSNumber numberWithInt:[[_anims objectAtIndex:i] count]]];
    }
};

- (TC_ID) InitialWithName: (NSString*) name WithX: (GLfloat)x WithY: (GLfloat)y WithZ: (GLfloat)z WithHeight: (GLfloat)height WithWidth: (GLfloat)width WithScript: (NSString*) script  WithShader:(NSString*)shader WithFrame: (NSMutableArray*)frames WithGroup: (TC_ID)group
{
    TC_ID mid = [self InitialWithName:name WithX:x WithY:y WithZ:z WithHeight:height WithWidth:width WithScript:script WithShader:shader WithTexture:nil WithGroup:group];
    _anims = frames;
    return mid;
}
- (void) drawSelf
{
    if(!_show)
    {
        return;
    }
    NSNumber* temp = [[_anims objectAtIndex:_currentSequence] objectAtIndex: _currentFrame];
    glUseProgram(_program.sid);
    glBindVertexArrayOES(_vertexArray);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBindTexture(GL_TEXTURE_2D, temp.intValue);
    [self activeShader];
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix.m);
    glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, _normalMatrix.m);
    glUniform1i(uniforms[UNIFORM_SAMPLE], 0);
    glDrawArrays(GL_TRIANGLES, 0, 6);
    _currentFrame = (_currentFrame + _frameSpeed) %  [[_totalFrame objectAtIndex: _currentSequence] intValue];
}
@end
