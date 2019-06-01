//
//  AppDelegate.swift
//  SwiftTraceOSX
//
//  Created by John Holdsworth on 13/06/2016.
//  Copyright © 2016 John Holdsworth. All rights reserved.
//

import Cocoa

public protocol P {

    func x()
    func y() -> Float
    func z( _ d: Int, f: Double, g: Float, h: Double, f1: Double, g1: Float, h1: Double, f2: Double, g2: Float, h2: Double, e: Int )
    func rect(r1: NSRect, r2: NSRect) -> NSRect
}

open class TestClass: P {

    let i = 999

    open func x() {
        print( "HERE \(i)" )
    }

    open func y() -> Float {
        print( "HERE2" )
        return -9.0
    }

    open func z( _ d: Int, f: Double, g: Float, h: Double, f1: Double, g1: Float, h1: Double, f2: Double, g2: Float, h2: Double, e: Int ) {
        print( "HERE \(i) \(d) \(e) \(f) \(g) \(h) \(f1) \(g1) \(h1) \(f2) \(g2) \(h2)" )
    }

    public func rect(r1: NSRect, r2: NSRect) -> NSRect {
        return r2
    }
}


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application

        // any inclusions or exlusiona need to come before trace enabled
        //SwiftTrace.include( "Swift.Optiona|TestClass" )

        class MyTracer: SwiftTrace.Patch {

            override func onEntry(stack: inout SwiftTrace.EntryStack) {
                print( ">> "+name )
            }
        }

        SwiftTrace.patchFactory = MyTracer.self

        type(of: self).traceBundle()

        print(SwiftTrace.methodNames(ofClass: TestClass.self))

        let a: P = TestClass()
        a.x()
        print( a.y() )
        a.x()
        a.z( 88, f: 66, g: 55, h: 44, f1: 66, g1: 55, h1: 44, f2: 66, g2: 55, h2: 44, e: 77 )
        print(SwiftTrace.invoke(target: a as AnyObject, methodName: "SwiftTwaceOSX.TestClass.rect(r1: __C.CGRect, r2: __C.CGRect) -> __C.CGRect", args: NSRect(x: 1111.0, y: 2222.0, width: 3333.0, height: 4444.0), NSRect(x: 11111.0, y: 22222.0, width: 33333.0, height: 44444.0)) as NSRect)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

