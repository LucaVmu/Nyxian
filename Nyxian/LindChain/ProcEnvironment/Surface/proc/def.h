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

#ifndef PROC_DEF_H
#define PROC_DEF_H

/// Helper macros
#define proc_getpid(obj) (obj)->proc.bsd.kp_proc.p_pid
#define proc_getppid(obj) (obj)->proc.bsd.kp_eproc.e_ppid
#define proc_getentitlements(obj) (obj)->proc.nyx.entitlements

#define proc_setpid(obj, pid) (obj)->proc.bsd.kp_proc.p_pid = pid
#define proc_setppid(obj, ppid) (obj)->proc.bsd.kp_proc.p_oppid = ppid; (obj)->proc.bsd.kp_eproc.e_ppid = ppid; (obj)->proc.bsd.kp_eproc.e_pgid = ppid
#define proc_setentitlements(obj, entitlement) (obj)->proc.nyx.entitlements = entitlement

/// UID Helper macros
#define proc_getuid(obj) (obj)->proc.bsd.kp_eproc.e_ucred.cr_uid
#define proc_getruid(obj) (obj)->proc.bsd.kp_eproc.e_pcred.p_ruid
#define proc_getsvuid(obj) (obj)->proc.bsd.kp_eproc.e_pcred.p_svuid

#define proc_setuid(obj, uid) (obj)->proc.bsd.kp_eproc.e_ucred.cr_uid = uid
#define proc_setruid(obj, ruid) (obj)->proc.bsd.kp_eproc.e_pcred.p_ruid = ruid
#define proc_setsvuid(obj, svuid) (obj)->proc.bsd.kp_eproc.e_pcred.p_svuid = svuid

/// GID Helper macros
#define proc_getgid(obj) (obj)->proc.bsd.kp_eproc.e_ucred.cr_groups[0]
#define proc_getrgid(obj) (obj)->proc.bsd.kp_eproc.e_pcred.p_rgid
#define proc_getsvgid(obj) (obj)->proc.bsd.kp_eproc.e_pcred.p_svgid

#define proc_setgid(obj, gid) (obj)->proc.bsd.kp_eproc.e_ucred.cr_groups[0] = gid
#define proc_setrgid(obj, rgid) (obj)->proc.bsd.kp_eproc.e_pcred.p_rgid = rgid
#define proc_setsvgid(obj, svgid) (obj)->proc.bsd.kp_eproc.e_pcred.p_svgid = svgid

#define pid_is_launchd(pid) pid == 1

#define PID_LAUNCHD 1

#define proc_cpy(a,b) memcpy(&a, &b, sizeof(ksurface_proc_t))

#define _kernel_proc_obj &(surface->proc_info.obj[0])

#endif /* PROC_DEF_H */
