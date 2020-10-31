//
//  SwiftInterpose.swift
//  SwiftTrace
//
//  Created by John Holdsworth on 23/09/2020.
//  Copyright © 2020 John Holdsworth. All rights reserved.
//
//  $Id: //depot/SwiftTrace/SwiftTrace/SwiftInterpose.swift#41 $
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
    public static var excludeFunction = NSRegularExpression(regexp:
        "^\\w+\\.\\w+\\(|SwiftTrace")

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
        dladdr(autoBitCast(aType), &info)
        interpose(aBundle: info.dli_fname, methodName: methodName,
                  patchClass: patchClass, onEntry: onEntry, onExit: onExit,
                  replaceWith: replaceWith)
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
            findSwiftSymbols(aBundle, suffix, { symval, symname, _, _ in
                if demangle(symbol: symname) == methodName,
                    let current = interposed(replacee: symval),
                    let method = patchClass.init(name: methodName,
                         original: OpaquePointer(current),
                         onEntry: onEntry, onExit: onExit,
                         replaceWith: replaceWith) {
                    interposes.append(dyld_interpose_tuple(
                        replacement: autoBitCast(method.forwardingImplementation()),
                        replacee: current))
                }
            })
        }

        apply(interposes: interposes, symbols: [methodName])
    }

    open class func interposed(replacee: UnsafeRawPointer) -> UnsafeRawPointer? {
        var current = replacee
        while let replacement = interposed[current] {
            current = replacement
        }
        return current
    }

    /// Use interposing to trace all methods in a bundle
    /// Requires "Other Linker Flags" -Xlinker -interposable
    /// Filters using method include/exlxusion class vars.
    /// - Parameters:
    ///   - inBundlePath: path to bundle to interpose
    ///   - packageName: include only methods with prefix
    ///   - subLevels: not currently used
    @objc open class func interposeMethods(inBundlePath: UnsafePointer<Int8>,
                                           packageName: String? = nil,
                                           subLevels: Int = 0) {
        startNewTrace(subLevels: subLevels)
        var interposes = [dyld_interpose_tuple]()
        var symbols = [String]()

        for suffix in swiftFunctionSuffixes {
            findSwiftSymbols(inBundlePath, suffix) {
                symval, symname,  _, _ in
                if let methodName = demangle(symbol: symname),
                    packageName == nil ||
                        methodName.hasPrefix(packageName!+".") ||
                        methodName.hasPrefix("(extension in \(packageName!))"),
                    excludeFunction.firstMatch(in: methodName, options: [],
                        range: NSMakeRange(0, methodName.utf16.count)) == nil,
                    let factory = methodFilter(methodName),
                    let current = interposed(replacee: symval),
                    let method = factory.init(name: methodName,
                                              original: OpaquePointer(current)) {
//                    print(interposes.count, methodName)
                    interposes.append(dyld_interpose_tuple(
                        replacement: autoBitCast(method.forwardingImplementation()),
                        replacee: current))
                    symbols.append(methodName)
                }
            }
        }

        apply(interposes: interposes, symbols: symbols)

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
    @objc open class func traceFrameworkMethods() {
        appBundleImages { imageName, _ in
            if strstr(imageName, ".framework") != nil {
                interposeMethods(inBundlePath: imageName)
                trace(bundlePath: imageName)
            }
        }
    }

    open class func apply(interposes: [dyld_interpose_tuple],
                          symbols: [String]? = nil,
                          onInjection: ((UnsafePointer<mach_header>) -> Void)? = nil) {
        for toapply in interposes {
            interposed[toapply.replacee] = toapply.replacement
        }
        interposes.withUnsafeBufferPointer { interposes in
            let debugInterpose = getenv("DEBUG_INTERPOSE") != nil
            var lastLoaded = true

            appBundleImages { (imageName, header) in
                if lastLoaded {
                    onInjection?(header)
                    lastLoaded = false
                }

                if debugInterpose {
                    for symno in 0 ..< interposes.count {
                        print("Interposing: \(symbols?[symno] ?? "unknown")")
                        dyld_dynamic_interpose(header,
                                               interposes.baseAddress!+symno, 1)
                    }
                } else {
                    dyld_dynamic_interpose(header,
                                           interposes.baseAddress!, interposes.count)
                }
            }
        }
    }

    /// Revert all previous interposes
    @objc open class func revertInterposes() {
        let replacements = Set(interposed.values)
        var reverses = [dyld_interpose_tuple]()

        for (replacee, replacement) in interposed {
            if !replacements.contains(replacee) {
                var current: UnsafeRawPointer? = replacement
                while current != nil {
                    reverses.append(dyld_interpose_tuple(
                        replacement: replacee, replacee: current!))
                    current = interposed[current!]
                }
            }
        }

        appBundleImages { (imageName, header) in
            dyld_dynamic_interpose(header, reverses, reverses.count)
        }
        
        interposed.removeAll()
    }
}
#endif
