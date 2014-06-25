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
@property (strong, nonatomic) TC_Layer *act;
@property (strong, nonatomic) TC_Layer *act1;
@property (strong, nonatomic) TC_Layer *act2;
@property (strong, nonatomic) TC_Camera * camera;

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
    
    gameObjectList = [NSMutableArray arrayWithCapacity:10];
    
    [self setupGL];
    initList();
    
    self.act = [TC_Layer alloc];
    [self.act InitialWithName:@"try" WithX:0 WithY:0 WithZ:-90 WithHeight:30.0f WithWidth:30.0f WithScript:@"no" WithShader:@"Shader" WithTexture:@"test"];
    [self.act start];
    self.act1 = [TC_Layer alloc];
    [self.act1 InitialWithName:@"try" WithX:0 WithY:0 WithZ:-90 WithHeight:30.0f WithWidth:30.0f WithScript:@"no" WithShader:@"Shader" WithTexture:@"test"];
    [self.act1 start];
    self.act2 = [TC_Layer alloc];
    [self.act2 InitialWithName:@"try" WithX:0 WithY:0 WithZ:-90 WithHeight:30.0f WithWidth:30.0f WithScript:@"no" WithShader:@"Shader" WithTexture:@"test"];
    [self.act2 start];
    
    
    self.camera = [TC_Camera alloc];
    [self.camera InitCamera];
    [self.camera addChild:self.act AtX:50 AtY:0];
    [self.camera addChild:self.act1 AtX:50 AtY:50];
    [self.camera addChild:self.act2 AtX:-50 AtY:0];

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
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
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
    [self.act1 selfUpateWithAspect:aspect];
    [self.act2 selfUpateWithAspect:aspect];
    
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect //huitu
{
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    [self.act drawSelf];
    [self.act1 drawSelf];
    [self.act2 drawSelf];
}


@end
