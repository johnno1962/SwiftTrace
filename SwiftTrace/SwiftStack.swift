//
//  SwiftStack.swift
//  SwiftTrace
//
//  Created by John Holdsworth on 20/04/2020.
//  Copyright © 2020 John Holdsworth. All rights reserved.
//
//  $Id: //depot/SwiftTrace/SwiftTrace/SwiftStack.swift#13 $
//
//  Stack layout used by assemby trampolines
//  ========================================
//
//  See: https://github.com/apple/swift/blob/main/docs/ABI/RegisterUsage.md
//  https://github.com/apple/swift/blob/main/docs/ABI/CallingConvention.rst
//

import Foundation

extension SwiftTrace {

    #if arch(arm64)
    /**
        Stack layout on entry from xt_forwarding_trampoline_arm64.s
     */
    public struct EntryStack {
        static let maxFloatSlots = 8
        static let maxIntSlots = 6 // Conservative here, actually it's 8

        public var floatArg1: Double = 0.0
        public var floatArg2: Double = 0.0
        public var floatArg3: Double = 0.0
        public var floatArg4: Double = 0.0
        public var floatArg5: Double = 0.0
        public var floatArg6: Double = 0.0
        public var floatArg7: Double = 0.0
        public var floatArg8: Double = 0.0
        public var intArg1: intptr_t = 0
        public var intArg2: intptr_t = 0
        public var intArg3: intptr_t = 0
        public var intArg4: intptr_t = 0
        public var intArg5: intptr_t = 0
        public var intArg6: intptr_t = 0
        public var intArg7: intptr_t = 0
        public var intArg8: intptr_t = 0
        public var structReturn: intptr_t = 0 // x8
        public var framePointer: intptr_t = 0
        public var swiftSelf: intptr_t = 0 // x20
        public var thrownError: intptr_t = 0 // x21
        public var frame: (fp: intptr_t, lr: intptr_t) = (0, 0)
    }

    /**
        Stack layout on exit from xt_forwarding_trampoline_arm64.s
     */
    public struct ExitStack {
        static let returnRegs = 4

        public var floatReturn1: Double = 0.0
        public var floatReturn2: Double = 0.0
        public var floatReturn3: Double = 0.0
        public var floatReturn4: Double = 0.0
        public var d4: Double = 0.0
        public var d5: Double = 0.0
        public var d6: Double = 0.0
        public var d7: Double = 0.0
        public var intReturn1: intptr_t = 0
        public var intReturn2: intptr_t = 0
        public var intReturn3: intptr_t = 0
        public var intReturn4: intptr_t = 0
        public var x4: intptr_t = 0
        public var x5: intptr_t = 0
        public var x6: intptr_t = 0
        public var x7: intptr_t = 0
        public var structReturn: intptr_t = 0 // x8
        public var framePointer: intptr_t = 0
        public var swiftSelf: intptr_t = 0 // x20
        public var thrownError: intptr_t = 0 // x21
        public var frame: (fp: intptr_t, lr: intptr_t) = (0, 0)

        mutating func resyncStructReturn() {
            structReturn = autoBitCast(invocation.structReturn)
        }
    }
    #else // x86_64
    /**
        Stack layout on entry from xt_forwarding_trampoline_x64.s
     */
    public struct EntryStack {
        static let maxFloatSlots = 8
        static let maxIntSlots = 6

        public var floatArg1: Double = 0.0
        public var floatArg2: Double = 0.0
        public var floatArg3: Double = 0.0
        public var floatArg4: Double = 0.0
        public var floatArg5: Double = 0.0
        public var floatArg6: Double = 0.0
        public var floatArg7: Double = 0.0
        public var floatArg8: Double = 0.0
        public var r10: intptr_t = 0
        public var r12: intptr_t = 0
        public var swiftSelf: intptr_t = 0  // r13
        public var r14: intptr_t = 0
        public var r15: intptr_t = 0
        public var intArg1: intptr_t = 0    // rdi
        public var intArg2: intptr_t = 0    // rsi
        public var intArg3: intptr_t = 0    // rcx
        public var intArg4: intptr_t = 0    // rdx
        public var intArg5: intptr_t = 0    // r8
        public var intArg6: intptr_t = 0    // r9
        public var structReturn: intptr_t = 0 // rax
        public var rbx: intptr_t = 0
        public var framePointer: intptr_t = 0
    }

    /**
        Stack layout on exit from xt_forwarding_trampoline_x64.s
     */
    public struct ExitStack {
        static let returnRegs = 4

        public var stackShift1: intptr_t = 0
        public var stackShift2: intptr_t = 0
        public var floatReturn1: Double = 0.0 // xmm0
        public var floatReturn2: Double = 0.0 // xmm1
        public var floatReturn3: Double = 0.0 // xmm2
        public var floatReturn4: Double = 0.0 // xmm3
        public var xmm4: Double = 0.0
        public var xmm5: Double = 0.0
        public var xmm6: Double = 0.0
        public var xmm7: Double = 0.0
        public var r10: intptr_t = 0
        public var thrownError: intptr_t = 0 // r12
        public var swiftSelf: intptr_t = 0  // r13
        public var r14: intptr_t = 0
        public var r15: intptr_t =  0
        public var rdi: intptr_t = 0
        public var rsi: intptr_t = 0
        public var intReturn1: intptr_t = 0 // rax (also struct Return)
        public var intReturn2: intptr_t = 0 // rdx
        public var intReturn3: intptr_t = 0 // rcx
        public var intReturn4: intptr_t = 0 // r8
        public var r9: intptr_t = 0
        public var rbx: intptr_t = 0
        public var framePointer: intptr_t = 0
        public var structReturn: intptr_t {
            return intReturn1
        }
        mutating func resyncStructReturn() {
            intReturn1 = autoBitCast(invocation.structReturn)
        }
    }
    #endif
}

extension SwiftTrace.EntryStack {
    public var invocation: SwiftTrace.Swizzle.Invocation! {
        return SwiftTrace.Swizzle.Invocation.current
    }
}

extension SwiftTrace.ExitStack {
    public var invocation: SwiftTrace.Swizzle.Invocation! {
        return SwiftTrace.Swizzle.Invocation.current
    }
    public mutating func genericReturn<T>(swizzle: SwiftTrace.Swizzle? = nil,
                                          to: Any.Type = T.self) -> UnsafeMutablePointer<T> {
        if MemoryLayout<T>.size > MemoryLayout<intptr_t>.size * SwiftTrace.ExitStack.returnRegs {
            resyncStructReturn()
            return UnsafeMutablePointer(cast: invocation.structReturn!)
        }
        else {
            let swizzle = swizzle ?? invocation!.swizzle
            if T.self is SwiftTraceFloatArg.Type {
                return swizzle.rebind(&floatReturn1)
            }
            else {
                return swizzle.rebind(&intReturn1)
            }
        }
    }
    mutating public func getReturn<T>() -> T {
        return genericReturn().pointee
    }
    mutating public func setReturn<T>(value: T) {
        intReturn1 = 0
        intReturn2 = 0
        intReturn3 = 0
        intReturn4 = 0
        return genericReturn().pointee = value
    }
    mutating public func stringReturn() -> String {
        return getReturn()
    }
}
