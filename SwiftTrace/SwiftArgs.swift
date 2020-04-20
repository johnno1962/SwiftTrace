//
//  SwiftArgs.swift
//  SwiftTrace
//
//  Created by John Holdsworth on 19/04/2020.
//  Copyright © 2020 John Holdsworth. All rights reserved.
//
//  Repo: https://github.com/johnno1962/SwiftTrace
//  $Id: //depot/SwiftTrace/SwiftTrace/SwiftArgs.swift#6 $
//

import Foundation

extension SwiftTrace {

    open class Arguments: Swizzle {

        static let argumentParser =
            try! NSRegularExpression(pattern: #":\s*([^,)]+)[,)]|\.setter : (.+)$"#, options: [])

        static let returnParser =
            try! NSRegularExpression(pattern: #"\) -> (.+)$"#, options: [])

        open override func onEntry(stack: inout EntryStack) {
            let invocation =  self.invocation()!
            invocation.decorated =
                decorate(signature: signature, invocation: invocation,
                         parser: Self.argumentParser,
                         intArgs: &stack.intArg1,
                         floatArgs: &stack.floatArg1)
        }

        open override func message(stack: inout ExitStack) -> String {
            let invocation = self.invocation()!
            return decorate(signature: invocation.decorated ?? signature,
                            invocation: invocation,
                            parser: Self.returnParser,
                            intArgs: &stack.intReturn1,
                            floatArgs: &stack.floatReturn1)
        }

        func decorate(signature: String, invocation: Invocation,
                      parser: NSRegularExpression,
                      intArgs: UnsafePointer<intptr_t>,
                      floatArgs: UnsafePointer<Double>) -> String {
            var intCount = 0, floatCount = 0
            var position = signature.startIndex
            var output = ""

            parser.enumerateMatches(in: signature, options: [],
                  range: NSRange(signature.startIndex ..<
                                 signature.endIndex, in: signature)) {
                (result: NSTextCheckingResult?,
                 flags: NSRegularExpression.MatchingFlags,
                 stop: UnsafeMutablePointer<ObjCBool>) in
                if let match = result,
                    let range = Range(match.range(at: 1), in: signature) ??
                                Range(match.range(at: 2), in: signature) {
                    var value: String?
                    output += signature[position ..< range.lowerBound]

                    func argValue<Type,Reg>(type: Type.Type,
                                            registers: UnsafePointer<Reg>,
                                            count: inout Int, maxCount: Int) {
                        let slots = (MemoryLayout<Type>.size +
                            MemoryLayout<Reg>.size - 1) /
                            MemoryLayout<Reg>.size
                        if count + slots <= maxCount {
                            (registers + count)
                                .withMemoryRebound(to: Type.self, capacity: 1) {
                                value = Type.self == String.self ?
                                    "\"\($0.pointee)\"" : "\($0.pointee)"
                                invocation.arguments.append($0.pointee)
                            }
                        }
                        count += slots
                    }

                    func intValue<Type>(type: Type.Type) {
                        argValue(type: type, registers: intArgs, count: &intCount,
                                 maxCount: SwiftTrace.EntryStack.maxIntArgs)
                    }

                    func floatValue<Type>(type: Type.Type) {
                        argValue(type: type, registers: floatArgs, count: &floatCount,
                                 maxCount: SwiftTrace.EntryStack.maxFloatArgs)
                    }

                    let type = String(signature[range])
                    switch type {
                    case "Swift.Int":
                        intValue(type: Int.self)
                    case "Swift.String":
                        intValue(type: String.self)
                    case "Swift.Float":
                        floatValue(type: Float.self)
                    case "Swift.Double":
                        floatValue(type: Double.self)
                    case "__C.CGRect":
                        floatValue(type: OSRect.self)
                    case "__C.CGPoint":
                        floatValue(type: OSPoint.self)
                    case "__C.CGSize":
                        floatValue(type: OSSize.self)
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
                        stop.pointee = true
                    }

                    output += value ?? type
                    position = range.upperBound
                }
            }

            return output + signature[position ..< signature.endIndex]
        }
    }
}
