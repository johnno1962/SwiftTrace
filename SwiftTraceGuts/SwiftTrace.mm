//
//  SwiftTrace.m
//  SwiftTrace
//
//  Repo: https://github.com/johnno1962/SwiftTrace
//  $Id: //depot/SwiftTrace/SwiftTraceGuts/SwiftTrace.mm#1 $
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

extern char xt_forwarding_trampoline_page, xt_forwarding_trampolines_start,
            xt_forwarding_trampolines_next, xt_forwarding_trampolines_end;

static OSSpinLock lock = OS_SPINLOCK_INIT;

// trampoline implementation specific stuff...
typedef struct {
#if !defined(__LP64__)
    IMP tracer;
#endif
    void *patch; // Pointer to SwiftTrace.Patch instance retained elsewhere
} XtraceTrampolineDataBlock;

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
static const int32_t SPLForwardingTrampolineInstructionCount = 84;
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

    XtraceTrampolineDataBlock trampolineData[numberOfTrampolinesPerPage];

    int32_t trampolineInstructions[SPLForwardingTrampolineInstructionCount];
    SPLForwardingTrampolineEntryPointBlock trampolineEntryPoints[numberOfTrampolinesPerPage];
} SPLForwardingTrampolinePage;

//check_compile_time(sizeof(SPLForwardingTrampolineEntryPointBlock) == sizeof(XtraceTrampolineDataBlock));
//check_compile_time(sizeof(SPLForwardingTrampolinePage) == 2 * PAGE_SIZE);
//check_compile_time(offsetof(SPLForwardingTrampolinePage, trampolineInstructions) == PAGE_SIZE);

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

IMP imp_implementationForwardingToTracer(void *patch, IMP onEntry, IMP onExit)
{
    OSSpinLockLock(&lock);

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
    
    OSSpinLockUnlock(&lock);
    
    return implementation;
}

// From here on additions to the original code for use by "SwiftTrace".

@class Swizzle;
@interface SwiftTrace : NSObject
/// Format for ms of time spend in method
@property (nonatomic, class, copy) NSString * _Nonnull timeFormat;
+ (NSString * _Nonnull)timeFormat ;
+ (void)setTimeFormat:(NSString * _Nonnull)value;
/// Format for idenifying class instance
@property (nonatomic, class, copy) NSString * _Nonnull identifyFormat;
+ (NSString * _Nonnull)identifyFormat ;
+ (void)setIdentifyFormat:(NSString * _Nonnull)value;
/// Indentation amogst different call levels on the stack
@property (nonatomic, class, copy) NSString * _Nonnull traceIndent;
+ (NSString * _Nonnull)traceIndent ;
+ (void)setTraceIndent:(NSString * _Nonnull)value;
/// Class used to create “Sizzle” instances representing a member function
@property (nonatomic, class) Swizzle *_Nonnull swizzleFactory;
+ (Swizzle * _Nonnull)swizzleFactory ;
+ (void)setSwizzleFactory:(Swizzle * _Nonnull)value;
@property (nonatomic, class, strong) SwiftTrace * _Nonnull lastSwiftTrace;
+ (SwiftTrace * _Nonnull)lastSwiftTrace ;
+ (void)setLastSwiftTrace:(SwiftTrace * _Nonnull)value;
/// Linked list of previous traces
@property (nonatomic, readonly, strong) SwiftTrace * _Nullable previousSwiftTrace;
/// Trace only instances of a particular class
@property (nonatomic) Class _Nullable classFilter;
/// Trace only a particular instance
@property (nonatomic) intptr_t instanceFilter;
/// Trace only a particular instance
@property (nonatomic, readonly) NSInteger subLevels;
- (nonnull instancetype)initWithPrevious:(SwiftTrace * _Nullable)previous subLevels:(NSInteger)subLevels;
+ (SwiftTrace * _Nonnull)startNewTraceWithSubLevels:(NSInteger)subLevels;
@property (nonatomic, class, readonly) NSInteger noFilter;
+ (NSInteger)noFilter;
@property (nonatomic, class, readonly) NSInteger noObject;
+ (NSInteger)noObject;
- (void)mutePreviousUnfiltered;
/// default pattern of symbols to be excluded from tracing
@property (nonatomic, class, readonly, copy) NSString * _Nonnull defaultMethodExclusions;
+ (NSString * _Nonnull)defaultMethodExclusions;
@property (nonatomic, class, strong) NSRegularExpression * _Nullable exclusionRegexp;
+ (NSRegularExpression * _Nullable)exclusionRegexp;
+ (void)setExclusionRegexp:(NSRegularExpression * _Nullable)value;
@property (nonatomic, class, strong) NSRegularExpression * _Nullable inclusionRegexp;
+ (NSRegularExpression * _Nullable)inclusionRegexp;
+ (void)setInclusionRegexp:(NSRegularExpression * _Nullable)value;
/// Exclude symbols matching this pattern. If not specified
/// a default pattern in swiftTraceDefaultExclusions is used.
/// \param pattern regexp for symbols to exclude
///
@property (nonatomic, class, copy) NSString * _Nullable methodExclusionPattern;
+ (NSString * _Nullable)methodExclusionPattern;
+ (void)setMethodExclusionPattern:(NSString * _Nullable)newValue;
/// Include symbols matching pattern only
/// \param pattern regexp for symbols to include
///
@property (nonatomic, class, copy) NSString * _Nullable methodInclusionPattern;
+ (NSString * _Nullable)methodInclusionPattern;
+ (void)setMethodInclusionPattern:(NSString * _Nullable)newValue;
/// in order to be traced, symbol must be included and not excluded
/// \param symbol String representation of method
///
@property (nonatomic, class, copy) Swizzle *_Nullable (^ _Nonnull methodFilter)(NSString * _Nonnull);
+ (Swizzle *_Nullable (^ _Nonnull)(NSString * _Nonnull))methodFilter;
/// Intercepts and tracess all classes linked into the bundle containing a class.
/// \param theClass the class to specify the bundle
///
/// \param subLevels levels of unqualified traces to show
///
+ (void)traceBundleWithContaining:(Class _Nonnull)theClass subLevels:(NSInteger)subLevels;
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
+ (NSArray<Class> * _Nonnull)swiftClassListWithBundlePath:(int8_t const * _Nonnull)bundlePath;
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
/// follow chain of Sizzles through to find original implementataion
+ (Swizzle * _Nullable)originalSwizzleFor:(IMP _Nonnull)implementation;
/// Returns a list of all Swift methods as demangled symbols of a class
/// \param ofClass - class to be dumped
///
+ (NSArray<NSString *> * _Nonnull)methodNamesOfClass:(Class _Nonnull)ofClass;
+ (BOOL)undoLastTrace;
/// Remove all swizzles applied until now
+ (void)removeAllTraces;
/// Remove all swizzles for this trace
- (void)removeSwizzles;
/// Intercept Objective-C class’ methods using swizzling
/// \param aClass meta-class or class to be swizzled
///
/// \param which “+” for class methods, “-” for instance methods
///
+ (void)traceWithObjcClass:(Class _Nonnull)aClass which:(NSString * _Nonnull)which;
/// Very old code intended to prevent property accessors from being traced
/// \param aClass class of method
///
/// \param sel selector of method being checked
///
+ (BOOL)dontSwizzlePropertyWithAClass:(Class _Nonnull)aClass sel:(SEL _Nonnull)sel;
@end

