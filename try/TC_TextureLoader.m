//
//  TC_TextureLoader.m
//  try
//
//  Created by tanshuo on 6/24/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//

#import "TC_TextureLoader.h"
int genNum2(int num)
{
    int i;
    int acc = 1;
    for(i = 0;i < 10000;i++)
    {
        acc = acc * 2;
        if(acc > num)
        {
            return acc;
        }
    }
    return acc;
}

NSData* ResizeTextureWith(CGImageRef im,GLuint* width,GLuint* height)
{
    int m_width;
    int m_height;
    
    m_width = CGImageGetWidth(im);
    m_height = CGImageGetHeight(im);
    
    *width = genNum2(m_width);
    *height = genNum2(m_height);
    
    NSMutableData* imagedata = [NSMutableData dataWithLength: 4 * (*width) * (*height)];
    if(imagedata == nil)
    {
        NSLog(@"no enough mem\n");
        return nil;
    }
    CGColorSpaceRef color = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate([imagedata mutableBytes], *width, *height, 8, 4 * (*width), color, 1);
    CGColorSpaceRelease(color);
    CGContextTranslateCTM(context, 0, *height);
    CGContextScaleCTM(context, 1.0f, -1.0f);
    CGContextDrawImage(context, CGRectMake(0, 0, *width, *height), im);
    CGContextRelease(context);
    
    return imagedata;
};

@implementation TC_TextureLoader


+ (TC_TextureInfo*)loadTexture: (NSString*)t
{
    TC_TextureInfo* result;
    NSString* path;
    path = [[NSBundle mainBundle] pathForResource:t ofType:@"tct"];
    CGImageRef im = [[UIImage imageNamed:path] CGImage];
    if(im == nil)
    {
        return nil;
    }
    GLuint width;
    GLuint height;
    NSData* data = ResizeTextureWith(im,&width,&height);
    GLuint tid;
    glGenTextures(1, &tid);
    glBindTexture(GL_TEXTURE_2D, tid);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, [data bytes]);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    result = [TC_TextureInfo alloc];
    result.width = width;
    result.height = height;
    result.name = tid;
    result.counter = 1;
    return result;
}

@end
