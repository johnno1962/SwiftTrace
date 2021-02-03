
//  $Id: //depot/SwiftTrace/SwiftTraceGuts/xt_forwarding_trampoline_x64.s#6 $

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
    popq    %r11    // recover trampoline return address
    pushq   %rbp    // save frame pointer
    movq    %rsp, %rbp
    pushq   %rbp    // align stack
    pushq   %rbx
    pushq   %rax    // pointer for return of struct
    pushq   %r9     // push 6 registers for int paremters
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
    subq    $64, %rsp // make space for floating point registers and save
    movsd   %xmm0, (%rsp)
    movsd   %xmm1, 8(%rsp)
    movsd   %xmm2, 16(%rsp)
    movsd   %xmm3, 24(%rsp)
    movsd   %xmm4, 32(%rsp)
    movsd   %xmm5, 40(%rsp)
    movsd   %xmm6, 48(%rsp)
    movsd   %xmm7, 56(%rsp)
    subq    $4096+5, %r11   // find trampoline info relative to return address
    movq    (%r11), %rdi    // first argument is pointer to forwarding info
    movq    184(%rsp), %rsi // recover original return address
    movq    %rsp, %rdx      // pass through stack
    leaq    onEntry(%rip), %r11
    callq   *(%r11)          // call tracing entry routine (saves return address)
    leaq    returning(%rip), %r11
    movq    %r11, 184(%rsp)  // patch return address to "returning" code
    movq    %rax, %r11       // pointer to original implementation returned
    movsd   (%rsp), %xmm0 // restore all registers
    movsd   8(%rsp), %xmm1
    movsd   16(%rsp), %xmm2
    movsd   24(%rsp), %xmm3
    movsd   32(%rsp), %xmm4
    movsd   40(%rsp), %xmm5
    movsd   48(%rsp), %xmm6
    movsd   56(%rsp), %xmm7
    addq    $64, %rsp
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
    popq    %rbp
    popq    %rbp    // restore frame pointer
    jmpq    *%r11   // forward onto original implementation

returning:
    pushq   %rbp    // make space for real return address
    pushq   %rbp    // bump frame
    movq    %rsp, %rbp
    pushq   %rbp    // align stack to 16 bytes
    pushq   %rbx
    pushq   %r9
    pushq   %r8     // push the 4 regs used for int returns
    pushq   %rcx
    pushq   %rdx
    pushq   %rax
    pushq   %rsi
    pushq   %rdi
    pushq   %r15
    pushq   %r14
    pushq   %r13    // Swift "call context" register for self
    pushq   %r12
    pushq   %r10
    subq    $64, %rsp   // make space for floating point regeisters and save
    movsd   %xmm0, (%rsp)
    movsd   %xmm1, 8(%rsp)
    movsd   %xmm2, 16(%rsp)
    movsd   %xmm3, 24(%rsp)
    movsd   %xmm4, 32(%rsp)
    movsd   %xmm5, 40(%rsp)
    movsd   %xmm6, 48(%rsp)
    movsd   %xmm7, 56(%rsp)
    leaq    onExit(%rip), %r11
    callq   *(%r11)         // call tracing exit routine
    movsd   (%rsp), %xmm0   // restore all registers
    movsd   8(%rsp), %xmm1
    movsd   16(%rsp), %xmm2
    movsd   24(%rsp), %xmm3
    movsd   32(%rsp), %xmm4
    movsd   40(%rsp), %xmm5
    movsd   48(%rsp), %xmm6
    movsd   56(%rsp), %xmm7
    addq    $64, %rsp
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
    popq    %rbp
    popq    %rbp
    ret     // return to original caller - reset by "onExit()"
    nop
    nop
    nop
    nop

_xt_forwarding_trampolines_start:
    callq _xt_forwarding_trampoline
    nop
    nop
    nop

// another 469 trampoline entry points
_xt_forwarding_trampolines_next:
.rept 465
    callq _xt_forwarding_trampoline
    nop
    nop
    nop
.endr

_xt_forwarding_trampolines_end:
nop

#endif
