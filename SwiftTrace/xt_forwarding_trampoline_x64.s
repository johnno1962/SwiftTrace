
//  $Id: //depot/SwiftTrace/SwiftTrace/xt_forwarding_trampoline_x64.s#8 $

#if defined(__LP64__) && !defined(__arm64__)
.text
.align 12
tracer:
    .quad 0

.align 12
.globl _xt_forwarding_trampoline_page
.globl _xt_forwarding_trampolines_start
.globl _xt_forwarding_trampolines_next
.globl _xt_forwarding_trampolines_end

_xt_forwarding_trampoline_page:
_xt_forwarding_trampoline:
    popq    %rax    // pop return adddress
    pushq   %rdi    // push all registers used as paremters
    pushq   %rsi
    pushq   %rdx
    pushq   %rcx
    pushq   %r8
    pushq   %r9
    pushq   %rbp
    movq    %rsp, %rbp
    subq    $64, %rsp   // make space for floating point regeisters and save
    movsd   %xmm0, -8(%rbp)
    movsd   %xmm1, -16(%rbp)
    movsd   %xmm2, -24(%rbp)
    movsd   %xmm3, -32(%rbp)
    movsd   %xmm4, -40(%rbp)
    movsd   %xmm5, -48(%rbp)
    movsd   %xmm6, -56(%rbp)
    movsd   %xmm7, -64(%rbp)
    subq    $4096+5, %rax   // frind trampoline info relative to return address
    movq    (%rax), %rdi    // first argument is pointer to forwarding info
    leaq    tracer(%rip), %rax
    callq   *(%rax)          // call tracing routine
    movsd   -64(%rbp), %xmm7 // restore all registers
    movsd   -56(%rbp), %xmm6
    movsd   -48(%rbp), %xmm5
    movsd   -40(%rbp), %xmm4
    movsd   -32(%rbp), %xmm3
    movsd   -24(%rbp), %xmm2
    movsd   -16(%rbp), %xmm1
    movsd   -8(%rbp), %xmm0
    addq    $64, %rsp
    popq    %rbp
    popq    %r9
    popq    %r8
    popq    %rcx
    popq    %rdx
    popq    %rsi
    popq    %rdi
    jmpq    *%rax   // forward onto original implementation
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
callq _xt_forwarding_trampoline
nop
nop
nop
callq _xt_forwarding_trampoline
nop
nop
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