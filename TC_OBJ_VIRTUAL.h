//
//  TC_OBJ_VIRTUAL.h
//  try
//
//  Created by tanshuo on 7/14/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//

#ifndef try_TC_OBJ_VIRTUAL_h
#define try_TC_OBJ_VIRTUAL_h
#import "TC_VirtualMachine.h"
#import "TC_Camera.h"
#import "TC_Sprite.h"
#import "TC_Control.h"
#define CAMERA_NUM 3

TC_Camera* camera[CAMERA_NUM];

TC_Interpretor* _it;
TC_Control* control;

double _timer;
#endif
