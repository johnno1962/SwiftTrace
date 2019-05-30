//
//  SwiftTrace.swift
//  SwiftTraceApp
//
//  Created by John Holdsworth on 10/06/2016.
//  Copyright © 2016 John Holdsworth. All rights reserved.
//
//  Repo: https://github.com/johnno1962/SwiftTrace
//  $Id: //depot/SwiftTrace/SwiftTrace/SwiftTrace.swift#108 $
//

import Foundation

/**
    NSObject convenience methods
 */
extension NSObject {

    /**
        Trace the bundle containing the target class
     */
    public class func traceBundle() {
        SwiftTrace.traceBundle(containing: self)
    }

    /**
        Trace the target class
     */
    public class func traceClass() {
        SwiftTrace.trace(aClass: self)
    }

}

/**
    Base class for SwiftTrace api through it's public class methods
 */
open class SwiftTrace: NSObject {

    /**
        Class used to create "Patch" instances representing a member function
     */
    public static var patchFactory = Patch.self

    /**
        Class used to create "Invocation" instances representing a
        specific call to a member function on the "ThreadLocal" stack.
     */
    public static var defaultInvocationFactory = Patch.Invocation.self

    /**
        Type of "null implementation" replacing methods actual implementation
     */
    public typealias nullImplementationType = @convention(c) (_ patch: Patch) -> AnyObject?

    /**
     Strace "info" instance used to store information about a patch on a method
     */
    open class Patch: NSObject {

        /** Dictionary of patch objects created by trampoline */
        static var active = [IMP: Patch]()

        /** follow chain of Patches through to find original patch */
        open class func originalPatch(for implementation: IMP) -> Patch? {
            var implementation = implementation
            var patch: Patch?
            while active[implementation] != nil {
                patch = active[implementation]
                implementation = patch!.implementation
            }
            return patch
        }

       /** string representing Swift or Objective-C method to user */
        public let name: String

        /** pointer to original function implementing method */
        var implementation: IMP

        /** vtable slot patched for unpatching */
        var vtableSlot: UnsafeMutablePointer<SIMP>?

        /** Original objc method swizzled */
        let objcMethod: Method?

        /** Closure to call instead of original implementation */
        public let nullImplmentation: nullImplementationType?

        /**
         designated initialiser
         - parameter name: string representing method being traced
         - parameter vtableSlot: pointer to vtable slot patched
         - parameter objcMethod: pointer to original Method patched
         - parameter justReturn: implementation to replace that of class
         */
        public required init?(name: String,
                              vtableSlot: UnsafeMutablePointer<SIMP>? = nil, objcMethod: Method? = nil,
                              justReturn: nullImplementationType? = nil) {
            self.name = name
            self.vtableSlot = vtableSlot
            self.objcMethod = objcMethod
            if let vtableSlot = vtableSlot {
                implementation = vtableSlot
                    .withMemoryRebound(to: IMP.self, capacity: 1, { $0 }).pointee
            }
            else {
                implementation = method_getImplementation(objcMethod!)
            }
            nullImplmentation = justReturn
        }

        /** Called from assembly code on entry to Patched method */
        static var onEntry: @convention(c) (_ patch: Patch, _ returnAddress: UnsafeRawPointer,
            _ stackPointer: UnsafeMutablePointer<UInt64>) -> IMP? = {
                (patch, returnAddress, stackPointer) -> IMP? in
                let local = ThreadStack.threadLocal()
                let invocation = patch.invocationFactory.init(stackDepth: local.stack.count, patch: patch,
                                              returnAddress: returnAddress, stackPointer: stackPointer )
                local.stack.append(invocation)
                patch.onEntry(stack: invocation.entryStack)
                return patch.nullImplmentation != nil ?
                    unsafeBitCast(patch.nullImplmentation, to: IMP.self) : patch.implementation
        }

        /** Called from assembly code when Patched method returns */
        static var onExit: @convention(c) () -> UnsafeRawPointer = {
            let invocation = Invocation.current!
            invocation.patch.onExit(stack: invocation.exitStack)
            ThreadStack.threadLocal().stack.removeLast()
            return invocation.returnAddress
        }

        /**
            Return a unique pointer to a trampoline that will callback the oneEntry()
            and onExit() method in this class
         */
        func forwardingImplementation() -> SIMP {
            /* create trampoline */
            let impl = imp_implementationForwardingToTracer(unsafeBitCast(self, to: UnsafeMutableRawPointer.self),
                                unsafeBitCast(Patch.onEntry, to: IMP.self), unsafeBitCast(Patch.onExit, to: IMP.self))
            Patch.active[impl] = self // track Patches by trampoline and retain them
            return unsafeBitCast(impl, to: SIMP.self)
        }

