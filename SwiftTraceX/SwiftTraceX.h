//
//  SwiftTraceX.h
//  SwiftTraceX
//
//  Created by John Holdsworth on 13/06/2016.
//  Copyright © 2016 John Holdsworth. All rights reserved.
//

#import <Cocoa/Cocoa.h>

//! Project version number for SwiftTraceX.
FOUNDATION_EXPORT double SwiftTraceXVersionNumber;

//! Project version string for SwiftTraceX.
FOUNDATION_EXPORT const unsigned char SwiftTraceXVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <SwiftTraceX/PublicHeader.h>

#ifdef __cplusplus
extern "C" {
#endif
    IMP imp_implementationForwardingToTracer(void *info, IMP tracer);
#ifdef __cplusplus
}
#endif

