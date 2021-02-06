//
//  AppDelegate.swift
//  SwiftTraceOSX
//
//  Created by John Holdsworth on 13/06/2016.
//  Copyright © 2016 John Holdsworth. All rights reserved.
//

import Cocoa

public typealias XInt = UInt16

public struct Stret: SwiftTraceFloatArg {
    let r1: CGRect, r2: CGRect, r3: CGRect
}

public struct Str3 {
    var s1 = "s1", s2 = "s2", s3 = "s3"
}

public typealias uuid_t = (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)
public typealias uuid_string_t = (Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8)

public struct STR: Hashable {
    let s: String
//    let a = 1
//    let u = URL(string: "https://google.com")
    let u = URL(string: "")
//    let b = 2
    public init(s: String) {
        self.s = s
//        u = UUID()
//        print(u)
    }
    public func hash(into hasher: inout Hasher) {
//        s.hash(into: &hasher)
    }
    public static func ==(lhs: STR, rhs: STR) -> Bool {
        return lhs.s == rhs.s && lhs.u == rhs.u
    }
}

public protocol P2 {
}
extension String: P2 {
}

public protocol P {
    associatedtype myType
    associatedtype myType2
    var i: Int { get set }
    func x()
    func y() -> Float
    func z( _ d: XInt, f: Double, s: String?, g: Float, h: Double, f1: Double?, g1: Float, h1: Double, f2: Double, g2: Float, h2: myType?, e: myType2? )
    func rect(r1: NSRect, r2: NSRect) -> NSRect
    func rect2(r1: NSRect, r2: NSRect) -> Stret
    func arr(a: [String?], b: [Int]) -> ArraySlice<String?>
    func arr2(a: [String?], b: [Int]) -> Set<STR>
    func str(i: Int, s: STR, j: Int) -> STR
    func dict(d: [String: Set<STR>]?) -> [String: Set<STR>]?
    func c(c: @escaping (_ a: String) -> ()) -> (_ a: String) -> ()
    func u(i: Int, u: URL, j: Int) -> URL
    func p(p: P2) -> P2
    func c2(c: TestClass) -> TestClass
    func any(a: Any) -> Any
}

open class TestClass: P {

    public var i = 999
    public var s = "8"
    public var tc: TestClass?

    open func x() {
        print( "open func x() \(i)" )
    }

    open func y() -> Float {
        print( "open func y()" )
        return -9.0
    }

    open func z( _ d: XInt, f: Double, s: String?, g: Float, h: Double, f1: Double?, g1: Float, h1: Double, f2: Double, g2: Float, h2: Double?, e: CGFloat? ) {
        print( "open func z( \(i) \(d) \(String(describing: e)) \(f) \(String(describing: s)) \(g) \(h) \(String(describing: f1)) \(g1) \(h1) \(f2) \(g2) \(String(describing: h2)) )" )
    }

    public func rect(r1: NSRect, r2: NSRect) -> NSRect {
        return r1
    }

    public func rect2(r1: NSRect, r2: NSRect) -> Stret {
        return Stret(r1: r1, r2: r2, r3: r2)
    }

    public func arr(a: [String?], b: [Int]) -> ArraySlice<String?> {
        return a[1...]
    }

    public func arr2(a: [String?], b: [Int]) -> Set<STR> {
        return Set(a.map {STR(s: $0!)})
    }

    public func str(i: Int, s: STR, j: Int) -> STR {
        return s
    }

    public func dict(d: [String: Set<STR>]?) -> [String: Set<STR>]? {
        return d
    }

    public func c(c: @escaping (_ a: String) -> ()) -> (_ a: String) -> () {
        return c
    }

    public func u(i: Int, u: URL, j: Int) -> URL {
        return u
    }

    public func p(p: P2) -> P2 {
        return p
    }

    public func c2(c: TestClass) -> TestClass {
        return c
    }

    public func any(a: Any) -> Any {
        return a
    }

    public func str3(s1: String, s2: String, s3: String) -> Str3 {
        return Str3(s1: s1, s2: s2, s3: s3)
    }
}

struct TestStruct: P {

    public var i = 999

    public func x() {
        print( "open func x() \(i)" )
    }

    public func y() -> Float {
        print( "open func y()" )
        return -9.0
    }

