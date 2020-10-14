//
//  SwiftArgs.swift
//  SwiftTrace
//
//  Created by John Holdsworth on 19/04/2020.
//  Copyright © 2020 John Holdsworth. All rights reserved.
//
//  Repo: https://github.com/johnno1962/SwiftTrace
//  $Id: //depot/SwiftTrace/SwiftTrace/SwiftArgs.swift#87 $
//
//  Decorate trace with argument/return values
//  ==========================================
//

import Foundation
#if SWIFT_PACKAGE
import SwiftTraceGuts
#endif

#if os(macOS)
import AppKit
typealias OSRect = NSRect
typealias OSPoint = NSPoint
typealias OSSize = NSSize
typealias OSEdgeInsets = NSEdgeInsets
#elseif os(iOS) || os(tvOS)
import UIKit
typealias OSRect = CGRect
typealias OSPoint = CGPoint
typealias OSSize = CGSize
typealias OSEdgeInsets = UIEdgeInsets
#endif

public protocol SwiftTraceArg {
}
public protocol SwiftTraceFloatArg: SwiftTraceArg {
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
extension CGFloat: SwiftTraceFloatArg {}
#endif

@_silgen_name("swift_getTypeName")
private func getTypeName(_ type: Any.Type, qualified: Bool)
                  -> (name: UnsafePointer<Int8>, size: Int)

extension SwiftTrace {

    /**
     Add a type to the map of type arguments that can be formatted
     */
    open class func addFormattedType<T>(_ type: T.Type, prefix: String? = nil) {
        let typeName = prefix != nil ?
            prefix!+"."+String(describing: type) :
            String(cString: getTypeName(type, qualified: true).name)
        let slotsRequired = (MemoryLayout<T>.size +
            MemoryLayout<intptr_t>.size - 1) /
            MemoryLayout<intptr_t>.size
        if slotsRequired > (T.self is SwiftTraceFloatArg ?
            EntryStack.maxFloatSlots : EntryStack.maxIntSlots) {
            NSLog("SwiftTrace: ⚠️ Type \(typeName) is too large to be formatted ⚠️")
        }
        Decorated.swiftTypeHandlers[typeName] =
            { Decorated.handleArg(invocation: $0, isReturn: $1, type: type) }
    }

    /**
     Returns a pointer to tye type handlers dictionary
     */
    @objc class var swiftTypeHandlers: UnsafeMutableRawPointer {
        return UnsafeMutableRawPointer(&Decorated.swiftTypeHandlers)
    }

    /**
     Swizze subclas that decorates signature with argument/return values
     */
    open class Decorated: Swizzle {

        /**
         Basic Swift argument type detector
         */
        static let argumentParser =
            NSRegularExpression(regexp: ": ([^,)]+)[,)]|\\.setter : (.+)$")

        /**
         Very basic return valuue type detector
         */
        static let returnParser =
            NSRegularExpression(regexp: ".+\\) -> (.+?)( in conformance .+)?$")

        /**
         Cache of positions in signature of arguments
         */
        lazy var argTypeRanges: [Range<String.Index>] = {
            return ranges(in: signature, parser: Decorated.argumentParser)
        }()

        /**
         Ranges of arguments in signature
         */
        open func ranges(in signature: String, parser: NSRegularExpression) -> [Range<String.Index>] {
            return parser.matches(in: signature,
                    range: NSRange(signature.startIndex ..<
                    signature.endIndex, in: signature)).compactMap {
                Range($0.range(at: 1), in: signature) ??
                Range($0.range(at: 2), in: signature)
            }
        }

        /**
         substitute argguament values into signature on method entry
         */
        open override func entryDecorate(stack: inout EntryStack) -> String {
            let invocation = self.invocation()!
            return objcMethod != nil ?
                objcDecorate(signature: nil,
                             invocation: invocation) :
                swiftDecorate(signature: signature,
                              invocation: invocation,
                              parser: Decorated.argumentParser)
        }

        /**
         Determine return value on method exit
         */
        open override func exitDecorate(stack: inout ExitStack) -> String {
            let invocation = self.invocation()!
            return objcMethod != nil ?
                objcDecorate(signature: invocation.decorated ?? signature,
                             invocation: invocation) :
                swiftDecorate(signature: invocation.decorated ?? signature,
                              invocation: invocation,
                              parser: Decorated.returnParser)
        }

        /**
         Array of argument values as 'Any'
         */
        open var arguments: [Any] {
            let invocation = self.invocation()!
            if invocation.arguments.isEmpty {
                _ = entryDecorate(stack: &invocation.entryStack.pointee)
            }
            return invocation.arguments
        }

