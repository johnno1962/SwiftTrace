//
//  SwiftTrace.h
//  SwiftTrace
//
//  Created by John Holdsworth on 10/06/2016.
//  Copyright © 2016 John Holdsworth. All rights reserved.
//
//  Repo: https://github.com/johnno1962/SwiftTrace
//  $Id: //depot/SwiftTrace/SwiftTrace/SwiftTrace.h#8 $
//

#import <Foundation/Foundation.h>

//! Project version number for SwiftTrace.
FOUNDATION_EXPORT double SwiftTraceVersionNumber;

//! Project version string for SwiftTrace.
FOUNDATION_EXPORT const unsigned char SwiftTraceVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <SwiftTrace/PublicHeader.h>

#ifdef __cplusplus
extern "C" {
#endif
    IMP _Nonnull imp_implementationForwardingToTracer(void * _Nonnull info, IMP _Nonnull onEntry, IMP _Nonnull onExit);
    void findPureSwiftClasses(const char * _Nullable path, void (^ _Nonnull callback)(void * _Nonnull symbol));
#ifdef __cplusplus
}
#endif