        /**
         method called before trampoline enters the target "Patch"
         */
        open func onEntry(stack: UnsafeMutablePointer<EntryStack>) {
        }

        /**
         method called after trampoline exists the target "Patch"
         */
        open func onExit(stack: UnsafeMutablePointer<ExitStack>) {
            if let invocation = Invocation.current {
                let elapsed = Date.timeIntervalSinceReferenceDate - invocation.timeEntered
                print("\(String(repeating: "  ", count: invocation.stackDepth))\(name) \(String(format: "%.1fms", elapsed * 1000.0))")
            }
        }

        /**
         Class used to create a specific "Invocation" of the "Patch" on entry
         */
        open var invocationFactory: Invocation.Type {
            return defaultInvocationFactory
        }

        /**
         The inner invocation instance on the stack of the current thread.
         */
        open func invocation() -> Invocation! {
            return Invocation.current
        }

        /**
            Remove this patch
         */
        open func remove() {
            if let vtableSlot = vtableSlot {
                vtableSlot.pointee = unsafeBitCast(implementation, to: SIMP.self)
            }
            else if let objcMethod = objcMethod {
                method_setImplementation(objcMethod, implementation)
            }
        }

        /**
            Remove all patches recursively
         */
        open func removeAll() {
            (Patch.originalPatch(for: implementation) ?? self).remove()
        }

        /** find "self" for the current invocation */
        open func getSelf<T>() -> T {
            return unsafeBitCast(invocation().swiftSelf, to: T.self)
        }

        /** Interpret stack Pointer as for incoming arguments */
        open var arguments: UnsafeMutablePointer<EntryStack> {
            return invocation().entryStack
        }

        /** Interpret stack Pointer as for outgoing return values */
        open var returns: UnsafeMutablePointer<ExitStack> {
            return invocation().exitStack
        }

        /** convert arguments (return results) as a specifi type */
        open func cast<IN,OUT>(_ arg: UnsafeMutablePointer<IN>, as: OUT.Type) -> UnsafeMutablePointer<OUT> {
            return arg.withMemoryRebound(to: OUT.self, capacity: 1) { $0 }
        }

        /** pointer to memory for return of struct */
        open func structReturn<T>() -> UnsafeMutablePointer<T> {
            return invocation().structReturn!.assumingMemoryBound(to: T.self)
        }

        /**
         Represents a specific call to a member function on the "ThreadLocal" stack
         */
        public class Invocation {

            /** Time call was started */
            public let timeEntered: Double

            /** Number of calls above this on the stack of the current thread */
            public let stackDepth: Int

            /** "Patch" related to this call */
            public let patch: Patch

            /** Original return address of call to trampoline */
            public let returnAddress: UnsafeRawPointer

            /** Architecture depenent place on stack where arguments stored */
            public let entryStack: UnsafeMutablePointer<EntryStack>

            public var structReturn: UnsafeMutableRawPointer? = nil
            
            public var exitStack: UnsafeMutablePointer<ExitStack> {
                return entryStack.withMemoryRebound(to: ExitStack.self, capacity: 1) { $0 }
            }

            /** "self" for method invocations */
            public let swiftSelf: intptr_t

            /** for use relaying data from entry to exit */
            public var userInfo: AnyObject?

            /**
             designated initialiser
             - parameter stackDepth: number of calls that have been made on the stack
             - parameter patch: associated Patch instance
             - parameter returnAddress: adress in process trampoline was called from
             - parameter stackPointer: stack pointer of thread with saved registers
             */
            public required init(stackDepth: Int, patch: Patch, returnAddress: UnsafeRawPointer,
                                 stackPointer: UnsafeMutablePointer<UInt64>) {
                timeEntered = Date.timeIntervalSinceReferenceDate
                self.stackDepth = stackDepth
                self.patch = patch
                self.returnAddress = returnAddress
                self.entryStack = patch.cast(stackPointer, as: EntryStack.self)
                self.swiftSelf = patch.objcMethod != nil ?
                    self.entryStack.pointee.intArg1 : self.entryStack.pointee.swiftSelf
                self.structReturn = UnsafeMutableRawPointer(bitPattern: self.entryStack.pointee.structReturn)
            }

            /**
             The inner invocation instance on the current thread.
             */
            public static var current: Invocation! {
                return ThreadStack.threadLocal().stack.last
            }
        }

        /**
         Class implementing thread local storage to arrange a call stack
         */
        public class ThreadStack {

            private static var keyVar: pthread_key_t = 0

            private static var pthreadKey: pthread_key_t = {
                let ret = pthread_key_create(&keyVar, {
                    #if os(Linux) || os(Android)
                    Unmanaged<ThreadStack>.fromOpaque($0!).release()
                    #else
                    Unmanaged<ThreadStack>.fromOpaque($0).release()
                    #endif
                })
                if ret != 0 {
                    NSLog("Could not pthread_key_create: %s", strerror(ret))
                }
                return keyVar
            }()

