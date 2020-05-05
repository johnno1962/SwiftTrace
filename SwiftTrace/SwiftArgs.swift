//
//  SwiftArgs.swift
//  SwiftTrace
//
//  Created by John Holdsworth on 19/04/2020.
//  Copyright © 2020 John Holdsworth. All rights reserved.
//
//  Repo: https://github.com/johnno1962/SwiftTrace
//  $Id: //depot/SwiftTrace/SwiftTrace/SwiftArgs.swift#49 $
//
//  Decorate trace with argument/return values
//  ==========================================
//

import Foundation

extension SwiftTrace {

    public static var identifyFormat = "<%@ %p>"

    open class Decorated: Swizzle {

        static let argumentParser =
            NSRegularExpression(regexp: ":\\s*([^,)]+)[,)]|\\.setter : (.+)$")

        static let returnParser =
            NSRegularExpression(regexp: "\\) -> (.+)$")

        lazy var argTypeRanges: [Range<String.Index>] = {
            return ranges(in: signature, parser: Decorated.argumentParser)
        }()

        open func ranges(in signature: String, parser: NSRegularExpression) -> [Range<String.Index>] {
            return parser.matches(in: signature,
                    range: NSRange(signature.startIndex ..<
                    signature.endIndex, in: signature)).compactMap {
                Range($0.range(at: 1), in: signature) ??
                Range($0.range(at: 2), in: signature)
            }
        }

        open override func onEntry(stack: inout EntryStack) {
            entryDecorate(stack: &stack)
        }

        open func entryDecorate(stack: inout EntryStack) {
            let invocation = self.invocation()!
                invocation.decorated = objcMethod != nil ?
                    objcDecorate(signature: nil,
                                 invocation: invocation,
                                 intArgs: &stack.intArg1,
                                 floatArgs: &stack.floatArg1) :
                    swiftDecorate(signature: signature,
                                  invocation: invocation,
                                  parser: Decorated.argumentParser,
                                  intArgs: &stack.intArg1,
                                  floatArgs: &stack.floatArg1)
        }

        open override func traceMessage(stack: inout ExitStack) -> String {
            let invocation = self.invocation()!
            return objcMethod != nil ?
                objcDecorate(signature: invocation.decorated ?? signature,
                             invocation: invocation,
                             intArgs: &stack.intReturn1,
                             floatArgs: &stack.floatReturn1) :
                swiftDecorate(signature: invocation.decorated ?? signature,
                              invocation: invocation,
                              parser: Decorated.returnParser,
                              intArgs: &stack.intReturn1,
                              floatArgs: &stack.floatReturn1)
        }

        open var arguments: [Any] {
            let invocation = self.invocation()!
            if invocation.arguments.isEmpty {
                entryDecorate(stack: &invocation.entryStack.pointee)
            }
            return invocation.arguments
        }

        open func swiftDecorate(signature: String, invocation: Invocation,
                                parser: NSRegularExpression,
                                intArgs: UnsafePointer<intptr_t>,
                                floatArgs: UnsafePointer<Double>) -> String {
            guard invocation.shouldDecorate else {
                return signature
            }
            let isReturn = !(parser === Decorated.argumentParser)
            var position = signature.startIndex
            var output = ""

            if !isReturn {
                invocation.arguments
                    .append(unsafeBitCast(invocation.swiftSelf, to: AnyObject.self))
            }

            var hasSeenUnknownArgumentType = false
            let typeRanges = !isReturn ? argTypeRanges :
                ranges(in: signature, parser: parser)
            invocation.floatArgumentOffset = 0
            invocation.intArgumentOffset = 0

            for range in typeRanges where !hasSeenUnknownArgumentType {
                output += signature[position ..< range.lowerBound]
                var value: String?

                let type = String(signature[range])
                if let typeHandler = Decorated.swiftTypeHandlers[type],
                    let handled = typeHandler(invocation, isReturn) {
                    value = handled
                } else if NSClassFromString(type) != nil {
                    value = Decorated.handleArg(invocation: invocation,
                                                isReturn: isReturn,
                                                type: AnyObject?.self)
                } else {
                    hasSeenUnknownArgumentType = true
                }

                output += value ?? type
                position = range.upperBound
            }

            return output + signature[position ..< signature.endIndex]
        }

