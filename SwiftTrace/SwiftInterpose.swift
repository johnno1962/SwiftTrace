//
//  SwiftInterpose.swift
//  SwiftTrace
//
//  Created by John Holdsworth on 23/09/2020.
//  Copyright © 2020 John Holdsworth. All rights reserved.
//
//  $Id: //depot/SwiftTrace/SwiftTrace/SwiftInterpose.swift#21 $
//
//  Extensions to SwiftTrace using dyld_dynamic_interpose
//  =====================================================
//

import Foundation
#if SWIFT_PACKAGE
import SwiftTraceGuts
#endif

#if os(macOS) || os(iOS) || os(tvOS)
extension SwiftTrace {

    /// Function type suffixes at end of mangled symbol name
    public static var swiftFunctionSuffixes = ["fC", "yF", "lF", "tF", "Qrvg"]

    /// Regexp pattern for functions to exclude from interposing
    public static var excludeFunction = NSRegularExpression(regexp: "^(\\w+\\.\\w+\\()")


    /// "interpose" aspects onto Swift function name.
    /// If the symbol is not in a different framework
    /// requires the linker flags -Xlinker -interposable.
    /// - Parameters:
    ///   - aType: A type in the bundle continaing the function
    ///   - methodName: The full name of the function
    ///   - patchClass: normally not required
    ///   - onEntry: closure called on entry
    ///   - onExit: closure called on exit
    ///   - replaceWith: optional replacement for function
    open class func interpose(aType: Any.Type, methodName: String,
                              patchClass: Aspect.Type = Aspect.self,
                              onEntry: EntryAspect? = nil,
                              onExit: ExitAspect? = nil,
                              replaceWith: nullImplementationType? = nil) {
        var info = Dl_info()
        dladdr(unsafeBitCast(aType, to: UnsafeRawPointer.self), &info)
        interpose(aBundle: info.dli_fname, methodName: methodName,
                  patchClass: patchClass,
                  onEntry: onEntry, onExit: onExit, replaceWith: replaceWith)
    }

    /// "interpose" aspects onto Swift function name.
    /// If the symbol is not in a different framework
    /// requires the linker flags -Xlinker -interposable.
    /// - Parameters:
    ///   - aBundle: Patch to framework containing function
    ///   - methodName: The full name of the function
    ///   - patchClass: normally not required
    ///   - onEntry: closure called on entry
    ///   - onExit: closure called on exit
    ///   - replaceWith: optional replacement for function
    open class func interpose(aBundle: UnsafePointer<Int8>?, methodName: String,
                              patchClass: Aspect.Type = Aspect.self,
                              onEntry: EntryAspect? = nil,
                              onExit: ExitAspect? = nil,
                              replaceWith: nullImplementationType? = nil) {
        var interposes = [dyld_interpose_tuple]()

        for suffix in swiftFunctionSuffixes {
            findSwiftSymbols(aBundle, suffix, { symval, symname,  _, _ in
                if demangle(symbol: symname) == methodName,
                    let method = patchClass.init(name: methodName,
                         original: OpaquePointer(symval),
                         onEntry: onEntry, onExit: onExit,
                         replaceWith: replaceWith) {
                    let hook = method.forwardingImplementation()
                    interposes.append(dyld_interpose_tuple(
                        replacement: unsafeBitCast(hook, to: UnsafeRawPointer.self),
                        replacee: symval))
                }
            })
        }

        interposes.withUnsafeBufferPointer { interposes in
            appBundleImages { (imageName, header) in
                dyld_dynamic_interpose(header, interposes.baseAddress!,
                                       interposes.count)
            }
        }
    }

    /// Use interposing to trace all methods in a bundle
    /// Requires "Other Linker Flags" -Xlinker -interposable
    /// Filters using method include/exlxusion class vars.
    /// - Parameters:
    ///   - inBundlePath: path to bundle to interpose
    @objc open class func interposeMethods(inBundlePath: UnsafePointer<Int8>,
                                           subLevels: Int = 0) {
        startNewTrace(subLevels: subLevels)
        var interposes = [dyld_interpose_tuple]()
        var symbols = [String]()

        for suffix in swiftFunctionSuffixes {
            findSwiftSymbols(inBundlePath, suffix) {
                symval, symname,  _, _ in
                if let methodName = demangle(symbol: symname),
                    excludeFunction.firstMatch(in: methodName, options: [],
                        range: NSMakeRange(0, methodName.utf16.count)) == nil &&
                    !methodName.contains("SwiftTrace") &&
                    !(methodName.contains(".getter :") && !methodName.hasSuffix("some")),
                    let factory = methodFilter(methodName),
                    let method = factory.init(name: methodName,
                         original: OpaquePointer(symval)) {
                    let current = interposed[symval] ?? symval
                    let hook = unsafeBitCast(
                        method.forwardingImplementation(),
                        to: UnsafeMutableRawPointer.self)
//                    print(interposes.count, methodName)
                    interposes.append(dyld_interpose_tuple(
                        replacement: hook, replacee: current))
                    interposed[current] = hook
                    symbols.append(methodName)
                }
            }
        }

        interposes.withUnsafeBufferPointer { interposes in
            let debugInterpose = getenv("DEBUG_INTERPOSE") != nil
            appBundleImages { (imageName, header) in
                for symno in 0..<interposes.count {
                    if debugInterpose {
                        print("Interposing: \(symbols[symno])")
                    }
                    dyld_dynamic_interpose(header,
                                           interposes.baseAddress!+symno, 1)
                }
            }
        }

        bundlesInterposed.insert(String(cString: inBundlePath))
    }

    /// Use interposing to trace all methods in main bundle
    @objc open class func traceMainBundleMethods() {
        interposeMethods(inBundlePath: Bundle.main.executablePath!)
    }

    /// Use interposing to trace all methods in a framework
    /// Doesn't actually require -Xlinker -interposable
    /// - Parameters:
    ///   - aClass: Class which the framework contains
    @objc open class func traceMethods(inFrameworkContaining aClass: AnyClass) {
        interposeMethods(inBundlePath: class_getImageName(aClass)!)
    }

    /// Apply a trace to all methods in framesworks in app bundle
    /// - Parameter subLevels: levels of unqualified traces to show
    @objc class func traceFrameworkMethods() {
        appBundleImages { imageName, _ in
            if strstr(imageName, ".framework") != nil {
                interposeMethods(inBundlePath: imageName)
                trace(bundlePath: imageName)
            }
        }
    }
}
#endif
