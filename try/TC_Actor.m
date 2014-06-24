//
//  TC_Actor.m
//  try
//
//  Created by tanshuo on 6/22/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//

#import "TC_Actor.h"


@implementation TC_Actor
- (void)InitialWithName: (NSString*) name WithX: (GLfloat)x WithY: (GLfloat)y WithZ: (GLfloat)z WithHeight: (GLfloat)height WithWidth: (GLfloat)width WithScript: (NSString*) script WithShader:(NSString*)shader
{
    GLfloat gCubeVertexData[36] =
    {
        // Data layout for each line below is:
        // positionX, positionY, positionZ,     normalX, normalY, normalZ,
        - width / 2.0f, - height / 2.0f, 0.0f, 0.0f, 0.0f, 1.0f,
        - width / 2.0f, + height / 2.0f, 0.0f, 0.0f, 0.0f, 1.0f,
        + width / 2.0f, + height / 2.0f, 0.0f, 0.0f, 0.0f, 1.0f,
        + width / 2.0f, + height / 2.0f, 0.0f, 0.0f, 0.0f, 1.0f,
        + width / 2.0f, - height / 2.0f, 0.0f, 0.0f, 0.0f, 1.0f,
        - width / 2.0f, - height / 2.0f, 0.0f, 0.0f, 0.0f, 1.0f,
    };
    self._name = [[NSString alloc] initWithString:name];
    _position.x = x;
    _position.y = y;
    _position.z = z;
    _rotation = 0.0f;
    
    _baseModelViewMatrix = GLKMatrix4MakeTranslation(x, y, z);
    _baseModelViewMatrix = GLKMatrix4Rotate(_baseModelViewMatrix, GLKMathDegreesToRadians(_rotation), 0.0f, 0.0f, 1.0f);
    
    _virtual = [TC_ScriptLoader loadScriptWith:script];
    _program = [TC_ShaderLoader loadShaderWithVertexShader:shader WithFragmentShader:shader];
    
    glGenVertexArraysOES(1, &_vertexArray);
    glBindVertexArrayOES(_vertexArray);
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(gCubeVertexData), gCubeVertexData, GL_STATIC_DRAW);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(12));
};

- (void) drawSelf;
{
    glUseProgram(_program);
    [self activeShader];
   
    glBindVertexArrayOES(_vertexArray);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix.m);
    glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, _normalMatrix.m);
    
    glDrawArrays(GL_TRIANGLES, 0, 6);
}

- (void)activeShader
{
    [self SetUniformWithProjection:glGetUniformLocation(_program, "modelViewProjectionMatrix") WithNormal:glGetUniformLocation(_program, "normalMatrix")];
    
};

- (int) actWithScript
{
    return 0;
};

- (void) selfUpateWithAspect: (float)aspect
{
    _projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90), aspect, 0.1f, 10000.0f);
  
    [self actWithScript];
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(_position.x,_position.y,_position.z);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(_rotation), 0.0f, 0.0f, 1.0f);
    modelViewMatrix = GLKMatrix4Multiply(_baseModelViewMatrix, modelViewMatrix);
    modelViewMatrix = GLKMatrix4Multiply(_baseModelViewMatrix, modelViewMatrix);
    _normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(_baseModelViewMatrix), NULL);
    _modelViewProjectionMatrix = GLKMatrix4Multiply(_projectionMatrix, _baseModelViewMatrix);
};

- (void) start
{

};

- (void) die
{
    glDeleteBuffers(1, &_vertexBuffer);
    glDeleteVertexArraysOES(1, &_vertexArray);
    if (_program) {
        glDeleteProgram(_program);
        _program = 0;
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
- (GLKMatrix4) getProjectionMatrix
{
    return _projectionMatrix;
}
- (GLKMatrix3) getNormalMatrix
{
    return _normalMatrix;
}
- (GLuint) getShader
{
    return _program;
}



- (void) SetUniformWithProjection: (GLint)pro WithNormal: (GLint)normal
{
    uniforms[0] = pro;
    uniforms[1] = normal;
}

- (void) dealloc
{
    [self die];
}


@end
