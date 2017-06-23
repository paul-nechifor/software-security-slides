#include <stdio.h>
#include "common.c"

void trace_proc(pid_t pid, void *data) {
    char buf[0x1000];
    struct user_regs_struct regs;
    int inject_point = *(int*) data;
    int total;
    
    read_stdin_to_buf(buf, sizeof(buf), &total);
    put_data(pid, inject_point, buf, total);
        
    ptrace(PTRACE_GETREGS, pid, NULL, &regs);
    
    // Clean up some registers.
    regs.eax = regs.ebx = regs.ecx = regs.edx = 0;
    
    // Change the instruction pointer to the injection entry point.
    regs.eip = inject_point;
    
    ptrace(PTRACE_SETREGS, pid, NULL, &regs);
}

int main(int argc, char *argv[]) {
    if (argc < 3) {
        die("Missing args.");
    }
    
    pid_t pid = atoi(argv[1]);
    int inject_point = strtol(argv[2], NULL, 16);
    
    wrap_attach_proc(pid, trace_proc, &inject_point);
    
    return 0;
}
