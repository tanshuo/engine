//
//  globol.c
//  try
//
//  Created by tanshuo on 6/22/14.
//  Copyright (c) 2014 tanshuo. All rights reserved.
//

#include "tool.h"


TC_ID genID()//always greater than 0, unique
{
    TC_ObjList iter;
    
    if(obj_num == 0)
        return 0;
    if(obj_num == 1)
        return 1;
    for(iter = objlist; iter->next != NULL; iter = iter->next)
    {
        if(iter->obj_id != iter->next->obj_id - 1)
        {
            return iter->obj_id + 1;
        }
    }
    
    return iter->obj_id + 1;
}

void initList()
{
    if(objlist == NULL)
    {
        objlist = (TC_ObjList)malloc(sizeof(struct objectlist));
        obj_num = 1;
        objlist->pre = NULL;
        objlist->next = NULL;
        objlist->obj_id = 0;
        strcpy(objlist->name, "root");
    }
}

void deleteList()
{
    free(objlist);
    objlist = NULL;
    obj_num = 0;
}

void addEntry(TC_ID obj_id, const char* name)
{
    TC_ObjList iter;
    TC_ObjList temp;
    TC_ObjList new_entry;
    
    if(obj_num == 0)
    {
        initList();
    }
    new_entry = (TC_ObjList)malloc(sizeof(struct objectlist));
    if(new_entry == NULL)
    {
        printf("Can not add more game object\n");
        return;
    }
    new_entry->obj_id = obj_id;
    strcpy(new_entry->name, name);
    for(iter = objlist; iter != NULL; iter = iter->next)
    {
        if(iter->obj_id < obj_id)
        {
            temp = iter->next;
            new_entry->pre = iter;
            new_entry->next = temp;
            iter->next = new_entry;
            if(temp)
                temp->pre = new_entry;
            break;
        }
    }
    obj_num++;
}

void deleteEntryByID(TC_ID obj_id)
{
    TC_ObjList iter;
    TC_ObjList left;
    TC_ObjList right;
    if(obj_id < 1)
    {
        printf("wrong id!\n");
        return;
    }
    for(iter = objlist; iter != NULL; iter = iter->next)
    {
        if(iter->obj_id == obj_id)
        {
            obj_num--;
            left = iter->pre;
            right = iter->next;
            free(iter);
            left->next = right;
            right->pre = left;
            break;
        }
    }
}

TC_ID findIDByName(char* name)
{
    TC_ObjList iter;
    for(iter = objlist; iter != NULL; iter = iter->next)
    {
        if(strcmp(iter->name, name) == 0)
        {
            return iter->obj_id;
        }
    }
    return 0;
}
