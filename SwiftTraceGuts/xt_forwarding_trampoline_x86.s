
//  $Id: //depot/SwiftTrace/SwiftTraceGuts/xt_forwarding_trampoline_x86.s#1 $

// This architecture is no longer supported

#if defined(__i386__)
.text
.align 12
.globl _xt_forwarding_trampoline_page
.globl _xt_forwarding_trampolines_start
.globl _xt_forwarding_trampolines_next
.globl _xt_forwarding_trampolines_end

_xt_forwarding_trampoline_page:
_xt_forwarding_trampoline:
    popl %eax           // pop saved pc (address of first of the three nops)
    pushl %ebp          // save frame pointer
    movl %esp, %ebp     // set up new frame
    subl $4096+5, %eax  // offset address by one page and the length of the call instrux
    pushl %eax          // save pointer to trampoline data (func+data)
    movl 4(%eax), %eax
    pushl %eax          // save pointer to user data
    movl 4(%esp), %eax  // fetch pointer to C aspect handler
    call *(%eax)        // call trace handler
    popl %ebp
    popl %ebp
    popl %ebp           // restore frame pointer
    jmpl *%eax          // pass on to original implementation
    nop
    nop
    nop
    nop
    nop
    nop
    nop

_xt_forwarding_trampolines_start:
// 508 trampoline entry points
call _xt_forwarding_trampoline
nop
nop
nop
_xt_forwarding_trampolines_next:
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
call _xt_forwarding_trampoline
nop
nop
nop
_xt_forwarding_trampolines_end:

#endif
