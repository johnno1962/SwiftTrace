//
//  SwiftArgs.swift
//  SwiftTrace
//
//  Created by John Holdsworth on 19/04/2020.
//  Copyright © 2020 John Holdsworth. All rights reserved.
//
//  Repo: https://github.com/johnno1962/SwiftTrace
//  $Id: //depot/SwiftTrace/SwiftTrace/SwiftArgs.swift#177 $
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

/// generic function to append a value to the arguments array
public func appender<Type>(value: Type, out: inout [Any]) {
    out.append(value)
}

/// generic function to describe a value of any type
public func describer<Type>(value: Type, out: inout String) {
    if type(of: value) is AnyClass && !(value is CustomStringConvertible) {
        out += String(format: SwiftTrace.identifyFormat, "\(value)" as NSString,
                      unsafeBitCast(value, to: uintptr_t.self))+"("
        if out.utf8.count < SwiftTrace.maxArgumentDescriptionBytes {
            var first = true
            for (name, field) in Mirror(reflecting: value).children {
                out += "\(first ? "" : ", ")\(name ?? "_"): "
                describer(value: field, out: &out)
                first = false
            }
        } else {
            out += "..."
        }
        out += ")"
    } else {
        out += value is String ? "\"\(value)\"" : "\(value)"
    }
}

extension SwiftTrace {

    /**
     Enable auto decoration of unknown types
     */
    static public var typeLookup = false

    /**
     Decorating "Any" is not fully understood.
     */
    public static var decorateAny = false {
        didSet {
            SwiftMeta.typeLookupCache["Any"] = decorateAny ? Any.self : nil
        }
    }

    /**
     A "pagmatic" limit on the size of structs that will be decorated
     */
    static public var maxIntegerArgumentSlots = 4

    /**
     A limit on argument description size
     */
    static public var maxArgumentDescriptionBytes = 1_000

    // For describing values and appending values to arguments array
    static var describerFptr = SwiftMeta.bindGeneric(name: "describer",
                                                     args: "SSzt")
    static var appenderFptr = SwiftMeta.bindGeneric(name: "appender",
                                                    args: "SayypGzt")

    /**
     Default pattern of type names to be excluded from decoration
     */
    open class var defaultLookupExclusions: String {
        return """
            ^SwiftUI\\.(Font\\.Design|ToggleStyleConfiguration|AccessibilityChildBehavior|\
            LocalizedStringKey\\.StringInterpolation|RoundedCornerStyle|Image\\.ResizingMode|\
            PopoverAttachmentAnchor|KeyEquivalent|Text\\.DateStyle|ToolbarItemPlacement|\
            Color\\.RGBColorSpace|SwitchToggleStyle|RoundedRectangle|Capsule|\
            ButtonStyleConfiguration|NavigationBarItem\\.TitleDisplayMode)
            """
    }

    static var lookupExclusionRegexp: NSRegularExpression? =
        NSRegularExpression(regexp: defaultLookupExclusions)

    /**
     Exclude types with name matching this pattern. If not specified
     a default regular expression in defaultLookupExclusions is used.
     */
    open class var lookupExclusionPattern: String? {
        get { return lookupExclusionRegexp?.pattern }
        set(newValue) {
            lookupExclusionRegexp = newValue == nil ? nil :
                NSRegularExpression(regexp: newValue!)
        }
    }

    /**
     Add a type to the map of type arguments that can be formatted
     (This is now automated by type lookup if you select it)
     */
    open class func makeTraceable(types: [Any.Type]) {
        for type in types {
            let typeName = _typeName(type)
            let slotsRequired = (SwiftMeta.sizeof(anyType: type) +
                MemoryLayout<intptr_t>.size - 1) /
                MemoryLayout<intptr_t>.size
            if slotsRequired > (type is SwiftTraceFloatArg ?
                EntryStack.maxFloatSlots : maxIntegerArgumentSlots) {
                NSLog("SwiftTrace: ⚠️ Type \(typeName) is too large to be formatted ⚠️")
            }
            Decorated.swiftTypeHandlers[typeName] =
                { Decorated.handleArg(invocation: $0, isReturn: $1, type: type) }
        }
    }

