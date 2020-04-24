//
//  SwiftTrace.swift
//  SwiftTraceApp
//
//  Created by John Holdsworth on 10/06/2016.
//  Copyright © 2016 John Holdsworth. All rights reserved.
//
//  Repo: https://github.com/johnno1962/SwiftTrace
//  $Id: //depot/SwiftTrace/SwiftTrace/SwiftTrace.swift#184 $
//

import Foundation

#if os(macOS)
import AppKit
typealias OSRect = NSRect
typealias OSPoint = NSPoint
typealias OSSize = NSSize
#elseif os(iOS) || os(tvOS)
import UIKit
typealias OSRect = CGRect
typealias OSPoint = CGPoint
typealias OSSize = CGSize
#endif

/** unsafeBitCast one type to another */
func autoBitCast<IN,OUT>(_ arg: IN) -> OUT {
    return unsafeBitCast(arg, to: OUT.self)
}

/**
    Base class for SwiftTrace api through it's public class methods
 */
@objc(SwiftTrace)
@objcMembers
open class SwiftTrace: NSObject {

    /**
        Class used to create "Patch" instances representing a member function
     */
    public static var swizzleFactory: Swizzle.Type = Arguments.self

    /**
        Class used to create "Invocation" instances representing a
        specific call to a member function on the "ThreadLocal" stack.
     */
    public static var defaultInvocationFactory = Swizzle.Invocation.self

    /**
        Type of "null implementation" replacing methods actual implementation
     */
    public typealias nullImplementationType = @convention(c) () -> AnyObject?

    static var lastSwiftTrace = SwiftTrace(previous: nil)

    init(previous: SwiftTrace?) {
        previousSwiftTrace = previous
    }

    /** Dictionary of patch objects created by trampoline */
    var previousSwiftTrace: SwiftTrace?

    /** Trace only instances of a particular class */
    var classFilter: AnyClass?

    /** Trace only a particualar instance */
    var instanceFilter: AnyObject?

    /** Dictionary of patch objects created by trampoline */
    var activeSwizzles = [IMP: Swizzle]()

    @discardableResult
    open class func startNewTrace() -> SwiftTrace {
        lastSwiftTrace = SwiftTrace(previous: Self.lastSwiftTrace)
        return lastSwiftTrace
    }

    /**
     default pattern of symbols to be excluded from tracing
     */
    open class var defaultMethodExclusions: String { "\\.getter| (?:retain|_tryRetain|release|_isDeallocating|.cxx_destruct|dealloc|description| debugDescription)]|initWithCoder|^\\+\\[(Reader_Base64|UI(NibStringIDTable|NibDecoder|CollectionViewData|WebTouchEventsGestureRecognizer)) |^.\\[UIView |UIDeviceWhiteColor initWithWhite:alpha:|UIButton _defaultBackgroundImageForType:andState:|UIImage _initWithCompositedSymbolImageLayers:name:alignUsingBaselines:|_UIWindowSceneDeviceOrientationSettingsDiffAction _updateDeviceOrientationWithSettingObserverContext:windowScene:transitionContext:|UIColorEffect colorEffectSaturate:|UIWindow _windowWithContextId:|RxSwift.ScheduledDisposable.dispose|RemoteCapture (?:capture0|subtractAndEncode:)" }

    static var inclusionRegexp: NSRegularExpression?
    static var exclusionRegexp: NSRegularExpression? = NSRegularExpression(regexp: defaultMethodExclusions)

    /**
     Include symbols matching pattern only
     - parameter pattern: regexp for symbols to include
     */
    open class func include(_ pattern: String) {
        inclusionRegexp = NSRegularExpression(regexp: pattern)
    }

    /**
     Exclude symbols matching this pattern. If not specified
     a default pattern in swiftTraceDefaultExclusions is used.
     - parameter pattern: regexp for symbols to exclude
     */
    open class func exclude(_ pattern: String) {
        exclusionRegexp = NSRegularExpression(regexp: pattern)
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
    open class func traceBundle(containing theClass: AnyClass) {
        startNewTrace()
        trace(bundlePath: class_getImageName(theClass))
    }

    /**
        Trace all user developed classes in the main bundle of an app
     */
    open class func traceMainBundle() {
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

        if let classes = UnsafePointer(objc_copyClassList(&nc)) {
            for i in 0 ..< Int(nc) {
                callback(classes[i], &stopped)
                if stopped {
                    break
                }
            }
            free(UnsafeMutableRawPointer(mutating: classes))
        }

        return stopped
    }

