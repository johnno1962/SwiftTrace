//
//  SwiftTrace.m
//  SwiftTrace
//
//  Repo: https://github.com/johnno1962/SwiftTrace
//  $Id: //depot/SwiftTrace/SwiftTraceGuts/SwiftTrace.mm#64 $
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

#import "SwiftTrace.h"

#import <AssertMacros.h>
#import <libkern/OSAtomic.h>

#import <mach/vm_types.h>
#import <mach/vm_map.h>
#import <mach/mach_init.h>
#import <objc/runtime.h>
#import <os/lock.h>

extern char xt_forwarding_trampoline_page, xt_forwarding_trampolines_start,
            xt_forwarding_trampolines_next, xt_forwarding_trampolines_end;

static os_unfair_lock lock = OS_UNFAIR_LOCK_INIT;

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

/// Fox for libMiainThreadCheck when using tramplines
typedef const char * (*image_path_func)(const void *ptr);
static image_path_func orig_path_func;

static const char *myld_image_path_containing_address(const void* addr) {
    return orig_path_func(addr) ?: "/trampoline";
}

IMP imp_implementationForwardingToTracer(void *patch, IMP onEntry, IMP onExit)
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        struct rebinding path_rebinding = {"dyld_image_path_containing_address",
          (void *)myld_image_path_containing_address, (void **)&orig_path_func};
        rebind_symbols(&path_rebinding, 1);
    });
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

// ====================================================================
// From here on additions to the original code for use by "SwiftTrace".
// ====================================================================
// Begin copy of SWiftTrace-Swift.h included here
// ====================================================================
// Generated by Apple Swift version 5.3.2 (swiftlang-1200.0.45 clang-1200.0.32.28)
#ifndef SWIFTTRACE_SWIFT_H
#define SWIFTTRACE_SWIFT_H
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgcc-compat"

#if !defined(__has_include)
# define __has_include(x) 0
#endif
#if !defined(__has_attribute)
# define __has_attribute(x) 0
#endif
#if !defined(__has_feature)
# define __has_feature(x) 0
#endif
#if !defined(__has_warning)
# define __has_warning(x) 0
#endif

#if __has_include(<swift/objc-prologue.h>)
# include <swift/objc-prologue.h>
#endif

#pragma clang diagnostic ignored "-Wauto-import"
#include <Foundation/Foundation.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

#if !defined(SWIFT_TYPEDEFS)
# define SWIFT_TYPEDEFS 1
# if __has_include(<uchar.h>)
#  include <uchar.h>
# elif !defined(__cplusplus)
typedef uint_least16_t char16_t;
typedef uint_least32_t char32_t;
# endif
typedef float swift_float2  __attribute__((__ext_vector_type__(2)));
typedef float swift_float3  __attribute__((__ext_vector_type__(3)));
typedef float swift_float4  __attribute__((__ext_vector_type__(4)));
typedef double swift_double2  __attribute__((__ext_vector_type__(2)));
typedef double swift_double3  __attribute__((__ext_vector_type__(3)));
typedef double swift_double4  __attribute__((__ext_vector_type__(4)));
typedef int swift_int2  __attribute__((__ext_vector_type__(2)));
typedef int swift_int3  __attribute__((__ext_vector_type__(3)));
typedef int swift_int4  __attribute__((__ext_vector_type__(4)));
typedef unsigned int swift_uint2  __attribute__((__ext_vector_type__(2)));
typedef unsigned int swift_uint3  __attribute__((__ext_vector_type__(3)));
typedef unsigned int swift_uint4  __attribute__((__ext_vector_type__(4)));
#endif

#if !defined(SWIFT_PASTE)
# define SWIFT_PASTE_HELPER(x, y) x##y
# define SWIFT_PASTE(x, y) SWIFT_PASTE_HELPER(x, y)
#endif
#if !defined(SWIFT_METATYPE)
# define SWIFT_METATYPE(X) Class
#endif
#if !defined(SWIFT_CLASS_PROPERTY)
# if __has_feature(objc_class_property)
#  define SWIFT_CLASS_PROPERTY(...) __VA_ARGS__
# else
#  define SWIFT_CLASS_PROPERTY(...)
# endif
#endif

#if __has_attribute(objc_runtime_name)
# define SWIFT_RUNTIME_NAME(X) __attribute__((objc_runtime_name(X)))
#else
# define SWIFT_RUNTIME_NAME(X)
#endif
#if __has_attribute(swift_name)
# define SWIFT_COMPILE_NAME(X) __attribute__((swift_name(X)))
#else
# define SWIFT_COMPILE_NAME(X)
#endif
#if __has_attribute(objc_method_family)
# define SWIFT_METHOD_FAMILY(X) __attribute__((objc_method_family(X)))
#else
# define SWIFT_METHOD_FAMILY(X)
#endif
#if __has_attribute(noescape)
# define SWIFT_NOESCAPE __attribute__((noescape))
#else
# define SWIFT_NOESCAPE
#endif
#if __has_attribute(ns_consumed)
# define SWIFT_RELEASES_ARGUMENT __attribute__((ns_consumed))
#else
# define SWIFT_RELEASES_ARGUMENT
#endif
#if __has_attribute(warn_unused_result)
# define SWIFT_WARN_UNUSED_RESULT __attribute__((warn_unused_result))
#else
# define SWIFT_WARN_UNUSED_RESULT
#endif
#if __has_attribute(noreturn)
# define SWIFT_NORETURN __attribute__((noreturn))
#else
# define SWIFT_NORETURN
#endif
#if !defined(SWIFT_CLASS_EXTRA)
# define SWIFT_CLASS_EXTRA
#endif
#if !defined(SWIFT_PROTOCOL_EXTRA)
# define SWIFT_PROTOCOL_EXTRA
#endif
#if !defined(SWIFT_ENUM_EXTRA)
# define SWIFT_ENUM_EXTRA
#endif
#if !defined(SWIFT_CLASS)
# if __has_attribute(objc_subclassing_restricted)
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_CLASS_EXTRA
#  define SWIFT_CLASS_NAMED(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# else
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
#  define SWIFT_CLASS_NAMED(SWIFT_NAME) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# endif
#endif
#if !defined(SWIFT_RESILIENT_CLASS)
# if __has_attribute(objc_class_stub)
#  define SWIFT_RESILIENT_CLASS(SWIFT_NAME) SWIFT_CLASS(SWIFT_NAME) __attribute__((objc_class_stub))
#  define SWIFT_RESILIENT_CLASS_NAMED(SWIFT_NAME) __attribute__((objc_class_stub)) SWIFT_CLASS_NAMED(SWIFT_NAME)
# else
#  define SWIFT_RESILIENT_CLASS(SWIFT_NAME) SWIFT_CLASS(SWIFT_NAME)
#  define SWIFT_RESILIENT_CLASS_NAMED(SWIFT_NAME) SWIFT_CLASS_NAMED(SWIFT_NAME)
# endif
#endif

