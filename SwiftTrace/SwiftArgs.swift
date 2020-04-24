//
//  SwiftArgs.swift
//  SwiftTrace
//
//  Created by John Holdsworth on 19/04/2020.
//  Copyright © 2020 John Holdsworth. All rights reserved.
//
//  Repo: https://github.com/johnno1962/SwiftTrace
//  $Id: //depot/SwiftTrace/SwiftTrace/SwiftArgs.swift#39 $
//
//  Decorate trace with argument/return values
//  ==========================================
//

import Foundation

extension SwiftTrace {

    open class Arguments: Swizzle {

        static let argumentParser =
            NSRegularExpression(regexp: #":\s*([^,)]+)[,)]|\.setter : (.+)$"#)

        static let returnParser =
            NSRegularExpression(regexp: #"\) -> (.+)$"#)

        lazy var argTypeRanges: [Range<String.Index>] = {
            return ranges(in: signature, parser: Self.argumentParser)
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
            let invocation =  self.invocation()!
                invocation.decorated = objcMethod != nil ?
                    objcDecorate(signature: nil,
                                 invocation: invocation,
                                 intArgs: &stack.intArg1,
                                 floatArgs: &stack.floatArg1) :
                    swiftDecorate(signature: signature,
                                  invocation: invocation,
                                  parser: Self.argumentParser,
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
                              parser: Self.returnParser,
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
            var intSlot = 0, floatSlot = 0
            var position = signature.startIndex
            var output = ""

            let typeRanges = parser === Self.argumentParser ?
                argTypeRanges : ranges(in: signature, parser: parser)

            LOOP:
            for range in typeRanges {
                output += signature[position ..< range.lowerBound]
                var value: String?

                func argValue<Type,Slot>(type: Type.Type,
                                        registers: UnsafePointer<Slot>,
                                        slot: inout Int, maxSlots: Int) {
                    let slotsRequired = (MemoryLayout<Type>.size +
                        MemoryLayout<Slot>.size - 1) /
                        MemoryLayout<Slot>.size
                    if slot + slotsRequired <= maxSlots {
                        (registers + slot)
                            .withMemoryRebound(to: Type.self, capacity: 1) {
                            value = Type.self == String.self ?
                                "\"\($0.pointee)\"" : "\($0.pointee)"
                            invocation.arguments.append($0.pointee)
                        }
                    }
                    slot += slotsRequired
                }

                func intValue<Type>(type: Type.Type) {
                    argValue(type: type, registers: intArgs, slot: &intSlot,
                             maxSlots: SwiftTrace.EntryStack.maxIntArgs)
                }

                func floatValue<Type>(type: Type.Type) {
                    argValue(type: type, registers: floatArgs, slot: &floatSlot,
                             maxSlots: SwiftTrace.EntryStack.maxFloatArgs)
                }

                let type = String(signature[range])
                switch type {
                case "Swift.Int":
                    intValue(type: Int.self)
                case "Swift.String":
                    intValue(type: String.self)
                case "Swift.Array<Swift.Int>":
                    intValue(type: [Int].self)
                case "Swift.Array<Swift.String>":
                    intValue(type: [String].self)
                case "Swift.Optional<Swift.String>":
                    intValue(type: String?.self)
                case "Swift.Float":
                    floatValue(type: Float.self)
                case "Swift.Double":
                    floatValue(type: Double.self)
                case "Swift.Bool":
                    intValue(type: Bool.self)
                #if os(macOS) || os(iOS) || os(tvOS)
                case "__C.CGRect":
                    floatValue(type: OSRect.self)
                case "__C.CGPoint":
                    floatValue(type: OSPoint.self)
                case "__C.CGSize":
                    floatValue(type: OSSize.self)
                #endif
                case "Swift.UInt":   intValue(type: UInt.self)
                case "Swift.Int64":  intValue(type: Int64.self)
                case "Swift.UInt64": intValue(type: UInt64.self)
                case "Swift.Int32":  intValue(type: Int32.self)
                case "Swift.UInt32": intValue(type: UInt32.self)
                case "Swift.Int16":  intValue(type: Int16.self)
                case "Swift.UInt16": intValue(type: UInt16.self)
                case "Swift.Int8":   intValue(type: Int8.self)
                case "Swift.UInt8":  intValue(type: UInt8.self)
                default:
                    if NSClassFromString(type) != nil {
                        intValue(type: AnyObject.self)
                    } else {
                        break LOOP
                    }
                }

                output += value ?? type
                position = range.upperBound
            }

            return output + signature[position ..< signature.endIndex]
        }

        lazy var methodSignature: Any? = {
            return method_getSignature(self.objcMethod!)
        }()

        lazy var selector: String = {
            return NSStringFromSelector(method_getName(objcMethod!))
        }()

        static var identifyFormat = "<%@ %p>"

        func identify(id: AnyObject) -> String {
            return String(format: Self.identifyFormat,
                          NSString(string: NSStringFromClass(object_getClass(id)!)),
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
            let objcSelf = unsafeBitCast(invocation.swiftSelf, to: AnyObject.self)
            var output = isReturn ? signature! + " -> " :
                "\(object_isClass(objcSelf) ? "+" : "-")[\(identify(id: objcSelf)) "
            // (Objective-)C methods have two implict arguments: self and _cmd;
            // if returning a struct, there is also the struct return address.
            var index = 2, intSlot = isReturn ? 0 : isStret ? 3 : 2, floatSlot = 0
            let selector = isReturn ? "__RETURN__:" : self.selector

            if !selector.hasSuffix(":") {
                output += selector
            } else {
                var args = [String]()
                let thread = ThreadStack.threadLocal()
                var hasSeenUnknownArgumentType = false

                for arg in selector.components(separatedBy: ":").dropLast() {
                    var value: String?

                    func argValue<Type,Slot>(type: Type.Type,
                                            registers: UnsafePointer<Slot>,
                                            slot: inout Int, maxSlots: Int) {
                        let slotsRequired = (MemoryLayout<Type>.size +
                            MemoryLayout<Slot>.size - 1) /
                            MemoryLayout<Slot>.size
                        if slot + slotsRequired <= maxSlots {
                            (registers + slot)
                                .withMemoryRebound(to: Type.self, capacity: 1) {

                                if hasSeenUnknownArgumentType {
                                    return
                                } else if Type.self == AnyObject?.self {
                                    if let id = unsafeBitCast($0.pointee,
                                                              to: AnyObject?.self) {
                                        let describing = thread.describing
                                        thread.describing = true
                                        if id.isKind(of: NSString.self) {
                                            value = "@\"\(id)\""
                                        } else {
                                            value = describing ? identify(id: id) : "\(id)"
                                        }
                                        thread.describing = describing
                                    } else {
                                        value = "nil"
                                    }
                                } else if Type.self == UnsafePointer<UInt8>.self {
                                    let str = unsafeBitCast($0.pointee,
                                                            to: UnsafePointer<UInt8>.self)
                                    value = "\"\(String(cString: str))\""
                                } else if Type.self == UnsafeRawPointer.self {
                                    value = String(format: "%p", unsafeBitCast($0.pointee, to: uintptr_t.self))
                                } else if Type.self == Selector.self {
                                    let SEL = unsafeBitCast($0.pointee, to: Selector.self)
                                    value = "@selector(\(NSStringFromSelector(SEL)))"
                                } else {
                                    value = "\($0.pointee)"
                                }

                                invocation.arguments.append($0.pointee)
                            }
                        }

                        slot += slotsRequired
                    }

                    func intValue<Type>(type: Type.Type) {
                        argValue(type: type, registers: intArgs, slot: &intSlot,
                                 maxSlots: SwiftTrace.EntryStack.maxIntArgs)
                    }

                    func floatValue<Type>(type: Type.Type) {
                        argValue(type: type, registers: floatArgs, slot: &floatSlot,
                                 maxSlots: SwiftTrace.EntryStack.maxFloatArgs)
                    }

                    let type = isReturn ? returnType :
                        String(cString: sig_argumentType(methodSignature, UInt(index)))

                    switch type {
                    case "@": intValue(type: AnyObject?.self)
                    case "#": intValue(type: AnyObject?.self)
                    case "c": intValue(type: Int8.self)
                    case "i": intValue(type: Int32.self)
                    case "s": intValue(type: Int16.self)
                    case "l": intValue(type: Int32.self)
                    case "q": intValue(type: Int64.self)
                    case "C": intValue(type: UInt8.self)
                    case "I": intValue(type: UInt32.self)
                    case "S": intValue(type: UInt16.self)
                    case "L": intValue(type: UInt32.self)
                    case "Q": intValue(type: UInt64.self)
                    case "f": floatValue(type: Float.self)
                    case "d": floatValue(type: Double.self)
                    case "B": intValue(type: Bool.self)
                    case "*": intValue(type: UnsafePointer<UInt8>.self)
                    case ":": intValue(type: Selector.self)
                    case "{_NSRange=QQ}": intValue(type: NSRange.self)
                    #if os(macOS) || os(iOS) || os(tvOS)
                    case "{CGRect={CGPoint=dd}{CGSize=dd}}":
                        floatValue(type: OSRect.self)
                    case "{CGPoint=dd}":
                        floatValue(type: OSPoint.self)
                    case "{CGSize=dd}":
                        floatValue(type: OSSize.self)
                    #endif
                    case "v":
                        value = "Void"
                    case "@?":
                        value = "^{}"
                    default:
                        if type.hasPrefix("^") {
                            intValue(type: UnsafeRawPointer.self)
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
    }
}
