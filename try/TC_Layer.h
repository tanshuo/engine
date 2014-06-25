//
//  TC_Layer.h
//  try
//
//  Created by tanshuo on 6/24/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//

#import "TC_DisplayObject.h"

@interface TC_Layer : TC_DisplayObject{
    TC_Layer* _parent;
    NSMutableArray* _child;
    TC_Position _relativePosition;
    float _relativeRotation;
    int _child_num;
}
- (void) InitialWithName: (NSString*) name WithX: (GLfloat)x WithY: (GLfloat)y WithZ: (GLfloat)z WithHeight: (GLfloat)height WithWidth: (GLfloat)width WithScript: (NSString*) script WithShader: (NSString*) shader WithTexture: (NSString*)texture;
- (void) selfUpateWithAspect: (float)aspect;
- (TC_Position)getRelativePosition;
- (float)getRelativeRotation;
- (void) setRelativePositionWithX: (float)x WithY: (float)y;
- (void) setRelativeRotation: (float) deg;
- (void) setParent: (TC_Layer*) parent;
- (void) addChild: (TC_Layer*) child AtX: (float)x AtY: (float)y;
- (void) removeChildByID: (TC_ID)obj_id;
- (void) removeLastChild;
- (void) removeAllChild;
- (void) setDepth: (float)z;
- (void) setX: (float)x;
- (void) setY: (float)y;
- (void) die;
@end
