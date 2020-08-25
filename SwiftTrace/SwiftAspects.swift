//
//  SwiftAspects.swift
//  SwiftTrace
//
//  Created by John Holdsworth on 20/04/2020.
//  Copyright © 2020 John Holdsworth. All rights reserved.
//
//  Repo: https://github.com/johnno1962/SwiftTrace
//  $Id: //depot/SwiftTrace/SwiftTrace/SwiftAspects.swift#9 $
//
//  Add aspects to Swift methods
//  ============================
//

import Foundation

extension SwiftTrace {

    public typealias EntryAspect = (_ swizzle: Swizzle, _ stack: inout EntryStack) -> Void
    public typealias ExitAspect = (_ swizzle: Swizzle, _ stack: inout ExitStack) -> Void

    /**
        Add a closure aspect to be called before or after a "Swizzle" is called
        - parameter methodName: - unmangled name of Method for aspect
        - parameter onEntry: - closure to be called before "Swizzle" is called
        - parameter onExit: - closure to be called after "Swizzle" returns
     */
    open class func addAspect(methodName: String,
                              patchClass: Aspect.Type = Aspect.self,
                              onEntry: EntryAspect? = nil,
                              onExit: ExitAspect? = nil,
                              replaceWith: nullImplementationType? = nil) -> Bool {
        return forAllClasses {
            (aClass, stop) in
            stop = addAspect(aClass: aClass, methodName: methodName,
                             onEntry: onEntry, onExit: onExit, replaceWith: replaceWith)
        }
    }

    /**
        Add a closure aspect to be called before or after a "Swizzle" is called
        - parameter toClass: - specifying the class to add aspect is more efficient
        - parameter methodName: - unmangled name of Method for aspect
        - parameter onEntry: - closure to be called before "Swizzle" is called
        - parameter onExit: - closure to be called after "Swizzle" returns
     */
    open class func addAspect(aClass: AnyClass, methodName: String,
                              patchClass: Aspect.Type = Aspect.self,
                              onEntry: EntryAspect? = nil,
                              onExit: ExitAspect? = nil,
                              replaceWith: nullImplementationType? = nil) -> Bool {
        return iterateMethods(ofClass: aClass) {
            (name, vtableSlot, stop) in
            if name == methodName, let method = patchClass.init(name: name,
                        vtableSlot: vtableSlot, onEntry: onEntry,
                        onExit: onExit, replaceWith: replaceWith) {
                vtableSlot.pointee = method.forwardingImplementation()
                stop = true
            }
        }
    }

    public static var swiftFunctionSuffixes = ["fC", "yF", "lF", "tF", "Qrvg"]

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
            findImages { (imageName, header) in
                dyld_dynamic_interpose(header, interposes.baseAddress!,
                                       interposes.count)
            }
        }
    }

    /**
        Add a closure aspect to be called before or after a "Swizzle" is called
        - parameter methodName: - unmangled name of Method for aspect
     */
    @discardableResult
    open class func removeAspect(methodName: String) -> Bool {
        return forAllClasses {
            (aClass, stop) in
            stop = removeAspect(aClass: aClass, methodName: methodName)
        }
    }

    /**
        Add a closure aspect to be called before or after a "Swizzle" is called
        - parameter aClass: - specifying the class to remove aspect is more efficient
        - parameter methodName: - unmangled name of Method for aspect
     */
    @discardableResult
    open class func removeAspect(aClass: AnyClass, methodName: String) -> Bool {
        return iterateMethods(ofClass: aClass) {
            (name, vtableSlot, stop) in
            if name == methodName,
                let swizzle = SwiftTrace.lastSwiftTrace.activeSwizzles[unsafeBitCast(vtableSlot.pointee, to: IMP.self)] {
                swizzle.remove()
                stop = true
            }
        }
    }

    /**
        Internal class used in the implementation of aspects
     */
    open class Aspect: Decorated {

        let entryAspect: EntryAspect?
        let exitAspect: ExitAspect?

        public required init?(name: String, vtableSlot: UnsafeMutablePointer<SIMP>? = nil, original: OpaquePointer? = nil,
                              onEntry: EntryAspect? = nil, onExit: ExitAspect? = nil,
                              replaceWith: nullImplementationType? = nil) {
            self.entryAspect = onEntry
            self.exitAspect = onExit
            super.init(name: name, vtableSlot: vtableSlot,
                       original: original, replaceWith: replaceWith)
        }

        public required init?(name: String, vtableSlot: UnsafeMutablePointer<SIMP>? = nil, objcMethod: Method? = nil, original: OpaquePointer? = nil, replaceWith: nullImplementationType? = nil) {
            fatalError("Aspect.init(name:vtableSlot:objcMethod:replaceWith:) should not be used")
        }

        open override func onEntry(stack: inout EntryStack) {
            entryAspect?(self, &stack)
        }

        open override func onExit(stack: inout ExitStack) {
            exitAspect?(self, &stack)
        }
    }
}