            /**
             The stack of Invocations logged on this thread
             */
            public var stack = [Invocation]()

            /**
             Returns an instance of ThreadLocal specific to the current thread
             */
            static public func threadLocal() -> ThreadStack {
                let keyVar = ThreadStack.pthreadKey
                if let existing = pthread_getspecific(keyVar) {
                    return Unmanaged<ThreadStack>.fromOpaque(existing).takeUnretainedValue()
                }
                else {
                    let unmanaged = Unmanaged.passRetained(ThreadStack())
                    let ret = pthread_setspecific(keyVar, unmanaged.toOpaque())
                    if ret != 0 {
                        NSLog("Could not pthread_setspecific: %s", strerror(ret))
                    }
                    return unmanaged.takeUnretainedValue()
                }
            }
        }
    }

    #if arch(arm64)
    /**
        Stack layout on entry from xt_forwarding_trampoline_arm64.s
     */
    public struct EntryStack {
        static let maxFloatArgs = 8
        static let maxIntArgs = 8

        public var swiftSelf: intptr_t = 0 // x20
        public var structReturn: intptr_t = 0 // x8
        public var floatArg1: Double = 0.0
        public var floatArg2: Double = 0.0
        public var floatArg3: Double = 0.0
        public var floatArg4: Double = 0.0
        public var floatArg5: Double = 0.0
        public var floatArg6: Double = 0.0
        public var floatArg7: Double = 0.0
        public var floatArg8: Double = 0.0
        public var intArg1: intptr_t = 0
        public var intArg2: intptr_t = 0
        public var intArg3: intptr_t = 0
        public var intArg4: intptr_t = 0
        public var intArg5: intptr_t = 0
        public var intArg6: intptr_t = 0
        public var intArg7: intptr_t = 0
        public var intArg8: intptr_t = 0
        public var framePointer: intptr_t = 0
        public var linkRegister: intptr_t = 0

        public var invocation: Patch.Invocation! {
            return Patch.Invocation.current
        }
    }

    /**
        Stack layout on exit from xt_forwarding_trampoline_arm64.s
     */
    public struct ExitStack {
        static let returnRegs = 4

        public var swiftSelf: intptr_t = 0 // x20
        public var structReturn: intptr_t = 0 // x8
        public var floatReturn1: Double = 0.0
        public var floatReturn2: Double = 0.0
        public var floatReturn3: Double = 0.0
        public var floatReturn4: Double = 0.0
        public var d4: Double = 0.0
        public var d5: Double = 0.0
        public var d6: Double = 0.0
        public var d7: Double = 0.0
        public var intReturn1: intptr_t = 0
        public var intReturn2: intptr_t = 0
        public var intReturn3: intptr_t = 0
        public var intReturn4: intptr_t = 0
        public var x4: intptr_t = 0
        public var x5: intptr_t = 0
        public var x6: intptr_t = 0
        public var x7: intptr_t = 0
        public var thrownError: intptr_t = 0
        public var framePointer: intptr_t = 0

        public var invocation: Patch.Invocation! {
            return Patch.Invocation.current
        }
        mutating func genericReturn<T>(patch: Patch? = nil) -> UnsafeMutablePointer<T> {
            if MemoryLayout<T>.size > MemoryLayout<intptr_t>.size * ExitStack.returnRegs {
                structReturn = unsafeBitCast(invocation.structReturn, to: Int.self)
                return invocation.structReturn!.assumingMemoryBound(to: T.self)
            }
            else {
                return (patch ?? invocation!.patch).cast(&intReturn1, as: T.self)
            }
        }
        mutating public func getReturn<T>() -> T {
            return genericReturn().pointee
        }
        mutating public func setReturn<T>(value: T) {
            intReturn1 = 0
            intReturn2 = 0
            return genericReturn().pointee = value
        }
        mutating public func stringReturn() -> String {
            print(self)
            return getReturn()
        }
        mutating public func setReturn(string: String) {
            setReturn(value: string)
        }
    }
    #else // x86_64
    /**
        Stack layout on entry from xt_forwarding_trampoline_x64.s
     */
    public struct EntryStack {
        static let maxFloatArgs = 8
        static let maxIntArgs = 6

