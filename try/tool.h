//
//  globol.h
//  try
//
//  Created by tanshuo on 6/22/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//

#ifndef try_tool_h
#define try_tool_h
#import "types.h"
#import "list.h"
#import <stdlib.h>
#import <stdio.h>
#import <string.h>

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

void initList();
void deleteList();
void addEntry(TC_ID obj_id, const char* name);
void deleteEntryByID(TC_ID obj_id);

TC_ID genID();
TC_ID findIDByName(char* name);

unsigned int getObjectNum();

#endif
