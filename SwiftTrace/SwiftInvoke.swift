//
//  SwiftInvoke.swift
//  SwiftTrace
//
//  Created by John Holdsworth on 20/04/2020.
//  Copyright © 2020 John Holdsworth. All rights reserved.
//
//  Repo: https://github.com/johnno1962/SwiftTrace
//  $Id: //depot/SwiftTrace/SwiftTrace/SwiftInvoke.swift#7 $
//
//  Invocation interface for Swift
//  ==============================
//

extension SwiftTrace {

    /**
        Implementation of invocation api
     */
    public class Call: Swizzle {

        public var input = EntryStack()
        public var output = ExitStack()
        var backup = EntryStack()
        var target: AnyObject
        var caller: SIMP? = nil

        public init?(target: AnyObject, methodName: String) {
            self.target = target
            var sigh: SIMP = { }
            super.init(name: methodName, vtableSlot: &sigh)

            guard iterateMethods(ofClass: type(of: target), callback: {
                (name, vtableSlot, stop) in
                if name == methodName {
                    self.vtableSlot = vtableSlot
                    implementation = rebind(vtableSlot).pointee
                    stop = true
                }
            }) else {
                return nil
            }

            input.swiftSelf = autoBitCast(target)

            caller = autoBitCast(imp_implementationForwardingToTracer(autoBitCast(self),
                                 autoBitCast(Swizzle.onEntry), autoBitCast(Swizzle.onExit)))
        }

        public required init?(name: String, vtableSlot: UnsafeMutablePointer<SIMP>? = nil,
                              objcMethod: Method? = nil, replaceWith: nullImplementationType? = nil) {
            fatalError("SwiftTrace.Call.init(name:vtableSlot:objcMethod:replaceWith:) must not be used")
        }

        public func reset(target: AnyObject) {
            self.target = target
        }

        public var intArgNumber = 0
        public var floatArgNumber = 0

        public func resetArgs() {
            intArgNumber = 0
            floatArgNumber = 0
        }

        public func add<T>(arg: T) {
            if arg is SwiftTraceFloatArg {
                let registers = (MemoryLayout<T>.size +
                    MemoryLayout<Double>.size - 1) / MemoryLayout<Double>.size
                if floatArgNumber + registers > EntryStack.maxFloatArgs {
                    fatalError("Too many float args for SwiftTrace.Call")
                }
                rebind(rebind(&input.floatArg1, to: T.self).advanced(by: floatArgNumber))
                    .pointee = arg
                floatArgNumber += registers
                return
            }
            else {
                let registers = (MemoryLayout<T>.size +
                    MemoryLayout<intptr_t>.size - 1) / MemoryLayout<intptr_t>.size
                if intArgNumber + registers > EntryStack.maxIntArgs {
                    fatalError("Too many int args for SwiftTrace.Call")
                }
                rebind(rebind(&input.intArg1, to: Int.self).advanced(by: intArgNumber))
                    .pointee = arg
                intArgNumber += registers
            }
        }

        public func invoke() {
            caller!()
            resetArgs()
        }

        public override func onEntry(stack: inout EntryStack) {
            input.framePointer = stack.framePointer
            input.structReturn = stack.structReturn
            backup = stack
            stack = input
        }

        public override func onExit(stack: inout ExitStack) {
            output = stack
            rebind(&stack.floatReturn1).pointee = backup
        }

        public func getReturn<T>() -> T {
            return output.genericReturn(swizzle: self).pointee
        }
    }

    /**
        Basic Swift method invocation api
         - parameter self: instance to message
         - parameter methodName: de-mangled method name to invoke
         - parameter args: list of values to use as arguments
     */
    open class func invoke<T>(target: AnyObject, methodName: String, args: Any...) -> T {
        guard let call = Call(target: target, methodName: methodName) else {
            fatalError("Unknown method \(methodName) on class \(target)")
        }

        for arg in args {
            if let arg = arg as? SwiftTraceArg {
                arg.add(toCall: call)
            }
            else if type(of: arg) is AnyObject.Type {
                call.add(arg: unsafeBitCast(arg, to: Int.self))
            }
            else {
                fatalError("Unsupported argument type \(type(of: arg))")
            }
        }

        call.invoke()

        return call.getReturn()
    }
}

public protocol SwiftTraceArg {
    func add(toCall call: SwiftTrace.Call)
}
public protocol SwiftTraceFloatArg: SwiftTraceArg {
}
extension SwiftTraceArg {
    public func add(toCall call: SwiftTrace.Call) {
        call.add(arg: self)
    }
}

extension Bool: SwiftTraceArg {}
extension Int: SwiftTraceArg {}
extension UInt: SwiftTraceArg {}
extension Int8: SwiftTraceArg {}
extension UInt8: SwiftTraceArg {}
extension Int16: SwiftTraceArg {}
extension UInt16: SwiftTraceArg {}
extension Int32: SwiftTraceArg {}
extension UInt32: SwiftTraceArg {}
extension Int64: SwiftTraceArg {}
extension UInt64: SwiftTraceArg {}
extension UnsafePointer: SwiftTraceArg {}
extension UnsafeMutablePointer: SwiftTraceArg {}
extension String: SwiftTraceArg {}
extension Double: SwiftTraceFloatArg {}
extension Float: SwiftTraceFloatArg {}
#if os(macOS) || os(iOS) || os(tvOS)
extension OSRect: SwiftTraceFloatArg {}
extension OSPoint: SwiftTraceFloatArg {}
extension OSSize: SwiftTraceFloatArg {}
#endif
