//
//  TC_Actor.h
//  try
//
//  Created by tanshuo on 6/22/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "types.h"
#import "tool.h"
#import "TC_VirtualMachine.h"
#import "TC_ScriptLoader.h"
#import "TC_ShaderLoader.h"

@interface TC_Actor:NSObject
{
    TC_ID _id;
    
    GLint uniforms[NUM_UNIFORMS];
    GLuint _program;
    GLKMatrix4 _modelViewProjectionMatrix;
    GLKMatrix3 _normalMatrix;
    
    GLKMatrix4 _projectionMatrix;
    GLKMatrix4 _baseModelViewMatrix;
    
    GLuint _vertexArray;
    GLuint _vertexBuffer;
    float _rotation;
    TC_Position _position;
    
    TC_ID _currentFrame;
    TC_ID _totalFrame;
    
    TC_ID _currentline;
    TC_VirtualMachine* _virtual;
    
    TC_Signal _eventlist[50];
}
@property (strong,nonatomic) NSString* _name;
- (void) InitialWithName: (NSString*) name WithX: (GLfloat)x WithY: (GLfloat)y WithZ: (GLfloat)z WithHeight: (GLfloat)height WithWidth: (GLfloat)width WithScript: (NSString*) script WithShader: (NSString*) shader;

- (void) start;

- (void) activeShader;
- (void) drawSelf;//only method called in drawrect.

- (void) sendSignalTo: (int)_id WithData1:(float)data1 WithData2:(float)data2;
- (int) waitToSignal: (TC_ID)what_to_do;//if no more, return 0;if no such signal, break out reading script.

- (int) actWithScript;
- (void) selfUpateWithAspect: (float)aspect;//only method in update, all stepss in one frame, 0 is break, 1 is go on.


- (TC_Position) getPosition;
- (float) getRotation;
- (GLKMatrix4) getProjectionMatrix;
- (GLKMatrix3) getNormalMatrix;
- (GLuint) getShader;


- (void) SetUniformWithProjection: (GLint)pro WithNormal: (GLint)normal;

- (void) die;
- (void) dealloc;

@end
