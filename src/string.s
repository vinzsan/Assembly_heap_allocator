.code64
.intel_syntax noprefix

.equ STATIC_BLOCK_ITOA_NEG, 15

.section .bss
    static_itoa_reserve: .skip 32

.section .text

.global _strlen
.global _memcpy
.global print
.global _strcmp
.global _itoa

_itoa:

    push rbp
    mov rbp,rsp

    push r12
    xor rcx,rcx
    
    mov rax,rdi

    lea r12,[rip + static_itoa_reserve + STATIC_BLOCK_ITOA_NEG]
    mov BYTE ptr [r12],0
    
    test rsi,rsi
    jz _itoa.skip_endl
    mov BYTE ptr [r12 + 1],'\n'

_itoa.skip_endl:

    mov rcx,10
    
_itoa.iter:

    xor rdx,rdx
    div rcx
    add dl,'0'
    mov BYTE ptr [r12],dl
    dec r12
    test al,al
    
    jz _itoa.end
    jmp _itoa.iter

_itoa.end:

    inc r12
    mov rax,r12

    pop r12

    leave
    ret

_strcmp:

    push rbp
    mov rbp,rsp

_strcmp.iter:

    mov al,[rdi]
    mov dl,[rsi]
    cmp al,dl
    jnz _strcmp.not_equal
    test al,al
    jz _strcmp.equal
    inc rdi
    inc rsi
    jmp _strcmp.iter

_strcmp.equal:

    xor rax,rax
    jmp _strcmp.done

_strcmp.not_equal:

    mov rax,1

_strcmp.done:

    leave
    ret

_strlen:

    xor rcx,rcx

_strlen.iter:

    cmp BYTE ptr [rcx + rdi],0
    je _strlen.done
    inc rcx
    jmp _strlen.iter

_strlen.done:

    mov rax,rcx
    ret

_memcpy:

    push rbp
    mov rbp,rsp
    
_memcpy.iter:

    mov al,[rdi]
    mov BYTE ptr [rsi],al
    test al,al
    jz _memcpy.done
    inc rdi
    inc rsi
    jmp _memcpy.iter

_memcpy.done:

    xor rax,rax

    leave
    ret

_strncpy:

    push rbp
    mov rbp,rsp

    xor rcx,rcx
    mov rcx,rdx
    
_strncpy.iter:

    mov al,[rdi]
    mov BYTE ptr [rsi],al
    test rcx,rcx
    jz _strncpy.done

    inc rdi
    inc rsi
    dec rcx
    
    jmp _strncpy.iter

_strncpy.done:

    mov rax,rsi

    leave
    ret

print:

    push rbp
    mov rbp,rsp
    
    call _strlen
    mov rdx,rax
    
    mov rsi,rdi
    mov rdi,1
    mov rax,1
    syscall

    leave
    ret
    
    
    