        public var floatArg1: Double = 0.0
        public var floatArg2: Double = 0.0
        public var floatArg3: Double = 0.0
        public var floatArg4: Double = 0.0
        public var floatArg5: Double = 0.0
        public var floatArg6: Double = 0.0
        public var floatArg7: Double = 0.0
        public var floatArg8: Double = 0.0
        public var framePointer: intptr_t = 0
        public var intArg1: intptr_t = 0    // rdi
        public var intArg2: intptr_t = 0    // rsi
        public var intArg3: intptr_t = 0    // rcx
        public var intArg4: intptr_t = 0    // rdx
        public var intArg5: intptr_t = 0    // r8
        public var intArg6: intptr_t = 0    // r9
        public var r10: intptr_t = 0
        public var r12: intptr_t = 0
        public var swiftSelf: intptr_t = 0  // r13
        public var r14: intptr_t = 0
        public var r15: intptr_t = 0
        public var structReturn: intptr_t = 0 // rax
        public var rbx: intptr_t = 0

        public var invocation: Patch.Invocation! {
            return Patch.Invocation.current
        }
    }

    /**
        Stack layout on exit from xt_forwarding_trampoline_x64.s
     */
    public struct ExitStack {
        static let returnRegs = 4

        public var stackShift1: intptr_t = 0
        public var stackShift2: intptr_t = 0
        public var floatReturn1: Double = 0.0 // xmm0
        public var floatReturn2: Double = 0.0 // xmm1
        public var floatReturn3: Double = 0.0 // xmm2
        public var floatReturn4: Double = 0.0 // xmm3
        public var xmm4: Double = 0.0
        public var xmm5: Double = 0.0
        public var xmm6: Double = 0.0
        public var xmm7: Double = 0.0
        public var framePointer: intptr_t = 0
        public var rdi: intptr_t = 0
        public var rsi: intptr_t = 0
        public var r9: intptr_t = 0
        public var r10: intptr_t = 0
        public var thrownError: intptr_t = 0 // r12
        public var swiftSelf: intptr_t = 0  // r13
        public var r14: intptr_t = 0
        public var r15: intptr_t =  0
        public var rbx: intptr_t = 0

        public var structReturn: UnsafeMutableRawPointer? {
            return UnsafeMutableRawPointer(bitPattern: intReturn1)!
        }
        public var intReturn1: intptr_t = 0 // rax (also struct Return)
        public var intReturn2: intptr_t = 0 // rdx
        public var intReturn3: intptr_t = 0 // rcx
        public var intReturn4: intptr_t = 0 // r8
        public var invocation: Patch.Invocation! {
            return Patch.Invocation.current
        }
        mutating func genericReturn<T>(patch: Patch? = nil) -> UnsafeMutablePointer<T> {
            if MemoryLayout<T>.size > MemoryLayout<intptr_t>.size * ExitStack.returnRegs {
                intReturn1 = unsafeBitCast(invocation.structReturn, to: Int.self)
                return invocation.structReturn!.assumingMemoryBound(to: T.self)
            }
            else {
                return (patch ?? invocation!.patch).cast(&intReturn1, as: T.self)
            }
        }
        mutating public func getReturn<T>() -> T {
            return genericReturn().pointee
        }
        mutating public func setReturn<T>(value: T) {
            intReturn1 = 0
            intReturn2 = 0
            return genericReturn().pointee = value
        }
        mutating public func stringReturn() -> String {
            return getReturn()
        }
        mutating public func setReturn(string: String) {
            setReturn(value: string)
        }
    }
    #endif

    /**
     default pattern of symbols to be excluded from tracing
     */
    static public let defaultMethodExclusions = "\\.getter|retain]|release]|_tryRetain]|.cxx_destruct]|initWithCoder|_isDeallocating]|^\\+\\[(Reader_Base64|UI(NibStringIDTable|NibDecoder|CollectionViewData|WebTouchEventsGestureRecognizer)) |^.\\[UIView |UIButton _defaultBackgroundImageForType:andState:|RxSwift.ScheduledDisposable.dispose"

    static var inclusionRegexp: NSRegularExpression?
    static var exclusionRegexp: NSRegularExpression? = NSRegularExpression(pattern: defaultMethodExclusions)

    /**
     Include symbols matching pattern only
     - parameter pattern: regexp for symbols to include
     */
    open class func include(_ pattern: String) {
        inclusionRegexp = NSRegularExpression(pattern: pattern)
    }

    /**
     Exclude symbols matching this pattern. If not specified
     a default pattern in swiftTraceDefaultExclusions is used.
     - parameter pattern: regexp for symbols to exclude
     */
    open class func exclude(_ pattern: String) {
        exclusionRegexp = NSRegularExpression(pattern: pattern)
    }

    /**
     in order to be traced, symbol must be included and not excluded
     - parameter symbol: String representation of method
     */
    class func included(symbol: String) -> Bool {
        return
            (inclusionRegexp?.matches(symbol) != false) &&
            (exclusionRegexp?.matches(symbol) != true)
    }

    /**
        Intercepts and tracess all classes linked into the bundle containing a class.
        - parameter containing: the class to specify the bundle
     */
    @objc open class func traceBundle(containing theClass: AnyClass) {
        trace(bundlePath: class_getImageName(theClass))
    }

