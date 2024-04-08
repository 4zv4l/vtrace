module ptrace

#include <sys/ptrace.h>
#include <sys/user.h>
struct C.user_regs_struct {
    orig_rax usize
    rax usize
    rdi usize
    rsi usize
    rdx usize
}
fn C.WIFSTOPPED(int) int
fn C.WSTOPSIG(int) int

// currently supported ptrace options
pub enum Ptrace_opt {
    trace_sys_good = C.PTRACE_O_TRACESYSGOOD
    exit_kill = C.PTRACE_O_EXITKILL
}

// become a tracee
pub fn trace_me() {
    C.ptrace(C.PTRACE_TRACEME, 0, 0, 0)
}

// set ptrace options
pub fn set_options(pid int, option Ptrace_opt) {
    C.ptrace(C.PTRACE_SETOPTIONS, pid, 0, option)
}

// breakpoint at next syscall entry/exit
pub fn syscall(pid int) {
    C.ptrace(C.PTRACE_SYSCALL, pid, 0, 0)
}

// wait for process to change state
pub fn wait(pid int) {
    C.waitpid(pid, 0, 0)
}

// wait for a syscall stop
pub fn wait_for_syscall(pid int) bool {
    status := 0
    for {
        syscall(pid)
        C.waitpid(pid, &status, 0)
        if C.WIFSTOPPED(status) > 0 && (C.WSTOPSIG(status) & 0x80) > 0 { return true }
        if C.WIFEXITED(status) { return false }
    }
    return false
}

// check if process is terminated
pub fn is_exited(status int) bool {
    return C.WIFEXITED(status)
}

// return the current process's registers content
pub fn get_regs(pid int) C.user_regs_struct {
    regs := C.user_regs_struct{}
    C.ptrace(C.PTRACE_GETREGS, pid, 0, &regs)
    return regs
}
