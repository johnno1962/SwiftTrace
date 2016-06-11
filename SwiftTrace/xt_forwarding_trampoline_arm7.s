#ifdef __arm__

#include <arm/arch.h>
#if defined(_ARM_ARCH_7)

# Write out the trampoline table, aligned to the page boundary
.text
.align 14
.globl _xt_forwarding_trampoline_page
.globl _xt_forwarding_trampolines_start
.globl _xt_forwarding_trampolines_next
.globl _xt_forwarding_trampolines_end

_xt_forwarding_trampoline_page:
_xt_forwarding_trampoline:
	push {r7, lr}           // save frame potinter and return addresss
	mov	r7, sp              // set up new frame
    push {r0, r1, r2, r3, r9}   // save first four args on stack
    sub r12, #0x4000        // r12 = r12 - pagesize, that is where the data for this trampoline is stored
    ldr r0, [r12, #-4]      // first arg is user data ptr
    ldr r12, [r12]          // get potinter to hander func
    blx r12                 // call tracer function
    mov r12, r0             // return value is original implementation
    pop {r0, r1, r2, r3, r9}
	mov	sp, r7              // unwind stack
    pop {r7, lr}
    mov pc, r12             // pass control to original imp.

_xt_forwarding_trampolines_start:
# Save pc+8 into r12, then jump to the actual trampoline implementation
mov r12, pc
b _xt_forwarding_trampoline;

_xt_forwarding_trampolines_next:
# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

# Next trampoline entry point
mov r12, pc
b _xt_forwarding_trampoline;

_xt_forwarding_trampolines_end:
#endif
#endif
