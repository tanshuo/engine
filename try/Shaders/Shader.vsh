//
//  Shader.vsh
//  try
//
//  Created by tanshuo on 6/20/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

attribute vec4 position;
attribute vec3 normal;
attribute vec2 texture0;


varying lowp vec4 colorVarying;
varying lowp vec2 coordVarying;

uniform mat4 modelViewProjectionMatrix;
uniform mat3 normalMatrix;


void main()
{
    vec3 eyeNormal = normalize(normalMatrix * normal);
    vec3 lightPosition = vec3(0.0, 0.0, 1.0);
    vec4 diffuseColor = vec4(1.0, 1.0, 1.0, 1.0);
    
    float nDotVP = max(0.0, dot(eyeNormal, normalize(lightPosition)));
                 
    colorVarying = diffuseColor * nDotVP;
    
    gl_Position = modelViewProjectionMatrix * position;
    coordVarying = texture0;
}