#if !defined(SWIFT_PROTOCOL)
# define SWIFT_PROTOCOL(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
# define SWIFT_PROTOCOL_NAMED(SWIFT_NAME) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
#endif

#if !defined(SWIFT_EXTENSION)
# define SWIFT_EXTENSION(M) SWIFT_PASTE(M##_Swift_, __LINE__)
#endif

#if !defined(OBJC_DESIGNATED_INITIALIZER)
# if __has_attribute(objc_designated_initializer)
#  define OBJC_DESIGNATED_INITIALIZER __attribute__((objc_designated_initializer))
# else
#  define OBJC_DESIGNATED_INITIALIZER
# endif
#endif
#if !defined(SWIFT_ENUM_ATTR)
# if defined(__has_attribute) && __has_attribute(enum_extensibility)
#  define SWIFT_ENUM_ATTR(_extensibility) __attribute__((enum_extensibility(_extensibility)))
# else
#  define SWIFT_ENUM_ATTR(_extensibility)
# endif
#endif
#if !defined(SWIFT_ENUM)
# define SWIFT_ENUM(_type, _name, _extensibility) enum _name : _type _name; enum SWIFT_ENUM_ATTR(_extensibility) SWIFT_ENUM_EXTRA _name : _type
# if __has_feature(generalized_swift_name)
#  define SWIFT_ENUM_NAMED(_type, _name, SWIFT_NAME, _extensibility) enum _name : _type _name SWIFT_COMPILE_NAME(SWIFT_NAME); enum SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_ENUM_ATTR(_extensibility) SWIFT_ENUM_EXTRA _name : _type
# else
#  define SWIFT_ENUM_NAMED(_type, _name, SWIFT_NAME, _extensibility) SWIFT_ENUM(_type, _name, _extensibility)
# endif
#endif
#if !defined(SWIFT_UNAVAILABLE)
# define SWIFT_UNAVAILABLE __attribute__((unavailable))
#endif
#if !defined(SWIFT_UNAVAILABLE_MSG)
# define SWIFT_UNAVAILABLE_MSG(msg) __attribute__((unavailable(msg)))
#endif
#if !defined(SWIFT_AVAILABILITY)
# define SWIFT_AVAILABILITY(plat, ...) __attribute__((availability(plat, __VA_ARGS__)))
#endif
#if !defined(SWIFT_WEAK_IMPORT)
# define SWIFT_WEAK_IMPORT __attribute__((weak_import))
#endif
#if !defined(SWIFT_DEPRECATED)
# define SWIFT_DEPRECATED __attribute__((deprecated))
#endif
#if !defined(SWIFT_DEPRECATED_MSG)
# define SWIFT_DEPRECATED_MSG(...) __attribute__((deprecated(__VA_ARGS__)))
#endif
#if __has_feature(attribute_diagnose_if_objc)
# define SWIFT_DEPRECATED_OBJC(Msg) __attribute__((diagnose_if(1, Msg, "warning")))
#else
# define SWIFT_DEPRECATED_OBJC(Msg) SWIFT_DEPRECATED_MSG(Msg)
#endif
#if !defined(IBSegueAction)
# define IBSegueAction
#endif
#if __has_feature(modules)
#if __has_warning("-Watimport-in-framework-header")
#pragma clang diagnostic ignored "-Watimport-in-framework-header"
#endif
@import ObjectiveC;
#endif

#pragma clang diagnostic ignored "-Wproperty-attribute-mismatch"
#pragma clang diagnostic ignored "-Wduplicate-method-arg"
#if __has_warning("-Wpragma-clang-attribute")
# pragma clang diagnostic ignored "-Wpragma-clang-attribute"
#endif
#pragma clang diagnostic ignored "-Wunknown-pragmas"
#pragma clang diagnostic ignored "-Wnullability"

#if __has_attribute(external_source_symbol)
# pragma push_macro("any")
# undef any
# pragma clang attribute push(__attribute__((external_source_symbol(language="Swift", defined_in="SwiftTrace",generated_declaration))), apply_to=any(function,enum,objc_interface,objc_category,objc_protocol))
# pragma pop_macro("any")
#endif


@class Swizzle;

