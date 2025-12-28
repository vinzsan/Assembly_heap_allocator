.code64
.intel_syntax noprefix

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
    