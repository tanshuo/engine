//
//  TC_Game.h
//  try
//
//  Created by tanshuo on 6/24/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "types.h"
#import "tool.h"
#import "TC_VirtualMachine.h"
#import "TC_ScriptLoader.h"
#import "TC_ShaderLoader.h"
#import "TC_TextureLoader.h"
#import "TC_GameObjectList.h"
#import "TC_DisplayObject.h"
#import "TC_Layer.h"
#import "TC_Camera.h"
#import "TC_Sprite.h"
#import "TC_Interpretor.h"
#import "TC_OBJ_VIRTUAL.h"
#import "TC_PhysicsWorld.h"




@interface TC_Game : NSObject
+ (void) gameStart;
+ (void) upateWithleft: (float)left Right:(float)right Bottom:(float) bottom Top:(float)top;
+ (void) display;
+ (void) sceneInit;
@end
