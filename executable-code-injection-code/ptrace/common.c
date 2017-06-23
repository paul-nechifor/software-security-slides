#include <string.h>
#include <stdlib.h>
#include <sys/ptrace.h>
#include <sys/user.h>
#include <errno.h>
#include <unistd.h>

#define die(msg, ...) {                                                        \
    fprintf(stderr, msg "\n", ## __VA_ARGS__);                                 \
    exit(EXIT_SUCCESS);                                                        \
}

union four_bytes {
    long val;
    char chars[4];
};

void get_data(pid_t pid, long addr, char *str, int len) {
    char *laddr;
    int i, end, left;
    union four_bytes data;
    
    laddr = str;
    for (i = 0, end = len/4; i < end; i++) {
        data.val = ptrace(PTRACE_PEEKDATA, pid, addr + i * 4, NULL);
        memcpy(laddr, data.chars, 4);
        laddr += 4;
    }
    
    left = len % 4;
    if (left != 0) {
        data.val = ptrace(PTRACE_PEEKDATA, pid, addr + i * 4, NULL);
        memcpy(laddr, data.chars, left);
    }
}

void put_data(pid_t child, long addr, char *str, int len) {
    char *laddr;
    int i, end, left;
    union four_bytes data;
    
    laddr = str;
    for (i = 0, end = len/4; i < end; i++) {
        memcpy(data.chars, laddr, 4);
        ptrace(PTRACE_POKEDATA, child, addr + i * 4, data.val);
        laddr += 4;
    }
    
    left = len % 4;
    if (left != 0) {
        memcpy(data.chars, laddr, left);
        ptrace(PTRACE_POKEDATA, child, addr + i * 4, data.val);
    }
}

void wrap_attach_proc(pid_t pid, void (*func)(pid_t, void*), void *data) {
    long ret;
    
    ret = ptrace(PTRACE_ATTACH, pid, NULL, NULL);
    if (ret != 0) {
        die("Couldn't attach to process.");
    }
    
    // Wait for process to stop.
    waitpid(pid, NULL, WUNTRACED);
    
    func(pid, data);
    
    // Detach so that the process can continue.
    ret = ptrace(PTRACE_DETACH, pid, NULL, NULL);
    if (ret != 0) {
        die("Couldn't detach from process.");
    }
}

void read_stdin_to_buf(char buf[], int max_size, int *size) {
    ssize_t nread;
    int total = 0;

    while ((nread = read(STDIN_FILENO, buf + total, max_size - total)) > 0) {
        total += nread;
    }
    
    *size = total;
}

