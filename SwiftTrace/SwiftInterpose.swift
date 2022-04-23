//
//  SwiftInterpose.swift
//  SwiftTrace
//
//  Created by John Holdsworth on 23/09/2020.
//  Copyright © 2020 John Holdsworth. All rights reserved.
//
//  $Id: //depot/SwiftTrace/SwiftTrace/SwiftInterpose.swift#69 $
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
    /// to interpose i.e. constructors, functions (methods),
    /// getters of Opaque type (for SwiftUI body properties)
    /// and setters and destructors.
    public static var traceableFunctionSuffixes = ["fC", "F", "Qrvg", "s", "fD"]

    /// Regexp pattern for functions to exclude from interposing
    public static var interposeEclusions: NSRegularExpression? = nil

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
    open class func interpose(aType: Any.Type, methodName: String? = nil,
                              patchClass: Aspect.Type = Aspect.self,
                              onEntry: EntryAspect? = nil,
                              onExit: ExitAspect? = nil,
                              replaceWith: nullImplementationType? = nil) -> Int {
        let bundlePath: UnsafePointer<CChar>?
        if let aClass = aType as? AnyClass {
            bundlePath = class_getImageName(aClass)
            if methodName == nil && onEntry == nil && onExit == nil {
                trace(aClass: aClass) // update vtable
            }
        } else {
            bundlePath = Bundle.main.executablePath?
                .withCString {autoBitCast(strdup($0)!)}
        }

        return interpose(aBundle: bundlePath,
                         methodName: methodName ?? _typeName(aType)+".",
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
                              replaceWith: nullImplementationType? = nil) -> Int {
        var interposes = [dyld_interpose_tuple]()
        var symbols = [UnsafePointer<Int8>]()

        for suffix in traceableFunctionSuffixes {
            findSwiftSymbols(aBundle, suffix) { symval, symname, _, _ in
                if let theMethod = SwiftMeta.demangle(symbol: symname),
                   theMethod.hasPrefix(methodName),
                    let current = interposed(replacee: symval),
                    let interpose = patchClass.init(name: theMethod,
                         original: OpaquePointer(current),
                         onEntry: onEntry, onExit: onExit,
                         replaceWith: replaceWith) {
                    interposes.append(dyld_interpose_tuple(
                        replacement: autoBitCast(interpose.forwardingImplementation),
                        replacee: current))
                    symbols.append(symname)
                }
            }
        }

        return apply(interposes: interposes, symbols: symbols)
    }

    /// Has symbol already been interposed?
    /// - Parameter replacee: original function
    /// - Returns: pointer to end of chain of any interposes that have been aplied
    open class func interposed(replacee: UnsafeRawPointer) -> UnsafeRawPointer? {
        let interposed = NSObject.swiftTraceInterposed.bindMemory(to:
            [UnsafeRawPointer : UnsafeRawPointer].self, capacity: 1)
        var current = replacee
        while let replacement = interposed.pointee[current] {
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
                                           subLevels: Int = 0) -> Int {
        startNewTrace(subLevels: subLevels)
        var interposes = [dyld_interpose_tuple]()
        var symbols = [UnsafePointer<Int8>]()

        for suffix in traceableFunctionSuffixes {
            findSwiftSymbols(inBundlePath, suffix) {
                symval, symname,  _, _ in
                if let methodName = SwiftMeta.demangle(symbol: symname),
                    packageName == nil ||
                        methodName.hasPrefix(packageName!+".") ||
                        methodName.hasPrefix("(extension in \(packageName!))"),
                    interposeEclusions?.matches(methodName) != true,
                    let factory = methodFilter(methodName),
                    let current = interposed(replacee: symval),
                    let method = factory.init(name: methodName,
                                              original: OpaquePointer(current)) {
//                    print(interposes.count, methodName, String(cString: symname))
                    interposes.append(dyld_interpose_tuple(
                        replacement: autoBitCast(method.forwardingImplementation),
                        replacee: current))
                    symbols.append(symname)
                }
            }
        }

        bundlesInterposed.insert(String(cString: inBundlePath))
        return apply(interposes: interposes, symbols: symbols)
    }

    /// Use interposing to trace all methods in main bundle
    @objc open class func traceMainBundleMethods() -> Int {
        return interposeMethods(inBundlePath: Bundle.main.executablePath!)
    }

    /// Use interposing to trace all methods in a framework
    /// Doesn't actually require -Xlinker -interposable
    /// - Parameters:
    ///   - aClass: Class which the framework contains
    @objc open class func traceMethods(inFrameworkContaining aClass: AnyClass) -> Int {
        return interposeMethods(inBundlePath: class_getImageName(aClass)!)
    }

    /// Apply a trace to all methods in framesworks in app bundle
    @objc open class func traceFrameworkMethods() -> Int {
        var replaced = 0
        appBundleImages { imageName, _, _ in
            if strstr(imageName, ".framework") != nil {
                replaced += interposeMethods(inBundlePath: imageName)
                trace(bundlePath: imageName)
            }
        }
        return replaced
    }

    /// Legacy entry point that can use either fishhook or "dyld_dynamic_interpose"
    open class func apply(interposes: [dyld_interpose_tuple],
                          symbols: [UnsafePointer<Int8>], onInjection:
                    ((UnsafePointer<mach_header>, intptr_t) -> Void)? = nil)
        -> Int {
        var rebindings = record(interposes: interposes, symbols: symbols)
        #if true // use fishhook now
        return apply(rebindings: &rebindings, onInjection: onInjection).count
        #else // Original way using dyld_dynamic_interpose
        interposes.withUnsafeBufferPointer { interposes in
            let debugInterpose = getenv("DEBUG_INTERPOSE") != nil
            var lastLoaded = true

            appBundleImages { (imageName, header, _) in
                if lastLoaded {
                    onInjection?(header)
                    lastLoaded = false
                }

                if debugInterpose {
                    for symno in 0 ..< interposes.count {
                        print("Interposing: \(SwiftMeta.demangle(symbol: symbols[symno]) ?? String(cString: symbols[symno]))")
                        dyld_dynamic_interpose(header,
                                               interposes.baseAddress!+symno, 1)
                    }
                } else {
                    dyld_dynamic_interpose(header,
                                           interposes.baseAddress!, interposes.count)
                }
            }
        }
        #endif
    }

    /// record interposed so they can be untraced and combine with symbols to create rebindings
    open class func record(interposes: [dyld_interpose_tuple],
                           symbols: [UnsafePointer<Int8>]) -> [rebinding] {
        let interposed = NSObject.swiftTraceInterposed.bindMemory(to:
            [UnsafeRawPointer : UnsafeRawPointer].self, capacity: 1)
        for toapply in interposes
            where toapply.replacee != toapply.replacement {
            interposed.pointee[toapply.replacee] = toapply.replacement
        }
        var rebindings = [rebinding]()
        for i in 0..<interposes.count {
            rebindings.append(rebinding(name: symbols[i],
                replacement: UnsafeMutableRawPointer(mutating:
                interposes[i].replacement), replaced: nil))
        }
        return rebindings
    }

    /// Use fishhook to apply interposes returning an array of symbols that were patched
    open class func apply(rebindings: inout [rebinding], onInjection:
        ((UnsafePointer<mach_header>, intptr_t) -> Void)? = nil)
        -> [UnsafePointer<Int8>] {
        var interposed = [UnsafePointer<Int8>]()
        rebindings.withUnsafeMutableBufferPointer {
            let buffer = $0.baseAddress!, count = $0.count
            var lastLoaded = true
            appBundleImages { path, header, slide in
                if lastLoaded {
                    onInjection?(header, slide)
                    lastLoaded = false
                }

                interposed += apply(rebindings: buffer, count: count,
                                    header: header, slide: slide)
            }
        }
        return interposed
    }

    /// Use fishhook to apply interposes in an image returning an array of symbols that were patched
    open class func apply(rebindings: UnsafeMutablePointer<rebinding>, count: Int,
                          header: UnsafePointer<mach_header>, slide: intptr_t)
        -> [UnsafePointer<Int8>] {
        var interposed = [UnsafePointer<Int8>]()
        for i in 0..<count {
            rebindings[i].replaced =
                UnsafeMutablePointer(cast: &rebindings[i].replaced)
        }
        rebind_symbols_image(UnsafeMutableRawPointer(mutating: header),
                             slide, rebindings, count)
        for i in 0..<count {
            if rebindings[i].replaced !=
                UnsafeMutablePointer(cast: &rebindings[i].replaced) {
                interposed.append(rebindings[i].name)
            }
        }
        return interposed
    }

    /// Revert all previous interposes
    @objc open class func revertInterposes() {
        let interposed = NSObject.swiftTraceInterposed.bindMemory(to:
            [UnsafeRawPointer : UnsafeRawPointer].self, capacity: 1)
        let replacements = Set(interposed.pointee.values)
        var reverses = [dyld_interpose_tuple]()

        for (replacee, replacement) in interposed.pointee {
            if !replacements.contains(replacee) {
                var current: UnsafeRawPointer? = replacement
                while current != nil {
                    reverses.append(dyld_interpose_tuple(
                        replacement: replacee, replacee: current!))
                    current = interposed.pointee[current!]
                }
            }
        }

        #if true // use fishhook
        var info = Dl_info()
        var rebindings = [rebinding]()
        for interpose in reverses {
            if dladdr(interpose.replacement, &info) != 0 {
                rebindings.append(rebinding(name: info.dli_sname,
                    replacement: UnsafeMutableRawPointer(mutating:
                    interpose.replacement), replaced: nil))
            }
        }
        rebind_symbols(&rebindings, rebindings.count)
        #else
        appBundleImages { (imageName, header) in
            dyld_dynamic_interpose(header, reverses, reverses.count)
        }
        #endif

        interposed.pointee.removeAll()
    }
}
#endif
