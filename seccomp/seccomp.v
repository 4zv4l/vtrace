module seccomp

#flag -lseccomp
#include <seccomp.h>

fn C.seccomp_syscall_resolve_num_arch(int, int) charptr

pub fn syscall_resolve_num(syscall usize) string {
    cstr := C.seccomp_syscall_resolve_num_arch(C.SCMP_ARCH_NATIVE, syscall)
    return unsafe{ cstr.vstring() }
}