    /**
     Prevent a type fom being decorated
     */
    open class func makeUntracable(typesNamed: [String]) {
        for typeName in typesNamed {
            SwiftMeta.typeLookupCache[typeName] = nil
        }
    }

    /**
     Prepare function pointer that will trace an individual function.
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
     Returns a pointer to the type handlers dictionary - no longer used
     */
    @objc class var swiftTypeHandlers: UnsafeMutableRawPointer {
        return UnsafeMutableRawPointer(&Decorated.swiftTypeHandlers)
    }

    /**
     Swizze subclass that decorates signature with argument/return values
     */
    open class Decorated: Swizzle {

        /**
         Basic Swift argument type detector
         */
        static let swiftArgumentTypeParser =
            NSRegularExpression(regexp: "(?:[:,] |(?<![<(,])\\()([^:,)<]+(?:<.+?>)?)(?=[,)])|\\.setter : (.+)$")

        /**
         Very basic return valuue type detector
         */
        static let swiftReturnValueTypeParser =
            NSRegularExpression(regexp: " -> (.+?)( in conformance .+)?$")

        /**
         Cache of positions in signature of arguments
         */
        lazy var argTypeRanges: [Range<String.Index>] = {
            return ranges(in: signature, parser: Decorated.swiftArgumentTypeParser)
        }()

        /**
         Ranges of argument/return typs in signature. There's a lot going on here..
         */
        open func ranges(in signature: String, parser: NSRegularExpression) -> [Range<String.Index>] {
            let parsingArguments = parser === Decorated.swiftArgumentTypeParser
            let start = parsingArguments ?
                signature.index(of: .start+1 + .first(of: "(")) ??
                    signature.startIndex :
                signature.index(of: .last(of: " -> ")) ?? signature.startIndex
            let end = parsingArguments ?
                signature.index(of: .first(of: " -> ")) ?? signature.endIndex :
                    signature.endIndex
            var matches = parser.matches(in: signature,
                    range: NSRange(start ..< end, in: signature)).compactMap {
                Range($0.range(at: 1), in: signature) ??
                Range($0.range(at: 2), in: signature)
            }
            if parsingArguments {
                // filter out any types detected in closure arguments
                matches = matches.filter {
                    !signature[start+1..<$0.lowerBound].contains("(")
                }
            }
            return matches
        }

