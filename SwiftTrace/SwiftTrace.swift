//
//  SwiftTrace.swift
//  SwiftTraceApp
//
//  Created by John Holdsworth on 10/06/2016.
//  Copyright © 2016 John Holdsworth. All rights reserved.
//
//  Repo: https://github.com/johnno1962/SwiftTrace
//  $Id: //depot/SwiftTrace/SwiftTrace/SwiftTrace.swift#27 $
//

import Foundation

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
    default pattern of symbols to be excluded from tracing
 */
public let swiftTraceDefaultExclusions = "\\.getter|retain]|release]|_tryRetain]|.cxx_destruct]|initWithCoder|_isDeallocating]|^\\+\\[(Reader_Base64|UI(NibStringIDTable|NibDecoder|CollectionViewData|WebTouchEventsGestureRecognizer)) |^.\\[UIView |UIButton _defaultBackgroundImageForType:andState:|RxSwift.ScheduledDisposable.dispose"

/**
    Base class for SwiftTrace api through it's public class methods
 */
open class SwiftTrace: NSObject {

    public static var methodFactory = Method.self
    public static var invocationFactory = Invocation.self

    /**
     Strace "info" instance used to store information about a method
     */
    open class Method: NSObject {

        /** string representing Swift or Objective-C method to user */
        public let name: String

        /** pointer to original function implementing method */
        let implementation: IMP

        /**
         designated initialiser
         - parameter symbol: string representing method being traced
         - parameter original: pointer to function implementing method
         */
        public required init?(name: String, implementation: IMP) {
            self.name = name
            self.implementation = implementation
        }

        /**
         Take a unmanaged, retained potinter to this instance for storing in trampoline
         */
        func retainedPointer() -> UnsafeMutableRawPointer {
            return Unmanaged.passRetained(self).toOpaque()
        }

        /**
         Return a unique pointer to a function that will callback the trace() method in this class
         */
        func forwardingImplementation() -> IMP {
            let tracerp: @convention(c) (_ method: Method, _ returnAddress: IMP,
                _ swiftSelf: UnsafeMutableRawPointer, _ theStack: UnsafeMutablePointer<UInt64>) -> IMP = {
                (method: SwiftTrace.Method, returnAddress: IMP,
                    swiftSelf: UnsafeMutableRawPointer, theStack: UnsafeMutablePointer<UInt64>) -> IMP in
                let local = SwiftTrace.ThreadLocal.threadLocal()
                let invoke = method.invocationFactory.init(depth: local.stack.count, method: method,
                     returnAddress: returnAddress, swiftSelf: swiftSelf, theStack : theStack )
                invoke.onEntry()
                local.stack.append(invoke)
                return method.implementation
            }

            let exiterp: @convention(c) () -> IMP? = {
                () -> IMP? in
                let local = SwiftTrace.ThreadLocal.threadLocal()
                let invoke = local.stack.removeLast()
                invoke.onExit()
                return invoke.returnAddress
            }

            return imp_implementationForwardingToTracer(retainedPointer(), unsafeBitCast(tracerp, to: IMP.self), unsafeBitCast(exiterp, to: IMP.self))
        }

        open var invocationFactory: Invocation.Type {
            return SwiftTrace.invocationFactory
        }
    }

    open class Invocation {

        public let depth: Int
        public let method: Method
        public let returnAddress: IMP
        public let swiftSelf: UnsafeMutableRawPointer
        public let theStack: UnsafeMutablePointer<UInt64>
        public let timeEntered: Double

        static func ftime() -> Double {
            var tv = timeval()
            gettimeofday(&tv, nil)
            return Double(tv.tv_sec) + Double(tv.tv_usec)/1_000_000.0
        }

        required public init(depth: Int, method: Method, returnAddress: IMP,
                             swiftSelf: UnsafeMutableRawPointer,
                             theStack: UnsafeMutablePointer<UInt64>) {
            self.depth = depth
            self.method = method
            self.returnAddress = returnAddress
            self.swiftSelf = swiftSelf
            self.theStack = theStack
            timeEntered = Invocation.ftime()
        }

        open func onEntry() {
        }

        open func onExit() {
            print("\(String(repeating: "  ", count: depth))\(method.name) \(String(format: "%.1f", (Invocation.ftime()-timeEntered)*1000.0))ms")
        }

    }

    private class ThreadLocal {

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

        var stack = [Invocation]()