/// Base class for SwiftTrace api through it’s public class methods
SWIFT_CLASS_NAMED("SwiftTrace")
@interface SwiftTrace : NSObject
/// Format for ms of time spend in method
SWIFT_CLASS_PROPERTY(@property (nonatomic, class, copy) NSString * _Nonnull timeFormat;)
+ (NSString * _Nonnull)timeFormat SWIFT_WARN_UNUSED_RESULT;
+ (void)setTimeFormat:(NSString * _Nonnull)value;
/// Format for idenifying class instance
SWIFT_CLASS_PROPERTY(@property (nonatomic, class, copy) NSString * _Nonnull identifyFormat;)
+ (NSString * _Nonnull)identifyFormat SWIFT_WARN_UNUSED_RESULT;
+ (void)setIdentifyFormat:(NSString * _Nonnull)value;
/// Indentation amongst different call levels on the stack
SWIFT_CLASS_PROPERTY(@property (nonatomic, class, copy) NSString * _Nonnull traceIndent;)
+ (NSString * _Nonnull)traceIndent SWIFT_WARN_UNUSED_RESULT;
+ (void)setTraceIndent:(NSString * _Nonnull)value;
/// Class used to create “Sizzle” instances representing a member function
SWIFT_CLASS_PROPERTY(@property (nonatomic, class) SWIFT_METATYPE(Swizzle) _Nonnull swizzleFactory;)
+ (SWIFT_METATYPE(Swizzle) _Nonnull)swizzleFactory SWIFT_WARN_UNUSED_RESULT;
+ (void)setSwizzleFactory:(SWIFT_METATYPE(Swizzle) _Nonnull)value;
SWIFT_CLASS_PROPERTY(@property (nonatomic, class, strong) SwiftTrace * _Nonnull lastSwiftTrace;)
+ (SwiftTrace * _Nonnull)lastSwiftTrace SWIFT_WARN_UNUSED_RESULT;
+ (void)setLastSwiftTrace:(SwiftTrace * _Nonnull)value;
/// Returns a pointer to the interposed dictionary. Required to
/// ensure only one interposed dictionary us used if the user
/// includes SwiftTrace as a package or pod in their project.
SWIFT_CLASS_PROPERTY(@property (nonatomic, class, readonly) void * _Nonnull interposedPointer;)
+ (void * _Nonnull)interposedPointer SWIFT_WARN_UNUSED_RESULT;
SWIFT_CLASS_PROPERTY(@property (nonatomic, class, readonly) BOOL isTracing;)
+ (BOOL)isTracing SWIFT_WARN_UNUSED_RESULT;
- (nonnull instancetype)initWithPrevious:(SwiftTrace * _Nullable)previous subLevels:(NSInteger)subLevels OBJC_DESIGNATED_INITIALIZER;
+ (SwiftTrace * _Nonnull)startNewTraceWithSubLevels:(NSInteger)subLevels;
- (void)mutePreviousUnfiltered;
/// Default pattern of common/problematic symbols to be excluded from tracing
SWIFT_CLASS_PROPERTY(@property (nonatomic, class, readonly, copy) NSString * _Nonnull defaultMethodExclusions;)
+ (NSString * _Nonnull)defaultMethodExclusions SWIFT_WARN_UNUSED_RESULT;
/// Exclude symbols matching this pattern. If not specified
/// a default pattern in swiftTraceDefaultExclusions is used.
SWIFT_CLASS_PROPERTY(@property (nonatomic, class, copy) NSString * _Nullable methodExclusionPattern;)
+ (NSString * _Nullable)methodExclusionPattern SWIFT_WARN_UNUSED_RESULT;
+ (void)setMethodExclusionPattern:(NSString * _Nullable)newValue;
/// Include symbols matching pattern only
SWIFT_CLASS_PROPERTY(@property (nonatomic, class, copy) NSString * _Nullable methodInclusionPattern;)
+ (NSString * _Nullable)methodInclusionPattern SWIFT_WARN_UNUSED_RESULT;
+ (void)setMethodInclusionPattern:(NSString * _Nullable)newValue;
/// In order to be traced, symbol must be included and not excluded
/// \param symbol String representation of method
///
SWIFT_CLASS_PROPERTY(@property (nonatomic, class, copy) SWIFT_METATYPE(Swizzle) _Nullable (^ _Nonnull methodFilter)(NSString * _Nonnull);)
+ (SWIFT_METATYPE(Swizzle) _Nullable (^ _Nonnull)(NSString * _Nonnull))methodFilter SWIFT_WARN_UNUSED_RESULT;
+ (void)setMethodFilter:(SWIFT_METATYPE(Swizzle) _Nullable (^ _Nonnull)(NSString * _Nonnull))newValue;
/// Intercepts and tracess all classes linked into the bundle containing a class.
/// \param theClass the class to specify the bundle, nil implies caller bundle
///
/// \param subLevels levels of unqualified traces to show
///
+ (void)traceBundleWithContaining:(Class _Nullable)theClass subLevels:(NSInteger)subLevels;
/// Trace all user developed classes in the main bundle of an app
/// \param subLevels levels of unqualified traces to show
///
+ (void)traceMainBundleWithSubLevels:(NSInteger)subLevels;
/// Trace a classes defined in a specific bundlePath (executable image)
/// \param bundlePath Path to bundle to trace
///
/// \param subLevels levels of unqualified traces to show
///
+ (void)traceWithBundlePath:(int8_t const * _Nullable)bundlePath subLevels:(NSInteger)subLevels;
/// Lists Swift classes not inheriting from NSObject in an app or framework.
+ (NSArray<Class> * _Nonnull)swiftClassListWithBundlePath:(int8_t const * _Nullable)bundlePath SWIFT_WARN_UNUSED_RESULT;
/// Intercepts and tracess all classes with names matching regexp pattern
/// \param pattern regexp patten to specify classes to trace
///
/// \param subLevels levels of unqualified traces to show
///
+ (void)traceClassesMatchingPattern:(NSString * _Nonnull)pattern subLevels:(NSInteger)subLevels;
/// Underlying implementation of tracing an individual classs.
/// \param aClass the class, the methods of which to trace
///
+ (void)traceWithAClass:(Class _Nonnull)aClass;
/// Trace instances of a particular class including methods of superclass
/// \param aClass the class, the methods of which to trace
///
/// \param subLevels levels of unqualified traces to show
///
+ (void)traceInstancesOfClass:(Class _Nonnull)aClass subLevels:(NSInteger)subLevels;
/// Trace a particular instance only.
/// \param anInstance the class, the methods of which to trace
///
/// \param subLevels levels of unqualified traces to show
///
+ (void)traceWithAnInstance:(id _Nonnull)anInstance subLevels:(NSInteger)subLevels;
+ (void)traceProtocolsInBundleWithContaining:(Class _Nullable)aClass matchingPattern:(NSString * _Nullable)matchingPattern subLevels:(NSInteger)subLevels;
/// follow chain of Sizzles through to find original implementataion
+ (Swizzle * _Nullable)originalSwizzleFor:(IMP _Nonnull)implementation SWIFT_WARN_UNUSED_RESULT;
/// Returns a list of all Swift methods as demangled symbols of a class
/// \param ofClass - class to be dumped
///
+ (NSArray<NSString *> * _Nonnull)methodNamesOfClass:(Class _Nonnull)ofClass SWIFT_WARN_UNUSED_RESULT;
+ (BOOL)undoLastTrace SWIFT_WARN_UNUSED_RESULT;
/// Remove all swizzles applied until now
+ (void)removeAllTraces;
/// Remove all swizzles for this trace
- (void)removeSwizzles;
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_UNAVAILABLE_MSG("-init is unavailable");
@end


