
//  $Id: //depot/SwiftTrace/SwiftTrace/xt_forwarding_trampoline_x64.s#11 $

//  https://en.wikipedia.org/wiki/X86_calling_conventions

#if defined(__LP64__) && !defined(__arm64__)
.text
.align 12
tracer:
    .quad 0 // pointer to function to trace call
    // tracer instance stored at trampoline offset

.align 12
.globl _xt_forwarding_trampoline_page
.globl _xt_forwarding_trampolines_start
.globl _xt_forwarding_trampolines_next
.globl _xt_forwarding_trampolines_end

_xt_forwarding_trampoline_page:
_xt_forwarding_trampoline:
    popq    %r11    // pop trampoline return adddress
    pushq   %rdi    // push all registers used as paremters
    pushq   %rsi
    pushq   %rcx
    pushq   %rdx
    pushq   %r8
    pushq   %r9
    pushq   %r10
    pushq   %r12
    pushq   %r13    // Swift "call context" register for self
    pushq   %r14
    pushq   %r15
    pushq   %rax    // pointer for return of struct 
    pushq   %rbx
    pushq   %rbp
    movq    %rsp, %rbp
    subq    $72, %rsp   // make space for floating point regeisters and save
    movsd   %xmm0, -8(%rbp)
    movsd   %xmm1, -16(%rbp)
    movsd   %xmm2, -24(%rbp)
    movsd   %xmm3, -32(%rbp)
    movsd   %xmm4, -40(%rbp)
    movsd   %xmm5, -48(%rbp)
    movsd   %xmm6, -56(%rbp)
    movsd   %xmm7, -64(%rbp)
    subq    $4096+5, %r11   // find trampoline info relative to return address
    movq    (%r11), %rdi    // first argument is pointer to forwarding info
    leaq    tracer(%rip), %r11
    callq   *(%r11)          // call tracing routine
    movq    %rax, %r11       // pointer to original implementation returned
    movsd   -64(%rbp), %xmm7 // restore all registers
    movsd   -56(%rbp), %xmm6
    movsd   -48(%rbp), %xmm5
    movsd   -40(%rbp), %xmm4
    movsd   -32(%rbp), %xmm3
    movsd   -24(%rbp), %xmm2
    movsd   -16(%rbp), %xmm1
    movsd   -8(%rbp), %xmm0
    addq    $72, %rsp
    popq    %rbp
    popq    %rbx
    popq    %rax
    popq    %r15
    popq    %r14
    popq    %r13
    popq    %r12
    popq    %r10
    popq    %r9
    popq    %r8
    popq    %rdx
    popq    %rcx
    popq    %rsi
    popq    %rdi
    jmpq    *%r11   // forward onto original implementation
    nop
    nop
    nop
    nop
    nop
    nop
    nop

_xt_forwarding_trampolines_start:

// 508 trampoline entry points
callq _xt_forwarding_trampoline
nop
nop
nop
_xt_forwarding_trampolines_next:
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
nop
_xt_forwarding_trampolines_end:

#endif