    /**
        Trace all user developed classes in the main bundle of an app
     */
    @objc open class func traceMainBundle() {
        let main = dlsym(UnsafeMutableRawPointer(bitPattern: -2), "main")
        var info = Dl_info()
        if main != nil && dladdr(main, &info) != 0 && info.dli_fname != nil {
            trace(bundlePath: info.dli_fname)
        }
        else {
            fatalError("Could not locate main bundle")
        }
    }

    /**
        Iterate over all known classes in the app
     */
    @discardableResult
    open class func forAllClasses( callback: (_ aClass: AnyClass,
                                              _ stop: inout Bool) -> Void ) -> Bool {
        var stopped = false
        var nc: UInt32 = 0

        if let classes = objc_copyClassList(&nc) {
            for aClass in (0..<Int(nc)).map({ classes[$0] }) {
                callback(aClass, &stopped)
                if stopped {
                    break
                }
            }
            free(UnsafeMutableRawPointer(classes))
        }

        return stopped
    }

    /**
        Trace a classes defined in a specific bundlePath (executable image)
     */
    @objc class func trace(bundlePath: UnsafePointer<Int8>?) {
        var registered = Set<UnsafeRawPointer>()
        forAllClasses {
            (aClass, stop) in
            if class_getImageName(aClass) == bundlePath {
                trace(aClass: aClass)
                registered.insert(unsafeBitCast(aClass, to: UnsafeRawPointer.self))
            }
        }
        /* This should pick up and Pure Swift classes */
        findPureSwiftClasses(bundlePath, { aClass in
            if !registered.contains(aClass) {
                trace(aClass: unsafeBitCast(aClass, to: AnyClass.self))
            }
        })
    }

    /**
        Lists Swift classes in an app or framework.
     */
    open class func swiftClassList(bundlePath: UnsafePointer<Int8>) -> [AnyClass] {
        var classes = [AnyClass]()
        findPureSwiftClasses(bundlePath, { aClass in
            classes.append(unsafeBitCast(aClass, to: AnyClass.self))
        })
        return classes
    }

    /**
        Intercepts and tracess all classes with names matching regexp pattern
        - parameter pattern: regexp patten to specify classes to trace
     */
    @objc open class func traceClassesMatching(pattern: String) {
        if let regexp = NSRegularExpression(pattern: pattern) {
            forAllClasses {
                (aClass, stop) in
                let className = NSStringFromClass(aClass) as NSString
                if regexp.firstMatch(in: String(describing: className) as String, range: NSMakeRange(0, className.length)) != nil {
                    trace(aClass: aClass)
                }
            }
        }
    }

    /**
        Specify an individual classs to trace
        - parameter aClass: the class, the methods of which to trace
     */
    @objc open class func trace(aClass: AnyClass) {

        let className = NSStringFromClass(aClass)
        if className.hasPrefix("Swift.") || className.hasPrefix("__") {
            return
        }

        var tClass: AnyClass? = aClass
        while tClass != nil {
            if NSStringFromClass(tClass!).contains("SwiftTrace") {
                return
            }
            tClass = class_getSuperclass(tClass)
        }

        trace(objcClass: object_getClass(aClass)!, which: "+")
        trace(objcClass: aClass, which: "-")

        iterateMethods(ofClass: aClass) {
            (name, vtableSlot, stop) in
            if included(symbol: name),
                let patch = patchFactory.init(name: name, vtableSlot: vtableSlot) {
                vtableSlot.pointee = patch.forwardingImplementation()
            }
        }
    }

    /**
        Iterate over all methods in the vtable that follows the class information
        of a Swift class (TargetClassMetadata)
     */
    @discardableResult
    open class func iterateMethods(ofClass aClass: AnyClass,
           callback: (_ name: String, _ vtableSlot: UnsafeMutablePointer<SIMP>, _ stop: inout Bool) -> Void) -> Bool {
        let swiftMeta = unsafeBitCast(aClass, to: UnsafeMutablePointer<TargetClassMetadata>.self)
        let className = NSStringFromClass(aClass)
        var stop = false

        guard (className.hasPrefix("_Tt") || className.contains(".")) && !className.hasPrefix("Swift.") else {
            //print("Object is not instance of Swift class")
            return false
        }

        withUnsafeMutablePointer(to: &swiftMeta.pointee.IVarDestroyer) {
            (vtableStart) in
            swiftMeta.withMemoryRebound(to: Int8.self, capacity: 1) {
                let endMeta = ($0 - Int(swiftMeta.pointee.ClassAddressPoint) + Int(swiftMeta.pointee.ClassSize))
                endMeta.withMemoryRebound(to: Optional<SIMP>.self, capacity: 1) {
                    (vtableEnd) in

                    var info = Dl_info()
                    for i in 0..<(vtableEnd - vtableStart) {
                        if var impl = unsafeBitCast(vtableStart[i], to: IMP?.self) {
                            if let patch = Patch.originalPatch(for: impl) {
                                impl = patch.implementation
                            }
                            let voidPtr = unsafeBitCast(impl, to: UnsafeMutableRawPointer.self)
                            if fast_dladdr(voidPtr, &info) != 0 && info.dli_sname != nil,
                                let demangled = demangle(symbol: info.dli_sname) {
                                callback(demangled, &vtableStart[i]!, &stop)
                                if stop {
                                    break
                                }
                            }
                        }
                    }
                }
            }
        }

        return stop
    }