        lazy var hasSelf: Bool = {
            return objcMethod != nil || vtableSlot != nil &&
                !signature.hasPrefix("protocol witness for ")
        }()

        /**
         Argument decorator for Sift signatures
         */
        open func swiftDecorate(signature: String, invocation: Invocation,
                                parser: NSRegularExpression) -> String {
            guard invocation.shouldDecorate else {
                return signature
            }
            let isReturn = !(parser === Decorated.argumentParser)
            var output = ""

            if !isReturn && hasSelf {
                invocation.arguments
                    .append(unsafeBitCast(invocation.swiftSelf, to: AnyObject.self))
            }

            let typeRanges = !isReturn ? argTypeRanges :
                ranges(in: signature, parser: parser)
            var position = isReturn ? typeRanges.last?.lowerBound ??
                signature.startIndex : signature.startIndex
            invocation.floatArgumentOffset = 0
            invocation.intArgumentOffset = 0

            for range in typeRanges {
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
                } else if type.hasPrefix("Swift.Optional<") {
                    let optional = type[type.index(type.startIndex, offsetBy: 15) ..<
                                        type.index(type.endIndex, offsetBy: -1)]
                        .replacingOccurrences(of: "^__C\\.", with: "",
                                              options: .regularExpression)
                    if NSClassFromString(optional) != nil {
                        value = Decorated.handleArg(invocation: invocation,
                                                    isReturn: isReturn,
                                                    type: AnyObject?.self)
                    }
                }

                position = range.upperBound

                if value == nil {
                    output += isReturn ? "" : type
                    break
                }

                output += value!
            }

            let endIndex = isReturn ?
                typeRanges.isEmpty ? signature.startIndex :
                    !hasSelf && !typeRanges.isEmpty ?
                    typeRanges[0].upperBound : signature.endIndex :
                signature.endIndex
            return output + signature[position ..< endIndex]
        }

        /**
         Mapping of Swift type names to handler for that concrete type
         */
        public static var swiftTypeHandlers: [String: (Invocation, Bool) -> String?] = [
            "Swift.Int": { handleArg(invocation: $0, isReturn: $1, type: Int.self) },
            "Swift.Array<Swift.Int>": { handleArg(invocation: $0, isReturn: $1, type: [Int].self) },
            "Swift.Optional<Swift.Int>": { handleArg(invocation: $0, isReturn: $1, type: Int?.self) },
            "Swift.Range<Swift.Int>": { handleArg(invocation: $0, isReturn: $1, type: Range<Int>.self) },
            "Swift.UInt": { handleArg(invocation: $0, isReturn: $1, type: UInt.self) },
            "Swift.Array<Swift.UInt>": { handleArg(invocation: $0, isReturn: $1, type: [UInt].self) },
            "Swift.Optional<Swift.UInt>": { handleArg(invocation: $0, isReturn: $1, type: UInt?.self) },
            "Swift.Int64": { handleArg(invocation: $0, isReturn: $1, type: Int64.self) },
            "Swift.UInt64": { handleArg(invocation: $0, isReturn: $1, type: UInt64.self) },
            "Swift.Int32": { handleArg(invocation: $0, isReturn: $1, type: Int32.self) },
            "Swift.UInt32": { handleArg(invocation: $0, isReturn: $1, type: UInt32.self) },
            "Swift.Int16": { handleArg(invocation: $0, isReturn: $1, type: Int16.self) },
            "Swift.UInt16": { handleArg(invocation: $0, isReturn: $1, type: UInt16.self) },
            "Swift.Int8": { handleArg(invocation: $0, isReturn: $1, type: Int8.self) },
            "Swift.UInt8": { handleArg(invocation: $0, isReturn: $1, type: UInt8.self) },
            "Swift.String": { handleArg(invocation: $0, isReturn: $1, type: String.self) },
            "Swift.Array<Swift.String>": { handleArg(invocation: $0, isReturn: $1, type: [String].self) },
            "Swift.Optional<Swift.String>": { handleArg(invocation: $0, isReturn: $1, type: String?.self) },
            "Swift.Bool": { handleArg(invocation: $0, isReturn: $1, type: Bool.self) },
            "Swift.Optional<Swift.Bool>": { handleArg(invocation: $0, isReturn: $1, type: Bool?.self) },
            "Swift.Float": { handleArg(invocation: $0, isReturn: $1, type: Float.self) },
            "Swift.Optional<Swift.Float>": { handleArg(invocation: $0, isReturn: $1, type: Float?.self) },
            "Swift.Double": { handleArg(invocation: $0, isReturn: $1, type: Double.self) },
            "Swift.Optional<Swift.Double>": { handleArg(invocation: $0, isReturn: $1, type: Double?.self) },
            "CoreGraphics.CGFloat": { handleArg(invocation: $0, isReturn: $1, type: CGFloat.self) },
            "Swift.Optional<CoreGraphics.CGFloat>": { handleArg(invocation: $0, isReturn: $1, type: CGFloat?.self) },
            "__C.CGRect": { handleArg(invocation: $0, isReturn: $1, type: OSRect.self) },
            "__C.CGPoint": { handleArg(invocation: $0, isReturn: $1, type: OSPoint.self) },
            "__C.CGSize": { handleArg(invocation: $0, isReturn: $1, type: OSSize.self) },
            "__C.NSEdgeInsets": { handleArg(invocation: $0, isReturn: $1, type: OSEdgeInsets.self) },
            "CoreGraphics.UIEdgeInsets": { handleArg(invocation: $0, isReturn: $1, type: OSEdgeInsets.self) },

            "()": { _,_  in return "Void" },
        ]

