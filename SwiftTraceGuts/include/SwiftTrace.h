//
//  SwiftTrace.h
//  SwiftTrace
//
//  Created by John Holdsworth on 10/06/2016.
//  Copyright © 2016 John Holdsworth. All rights reserved.
//
//  Repo: https://github.com/johnno1962/SwiftTrace
//  $Id: //depot/SwiftTrace/SwiftTraceGuts/include/SwiftTrace.h#35 $
//

#ifndef SWIFTTRACE_H
#define SWIFTTRACE_H

#import <Foundation/Foundation.h>

//! Project version number for SwiftTrace.
FOUNDATION_EXPORT double SwiftTraceVersionNumber;

//! Project version string for SwiftTrace.
FOUNDATION_EXPORT const unsigned char SwiftTraceVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <SwiftTrace/PublicHeader.h>

/**
 Objective-C inteface to SwftTrace as a category on NSObject
 as a summary of the functionality available. Intended to be
 used from Swift where SwifTrace has been provided from a
 dynamically loaded bundle, for example, from InjectionIII.

 Each trace superceeds any previous traces when they where
 not explicit about the class or instance being traced
 (see swiftTraceIntances and swiftTraceInstance). For
 example, the following code:

 UIView.swiftTraceBundle()
 UITouch.traceInstances(withSubLevels: 3)

 Will put a trace on all of the UIKit frameowrk which is then
 refined by the specific trace for only instances of class
 UITouch to be printed and any calls to UIKit made by those
 methods up to three levels deep.
 */
@interface NSObject(SwiftTrace)
/**
 The default regexp used to exclude certain methods from tracing.
 */
+ (NSString * _Nonnull)swiftTraceDefaultMethodExclusions;
/**
 Optional filter of methods to be included in subsequent traces.
 */
@property (nonatomic, class, copy) NSString *_Nullable swiftTraceMethodInclusionPattern;
/**
 Provide a regular expression to exclude methods.
 */
@property (nonatomic, class, copy) NSString *_Nullable swiftTraceMethodExclusionPattern;
/**
 Real time control over methods to be traced (regular expressions)
 */
@property (nonatomic, class, copy) NSString *_Nullable swiftTraceFilterInclude;
@property (nonatomic, class, copy) NSString *_Nullable swiftTraceFilterExclude;
/**
 Function type suffixes at end of mangled symbol name.
 */
@property (nonatomic, class, copy) NSArray<NSString *> * _Nonnull swiftTraceFunctionSuffixes;
/** Are we tracing? */
@property (readonly, class) BOOL swiftTracing;
/** lookup unknonw types */
@property (class) BOOL swiftTraceTypeLookup;
/**
 Class will be traced (as opposed to swiftTraceInstances which
 will trace methods declared in super classes as well and only
 for instances of that particular class not any subclasses.)
*/
+ (void)swiftTrace;
/**
 Trace all methods defined in classes contained in the main
 executable of the application.
 */
+ (void)swiftTraceMainBundle;
/**
 Trace all methods of classes in the main bundle but also
 up to subLevels of calls made by those methods if a more
 general trace has already been placed on them.
 */
+ (void)swiftTraceMainBundleWithSubLevels:(int)subLevels;
/**
 Add a trace to all methods of all classes defined in the
 bundle or framework that contains the receiving class.
 */
+ (void)swiftTraceBundle;
/**
 Add a trace to all methods of all classes defined in the
 all frameworks in the app bundle.
 */
+ (void)swiftTraceFrameworkMethods;
/**
 Output a trace of methods defined in the bundle containing
 the reciever and up to subLevels of calls made by them.
 */
+ (void)swiftTraceBundleWithSubLevels:(int)subLevels;
/**
 Trace classes in the application that have names matching
 the regular expression.
 */
+ (void)swiftTraceClassesMatchingPattern:(NSString * _Nonnull)pattern;
/**
 Trace classes in the application that have names matching
 the regular expression and subLevels of cals they make to
 classes that have already been traced.
 */
+ (void)swiftTraceClassesMatchingPattern:(NSString * _Nonnull)pattern subLevels:(intptr_t)subLevels;
/**
 Return an array of the demangled names of methods declared
 in the reciving Swift class that can be traced.
 */
+ (NSArray<NSString *> * _Nonnull)swiftTraceMethodNames;
/**
Return an array of the demangled names of methods declared
in the Swift class provided.
*/
+ (NSArray<NSString *> * _Nonnull)switTraceMethodsNamesOfClass:(Class _Nonnull)aClass;
/**
 Trace instances of the specific receiving class (including
 the methods of its superclasses.)
 */
+ (void)swiftTraceInstances;
/**
 Trace instances of the specific receiving class (including
 the methods of its superclasses and subLevels of previously
 traced methods called by those methods.)
 */
+ (void)swiftTraceInstancesWithSubLevels:(int)subLevels;
/**
 Trace a methods (including those of all superclasses) for
 a particular instance only.
 */