    /**
        Returns a list of all Swift methods as demangled symbols of a class
        - parameter ofClass: - class to be dumped
     */
    open class func methodNames(ofClass: AnyClass) -> [String] {
        var names = [String]()
        iterateMethods(ofClass: ofClass) {
            (name, vtableSlot, stop) in
            names.append(name)
        }
        return names
    }

    public typealias EntryAspect = (_ patch: Patch, UnsafeMutablePointer<EntryStack>) -> Void
    public typealias ExitAspect = (_ patch: Patch, UnsafeMutablePointer<ExitStack>) -> Void

    /**
        Add a closure aspect to be called before or after a "Patch" is called
        - parameter methodName: - unmangled name of Method for aspect
        - parameter onEntry: - closure to be called before "Patch" is called
        - parameter onExit: - closure to be called after "Patch" returns
     */
    @discardableResult
    open class func addAspect(methodName: String,
                              patchClass: Aspect.Type = Aspect.self,
                              onEntry: EntryAspect? = nil,
                              onExit: ExitAspect? = nil,
                              justReturn: nullImplementationType? = nil) -> Bool {
        return forAllClasses {
            (aClass, stop) in
            stop = addAspect(methodName: methodName, ofClass: aClass, 
                             onEntry: onEntry, onExit: onExit, justReturn: justReturn)
        }
    }

    /**
        Add a closure aspect to be called before or after a "Patch" is called
        - parameter toClass: - specifying the class to add aspect is more efficient
        - parameter methodName: - unmangled name of Method for aspect
        - parameter onEntry: - closure to be called before "Patch" is called
        - parameter onExit: - closure to be called after "Patch" returns
     */
    @discardableResult
    open class func addAspect(methodName: String, ofClass aClass: AnyClass,
                              patchClass: Aspect.Type = Aspect.self,
                              onEntry: EntryAspect? = nil,
                              onExit: ExitAspect? = nil,
                              justReturn: nullImplementationType? = nil) -> Bool {
        return iterateMethods(ofClass: aClass) {
            (name, vtableSlot, stop) in
            if name == methodName, let method = patchClass.init(name: name,
                vtableSlot: vtableSlot, onEntry: onEntry,
                        onExit: onExit, justReturn: justReturn) {
                vtableSlot.pointee = method.forwardingImplementation()
                stop = true
            }
        }
    }

    /**
        Add a closure aspect to be called before or after a "Patch" is called
        - parameter methodName: - unmangled name of Method for aspect
     */
    @discardableResult
    open class func removeAspect(methodName: String) -> Bool {
        return forAllClasses {
            (aClass, stop) in
            stop = removeAspect(fromClass: aClass, methodName: methodName)
        }
    }

    /**
        Add a closure aspect to be called before or after a "Patch" is called
        - parameter toClass: - specifying the class to add aspect is more efficient
        - parameter methodName: - unmangled name of Method for aspect
     */
    @discardableResult
    open class func removeAspect(fromClass aClass: AnyClass, methodName: String) -> Bool {
        return iterateMethods(ofClass: aClass) {
            (name, vtableSlot, stop) in
            if name == methodName,
                let patch = Patch.active[unsafeBitCast(vtableSlot.pointee, to: IMP.self)] {
                patch.remove()
                stop = true
            }
        }
    }

    /**
        Internal class used in the implementation of aspects
     */
    open class Aspect: Patch {

        let entryAspect: EntryAspect?
        let exitAspect: ExitAspect?

        public required init?(name: String, vtableSlot: UnsafeMutablePointer<SIMP>,
                              onEntry: EntryAspect? = nil, onExit: ExitAspect? = nil,
                              justReturn: nullImplementationType? = nil) {
            self.entryAspect = onEntry
            self.exitAspect = onExit
            super.init(name: name, vtableSlot: vtableSlot, justReturn: justReturn)
        }

