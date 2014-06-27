//
//  TC_Shaderinfo.m
//  try
//
//  Created by tanshuo on 6/27/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//

#import "TC_Shaderinfo.h"

@implementation TC_Shaderinfo
@synthesize sid = _sid;
@synthesize counter = _counter;
@synthesize shader = _shader;
- (void) die
{
    self.counter--;
    if(_counter <= 0)
    {
        glDeleteProgram(_sid);
    }
}
- (NSString*) getShd
{
    return _shader;
}
- (GLuint) getSID
{
    return _sid;
}
- (void)dealloc
{
    [self die];
}
@end
