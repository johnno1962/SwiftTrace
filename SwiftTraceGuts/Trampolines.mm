//
//  Trampolines.mm
//  SwiftTrace
//
//  Created by John Holdsworth on 21/01/2022.
//  Repo: https://github.com/johnno1962/SwiftTrace
//  $Id: //depot/SwiftTrace/SwiftTraceGuts/Trampolines.mm#6 $
//

#if DEBUG || !DEBUG_ONLY
#import "include/SwiftTrace.h"

//
//  Trampoline code thanks to:
//  https://github.com/OliverLetterer/imp_implementationForwardingToSelector
//
//  imp_implementationForwardingToSelector.m
//  imp_implementationForwardingToSelector
//
//  Created by Oliver Letterer on 22.03.14.
//  Copyright (c) 2014 Oliver Letterer <oliver.letterer@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import <AssertMacros.h>
#import <libkern/OSAtomic.h>

#import <mach/vm_types.h>
#import <mach/vm_map.h>
#import <mach/mach_init.h>
#import <objc/runtime.h>
#import <os/lock.h>

extern char xt_forwarding_trampoline_page, xt_forwarding_trampolines_start,
            xt_forwarding_trampolines_next, xt_forwarding_trampolines_end;

// trampoline implementation specific stuff...
typedef struct {
#if !defined(__LP64__)
    IMP tracer;
#endif
    void *patch; // Pointer to SwiftTrace.Patch instance retained elsewhere
} SwiftTraceTrampolineDataBlock;

typedef int32_t SPLForwardingTrampolineEntryPointBlock[2];
#if defined(__i386__)
static const int32_t SPLForwardingTrampolineInstructionCount = 8;
#elif defined(_ARM_ARCH_7)
static const int32_t SPLForwardingTrampolineInstructionCount = 12;
#undef PAGE_SIZE
#define PAGE_SIZE (1<<14)
#elif defined(__arm64__)
static const int32_t SPLForwardingTrampolineInstructionCount = 62;
#undef PAGE_SIZE
#define PAGE_SIZE (1<<14)
#elif defined(__LP64__) // x86_64
static const int32_t SPLForwardingTrampolineInstructionCount = 92;
#else
#error SwiftTrace is not supported on this platform
#endif

static const size_t numberOfTrampolinesPerPage = (PAGE_SIZE - SPLForwardingTrampolineInstructionCount * sizeof(int32_t)) / sizeof(SPLForwardingTrampolineEntryPointBlock);

typedef struct {
    union {
        struct {
#if defined(__LP64__)
            IMP onEntry;
            IMP onExit;
#endif
            int32_t nextAvailableTrampolineIndex;
        };
        int32_t trampolineSize[SPLForwardingTrampolineInstructionCount];
    };

    SwiftTraceTrampolineDataBlock trampolineData[numberOfTrampolinesPerPage];

    int32_t trampolineInstructions[SPLForwardingTrampolineInstructionCount];
    SPLForwardingTrampolineEntryPointBlock trampolineEntryPoints[numberOfTrampolinesPerPage];
} SPLForwardingTrampolinePage;

static_assert(sizeof(SPLForwardingTrampolineEntryPointBlock) == sizeof(SwiftTraceTrampolineDataBlock),
              "Inconsistent entry point/data block sizes");
static_assert(sizeof(SPLForwardingTrampolinePage) == 2 * PAGE_SIZE,
              "Incorrect trampoline pages size");
static_assert(offsetof(SPLForwardingTrampolinePage, trampolineInstructions) == PAGE_SIZE,
              "Incorrect trampoline page offset");

static SPLForwardingTrampolinePage *SPLForwardingTrampolinePageAlloc()
{
    vm_address_t trampolineTemplatePage = (vm_address_t)&xt_forwarding_trampoline_page;

    vm_address_t newTrampolinePage = 0;
    kern_return_t kernReturn = KERN_SUCCESS;

    //printf( "%d %d %d %d %d\n", vm_page_size, &xt_forwarding_trampolines_start - &xt_forwarding_trampoline_page, SPLForwardingTrampolineInstructionCount*4, &xt_forwarding_trampolines_end - &xt_forwarding_trampoline_page, &xt_forwarding_trampolines_next - &xt_forwarding_trampolines_start );

    assert( &xt_forwarding_trampolines_start - &xt_forwarding_trampoline_page ==
           SPLForwardingTrampolineInstructionCount * sizeof(int32_t) );
    assert( &xt_forwarding_trampolines_end - &xt_forwarding_trampoline_page == PAGE_SIZE );
    assert( &xt_forwarding_trampolines_next - &xt_forwarding_trampolines_start == sizeof(SwiftTraceTrampolineDataBlock) );

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

static NSMutableArray *normalTrampolinePages = nil;

static SPLForwardingTrampolinePage *nextTrampolinePage()
{
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

#if 00
/// Fix for libMainThreadCheck when using trampolines
typedef const char * (*image_path_func)(const void *ptr);
static image_path_func orig_path_func;

static const char *myld_image_path_containing_address(const void* addr) {
    return orig_path_func(addr) ?: "/trampoline";
}
#endif

IMP imp_implementationForwardingToTracer(void *patch, IMP onEntry, IMP onExit)
{
#if 00
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        struct rebinding path_rebinding = {"dyld_image_path_containing_address",
          (void *)myld_image_path_containing_address, (void **)&orig_path_func};
        rebind_symbols(&path_rebinding, 1);
    });
#endif

    static os_unfair_lock lock = OS_UNFAIR_LOCK_INIT;
    os_unfair_lock_lock(&lock);

    SPLForwardingTrampolinePage *dataPageLayout = nextTrampolinePage();

    int32_t nextAvailableTrampolineIndex = dataPageLayout->nextAvailableTrampolineIndex;

#if !defined(__LP64__)
    dataPageLayout->trampolineData[nextAvailableTrampolineIndex].tracer = onEntry;
#else
    dataPageLayout->onEntry = onEntry;
    dataPageLayout->onExit = onExit;
#endif
    dataPageLayout->trampolineData[nextAvailableTrampolineIndex].patch = patch;
    dataPageLayout->nextAvailableTrampolineIndex++;

    IMP implementation = (IMP)&dataPageLayout->trampolineEntryPoints[nextAvailableTrampolineIndex];

    os_unfair_lock_unlock(&lock);

    return implementation;
}

id findSwizzleOf(void * _Nonnull trampoline) {
    for (NSValue *allocated in normalTrampolinePages) {
        SPLForwardingTrampolinePage *trampolinePage =
            (SPLForwardingTrampolinePage *)allocated.pointerValue;
        if (trampoline >= trampolinePage->trampolineInstructions && trampoline <
            trampolinePage->trampolineInstructions + numberOfTrampolinesPerPage)
            return *(id const *)(void *)((char *)trampoline - PAGE_SIZE);
    }
    return nil;
}
#endif
