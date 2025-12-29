.code64
.intel_syntax noprefix

.section .text

.global _strlen
.global _memcpy
.global print
.global _strcmp

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
    
    
    