@interface SwiftTrace (SWIFT_EXTENSION(SwiftTrace))
@end



@interface SwiftTrace (SWIFT_EXTENSION(SwiftTrace))
/// Add a closure aspect to be called before or after a “Swizzle” is called
/// \param methodName - unmangled name of Method for aspect
///
+ (BOOL)removeAspectWithMethodName:(NSString * _Nonnull)methodName;
/// Add a closure aspect to be called before or after a “Swizzle” is called
/// \param aClass - specifying the class to remove aspect is more efficient
///
/// \param methodName - unmangled name of Method for aspect
///
+ (BOOL)removeAspectWithAClass:(Class _Nonnull)aClass methodName:(NSString * _Nonnull)methodName;
@end


@interface SwiftTrace (SWIFT_EXTENSION(SwiftTrace))
/// Accumulated amount of time spent in each swizzled method.
+ (NSDictionary<NSString *, NSNumber *> * _Nonnull)elapsedTimes SWIFT_WARN_UNUSED_RESULT;
/// Numbers of times each swizzled method has been invoked.
+ (NSDictionary<NSString *, NSNumber *> * _Nonnull)invocationCounts SWIFT_WARN_UNUSED_RESULT;
+ (NSArray<Swizzle *> * _Nonnull)callOrder SWIFT_WARN_UNUSED_RESULT;
@end

@class NSRegularExpression;

@interface SwiftTrace (SWIFT_EXTENSION(SwiftTrace))
/// Function type suffixes at end of mangled symbol name
SWIFT_CLASS_PROPERTY(@property (nonatomic, class, copy) NSArray<NSString *> * _Nonnull swiftFunctionSuffixes;)
+ (NSArray<NSString *> * _Nonnull)swiftFunctionSuffixes SWIFT_WARN_UNUSED_RESULT;
+ (void)setSwiftFunctionSuffixes:(NSArray<NSString *> * _Nonnull)value;
/// Regexp pattern for functions to exclude from interposing
SWIFT_CLASS_PROPERTY(@property (nonatomic, class, strong) NSRegularExpression * _Nullable interposeEclusions;)
+ (NSRegularExpression * _Nullable)interposeEclusions SWIFT_WARN_UNUSED_RESULT;
+ (void)setInterposeEclusions:(NSRegularExpression * _Nullable)value;
+ (void const * _Nullable)interposedWithReplacee:(void const * _Nonnull)replacee SWIFT_WARN_UNUSED_RESULT;
/// Use interposing to trace all methods in a bundle
/// Requires “Other Linker Flags” -Xlinker -interposable
/// Filters using method include/exlxusion class vars.
/// \param inBundlePath path to bundle to interpose
///
/// \param packageName include only methods with prefix
///
/// \param subLevels not currently used
///
+ (void)interposeMethodsInBundlePath:(int8_t const * _Nonnull)inBundlePath packageName:(NSString * _Nullable)packageName subLevels:(NSInteger)subLevels;
/// Use interposing to trace all methods in main bundle
+ (void)traceMainBundleMethods;
/// Use interposing to trace all methods in a framework
/// Doesn’t actually require -Xlinker -interposable
/// \param aClass Class which the framework contains
///
+ (void)traceMethodsInFrameworkContaining:(Class _Nonnull)aClass;
/// Apply a trace to all methods in framesworks in app bundle
+ (void)traceFrameworkMethods;
/// Revert all previous interposes
+ (void)revertInterposes;
@end