    /**
        Trace a classes defined in a specific bundlePath (executable image)
     */
    class func trace(bundlePath: UnsafePointer<Int8>?) {
        startNewTrace()
        var registered = Set<UnsafeRawPointer>()
        forAllClasses {
            (aClass, stop) in
            if class_getImageName(aClass) == bundlePath {
                trace(aClass: aClass)
                registered.insert(autoBitCast(aClass))
            }
        }
        /* This should pick up and Pure Swift classes */
        findPureSwiftClasses(bundlePath, { aClass in
            if !registered.contains(aClass) {
                trace(aClass: autoBitCast(aClass))
            }
        })
    }

    /**
        Lists Swift classes in an app or framework.
     */
    open class func swiftClassList(bundlePath: UnsafePointer<Int8>) -> [AnyClass] {
        var classes = [AnyClass]()
        findPureSwiftClasses(bundlePath, { aClass in
            classes.append(autoBitCast(aClass))
        })
        return classes
    }

    /**
        Intercepts and tracess all classes with names matching regexp pattern
        - parameter pattern: regexp patten to specify classes to trace
     */
    open class func traceClassesMatching(pattern: String) {
        startNewTrace()
        let regexp = NSRegularExpression(regexp: pattern)
        forAllClasses {
            (aClass, stop) in
            let className = NSStringFromClass(aClass) as NSString
            if regexp.firstMatch(in: String(describing: className) as String, range: NSMakeRange(0, className.length)) != nil {
                trace(aClass: aClass)
            }
        }
    }

    /**
        Specify an individual classs to trace
        - parameter aClass: the class, the methods of which to trace
     */
    open class func trace(aClass: AnyClass) {
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
                let patch = swizzleFactory.init(name: name, vtableSlot: vtableSlot) {
                vtableSlot.pointee = patch.forwardingImplementation()
            }
        }
    }

    /**
        Specify an individual classs to trace
        - parameter aClass: the class, the methods of which to trace
     */
    open class func traceInstances(aClass: AnyClass) {
        startNewTrace().classFilter = aClass
        var tClass: AnyClass? = aClass
        while tClass != NSObject.self && tClass != nil {
            trace(aClass: tClass!)
            tClass = class_getSuperclass(tClass)
        }
    }

    /**
        Specify an individual classs to trace
        - parameter aClass: the class, the methods of which to trace
     */
    open class func traceInstance(anInstance: AnyObject) {
        startNewTrace().instanceFilter = anInstance
        traceInstances(aClass: object_getClass(anInstance)!)
    }

    /**
        Iterate over all methods in the vtable that follows the class information
        of a Swift class (TargetClassMetadata)
     */
    @discardableResult
    open class func iterateMethods(ofClass aClass: AnyClass,
           callback: (_ name: String, _ vtableSlot: UnsafeMutablePointer<SIMP>, _ stop: inout Bool) -> Void) -> Bool {
        let swiftMeta: UnsafeMutablePointer<TargetClassMetadata> = autoBitCast(aClass)
        let className = NSStringFromClass(aClass)
        var stop = false

        guard (className.hasPrefix("_Tt") || className.contains(".")) &&
            !className.hasPrefix("Swift.") && class_getSuperclass(aClass) != nil else {
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
                        if var impl: IMP = autoBitCast(vtableStart[i]) {
                            if let patch = Swizzle.originalSwizzle(for: impl) {
                                impl = patch.implementation
                            }
                            let voidPtr: UnsafeMutableRawPointer = autoBitCast(impl)
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

    /**
        Remove all patches applied until now
     */
    open class func removeAllSwizzles() {
        while true {
            lastSwiftTrace.removeSwizzles()
            if let previous = lastSwiftTrace.previousSwiftTrace {
                lastSwiftTrace = previous
            } else {
                break
            }
        }
    }

    /**
        Remove all patches for this trace
     */
    open func removeSwizzles() {
        for (_, swizzle) in activeSwizzles {
            swizzle.removeAll()
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
                    dontSwizzleProperty(aClass: aClass, sel:sel)) {
                    continue
                }

                if let info = swizzleFactory.init(name: name, objcMethod: method) {
                    method_setImplementation(method,
                        autoBitCast(info.forwardingImplementation()))
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
    class func dontSwizzleProperty(aClass: AnyClass, sel: Selector) -> Bool {
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
}

/**
    Convenience extension to trap regex errors and report them
 */
extension NSRegularExpression {

    convenience init(regexp: String) {
        do {
            try self.init(pattern: regexp)
        }
        catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }

    func matches(_ string: String) -> Bool {
        return rangeOfFirstMatch(in: string,
            range: NSRange(string.startIndex ..< string.endIndex,
                           in: string)).location != NSNotFound
    }
}