- (void)swiftTraceInstance;
/**
 Trace methods including those of all superclasses for a 
 particular instance only and subLevels of calls they make.
 */
- (void)swiftTraceInstanceWithSubLevels:(int)subLevels;
/**
 Trace all protocols contained in the bundle declaring the receiver class
 */
+ (void)swiftTraceProtocolsInBundle;
/**
 Trace protocols in bundle with qualifications
 */
+ (void)swiftTraceProtocolsInBundleWithMatchingPattern:(NSString * _Nullable)pattern;
+ (void)swiftTraceProtocolsInBundleWithSubLevels:(int)subLevels;
+ (void)swiftTraceProtocolsInBundleWithMatchingPattern:(NSString * _Nullable)pattern subLevels:(int)subLevels;
/**
 Use interposing to trace all methods in main bundle
 Use swiftTraceInclusionPattern, swiftTraceExclusionPattern to filter
 */
+ (void)swiftTraceMethodsInFrameworkContaining:(Class _Nonnull)aClass;
+ (void)swiftTraceMainBundleMethods;
+ (void)swiftTraceMethodsInBundle:(const char * _Nonnull)bundlePath
                      packageName:(NSString * _Nullable)packageName;
+ (void)swiftTraceBundlePath:(const char * _Nonnull)bundlePath;
/**
 Remove most recent trace
 */
+ (BOOL)swiftTraceUndoLastTrace;
/**
 Remove all tracing swizles.
 */
+ (void)swiftTraceRemoveAllTraces;
/**
 Remove all interposes from tracing.
 */
+ (void)swiftTraceRevertAllInterposes;
/**
 Total elapsed time by traced method.
 */
+ (NSDictionary<NSString *, NSNumber *> * _Nonnull)swiftTraceElapsedTimes;
/**
 Invocation counts by traced method.
 */
+ (NSDictionary<NSString *, NSNumber *> * _Nonnull)swiftTraceInvocationCounts;
@end

/// All types have this structure generated by the compiler
/// From which you can extract the size and stride.
struct ValueWitnessTable {
    IMP _Nonnull initializeBufferWithCopyOfBuffer, destroy,
        initializeWithCopy, assignWithCopy,
        initializeWithTake, assignWithTake,
        getEnumTagSinglePayload, storeEnumTagSinglePayload;
    size_t size, stride;
    uintptr_t flags;
};

#import <mach-o/loader.h>
#import <objc/runtime.h>
#import <dlfcn.h>

typedef void (*SignatureOfFunctionTakingGenericValue)(const void * _Nullable valuePtr,
              void * _Nonnull outPtr, const void * _Nonnull metaType, const void * _Nullable witnessTable);

#ifdef __cplusplus
extern "C" {
#endif
    IMP _Nonnull imp_implementationForwardingToTracer(void * _Nonnull patch, IMP _Nonnull onEntry, IMP _Nonnull onExit);
    NSArray<Class> * _Nonnull objc_classArray(void);
    NSMethodSignature * _Nullable method_getSignature(Method _Nonnull Method);
    const char * _Nonnull sig_argumentType(id _Nonnull signature, NSUInteger index);
    const char * _Nonnull sig_returnType(id _Nonnull signature);
    const char * _Nonnull classesIncludingObjc();
    void findSwiftSymbols(const char * _Nullable path, const char * _Nonnull suffix, void (^ _Nonnull callback)(const void * _Nonnull address, const char * _Nonnull symname, void * _Nonnull typeref, void * _Nonnull typeend));
    void appBundleImages(void (^ _Nonnull callback)(const char * _Nonnull imageName, const struct mach_header * _Nonnull header));
    struct ValueWitnessTable * _Nonnull getValueWitnessTable(struct ValueWitnessTable * _Nonnull * _Nonnull metaType);
    void thunkToGeneric(SignatureOfFunctionTakingGenericValue _Nonnull genericFunction,
                        const void * _Nullable valuePtr, void * _Nonnull outPtr,
                        const void * _Nonnull metaType, const void * _Nullable witnessTable);
    const char * _Nullable callerBundle(void);
    int fast_dladdr(const void * _Nonnull, Dl_info * _Nonnull);
#ifdef __cplusplus
}
#endif

struct dyld_interpose_tuple {
  const void * _Nonnull replacement;
  const void * _Nonnull replacee;
};

/// Very handy albeit private API on dynamic loader.
void dyld_dynamic_interpose(
    const struct mach_header * _Nonnull mh,
    const struct dyld_interpose_tuple array[_Nonnull],
    size_t count) __attribute__((weak_import));


#ifdef __IPHONE_OS_VERSION_MIN_REQUIRED
#import <CoreGraphics/CGGeometry.h>
#define OSRect CGRect
#define OSMakeRect CGRectMake
#else
#define OSRect NSRect
#define OSMakeRect NSMakeRect
#endif

@interface ObjcTraceTester: NSObject

- (OSRect)a:(float)a i:(int)i b:(double)b c:(NSString *_Nullable)c o:o s:(SEL _Nullable)s;

@end
#endif