        public static var swiftTypeHandlers: [String: (Invocation, Bool) -> String?] = [
            "Swift.Int": { handleArg(invocation: $0, isReturn: $1, type: Int.self) },
            "Swift.UInt": { handleArg(invocation: $0, isReturn: $1, type: UInt.self) },
            "Swift.Int64": { handleArg(invocation: $0, isReturn: $1, type: Int64.self) },
            "Swift.UInt64": { handleArg(invocation: $0, isReturn: $1, type: UInt64.self) },
            "Swift.Int32": { handleArg(invocation: $0, isReturn: $1, type: Int32.self) },
            "Swift.UInt32": { handleArg(invocation: $0, isReturn: $1, type: UInt32.self) },
            "Swift.Int16": { handleArg(invocation: $0, isReturn: $1, type: Int16.self) },
            "Swift.UInt16": { handleArg(invocation: $0, isReturn: $1, type: UInt16.self) },
            "Swift.Int8": { handleArg(invocation: $0, isReturn: $1, type: Int8.self) },
            "Swift.UInt8": { handleArg(invocation: $0, isReturn: $1, type: UInt8.self) },
            "Swift.String": { handleArg(invocation: $0, isReturn: $1, type: String.self) },
            "Swift.Array<Swift.Int>": { handleArg(invocation: $0, isReturn: $1, type: [Int].self) },
            "Swift.Array<Swift.String>": { handleArg(invocation: $0, isReturn: $1, type: [String].self) },
            "Swift.Optional<Swift.String>": { handleArg(invocation: $0, isReturn: $1, type: String?.self) },
            "Swift.Bool": { handleArg(invocation: $0, isReturn: $1, type: Bool.self) },
            "Swift.Float": { handleArg(invocation: $0, isReturn: $1, type: Float.self) },
            "Swift.Double": { handleArg(invocation: $0, isReturn: $1, type: Double.self) },
            "CoreGraphics.CGFloat": { handleArg(invocation: $0, isReturn: $1, type: CGFloat.self) },
            "__C.CGRect": { handleArg(invocation: $0, isReturn: $1, type: OSRect.self) },
            "__C.CGPoint": { handleArg(invocation: $0, isReturn: $1, type: OSPoint.self) },
            "__C.CGSize": { handleArg(invocation: $0, isReturn: $1, type: OSSize.self) },
            "()": { _,_  in return "Void" },
        ]

        lazy var methodSignature: Any? = {
            return method_getSignature(self.objcMethod!)
        }()

        lazy var selector: String = {
            return NSStringFromSelector(method_getName(objcMethod!))
        }()

        static func identify(id: AnyObject) -> String {
            let className = NSStringFromClass(object_getClass(id)!)
            return object_isClass(id) ? className :
                String(format: identifyFormat, className as NSString,
                       unsafeBitCast(id, to: uintptr_t.self))
        }

        open func objcDecorate(signature: String?, invocation: Invocation,
                               intArgs: UnsafePointer<intptr_t>,
                               floatArgs: UnsafePointer<Double>) -> String {
            guard methodSignature != nil else {
                return signature ?? invocation.swizzle.signature }
            let isReturn = signature != nil
            let returnType = String(cString: sig_returnType(methodSignature!))
            // Is method returning a struct?
            // If so there is an implicit argument which is the address
            // to write the struct into (even if the registers are used.)
            #if arch(arm64)
            let isStret = false
            #else
            let isStret = returnType.hasPrefix("{") &&
                !returnType.hasSuffix("=dd}") && !returnType.hasSuffix("=QQ}")
            if isStret && !isReturn {
                invocation.swiftSelf = intArgs[1]
            }
            #endif
            guard invocation.shouldDecorate else {
                return invocation.swizzle.signature
            }
            let objcSelf = unsafeBitCast(invocation.swiftSelf, to: AnyObject.self)
            if !isReturn {
                invocation.arguments.append(objcSelf)
            }
            var output = isReturn ? signature! + " -> " :
                "\(object_isClass(objcSelf) ? "+" : "-")[\(Decorated.identify(id: objcSelf)) "
            // /\(ThreadLocal.current().levelsTracing)/\(trace.instanceFilter)/\(trace.classFilter)
            // (Objective-)C methods have two implict arguments: self and _cmd;
            // if returning a struct, there is also the struct return address.
            var index = 2
            invocation.intArgumentOffset = isReturn ? 0 : isStret ? 3 : 2
            invocation.floatArgumentOffset = 0
            let selector = isReturn ? "__RETURN__:" : self.selector

            if !selector.hasSuffix(":") {
                output += selector
            } else {
                var args = [String]()
                var hasSeenUnknownArgumentType = false

                for arg in selector.components(separatedBy: ":").dropLast() {
                    var value: String?
                    let type = isReturn ? returnType :
                        String(cString: sig_argumentType(methodSignature!, UInt(index)))

                    if !hasSeenUnknownArgumentType {
                        if let typeHandler = Decorated.objcTypeHandlers[type],
                            let handled = typeHandler(invocation, isReturn) {
                            value = handled
                        } else if type.hasPrefix("^") {
                            value = Decorated.handleArg(invocation: invocation,
                                                        isReturn: isReturn,
                                                        type: UnsafeRawPointer.self)
                        } else {
                            hasSeenUnknownArgumentType = true
                        }
                    }

                    args.append((isReturn ? "" : arg + ":") + (value ?? "(\(type))"))
                    index += 1
                }

                output += args.joined(separator: " ")
            }

            return output + (isReturn ? "" : "]")
        }

