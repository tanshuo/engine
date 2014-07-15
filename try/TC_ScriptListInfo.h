//
//  TC_ScriptListInfo.h
//  try
//
//  Created by tanshuo on 7/11/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "types.h"
#import "TC_VirtualMachine.h"

@interface TC_ScriptListInfo : NSObject
@property (strong,nonatomic) NSString* name;
@property (strong,nonatomic) TC_VirtualMachine* vm;
@property TC_ID owrner;
@end
