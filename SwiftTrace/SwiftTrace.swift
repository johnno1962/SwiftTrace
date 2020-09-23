//
//  SwiftTrace.swift
//  SwiftTraceApp
//
//  Created by John Holdsworth on 10/06/2016.
//  Copyright © 2016 John Holdsworth. All rights reserved.
//
//  Repo: https://github.com/johnno1962/SwiftTrace
//  $Id: //depot/SwiftTrace/SwiftTrace/SwiftTrace.swift#230 $
//

import Foundation
#if SWIFT_PACKAGE
import SwiftTraceGuts
#endif

#if os(macOS)
import AppKit
typealias OSRect = NSRect
typealias OSPoint = NSPoint
typealias OSSize = NSSize
typealias OSEdgeInsets = NSEdgeInsets
#elseif os(iOS) || os(tvOS)
import UIKit
typealias OSRect = CGRect
typealias OSPoint = CGPoint
typealias OSSize = CGSize
typealias OSEdgeInsets = UIEdgeInsets
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
     Format for ms of time spend in method
     */
    public static var timeFormat = " %.1fms"

    /**
     Format for idenifying class instance
     */
    public static var identifyFormat = "<%@ %p>"

    /**
     Indentation amogst different call levels on the stack
     */
    public static var traceIndent = "  "

    /**
        Class used to create "Sizzle" instances representing a member function
     */
    public static var swizzleFactory: Swizzle.Type = Decorated.self

    /**
        Class used to create "Invocation" instances representing a
        specific call to a member function on the "ThreadLocal" stack.
     */
    public static var defaultInvocationFactory = Swizzle.Invocation.self

    /**
        Type of "null implementation" replacing methods actual implementation
     */
    public typealias nullImplementationType = @convention(c) () -> AnyObject?

    public static var lastSwiftTrace = SwiftTrace(previous: nil, subLevels: 0)

    /** Linked list of previous traces */
    let previousSwiftTrace: SwiftTrace?

    /** Trace only instances of a particular class */
    var classFilter: AnyClass?

    /** Trace only a particular instance */
    var instanceFilter: intptr_t?

    /** Trace only a particular instance */
    let subLevels: Int

    /** Dictionary of swizzle objects created by trampoline */
    var activeSwizzles = [IMP: Swizzle]()

    public required init(previous: SwiftTrace?, subLevels: Int) {
        previousSwiftTrace = previous
        self.subLevels = subLevels
        super.init()
    }

    @discardableResult
    open class func startNewTrace(subLevels: Int) -> SwiftTrace {
        if subLevels != 0 {
            lastSwiftTrace.mutePreviousUnfiltered()
        }
        lastSwiftTrace = self.init(previous: lastSwiftTrace, subLevels: subLevels)
        return lastSwiftTrace
    }

    static let neverMatches = -1

    open func mutePreviousUnfiltered() {
        if instanceFilter == nil && classFilter == nil {
            instanceFilter = SwiftTrace.neverMatches
        }
        previousSwiftTrace?.mutePreviousUnfiltered()
    }

    /**
     Default pattern of common/problematic symbols to be excluded from tracing
     */
    open class var defaultMethodExclusions: String {
        return """
            \\.getter| (?:retain|_tryRetain|release|autorelease|_isDeallocating|.cxx_destruct|dealloc|description| debugDescription)]|initWithCoder|\
            ^\\+\\[(?:Reader_Base64|UI(?:NibStringIDTable|NibDecoder|CollectionViewData|WebTouchEventsGestureRecognizer)) |\
            ^.\\[(?:UIView|RemoteCapture|BCEvent) |UIDeviceWhiteColor initWithWhite:alpha:|UIButton _defaultBackgroundImageForType:andState:|\
            UIImage _initWithCompositedSymbolImageLayers:name:alignUsingBaselines:|\
            _UIWindowSceneDeviceOrientationSettingsDiffAction _updateDeviceOrientationWithSettingObserverContext:windowScene:transitionContext:|\
            UIColorEffect colorEffectSaturate:|UIWindow _windowWithContextId:|RxSwift.ScheduledDisposable.dispose| ns(?:li|is)_
            """
    }

    static var exclusionRegexp: NSRegularExpression? =
        NSRegularExpression(regexp: defaultMethodExclusions)
    static var inclusionRegexp: NSRegularExpression?

    /**
     Exclude symbols matching this pattern. If not specified
     a default pattern in swiftTraceDefaultExclusions is used.
     */
    open class var methodExclusionPattern: String? {
        get { return exclusionRegexp?.pattern }
        set(newValue) {
            exclusionRegexp = newValue == nil ? nil :
                NSRegularExpression(regexp: newValue!)
        }
    }

    /**
     Include symbols matching pattern only
     */
    open class var methodInclusionPattern: String? {
        get { return inclusionRegexp?.pattern }
        set(newValue) {
            inclusionRegexp = newValue == nil ? nil :
                NSRegularExpression(regexp: newValue!)
        }
    }

    /**
     Default/current implementation for method filter
     */
    static var _methodFilter: (_ symbol: String) -> Swizzle.Type? = {
        (symbol) in
        return
            (inclusionRegexp?.matches(symbol) != false) &&
            (exclusionRegexp?.matches(symbol) != true) ?
            swizzleFactory : nil
    }

    /**
     In order to be traced, symbol must be included and not excluded
     - parameter symbol: String representation of method
     */
    open class var methodFilter: (_ symbol: String) -> Swizzle.Type? {
        get { return _methodFilter }
        set(newValue) { _methodFilter = newValue }
    }

    /**
     Intercepts and tracess all classes linked into the bundle containing a class.
     - parameter theClass: the class to specify the bundle, nil implies caller bundle
     - parameter subLevels: levels of unqualified traces to show
     */
    open class func traceBundle(containing theClass: AnyClass? = nil, subLevels: Int = 0) {
        trace(bundlePath: theClass != nil ?
            class_getImageName(theClass) : callerBundle(), subLevels: subLevels)
    }

    /**
     Trace all user developed classes in the main bundle of an app
     - parameter subLevels: levels of unqualified traces to show
     */
    open class func traceMainBundle(subLevels: Int = 0) {
        let RTLD_MAIN_ONLY = UnsafeMutableRawPointer(bitPattern: -5)
        let main = dlsym(RTLD_MAIN_ONLY, "main")
        var info = Dl_info()
        if main != nil && dladdr(main, &info) != 0 && info.dli_fname != nil {
            trace(bundlePath: info.dli_fname, subLevels: subLevels)
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
     - parameter bundlePath: Path to bundle to trace
     - parameter subLevels: levels of unqualified traces to show
     */
    class func trace(bundlePath: UnsafePointer<Int8>?, subLevels: Int = 0) {
        startNewTrace(subLevels: subLevels)
        var registered = Set<UnsafeRawPointer>()
        forAllClasses {
            (aClass, stop) in
            if class_getImageName(aClass) == bundlePath {
                trace(aClass: aClass)
                registered.insert(autoBitCast(aClass))
            }
        }
        /* This should pick up and Pure Swift classes */
        findSwiftSymbols(bundlePath, "CN", { aClass, _,  _, _ in
            if !registered.contains(aClass) {
                trace(aClass: autoBitCast(aClass))
            }
        })
    }

    /**
     Lists Swift classes not inheriting from NSObject in an app or framework.
     */
    open class func swiftClassList(bundlePath: UnsafePointer<Int8>? = nil) -> [AnyClass] {
        var classes = [AnyClass]()
        findSwiftSymbols(bundlePath, "CN", { aClass, _, _, _ in
            classes.append(autoBitCast(aClass))
        })
        return classes
    }

    /**
     Intercepts and tracess all classes with names matching regexp pattern
     - parameter pattern: regexp patten to specify classes to trace
     - parameter subLevels: levels of unqualified traces to show
     */
    open class func traceClasses(matchingPattern pattern: String, subLevels: Int = 0) {
        startNewTrace(subLevels: subLevels)
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
     Underlying implementation of tracing an individual classs.
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
            if let factory = methodFilter(name),
                let swizzle = factory.init(name: name, vtableSlot: vtableSlot) {
                vtableSlot.pointee = swizzle.forwardingImplementation()
            }
        }
    }

    /**
     Trace instances of a particular class including methods of superclass
     - parameter aClass: the class, the methods of which to trace
     - parameter subLevels: levels of unqualified traces to show
     */
    open class func traceInstances(ofClass aClass: AnyClass, subLevels: Int = 0) {
        startNewTrace(subLevels: subLevels).classFilter = aClass
        var tClass: AnyClass? = aClass
        while tClass != NSObject.self && tClass != nil {
            trace(aClass: tClass!)
            tClass = class_getSuperclass(tClass)
        }
    }

    /**
     Trace a particular instance only.
     - parameter anInstance: the class, the methods of which to trace
     - parameter subLevels: levels of unqualified traces to show
     */
    open class func trace(anInstance: AnyObject, subLevels: Int = 0) {
        traceInstances(ofClass: object_getClass(anInstance)!, subLevels: subLevels)
        lastSwiftTrace.instanceFilter = unsafeBitCast(anInstance, to: intptr_t.self)
        lastSwiftTrace.classFilter =  nil
    }

    /**
     Iterate over all methods in the vtable that follows the class information
     of a Swift class (TargetClassMetadata)
     - parameter aClass: the class, the methods of which to trace
     - parameter callback: per method callback
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
                            if let swizzle = originalSwizzle(for: impl) {
                                impl = swizzle.implementation
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
     Trace the protocol witnesses for a bundle containg the specified class
     - parameter aClass: the class, the methods of which to trace
     - parameter matchingPattern: regex pattern to match entries against
     - parameter subLevels: subLevels to log of previous traces to trace
     */
    #if swift(>=5.0)
    open class func traceProtocolsInBundle(containing aClass: AnyClass? = nil, matchingPattern: String? = nil, subLevels: Int = 0) {
        startNewTrace(subLevels: subLevels)
        let regex = matchingPattern != nil ?
            NSRegularExpression(regexp: matchingPattern!) : nil
        findSwiftSymbols(aClass == nil ? callerBundle() :
            aClass == NSObject.self ? nil : class_getImageName(aClass), "WP") {
            (address: UnsafeMutableRawPointer, _, typeref, typeend) in
            let witnessTable = address.assumingMemoryBound(to: SIMP.self)
            var info = Dl_info()
            // The start of a witness table is always the protocol descriptor
            // then the associated types (always in section `__swift5_typeref`)
            // followed by pointers to the witness tables of the protocols the
            // protocol directly inherits from and finally pointers to the
            // implementations of the functions defined by the original protocol.
            // So it is possible to "safely" scan until the demangled symbol
            // name is not an inherited protocol witness table or witness entry.
            for slot in 1..<1000 {
                // skip associated type witness entries
                if typeref <= autoBitCast(witnessTable[slot]) &&
                    autoBitCast(witnessTable[slot]) < typeend {
                    continue
                }
                if fast_dladdr(autoBitCast(witnessTable[slot]),
                               &info) != 0 && info.dli_sname != nil,
                    let demangled = demangle(symbol: info.dli_sname) {
                    if demangled.hasPrefix("protocol witness table for") {
                        continue
                    }
                    if demangled.hasPrefix("protocol witness for ") &&
                            !demangled.contains("SwiftTrace."),
                        regex == nil || regex!.matches(demangled) {
                        if let factory = methodFilter(demangled),
                            let swizzle = factory.init(name: demangled,
                                                       vtableSlot: &witnessTable[slot]) {
                            witnessTable[slot] = swizzle.forwardingImplementation()
                        }
                        continue
                    }
                }
                break
            }
        }
    }
    #endif

    /** follow chain of Sizzles through to find original implementataion */
    open class func originalSwizzle(for implementation: IMP) -> Swizzle? {
        var implementation = implementation
        var swizzle: Swizzle?
        var trace: SwiftTrace? = SwiftTrace.lastSwiftTrace
        while trace != nil {
            while trace!.activeSwizzles[implementation] != nil {
                swizzle = trace!.activeSwizzles[implementation]
                implementation = swizzle!.implementation
            }
            trace = trace?.previousSwiftTrace
        }
        return swizzle
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

    open class func undoLastTrace() -> Bool {
        lastSwiftTrace.removeSwizzles()
        if let previous = lastSwiftTrace.previousSwiftTrace {
            lastSwiftTrace = previous
            return true
        }
        return false
    }

    /**
     Remove all swizzles applied until now
     */
    open class func removeAllTraces() {
        while undoLastTrace() {
        }
    }

    /**
     Remove all swizzles for this trace
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

                if which == "+" ? selName.hasPrefix("shared") :
                    dontSwizzleProperty(aClass: aClass, sel:sel) {
                    continue
                }

                if let factory = methodFilter(name),
                    let swizzle = factory.init(name: name, objcMethod: method) {
                    class_replaceMethod(aClass, sel,
                            autoBitCast(swizzle.forwardingImplementation()), type)
                }
            }
            free(methods)
        }
    }

    /**
     Very old code intended to prevent property accessors from being traced
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
