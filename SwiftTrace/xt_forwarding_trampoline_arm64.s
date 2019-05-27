
//  $Id: //depot/SwiftTrace/SwiftTrace/xt_forwarding_trampoline_arm64.s#12 $

#if defined(__arm64__)
.text
.align 14
onEntry:
    .quad 0
onExit:
    .quad 0

.align 14
.globl _xt_forwarding_trampoline_page
.globl _xt_forwarding_trampolines_start
.globl _xt_forwarding_trampolines_next
.globl _xt_forwarding_trampolines_end

// for ARM64 abi see http://infocenter.arm.com/help/topic/com.arm.doc.ihi0055b/IHI0055B_aapcs64.pdf

_xt_forwarding_trampoline_page:
_xt_forwarding_trampoline:
    sub x16, lr, #0x8       // x16 = lr - 8, that is the address of the corresponding `mov x17, lr` instruction of the current trampoline
    sub x16, x16, #0x4000   // x16 = x16 - 16384, that is where the data for this trampoline is stored
    mov lr, x17             // restore the link register to that to be used when calling the original implementation
    stp	lr, fp, [sp, #-16]! // save frame pointer and link register
    stp	x6, x7, [sp, #-16]! // save all regs used in parameter passing
    stp	x4, x5, [sp, #-16]!
    stp	x2, x3, [sp, #-16]!
    stp	x0, x1, [sp, #-16]!
    stp d1, d0, [sp, #-16]!
    stp d3, d2, [sp, #-16]!
    stp d5, d4, [sp, #-16]!
    stp d7, d6, [sp, #-16]!
    stp	x20, x8, [sp, #-16]! // r8 is pointer for return of structs
    mov	fp, sp
    ldr x0, [x16]   // first argument is trace info structure
    mov x1, lr      // second argument is return address
    mov x2, sp      // fourth argument is pointer to stack
    ldr x16, onEntry
    blr x16         // call tracer routine
    mov x16, x0     // original implementation to call is returned
    mov	sp, fp     // restore registers
    ldp	x20, x8, [sp], #16
    ldp	d7, d6, [sp], #16
    ldp	d5, d4, [sp], #16
    ldp	d3, d2, [sp], #16
    ldp	d1, d0, [sp], #16
    ldp	x0, x1, [sp], #16
    ldp	x2, x3, [sp], #16
    ldp	x4, x5, [sp], #16
    ldp	x6, x7, [sp], #16
    ldp	lr, fp, [sp], #16
    bl getpc
getpc:
    add lr, lr, #8
    br x16          // continue onto original implemntation

returning:
    stp	lr, fp, [sp, #-16]! // save frame pointer and link register
    stp	x1, x0, [sp, #-16]! // save all regs used in parameter passing
    stp	x3, x2, [sp, #-16]!
    stp	x5, x4, [sp, #-16]!
    stp	x7, x6, [sp, #-16]!
    stp d1, d0, [sp, #-16]!
    stp d3, d2, [sp, #-16]!
    stp d5, d4, [sp, #-16]!
    stp d7, d6, [sp, #-16]!
    stp	x20, x8, [sp, #-16]! // r8 is pointer for return of structs
    mov	fp, sp
    ldr x16, onExit
    blr x16         // call tracer routine
    mov x17, x0     // returns return address
    mov	sp, fp      // restore registers
    ldp	x20, x8, [sp], #16
    ldp	d7, d6, [sp], #16
    ldp	d5, d4, [sp], #16
    ldp	d3, d2, [sp], #16
    ldp	d1, d0, [sp], #16
    ldp	x7, x6, [sp], #16
    ldp	x5, x4, [sp], #16
    ldp	x3, x2, [sp], #16
    ldp	x1, x0, [sp], #16
    ldp	lr, fp, [sp], #16
    mov lr, x17
    ret          // return to caller
    nop
    nop
    nop

_xt_forwarding_trampolines_start:
# Save lr, which contains the address to where we need to branch back after function returns, then jump to the actual trampoline implementation
mov x17, lr
bl _xt_forwarding_trampoline;

_xt_forwarding_trampolines_next:
# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

# Next trampoline entry point
mov x17, lr
bl _xt_forwarding_trampoline;

_xt_forwarding_trampolines_end:

#endif
