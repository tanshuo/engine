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
@property  GLuint _viewRenderbuffer;
@property float ftime;

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
    [TC_Game gameStart];
    
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
    glGenRenderbuffers(1, &__viewRenderbuffer);
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update//jiaoben
{
    float left = self.view.bounds.origin.x - self.view.bounds.size.width / 2;
    float right = self.view.bounds.origin.x + self.view.bounds.size.width / 2;
    float bottom = self.view.bounds.origin.y - self.view.bounds.size.height / 2;
    float top = self.view.bounds.origin.y + self.view.bounds.size.height / 2;
    [TC_Game upateWithleft:left Right:right Bottom:bottom Top:top];
    _timer += self.timeSinceLastUpdate;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect //huitu
{
    if(self.ftime > 1.0f/FPS)
    {
        glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        [TC_Game display];
        [self swapbuffer];
        self.ftime = 0;
    }
    else
        self.ftime += self.timeSinceLastUpdate;
}

- (void) swapbuffer
{
    EAGLContext* oldcontext = [EAGLContext currentContext];
    GLuint oldrender;
    if(oldcontext!= self.context)
        [EAGLContext setCurrentContext:_context];
    glGetIntegerv(GL_RENDERBUFFER_BINDING_OES, (GLint*)&oldrender);
    glBindRenderbuffer(GL_RENDERBUFFER_OES, __viewRenderbuffer);
    if(oldcontext!= self.context)
    {
        [EAGLContext setCurrentContext: oldcontext];
    }
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    CGPoint touchpoint = [touch locationInView:self.view];
    control.x = touchpoint.x - self.view.bounds.size.width / 2;
    control.y = -(touchpoint.y - self.view.bounds.size.height / 2);
    control.count = TLL;
}

@end
