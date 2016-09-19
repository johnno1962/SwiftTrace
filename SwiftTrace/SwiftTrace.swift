//
//  SwiftTrace.swift
//  SwiftTraceApp
//
//  Created by John Holdsworth on 10/06/2016.
//  Copyright © 2016 John Holdsworth. All rights reserved.
//
//  Repo: https://github.com/johnno1962/SwiftTrace
//  $Id: //depot/SwiftTrace/SwiftTrace/SwiftTrace.swift#13 $
//

import Foundation

/** pointer to a function implementing a Swift method */
typealias SIMP = @convention(c) ( _: AnyObject ) -> Void

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

/**
    tracer callback called by trampoline before each traced method is called
    - paramter info: pointer data object used in itracing using it's method "trace()"
 */
private func tracer( _ info: AnyObject ) -> IMP {
    let sinfo = info as! SwiftTraceInfo
    return sinfo.trace()
}

/**
    Strace "info" instance used to store information about a method
 */
open class SwiftTraceInfo: NSObject {

    /** string representing Swift or Objective-C method to user */
    open let symbol: String

    /** pointer to original function implementing method */
    open let original: IMP

    /**
        designated initialiser
        - parameter symbol: string representing method being traced
        - parameter original: pointer to function implementing method
     */
    public required init( symbol: String, original: IMP ) {
        self.symbol = symbol
        self.original = original
    }

    /**
        Take a unmanaged, retained potinter to this instance for storing in trampoline
     */
    func voidPointer() -> UnsafeMutableRawPointer {
        return unsafeBitCast( Unmanaged.passRetained( self ), to: UnsafeMutableRawPointer.self )
    }

    /**
        Return a unique pointer to a function that will callback the trace() method in this class
     */
    func forwardingImplementation() -> IMP {
        let tracerp: @convention(c) ( _: AnyObject ) -> IMP = tracer
        return imp_implementationForwardingToTracer(voidPointer(), unsafeBitCast(tracerp, to: IMP.self))
    }

    /**
        called back by trampoline before each method is called
        - returns: pointer to original function implementing method
     */
    open func trace() -> IMP {
        print( symbol )
        return original
    }

}

extension NSObject {

    /**
        Trace the bundle containing the target class
     */
    public class func traceBundle() {
        SwiftTrace.traceBundleContaining( self )
    }

    /**
        Trace the target class
     */
    public class func traceClass() {
        SwiftTrace.trace( self )
    }

}

extension NSRegularExpression {

    convenience init?( pattern: String ) {
        do {
            try self.init(pattern: pattern, options: [])
        }
        catch let error as NSError {
            print(error.localizedDescription)
            return nil
        }
    }

    func matches( _ string: String ) -> Bool {
        return rangeOfFirstMatch( in: string, options: [],
                                  range: NSMakeRange( 0, string.utf16.count ) ).location != NSNotFound
    }

}

/**
    default pattern of symbols to be excluded from tracing
 */
public let swiftTraceDefaultExclusions = "\\.getter|retain]|_tryRetain]|_isDeallocating]|^\\+\\[(Reader_Base64|UI(NibStringIDTable|NibDecoder|CollectionViewData|WebTouchEventsGestureRecognizer)) |^.\\[UIView |UIButton _defaultBackgroundImageForType:andState:|RxSwift.ScheduledDisposable.dispose"

/**
    Base class for SwiftTrace api through it's public class methods
 */
open class SwiftTrace: NSObject {

    /**
        A SwiftTraceInfo subclass, the "trace()" method of which will be called before each traced method
     */
    open static var tracerClass = SwiftTraceInfo.self

    static var inclusionRegexp: NSRegularExpression?
    static var exclusionRegexp: NSRegularExpression? = NSRegularExpression( pattern: swiftTraceDefaultExclusions )

    /**
        Include symbols matching pattern only
        - parameter pattern: regexp for symbols to include
     */
    open class func include( _ pattern: String ) {
        inclusionRegexp = NSRegularExpression(pattern: pattern)
    }

    /**
        Exclude symbols matching this pattern. If not specified
        a default pattern in swiftTraceDefaultExclusions is used.
        - parameter pattern: regexp for symbols to exclude
     */
    open class func exclude( _ pattern: String ) {
        exclusionRegexp = NSRegularExpression(pattern: pattern)
    }

    /**
        in order to be traced, symbol must be included and not excluded
        - parameter symbol: String representation of method
     */
    class func valid( _ symbol: String ) -> Bool {
        return
            (inclusionRegexp == nil ||  inclusionRegexp!.matches(symbol)) &&
            (exclusionRegexp == nil || !exclusionRegexp!.matches(symbol))
    }

