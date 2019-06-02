//
//  AppDelegate.swift
//  SwiftTraceApp
//
//  Created by John Holdsworth on 10/06/2016.
//  Copyright © 2016 John Holdsworth. All rights reserved.
//

import UIKit
import SwiftTrace

public struct TestStruct: Equatable {

    let a = 1.0, b = 2.0, c = 3.0
    var i = 111, j = 222, k = "333"
}

public func ==(lhs: TestStruct, rhs: TestStruct) -> Bool {

    return lhs.a == lhs.a && lhs.b == lhs.b && lhs.c == lhs.c && lhs.i == lhs.i && lhs.j == lhs.j && lhs.k == lhs.k
}

public struct Strings: SwiftTraceArg {
    var s1 = "ONE", s2 = "TWO"//, s3 = "THREE"
}

public protocol P {
    func x()
    func y() -> CGRect
    @discardableResult
    func zzz( _ d: Int, f: Double, g: Float, h: String, f1: Double, g1: Float, h1: Double, f2: Double, g2: Float, h2: Double, e: Int, ff: Int, o: TestClass ) throws -> String
    func ssssss( a: TestStruct ) -> TestStruct
    func str() -> NSString
    func rect(r: CGRect) -> CGRect
}

public class TestClass: P, SwiftTraceArg {

    let i = 999

    public func x() {
        print( "TestClass.x() self.i: \(i)" )
    }

    public func y() -> CGRect {
        print( "TestClass.y()" )
        return CGRect(x: 1.0, y: 2.0, width: 3.0, height: 4.0)
    }

    @discardableResult
    public func zzz( _ d: Int, f: Double, g: Float, h: String, f1: Double, g1: Float, h1: Double, f2: Double, g2: Float, h2: Double, e: Int, ff: Int, o: TestClass ) throws -> String {
        print( "TestClass.zzz(_ d: \(d), f: \(f), g: \(g), h: \(h), f1: \(f1), g1: \(g1), h1: \(h1), f2: \(f2), g2: \(g2), h2: \(h2), e: \(e), ff: \(ff), self.i: \(i), o.i: \(o.i))")
        throw NSError(domain: "HOLLOO", code: 123, userInfo: ["john": "error"])
        //return "4-4-4"
    }

    public func ssssss( a: TestStruct ) -> TestStruct {
        return a
    }

    static var c = 0

    public func str() -> NSString {
        return "NO" as NSString
    }

    public func str2(strs: inout Strings) -> Strings {
        return strs
    }

    public func str3(strs: Strings) -> Strings {
        return strs
    }

    public func rect(r: CGRect) -> CGRect {
        return r
    }
}

class MyTracer: SwiftTrace.Patch {

    override func onEntry(stack: inout SwiftTrace.EntryStack) {
        //print(stack)
        if name == "SwiftTwaceApp.TestClass.zzz(_: Swift.Int, f: Swift.Double, g: Swift.Float, h: Swift.String, f1: Swift.Double, g1: Swift.Float, h1: Swift.Double, f2: Swift.Double, g2: Swift.Float, h2: Swift.Double, e: Swift.Int, ff: Swift.Int, o: SwiftTwaceApp.TestClass) throws -> Swift.String" {
            print("\(stack.intArg1) \(rebind(&stack.intArg2, to: String.self).pointee) \(stack.floatArg1) \(rebind(&stack.floatArg5, to: Float.self).pointee) \(rebind(&stack.intArg6, to: TestClass.self).pointee.i) \((getSelf() as TestClass).i)")
        }
    }

