.code64
.intel_syntax noprefix

.equ FUTEX_WAIT,1
.equ FUTEX_WAKE,0

.equ CLONE_THREAD,0x00010000
.equ CLONE_FS,0x00000200
.equ CLONE_VM,0x00000100
.equ CLONE_FILES,0x00000400
.equ CLONE_SIGHAND,0x00000800

.section .rodata
.section .data
    static_atomic_arc:  .quad 0

.section .bss
    static_buffer_arc: .quad 0
    static_buffer_counter: .quad 0

.section .text

.global mut_lock
.global mut_unlock

.global atomic_store
.global atomic_load

atomic_store:

    push rbp
    mov rbp,rsp
    
    mov rax,rdi
    lock xchg QWORD ptr [rsi],rax
    
    leave
    ret

atomic_load:

    push rbp
    mov rbp,rsp
    
    lock xchg rax,QWORD ptr [rdi]

    leave
    ret

mut_lock:

    push rbp
    mov rbp,rsp
    
    push r12
    push rbx
    
    xor r12,r12
    
    mov rbx,rdi
    
mut_lock.iter:

    xor rax,rax
    mov r12,1
    lock cmpxchg QWORD ptr [rbx],r12
    mfence
    je mut_lock.done
    
    mov rax,202
    lea rdi,[rbx]
    mov rsi,0 | 0x80
    mov rdx,1
    xor r10,r10
    xor r8,r8
    syscall
    
    jmp mut_lock.iter

mut_lock.done:

    pop rbx
    pop r12

    leave
    ret
    
mut_unlock:

    push rbp
    mov rbp,rsp

    mov rax,0
    lock xchg QWORD ptr [rdi],rax
    mfence
    
    mov rax,202
    lea rdi,[rdi]
    mov rsi,1 | 0x80
    mov rdx,1
    xor r10,r10
    xor r8,r8
    syscall

    leave
    ret