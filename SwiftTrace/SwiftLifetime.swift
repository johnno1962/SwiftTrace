//
//  SwiftLifetime.swift
//  SwiftTrace
//
//  Created by John Holdsworth on 23/09/2020.
//  Copyright © 2020 John Holdsworth. All rights reserved.
//
//  $Id: //depot/SwiftTrace/SwiftTrace/SwiftLifetime.swift#5 $
//
//  Trace instance life cycle for tracking reference cycles.
//  ========================================================
//
//  Needs "Other Linker Flags" -Xlinker -interposable and for you
//  to call both traceMainBundleMethods() and traceMainBundle().
//  Classes being tracked must inherit from NSObject.
//

import Foundation

extension SwiftTrace {

    public static var liveObjects = [UnsafeRawPointer: Set<UnsafeRawPointer>]()
    public static var liveObjectsLock = OS_SPINLOCK_INIT

    open class LifetimeTracker: Decorated {

        let isAllocator: Bool
        let isDeallocator: Bool

        public required init?(name signature: String,
                              vtableSlot: UnsafeMutablePointer<SIMP>? = nil,
                              objcMethod: Method? = nil, objcClass: AnyClass? = nil,
                              original: OpaquePointer? = nil,
                              replaceWith: nullImplementationType? = nil) {
            isAllocator = signature.contains(" init") ||
                signature.contains(".__allocating_init(")
            isDeallocator = signature.contains(" .cxx_destruct") ||
                signature.contains(".__deallocating_deinit")
            super.init(name: signature, vtableSlot: vtableSlot,
                       objcMethod: objcMethod, objcClass: objcClass,
                       original: original, replaceWith: replaceWith)
        }

        open func register(typeOf instance: AnyObject) -> UnsafeRawPointer {
            let metaType: UnsafeRawPointer = autoBitCast(type(of: instance))
            if let _ = liveObjects[metaType] {
            } else {
                liveObjects[metaType] = Set()
            }
            return metaType
        }

        /**
         Inrement live instance count ofr initialisers
         */
        open override func exitDecorate(stack: inout ExitStack) -> String? {
            var info = "", live = "live"
            if isAllocator || isDeallocator {
                if isAllocator {
                    let instance = returnAsAny as AnyObject
                    OSSpinLockLock(&liveObjectsLock)
                    let metaType = register(typeOf: instance)
                    liveObjects[metaType]!
                        .insert(autoBitCast(instance))
                    invocation().numberLive = liveObjects[metaType]!.count
                    OSSpinLockUnlock(&liveObjectsLock)
                    if !instance.isKind(of: NSObject.self) {
                        live = "allocated"
                    }
                }
                info = " [\(invocation().numberLive) \(live)]"
            }
            return super.exitDecorate(stack: &stack)! + info
        }

        /**
         Decrement live instance count on dealloc
         */
        open override func entryDecorate(stack: inout EntryStack) -> String? {
            if isDeallocator {
                let instance = getSelf() as AnyObject
                OSSpinLockLock(&liveObjectsLock)
                let metaType = register(typeOf: instance)
                liveObjects[metaType]!
                    .remove(autoBitCast(instance))
                invocation().numberLive = liveObjects[metaType]!.count
                OSSpinLockUnlock(&liveObjectsLock)
            }
            return super.entryDecorate(stack: &stack)
        }
    }
}
