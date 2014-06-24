//
//  Shader.fsh
//  try
//
//  Created by tanshuo on 6/20/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

varying lowp vec4 colorVarying;
varying lowp vec2 coordVarying;
uniform sampler2D sampler;

void main()
{
    //gl_FragColor = colorVarying;
    gl_FragColor = texture2D(sampler,coordVarying.xy);
}