@implementation NSObject(SwiftTrace)
+ (NSString *)swiftTraceDefaultMethodExclusions {
    return [SwiftTrace defaultMethodExclusions];
}
+ (NSString *)swiftTraceExclusionPattern {
    return [SwiftTrace methodExclusionPattern];
}
+ (void)swiftTraceSetExclusionPattern:(NSString *)pattern {
    [SwiftTrace setMethodExclusionPattern:pattern];
}
+ (NSString *)swiftTraceInclusionPattern {
    return [SwiftTrace methodInclusionPattern];
}
+ (void)swiftTraceSetInclusionPattern:(NSString *)pattern {
    [SwiftTrace setMethodInclusionPattern:pattern];
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
@end

@implementation ObjcTraceTester: NSObject

- (OSRect)a:(float)a i:(int)i b:(double)b c:(NSString *)c o:o s:(SEL)s {
    return OSMakeRect(1, 2, 3, 4);
}

@end

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
                    strcmp(name, "CNZombie") && strcmp(name, "_CNZombie_"))
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
#else
typedef struct mach_header mach_header_t;
typedef struct segment_command segment_command_t;
typedef struct nlist nlist_t;
#endif

void findPureSwiftClasses(const char *path, void (^callback)(void *aClass)) {
    for (int32_t i = _dyld_image_count(); i >= 0 ; i--) {
        const mach_header_t *header = (const mach_header_t *)_dyld_get_image_header(i);
        const char *imageName = _dyld_get_image_name(i);
        if (imageName && (imageName == path || strcmp(imageName, path) == 0)) {
            segment_command_t *seg_linkedit = NULL;
            segment_command_t *seg_text = NULL;
            struct symtab_command *symtab = NULL;

            struct load_command *cmd = (struct load_command *)((intptr_t)header + sizeof(mach_header_t));
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

                    case LC_SYMTAB: {
                        symtab = (struct symtab_command *)cmd;
                        intptr_t file_slide = ((intptr_t)seg_linkedit->vmaddr - (intptr_t)seg_text->vmaddr) - seg_linkedit->fileoff;
                        const char *strings = (const char *)header + (symtab->stroff + file_slide);
                        nlist_t *sym = (nlist_t *)((intptr_t)header + (symtab->symoff + file_slide));

                        for (uint32_t i = 0; i < symtab->nsyms; i++, sym++) {
                            const char *sptr = strings + sym->n_un.n_strx;
                            void *aClass;
                            if (sym->n_type == 0xf &&
                                strncmp(sptr, "_$s", 3) == 0 &&
                                strcmp(sptr+strlen(sptr)-2, "CN") == 0 &&
                                (aClass = (void *)(sym->n_value + (intptr_t)header - (intptr_t)seg_text->vmaddr))) {
                                callback(aClass);
                            }
                        }

                        return;
                    }
                }
            }
        }
    }
}

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
    segment_command_t *seg_linkedit = NULL;
    segment_command_t *seg_text = NULL;
    struct symtab_command *symtab = NULL;
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