    public func z( _ d: XInt, f: Double, s: String?, g: Float, h: Double, f1: Double?, g1: Float, h1: Double, f2: Double, g2: Float, h2: CGFloat?, e: Int? ) {
        print( "open func z( \(i) \(d) \(String(describing: e)) \(f) \(String(describing: s)) \(g) \(h) \(String(describing: f1)) \(g1) \(h1) \(f2) \(g2) \(String(describing: h2)) )" )
    }

    public func rect(r1: NSRect, r2: NSRect) -> NSRect {
        return r1
    }

    public func rect2(r1: NSRect, r2: NSRect) -> Stret {
        return Stret(r1: r1, r2: r2, r3: r2)
    }

    public func arr(a: [String?], b: [Int]) -> ArraySlice<String?> {
        return a[1...]
    }

    public func arr2(a: [String?], b: [Int]) -> Set<STR> {
        return Set(a.map {STR(s: $0!)})
    }

    public func str(i: Int, s: STR, j: Int) -> STR {
        return s
    }

    public func dict(d: [String: Set<STR>]?) -> [String: Set<STR>]? {
        return d
    }

    public func c(c: @escaping (_ a: String) -> ()) -> (_ a: String) -> () {
        return c
    }

    public func u(i: Int, u: URL, j: Int) -> URL {
        return u
    }

    public func p(p: P2) -> P2 {
        return p
    }

    public func c2(c: TestClass) -> TestClass {
        return c
    }