        public required init?(name: String, vtableSlot: UnsafeMutablePointer<SIMP>? = nil, objcMethod: Method? = nil, justReturn: nullImplementationType? = nil) {
            fatalError("Aspect.init(name:vtableSlot:objcMethod:justReturn:) should not be used")
        }

        open override func onEntry(stack: UnsafeMutablePointer<EntryStack>) {
            entryAspect?(self, stack)
        }

        open override func onExit(stack: UnsafeMutablePointer<ExitStack>) {
            exitAspect?(self, stack)
        }
    }

    /**
        Implementation of invocatoin api
     */
    public class Call: Patch {

        public var input = EntryStack()
        public var output = ExitStack()
        let target: AnyObject
        var caller: IMP? = nil

        public init?(`self` anObject: AnyObject, methodName: String) {
            target = anObject
            var sigh: SIMP = { _ in }
            super.init(name: methodName, vtableSlot: &sigh)

            guard iterateMethods(ofClass: type(of: anObject), callback: {
                (name, vtableSlot, stop) in
                if name == methodName {
                    self.vtableSlot = vtableSlot
                    implementation = vtableSlot
                        .withMemoryRebound(to: IMP.self, capacity: 1, { $0 }).pointee
                    stop = true
                }
            })
            else {
                return nil
            }

            input.swiftSelf = unsafeBitCast(anObject, to: Int.self)

            caller = imp_implementationForwardingToTracer(unsafeBitCast(self, to: UnsafeMutableRawPointer.self),
                          unsafeBitCast(Patch.onEntry, to: IMP.self), unsafeBitCast(Patch.onExit, to: IMP.self))
        }

        public required init?(name: String, vtableSlot: UnsafeMutablePointer<SIMP>? = nil, objcMethod: Method? = nil, justReturn: nullImplementationType? = nil) {
            fatalError("Call.init(name:vtableSlot:objcMethod:justReturn:) should not be used")
        }

        var intArgNumber = 0
        var floatArgNumber = 0

        public func add<T>(arg: T) {
            if arg is Double || arg is Float {
                if floatArgNumber + 1 > EntryStack.maxFloatArgs {
                    fatalError("Too many float args")
                }
                cast(&input.floatArg1, as: Double.self).advanced(by: floatArgNumber)
                    .withMemoryRebound(to: T.self, capacity: 1) { $0 }.pointee = arg
                floatArgNumber += 1
            }
            else {
                let registers = MemoryLayout<T>.size / MemoryLayout<intptr_t>.size
                if intArgNumber + registers > EntryStack.maxIntArgs {
                    fatalError("Too many int args")
                }
                cast(&input.intArg1, as: intptr_t.self).advanced(by: intArgNumber)
                    .withMemoryRebound(to: T.self, capacity: 1) { $0 }.pointee = arg
                intArgNumber += registers
            }
        }

        public func invoke() {
            unsafeBitCast(caller!, to: (@convention (c) () -> ()).self)()
        }

        public override func onEntry(stack: UnsafeMutablePointer<EntryStack>) {
            input.framePointer = stack.pointee.framePointer
            stack.pointee = input
        }

        public override func onExit(stack: UnsafeMutablePointer<ExitStack>) {
            output = stack.pointee
        }

        public func getReturn<T>() -> T {
            return output.genericReturn(patch: self).pointee
        }
    }

    /**
        Basic Swift method invocation api
         - parameter self: instance to message
         - parameter methodName: de-mangled method name to invoke
         - parameter args: list of values to use as arguments
     */
    open class func invoke<T>(`self` anObject: AnyObject, methodName: String, args: Any...) -> T {
        guard let call = Call(self: anObject, methodName: methodName) else {
            fatalError("Unknown mehod \(methodName) on class \(anObject)")
        }

        for arg in args {
            if let arg = arg as? Double {
                call.add(arg: arg)
            }
            else if let arg = arg as? Float {
                call.add(arg: arg)
            }
            else if let arg = arg as? String {
                call.add(arg: arg)
            }
            else {
                var arg = arg
                call.add(arg: call.cast(&arg, as: Int.self).pointee)
            }
        }

        call.invoke()

        return call.getReturn()
    }

    /**
        Remove all patches applied until now
     */
    @objc open class func removeAllPatches() {
        for (_, patch) in Patch.active {
            patch.removeAll()
        }
    }

    /**
        Intercept Objective-C class' methods using swizzling
        - parameter aClass: meta-class or class to be swizzled
        - parameter which: "+" for class methods, "-" for instance methods
     */
    class func trace(objcClass aClass: AnyClass, which: String) {
        var mc: UInt32 = 0
        if let methods = class_copyMethodList(aClass, &mc) {
            for method in (0..<Int(mc)).map({ methods[$0] }) {
                let sel = method_getName(method)
                let selName = NSStringFromSelector(sel)
                let type = method_getTypeEncoding(method)
                let name = "\(which)[\(aClass) \(selName)] -> \(String(cString: type!))"

                if !included(symbol: name) || (which == "+" ?
                        selName.hasPrefix("shared") :
                        dontSwizzleProperty(aClass, sel:sel)) {
                    continue
                }

                if let info = patchFactory.init(name: name, objcMethod: method) {
                    method_setImplementation(method,
                        unsafeBitCast(info.forwardingImplementation(), to: IMP.self))
                }
            }
            free(methods)
        }
    }