@interface SwiftTrace (SWIFT_EXTENSION(SwiftTrace))
/// Hook to intercept all trace output
SWIFT_CLASS_PROPERTY(@property (nonatomic, class, copy) void (^ _Nonnull logOutput)(NSString * _Nonnull);)
+ (void (^ _Nonnull)(NSString * _Nonnull))logOutput SWIFT_WARN_UNUSED_RESULT;
+ (void)setLogOutput:(void (^ _Nonnull)(NSString * _Nonnull))value;
SWIFT_CLASS_PROPERTY(@property (nonatomic, class, copy) NSString * _Nullable traceFilterInclude;)
+ (NSString * _Nullable)traceFilterInclude SWIFT_WARN_UNUSED_RESULT;
+ (void)setTraceFilterInclude:(NSString * _Nullable)pattern;
SWIFT_CLASS_PROPERTY(@property (nonatomic, class, copy) NSString * _Nullable traceFilterExclude;)
+ (NSString * _Nullable)traceFilterExclude SWIFT_WARN_UNUSED_RESULT;
+ (void)setTraceFilterExclude:(NSString * _Nullable)pattern;
@end


@interface SwiftTrace (SWIFT_EXTENSION(SwiftTrace))
/// Enable auto decoration of unknown types
SWIFT_CLASS_PROPERTY(@property (nonatomic, class) BOOL typeLookup;)
+ (BOOL)typeLookup SWIFT_WARN_UNUSED_RESULT;
+ (void)setTypeLookup:(BOOL)value;
/// Decorating “Any” is not fully understood.
SWIFT_CLASS_PROPERTY(@property (nonatomic, class) BOOL decorateAny;)
+ (BOOL)decorateAny SWIFT_WARN_UNUSED_RESULT;
+ (void)setDecorateAny:(BOOL)value;
/// A “pagmatic” limit on the size of structs that will be decorated
SWIFT_CLASS_PROPERTY(@property (nonatomic, class) NSInteger maxIntegerArgumentSlots;)
+ (NSInteger)maxIntegerArgumentSlots SWIFT_WARN_UNUSED_RESULT;
+ (void)setMaxIntegerArgumentSlots:(NSInteger)value;
/// A limit on argument description size
SWIFT_CLASS_PROPERTY(@property (nonatomic, class) NSInteger maxArgumentDescriptionBytes;)
+ (NSInteger)maxArgumentDescriptionBytes SWIFT_WARN_UNUSED_RESULT;
+ (void)setMaxArgumentDescriptionBytes:(NSInteger)value;
/// Default pattern of type names to be excluded from decoration
SWIFT_CLASS_PROPERTY(@property (nonatomic, class, readonly, copy) NSString * _Nonnull defaultLookupExclusions;)
+ (NSString * _Nonnull)defaultLookupExclusions SWIFT_WARN_UNUSED_RESULT;
/// Exclude types with name matching this pattern. If not specified
/// a default regular expression in defaultLookupExclusions is used.
SWIFT_CLASS_PROPERTY(@property (nonatomic, class, copy) NSString * _Nullable lookupExclusionPattern;)
+ (NSString * _Nullable)lookupExclusionPattern SWIFT_WARN_UNUSED_RESULT;
+ (void)setLookupExclusionPattern:(NSString * _Nullable)newValue;
/// Prevent a type fom being decorated
+ (void)makeUntracableWithTypesNamed:(NSArray<NSString *> * _Nonnull)typesNamed;
/// Prepare function pointer that will trace an individual function.
+ (void (* _Nullable)(void))traceWithName:(NSString * _Nonnull)signature vtableSlot:(void (* _Nonnull * _Nullable)(void))vtableSlot objcMethod:(Method _Nullable)objcMethod objcClass:(Class _Nullable)objcClass original:(void const * _Nonnull)original SWIFT_WARN_UNUSED_RESULT;
@end

#if __has_attribute(external_source_symbol)
# pragma clang attribute pop
#endif
#pragma clang diagnostic pop
#endif
// ====================================================================
// End copy of SWiftTrace-Swift.h included here
// ====================================================================

