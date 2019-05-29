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
    let i = 111, j = 222, k = 333

}

public func ==(lhs: TestStruct, rhs: TestStruct) -> Bool {

    return lhs.a == lhs.a && lhs.b == lhs.b && lhs.c == lhs.c && lhs.i == lhs.i && lhs.j == lhs.j && lhs.k == lhs.k
}

public class RET {
    deinit {
        print("!RET")
    }
}

public class RET2: RET {
}

public protocol P {
    func x()
    func y() -> Float
    @discardableResult
    func zzz( _ d: Int, f: Double, g: Float, h: String, f1: Double, g1: Float, h1: Double, f2: Double, g2: Float, h2: Double, e: Int, ff: Int, o: TestClass ) throws -> String
    func ssssss( a: TestStruct ) -> TestStruct
    func str() -> NSString
}

public class TestClass: P {

    let i = 999

    public func x() {
        print( "HERE \(i)" )
    }

    public func y() -> Float {
       print( "HERE2" )
        return -9.0
    }

    @discardableResult
    public func zzz( _ d: Int, f: Double, g: Float, h: String, f1: Double, g1: Float, h1: Double, f2: Double, g2: Float, h2: Double, e: Int, ff: Int, o: TestClass ) throws -> String {
        print( "HERE \(i) \(d) \(e) \(f) \(g) \(h) \(f1) \(g1) \(h1) \(f2) \(g2) \(h2)" )
        //throw NSError(domain: "HOLLOO", code: 123, userInfo: ["john": "error"])
        return "4-4-4"
    }

    public func ssssss( a: TestStruct ) -> TestStruct {
        return a
    }

    static var c = 0

    public func str() -> NSString {
        return "NO" as NSString
    }

}

class MyTracer: SwiftTrace.Patch {

    override func onEntry(stack: UnsafeMutablePointer<SwiftTrace.EntryStack>) {
        print(stack.pointee)
        if name == "SwiftTwaceApp.TestClass.zzz(_: Swift.Int, f: Swift.Double, g: Swift.Float, h: Swift.String, f1: Swift.Double, g1: Swift.Float, h1: Swift.Double, f2: Swift.Double, g2: Swift.Float, h2: Swift.Double, e: Swift.Int, ff: Swift.Int, o: SwiftTwaceApp.TestClass) throws -> Swift.String" {
            print("\(stack.pointee.intArg1) \(cast(&stack.pointee.intArg2, as: String.self).pointee) \(stack.pointee.floatArg1) \(cast(&stack.pointee.floatArg5, as: Float.self).pointee) \((getSelf() as TestClass).i)")
        }
    }

    override func onExit(stack: UnsafeMutablePointer<SwiftTrace.ExitStack>) {
        print(stack.pointee)
        print("\(getSelf() as AnyObject)")
        if name == "SwiftTwaceApp.TestClass.ssssss(a: SwiftTwaceApp.TestStruct) -> SwiftTwaceApp.TestStruct" {
            print(structReturn().pointee as TestStruct)
        }
        if name == "SwiftTwaceApp.TestClass.zzz(_: Swift.Int, f: Swift.Double, g: Swift.Float, h: Swift.String, f1: Swift.Double, g1: Swift.Float, h1: Swift.Double, f2: Swift.Double, g2: Swift.Float, h2: Swift.Double, e: Swift.Int, ff: Swift.Int, o: SwiftTwaceApp.TestClass) throws -> Swift.String" {
            if stack.pointee.thrownError != 0 {
                print(cast(&stack.pointee.thrownError, as: NSError.self).pointee)
            }
            stack.pointee.thrownError = 0
//            stack.invocation.patch.argument(&intReturn1, as: String.self) = "5-5-5"
            stack.pointee.setReturn(value: "5-5-5")
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

        print(SwiftTrace.addAspect(methodName: "SwiftTwaceApp.TestClass.x() -> ()", ofClass: TestClass.self,
           onEntry: { (patch: SwiftTrace.Patch, stack: UnsafeMutablePointer<SwiftTrace.EntryStack>) in
//            patch.argument(&stack.pointee.intArg2, as: String.self).pointee = "Grief"
            print("ONE") },
           onExit: { (patch: SwiftTrace.Patch, stack: UnsafeMutablePointer<SwiftTrace.ExitStack>) in
//            stack.pointee.setReturn(value: "Phew")
            print("TWO") }))
        print(SwiftTrace.addAspect(methodName: "SwiftTwaceApp.TestClass.y() -> Swift.Float", onExit: { (_, _) in print("TWO!") }))
        print(SwiftTrace.addAspect(methodName: "SwiftTwaceApp.TestClass.str() -> __C.NSString", justReturn: { _ in
            TestClass.c += 1
            return "YES #\(TestClass.c)" as NSString
        }))

        let a: P = TestClass()
        a.x()

        print( a.y() )
        print(SwiftTrace.removeAspect(fromClass: TestClass.self, methodName: "SwiftTwaceApp.TestClass.y() -> Swift.Float"))
        print( a.y() )

        a.x()
        print(try! a.zzz( 123, f: 66, g: 55, h: "4-4", f1: 66, g1: 55, h1: 44, f2: 66, g2: 55, h2: 44, e: 77, ff: 11, o: TestClass()))
        print(a.ssssss( a: TestStruct() ))

        print(">>>> AH \(a.str())")
        print(">>>> AH \(a.str())")
        print(">>>> AH \(a.str())")


        let b = TestClass()

//        let call = SwiftTrace.Call(self: b, methodName: "SwiftTwaceApp.TestClass.zzz(_: Swift.Int, f: Swift.Double, g: Swift.Float, h: Swift.String, f1: Swift.Double, g1: Swift.Float, h1: Swift.Double, f2: Swift.Double, g2: Swift.Float, h2: Swift.Double, e: Swift.Int, ff: Swift.Int, o: SwiftTwaceApp.TestClass) throws -> Swift.String")!
//
//        call.add(arg: 777)
//        call.add(arg: 101.0)
//        call.add(arg: Float(102.0))
//        call.add(arg: "2-2")
//        call.add(arg: 103.0)
//        call.add(arg: Float(104.0))
//        call.add(arg: 105.0)
//        call.add(arg: 106.0)
//        call.add(arg: Float(107.0))
//        call.add(arg: 108.0)
//        call.add(arg: 888)
//        call.add(arg: 999)
//        call.add(arg: b)
//
//        call.invoke()
//
//        print("!!!!!! "+call.getReturn())

        print("!!!!!!!!!!!! "+SwiftTrace.invoke(self: b, methodName: "SwiftTwaceApp.TestClass.zzz(_: Swift.Int, f: Swift.Double, g: Swift.Float, h: Swift.String, f1: Swift.Double, g1: Swift.Float, h1: Swift.Double, f2: Swift.Double, g2: Swift.Float, h2: Swift.Double, e: Swift.Int, ff: Swift.Int, o: SwiftTwaceApp.TestClass) throws -> Swift.String", args: 777, 101.0, Float(102.0), "2-2", 103.0, Float(104.0), 105.0, 106.0, Float(107.0), 108.0, 888, 999, b))

//        SwiftTrace.removeAllPatches()
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

