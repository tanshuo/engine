//
//  TC_ScriptLoader.h
//  try
//
//  Created by tanshuo on 6/23/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "TC_VirtualMachine.h"
#import "TC_ScriptListInfo.h"
#import "types.h"

NSMutableArray* scriptlist;

@interface TC_ScriptLoader : NSObject
+ (TC_VirtualMachine*)loadScriptWith: (NSString*)name;
+ (TC_VirtualMachine*) lookscript: (NSString*) name;
@end
