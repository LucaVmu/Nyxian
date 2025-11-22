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

#import <LindChain/ProcEnvironment/Surface/proc/new.h>
#import <LindChain/ProcEnvironment/Surface/proc/def.h>
#import <LindChain/ProcEnvironment/Surface/proc/fetch.h>
#import <LindChain/ProcEnvironment/Surface/proc/alloc.h>

ksurface_error_t proc_new_proc(pid_t pid,
                               uid_t uid,
                               gid_t gid,
                               NSString *executablePath,
                               PEEntitlement entitlement,
                               ksurface_proc_obj_t **obj)
{
    ksurface_error_t error = proc_alloc(obj);
    if(error != kSurfaceErrorSuccess)
    {
        return error;
    }
    
    // Set ksurface_proc properties
    (*obj)->proc.parent = _kernel_proc_obj;
    (*obj)->proc.children.children_cnt = 0;
    (*obj)->proc.children.children_cnt = 0;
    (*obj)->proc.nyx.force_task_role_override = true;
    (*obj)->proc.nyx.task_role_override = TASK_UNSPECIFIED;
    (*obj)->proc.nyx.entitlements = entitlement;
    strncpy((*obj)->proc.nyx.executable_path, [[[NSURL fileURLWithPath:executablePath] path] UTF8String], PATH_MAX);
    
    // Set bsd process stuff
    if(gettimeofday(&(*obj)->proc.bsd.kp_proc.p_un.__p_starttime, NULL) != 0)
    {
        seqlock_unlock(&((*obj)->seqlock));
        return kSurfaceErrorUndefined;
    }
    (*obj)->proc.bsd.kp_proc.p_flag = P_LP64 | P_EXEC;
    (*obj)->proc.bsd.kp_proc.p_stat = SRUN;
    (*obj)->proc.bsd.kp_proc.p_pid = pid;
    (*obj)->proc.bsd.kp_proc.p_oppid = proc_getppid(_kernel_proc_obj);
    (*obj)->proc.bsd.kp_proc.p_priority = PUSER;
    (*obj)->proc.bsd.kp_proc.p_usrpri = PUSER;
    strncpy((*obj)->proc.bsd.kp_proc.p_comm, [[[NSURL fileURLWithPath:executablePath] lastPathComponent] UTF8String], MAXCOMLEN + 1);
    (*obj)->proc.bsd.kp_proc.p_acflag = 2;
    (*obj)->proc.bsd.kp_eproc.e_pcred.p_ruid = uid;
    (*obj)->proc.bsd.kp_eproc.e_pcred.p_svuid = uid;
    (*obj)->proc.bsd.kp_eproc.e_pcred.p_rgid = gid;
    (*obj)->proc.bsd.kp_eproc.e_pcred.p_svgid = gid;
    (*obj)->proc.bsd.kp_eproc.e_ucred.cr_ref = 5;
    (*obj)->proc.bsd.kp_eproc.e_ucred.cr_uid = uid;
    (*obj)->proc.bsd.kp_eproc.e_ucred.cr_ngroups = 4;
    (*obj)->proc.bsd.kp_eproc.e_ucred.cr_groups[0] = gid;
    (*obj)->proc.bsd.kp_eproc.e_ucred.cr_groups[1] = 250;
    (*obj)->proc.bsd.kp_eproc.e_ucred.cr_groups[2] = 286;
    (*obj)->proc.bsd.kp_eproc.e_ucred.cr_groups[3] = 299;
    (*obj)->proc.bsd.kp_eproc.e_ppid = proc_getppid(_kernel_proc_obj);
    (*obj)->proc.bsd.kp_eproc.e_pgid = proc_getppid(_kernel_proc_obj);
    (*obj)->proc.bsd.kp_eproc.e_tdev = -1;
    (*obj)->proc.bsd.kp_eproc.e_flag = 2;
    
    seqlock_unlock(&((*obj)->seqlock));
    
    return kSurfaceErrorSuccess;
}

ksurface_error_t proc_new_child_proc(ksurface_proc_obj_t *parent,
                                     pid_t pid,
                                     NSString *executablePath,
                                     ksurface_proc_obj_t **obj)
{
    ksurface_error_t error = proc_alloc(obj);
    if(error != kSurfaceErrorSuccess)
    {
        return error;
    }
    
    seqlock_lock(&(parent->seqlock));
    
    unsigned long idx = parent->proc.children.children_cnt;
    if(!(idx < CHILD_PROC_MAX))
    {
        seqlock_unlock(&((*obj)->seqlock));
        seqlock_unlock(&(parent->seqlock));
        return kSurfaceErrorOutOfBounds;
    }
    
    parent->proc.children.children_proc[idx] = *obj;                    /* New process gets referenced into parent */
    parent->proc.children.children_cnt++;
    (*obj)->proc.parent = parent;                                       /* Parent process gets referenced into new process */
    
    proc_retain(parent);
    proc_retain(*obj);
    
    // Copy parent structure to child to inherite properties 1:1
    memcpy(&((*obj)->proc.bsd), &((parent)->proc.bsd), sizeof(kinfo_proc_t));
    
    // Reset time to now
    if(gettimeofday(&((*obj)->proc.bsd.kp_proc.p_un.__p_starttime), NULL) != 0)
    {
        seqlock_unlock(&((*obj)->seqlock));
        seqlock_unlock(&(parent->seqlock));
        return kSurfaceErrorUndefined;
    }
    
    // Overwriting executable path
    strncpy((*obj)->proc.nyx.executable_path, [[[NSURL fileURLWithPath:executablePath] path] UTF8String], PATH_MAX);
    strncpy((*obj)->proc.bsd.kp_proc.p_comm, [[[NSURL fileURLWithPath:executablePath] lastPathComponent] UTF8String], MAXCOMLEN + 1);
    
    // Patching the old process structure we copied out of the process table
    proc_setppid(*obj, proc_getppid(parent));
    proc_setpid(*obj, pid);
    proc_setentitlements(*obj, proc_getentitlements(parent));
    
    seqlock_unlock(&((*obj)->seqlock));
    seqlock_unlock(&(parent->seqlock));
    
    return kSurfaceErrorSuccess;
}
