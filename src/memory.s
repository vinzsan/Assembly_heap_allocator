.code64
.intel_syntax noprefix

.equ STRUCT_SIZE, 24

.section .rodata
    L2: .string "_free() abort,deteksi double free\n"
        .string "instruksi ud2 di jalankan,exit program\n"

.section .note
    NOTE: .string "Belajar membuat heap allocator sederhana\n"

.section .data

.align 8

    HEAD: .quad 0   # pakai metadata like C
    TAIL: .quad 0

.align 8    

    # struct metadatanya
    # 
    # METADATA + 0 = flags
    # METADATA + 8 = size
    # METADATA + 16 = next struct

    HEAD_M: .quad 0
    TAIL_M: .quad 0

.section .text

.global virtual_map
.global free_map
.global _allocate
.global _free

   # sbrk() function sederhana untuk operasi aritmatika ptr

_sbrk:

    push rbp
    mov rbp,rsp

    push r12
    push r13
    
    push r14
    mov r14,rdi
    
    mov rax,12
    xor rdi,rdi
    syscall
    
    cmp rax,-1
    je _sbrk.err_signed
    
    mov r12,rax

    lea rdi,[r12 + r14]
    mov rax,12
    syscall
    
    cmp rax,-1
    je _sbrk.err_signed
    
    mov r13,rax
    
    cmp QWORD ptr [rip + HEAD],0
    jne _sbrk.non_null
    
    mov QWORD ptr [rip + HEAD],r12
    
_sbrk.non_null:

    mov QWORD ptr [rip + TAIL],r13
    
    mov rax,r12

    pop r14
    pop r13
    pop r12

    leave
    ret

_sbrk.err_signed:

    mov rax,-1

    pop r14
    pop r13
    pop r12

    leave
    ret

    # src_free_block() adalah function untuk mencari block metadata yang masih bisa
    # di reuse atau jika tidak maka buat block baru

_src_free_block:

    push rbp
    mov rbp,rsp
    
    push r12
    push r13 
    
    mov r12,rdi
    
    mov r13,QWORD ptr [rip + HEAD_M]
    
_src_free_block.iter:

    test r13,r13
    jz _src_free_block.done
    nop

_src_free_block.l01:

    mov rax,r13
    cmp QWORD ptr [rax],0
    je _src_free_block.l02

_src_free_block.l02:

    mov rax,r13
    cmp QWORD ptr [rax + 8],r12
    jle _src_free_block.next_block
    
    mov rax,r13

    pop r13
    pop r12
    
    leave

    ret

    ud2

_src_free_block.next_block:

    mov rax,r13
    
    mov r13,[rax + 16]
    
    jmp _src_free_block.iter
    
_src_free_block.done:

    xor rax,rax

    pop r13
    pop r12

    leave
    ret

    # allocate() adalah function untuk mengalokasikan block data
    # allocate menggunakan linked list untuk modelnya
    
_allocate:

    push rbp
    mov rbp,rsp
    sub rsp,16
    
    push r12
    push r13
    push rbx

    # simpan sizenya di stack biar keliatan buth,sebenernya bisa di r14/dll
    mov QWORD ptr [rbp - 8],rdi
    call _src_free_block
    
    test rax,rax

    mov r12,rax

    jz _allocate.new_block_created
    
    mov QWORD ptr [r12],0
    lea rax,[r12 + STRUCT_SIZE]
    
    jmp _allocate.end
    
    int3
    hlt

_allocate.new_block_created:

    mov rdi,QWORD ptr [rbp - 8]
    add rdi,24
    call _sbrk
    
    test rax,rax
    jz _allocate.null

    mov r13,rax
    
    xor rdx,rdx

    mov rax,r13
    mov QWORD ptr [rax],rdx
    
    mov rax,r13
    mov rdi,QWORD ptr [rbp - 8]
    mov QWORD ptr [rax + 8],rdi
    
    mov rax,r13
    mov QWORD ptr [rax + 16],rdx
    
_allocate.l01:

    cmp QWORD ptr [rip + HEAD_M],0
    jne _allocate.e01

    mov QWORD ptr [rip + HEAD_M],r13
    mov QWORD ptr [rip + TAIL_M],r13
    
    lea rax,[r13 + STRUCT_SIZE]
    jmp _allocate.end
    
    int3

_allocate.e01:

    mov rax,QWORD ptr [rip + TAIL_M]
    mov QWORD ptr [rax + 16],r13

    mov QWORD ptr [rip + TAIL_M],r13
    
    lea rax,[r13 + STRUCT_SIZE]
    jmp _allocate.end
    
_allocate.null:

    xor rax,rax
    jmp _allocate.end
    
    ud2

_allocate.end:

    pop rbx
    pop r13
    pop r12

    leave
    ret

    hlt
    
_free:

    push rbp
    mov rbp,rsp
    
    test rdi,rdi
    jz _free.done

    mov rax,rdi
    
    lea rsi,[rax - STRUCT_SIZE]

    cmp QWORD ptr [rsi],1 # FLAGS free is 1
    je _free.twice
    
    mov QWORD ptr [rsi],1
    
    jmp _free.done

_free.twice:

    lea rdi,[rip + L2]
    call print

    lea rdi,[rip + L2 + 35]
    call print

    ud2
    hlt

_free.done:

    xor rax,rax

    leave
    ret

virtual_map:

    push rbp
    mov rbp,rsp
    
    mov rsi,rdi
    
    mov rax,9
    xor rdi,rdi
    mov rdx,0x02
    mov r10,0x22
    mov r8,-1
    xor r9,r9
    syscall

    leave
    ret

free_map:

    push rbp
    mov rbp,rsp

    sub rsp,16
    
    mov QWORD ptr [rbp - 8],rdi
    
    cmp rdi,-1
    jle free_map.null
    
    mov rax,11
    mov rdi,QWORD ptr [rbp - 8]
    syscall
    
    jmp free_map.done
    
free_map.null:

    leave

    ud2

free_map.done:

    leave
    ret
    
#   End Memory alloc

_memory_alloc:

