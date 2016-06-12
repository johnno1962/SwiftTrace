
//  $Id: //depot/SwiftTrace/SwiftTrace/xt_forwarding_trampoline_arm7.s#8 $

#ifdef __arm__

#include <arm/arch.h>
#if defined(_ARM_ARCH_7)

// for abi see: http://infocenter.arm.com/help/topic/com.arm.doc.ihi0042f/IHI0042F_aapcs.pdf
// instrux ref: http://infocenter.arm.com/help/topic/com.arm.doc.qrc0001m/QRC0001_UAL.pdf

# Write out the trampoline table, aligned to the page boundary
.text
.align 14
.globl _xt_forwarding_trampoline_page
.globl _xt_forwarding_trampolines_start
.globl _xt_forwarding_trampolines_next
.globl _xt_forwarding_trampolines_end

_xt_forwarding_trampoline_page:
_xt_forwarding_trampoline:
	push {r7, lr}           // save frame pointer and return addresss
	mov	r7, sp              // set up new frame
    push {r0, r1, r2, r3, r9}   // save first four args on stack
    sub r12, #0x4000        // r12 = r12 - pagesize, that is where the data for this trampoline is stored
    ldr r0, [r12, #-4]      // first arg is user data ptr
    ldr r12, [r12]          // get pointer to tracer func
    blx r12                 // call it
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
