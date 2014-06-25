//
//  TC_Layer.m
//  try
//
//  Created by tanshuo on 6/24/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//

#import "TC_Layer.h"

@implementation TC_Layer
- (void) InitialWithName: (NSString*) name WithX: (GLfloat)x WithY: (GLfloat)y WithZ: (GLfloat)z WithHeight: (GLfloat)height WithWidth: (GLfloat)width WithScript: (NSString*) script WithShader: (NSString*) shader WithTexture: (NSString*)texture WithGroup: (TC_ID)group;
{
    [super InitialWithName:name WithX:x WithY:y WithZ:z WithHeight:height WithWidth:width WithScript:script WithShader:shader WithTexture:texture];
    _child_num = 0;
    _relativeRotation = 0;
    _relativePosition.x = x;
    _relativePosition.y = y;
    _relativePosition.z = z;
    _child_num = 0;
    _child = [NSMutableArray arrayWithCapacity:10];
    _parent = nil;
    _show = NO;
    _group = group;
    _alive = YES;
    [gameObjectList addObject:self];
}
- (void) selfUpateWithAspect: (float)aspect
{
    if(!_alive)
    {
        [self die];
    }
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
- (TC_ID) getGroup
{
    return _group;
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
- (TC_Layer*) getChildByName: (NSString*)name
{
    int i;
    TC_Layer* temp = nil;
    for(i = 0; i < _child_num; i++)
    {
        temp = [_child objectAtIndex:i];
        if(temp)
            if([ [temp getName] isEqual:name])
            {
               return temp;
            }
    }
    return temp;
}
- (TC_Layer*) getChildByIndex: (TC_ID)index
{
    return [_child objectAtIndex:index];
}
- (TC_Layer*) getfirstChild: (TC_ID)index
{
    return [_child firstObject];
}
- (TC_Layer*) getlastChild: (TC_ID)index
{
    return [_child lastObject];
}
- (int) countOfChildren
{
    return _child_num;
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
- (TC_Layer*) removeLastChild
{
    TC_Layer* result = nil;
    if(_child_num > 0)
    {
        _child_num --;
        result = [_child lastObject];
        [[_child lastObject] setParent:nil];
        [_child removeLastObject];
    }
    return result;
}
- (void) removeAllChild
{
    while(_child_num > 0)
        [self removeLastChild];
}
+ (void) removeLayer: (TC_Layer*)layer
{
    TC_Layer* temp;
    while((temp = [layer removeLastChild]))
    {
        [self removeLayer:temp];
    }
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

- (BOOL) lonely
{
    if(_parent == nil)
        return true;
    else
        return NO;
}
- (void) kill
{
    _alive = NO;
}
- (void) die
{
    [super die];
    [TC_Layer removeLayer:self];
    [gameObjectList removeObject:self];
}
@end