    /**
        Intercepts and tracess all classes linked into the bundle containing a class.
        - parameter aClass: the class to specify the bundle
     */
    open class func traceBundleContaining( _ aClass: AnyClass ) {
        var info = Dl_info()
        if dladdr(unsafeBitCast(aClass, to: UnsafeRawPointer.self), &info) == 0 {
            print( "SwiftTrace: Could not find bundle for class \(aClass)" )
            return
        }
        let bundlePath = info.dli_fname

        var nc: UInt32 = 0
        let classes = objc_copyClassList( &nc )
        for i in 0..<Int(nc) {
            let aClass: AnyClass = classes![i]!

            if dladdr(unsafeBitCast(aClass, to: UnsafeRawPointer.self), &info) != 0 &&
                    info.dli_fname != nil && info.dli_fname == bundlePath {
                trace(aClass)
            }
        }
    }

    /**
        Intercepts and tracess all classes with names matching regexp pattern
        - parameter pattern: regexp patten to specify classes to trace
     */
    open class func traceClassesMatching( _ pattern: String ) {
        if let regexp = NSRegularExpression( pattern: pattern ) {
            var nc: UInt32 = 0
            let classes = objc_copyClassList( &nc )
            
            for i in 0..<Int(nc) {
                let aClass: AnyClass = classes![i]!
                let className = NSStringFromClass( aClass ) as NSString
                if regexp.firstMatch( in: String( describing: className ) as String, range: NSMakeRange(0, className.length) ) != nil {
                    trace( aClass )
                }
            }
        }
    }

    /**
        Specify an individual classs to trace
        - parameter aClass: the class, the methods of which to trace
     */
    open class func trace( _ aClass: AnyClass ) {

        if aClass == self || aClass == SwiftTraceInfo.self || class_getSuperclass(aClass) == SwiftTraceInfo.self {
            return
        }

        let className = NSStringFromClass( aClass )
        if className == "__ARCLite__" || className.hasPrefix("Swift_") {
            return
        }

        traceObjcClass(object_getClass( aClass ), which: "+")
        traceObjcClass(aClass, which: "-")

        let swiftClass = unsafeBitCast(aClass, to: UnsafeMutablePointer<TargetClassMetadata>.self)

        if (swiftClass.pointee.Data & 0x1) == 0 {
            //print("Object is not instance of Swift class")
            return
        }

        withUnsafeMutablePointer(to: &swiftClass.pointee.IVarDestroyer) {
            (sym_start) in
            swiftClass.withMemoryRebound(to: Int8.self, capacity: 1) {
                let ptr = ($0 + -Int(swiftClass.pointee.ClassAddressPoint) + Int(swiftClass.pointee.ClassSize))
                ptr.withMemoryRebound(to: Optional<SIMP>.self, capacity: 1) {
                    (sym_end) in
//            let sym_end = UnsafeMutablePointer<SIMP?>($0 +
//                -Int(swiftClass.pointee.ClassAddressPoint) + Int(swiftClass.pointee.ClassSize))

                    var info = Dl_info()
                    for i in 0..<(sym_end - sym_start) {
                        if let fptr = sym_start[i] {
                            let vptr = unsafeBitCast(fptr, to: UnsafeRawPointer.self)
                            if dladdr( vptr, &info ) != 0 && info.dli_sname != nil {
                                let demangled = _stdlib_demangleName( String( cString: info.dli_sname ) )
                                if valid( demangled ) {
                                    let info = tracerClass.init( symbol: demangled,
                                                                 original: unsafeBitCast(fptr, to: IMP.self) )
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
    class func traceObjcClass( _ aClass: AnyClass, which: String ) {
        var mc: UInt32 = 0
        let methods = class_copyMethodList(aClass, &mc)
        let className = NSStringFromClass(aClass)

        for i in 0..<Int(mc) {
            let sel = method_getName(methods?[i])
            let selName = NSStringFromSelector(sel!)
            let type = method_getTypeEncoding(methods?[i])
            let symbol = "\(which)[\(className) \(selName)] -> \(String(cString: type!))"

            if !valid( symbol ) || (which == "+" ?
                    selName.hasPrefix("shared") :
                    dontSwizzleProperty(aClass, sel:sel!)) {
                continue
            }

            let info = tracerClass.init( symbol: symbol, original: method_getImplementation(methods?[i]) )
            class_replaceMethod( aClass, sel, info.forwardingImplementation(), type )
        }
    }

    /**
        Code intended to prevent property accessors from being traced
        - parameter aClass: class of method
        - parameter sel: selector of method being checked
     */
    class func dontSwizzleProperty( _ aClass: AnyClass, sel: Selector ) -> Bool {
        var name = [Int8]( repeating: 0, count: 5000 )
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
