//
//  TC_DISPLAYOBJECT.h
//  try
//
//  Created by tanshuo on 6/22/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//  basic object using opengl interface to draw it self 

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "types.h"
#import "tool.h"
#import "TC_VirtualMachine.h"
#import "TC_ScriptLoader.h"
#import "TC_ShaderLoader.h"
#import "TC_TextureLoader.h"
#import "TC_GameObjectList.h"

@interface TC_DisplayObject:NSObject
{
    TC_OBJ_TYPE _type;
    TC_ID _id;
    TC_ID _label;
    NSString* _name;
    BOOL _show;
    BOOL _active;
   
    GLint uniforms[NUM_UNIFORMS];
    TC_Shaderinfo* _program;
    
    TC_TextureInfo* _textureinfo;
    
    GLKMatrix4 _modelViewProjectionMatrix;
    GLKMatrix3 _normalMatrix;
    
    GLKMatrix4 _projectionMatrix;
    GLKMatrix4 _baseModelViewMatrix;
    
    GLuint _vertexArray;
    GLuint _vertexBuffer;
    float _rotation;
    float _w;
    float _h;
    TC_Position _position;
  
    TC_ID _currentline;
    TC_VirtualMachine* _virtual;
    
    TC_Signal _eventlist[50];
}
@property (strong,nonatomic) TC_VirtualMachine* virtual;
@property (strong,nonatomic) NSString* name;
@property TC_Position position;
@property float rotation;
@property float w;
@property float h;
@property TC_OBJ_TYPE type;
@property TC_ID label;
@property BOOL show;
@property BOOL active;
@property TC_ID oid;

- (TC_ID) InitialWithName: (NSString*) name WithX: (GLfloat)x WithY: (GLfloat)y WithZ: (GLfloat)z WithHeight: (GLfloat)height WithWidth: (GLfloat)width WithScript: (NSString*) script WithShader: (NSString*) shader WithTexture: (NSString*)texture;

- (void) start;

- (void) activeShader;
- (void) drawSelf;//only method called in drawrect.

- (void) sendSignalTo: (int)_id WithData1:(float)data1 WithData2:(float)data2;
- (int) waitToSignal: (TC_ID)what_to_do;//if no more, return 0;if no such signal, break out reading script.

- (void) selfUpateWithleft: (float)left Right:(float)right Bottom:(float) bottom Top:(float)top;//only method in update, all stepss in one frame,


- (TC_ID) getID;
- (NSString*) getName;
- (TC_Position) getPosition;
- (float) getRotation;


- (void) SetUniformWithProjection: (GLint)pro WithNormal: (GLint)normal WithSampler:(GLint)sampler;

- (void) die;
- (void) dealloc;

@end
