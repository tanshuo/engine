//
//  TC_PhysicsWorld.h
//  try
//
//  Created by tanshuo on 7/27/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "physics_set.h"

@interface TC_PhysicsWorld : NSObject
@property unsigned int time;

- (void) start;
- (void) update;
@end
