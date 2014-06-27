//
//  prefabLoader.h
//  try
//
//  Created by tanshuo on 6/25/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "TC_PrefabInfo.h"
#import "TC_TextureLoader.h"
typedef enum{
    IGNORE,
    NAME,
    SHADER,
    SCRIPT,
    FRAME,
    NEXT_FRAME,
    GROUP,
    SUB_BEGIN,
    SUB_END,
    SIZE,
    COMMENT,
    UNKNOWN
} PRE_CMD;

int prefab_cmd(FILE* input);
int readData(char* buff, FILE* input);
@interface TC_PrefabLoader : NSObject
+ (TC_PrefabInfo*)loadPrefab: (NSString*)prefab WithName:(NSString*) name;
@end
