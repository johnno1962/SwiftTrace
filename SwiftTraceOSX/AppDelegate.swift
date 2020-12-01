//
//  AppDelegate.swift
//  SwiftTraceOSX
//
//  Created by John Holdsworth on 13/06/2016.
//  Copyright © 2016 John Holdsworth. All rights reserved.
//

import Cocoa

public typealias XInt = UInt16

public struct Stret {
    let r1: CGRect, r2: CGRect, r3: CGRect
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
    func arr(a: [String], b: [Int]) -> [String]
    func c(c: @escaping (_ a: String) -> ()) -> (_ a: String) -> ()
}

open class TestClass: NSObject, P {

    public var i = 999

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

    public func arr(a: [String], b: [Int]) -> [String] {
        return a
    }

    public func c(c: @escaping (_ a: String) -> ()) -> (_ a: String) -> () {
        return c
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

    public func arr(a: [String], b: [Int]) -> [String] {
        return a
    }

    public func c(c: @escaping (_ a: String) -> ()) -> (_ a: String) -> () {
        return c
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


        var a/*: P*/ = TestClass()
        print(SwiftTrace.invoke(target: a as AnyObject, methodName: "SwiftTwaceOSX.TestClass.rect(r1: __C.CGRect, r2: __C.CGRect) -> __C.CGRect", args: NSRect(x: 1111.0, y: 2222.0, width: 3333.0, height: 4444.0), NSRect(x: 11111.0, y: 22222.0, width: 33333.0, height: 44444.0)) as NSRect)

        print(a.rect2(r1: NSRect(x: 1111.0, y: 2222.0, width: 3333.0, height: 4444.0), r2:NSRect(x: 11111.0, y: 22222.0, width: 33333.0, height: 44444.0)))

        print(SwiftTrace.methodNames(ofClass: TestClass.self))
        print(SwiftTrace.swiftClassList(bundlePath: class_getImageName(TestClass.self)))

        a.i = 888
        print(a.i)
        a.x()
        print( a.y() )
        a.x()
        a.z( 88, f: 66, s: "$%^", g: 55, h: 44, f1: 66, g1: 55, h1: 44, f2: 66, g2: 55, h2: 44, e: 77 )
        print(a.arr(a: ["a", "b", "c"], b: [1, 2, 3]))
        print(a.c(c: { _ in }))
        print(SwiftTrace.invoke(target: a as AnyObject, methodName: "SwiftTwaceOSX.TestClass.rect(r1: __C.CGRect, r2: __C.CGRect) -> __C.CGRect", args: NSRect(x: 1111.0, y: 2222.0, width: 3333.0, height: 4444.0), NSRect(x: 11111.0, y: 22222.0, width: 33333.0, height: 44444.0)) as NSRect)

        NSObject.swiftTraceRemoveAllTraces()

        print(SwiftTrace.invoke(target: a as AnyObject, methodName: "SwiftTwaceOSX.TestClass.rect(r1: __C.CGRect, r2: __C.CGRect) -> __C.CGRect", args: NSRect(x: 1111.0, y: 2222.0, width: 3333.0, height: 4444.0), NSRect(x: 11111.0, y: 22222.0, width: 33333.0, height: 44444.0)) as NSRect)

        SwiftTrace.swizzleFactory = SwiftTrace.Decorated.self
        #endif
//        SwiftTrace.trace(aClass: TestClass.self)

//        ptest(p: TestClass())

        TestClass.swiftTraceProtocolsInBundle()

        ptest(p: TestStruct())
        ptest(p: TestClass())

        for call in SwiftTrace.callOrder() {
            print(call.signature)
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

