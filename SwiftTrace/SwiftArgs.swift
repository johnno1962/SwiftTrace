//
//  SwiftArgs.swift
//  SwiftTrace
//
//  Created by John Holdsworth on 19/04/2020.
//  Copyright © 2020 John Holdsworth. All rights reserved.
//
//  Repo: https://github.com/johnno1962/SwiftTrace
//  $Id: //depot/SwiftTrace/SwiftTrace/SwiftArgs.swift#109 $
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
extension CGFloat: SwiftTraceFloatArg {}
extension OSPoint: SwiftTraceFloatArg {}
extension OSSize: SwiftTraceFloatArg {}
extension OSRect: SwiftTraceFloatArg {}
extension OSEdgeInsets: SwiftTraceFloatArg {}
#endif

/**
 Use witness value table to get size of any type
 */
@_silgen_name("sizeofAnyType")
public func sizeof(anyType: Any.Type) -> size_t

/**
 Shenaniggans to be able to decorate any type linked into an app
 */
@_silgen_name("thunkToGeneric")
func thunkToGeneric(funcPtr: UnsafeRawPointer, valuePtr: UnsafeRawPointer,
                    type: Any.Type, outPtr: UnsafeMutableRawPointer)

/// generic function to describe a value of any type
public func describer<Type>(value: Type, outPtr: UnsafeMutableRawPointer) {
    outPtr.assumingMemoryBound(to: String.self).pointee =  "\(value)"
}

/// generic function to append a value to an array
public func appender<Type>(value: Type, outPtr: UnsafeMutableRawPointer) {
    outPtr.assumingMemoryBound(to: [Any].self).pointee.append(value)
}

extension SwiftTrace {

    /**
     Enable auto decoration of unknwon top level types
     */
    static public var autoDecorate = true
    /**
     Definitions related to auto-tracability of types
     */
    public static let module =
        mangle(_typeName(SwiftTrace.self).components(separatedBy: ".")[0])
    public static let argumentMangling = "5value6outPtryx_SvtlF"
    static func mangle(_ name: String) -> String {
        return "\(name.utf16.count)\(name)"
    }
    public static func bindGeneric(name: String, owner: String = module)
        -> UnsafeMutableRawPointer {
        let symbol = "$s\(owner)\(mangle(name))\(argumentMangling)"
        let RTLD_DEFAULT = UnsafeMutableRawPointer(bitPattern: -2)
        guard let genericFunctionPtr = dlsym(RTLD_DEFAULT, symbol) else {
            fatalError("Could lot locate generic function for symbol \(symbol)")
        }
        return genericFunctionPtr
    }

    static var describerFptr = bindGeneric(name: "describer")
    static var appenderFptr = bindGeneric(name: "appender")

    /**
     Add a type to the map of type arguments that can be formatted
     */
    open class func makeTraceable(types: [Any.Type]) {
        for type in types {
            let typeName = _typeName(type)
            let slotsRequired = (sizeof(anyType: type) +
                MemoryLayout<intptr_t>.size - 1) /
                MemoryLayout<intptr_t>.size
            if slotsRequired > (type is SwiftTraceFloatArg ?
                EntryStack.maxFloatSlots : EntryStack.maxIntSlots) {
                NSLog("SwiftTrace: ⚠️ Type \(typeName) is too large to be formatted ⚠️")
            }
            Decorated.swiftTypeHandlers[typeName] =
                { Decorated.handleArg(invocation: $0, isReturn: $1, type: type) }
        }
    }

    /**
     Prepare function that will trace an individual function.
     */
    open class func trace(name signature: String,
                          vtableSlot: UnsafeMutablePointer<SIMP>? = nil,
                          objcMethod: Method? = nil, objcClass: AnyClass? = nil,
                          original: UnsafeRawPointer) -> SIMP? {
        return Decorated(name: signature, vtableSlot: vtableSlot,
                         objcMethod: objcMethod, objcClass: objcClass,
                         original: autoBitCast(original))?.forwardingImplementation
    }

