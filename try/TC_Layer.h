//
//  TC_Layer.h
//  try
//
//  Created by tanshuo on 6/24/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//

#import "TC_DisplayObject.h"

@interface TC_Layer : TC_DisplayObject{
    TC_Layer* parent;
    TC_Layer* child;
}
@end
