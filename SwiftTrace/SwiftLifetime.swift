//
//  SwiftLifetime.swift
//  SwiftTrace
//
//  Created by John Holdsworth on 23/09/2020.
//  Copyright © 2020 John Holdsworth. All rights reserved.
//
//  $Id: //depot/SwiftTrace/SwiftTrace/SwiftLifetime.swift#12 $
//
//  Trace instance life cycle for tracking reference cycles.
//  ========================================================
//
//  Needs "Other Linker Flags" -Xlinker -interposable and for you
//  to call both traceMainBundleMethods() and traceMainBundle().
//  Classes being tracked must inherit from NSObject and have
//  have a non-trival deinitialiser to have .cxx_destroy method.
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
            isAllocator = signature.contains(".__allocating_init(") ||
                !class_isMetaClass(objcClass) && signature.contains(" init")

            isDeallocator = signature.contains(" .cxx_destruct") ||
                signature.contains(".__deallocating_deinit")
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

        /**
         Increment live instances for initialisers
         */
        open override func exitDecorate(stack: inout ExitStack) -> String? {
            var info = "", live = "live"
            if isAllocator || isDeallocator {
                if isAllocator &&
                    !tracksDeallocs.contains(
                        update(instance:returnAsAny as AnyObject)) {
                    live = "allocated"
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
