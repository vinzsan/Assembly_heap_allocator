.code64
.intel_syntax noprefix

.include "./include/module.inc"

.section .rodata
    L1: .string "Hello world\n"
    
    L02: .string "Nemgroes"
    L3: .string "Nemgroes"

    L4: .asciz "Tidak sama\n"
    L5:  .asciz "Sama\n"

.section .bss
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

    leave

    mov rax,231
    xor rdi,rdi
    syscall
