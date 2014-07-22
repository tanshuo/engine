//
//  TC_DISPLAYOBJECT.m
//  try
//
//  Created by tanshuo on 6/22/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//

#import "TC_OBJ_VIRTUAL.h"


@implementation TC_DisplayObject
@synthesize position = _position;
@synthesize rotation = _rotation;
@synthesize virtual = _virtual;
@synthesize w = _w;
@synthesize h = _h;
@synthesize label = _label;
@synthesize show = _show;
@synthesize active = _active;
@synthesize oid = _id;
@synthesize name = _name;

- (TC_ID)InitialWithName: (NSString*) name WithX: (GLfloat)x WithY: (GLfloat)y WithZ: (GLfloat)z WithHeight: (GLfloat)height WithWidth: (GLfloat)width WithScript: (NSString*) script WithShader:(NSString*)shader WithTexture: (NSString*)texture
{
    _label = 0;
    _type = OBJDISPLAY;
    _id = genID();
    _name = [[NSString alloc] initWithString:name];
    _show = YES;
    _active = YES;
    
    GLfloat gCubeVertexData[48] =
    {
        // Data layout for each line below is:
        // positionX, positionY, positionZ,     normalX, normalY, normalZ,
        - width / 2.0f, - height / 2.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f,
        - width / 2.0f, + height / 2.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 1.0f,
        + width / 2.0f, + height / 2.0f, 0.0f, 0.0f, 0.0f, 1.0f, 1.0f, 1.0f,
        + width / 2.0f, + height / 2.0f, 0.0f, 0.0f, 0.0f, 1.0f, 1.0f, 1.0f,
        + width / 2.0f, - height / 2.0f, 0.0f, 0.0f, 0.0f, 1.0f, 1.0f, 0.0f,
        - width / 2.0f, - height / 2.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f,
    };
    
    _position.x = x;
    _position.y = y;
    _position.z = z;
    _rotation = 0.0f;
    _w = 1;
    _h = 1;
    
    _baseModelViewMatrix = GLKMatrix4MakeTranslation(x, y, z);
    _baseModelViewMatrix = GLKMatrix4Rotate(_baseModelViewMatrix, GLKMathDegreesToRadians(_rotation), 0.0f, 0.0f, 1.0f);
    
    _virtual = [TC_ScriptLoader loadScriptWith:script];
    _virtual.target = self;
    ((TC_INS_VARIABLE*)[_virtual.local_var_list objectAtIndex:0]).obj = self;
    _program = [TC_ShaderLoader loadShaderWithVertexShader:shader WithFragmentShader:shader];
    _textureinfo = [TC_TextureLoader loadTexture:texture];
    
    
    if(_program.sid == 0)
    {
        if(_program)
        {
            [_program die];
        }
    }
    
    glGenVertexArraysOES(1, &_vertexArray);
    glBindVertexArrayOES(_vertexArray);
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(gCubeVertexData), gCubeVertexData, GL_STATIC_DRAW);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(12));
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 3, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(24));
    addEntry(_id, [name cStringUsingEncoding:NSASCIIStringEncoding]);
    NSLog(@"%@ has been create",self.name);
    return _id;
};

- (void) drawSelf;
{
    glBindTexture(GL_TEXTURE_2D, _textureinfo.name);
    if(!_show)
    {
        return;
    }
    glUseProgram(_program.sid);
    
    [self activeShader];
   
    glBindVertexArrayOES(_vertexArray);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix.m);
    glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, _normalMatrix.m);
    glUniform1i(uniforms[UNIFORM_SAMPLE], 0);
    glDrawArrays(GL_TRIANGLES, 0, 6);
}

- (void)activeShader
{
    [self SetUniformWithProjection:glGetUniformLocation(_program.sid, "modelViewProjectionMatrix") WithNormal:glGetUniformLocation(_program.sid, "normalMatrix") WithSampler:glGetUniformLocation(_program.sid, "sampler")];
    
};

- (int) actWithScript
{
    return 0;
};



- (void) selfUpateWithAspect: (float)aspect
{
    
    if(!_active)
    {
        return;
    }
    if(_virtual.has_start == NO)
    {
        _virtual.ip = _virtual.head;
        _virtual.has_start = YES;
        _virtual.true_false = NO;
        _virtual.last_true = YES;
    }
    else
    {
        _virtual.ip = _virtual.update;
    }
    //stack
    TC_INS_VARIABLE* var;
    var = [TC_INS_VARIABLE alloc];
    var.solved = YES;
    var.borrow = NO;
    var.type = VAR_OFF_SET;
    var.var = nil;
    var.location = VAR_STACK;
    var.addr = nil;
    var.obj = nil;
    var.argoffset = -1;// return offset
    [_virtual.var_stack addObject:var];
    _virtual.sp ++;
    
    var = [TC_INS_VARIABLE alloc];
    var.solved = YES;
    var.borrow = NO;
    var.type = VAR_OFF_SET;
    var.var = nil;
    var.location = VAR_STACK;
    var.addr = nil;
    var.obj = nil;
    var.argoffset = -1;// old frame pointer
    [_virtual.var_stack addObject:var];
    _virtual.sp ++;
    _virtual.bp = 0;
    _virtual.current_fun = [NSMutableArray arrayWithCapacity:10];
    
    ///
    while(true)
    {
        int re = [_virtual run_next_ins];
        if(re == -1)
        {
            break;
        }
    }
    [_virtual.var_stack removeAllObjects];
    
    
    _projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90), aspect, 0.1f, 10000.0f);
  
    [self actWithScript];
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(_position.x,_position.y,_position.z);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(_rotation), 0.0f, 0.0f, 1.0f);
    modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, _w, _h, 1);
    modelViewMatrix = GLKMatrix4Multiply(_baseModelViewMatrix, modelViewMatrix);
    _normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), NULL);
    _modelViewProjectionMatrix = GLKMatrix4Multiply(_projectionMatrix, modelViewMatrix);
};

- (void) start
{

};

- (void) die
{
    deleteEntryByID(_id);
   
    glDeleteBuffers(1, &_vertexBuffer);
    glDeleteVertexArraysOES(1, &_vertexArray);
    if(_textureinfo)
    {
        [_textureinfo die];
    }
   if (_program) {
        [_program die];
        _program = nil;
    }
};

- (void) sendSignalTo: (int)_id WithData1:(float)data1 WithData2:(float)data2
{

};

- (int) waitToSignal: (TC_ID)what_to_do
{
    return 0;
};

- (TC_Position) getPosition
{
    return _position;
}
- (float) getRotation
{
    return _rotation;
}

- (TC_ID) getID
{
    return _id;
}
- (NSString*) getName
{
    return _name;
}



- (void) SetUniformWithProjection: (GLint)pro WithNormal: (GLint)normal WithSampler:(GLint)sampler
{
    uniforms[0] = pro;
    uniforms[1] = normal;
    uniforms[2] = sampler;
}

- (void) dealloc
{
    [self die];
}


@end
