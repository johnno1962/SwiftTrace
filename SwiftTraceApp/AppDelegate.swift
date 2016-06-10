//
//  AppDelegate.swift
//  SwiftTraceApp
//
//  Created by John Holdsworth on 10/06/2016.
//  Copyright © 2016 John Holdsworth. All rights reserved.
//

import UIKit
import SwiftTrace

public class TestClass {

    let i = 999

    public func x() {
        print( "HERE \(i)" )
    }

    public func y() -> Float {
        print( "HERE2" )
        return -9.0
    }

    public func z( d: Int, f: Double, g: Float, h: Double, f1: Double, g1: Float, h1: Double, f2: Double, g2: Float, h2: Double, e: Int ) {
        print( "HERE \(i) \(d) \(e) \(f) \(g) \(h) \(f1) \(g1) \(h1) \(f2) \(g2) \(h2)" )
    }
    
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
        navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem()
        splitViewController.delegate = self

        // any inclusions or exlusiona need to come before trace enabled
        //SwiftTrace.include( "Swift.Optiona|TestClass" )

        class MyTracer: SwiftTraceInfo {

            override func trace() -> IMP {
                print( ">> "+symbol )
                return original
            }
            
        }

        SwiftTrace.tracerClass = MyTracer.self

        self.dynamicType.traceBundle()

        let a = TestClass()
        a.x()
        print( a.y() )
        a.x()
        a.z( 88, f: 66, g: 55, h: 44, f1: 66, g1: 55, h1: 44, f2: 66, g2: 55, h2: 44, e: 77 )

        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: - Split view

    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController:UIViewController, ontoPrimaryViewController primaryViewController:UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? DetailViewController else { return false }
        if topAsDetailController.detailItem == nil {
            // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
            return true
        }
        return false
    }

}

