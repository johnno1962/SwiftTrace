//
//  SwiftLifetime.swift
//  SwiftTrace
//
//  Created by John Holdsworth on 23/09/2020.
//  Copyright © 2020 John Holdsworth. All rights reserved.
//
//  $Id: //depot/SwiftTrace/SwiftTrace/SwiftLifetime.swift#16 $
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
            var methodCount: UInt32 = 0
            if !tracksDeallocs.contains(register),
               let generic = autoBitCast(metaType) as Any.Type as? AnyClass,
               let methods = class_copyMethodList(generic, &methodCount) {
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
                if !tracksDeallocs.contains(register),
                   let superClass = class_getSuperclass(generic) {
                    trackGenerics(autoBitCast(superClass), register: register)
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
                    let metaType = update(instance:returnAsAny as AnyObject)
                    if !tracksDeallocs.contains(metaType) {
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