    /**
        Legacy code intended to prevent property accessors from being traced
        - parameter aClass: class of method
        - parameter sel: selector of method being checked
     */
    class func dontSwizzleProperty(_ aClass: AnyClass, sel: Selector) -> Bool {
        var name = [Int8](repeating: 0, count: 5000)
        strcpy(&name, sel_getName(sel))
        if strncmp(name, "is", 2) == 0 && isupper(Int32(name[2])) != 0 {
            name[2] = Int8(towlower(Int32(name[2])))
            return class_getProperty(aClass, &name[2]) != nil
        }
        else if strncmp(name, "set", 3) != 0 || islower(Int32(name[3])) != 0 {
            return class_getProperty(aClass, name) != nil
        }
        else {
            name[3] = Int8(tolower(Int32(name[3])))
            name[Int(strlen(name))-1] = 0
            return class_getProperty(aClass, &name[3]) != nil
        }
    }

    /** pointer to a function implementing a Swift method */
    public typealias SIMP = @convention(c) (_: AnyObject) -> Void
    
    /**
     Layout of a class instance. Needs to be kept in sync with ~swift/include/swift/Runtime/Metadata.h
     */
    public struct TargetClassMetadata {
        
        let MetaClass: uintptr_t = 0, SuperClass: uintptr_t = 0
        let CacheData1: uintptr_t = 0, CacheData2: uintptr_t = 0
        
        let Data: uintptr_t = 0
        
        /// Swift-specific class flags.
        let Flags: UInt32 = 0
        
        /// The address point of instances of this type.
        let InstanceAddressPoint: UInt32 = 0
        
        /// The required size of instances of this type.
        /// 'InstanceAddressPoint' bytes go before the address point;
        /// 'InstanceSize - InstanceAddressPoint' bytes go after it.
        let InstanceSize: UInt32 = 0
        
        /// The alignment mask of the address point of instances of this type.
        let InstanceAlignMask: UInt16 = 0
        
        /// Reserved for runtime use.
        let Reserved: UInt16 = 0
        
        /// The total size of the class object, including prefix and suffix
        /// extents.
        let ClassSize: UInt32 = 0
        
        /// The offset of the address point within the class object.
        let ClassAddressPoint: UInt32 = 0
        
        /// An out-of-line Swift-specific description of the type, or null
        /// if this is an artificial subclass.  We currently provide no
        /// supported mechanism for making a non-artificial subclass
        /// dynamically.
        let Description: uintptr_t = 0
        
        /// A function for destroying instance variables, used to clean up
        /// after an early return from a constructor.
        var IVarDestroyer: SIMP? = nil
        
        // After this come the class members, laid out as follows:
        //   - class members for the superclass (recursively)
        //   - metadata reference for the parent, if applicable
        //   - generic parameters for this class
        //   - class variables (if we choose to support these)
        //   - "tabulated" virtual methods
        
    }

    /**
        Convert a executable symbol name "mangled" according to Swift's
        conventions into a human readable Swift language form
     */
    @objc open class func demangle(symbol: UnsafePointer<Int8>) -> String? {
        if let demangledNamePtr = _stdlib_demangleImpl(
            symbol, mangledNameLength: UInt(strlen(symbol)),
            outputBuffer: nil, outputBufferSize: nil, flags: 0) {
            let demangledName = String(cString: demangledNamePtr)
            free(demangledNamePtr)
            return demangledName
        }
        return nil
    }
}

/**
    Convenience extension to trap regex errors and report them
 */
private extension NSRegularExpression {

    convenience init?(pattern: String) {
        do {
            try self.init(pattern: pattern, options: [])
        }
        catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }

    func matches(_ string: String) -> Bool {
        return rangeOfFirstMatch(in: string, options: [],
                                 range: NSMakeRange(0, string.utf16.count)).location != NSNotFound
    }

}

// Taken from stdlib, not public Swift3+

@_silgen_name("swift_demangle")
private
func _stdlib_demangleImpl(
    _ mangledName: UnsafePointer<CChar>?,
    mangledNameLength: UInt,
    outputBuffer: UnsafeMutablePointer<UInt8>?,
    outputBufferSize: UnsafeMutablePointer<UInt>?,
    flags: UInt32
    ) -> UnsafeMutablePointer<CChar>?
