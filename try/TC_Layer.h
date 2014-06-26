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
    TC_ID _group;
    BOOL _alive;
}
- (TC_ID) InitialWithName: (NSString*) name WithX: (GLfloat)x WithY: (GLfloat)y WithZ: (GLfloat)z WithHeight: (GLfloat)height WithWidth: (GLfloat)width WithScript: (NSString*) script WithShader: (NSString*) shader WithTexture: (NSString*)texture WithGroup: (TC_ID)group;
- (void) selfUpateWithAspect: (float)aspect;
- (TC_Position)getRelativePosition;
- (float)getRelativeRotation;
- (void) setRelativePositionWithX: (float)x WithY: (float)y;
- (void) setRelativeRotation: (float) deg;
- (void) setParent: (TC_Layer*) parent;
- (TC_ID) getGroup;
- (BOOL) addChild: (TC_Layer*) child;

- (TC_Layer*) getChildByName: (NSString*)name;
- (TC_Layer*) getChildByIndex: (TC_ID)index;
- (TC_Layer*) getfirstChild: (TC_ID)index;
- (TC_Layer*) getlastChild: (TC_ID)index;
- (TC_Layer*) getParent;

- (int) countOfChildren;


- (void) removeChildByID: (TC_ID)obj_id;
- (TC_Layer*) removeLastChild;
- (void) removeAllChild;
+ (void) removeLayer: (TC_Layer*)layer;
- (void) enable;
- (void) hide;
- (void) setDepth: (float)z;
- (void) setX: (float)x;
- (void) setY: (float)y;
- (BOOL) lonely;
- (void) kill; //the only method to elimate an object
- (void) die;
@end