#ifndef SWIFTUISUPPORT
// NSObject bridge for when SwiftTrace is dynamically loaded
@implementation NSObject(SwiftTrace)
+ (NSString *)swiftTraceDefaultMethodExclusions {
    return [SwiftTrace defaultMethodExclusions];
}
+ (NSString *)swiftTraceMethodExclusionPattern {
    return [SwiftTrace methodExclusionPattern];
}
+ (void)setSwiftTraceMethodExclusionPattern:(NSString *)pattern {
    [SwiftTrace setMethodExclusionPattern:pattern];
}
+ (NSString *)swiftTraceMethodInclusionPattern {
    return [SwiftTrace methodInclusionPattern];
}
+ (void)setSwiftTraceMethodInclusionPattern:(NSString *)pattern {
    [SwiftTrace setMethodInclusionPattern:pattern];
}
+ (NSArray<NSString *> * _Nonnull)swiftTraceFunctionSuffixes {
    return [SwiftTrace swiftFunctionSuffixes];
}
+ (void)setSwiftTraceFunctionSuffixes:(NSArray<NSString *> * _Nonnull)value {
    [SwiftTrace setSwiftFunctionSuffixes:value];
}
+ (BOOL)swiftTracing {
    return [SwiftTrace isTracing];
}
+ (void *)swiftTraceInterposed {
    return [SwiftTrace interposedPointer];
}
+ (BOOL)swiftTraceTypeLookup {
    return [SwiftTrace typeLookup];
}
+ (void)setSwiftTraceTypeLookup:(BOOL)enabled {
    [SwiftTrace setTypeLookup:enabled];
    [SwiftTrace setDecorateAny:enabled];
}
+ (void)swiftTrace {
    [SwiftTrace traceWithAClass:self];
}
+ (void)swiftTraceBundle {
    [self swiftTraceBundleWithSubLevels:0];
}
+ (void)swiftTraceBundleWithSubLevels:(int)subLevels {
    [SwiftTrace traceBundleWithContaining:self subLevels:subLevels];
}
+ (void)swiftTraceMainBundle {
    [self swiftTraceMainBundleWithSubLevels:0];
}
+ (void)swiftTraceMainBundleWithSubLevels:(int)subLevels {
    [SwiftTrace traceMainBundleWithSubLevels:subLevels];
}
+ (void)swiftTraceClassesMatchingPattern:(NSString *)pattern {
    [self swiftTraceClassesMatchingPattern:pattern subLevels:0];
}
+ (void)swiftTraceClassesMatchingPattern:(NSString *)pattern subLevels:(intptr_t)subLevels {
    [SwiftTrace traceClassesMatchingPattern:pattern subLevels:subLevels];
}
+ (NSArray<NSString *> *)swiftTraceMethodNames {
    return [SwiftTrace methodNamesOfClass:self];
}
+ (NSArray<NSString *> *)switTraceMethodsNamesOfClass:(Class)aClass {
    return [SwiftTrace methodNamesOfClass:aClass];
}
+ (BOOL)swiftTraceUndoLastTrace {
    return [SwiftTrace undoLastTrace];
}
+ (void)swiftTraceRemoveAllTraces {
    [SwiftTrace removeAllTraces];
}
+ (void)swiftTraceRevertAllInterposes {
    [SwiftTrace revertInterposes];
}
+ (void)swiftTraceInstances {
    [self swiftTraceInstancesWithSubLevels:0];
}
+ (void)swiftTraceInstancesWithSubLevels:(int)subLevels {
    [SwiftTrace traceInstancesOfClass:self subLevels:subLevels];
}
- (void)swiftTraceInstance {
    [self swiftTraceInstanceWithSubLevels:0];
}
- (void)swiftTraceInstanceWithSubLevels:(int)subLevels {
    [SwiftTrace traceWithAnInstance:self subLevels:subLevels];
}
+ (void)swiftTraceProtocolsInBundle {
    [self swiftTraceProtocolsInBundleWithMatchingPattern:nil subLevels:0];
}
+ (void)swiftTraceProtocolsInBundleWithMatchingPattern:(NSString * _Nullable)pattern {
    [self swiftTraceProtocolsInBundleWithMatchingPattern:pattern subLevels:0];
}
+ (void)swiftTraceProtocolsInBundleWithSubLevels:(int)subLevels {
    [self swiftTraceProtocolsInBundleWithMatchingPattern:nil subLevels:subLevels];
}
+ (void)swiftTraceProtocolsInBundleWithMatchingPattern:(NSString *)pattern subLevels:(int)subLevels {
    [SwiftTrace traceProtocolsInBundleWithContaining:self matchingPattern:pattern subLevels:subLevels];
}
+ (void)swiftTraceMethodsInFrameworkContaining:(Class _Nonnull)aClass {
    [SwiftTrace traceMethodsInFrameworkContaining:aClass];
}
+ (void)swiftTraceMainBundleMethods {
    [SwiftTrace traceMainBundleMethods];
}
+ (void)swiftTraceFrameworkMethods {
    [SwiftTrace traceFrameworkMethods];
}
+ (void)swiftTraceMethodsInBundle:(const char * _Nonnull)bundlePath
                      packageName:(NSString * _Nullable)packageName {
    [SwiftTrace interposeMethodsInBundlePath:(const int8_t *)bundlePath
                                 packageName:packageName subLevels:0];
}
+ (void)swiftTraceBundlePath:(const char * _Nonnull)bundlePath {
    [SwiftTrace traceWithBundlePath:(const int8_t *)bundlePath subLevels:0];
}
+ (NSString * _Nullable)swiftTraceFilterInclude {
    return [SwiftTrace traceFilterInclude];
}
+ (void)setSwiftTraceFilterInclude:(NSString * _Nullable)include {
    [SwiftTrace setTraceFilterInclude:include];
}
+ (NSString * _Nullable)swiftTraceFilterExclude {
    return [SwiftTrace traceFilterExclude];
}
+ (void)setSwiftTraceFilterExclude:(NSString * _Nullable)exclude {
    [SwiftTrace setTraceFilterExclude:exclude];
}
+ (NSDictionary<NSString *, NSNumber *> * _Nonnull)swiftTraceElapsedTimes {
    return [SwiftTrace elapsedTimes];
}
+ (NSDictionary<NSString *, NSNumber *> * _Nonnull)swiftTraceInvocationCounts {
    return [SwiftTrace invocationCounts];
}
@end
#endif

#ifdef OBJC_TRACE_TESTER
@implementation ObjcTraceTester: NSObject

- (OSRect)a:(float)a i:(int)i b:(double)b c:(NSString *)c o:o s:(SEL)s {
    return OSMakeRect(1, 2, 3, 4);
}
@end
#endif

NSArray<Class> *objc_classArray() {
    unsigned nc;
    NSMutableArray<Class> *array = [NSMutableArray new];
    if (Class *classes = objc_copyClassList(&nc))
        for (int i=0; i<nc; i++) {
            if (class_getSuperclass(classes[i]))
                [array addObject:classes[i]];
            else {
                const char *name = class_getName(classes[i]);
                printf("%s\n", name);
                if (strcmp(name, "JSExport") && strcmp(name, "_NSZombie_") &&
                    strcmp(name, "__NSMessageBuilder") && strcmp(name, "__NSAtom") &&
                    strcmp(name, "__ARCLite__") && strcmp(name, "__NSGenericDeallocHandler") &&
                    strcmp(name, "CNZombie") && strcmp(name, "_CNZombie_") &&
                    strcmp(name, "NSVB_AnimationFencingSupport"))
                    [array addObject:classes[i]];
            }
        }
    return array;
}