        /**
         substitute argument values into signature on method entry
         */
        open override func entryDecorate(stack: inout EntryStack) -> String {
            let invocation = self.invocation()!
            return objcMethod != nil ?
                objcDecorate(signature: nil, invocation: invocation) :
                swiftDecorate(signature: signature, invocation: invocation,
                              parser: Decorated.swiftArgumentTypeParser)
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
                              parser: Decorated.swiftReturnValueTypeParser)
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
            let isReturn = !(parser === Decorated.swiftArgumentTypeParser)
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
                } else if typeLookup || type.hasPrefix("Swift"),
                      let anyType = SwiftMeta.lookupType(named: type,
                                               exclude: lookupExclusionRegexp) {
                    value = Decorated.handleArg(invocation: invocation,
                                            isReturn: isReturn, type: anyType)
                } else if NSClassFromString(type) != nil {
                    value = Decorated.handleArg(invocation: invocation,
                                                isReturn: isReturn,
                                                type: AnyObject?.self)
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
         Generic argument handler given an invocation and the concrete type
         */
        public static func handleArg(invocation: Invocation,
                                     isReturn: Bool, type: Any.Type) -> String? {
            let slot: Int
            let maxSlots: Int
            var argPointer: UnsafeRawPointer
            var slotsRequired = (SwiftMeta.sizeof(anyType: type) +
                MemoryLayout<intptr_t>.size - 1) /
                MemoryLayout<intptr_t>.size
            let typePtr = unsafeBitCast(type, to: UnsafeRawPointer.self)

            if type is SwiftTraceFloatArg.Type ||
                SwiftMeta.structsAllFloats.contains(typePtr) {
                slot = invocation.floatArgumentOffset
                maxSlots = isReturn ?
                    ExitStack.returnRegs : EntryStack.maxFloatSlots
                argPointer = UnsafeRawPointer((isReturn ?
                    withUnsafePointer(to:
                    &invocation.exitStack.pointee.floatReturn1) {$0} :
                    withUnsafePointer(to:
                    &invocation.entryStack.pointee.floatArg1) {$0})
                    .advanced(by: slot))
                invocation.floatArgumentOffset += slotsRequired
            } else if slotsRequired > maxIntegerArgumentSlots && !isReturn {
                return nil
            } else {
                if !isReturn, type == Any.self || type == Any?.self,
                    invocation.swizzle.signature.contains("er.accept(fieldEntry: ") {
                    // Not sure what's going on here. Problems with two methods:
                    // Apollo.GraphQLSelectionSetMapper.accept(fieldEntry:
                    // Apollo.GraphQLResultNormalizer.accept(fieldEntry:
                    invocation.intArgumentOffset += 1
                }
                slot = invocation.intArgumentOffset
                maxSlots = isReturn ?
                    ExitStack.returnRegs : EntryStack.maxIntSlots
                argPointer = UnsafeRawPointer((isReturn ?
                    withUnsafePointer(to:
                    &invocation.exitStack.pointee.intReturn1) {$0} :
                    withUnsafePointer(to:
                    &invocation.entryStack.pointee.intArg1) {$0})
                    .advanced(by: slot))
                if SwiftMeta.structsPassedByReference.contains(typePtr) {
                    argPointer = argPointer.load(as: UnsafeRawPointer.self)
                    slotsRequired = 1
                }
                invocation.intArgumentOffset = slot + slotsRequired
            }

            if isReturn, slotsRequired > ExitStack.returnRegs ||
                SwiftMeta.structsPassedByReference.contains(typePtr),
                let structPtr = invocation.structReturn {
                argPointer = UnsafeRawPointer(structPtr)
            } else if slot + slotsRequired > maxSlots {
                return nil
            }

            withUnsafeMutablePointer(to: &invocation.arguments) {
                SwiftMeta.thunkToGeneric(funcPtr: appenderFptr,
                                         valuePtr: argPointer,
                                         outPtr: $0, type: type)
            }

            var out = ""
            describe(argPointer, type: type, out: &out)
            return out
        }

        static func describe(_ argPointer: UnsafeRawPointer,
                             type: Any.Type, out: inout String) {
            if type == AnyObject?.self {
                if let id = argPointer.load(as: AnyObject?.self) {
                    if let cls = object_getClass(id), cls.isSubclass(of: NSProxy.class()) {
                        out += identify(id: id)
                    } else {
                        let thread = ThreadLocal.current()
                        let describing = thread.describing
                        defer { thread.describing = describing }
                        thread.describing = true
                        if id.isKind(of: NSString.self) {
                            out += "@\"\(id)\""
                        } else {
                            out += describing ? identify(id: id) : "\(id)"
                        }
                    }
                } else {
                    out += "nil"
                }
            } else if type == UnsafePointer<UInt8>?.self {
                if let str = argPointer.load(as: UnsafePointer<UInt8>?.self) {
                    out += "\"\(String(cString: str))\""
                } else {
                    out += "NULL"
                }
            } else if type == UnsafeRawPointer.self {
                out += "0x"+String(argPointer.load(as: uintptr_t.self), radix: 16)
            } else if type == Selector.self {
                let SEL = argPointer.load(as: Selector.self)
                out += "@selector(\(NSStringFromSelector(SEL)))"
            } else if type == String.self {
                out += "\"\(argPointer.load(as: String.self))\""
            } else if type == Bool.self {
                out += argPointer.load(as: Bool.self) ? "true" : "false"
            } else if let optionalType = type as? OptionalTyping.Type {
                optionalType.describe(optionalPtr: argPointer, out: &out)
            } else {
                SwiftMeta.thunkToGeneric(funcPtr: describerFptr,
                                         valuePtr: argPointer,
                                         outPtr: &out, type: type)
            }
        }
    }
}