        /**
         Selector name for objc method
         */
        lazy var selector: String = {
            return NSStringFromSelector(method_getName(objcMethod!))
        }()

        /**
         Identify an instance for trace output
         */
        static func identify(id: AnyObject, objcClass: AnyClass? = nil) -> String {
            var subClassed = ""
            let thisClass: AnyClass? = object_getClass(id)
            let className = NSStringFromClass(thisClass!)
            if objcClass != nil &&
                className != NSStringFromClass(objcClass!) {
                subClassed = "/\(objcClass!)"
            }
            return (object_isClass(id) ? className :
                String(format: identifyFormat, className as NSString,
                       unsafeBitCast(id, to: uintptr_t.self))) + subClassed
        }

        /**
         Build up selector notate with argument values for objc
         */
        open func objcDecorate(signature: String?, invocation: Invocation) -> String {
            guard methodSignature != nil else {
                return signature ?? invocation.swizzle.signature }
            let isReturn = signature != nil
            let isStret = objcAdjustStret(invocation: invocation, isReturn: isReturn,
                                          intArgs: &invocation.entryStack.pointee.intArg1)
            guard invocation.shouldDecorate else {
                return invocation.swizzle.signature
            }
            let objcSelf = unsafeBitCast(invocation.swiftSelf, to: AnyObject.self)
            if !isReturn {
                invocation.arguments.append(objcSelf)
            }
            var output = isReturn ? "" :
                "\(object_isClass(objcSelf) ? "+" : "-")[\(Decorated.identify(id: objcSelf, objcClass: objcClass)) "
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
                    let type = isReturn ? String(cString: sig_returnType(methodSignature!)) :
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

        /**
         Mapping of objc type encodings to handlers for that concrete type
         */
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
            "{UIEdgeInsets=dddd}":
                { handleArg(invocation: $0, isReturn: $1, type: OSEdgeInsets.self) },
            "{NSEdgeInsets=dddd}":
                { handleArg(invocation: $0, isReturn: $1, type: OSEdgeInsets.self) },
            "@?": { _,_  in return "^{}" },
            "v": { _,_  in return "Void" }
        ]

        /**
         Generic argument handler given an invoction and the concrete type
         */
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
                maxSlots = EntryStack.maxFloatSlots
                argPointer = invocation.swizzle.rebind((isReturn ?
                    withUnsafeMutablePointer(to:
                    &invocation.exitStack.pointee.floatReturn1) {$0} :
                    withUnsafeMutablePointer(to:
                    &invocation.entryStack.pointee.floatArg1) {$0})
                    .advanced(by: slot))
                invocation.floatArgumentOffset += slotsRequired
            } else {
                slot = invocation.intArgumentOffset
                maxSlots = EntryStack.maxIntSlots
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
                    if let cls = object_getClass(id), cls.isSubclass(of: NSProxy.class()) {
                        return identify(id: id)
                    }
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
            } else if let optionalType = type as? OptionalTyping.Type {
                return optionalType.describe(optional: argPointer.pointee)
            } else {
                return "\(argPointer.pointee)"
            }
        }
    }
}

fileprivate protocol OptionalTyping {
    static func describe<Ty>(optional: Ty) -> String
}
extension Optional: OptionalTyping {
    static func describe<Ty>(optional: Ty) -> String {
        if let value = unsafeBitCast(optional, to: Wrapped?.self) {
            return "\(value)"
        }
        return "nil"
    }
}
