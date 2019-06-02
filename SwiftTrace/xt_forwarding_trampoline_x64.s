
//  $Id: //depot/SwiftTrace/SwiftTrace/xt_forwarding_trampoline_x64.s#27 $

//  https://en.wikipedia.org/wiki/X86_calling_conventions

#if defined(__LP64__) && !defined(__arm64__)
.text
.align 12
onEntry:
    .quad 0 // pointer to function to trace call
onExit:
    .quad 0 // pointer to function to trace call
    // tracer instance stored at trampoline offset

.align 12
.globl _xt_forwarding_trampoline_page
.globl _xt_forwarding_trampolines_start
.globl _xt_forwarding_trampolines_next
.globl _xt_forwarding_trampolines_end

_xt_forwarding_trampoline_page:
_xt_forwarding_trampoline:
    pushq   %rbx
    pushq   %rax    // pointer for return of struct
    pushq   %r9     // push all registers used as paremters
    pushq   %r8
    pushq   %rcx
    pushq   %rdx
    pushq   %rsi
    pushq   %rdi
    pushq   %r15
    pushq   %r14
    pushq   %r13    // Swift "call context" register for self
    pushq   %r12
    pushq   %r10
    pushq   %rbp
    movq    %rsp, %rbp
    subq    $64, %rsp   // make space for floating point regeisters and save
    movsd   %xmm7, -8(%rbp)
    movsd   %xmm6, -16(%rbp)
    movsd   %xmm5, -24(%rbp)
    movsd   %xmm4, -32(%rbp)
    movsd   %xmm3, -40(%rbp)
    movsd   %xmm2, -48(%rbp)
    movsd   %xmm1, -56(%rbp)
    movsd   %xmm0, -64(%rbp)
    movq    112(%rbp), %r11 // recover trampoline return address
    subq    $4096+5, %r11   // find trampoline info relative to return address
    movq    (%r11), %rdi    // first argument is pointer to forwarding info
    movq    120(%rbp), %rsi // recover original return address
    movq    %rsp, %rdx      // pass through stack
    leaq    onEntry(%rip), %r11
    callq   *(%r11)          // call tracing entry routine (saves return address)
    leaq    returning(%rip), %r11
    movq    %r11, 120(%rbp)  // patch return address to "returning" code
    movq    %rax, %r11       // pointer to original implementation returned
    movsd   -64(%rbp), %xmm0 // restore all registers
    movsd   -56(%rbp), %xmm1
    movsd   -48(%rbp), %xmm2
    movsd   -40(%rbp), %xmm3
    movsd   -32(%rbp), %xmm4
    movsd   -24(%rbp), %xmm5
    movsd   -16(%rbp), %xmm6
    movsd   -8(%rbp), %xmm7
    addq    $64, %rsp
    popq    %rbp
    popq    %r10
    popq    %r12
    popq    %r13
    popq    %r14
    popq    %r15
    popq    %rdi
    popq    %rsi
    popq    %rdx
    popq    %rcx
    popq    %r8
    popq    %r9
    popq    %rax
    popq    %rbx
    addq    $8, %rsp // remove trampoline return address
    jmpq    *%r11   // forward onto original implementation

returning:
    pushq   %rbx
    pushq   %r9
    pushq   %r8     // push regs used for int returns
    pushq   %rcx
    pushq   %rdx
    pushq   %rax    // pointer for return of struct
    pushq   %rsi
    pushq   %rdi
    pushq   %r15
    pushq   %r14
    pushq   %r13    // Swift "call context" register for self
    pushq   %r12
    pushq   %r10
    pushq   %rbp
    movq    %rsp, %rbp
    subq    $64, %rsp   // make space for floating point regeisters and save
    movsd   %xmm7, -8(%rbp)
    movsd   %xmm6, -16(%rbp)
    movsd   %xmm5, -24(%rbp)
    movsd   %xmm4, -32(%rbp)
    movsd   %xmm3, -40(%rbp)
    movsd   %xmm2, -48(%rbp)
    movsd   %xmm1, -56(%rbp)
    movsd   %xmm0, -64(%rbp)
    leaq    onExit(%rip), %r11
    callq   *(%r11)          // call tracing exit routine
    movq    %rax, %r11       // returns original return address
    movsd   -64(%rbp), %xmm0 // restore all registers
    movsd   -56(%rbp), %xmm1
    movsd   -48(%rbp), %xmm2
    movsd   -40(%rbp), %xmm3
    movsd   -32(%rbp), %xmm4
    movsd   -24(%rbp), %xmm5
    movsd   -16(%rbp), %xmm6
    movsd   -8(%rbp), %xmm7
    addq    $64, %rsp
    popq    %rbp
    popq    %r10
    popq    %r12
    popq    %r13
    popq    %r14
    popq    %r15
    popq    %rdi
    popq    %rsi
    popq    %rax
    popq    %rdx
    popq    %rcx
    popq    %r8
    popq    %r9
    popq    %rbx
    pushq   %r11
    ret     // return to original caller

    nop
    nop

_xt_forwarding_trampolines_start:

// 469 trampoline entry points
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
_xt_forwarding_trampolines_end:

#endif