NSMethodSignature *method_getSignature(Method method) {
    const char *encoding = method_getTypeEncoding(method);
    @try {
        return [NSMethodSignature signatureWithObjCTypes:encoding];
    }
    @catch(NSException *err) {
        NSLog(@"*** Unsupported method encoding: %s", encoding);
        return nil;
    }
}

const char *sig_argumentType(id signature, NSUInteger index) {
    return [signature getArgumentTypeAtIndex:index];
}

const char *sig_returnType(id signature) {
    return [signature methodReturnType];
}

const char *swiftUIBundlePath() {
    if (Class AnyText = (__bridge Class)
        dlsym(RTLD_DEFAULT, "$s7SwiftUI14AnyTextStorageCN")) {
        return class_getImageName(AnyText);
    }
    return nullptr;
}

// https://stackoverflow.com/questions/20481058/find-pathname-from-dlopen-handle-on-osx

#import <dlfcn.h>
#import <mach-o/dyld.h>
#import <mach-o/arch.h>
#import <mach-o/getsect.h>
#import <mach-o/nlist.h>

#ifdef __LP64__
typedef struct mach_header_64 mach_header_t;
typedef struct segment_command_64 segment_command_t;
typedef struct nlist_64 nlist_t;
typedef uint64_t sectsize_t;
#define getsectdatafromheader_f getsectdatafromheader_64
#else
typedef struct mach_header mach_header_t;
typedef struct segment_command segment_command_t;
typedef struct nlist nlist_t;
typedef uint32_t sectsize_t;
#define getsectdatafromheader_f getsectdatafromheader
#endif

static char includeObjcClasses[] = {"CN"};
static char objcClassPrefix[] = {"_OBJC_CLASS_$_"};

const char *classesIncludingObjc() {
    return includeObjcClasses;
}

void findSwiftSymbols(const char *bundlePath, const char *suffix,
                      void (^callback)(const void *symval, const char *symname, void *typeref, void *typeend)) {
    for (int32_t i = _dyld_image_count(); i >= 0 ; i--) {
        const char *imageName = _dyld_get_image_name(i);
        if (!(imageName && (!bundlePath || imageName == bundlePath ||
                            strcmp(imageName, bundlePath) == 0)))
            continue;

        const mach_header_t *header =
            (const mach_header_t *)_dyld_get_image_header(i);
        segment_command_t *seg_linkedit = nullptr;
        segment_command_t *seg_text = nullptr;
        struct symtab_command *symtab = nullptr;
        // to filter associated type witness entries
        sectsize_t typeref_size = 0;
        char *typeref_start = getsectdatafromheader_f(header, SEG_TEXT,
                                            "__swift5_typeref", &typeref_size);

        struct load_command *cmd =
            (struct load_command *)((intptr_t)header + sizeof(mach_header_t));
        for (uint32_t i = 0; i < header->ncmds; i++,
             cmd = (struct load_command *)((intptr_t)cmd + cmd->cmdsize)) {
            switch(cmd->cmd) {
                case LC_SEGMENT:
                case LC_SEGMENT_64:
                    if (!strcmp(((segment_command_t *)cmd)->segname, SEG_TEXT))
                        seg_text = (segment_command_t *)cmd;
                    else if (!strcmp(((segment_command_t *)cmd)->segname, SEG_LINKEDIT))
                        seg_linkedit = (segment_command_t *)cmd;
                    break;

                case LC_SYMTAB: {
                    symtab = (struct symtab_command *)cmd;
                    intptr_t file_slide = ((intptr_t)seg_linkedit->vmaddr - (intptr_t)seg_text->vmaddr) - seg_linkedit->fileoff;
                    const char *strings = (const char *)header +
                                               (symtab->stroff + file_slide);
                    nlist_t *sym = (nlist_t *)((intptr_t)header +
                                               (symtab->symoff + file_slide));
                    size_t sufflen = strlen(suffix);
                    BOOL witnessFuncSearch = strcmp(suffix+sufflen-2, "Wl") == 0 ||
                                             strcmp(suffix+sufflen-5, "pACTK") == 0;
                    uint8_t symbolVisibility = witnessFuncSearch ? 0x1e : 0xf;

                    for (uint32_t i = 0; i < symtab->nsyms; i++, sym++) {
                        const char *symname = strings + sym->n_un.n_strx;
                        void *address;

                        if (sym->n_type == symbolVisibility &&
                            ((strncmp(symname, "_$s", 3) == 0 &&
                              strcmp(symname+strlen(symname)-sufflen, suffix) == 0) ||
                             (suffix == includeObjcClasses && strncmp(symname,
                              objcClassPrefix, sizeof objcClassPrefix-1) == 0)) &&
                            (address = (void *)(sym->n_value +
                             (intptr_t)header - (intptr_t)seg_text->vmaddr))) {
                            callback(address, symname+1, typeref_start,
                                     typeref_start + typeref_size);
                        }
                    }

                    if (bundlePath)
                        return;
                }
            }
        }
    }
}

