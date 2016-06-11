//
//  SwiftTrace.m
//  SwiftTrace
//
//  Repo: https://github.com/johnno1962/SwiftTrace
//  $Id: //depot/SwiftTrace/SwiftTrace/SwiftTrace.mm#7 $
//
//  With thanks to:
//  https://github.com/OliverLetterer/imp_implementationForwardingToSelector
//
//  imp_implementationForwardingToSelector.m
//  imp_implementationForwardingToSelector
//
//  Created by Oliver Letterer on 22.03.14.
//  Copyright 2014 Sparrowlabs. All rights reserved.
//
//

#import "SwiftTrace.h"

#import <AssertMacros.h>
#import <libkern/OSAtomic.h>

#import <mach/vm_types.h>
#import <mach/vm_map.h>
#import <mach/mach_init.h>

extern char xt_forwarding_trampoline_page, xt_forwarding_trampolines_start,
            xt_forwarding_trampolines_next, xt_forwarding_trampolines_end;

static OSSpinLock lock = OS_SPINLOCK_INIT;

// trampoline implementation specific stuff...
typedef struct {
#if !defined(__LP64__)
    IMP tracer;
#endif
    void *info;
} XtraceTrampolineDataBlock;

typedef int32_t SPLForwardingTrampolineEntryPointBlock[2];
#if defined(__i386__)
static const int32_t SPLForwardingTrampolineInstructionCount = 8;
#elif defined(_ARM_ARCH_7)
static const int32_t SPLForwardingTrampolineInstructionCount = 12;
#undef PAGE_SIZE
#define PAGE_SIZE (1<<14)
#elif defined(__arm64__)
static const int32_t SPLForwardingTrampolineInstructionCount = 32;
#undef PAGE_SIZE
#define PAGE_SIZE (1<<14)
#elif defined(__LP64__)
static const int32_t SPLForwardingTrampolineInstructionCount = 34;
#else
#error SwiftTrace is not supported on this platform
#endif

static const size_t numberOfTrampolinesPerPage = (PAGE_SIZE - SPLForwardingTrampolineInstructionCount * sizeof(int32_t)) / sizeof(SPLForwardingTrampolineEntryPointBlock);

typedef struct {
    union {
        struct {
#if defined(__LP64__)
            IMP tracer;
#endif
            int32_t nextAvailableTrampolineIndex;
        };
        int32_t trampolineSize[SPLForwardingTrampolineInstructionCount];
    };

    XtraceTrampolineDataBlock trampolineData[numberOfTrampolinesPerPage];

    int32_t trampolineInstructions[SPLForwardingTrampolineInstructionCount];
    SPLForwardingTrampolineEntryPointBlock trampolineEntryPoints[numberOfTrampolinesPerPage];
} SPLForwardingTrampolinePage;

check_compile_time(sizeof(SPLForwardingTrampolineEntryPointBlock) == sizeof(XtraceTrampolineDataBlock));
check_compile_time(sizeof(SPLForwardingTrampolinePage) == 2 * PAGE_SIZE);
check_compile_time(offsetof(SPLForwardingTrampolinePage, trampolineInstructions) == PAGE_SIZE);

static SPLForwardingTrampolinePage *SPLForwardingTrampolinePageAlloc()
{
    vm_address_t trampolineTemplatePage = (vm_address_t)&xt_forwarding_trampoline_page;

    vm_address_t newTrampolinePage = 0;
    kern_return_t kernReturn = KERN_SUCCESS;

    //printf( "%d %d %d %d %d\n", vm_page_size, &xt_forwarding_trampolines_start - &xt_forwarding_trampoline_page, SPLForwardingTrampolineInstructionCount*4, &xt_forwarding_trampolines_end - &xt_forwarding_trampoline_page, &xt_forwarding_trampolines_next - &xt_forwarding_trampolines_start );

    assert( &xt_forwarding_trampolines_start - &xt_forwarding_trampoline_page ==
           SPLForwardingTrampolineInstructionCount * sizeof(int32_t) );
    assert( &xt_forwarding_trampolines_end - &xt_forwarding_trampoline_page == PAGE_SIZE );
    assert( &xt_forwarding_trampolines_next - &xt_forwarding_trampolines_start == sizeof(XtraceTrampolineDataBlock) );

    // allocate two consequent memory pages
    kernReturn = vm_allocate(mach_task_self(), &newTrampolinePage, PAGE_SIZE * 2, VM_FLAGS_ANYWHERE);
    NSCAssert1(kernReturn == KERN_SUCCESS, @"vm_allocate failed", kernReturn);

    // deallocate second page where we will store our trampoline
    vm_address_t trampoline_page = newTrampolinePage + PAGE_SIZE;
    kernReturn = vm_deallocate(mach_task_self(), trampoline_page, PAGE_SIZE);
    NSCAssert1(kernReturn == KERN_SUCCESS, @"vm_deallocate failed", kernReturn);

    // trampoline page will be remapped with implementation of spl_objc_forwarding_trampoline
    vm_prot_t cur_protection, max_protection;
    kernReturn = vm_remap(mach_task_self(), &trampoline_page, PAGE_SIZE, 0, 0, mach_task_self(), trampolineTemplatePage, FALSE, &cur_protection, &max_protection, VM_INHERIT_SHARE);
    NSCAssert1(kernReturn == KERN_SUCCESS, @"vm_remap failed", kernReturn);

    return (SPLForwardingTrampolinePage *)newTrampolinePage;
}

static SPLForwardingTrampolinePage *nextTrampolinePage()
{
    static NSMutableArray *normalTrampolinePages = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        normalTrampolinePages = [NSMutableArray array];
    });

    NSMutableArray *thisArray = normalTrampolinePages;

    SPLForwardingTrampolinePage *trampolinePage = (SPLForwardingTrampolinePage *)[thisArray.lastObject pointerValue];

    if (!trampolinePage || (trampolinePage->nextAvailableTrampolineIndex == numberOfTrampolinesPerPage) ) {
        trampolinePage = SPLForwardingTrampolinePageAlloc();
        [thisArray addObject:[NSValue valueWithPointer:trampolinePage]];
    }

    return trampolinePage;
}

IMP imp_implementationForwardingToTracer(void *info, IMP tracer)
{
    OSSpinLockLock(&lock);

    SPLForwardingTrampolinePage *dataPageLayout = nextTrampolinePage();

    int32_t nextAvailableTrampolineIndex = dataPageLayout->nextAvailableTrampolineIndex;

#if !defined(__LP64__)
    dataPageLayout->trampolineData[nextAvailableTrampolineIndex].tracer = tracer;
#else
    dataPageLayout->tracer = tracer;
#endif
    dataPageLayout->trampolineData[nextAvailableTrampolineIndex].info = info;
    dataPageLayout->nextAvailableTrampolineIndex++;

    IMP implementation = (IMP)&dataPageLayout->trampolineEntryPoints[nextAvailableTrampolineIndex];
    
    OSSpinLockUnlock(&lock);
    
    return implementation;
}
