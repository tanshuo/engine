//
//  list.h
//  try
//
//  Created by tanshuo on 6/24/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//

#ifndef try_list_h
#define try_list_h
#import "types.h"
struct objectlist{
    TC_ID obj_id;
    struct objectlist* next;
    struct objectlist* pre;
    char name[20];
};
typedef struct objectlist* TC_ObjList;
TC_ObjList objlist;
unsigned int obj_num;

#endif