    override func onExit(stack: inout SwiftTrace.ExitStack) {
        //print(stack)
        print("\(getSelf() as AnyObject)")
        if name == "SwiftTwaceApp.TestClass.ssssss(a: SwiftTwaceApp.TestStruct) -> SwiftTwaceApp.TestStruct" {
            print(structReturn().pointee as TestStruct)
        }
        if name == "SwiftTwaceApp.TestClass.zzz(_: Swift.Int, f: Swift.Double, g: Swift.Float, h: Swift.String, f1: Swift.Double, g1: Swift.Float, h1: Swift.Double, f2: Swift.Double, g2: Swift.Float, h2: Swift.Double, e: Swift.Int, ff: Swift.Int, o: SwiftTwaceApp.TestClass) throws -> Swift.String" {
            if stack.thrownError != 0 {
                print(rebind(&stack.thrownError, to: NSError.self).pointee)
            }
            stack.thrownError = 0
//            stack.invocation.patch.argument(&intReturn1, as: String.self) = "5-5-5"
            stack.setReturn(value: "5-5-5")
        }
        if name == "SwiftTwaceApp.TestClass.y() -> __C.CGRect" {
            rebind(&stack.floatReturn1).pointee = CGRect(x: 11.0, y: 22.0, width: 33.0, height: 44.0)
        }
        if name == "SwiftTwaceApp.TestClass.str2(strs: inout SwiftTwaceApp.Strings) -> SwiftTwaceApp.Strings" {
            rebind(&stack.intReturn1, to: Strings.self).pointee.s2 += "!"
        }
    }

    func jjjjj(a: TestClass) {
        do {
            try a.zzz( 88, f: 66, g: 55, h: "44", f1: 66, g1: 55, h1: 44, f2: 66, g2: 55, h2: 44, e: 77, ff: 11, o: TestClass() )
        }
        catch {
            print(error)
        }
    }
}

