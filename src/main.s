.code64
.intel_syntax noprefix

.include "./include/module.inc"

.section .rodata
    L1: .string "Hello world\n"
    
    L02: .string "Nemgroes"
    L3: .string "Nemgroes"

    L4: .asciz "Tidak sama\n"
    L5:  .asciz "Sama\n"

    L6: .string "Hello from thread\n"
    L7: .string "Hello from main\n"

.section .data
    futex_locker: .quad 0
    thread_join: .quad 0
    
    timeval: .quad 2
    thread_tv: .quad 2

.section .bss
    thread_map: .quad 0
.section .text

.global _start

function1:

    push rbp
    mov rbp,rsp
    
    lea rdi,[rip + L02]
    lea rsi,[rip + L3]
    call _strcmp
    
    test rax,rax
    jnz function1.not_equal
    
    lea rdi,[rip + L5]
    call print

    jmp function1.end

function1.not_equal:

    lea rdi,[rip + L4]    
    call print

function1.end:

    xor rax,rax

    leave
    ret
    
function2:

    push rbp
    mov rbp,rsp
    sub rsp,32
    
    mov rdi,10
    lea rsi,[rbp - 16]
    call atomic_store
    

    lea rdi,[rbp - 16]
    call atomic_load

    mov rdi,rax
    mov rsi,1
    call _itoa
    
    mov rsi,rax
    mov rdi,1
    mov rax,1
    mov rdx,2
    syscall
    
    leave
    ret
    
function3:

    push rbp
    mov rbp,rsp
    sub rsp,32

    push rbx
    
    mov rdi,32
    call _allocate

    mov rbx,rax
    
    xor rax,rax
    xor rdi,rdi
    mov rsi,rbx
    mov rdx,64
    syscall
    
    mov QWORD ptr [rbp - 32],rax
    
    mov rax,1
    mov rdi,1
    mov rsi,rbx
    mov rdx,QWORD ptr [rbp - 32]
    syscall
    
    mov rdi,rbx
    call _free

    leave
    ret
    
#-----------------------

#----------------------
    
function.thread1:

    push rbp
    mov rbp,rsp

    push r12
    
    xor r12,r12
    
function.thread1.iter:

    cmp r12,10
    je function.thread1.done
    
    lea rdi,[rip + futex_locker]
    call mut_lock

    lea rdi,[rip + L6]
    call print
    inc r12

    lea rdi,[rip + futex_locker]
    call mut_unlock
    
    jmp function.thread1.iter

function.thread1.done:

    pop r12
    
    mov QWORD ptr [rip + thread_join],1
    
    mov rax,202
    lea rdi,[rip + thread_join]
    mov rsi,1 | 0x80
    mov rdx,1
    xor r10,r10
    xor r8,r8
    syscall

    leave
    ret
    
function4:

    push rbp
    mov rbp,rsp

    push rbx
    push r13

    mov rax,9
    xor rdi,rdi
    mov rsi,1024 * 8
    mov rdx,0x02
    mov r10,0x22 | 0x20000
    mov r8,-1
    xor r9,r9
    syscall
    
    mov r13,rax
    
    sub rsp,88
    
    lea rbx,[rsp]
    
    mov QWORD ptr [rbx],0x00000100 | 0x00000200 | 0x00000400 | 0x00000800 | 0x00010000
    mov QWORD ptr [rbx + 4 * 8],0
    mov QWORD ptr [rbx + 5 * 8],r13
    mov QWORD ptr [rbx + 6 * 8],1024 * 8
    
    mov rax,435
    mov rdi,rbx
    mov rsi,88
    syscall
    
    test rax,rax
    js function4.end
    jz function4.thread_create
    jmp function4.parents

function4.thread_create:

    lea rsp,[r13 + (1024 * 8)]

    call function.thread1
    
    mov rax,60
    xor rdi,rdi
    syscall

function4.parents:
    
    xor r14,r14

function4.iter_loop:

    cmp r14,10
    je function4.joinable
    
    lea rdi,[rip + futex_locker]
    call mut_lock

    lea rdi,[rip + L7]
    call print

    inc r14
    
    lea rdi,[rip + futex_locker]
    call mut_unlock

    jmp function4.iter_loop
    
function4.joinable:

    cmp QWORD ptr [rip + thread_join],1
    je function4.end
    
    mov rax,202
    lea rdi,[rip + thread_join]
    mov rsi,1 | 0x80
    mov rdx,1
    xor r10,r10
    xor r8,r8
    syscall

    jmp function4.joinable

function4.end:

    add rsp,88
    
    mov rax,11
    mov rdi,r13
    mov rsi,1024 * 8
    syscall

    leave
    ret

_start:

    and rsp,0xFFFFFFFFFFFFFFFF
    xor rbp,rbp

    push rbp
    mov rbp,rsp
    sub rsp,16
    
    mov rdi,1024
    call _allocate
    
    mov rdi,rax
    call _free

    mov rdi,32
    call _allocate

    mov r12,rax

    # test double free

    # mov rdi,r12
    # call _free
    
    # test memcpy
    
    lea rdi,[rip + L1]
    mov rsi,r12
    call _memcpy
    
    mov rdi,r12
    call print
    
    mov rdi,r12
    call _free
    
    mov rdi,1024
    call virtual_map
    
    mov rdi,rax
    call free_map

    call function1
    
    mov QWORD ptr [rbp - 8],'\n'
    mov QWORD ptr [rbp - 8 + 1],0

    lea rdi,[rbp - 8]
    call print

    #call function3
    
    call function4

    leave

    mov rax,231
    xor rdi,rdi
    syscall
