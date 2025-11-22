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
#import <LindChain/ProcEnvironment/Surface/proc/fetch.h>
#import <LindChain/ProcEnvironment/Surface/proc/def.h>

ksurface_error_t proc_for_pid(pid_t pid,
                              ksurface_proc_t **proc)
{
    if(proc == NULL) return kSurfaceErrorNullPtr;
    
    *proc = NULL;
    
    for(uint32_t i = 0; i < PROC_MAX; i++)
    {
        if(proc_retain(&(surface->proc_info.obj[i])))
        {
            unsigned long seq;
            do {
                seq = seqlock_read_begin(&(surface->proc_info.obj[i].seqlock));
                
                
            } while (seqlock_read_retry(&(surface->proc_info.obj[i].seqlock), seq));
            proc_release(&(surface->proc_info.obj[i]));
        }
    }
    
    return (*proc == NULL) ? kSurfaceErrorOutOfBounds : kSurfaceErrorSuccess;
}
