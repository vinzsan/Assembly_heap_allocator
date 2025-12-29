.code64
.intel_syntax noprefix

.equ FUTEX_WAIT,1
.equ FUTEX_WAKE,0

.section .rodata
.section .data
    static_atomic_arc:  .quad 0

.section .bss
    static_buffer_arc: .quad 0
    static_buffer_counter: .quad 0

.section .text

.global mutex_guard_lock
.global mutex_guard_unlock

.global atomic_store
.global atomic_load

#mutex_guard_lock:
#
#    push rbp
#    mov rbp,rsp
#
#    push r12
#    push r13
#
#    mov QWORD ptr [rip + static_buffer_counter],rdi
#    add QWORD ptr [rip + static_buffer_arc],1
#    
#    sub rsp,16
#    
#    lea r12,[rsp]
#    
#    mov QWORD ptr [r12],5
#    mov QWORD ptr [r12 + 8],0
#    
#    mov rax,202
#    lea rdi,[rip + static_buffer_arc]
#    mov rsi,0
#    mov rdx,[rip + static_buffer_counter]
#    mov r10,r12
#    syscall
#    
#    add QWORD ptr [rip + static_buffer_arc],1
#
#    add rsp,16
#
#    pop r13
#    pop r12
#
#    leave
#    ret
#
#mutex_guard_unlock:
#
#    push rbp
#    mov rbp,rsp
#
#    leave
#    ret
#
#atomic_load:
#
#    push rbp
#    mov rbp,rsp
#    
#    mov rax,[rip + static_atomic_arc]
#    xchg lock [rip + ]
#
#    leave
#    ret
#
#atomic_store:
#
#    push rbp
#    mov rbp,rsp
#    
#    xchg lock [rip + static_atomic_arc],rdi
#
#    leave
#    ret
#    