    public func any(a: Any) -> Any {
        return a
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        #if true
        // Insert code here to initialize your application
//        print(objc_classArray().count)

        // any inclusions or exlusiona need to come before trace enabled
        //SwiftTrace.include( "Swift.Optiona|TestClass" )
        SwiftTrace.typeLookup = true
        SwiftTrace.decorateAny = true

        class MyTracer: SwiftTrace.Swizzle {

            override func onEntry(stack: inout SwiftTrace.EntryStack) {
                print( ">> "+signature )
            }
        }

//        Self.swiftTraceSetExclusionPattern(NSObject.swiftTraceDefaultMethodExclusions())
//        NSObject.swiftTraceSetInclusionPattern(".")
//        SwiftTrace.patchFactory = MyTracer.self


        let objcTester = ObjcTraceTester()

        objcTester.swiftTraceInstance(withSubLevels: 2)
        objcTester.a(44, i:45, b: 55, c: "66", o: self, s: Selector(("jjj:")))

        NSObject.swiftTraceClasses(matchingPattern: "Test", subLevels: 2)

        objcTester.a(44, i:45, b: 55, c: "66", o: self, s: Selector(("jjj:")))

//        SwiftTrace.excludeFunction = NSRegularExpression(regexp:
//                                                            "^\\w+\\.\\w+\\(|extension in S|SwiftTrace|out: inout|autoBitCast")
        SwiftTrace.traceMainBundleMethods()

        var a/*: P*/ = TestClass()
//        print(SwiftTrace.invoke(target: a as AnyObject, methodName: "SwiftTwaceOSX.TestClass.rect(r1: __C.CGRect, r2: __C.CGRect) -> __C.CGRect", args: NSRect(x: 1111.0, y: 2222.0, width: 3333.0, height: 4444.0), NSRect(x: 11111.0, y: 22222.0, width: 33333.0, height: 44444.0)) as NSRect)

        print(a.rect2(r1: NSRect(x: 1111.0, y: 2222.0, width: 3333.0, height: 4444.0), r2:NSRect(x: 11111.0, y: 22222.0, width: 33333.0, height: 44444.0)))

        print(SwiftTrace.methodNames(ofClass: TestClass.self))
        print(SwiftTrace.swiftClassList(bundlePath: class_getImageName(TestClass.self)))

        let d = Optional.some(["test": Set([STR(s: "value")])])
        let any: Any = d
        print(a.any(a: any))

        print(a.u(i: 99, u: URL(string: "http://google.com")!, j: 89))

        a.i = 888
        print(a.i)
        a.x()
        print( a.y() )
        a.x()
        a.z( 88, f: 66, s: "$%^", g: 55, h: 44, f1: 66, g1: 55, h1: 44, f2: 66, g2: 55, h2: 44, e: 77 )
        print(a.arr(a: ["a", "b", "c"], b: [1, 2, 3]))
        print(a.arr2(a: ["a", "b", "c"], b: [1, 2, 3]))
        print(a.str(i: 77, s: STR(s: "value"), j: 88))
        print(SwiftMeta.sizeof(anyType: type(of: d)))
        print(a.dict(d: d)!)
        print(a.c(c: { _ in }))
//        a.tc = a
//        print(a.c2(c: a))
        print(a.p(p: "s"))
        print(MemoryLayout<STR>.size)
        print(SwiftTrace.invoke(target: a, methodName: "SwiftTwaceOSX.TestClass.rect(r1: __C.CGRect, r2: __C.CGRect) -> __C.CGRect", args: NSRect(x: 1111.0, y: 2222.0, width: 3333.0, height: 4444.0), NSRect(x: 11111.0, y: 22222.0, width: 33333.0, height: 44444.0)) as NSRect)

        print(SwiftTrace.invoke(target: a, methodName: "SwiftTwaceOSX.TestClass.arr(a: Swift.Array<Swift.Optional<Swift.String>>, b: Swift.Array<Swift.Int>) -> Swift.ArraySlice<Swift.Optional<Swift.String>>", args: ["a", "b", "c"] as [String?], [1, 2, 3]) as ArraySlice<String?>)

        print("invokeStret", SwiftTrace.Call(target: a, methodName: "SwiftTwaceOSX.TestClass.rect2(r1: __C.CGRect, r2: __C.CGRect) -> SwiftTwaceOSX.Stret")!.invokeStret(args: NSRect(x: 1111.0, y: 2222.0, width: 3333.0, height: 4444.0), NSRect(x: 1111.0, y: 2222.0, width: 3333.0, height: 4444.0)) as Stret)

        print("invokeStr3", SwiftTrace.Call(target: a as AnyObject, methodName: "SwiftTwaceOSX.TestClass.str3(s1: Swift.String, s2: Swift.String, s3: Swift.String) -> SwiftTwaceOSX.Str3")!.invokeStret(args: "a", "b", "c") as Str3)

        print(SwiftTrace.invoke(target: a as AnyObject, methodName: "SwiftTwaceOSX.TestClass.dict(d: Swift.Optional<Swift.Dictionary<Swift.String, Swift.Set<SwiftTwaceOSX.STR>>>) -> Swift.Optional<Swift.Dictionary<Swift.String, Swift.Set<SwiftTwaceOSX.STR>>>", args: d) as [String: Set<STR>]? as Any)

        NSObject.swiftTraceRemoveAllTraces()

        print(SwiftTrace.invoke(target: a as AnyObject, methodName: "SwiftTwaceOSX.TestClass.rect(r1: __C.CGRect, r2: __C.CGRect) -> __C.CGRect", args: NSRect(x: 1111.0, y: 2222.0, width: 3333.0, height: 4444.0), NSRect(x: 11111.0, y: 22222.0, width: 33333.0, height: 44444.0)) as NSRect)

        SwiftTrace.swizzleFactory = SwiftTrace.Decorated.self
        #endif
//        SwiftTrace.trace(aClass: TestClass.self)

//        ptest(p: TestClass())

        #if !arch(arm64)
//        TestClass.swiftTraceProtocolsInBundle()
        #endif

        ptest(p: TestStruct())
        ptest(p: TestClass())

        for call in SwiftTrace.callOrder() {
            print(call.signature)
        }

        findSwiftSymbols(Bundle.main.executablePath, classesIncludingObjc()) {
            cls,_,_,_ in
            print(unsafeBitCast(cls, to: AnyClass.self))
        }
    }

    func ptest<T: P>(p: T) {
        p.z( 88, f: 66, s: "$%^", g: 55, h: 44, f1: 66, g1: 55, h1: 44, f2: 66, g2: 55, h2: 44 as? T.myType, e: 77 as? T.myType2)
        print(p.rect(r1: NSRect(x: 1111.0, y: 2222.0, width: 3333.0, height: 4444.0), r2: NSRect(x: 1111.0, y: 2222.0, width: 3333.0, height: 4444.0)))
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