    /**
     Returns a pointer to tye type handlers dictionary - no longer used
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
            let endArgs = signature.range(of: " -> ")?.lowerBound
            let args = endArgs != nil ? signature[..<(endArgs!+0)] : signature
            return ranges(in: args, parser: Decorated.argumentParser)
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

            _ = Decorated.installCompoundTraceableTypes

            for range in typeRanges {
                output += signature[position ..< range.lowerBound]
                var value: String?

                let type = String(signature[range])
                if let typeHandler = Decorated.swiftTypeHandlers[type],
                    let handled = typeHandler(invocation, isReturn) {
                    value = handled
                } else if autoDecorate, signature[..<range.lowerBound]
                            .firstIndex(of: "<") == nil,
                      let anyType = Decorated.getType(named: type) {
                    value = Decorated.handleArg(invocation: invocation,
                                            isReturn: isReturn, type: anyType)
                } else if NSClassFromString(type) != nil {
                    value = Decorated.handleArg(invocation: invocation,
                                                isReturn: isReturn,
                                                type: AnyObject?.self)
                } else if type.hasPrefix("Swift.Optional<") {
                    let optional = type[.start+15 ..< .end-1]
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

        static let nameAbbreviations = [
            "Swift": "s"
        ]

        static var typeCache = [String: Any.Type?]()
        static var typeCacheLock = OS_SPINLOCK_INIT

        public static func getType(named: String) -> Any.Type? {
            OSSpinLockLock(&typeCacheLock)
            defer { OSSpinLockUnlock(&typeCacheLock) }
            if let type = typeCache[named] {
                return type
            }
            var mangled = ""
            for name in named.components(separatedBy: ".") {
                mangled += nameAbbreviations[name] ?? mangle(name)
            }
            let type = named.hasPrefix("Foundation.") ||
                named == "SwiftUI.StrokeStyle" ? nil :
                _typeByName(mangled+"V") ?? _typeByName(mangled+"C")
            typeCache[named] = type
            return type
        }

        static let installCompoundTraceableTypes: () = {
            SwiftTrace.makeTraceable(types: [
                Int?.self, [Int].self, Range<Int>.self,
                UInt?.self, [UInt].self, Range<UInt>.self,
                String?.self, [String].self, Bool?.self,
                Float.self, Double.self, CGFloat.self,
                Float?.self, Double?.self, CGFloat?.self,
                [Float].self, [Double].self, [CGFloat].self,
            ])
        }()

        /**
         Mapping of Swift type names to handler for that concrete type
         */
        public static var swiftTypeHandlers: [String: (Invocation, Bool) -> String?] = [
            "()": { _,_ in return "Void" }
        ]

        /**
         Selector name for objc method
         */
        lazy var selector: String = {
            return signature.hasPrefix("Injection#") ? signature :
                NSStringFromSelector(method_getName(objcMethod!))
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
            "v": { _,_  in return "void" }
        ]

        /**
         Generic argument handler given an invoction and the concrete type
         */
        public static func handleArg(invocation: Invocation,
                                     isReturn: Bool, type: Any.Type) -> String? {
            let slot: Int
            let maxSlots: Int
            var argPointer: UnsafeRawPointer
            let slotsRequired = (sizeof(anyType: type) +
                MemoryLayout<intptr_t>.size - 1) /
                MemoryLayout<intptr_t>.size
            if type is SwiftTraceFloatArg.Type {
                slot = invocation.floatArgumentOffset
                maxSlots = isReturn ? ExitStack.returnRegs : EntryStack.maxFloatSlots
                argPointer = UnsafeRawPointer((isReturn ?
                    withUnsafeMutablePointer(to:
                    &invocation.exitStack.pointee.floatReturn1) {$0} :
                    withUnsafeMutablePointer(to:
                    &invocation.entryStack.pointee.floatArg1) {$0})
                    .advanced(by: slot))
                invocation.floatArgumentOffset += slotsRequired
            } else {
                slot = invocation.intArgumentOffset
                maxSlots = isReturn ? ExitStack.returnRegs : EntryStack.maxIntSlots
                argPointer = UnsafeRawPointer((isReturn ?
                    withUnsafeMutablePointer(to:
                    &invocation.exitStack.pointee.intReturn1) {$0} :
                    withUnsafeMutablePointer(to:
                    &invocation.entryStack.pointee.intArg1) {$0})
                    .advanced(by: slot))
                invocation.intArgumentOffset += slotsRequired
            }

            if isReturn && slotsRequired > ExitStack.returnRegs,
                let structPtr = invocation.structReturn {
                argPointer = UnsafeRawPointer(structPtr)
            } else {
                guard slot + slotsRequired <= maxSlots else { return nil }
            }

            withUnsafeMutablePointer(to: &invocation.arguments) {
                thunkToGeneric(funcPtr: appenderFptr, valuePtr: argPointer,
                               type: type, outPtr: $0)
            }

            if type == AnyObject?.self {
                if let id = argPointer.load(as: AnyObject?.self) {
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
            else if type == UnsafePointer<UInt8>?.self {
                if let str = argPointer.load(as: UnsafePointer<UInt8>?.self) {
                    return "\"\(String(cString: str))\""
                } else {
                    return "NULL"
                }
            } else if type == UnsafeRawPointer.self {
                return String(format: "%p", argPointer.load(as: uintptr_t.self))
            } else if type == Selector.self {
                let SEL = argPointer.load(as: Selector.self)
                return "@selector(\(NSStringFromSelector(SEL)))"
            } else if type == String.self {
                return "\"\(argPointer.load(as: String.self))\""
            } else if let optionalType = type as? OptionalTyping.Type {
                return optionalType.describe(optionalPtr: argPointer)
            } else {
                var out = ""
                thunkToGeneric(funcPtr: describerFptr, valuePtr: argPointer,
                               type: type, outPtr: &out)
                return out
            }
        }
    }
}

fileprivate protocol OptionalTyping {
    static func describe(optionalPtr: UnsafeRawPointer) -> String
}
extension Optional: OptionalTyping {
    static func describe(optionalPtr: UnsafeRawPointer) -> String {
        if let value = optionalPtr.load(as: Wrapped?.self) {
            return "\(value)"
        }
        return "nil"
    }
}
