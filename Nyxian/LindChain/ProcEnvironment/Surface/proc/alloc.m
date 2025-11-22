/*
 Copyright (C) 2025 cr4zyengineer

 This file is part of Nyxian.

 Nyxian is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 Nyxian is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with Nyxian. If not, see <https://www.gnu.org/licenses/>.
*/

#import <LindChain/ProcEnvironment/Surface/proc/alloc.h>

bool proc_retain(ksurface_proc_obj_t *obj)
{
    if(!__atomic_load_n(&obj->inUse, __ATOMIC_ACQUIRE))
    {
        return false;
    }
    __atomic_add_fetch(&obj->refcnt, 1, __ATOMIC_ACQ_REL);
    if(!__atomic_load_n(&obj->inUse, __ATOMIC_ACQUIRE))
    {
        proc_release(obj);
        return false;
    }
    return true;
}

bool proc_release(ksurface_proc_obj_t *obj)
{
    unsigned long old = __atomic_fetch_sub(&obj->refcnt, 1, __ATOMIC_ACQ_REL);
    if(old == 1)
    {
        obj->inUse = false;
        memset((void*)&obj->proc, 0, sizeof(obj->proc));
        return true;
    }
    return false;
}

ksurface_error_t proc_alloc(ksurface_proc_obj_t **obj)
{
    if (!obj) return kSurfaceErrorNullPtr;
    *obj = NULL;
    
    for (uint32_t i = 0; i < PROC_MAX; i++)
    {
        ksurface_proc_obj_t *nobj = &surface->proc_info.obj[i];
        bool expected = false;
        if(__atomic_compare_exchange_n(&nobj->inUse, &expected, true, false, __ATOMIC_ACQ_REL, __ATOMIC_ACQUIRE))
        {
            __atomic_store_n(&nobj->refcnt, 1, __ATOMIC_RELEASE);
            seqlock_lock(&nobj->seqlock);
            memset((void*)&nobj->proc, 0, sizeof(nobj->proc));
            *obj = nobj;
            return kSurfaceErrorSuccess;
        }
    }
    
    return kSurfaceErrorOutOfBounds;
}
