import os
import ptrace
import seccomp

fn main() {
    if os.args.len < 2 {
        eprintln("usage: ${os.args[0]} cmd args...")
        return
    }

    pid := os.fork()
    mut process_alive := true
    match pid {
        -1 { // error
            eprintln("fork(): ${os.last_error().msg()}")
        }
        0 { // child
            ptrace.trace_me()
            C.kill(C.getpid(), C.SIGSTOP)
            os.execvp(os.args[1], os.args[2..])
                or { eprintln("execvp(${os.args[1]}): ${os.last_error().msg()}") }
        }
        else { // parent
            ptrace.wait(pid)
            ptrace.set_options(pid, .trace_sys_good)
            ptrace.set_options(pid, .exit_kill)
            C.ptrace(C.PTRACE_SETOPTIONS, pid, 0, C.PTRACE_O_TRACESYSGOOD)
            for process_alive {
                // before syscall
                if !ptrace.wait_for_syscall(pid) { break }
                mut regs := ptrace.get_regs(pid)
                println("${seccomp.syscall_resolve_num(regs.orig_rax)}")

                // after syscall
                if !ptrace.wait_for_syscall(pid) { process_alive = false }
                regs = ptrace.get_regs(pid)
                println("=> ${regs.rax}")
            }
        }
    }
}
