//
//  SwiftInvoke.swift
//  SwiftTrace
//
//  Created by John Holdsworth on 20/04/2020.
//  Copyright © 2020 John Holdsworth. All rights reserved.
//
//  Repo: https://github.com/johnno1962/SwiftTrace
//  $Id: //depot/SwiftTrace/SwiftTrace/SwiftInvoke.swift#5 $
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
            fatalError("SwiftTrace.Call.init(name:vtableSlot:objcMethod:replaceWith:) should not be used")
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
            let registers = MemoryLayout<T>.size / MemoryLayout<intptr_t>.size
            #if os(macOS) || os(iOS) || os(tvOS)
            if arg is OSRect {
                rebind(rebind(&input.floatArg1, to: Double.self).advanced(by: floatArgNumber))
                    .pointee = arg
                floatArgNumber += registers
                return
            }
            else if arg is OSPoint {
                rebind(rebind(&input.floatArg1, to: Double.self).advanced(by: floatArgNumber))
                    .pointee = arg
                floatArgNumber += registers
                return
            }
            else if arg is OSSize {
                rebind(rebind(&input.floatArg1, to: Double.self).advanced(by: floatArgNumber))
                    .pointee = arg
                floatArgNumber += registers
                return
            }
            #endif
            if arg is Double || arg is Float {
                if floatArgNumber + 1 > EntryStack.maxFloatArgs {
                    fatalError("Too many float args for SwiftTrace.Call")
                }
                rebind(rebind(&input.floatArg1, to: Double.self).advanced(by: floatArgNumber))
                    .pointee = arg
                floatArgNumber += 1
            }
            else {
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
            rebind(&stack.floatReturn1).pointee  = backup
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
            else if arg is Int || type(of: arg) is AnyObject.Type {
                var arg = arg
                call.add(arg: call.rebind(&arg, to: Int.self).pointee)
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
extension SwiftTraceArg {
    public func add(toCall call: SwiftTrace.Call) {
        call.add(arg: self)
    }
}

extension UnsafeMutablePointer: SwiftTraceArg {}
extension UnsafePointer: SwiftTraceArg {}
extension Double: SwiftTraceArg {}
extension Float: SwiftTraceArg {}
extension String: SwiftTraceArg {}
#if os(macOS) || os(iOS) || os(tvOS)
extension OSRect: SwiftTraceArg {}
extension OSPoint: SwiftTraceArg {}
extension OSSize: SwiftTraceArg {}
#endif
