//
//  SwiftTrace.h
//  SwiftTrace
//
//  Created by John Holdsworth on 10/06/2016.
//  Copyright © 2016 John Holdsworth. All rights reserved.
//
//  Repo: https://github.com/johnno1962/SwiftTrace
//  $Id: //depot/SwiftTrace/SwiftTrace/SwiftTrace.h#18 $
//

#import <Foundation/Foundation.h>

//! Project version number for SwiftTrace.
FOUNDATION_EXPORT double SwiftTraceVersionNumber;

//! Project version string for SwiftTrace.
FOUNDATION_EXPORT const unsigned char SwiftTraceVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <SwiftTrace/PublicHeader.h>

#import <dlfcn.h>
#import <objc/runtime.h>

#ifdef __cplusplus
extern "C" {
#endif
    IMP _Nonnull imp_implementationForwardingToTracer(void * _Nonnull patch, IMP _Nonnull onEntry, IMP _Nonnull onExit);
    NSArray<Class> * _Nonnull objc_classArray();
    NSMethodSignature * _Nonnull method_getSignature(Method _Nonnull Method);
    const char * _Nonnull sig_argumentType(id _Nonnull signature, NSUInteger index);
    const char * _Nonnull sig_returnType(id _Nonnull signature);
    void findPureSwiftClasses(const char * _Nullable path, void (^ _Nonnull callback)(void * _Nonnull symbol));
    int fast_dladdr(const void * _Nonnull, Dl_info * _Nonnull);
#ifdef __cplusplus
}
#endif

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
