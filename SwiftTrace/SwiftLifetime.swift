//
//  SwiftLifetime.swift
//  SwiftTrace
//
//  Created by John Holdsworth on 23/09/2020.
//  Copyright © 2020 John Holdsworth. All rights reserved.
//
//  $Id: //depot/SwiftTrace/SwiftTrace/SwiftLifetime.swift#21 $
//
//  Trace instance life cycle for tracking down reference cycles.
//  =============================================================
//
//  Needs "Other Linker Flags" -Xlinker -interposable and to have
//  called both traceMainBundleMethods() and traceMainBundle().
//
//  "allocating_init" initialiazers of Swift classes are intercepted
//  and init* methods of Objective-C classe are swizzled to record new
//  objects in a "live" Set on a per-class basis. Swift classes with
//  non-trivial initialisers that inherit from NSObject have an Objective-C
//  method ".cxx_destruct" which is swizzled to remove the instances of the
//  live Set as they are dealloctaed. For classes that don't inherit from
//  NSObject an associated reference is added to a "Reaper" instance that
//  removes the instance from the live Set using a method _cxx_destruct
//  added to the tracked class.
//

import Foundation

extension SwiftTrace {

    public static var liveObjects = [UnsafeRawPointer: Set<UnsafeRawPointer>]()
    public static var liveObjectsLock = OS_SPINLOCK_INIT
    private static var reaperKey = strdup("_reaper_")!

    open class LifetimeTracker: Decorated {

        /// Tracker to detect deallocations for
        /// classes not inheriting from NSObject
        open class Reaper: NSObject {
            let owner: UnsafeRawPointer
            init(owner: UnsafeRawPointer) {
                self.owner = owner
            }
            @objc func _cxx_destruct() {
            }
            deinit {
                (autoBitCast(owner) as AnyObject)._cxx_destruct?()
            }
        }

        public let isAllocator: Bool
        public let isDeallocator: Bool
        override var isLifetime: Bool { return isAllocator || isDeallocator }

        public required init?(name signature: String,
                              vtableSlot: UnsafeMutablePointer<SIMP>? = nil,
                              objcMethod: Method? = nil, objcClass: AnyClass? = nil,
                              original: OpaquePointer? = nil,
                              replaceWith: nullImplementationType? = nil) {
            isAllocator = signature.contains(".__allocating_init(") ||
                !class_isMetaClass(objcClass) && signature.contains(" init")
            isDeallocator = signature.contains("cxx_destruct") ||
                signature.contains(".__deallocating_deinit") // not used
            super.init(name: signature, vtableSlot: vtableSlot,
                       objcMethod: objcMethod, objcClass: objcClass,
                       original: original, replaceWith: replaceWith)
        }

        /**
         Update instances for each class
         */
        open func update(instance: AnyObject) -> UnsafeRawPointer {
            let metaType: UnsafeRawPointer = autoBitCast(type(of: instance))
            OSSpinLockLock(&liveObjectsLock)
            if liveObjects.index(forKey: metaType) == nil {
                liveObjects[metaType] = Set()
                trackGenerics(metaType, register: metaType)
            }
            if isAllocator {
                liveObjects[metaType]!
                    .insert(autoBitCast(instance))
            } else {
                liveObjects[metaType]!
                    .remove(autoBitCast(instance))
            }
            invocation().numberLive = liveObjects[metaType]!.count
            OSSpinLockUnlock(&liveObjectsLock)
            return metaType
        }

        /// Make sure deallocations of generic classes are tracked.
        /// - Parameter metaType: pointer to type info
        /// - Parameter register: generic to actually register
        open func trackGenerics(_ metaType: UnsafeRawPointer,
                                register: UnsafeRawPointer) {
            if !tracksDeallocs.contains(register),
                let generic = autoBitCast(metaType) as Any.Type as? AnyClass {
                var methodCount: UInt32 = 0
                if let methods = class_copyMethodList(generic, &methodCount) {
                    for method in (0..<Int(methodCount)).map({ methods[$0] }) {
                        let sel = method_getName(method)
                        let selName = NSStringFromSelector(sel)
                        if selName == ".cxx_destruct",
                           let type = method_getTypeEncoding(method),
                           let swizzle = swizzleFactory.init(name:
                                "-[\(generic) \(selName)] -> \(String(cString: type))",
                                objcMethod: method, objcClass: generic) {
                            class_replaceMethod(generic, sel,
                                    autoBitCast(swizzle.forwardingImplementation), type)
                            tracksDeallocs.insert(register)
                        }
                    }
                    free(methods)
                }
                if !tracksDeallocs.contains(register) {
                    if let superClass = class_getSuperclass(generic) {
                        trackGenerics(autoBitCast(superClass), register: register)
                    } else {
                        // fallback where class doesn't inherit from NSObject
                        if let tracker = class_getInstanceMethod(Reaper.self,
                                            #selector(Reaper._cxx_destruct)),
                           let type = method_getTypeEncoding(tracker),
                           let originalClass = autoBitCast(register) as Any.Type as? AnyClass,
                           let swizzle = LifetimeTracker(name:
                                 "-[\(generic) _cxx_destruct] -> \(String(cString: type))",
                                 objcMethod: tracker, objcClass: originalClass) {
                            class_replaceMethod(originalClass,
                                                #selector(Reaper._cxx_destruct),
                                  autoBitCast(swizzle.forwardingImplementation),
                                  type)
                        }
                    }
                }
            }
        }

        /**
         Increment live instances for initialisers
         */
        open override func exitDecorate(stack: inout ExitStack) -> String? {
            var info = "", live = "live"
            if isAllocator || isDeallocator {
                if isAllocator {
                    let instance = returnAsAny as AnyObject
                    let metaType = update(instance: instance)
                    if !tracksDeallocs.contains(metaType) {
                        objc_setAssociatedObject(instance, reaperKey,
                                 Reaper(owner: autoBitCast(instance)),
                                 .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                        live = "allocated"
                    }
                }
                info = " [\(invocation().numberLive) \(live)]"
            }
            return super.exitDecorate(stack: &stack)! + info
        }

        /**
         Decrement live instances on deallocations
         */
        open override func entryDecorate(stack: inout EntryStack) -> String? {
            if isDeallocator {
                _ = update(instance: getSelf())
            }
            return super.entryDecorate(stack: &stack)
        }
    }
}
