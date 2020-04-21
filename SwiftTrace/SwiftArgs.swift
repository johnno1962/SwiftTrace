//
//  SwiftArgs.swift
//  SwiftTrace
//
//  Created by John Holdsworth on 19/04/2020.
//  Copyright © 2020 John Holdsworth. All rights reserved.
//
//  Repo: https://github.com/johnno1962/SwiftTrace
//  $Id: //depot/SwiftTrace/SwiftTrace/SwiftArgs.swift#26 $
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

        open override func traceMessage(stack: inout ExitStack) -> String {
            let invocation = self.invocation()!
            return decorate(signature: invocation.decorated ?? signature,
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

        open func entryDecorate(stack: inout EntryStack) {
            let invocation =  self.invocation()!
            invocation.decorated =
                decorate(signature: signature, invocation: invocation,
                         parser: Self.argumentParser,
                         intArgs: &stack.intArg1,
                         floatArgs: &stack.floatArg1)
        }

        open func decorate(signature: String, invocation: Invocation,
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
                case "Swift.UInt":
                    intValue(type: UInt.self)
                case "Swift.Int64":
                    intValue(type: Int64.self)
                case "Swift.UInt64":
                    intValue(type: UInt64.self)
                case "Swift.Int32":
                    intValue(type: Int32.self)
                case "Swift.UInt32":
                    intValue(type: UInt32.self)
                case "Swift.Int16":
                    intValue(type: Int16.self)
                case "Swift.UInt16":
                    intValue(type: UInt16.self)
                case "Swift.Int8":
                    intValue(type: Int8.self)
                case "Swift.UInt8":
                    intValue(type: UInt8.self)
                default:
                    break LOOP
                }

                output += value ?? type
                position = range.upperBound
            }

            return output + signature[position ..< signature.endIndex]
        }
    }
}
