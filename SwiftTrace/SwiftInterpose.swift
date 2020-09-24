//
//  SwiftInterpose.swift
//  SwiftTrace
//
//  Created by John Holdsworth on 23/09/2020.
//  Copyright © 2020 John Holdsworth. All rights reserved.
//
//  $Id: //depot/SwiftTrace/SwiftTrace/SwiftInterpose.swift#6 $
//

import Foundation

#if DEBUG
extension SwiftTrace {

    public static var swiftFunctionSuffixes = ["fC", "yF", "lF", "tF", "Qrvg"]

    /// Previous interposes need to be tracked
    public static var interposed = [UnsafeMutableRawPointer: UnsafeMutableRawPointer]()

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
    /// - Parameters:
    ///   - bundlePath: path to bundle to interpose
    ///   - pattern: optional regex methodName should match
    ///   - excluding: optional regex that would exclude methods
    @objc open class func traceMethods(bundlePath: UnsafePointer<Int8>,
                       pattern: String? = nil, excluding: String? = nil) {
        var interposes = [dyld_interpose_tuple]()

        for suffix in swiftFunctionSuffixes {
            findSwiftSymbols(bundlePath, suffix) {
                symval, symname,  _, _ in
                if let methodName = demangle(symbol: symname),
                        pattern?.stMatches(methodName) != false &&
                        excluding?.stMatches(methodName) != true &&
                        !"^(\\w+\\.\\w+\\()".stMatches(methodName) &&
                        !(methodName.contains(".getter :") && !methodName.hasSuffix("some")),
                    let method = swizzleFactory.init(name: methodName,
                         original: OpaquePointer(symval)) {
                    let current = interposed[symval] ?? symval
                    let hook = unsafeBitCast(
                        method.forwardingImplementation(),
                        to: UnsafeMutableRawPointer.self)
//                    print(interposes.count, methodName)
                    interposes.append(dyld_interpose_tuple(
                        replacement: hook, replacee: current))
                    interposed[current] = hook
                }
            }
        }

        interposes.withUnsafeBufferPointer { interposes in
            appBundleImages { (imageName, header) in
                for symno in 0..<interposes.count {
                    dyld_dynamic_interpose(header,
                                           interposes.baseAddress!+symno, 1)
                }
            }
        }
    }

    /// Use interposing to trace all methods in main bundle
    /// - Parameters:
    ///   - pattern: optional regex methodName should match
    ///   - excluding: optional regex that would exclude methods
    @objc open class func traceMainBundleMethods(
        pattern: String? = nil, excluding: String? = nil) {
        traceMethods(bundlePath: Bundle.main.executablePath!,
                     pattern: pattern, excluding: excluding)
    }
}

fileprivate extension String {
    func stMatches(_ target: String) -> Bool {
        return target.replacingOccurrences(of: self,
            with: "___", options: .regularExpression) != target
    }
}
#endif
