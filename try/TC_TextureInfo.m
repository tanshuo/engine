//
//  h.m
//  try
//
//  Created by tanshuo on 6/24/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//

#import "TC_TextureInfo.h"

@implementation TC_TextureInfo
@synthesize name = _name;
@synthesize width = _width;
@synthesize height = _height;
@synthesize counter = _counter;
- (void) die
{
    self.counter--;
    if(counter <= 0)
    {
        [self clearTexBuffer];
    }
}
- (void) clearTexBuffer
{
    glDeleteTextures(1,&_name);
}
- (void) dealloc
{
    [self die];
}
@end
