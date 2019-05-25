//
//  SwiftTrace.swift
//  SwiftTraceApp
//
//  Created by John Holdsworth on 10/06/2016.
//  Copyright © 2016 John Holdsworth. All rights reserved.
//
//  Repo: https://github.com/johnno1962/SwiftTrace
//  $Id: //depot/SwiftTrace/SwiftTrace/SwiftTrace.swift#59 $
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
        SwiftTrace.traceBundleContaining(theClass: self)
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
    public static var defaultInvocationFactory = Invocation.self

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
        let implementation: IMP

        /** vtable slot patched for unpatching */
        let vtableSlot: UnsafeMutablePointer<SIMP>?

        /** Original objc method swizzled */
        let objcMethod: Method?

        /**
         designated initialiser
         - parameter name: string representing method being traced
         - parameter vtableSlot: pointer to vtable slot patched
         */
        public required init?(name: String, vtableSlot: UnsafeMutablePointer<SIMP>) {
            self.name = name
            self.vtableSlot = vtableSlot
            implementation = vtableSlot
                .withMemoryRebound(to: IMP.self, capacity: 1, { $0 }).pointee
            objcMethod = nil
        }

        /**
         designated initialiser
         - parameter name: string representing method being traced
         - parameter objcMethod: pointer to original Method patched
         */
        public required init?(name: String, objcMethod: Method) {
            self.name = name
            self.objcMethod = objcMethod
            implementation = method_getImplementation(objcMethod)
            vtableSlot = nil
        }

        /**
            Return a unique pointer to a function that will callback the oneEntry()
            and onExit() method in this class
         */
        func forwardingImplementation() -> SIMP {
            let onEntry: @convention(c) (_ patch: Patch, _ returnAddress: UnsafeRawPointer,
                _ swiftSelf: UnsafeMutableRawPointer, _ framePointer: UnsafeMutablePointer<UInt64>) -> IMP = {
                (patch, returnAddress, swiftSelf, framePointer) -> IMP in
                let local = ThreadLocal.threadLocal()
                let invoke = patch.invocationFactory.init(stackDepth: local.stack.count, patch: patch,
                     returnAddress: returnAddress, swiftSelf: swiftSelf, framePointer : framePointer )
                local.stack.append(invoke)
                invoke.onEntry()
                return patch.implementation
            }

            let onExit: @convention(c) () -> UnsafeRawPointer = {
                let local = ThreadLocal.threadLocal()
                local.stack.last!.onExit()
                return local.stack.removeLast().returnAddress
            }

            /* create trampoline */
            let impl = imp_implementationForwardingToTracer(unsafeBitCast(self, to: UnsafeMutableRawPointer.self),
                                unsafeBitCast(onEntry, to: IMP.self), unsafeBitCast(onExit, to: IMP.self))
            Patch.active[impl] = self
            return unsafeBitCast(impl, to: SIMP.self)
        }

        /**
           Class used to create a specific "Invocation" of the "Patch"
         */
        open var invocationFactory: Invocation.Type {
            return defaultInvocationFactory
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
    }

    /**
        Represents a specific call to a member function on the "ThreadLocal" stack
     */
    open class Invocation {

        /** Number of calls above this on the stack of the current thread */
        public let stackDepth: Int
        /** "Patch" related to this call */
        public let patch: Patch
        /** Original return address of call to trampoline */
        public let returnAddress: UnsafeRawPointer
        /** "self" for method invokations */
        public let swiftSelf: UnsafeMutableRawPointer
        /** Architecture depenent place on stack where arguments stored */
        public let framePointer: UnsafeMutablePointer<UInt64>
        /** Time call was started */
        public let timeEntered: Double

        /**
            micro-second precision time.
         */
        static public func ftime() -> Double {
            var tv = timeval()
            gettimeofday(&tv, nil)
            return Double(tv.tv_sec) + Double(tv.tv_usec)/1_000_000.0
        }

        /**
            designated initialiser
         */
        required public init(stackDepth: Int, patch: Patch, returnAddress: UnsafeRawPointer,
                             swiftSelf: UnsafeMutableRawPointer,
                             framePointer: UnsafeMutablePointer<UInt64>) {
            self.stackDepth = stackDepth
            self.patch = patch
            self.returnAddress = returnAddress
            self.swiftSelf = swiftSelf
            self.framePointer = framePointer
            timeEntered = Invocation.ftime()
        }

        /**
            method called before trampoline enters the target "Patch"
         */
        open func onEntry() {
        }

        /**
            method called after trampoline exists the target "Patch"
         */
        open func onExit() {
            let elapsed = Invocation.ftime() - timeEntered
            print("\(String(repeating: "  ", count: stackDepth))\(patch.name) \(String(format: "%.1fms", elapsed * 1000.0))")
        }

        /**
            The inner invocation instance on the current thread.
         */
        open class var current: Invocation? {
            return ThreadLocal.threadLocal().stack.last
        }
    }

    /**
        Class implementing thread local storage to arrange a call stack
     */
    public class ThreadLocal {

        private static var keyVar: pthread_key_t = 0

        private static var pthreadKey: pthread_key_t = {
            let ret = pthread_key_create(&keyVar, {
                #if os(Linux) || os(Android)
                Unmanaged<ThreadLocal>.fromOpaque($0!).release()
                #else
                Unmanaged<ThreadLocal>.fromOpaque($0).release()
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
        static public func threadLocal() -> ThreadLocal {
            let keyVar = ThreadLocal.pthreadKey
            if let existing = pthread_getspecific(keyVar) {
                return Unmanaged<ThreadLocal>.fromOpaque(existing).takeUnretainedValue()
            }
            else {
                let unmanaged = Unmanaged.passRetained(ThreadLocal())
                let ret = pthread_setspecific(keyVar, unmanaged.toOpaque())
                if ret != 0 {
                    NSLog("Could not pthread_setspecific: %s", strerror(ret))
                }
                return unmanaged.takeUnretainedValue()
            }
        }
    }

    /**
     default pattern of symbols to be excluded from tracing
     */
    static public let swiftTraceDefaultExclusions = "\\.getter|retain]|release]|_tryRetain]|.cxx_destruct]|initWithCoder|_isDeallocating]|^\\+\\[(Reader_Base64|UI(NibStringIDTable|NibDecoder|CollectionViewData|WebTouchEventsGestureRecognizer)) |^.\\[UIView |UIButton _defaultBackgroundImageForType:andState:|RxSwift.ScheduledDisposable.dispose"


    static var inclusionRegexp: NSRegularExpression?
    static var exclusionRegexp: NSRegularExpression? = NSRegularExpression(pattern: swiftTraceDefaultExclusions)

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
            (inclusionRegexp == nil ||  inclusionRegexp!.matches(symbol)) &&
            (exclusionRegexp == nil || !exclusionRegexp!.matches(symbol))
    }

    /**
        Intercepts and tracess all classes linked into the bundle containing a class.
        - parameter aClass: the class to specify the bundle
     */
    @objc open class func traceBundleContaining(theClass: AnyClass) {
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
            (name, impPtr, stop) in
            if included(symbol: name),
                let patch = patchFactory.init(name: name, vtableSlot: impPtr) {
                impPtr.pointee = patch.forwardingImplementation()
            }
        }
    }

    /**
        Iterate over all methods in the vtable that follows the class information
        of a Swift class (TargetClassMetadata)
     */
    @discardableResult
    open class func iterateMethods(ofClass aClass: AnyClass,
           callback: (_ name: String, _ impPtr: UnsafeMutablePointer<SIMP>, _ stop: inout Bool) -> Void) -> Bool {
        let swiftMeta = unsafeBitCast(aClass, to: UnsafeMutablePointer<TargetClassMetadata>.self)

        guard (swiftMeta.pointee.Data & 0x3) != 0 else {
            //print("Object is not instance of Swift class")
            return false
        }

        var stop = false
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
                            if dladdr(voidPtr, &info) != 0 && info.dli_sname != nil,
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
            (name, impPtr, stop) in
            names.append(name)
        }
        return names
    }

    /**
        Add a closure aspect to be called before or after a "Patch" is called
        - parameter methodName: - unmangled name of Method for aspect
        - parameter onEntry: - closure to be called before "Patch" is called
        - parameter onExit: - closure to be called after "Patch" returns
     */
    @discardableResult
    open class func addAspect(methodName: String,
                              patchClass: Aspect.Type = Aspect.self,
                              onEntry: @escaping () -> Void = {},
                              onExit: @escaping () -> Void = {}) -> Bool {
        return forAllClasses {
            (aClass, stop) in
            stop = addAspect(methodName: methodName, ofClass: aClass, 
                             onEntry: onEntry, onExit: onExit)
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
                              onEntry: @escaping () -> Void = {},
                              onExit: @escaping () -> Void = {}) -> Bool {
        return iterateMethods(ofClass: aClass) {
            (name, impPtr, stop) in
            if name == methodName, let method = patchClass.init(name: name,
                vtableSlot: impPtr, onEntry: onEntry, onExit: onExit) {
                impPtr.pointee = method.forwardingImplementation()
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
            (name, impPtr, stop) in
            if name == methodName,
                let patch = Patch.active[unsafeBitCast(impPtr.pointee, to: IMP.self)] {
                patch.remove()
                stop = true
            }
        }
    }

    /**
        Internal class used in the implementation of aspects
     */
    open class Aspect: Patch {

        let onEntry: () -> Void
        let onExit: () -> Void

        public required init?(name: String, vtableSlot: UnsafeMutablePointer<SIMP>) {
            fatalError()
        }

        public required init?(name: String, objcMethod: Method) {
            fatalError()
        }

        public required init?(name: String, vtableSlot: UnsafeMutablePointer<SIMP>,
                              onEntry: @escaping () -> Void,
                              onExit: @escaping () -> Void) {
            self.onEntry = onEntry
            self.onExit = onExit
            super.init(name: name, vtableSlot: vtableSlot)
        }

        /**
            returns Class used to create Invokations to call the aspects
         */
        open override var invocationFactory: Invocation.Type {
            return Applier.self
        }

        /**
            Class used to create Invokations to call the aspects
         */
        open class Applier: Invocation {

            open override func onEntry() {
                (patch as! Aspect).onEntry()
            }

            open override func onExit() {
                (patch as! Aspect).onExit()
            }
        }
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
        Code intended to prevent property accessors from being traced
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
