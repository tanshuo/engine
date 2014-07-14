//
//  TC_Camera.m
//  try
//
//  Created by tanshuo on 6/24/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//

#import "TC_Camera.h"

@implementation TC_Camera
- (void) InitCamera
{
    _id = 0;
    _position.x = 0.0;
    _position.y = 0.0;
    _position.z = 0.0;
    _relativePosition.x = 0.0;
    _relativePosition.y = 0.0;
    _relativePosition.z = -50.0;
    _rotation = 0;
    _relativeRotation = 0;
    _child_num = 0;
    _child = [NSMutableArray arrayWithCapacity:10];
    _parent = nil;
    _name = @"camera";
    _type = OBJCAMARA;
};
- (void) die
{
    [TC_Camera removeLayer:self];
}
@end
