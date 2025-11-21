//
//  SwiftTrace.swift
//  SwiftTraceApp
//
//  Created by John Holdsworth on 10/06/2016.
//  Copyright © 2016 John Holdsworth. All rights reserved.
//
//  Repo: https://github.com/johnno1962/SwiftTrace
//  $Id: //depot/SwiftTrace/SwiftTrace/SwiftTrace.swift#330 $
//

#if DEBUG || !DEBUG_ONLY
import Foundation
#if SWIFT_PACKAGE
#if canImport(InjectionNextC)
@_exported import InjectionNextC
#elseif DEBUG_ONLY
@_exported import SwiftTraceGutsD
#else
@_exported import SwiftTraceGuts
#endif
#endif

/**
    Base class for SwiftTrace api through it's public class methods
 */
@objc(SwiftTrace)
@objcMembers
/// Base namespace of SwiftTrace functions
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
     Indentation amongst different call levels on the stack
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
        Does the class have a .cxx_destruct method for tracking deallocs?
     */
    public static var tracksDeallocs = Set<UnsafeRawPointer>()

    /**
        Type of "null implementation" replacing methods actual implementation
     */
    public typealias nullImplementationType = @convention(c) () -> AnyObject?

    public static var lastSwiftTrace = SwiftTrace(previous: nil, subLevels: 0)

    /// Previous interposes need to be tracked
    fileprivate static var interposed = [UnsafeRawPointer: UnsafeRawPointer]()

    /**
     Returns a pointer to the interposed dictionary. Required to
     ensure only one interposed dictionary us used if the user
     includes SwiftTrace as a package or pod in their project.
     */
    @objc public class var interposedPointer: UnsafeMutableRawPointer {
        return UnsafeMutableRawPointer(&interposed)
    }

    static var bundlesInterposed = Set<String>()

    public class var isTracing: Bool {
        return lastSwiftTrace.previousSwiftTrace != nil
    }

    /** Linked list of previous traces */
    open var previousSwiftTrace: SwiftTrace?

    /** Trace only instances of a particular class */
    var classFilter: AnyClass?

    /** Trace only a particular instance */
    var instanceFilter: intptr_t?

    /** Trace only a particular instance */
    let subLevels: Int

    /** Dictionary of swizzle objects created by trampoline */
    open var activeSwizzles = [IMP: Swizzle]()

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
    public static var defaultMethodExclusions: String = """
            \\.getter : (?!some)|\\.hash[(]into: | async |interposedPointer|\
             (?:retain(?:Count)?|_tryRetain|release|autorelease|_isDeallocating|_?dealloc|class|self|description|\
            debugDescription|contextID|undoManager|_animatorClassForTargetClass|cursorUpdate|_isTrackingAreaObject)]|\
            ^\\+\\[(?:Reader_Base64|UI(?:NibStringIDTable|NibDecoder|CollectionViewData|WebTouchEventsGestureRecognizer)) |\
            ^.\\[(?:__NSAtom|NS(?:View|Appearance|AnimationContext|Segment|KVONotifying_\\S+)|_NSViewAnimator|UIView|RemoteCapture|BCEvent|SimpleSocket) |\
            _TtGC7SwiftUI|NSTheme|NSTracking|UIDeviceWhiteColor initWithWhite:alpha:|UIButton _defaultBackgroundImageForType:andState:|\
            UIImage _initWithCompositedSymbolImageLayers:name:alignUsingBaselines:|\
            _UIWindowSceneDeviceOrientationSettingsDiffAction _updateDeviceOrientationWithSettingObserverContext:windowScene:transitionContext:|\
            UIColorEffect colorEffectSaturate:|UIWindow _windowWithContextId:|RxSwift.ScheduledDisposable.dispose| ns(?:li|is)_|\
            Swift(Trace|Regex)|HotReloading|Xprobe|eraseToAnyView|enableInjection|.cxx_construct|_objc_initiateDealloc
            """

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
            inclusionRegexp?.matches(symbol) != false &&
            exclusionRegexp?.matches(symbol) != true ?
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
        trace(bundlePath: Bundle.main.executablePath!, subLevels: subLevels)
    }

    /**
     Iterate over all known classes in the app
     - parameter bundlePath: optional path to framework containg class
     */
    @discardableResult
    open class func forAllClasses(bundlePath: UnsafePointer<Int8>? = nil,
                                  callback: @escaping (_ aClass: AnyClass,
                                    _ stop: inout Bool) -> Void ) -> Bool {
        var stopped = false
        var seen = Set<UnsafeRawPointer>()
        if bundlePath != nil {
            let resilientSuperclass = 1 // dummy value for superclass
            let resilientPrefix = "OBJC_CLASS_$__TtC"
            findHiddenSwiftSymbols(bundlePath, classesIncludingObjc(), .any) {
                aClass, symbol, _,_ in
                var aClass = aClass
                let symname = String(cString: symbol)
                if aClass.load(as: intptr_t.self) == resilientSuperclass,
                    symname.hasPrefix(resilientPrefix),
                    let mangled = symname[safe: (.start+resilientPrefix.count)...],
                    let resilientClass = _typeByName(mangled+"C") as? AnyClass {
                    aClass = autoBitCast(resilientClass)
                }
                if !stopped && seen.insert(aClass).inserted {
                    callback(autoBitCast(aClass), &stopped)
                }
            }
            return stopped
        }

        // The old version of the code...
        var nc: UInt32 = 0
        if let classes = UnsafePointer(objc_copyClassList(&nc)) {
            for i in 0 ..< Int(nc) {
                let aClass: AnyClass = classes[i]
                if class_getSuperclass(aClass) != nil,
                   let imageName = class_getImageName(aClass),
                    bundlePath == nil || imageName == bundlePath ||
                    strcmp(imageName, bundlePath) == 0 {
                    callback(aClass, &stopped)
                }
                seen.insert(autoBitCast(aClass))
                if stopped {
                    break
                }
            }
            free(UnsafeMutableRawPointer(mutating: classes))
        }

        /* This should pick up Pure Swift classes */
        Bundle.main.executablePath!.withCString { executable in
            findSwiftSymbols(bundlePath ?? executable, "CN") {
                aClass, _,  _, _ in
                if !seen.contains(aClass) && !stopped {
                    callback(autoBitCast(aClass), &stopped)
                }
            }
        }

        return stopped
    }

    /**
     Trace a classes defined in a specific bundlePath (executable image)
     - parameter bundlePath: Path to bundle to trace
     - parameter subLevels: levels of unqualified traces to show
     */
    @objc open class func trace(bundlePath: UnsafePointer<Int8>?, subLevels: Int = 0) {
        startNewTrace(subLevels: subLevels)
        forAllClasses(bundlePath: bundlePath) {
            (aClass, stop) in
            trace(aClass: aClass)
        }
    }

    /**
     Lists Swift classes not inheriting from NSObject in an app or framework.
     */
    @objc open class func swiftClassList(bundlePath: UnsafePointer<Int8>? = nil) -> [AnyClass] {
        var classes = [AnyClass]()
        findSwiftSymbols(bundlePath, "CN") { aClass, _, _, _ in
            classes.append(autoBitCast(aClass))
        }
        return classes
    }

    /**
     Intercepts and tracess all classes with names matching regexp pattern
     - parameter pattern: regexp patten to specify classes to trace
     - parameter subLevels: levels of unqualified traces to show
     */
    @objc open class func traceClasses(matchingPattern pattern: String, subLevels: Int = 0) {
        startNewTrace(subLevels: subLevels)
        let regexp = NSRegularExpression(regexp: pattern)
        forAllClasses {
            (aClass, stop) in
            if regexp.matches(NSStringFromClass(aClass)) {
                trace(aClass: aClass)
            }
        }
    }

    static let retainSelector = sel_registerName("retain")

    /**
     Underlying implementation of tracing an individual classs.
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

        if class_getInstanceMethod(aClass, retainSelector) != nil {
            trace(objcClass: object_getClass(aClass)!, which: "+")
        }
        trace(objcClass: aClass, which: "-")

//        if let bundle = class_getImageName(aClass),
//            bundlesInterposed.contains(String(cString: bundle)) {
//            return
//        }

        iterateMethods(ofClass: aClass) {
            (name, slotIndex, vtableSlot, stop) in
            if let factory = methodFilter(name) {
                if let swizzle = factory.init(name: name, vtableSlot: vtableSlot) {
//                    print("Patching #\(slotIndex) \(name)")
                    vtableSlot.pointee = swizzle.forwardingImplementation
                }
            } else if !name.contains(".getter :") {
                print("Excluding SwiftTrace of \(name)")
            }
        }
    }

    /**
     Trace instances of a particular class including methods of superclass
     - parameter aClass: the class, the methods of which to trace
     - parameter subLevels: levels of unqualified traces to show
     */
    @objc open class func traceInstances(ofClass aClass: AnyClass, subLevels: Int = 0) {
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
    @objc open class func trace(anInstance: AnyObject, subLevels: Int = 0) {
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
                                   callback: (_ name: String, _ slotIndex: Int,
                                              _ vtableSlot: UnsafeMutablePointer<SIMP>,
                                              _ stop: inout Bool) -> Void) -> Bool {
        forEachVTableEntry(ofClass: aClass) {
            (symname, slotIndex, vtableSlot, stop) in
            if let demangled = SwiftMeta.demangle(symbol: symname) {
                callback(demangled, slotIndex, vtableSlot, &stop)
            }
        }
    }

    /**
     Iterate over all methods in the vtable that follows the class information
     of a Swift class (TargetClassMetadata)
     - parameter aClass: the class, the methods of which to trace
     - parameter callback: per method callback
     */
    @discardableResult
    open class func forEachVTableEntry(ofClass aClass: AnyClass,
                               callback: (_ symname: UnsafePointer<CChar>,
                                          _ slotIndex: Int,
                                          _ vtableSlot: UnsafeMutablePointer<SIMP>,
                                          _ stop: inout Bool) -> Void) -> Bool {
        let swiftMeta: UnsafeMutablePointer<SwiftMeta.TargetClassMetadata> = autoBitCast(aClass)
        let className = NSStringFromClass(aClass)
        var stop = false

        guard (className.hasPrefix("_Tt") || className.contains(".")) &&
                !className.hasPrefix("Swift.") &&
                swiftMeta.pointee.ClassAddressPoint > 1 else {//} && class_getSuperclass(aClass) != nil else {
            //print("Object is not instance of Swift class")
            return false
        }

        let endMeta = UnsafeMutablePointer<Int8>(cast: swiftMeta) -
            Int(swiftMeta.pointee.ClassAddressPoint) +
            Int(swiftMeta.pointee.ClassSize)
        let vtableStart = UnsafeMutablePointer<SIMP?>(cast:
            &swiftMeta.pointee.IVarDestroyer)
        let vtableEnd = UnsafeMutablePointer<SIMP?>(cast: endMeta)

        var info = Dl_info()
        for slotIndex in 0..<(vtableEnd - vtableStart) {
            if var impl: IMP = autoBitCast(vtableStart[slotIndex]) {
                if let swizzle = originalSwizzle(for: impl) {
                    impl = swizzle.implementation
                }
                if fast_dladdr(autoBitCast(impl), &info) != 0,
                   let symname = info.dli_sname,
                    // patch constructors, destructors, methods, getters, setters.
                    injectableSymbol(symname) {
                    callback(symname, slotIndex,
                             &vtableStart[slotIndex]!, &stop)
                    if stop {
                        break
                    }
                }
            }
        }

        return stop
    }

    public static var preserveStatics = false
    public static let deviceInjection = lastPseudoImage() != nil

    /// Determine if symbol name is injectable
    /// - Parameter symname: Pointer to symbol name
    /// - Returns: Whether symbol should be patched
    @objc public static var injectableSymbol: // STSymbolFilter
        (UnsafePointer<CChar>) -> Bool = { symname in
//        print("Injectable?", String(cString: symname))
        let symstart = symname +
            (symname.pointee == UInt8(ascii: "_") ? 1 : 0)
        let isCPlusPlus = strncmp(symstart, "_ZN", 3) == 0
        if isCPlusPlus { return true }
        let isSwift = strncmp(symstart, "$s", 2) == 0
        if !isSwift { return false }
        var symlast = symname+strlen(symname)-1
        return
            symlast.match(ascii: "C") ||
            symlast.match(ascii: "D") && symlast.match(ascii: "f") ||
            // static/class methods, getters, setters
            (symlast.match(ascii: "Z") || true) &&
                (symlast.match(ascii: "F") ||
                 symlast.match(ascii: "g") ||
                 symlast.match(ascii: "s")) ||
            // async [class] functions
            symlast.match(ascii: "u") && (
                symlast.match(ascii: "T") &&
                (symlast.match(ascii: "Z") || true) &&
                symlast.match(ascii: "F") ||
                // "Mutable Addressors"
                !preserveStatics &&
                symlast.match(ascii: "a") &&
                symlast.match(ascii: "v")) ||
            symlast.match(ascii: "M") &&
            symlast.match(ascii: "v")
    }

    #if swift(>=5.0)
    /**
     Trace internal protocol witnesses in SwiftUI.
     */
    @objc open class func traceSwiftUIProtocols(matchingPattern: String? = nil,
                                                subLevels: Int = 0) {
        traceProtocols(inBundle: swiftUIBundlePath(),
                       matchingPattern: matchingPattern, subLevels: subLevels)
    }
    /**
     Trace the protocol witnesses for a bundle containg the specified class
     - parameter aClass: the class contained in the bundle to trace
     - parameter matchingPattern: regex pattern to match entries against
     - parameter subLevels: subLevels to log of previous traces to trace
     */
    @objc open class func traceProtocolsInBundle(containing aClass: AnyClass? = nil, matchingPattern: String? = nil, subLevels: Int = 0) {
        let bundlePath = aClass == nil ? callerBundle() :
            aClass == NSObject.self ? nil : class_getImageName(aClass)
        traceProtocols(inBundle: bundlePath, matchingPattern: matchingPattern, subLevels: subLevels)
    }
    /**
     Trace the protocol witnesses for a bundle specifying the image path
     - parameter inBundle: Path to image the protocols of which to trace
     - parameter matchingPattern: regex pattern to match entries against
     - parameter subLevels: subLevels to log of previous traces to trace
     */
    @objc open class func traceProtocols(inBundle: UnsafePointer<Int8>?, matchingPattern: String? = nil, subLevels: Int = 0) {
        startNewTrace(subLevels: subLevels)
        let regex = matchingPattern.flatMap { NSRegularExpression(regexp: $0) }
        for witness in ["WP", "Wl"] {
            findHiddenSwiftSymbols(inBundle, witness, witness == "Wl" ?
                                    .hidden : .global) {
                (address: UnsafeRawPointer, _, typeref, typeend) in
                let witnessTable = UnsafeMutablePointer<SIMP>(mutating: address)
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
                        let demangled = SwiftMeta.demangle(symbol: info.dli_sname) {
                        if demangled.hasPrefix("protocol witness table for") {
                            continue
                        }
                        if demangled.hasPrefix("protocol witness for ") &&
                                !demangled.contains("SwiftTrace.") {
                            if regex?.matches(demangled) != false,
                                let factory = methodFilter(demangled),
                                let swizzle = factory.init(name: demangled,
                                               vtableSlot: &witnessTable[slot]) {
    //                            print("Tracing \(slot):", demangled)
                                witnessTable[slot] = swizzle.forwardingImplementation
                            }
                            continue
                        }
                    }
                    break
                }
            }
        }
    }
    #endif

    /** follow chain of Sizzles through to find original implementataion */
    open class func originalSwizzle(for implementation: IMP) -> Swizzle? {
        var trace: SwiftTrace? = SwiftTrace.lastSwiftTrace
        var implementation = implementation
        var swizzle: Swizzle?
        while trace != nil {
            while let previous = trace?.activeSwizzles[implementation] {
                swizzle = previous
                implementation = previous.implementation
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
            (name, slotIndex, vtableSlot, stop) in
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
                    let swizzle = factory.init(name: name, objcMethod: method,
                                               objcClass: aClass) {
//                    print("Sizzling \(name)")
                    class_replaceMethod(aClass, sel,
                            autoBitCast(swizzle.forwardingImplementation), type)
                    if selName == ".cxx_destruct" {
                        tracksDeallocs.insert(autoBitCast(aClass as Any.Type))
                    }
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

extension UnsafePointer where Pointee == Int8 {
    @inline(__always)
    mutating func match(ascii: UnicodeScalar, inc: Int = -1) -> Bool {
        if pointee == UInt8(ascii: ascii) {
            self = self.advanced(by: inc)
            return true
        }
        return false
    }
}
#endif
