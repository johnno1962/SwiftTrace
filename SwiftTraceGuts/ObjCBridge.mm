//
//  ObjCBridge.mm
//  SwiftTrace
//
//  Created by John Holdsworth on 21/01/2022.
//  Repo: https://github.com/johnno1962/SwiftTrace
//  $Id: //depot/SwiftTrace/SwiftTraceGuts/ObjCBridge.mm#3 $
//

#if DEBUG || !DEBUG_ONLY
#import "include/SwiftTrace.h"

#ifndef SWIFTUISUPPORT
// Bridge via NSObject for when SwiftTrace is dynamically loaded
#import "SwiftTrace-Swift.h"

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
+ (NSInteger)swiftTraceMethodsInFrameworkContaining:(Class _Nonnull)aClass {
    return [SwiftTrace traceMethodsInFrameworkContaining:aClass];
}
+ (NSInteger)swiftTraceMainBundleMethods {
    return [SwiftTrace traceMainBundleMethods];
}
+ (NSInteger)swiftTraceFrameworkMethods {
    return [SwiftTrace traceFrameworkMethods];
}
+ (NSInteger)swiftTraceMethodsInBundle:(const char * _Nonnull)bundlePath
                           packageName:(NSString * _Nullable)packageName {
    return [SwiftTrace interposeMethodsInBundlePath:(const int8_t *)bundlePath
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
+ (STSymbolFilter _Nonnull)swiftTraceSymbolFilter {
    return [SwiftTrace injectableSymbol];
}
+ (void)setSwiftTraceSymbolFilter:(STSymbolFilter _Nonnull)filter {
    [SwiftTrace setInjectableSymbol:filter];
}
+ (NSDictionary<NSString *, NSNumber *> * _Nonnull)swiftTraceElapsedTimes {
    return [SwiftTrace elapsedTimes];
}
+ (NSDictionary<NSString *, NSNumber *> * _Nonnull)swiftTraceInvocationCounts {
    return [SwiftTrace invocationCounts];
}
+ (NSString * _Nullable)swiftTraceDemangle:(char const * _Nonnull)symbol {
    return [SwiftMeta demangleWithSymbol:(const int8_t *)symbol];
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
#endif
