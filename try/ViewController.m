//
//  ViewController.m
//  try
//
//  Created by tanshuo on 6/20/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "ViewController.h"




@interface ViewController ()

@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) TC_Actor *act;

- (void)setupGL;
- (void)tearDownGL;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    [self setupGL];
    self.act = [TC_Actor alloc];
    [self.act InitialWithName:@"try" WithX:0 WithY:0 WithZ:-90 WithHeight:5.5f WithWidth:7.5f WithScript:@"no" WithShader:@"Shader"];
    [self.act start];
}

- (void)dealloc
{    
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }

    // Dispose of any resources that can be recreated.
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    glEnable(GL_DEPTH_TEST);
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update//jiaoben
{
    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    [self.act selfUpateWithAspect:aspect];
    
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect //huitu
{
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    [self.act drawSelf];
}


@end