class Benchmark  {
    func x() {
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool {
        // Override point for customization after application launch.
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
        navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        splitViewController.delegate = self

        // any inclusions or exlusions need to come before trace enabled
        SwiftTrace.patchFactory = MyTracer.self

        type(of: self).traceBundle()
        SwiftTrace.trace(aClass: type(of: self))

        print(SwiftTrace.swiftClassList(bundlePath: Bundle.main.executablePath!))
        print(SwiftTrace.methodNames(ofClass: TestClass.self))

        print(SwiftTrace.addAspect(aClass: TestClass.self, methodName: "SwiftTwaceApp.TestClass.x() -> ()",
           onEntry: { (patch: SwiftTrace.Patch, stack: inout SwiftTrace.EntryStack) in
//            patch.rebind(&stack.intArg2).pointee = "Grief"
            print("SwiftTwaceApp.TestClass.x() enter") },
           onExit: { (patch: SwiftTrace.Patch, stack: inout SwiftTrace.ExitStack) in
//            stack.setReturn(value: "Phew")
            print("SwiftTwaceApp.TestClass.x() exit") }))
        print(SwiftTrace.addAspect(methodName: "SwiftTwaceApp.TestClass.y() -> __C.CGRect", onExit: { (_, _) in print("SwiftTwaceApp.TestClass.y() exit!") }))
        print(SwiftTrace.addAspect(methodName: "SwiftTwaceApp.TestClass.str() -> __C.NSString", replaceWith: {
            TestClass.c += 1
            return "YES #\(TestClass.c)" as NSString
        }))
        print(SwiftTrace.addAspect(methodName: "SwiftTwaceApp.TestClass.ssssss(a: SwiftTwaceApp.TestStruct) -> SwiftTwaceApp.TestStruct", onExit: { (patch, stack) in
            patch.structReturn(as: TestStruct.self).pointee.k = "8-8-8"
        }))

        let a: P = TestClass()
        a.x()

        print( a.y() )
        print(SwiftTrace.removeAspect(aClass: TestClass.self, methodName: "SwiftTwaceApp.TestClass.y() -> __C.CGRect"))
        print( a.y() )

        a.x()
        print(try! a.zzz( 123, f: 66, g: 55, h: "4-4", f1: 66, g1: 55, h1: 44, f2: 66, g2: 55, h2: 44, e: 77, ff: 11, o: TestClass()))
        print(a.ssssss( a: TestStruct()))

        print(a.rect(r: CGRect(x: 111.0, y: 222.0, width: 333.0, height: 444.0)))

        print(">>>> AH \(a.str())")
        print(">>>> AH \(a.str())")
        print(">>>> AH \(a.str())")

        let b = TestClass()

        let call = SwiftTrace.Call(target: b, methodName: "SwiftTwaceApp.TestClass.zzz(_: Swift.Int, f: Swift.Double, g: Swift.Float, h: Swift.String, f1: Swift.Double, g1: Swift.Float, h1: Swift.Double, f2: Swift.Double, g2: Swift.Float, h2: Swift.Double, e: Swift.Int, ff: Swift.Int, o: SwiftTwaceApp.TestClass) throws -> Swift.String")!

        for _ in 0..<10 {
            call.add(arg: 777)
            call.add(arg: 101.0)
            call.add(arg: Float(102.0))
            call.add(arg: "2-2")
            call.add(arg: 103.0)
            call.add(arg: Float(104.0))
            call.add(arg: 105.0)
            call.add(arg: 106.0)
            call.add(arg: Float(107.0))
            call.add(arg: 108.0)
            call.add(arg: 888)
            call.add(arg: 999)
            call.add(arg: b)

            call.invoke()

            print("!!!!!! "+call.getReturn())
        }

        print("!!!!!!!!!!!! "+SwiftTrace.invoke(target: b, methodName: "SwiftTwaceApp.TestClass.zzz(_: Swift.Int, f: Swift.Double, g: Swift.Float, h: Swift.String, f1: Swift.Double, g1: Swift.Float, h1: Swift.Double, f2: Swift.Double, g2: Swift.Float, h2: Swift.Double, e: Swift.Int, ff: Swift.Int, o: SwiftTwaceApp.TestClass) throws -> Swift.String", args: 777, 101.0, Float(102.0), "2-2", 103.0, Float(104.0), 105.0, 106.0, Float(107.0), 108.0, 888, 999, b))
        print("!!!!!!!!!!!! "+SwiftTrace.invoke(target: b, methodName: "SwiftTwaceApp.TestClass.zzz(_: Swift.Int, f: Swift.Double, g: Swift.Float, h: Swift.String, f1: Swift.Double, g1: Swift.Float, h1: Swift.Double, f2: Swift.Double, g2: Swift.Float, h2: Swift.Double, e: Swift.Int, ff: Swift.Int, o: SwiftTwaceApp.TestClass) throws -> Swift.String", args: 777, 101.0, Float(102.0), "2-2", 103.0, Float(104.0), 105.0, 106.0, Float(107.0), 108.0, 888, 999, b))

        print(SwiftTrace.invoke(target: b, methodName: "SwiftTwaceApp.TestClass.rect(r: __C.CGRect) -> __C.CGRect", args: CGRect(x: 1111.0, y: 2222.0, width: 3333.0, height: 4444.0)) as CGRect)

        var strings = Strings()
        print(SwiftTrace.invoke(target: b, methodName: "SwiftTwaceApp.TestClass.str2(strs: inout SwiftTwaceApp.Strings) -> SwiftTwaceApp.Strings", args: call.rebind(&strings, to: Strings.self)) as Strings)
        print(SwiftTrace.invoke(target: b, methodName: "SwiftTwaceApp.TestClass.str3(strs: SwiftTwaceApp.Strings) -> SwiftTwaceApp.Strings", args: strings) as Strings)
        print(SwiftTrace.invoke(target: b, methodName: "SwiftTwaceApp.TestClass.x() -> ()", args: strings) as Void)

        SwiftTrace.removeAllPatches()

        let x = Benchmark()

        print(SwiftTrace.methodNames(ofClass: Benchmark.self))

        let start1 = Date.timeIntervalSinceReferenceDate
        for _ in 0..<10_000 {
            x.x(); x.x(); x.x(); x.x(); x.x()
            x.x(); x.x(); x.x(); x.x(); x.x()
        }
        print(Date.timeIntervalSinceReferenceDate - start1)

        print(SwiftTrace.addAspect(aClass: Benchmark.self, methodName: "SwiftTwaceApp.Benchmark.x() -> ()", onEntry: { (_, _) in}))

        let start2 = Date.timeIntervalSinceReferenceDate
        for _ in 0..<10_000 {
            x.x(); x.x(); x.x(); x.x(); x.x()
            x.x(); x.x(); x.x(); x.x(); x.x()
        }
        print(Date.timeIntervalSinceReferenceDate - start2)

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: - Split view

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? DetailViewController else { return false }
        if topAsDetailController.detailItem == nil {
            // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
            return true
        }
        return false
    }

}