void appBundleImages(void (^callback)(const char *sym, const struct mach_header *, intptr_t slide)) {
    NSBundle *mainBundle = [NSBundle mainBundle];
    const char *mainExecutable = mainBundle.executablePath.UTF8String;
    const char *bundleFrameworks = mainBundle.privateFrameworksPath.UTF8String;
    size_t frameworkPathLength = strlen(bundleFrameworks);

    for (int32_t i = _dyld_image_count()-1; i >= 0 ; i--) {
        const char *imageName = _dyld_get_image_name(i);
//        NSLog(@"findImages: %s", imageName);
        if (strcmp(imageName, mainExecutable) == 0 ||
            strncmp(imageName, bundleFrameworks, frameworkPathLength) == 0 ||
            (strstr(imageName, "/DerivedData/") &&
             strstr(imageName, ".framework/")) ||
            strstr(imageName, "/eval"))
            callback(imageName, _dyld_get_image_header(i),
                     _dyld_get_image_vmaddr_slide(i));
    }
}

const char *callerBundle() {
    void *returnAddress = __builtin_return_address(1);
    Dl_info info;
    if (dladdr(returnAddress, &info))
        return info.dli_fname;
    return nullptr;
}

#if TRY_TO_OPTIMISE_DLADDR
#import <vector>
#import <algorithm>

using namespace std;

class Symbol {
public:
    nlist_t *sym;
    Symbol(nlist_t *sym) {
        this->sym = sym;
    }
};

static bool operator < (Symbol s1, Symbol s2) {
    return s1.sym->n_value < s2.sym->n_value;
}

class Dylib {
    const mach_header_t *header;
    segment_command_t *seg_linkedit = nullptr;
    segment_command_t *seg_text = nullptr;
    struct symtab_command *symtab = nullptr;
    vector<Symbol> symbols;

public:
    char *start = nullptr, *stop = nullptr;
    const char *imageName;

    Dylib(int imageIndex) {
        imageName = _dyld_get_image_name(imageIndex);
        header = (const mach_header_t *)_dyld_get_image_header(imageIndex);
        struct load_command *cmd = (struct load_command *)((intptr_t)header + sizeof(mach_header_t));
        assert(header);

        for (uint32_t i = 0; i < header->ncmds; i++, cmd = (struct load_command *)((intptr_t)cmd + cmd->cmdsize))
        {
            switch(cmd->cmd)
            {
                case LC_SEGMENT:
                case LC_SEGMENT_64:
                    if (!strcmp(((segment_command_t *)cmd)->segname, SEG_TEXT))
                        seg_text = (segment_command_t *)cmd;
                    else if (!strcmp(((segment_command_t *)cmd)->segname, SEG_LINKEDIT))
                        seg_linkedit = (segment_command_t *)cmd;
                    break;

                case LC_SYMTAB:
                    symtab = (struct symtab_command *)cmd;
            }
        }

        const struct section_64 *section = getsectbynamefromheader_64( (const struct mach_header_64 *)header, SEG_TEXT, SECT_TEXT );
        if (section == 0) return;
        start = (char *)(section->addr + _dyld_get_image_vmaddr_slide( (uint32_t)imageIndex ));
        stop = start + section->size;
//        printf("%llx %llx %llx %s\n", section->addr, _dyld_get_image_vmaddr_slide( (uint32_t)imageIndex ), start, imageName);
    }

    bool contains(const void *p) {
        return p >= start && p <= stop;
    }

    int dladdr(const void *ptr, Dl_info *info) {
        intptr_t file_slide = ((intptr_t)seg_linkedit->vmaddr - (intptr_t)seg_text->vmaddr) - seg_linkedit->fileoff;
        const char *strings = (const char *)header + (symtab->stroff + file_slide);
        
        if (symbols.empty()) {
            nlist_t *sym = (nlist_t *)((intptr_t)header + (symtab->symoff + file_slide));

            for (uint32_t i = 0; i < symtab->nsyms; i++, sym++)
                if (sym->n_type == 0xf)
                    symbols.push_back(Symbol(sym));

            sort(symbols.begin(), symbols.end());
        }

        nlist_t nlist;
        nlist.n_value = (intptr_t)ptr - ((intptr_t)header - (intptr_t)seg_text->vmaddr);

        auto it = lower_bound(symbols.begin(), symbols.end(), Symbol(&nlist));
        if (it != symbols.end()) {
            info->dli_fname = imageName;
            info->dli_sname = strings + it->sym->n_un.n_strx + 1;
            return 1;
        }

        return 0;
    }
};

class DylibPtr {
public:
    Dylib *dylib;
    const char *start;
    DylibPtr(Dylib *dylib) {
        if ((this->dylib = dylib))
            this->start = dylib->start;
    }
};

bool operator < (DylibPtr s1, DylibPtr s2) {
    return s1.start < s2.start;
}
#endif

int fast_dladdr(const void *ptr, Dl_info *info) {
#if !TRY_TO_OPTIMISE_DLADDR
    return dladdr(ptr, info);
#else
    static vector<DylibPtr> dylibs;

    if (dylibs.empty()) {
        for (int32_t i = 0; i < _dyld_image_count(); i++)
            dylibs.push_back(DylibPtr(new Dylib(i)));

        sort(dylibs.begin(), dylibs.end());
    }

    if (ptr < dylibs[0].dylib->start)
        return 0;

//    printf("%llx?\n", ptr);
    DylibPtr dylibPtr(NULL);
    dylibPtr.start = (const char *)ptr;
    auto it = lower_bound(dylibs.begin(), dylibs.end(), dylibPtr);
    if (it != dylibs.end()) {
        Dylib *dylib = dylibs[distance(dylibs.begin(), it)-1].dylib;
        if (!dylib || !dylib->contains(ptr))
            return 0;
//        printf("%llx %llx %llx %d %s\n", ptr, dylib->start, dylib->stop, dylib->contains(ptr), info->dli_sname);
        return dylib->dladdr(ptr, info);
    }

    return 0;
#endif
}