        public static var objcTypeHandlers: [String: (Invocation, Bool) -> String?] = [
            "@": { handleArg(invocation: $0, isReturn: $1, type: AnyObject?.self) },
            "#": { handleArg(invocation: $0, isReturn: $1, type: AnyObject?.self) },
            "c": { handleArg(invocation: $0, isReturn: $1, type: Int8.self) },
            "i": { handleArg(invocation: $0, isReturn: $1, type: Int32.self) },
            "s": { handleArg(invocation: $0, isReturn: $1, type: Int16.self) },
            "l": { handleArg(invocation: $0, isReturn: $1, type: Int32.self) },
            "q": { handleArg(invocation: $0, isReturn: $1, type: Int64.self) },
            "C": { handleArg(invocation: $0, isReturn: $1, type: UInt8.self) },
            "I": { handleArg(invocation: $0, isReturn: $1, type: UInt32.self) },
            "S": { handleArg(invocation: $0, isReturn: $1, type: UInt16.self) },
            "L": { handleArg(invocation: $0, isReturn: $1, type: UInt32.self) },
            "Q": { handleArg(invocation: $0, isReturn: $1, type: UInt64.self) },
            "f": { handleArg(invocation: $0, isReturn: $1, type: Float.self) },
            "d": { handleArg(invocation: $0, isReturn: $1, type: Double.self) },
            "B": { handleArg(invocation: $0, isReturn: $1, type: Bool.self) },
            "*": { handleArg(invocation: $0, isReturn: $1, type: UnsafePointer<UInt8>?.self) },
            ":": { handleArg(invocation: $0, isReturn: $1, type: Selector.self) },
            "{_NSRange=QQ}":
                { handleArg(invocation: $0, isReturn: $1, type: NSRange.self) },
            "{CGRect={CGPoint=dd}{CGSize=dd}}":
                { handleArg(invocation: $0, isReturn: $1, type: OSRect.self) },
            "{CGPoint=dd}":
                { handleArg(invocation: $0, isReturn: $1, type: OSPoint.self) },
            "{CGSize=dd}":
                { handleArg(invocation: $0, isReturn: $1, type: OSSize.self) },
            "@?": { _,_  in return "^{}" },
            "v": { _,_  in return "Void" }
        ]

        public static func handleArg<Type>(invocation: Invocation,
                                           isReturn: Bool, type: Type.Type) -> String? {
            let slot: Int
            let maxSlots: Int
            let argPointer: UnsafeMutablePointer<Type>
            let slotsRequired = (MemoryLayout<Type>.size +
                MemoryLayout<intptr_t>.size - 1) /
                MemoryLayout<intptr_t>.size
            if Type.self is SwiftTraceFloatArg.Type {
                slot = invocation.floatArgumentOffset
                maxSlots = EntryStack.maxFloatArgs
                argPointer = invocation.swizzle.rebind((isReturn ?
                    withUnsafeMutablePointer(to:
                    &invocation.exitStack.pointee.floatReturn1) {$0} :
                    withUnsafeMutablePointer(to:
                    &invocation.entryStack.pointee.floatArg1) {$0})
                    .advanced(by: slot))
                invocation.floatArgumentOffset += slotsRequired
            } else {
                slot = invocation.intArgumentOffset
                maxSlots = EntryStack.maxIntArgs
                argPointer = invocation.swizzle.rebind((isReturn ?
                    withUnsafeMutablePointer(to:
                    &invocation.exitStack.pointee.intReturn1) {$0} :
                    withUnsafeMutablePointer(to:
                    &invocation.entryStack.pointee.intArg1) {$0})
                    .advanced(by: slot))
                invocation.intArgumentOffset += slotsRequired
            }

            guard slot + slotsRequired <= maxSlots else { return nil }

            invocation.arguments.append(argPointer.pointee)
            if Type.self == AnyObject?.self {
                if let id = unsafeBitCast(argPointer.pointee,
                                          to: AnyObject?.self) {
                    let thread = ThreadLocal.current()
                    let describing = thread.describing
                    defer { thread.describing = describing }
                    thread.describing = true
                    if id.isKind(of: NSString.self) {
                        return "@\"\(id)\""
                    } else {
                        return describing ? identify(id: id) : "\(id)"
                    }
                } else {
                    return "nil"
                }
            }
            else if Type.self == UnsafePointer<UInt8>?.self {
                if let str = unsafeBitCast(argPointer.pointee,
                                           to: UnsafePointer<UInt8>?.self) {
                    return "\"\(String(cString: str))\""
                } else {
                    return "NULL"
                }
            } else if Type.self == UnsafeRawPointer.self {
                return String(format: "%p", unsafeBitCast(argPointer.pointee, to: uintptr_t.self))
            } else if Type.self == Selector.self {
                let SEL = unsafeBitCast(argPointer.pointee, to: Selector.self)
                return "@selector(\(NSStringFromSelector(SEL)))"
            } else if Type.self == String.self {
                return "\"\(argPointer.pointee)\""
            } else {
                return "\(argPointer.pointee)"
            }
        }
    }
}
