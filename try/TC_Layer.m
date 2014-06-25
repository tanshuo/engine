//
//  TC_Layer.m
//  try
//
//  Created by tanshuo on 6/24/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//

#import "TC_Layer.h"

@implementation TC_Layer
- (void) InitialWithName: (NSString*) name WithX: (GLfloat)x WithY: (GLfloat)y WithZ: (GLfloat)z WithHeight: (GLfloat)height WithWidth: (GLfloat)width WithScript: (NSString*) script WithShader: (NSString*) shader WithTexture: (NSString*)texture
{
    [super InitialWithName:name WithX:x WithY:y WithZ:z WithHeight:height WithWidth:width WithScript:script WithShader:shader WithTexture:texture];
    _child_num = 0;
    _relativeRotation = 0;
    _relativePosition.x = 0;
    _relativePosition.y = 0;
    _relativePosition.z = 0;
    _child_num = 0;
    _child = [NSMutableArray arrayWithCapacity:10];
    _parent = nil;
    _show = NO;
    [gameObjectList addObject:self];
}
- (void) selfUpateWithAspect: (float)aspect
{
    if(_parent == nil)
    {
        _show = NO;
        return;
    }
    TC_Position finalPosition;
    finalPosition = [_parent getRelativePosition];
    finalPosition.x = finalPosition.x + _relativePosition.x;
    finalPosition.y = finalPosition.y + _relativePosition.y;
    finalPosition.z = finalPosition.z + _relativePosition.z;
    _position.x = finalPosition.x;
    _position.y = finalPosition.y;
    _position.z = finalPosition.z;
    _rotation = _relativeRotation + [_parent getRelativeRotation];
    [super selfUpateWithAspect:aspect];
}
- (TC_Position)getRelativePosition
{
    return _relativePosition;
}
- (void) setRelativePositionWithX: (float)x WithY: (float)y
{
    _relativePosition.x = x;
    _relativePosition.y = y;
}
- (void) setRelativeRotation: (float) deg
{
    _relativeRotation = deg;
}
- (float) getRelativeRotation
{
    return _relativeRotation;
}
- (void) addChild: (TC_Layer*) child AtX: (float)x AtY: (float)y
{
    _child_num ++;
    [child setRelativePositionWithX:x WithY:y];
    [child setDepth:1];
    [child setRelativeRotation:0];
    [child setParent:self];
    [child enable];
    [_child addObject:child];
    _child_num ++;
}
- (void) setParent: (TC_Layer*) parent
{
    _parent = parent;
}
- (void) removeChildByID: (TC_ID)obj_id
{
    TC_Layer* temp;
    int i;
    for(i = 0; i < _child_num; i++)
    {
        temp = [_child objectAtIndex:i];
        if(temp)
            if([temp getID] == obj_id)
            {
                 _child_num --;
                [temp setParent:nil];
                [_child removeObject:temp];
            }
    }
}
- (void) removeLastChild
{
    if(_child_num > 0)
    {
        _child_num --;
        [[_child lastObject] setParent:nil];
        [_child removeLastObject];
    }
}
- (void) removeAllChild
{
    while(_child_num > 0)
        [self removeLastChild];
}
- (void) enable
{
    _show = YES;
}
- (void) hide
{
    _show = NO;
}
- (void) setDepth: (float)z
{
    _relativePosition.z = z;
}
- (void) setX:(float)x
{
    _relativePosition.x = x;
}
- (void) setY:(float)y
{
    _relativePosition.y = y;
}
- (void) die
{
    [super die];
    [gameObjectList removeObject:self];
}
@end