        static func threadLocal() -> ThreadLocal {
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
     A SwiftTraceInfo subclass, the "trace()" method of which will be called before each traced method
     */

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
    class func included(_ symbol: String) -> Bool {
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

    @objc class func trace(bundlePath: UnsafePointer<Int8>?) {
        var nc: UInt32 = 0
        var registered = Set<UnsafeRawPointer>()
        if let classes = objc_copyClassList(&nc) {
            for aClass in (0..<Int(nc)).map({ classes[$0] }) {
                if class_getImageName(aClass) == bundlePath {
                    trace(aClass: aClass)
                    registered.insert(unsafeBitCast(aClass, to: UnsafeRawPointer.self))
                }
            }
            free(UnsafeMutableRawPointer(classes))
        }
        findSwiftClasses(bundlePath, { aClass in
            if !registered.contains(aClass!) {
                trace(aClass: unsafeBitCast(aClass, to: AnyClass.self))
            }
        })
    }

    /**
        Intercepts and tracess all classes with names matching regexp pattern
        - parameter pattern: regexp patten to specify classes to trace
     */
    @objc open class func traceClassesMatching(pattern: String) {
        if let regexp = NSRegularExpression(pattern: pattern) {
            var nc: UInt32 = 0
            if let classes = objc_copyClassList(&nc) {
                for i in 0..<Int(nc) {
                    let aClass: AnyClass = classes[i]
                    let className = NSStringFromClass(aClass) as NSString
                    if regexp.firstMatch(in: String(describing: className) as String, range: NSMakeRange(0, className.length)) != nil {
                        trace(aClass: aClass)
                    }
                }
                free(UnsafeMutableRawPointer(classes))
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
        repeat {
            if NSStringFromClass(tClass!).contains("SwiftTrace") {
                return
            }
            tClass = class_getSuperclass(tClass)
        } while tClass != nil

        trace(ObjcClass: object_getClass(aClass)!, which: "+")
        trace(ObjcClass: aClass, which: "-")

        let swiftMeta = unsafeBitCast(aClass, to: UnsafeMutablePointer<TargetClassMetadata>.self)

        if (swiftMeta.pointee.Data & 0x3) == 0 {
            //print("Object is not instance of Swift class")
            return
        }

        withUnsafeMutablePointer(to: &swiftMeta.pointee.IVarDestroyer) {
            (sym_start) in
            swiftMeta.withMemoryRebound(to: Int8.self, capacity: 1) {
                let ptr = ($0 + -Int(swiftMeta.pointee.ClassAddressPoint) + Int(swiftMeta.pointee.ClassSize))
                ptr.withMemoryRebound(to: Optional<SIMP>.self, capacity: 1) {
                    (sym_end) in

                    var info = Dl_info()
                    for i in 0..<(sym_end - sym_start) {
                        if let fptr = sym_start[i] {
                            let vptr = unsafeBitCast(fptr, to: UnsafeRawPointer.self)
                            if dladdr(vptr, &info) != 0 && info.dli_sname != nil {
                                let demangled = _stdlib_demangleName(String(cString: info.dli_sname))
                                if included(demangled),
                                    let info = SwiftTrace.methodFactory.init(name: demangled,
                                                                  implementation: unsafeBitCast(fptr, to: IMP.self)) {
                                    sym_start[i] = unsafeBitCast(info.forwardingImplementation(), to: SIMP.self)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    /**
        Intercept Objective-C class' methods using swizzling
        - parameter aClass: meta-class or class to be swizzled
        - parameter which: "+" for class methods, "-" for instance methods
     */
    class func trace(ObjcClass aClass: AnyClass, which: String) {
        var mc: UInt32 = 0
        if let methods = class_copyMethodList(aClass, &mc) {
            for method in (0..<Int(mc)).map({ methods[$0] }) {
                let sel = method_getName(method)
                let selName = NSStringFromSelector(sel)
                let type = method_getTypeEncoding(method)
                let name = "\(which)[\(aClass) \(selName)] -> \(String(cString: type!))"

                if !included(name) || (which == "+" ?
                        selName.hasPrefix("shared") :
                        dontSwizzleProperty(aClass, sel:sel)) {
                    continue
                }

                if let info = SwiftTrace.methodFactory.init(name: name,
                             implementation: method_getImplementation(method)) {
                    method_setImplementation(method, info.forwardingImplementation())
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
    private typealias SIMP = @convention(c) (_: AnyObject) -> Void
    
    /**
     Layout of a class instance. Needs to be kept in sync with ~swift/include/swift/Runtime/Metadata.h
     */
    private struct TargetClassMetadata {
        
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
    
}

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

// not public in Swift3

@_silgen_name("swift_demangle")
public
func _stdlib_demangleImpl(
    _ mangledName: UnsafePointer<CChar>?,
    mangledNameLength: UInt,
    outputBuffer: UnsafeMutablePointer<UInt8>?,
    outputBufferSize: UnsafeMutablePointer<UInt>?,
    flags: UInt32
    ) -> UnsafeMutablePointer<CChar>?


func _stdlib_demangleName(_ mangledName: String) -> String {
    return mangledName.utf8CString.withUnsafeBufferPointer {
        (mangledNameUTF8) in

        let demangledNamePtr = _stdlib_demangleImpl(
            mangledNameUTF8.baseAddress,
            mangledNameLength: UInt(mangledNameUTF8.count - 1),
            outputBuffer: nil,
            outputBufferSize: nil,
            flags: 0)

        if let demangledNamePtr = demangledNamePtr {
            let demangledName = String(cString: demangledNamePtr)
            free(demangledNamePtr)
            return demangledName
        }
        return mangledName
    }
}
