//
//  SwiftMeta.swift
//  SwiftTwaceApp
//
//  Created by John Holdsworth on 20/04/2020.
//  Copyright © 2020 John Holdsworth. All rights reserved.
//
//  Repo: https://github.com/johnno1962/SwiftTrace
//  $Id: //depot/SwiftTrace/SwiftTrace/SwiftMeta.swift#11 $
//
//  Requires https://github.com/johnno1962/StringIndex.git
//
//  Assumptions made about Swift MetaData
//  =====================================
//

import Foundation

// Taken from stdlib, not public Swift3+
@_silgen_name("swift_demangle")
private
func _stdlib_demangleImpl(
    _ mangledName: UnsafePointer<CChar>?,
    mangledNameLength: UInt,
    outputBuffer: UnsafeMutablePointer<UInt8>?,
    outputBufferSize: UnsafeMutablePointer<UInt>?,
    flags: UInt32
    ) -> UnsafeMutablePointer<CChar>?

/**
 Shenaniggans to be able to decorate any type linked into an app. Requires the following C function:
 
 typedef void (*SignatureOfFunctionTakingGenericValue)(const void *valuePtr,
                                         void *outPtr, const void *metaType);

 /// This can be used to call a Swift function with a generic value
 /// argument when you have a pointer to the value and its type.
 /// See: https://www.youtube.com/watch?v=ctS8FzqcRug
 void thunkToGeneric(SignatureOfFunctionTakingGenericValue genericFunction,
                     const void *valuePtr, const void *metaType, void *outPtr) {
     genericFunction(valuePtr, outPtr, metaType);
 }
 */
@_silgen_name("thunkToGeneric")
func thunkToGeneric(funcPtr: UnsafeRawPointer, valuePtr: UnsafeRawPointer?,
                    type: Any.Type, outPtr: UnsafeMutableRawPointer)

/// generic function to find the optional type for a wrapped type
public func getOptionalType<Type>(value: Optional<Type>, outPtr: UnsafeMutableRawPointer) {
    outPtr.assumingMemoryBound(to: Any.Type?.self).pointee = Optional<Type>.self
}

/// generic function to find the array type for an element type
public func getArrayType<Type>(value: Array<Type>, outPtr: UnsafeMutableRawPointer) {
    outPtr.assumingMemoryBound(to: Any.Type?.self).pointee = Array<Type>.self
}

public class SwiftMeta {

    /**
     Definitions related to auto-tracability of types
     */
    public static let module =
        mangle(_typeName(SwiftMeta.self).components(separatedBy: ".")[0])
    public static let argumentMangling = "5value6outPtryx_SvtlF"
    static func mangle(_ name: String) -> String {
        return "\(name.utf16.count)\(name)"
    }

    /**
     Find pointer for function processing type as generic
     */
    public static func bindGeneric(name: String, owner: String = module,
                   args: String = argumentMangling) -> UnsafeMutableRawPointer {
        let symbol = "$s\(owner)\(mangle(name))\(args)"
        let RTLD_DEFAULT = UnsafeMutableRawPointer(bitPattern: -2)
        guard let genericFunctionPtr = dlsym(RTLD_DEFAULT, symbol) else {
            fatalError("Could lot locate generic function for symbol \(symbol)")
        }
        return genericFunctionPtr
    }

    /**
     Gneric thunks that can be used to convert a type into the Array/Optional for that type
     */
    static var getArrayTypeFptr = bindGeneric(name: "getArrayType",
                                              args: "5value6outPtrySayxG_SvtlF")
    static var getOptionalTypeFptr = bindGeneric(name: "getOptionalType",
                                                 args: "5value6outPtryxSg_SvtlF")

    public static var nameAbbreviations = [
        "Swift": "s"
    ]

    public static var typeCache: [String: Any.Type?] = [
        "Swift.String": String.self,
        "Swift.Double": Double.self,
        "Swift.Float": Float.self,

        // These types are known to cause problems.
        // Pre-populating a nil entry prevents them
        // being lookuped up using getType(named:).
//        "Foundation.URL": nil,
//        "Foundation.UUID": nil,
//        "Foundation.IndexPath": nil,
////        "SwiftUI.StrokeStyle": nil,
////        "SwiftUI.CoordinateSpace": nil,
//        "SwiftUI.LocalizedStringKey.StringInterpolation": nil,
//        "SwiftUI.Color.RGBColorSpace": nil,
//        "SwiftUI.Image.ResizingMode": nil,
//        "SwiftUI.NavigationBarItem.TitleDisplayMode": nil,
//        "SwiftUI.RoundedRectangle": nil,
//        "SwiftUI.ToolbarItemPlacement": nil,
//        "SwiftUI.KeyEquivalent": nil,
//        "SwiftUI.Text.DateStyle": nil,
//        "SwiftUI.RoundedCornerStyle": nil,
//        "SwiftUI.PopoverAttachmentAnchor": nil,
//        "SwiftUI.SwitchToggleStyle": nil,

        // Also encountered these
//        "Kingfisher.Source": nil,
//        "Backend.Endpoint": nil,
//        "Backend.Video": nil,

        // This is a cheat as this struct
        // contains a mix of Float/String
//        "MovieSwift.ImageData": nil,
//        "Unwrap.RearrangeTheLinesPractice": nil,
//        "Curiosity.PostDetailToolbar": nil,
//        "Kingfisher.ImageLoadingResult": nil,
    ]
    static var typeCacheLock = OS_SPINLOCK_INIT

    /**
     Best effort recovery of type from a qualified name
     */
    public static func getType(named: String,
                               exclude: NSRegularExpression? = nil) -> Any.Type? {
        OSSpinLockLock(&typeCacheLock)
        defer { OSSpinLockUnlock(&typeCacheLock) }
        var out: Any.Type?
        if let type = typeCache[named] {
            return type
        } else if named.hasPrefix("Swift.Optional<"),
            let wrapped = named[safe: .start+15 ..< .end-1] {
            OSSpinLockUnlock(&typeCacheLock)
            if let wrappedType = SwiftMeta.getType(named: wrapped,
                                                   exclude: exclude) {
                thunkToGeneric(funcPtr: getOptionalTypeFptr,
                               valuePtr: nil,
                               type: wrappedType, outPtr: &out)
            }
            OSSpinLockLock(&typeCacheLock)
        } else if named.hasPrefix("Swift.Array<"),
            let element = named[safe: .start+12 ..< .end-1] {
            OSSpinLockUnlock(&typeCacheLock)
            if let elementType = SwiftMeta.getType(named: element,
                                                   exclude: exclude) {
                thunkToGeneric(funcPtr: getArrayTypeFptr,
                               valuePtr: nil,
                               type: elementType, outPtr: &out)
            }
            OSSpinLockLock(&typeCacheLock)
        } else if exclude?.matches(named) != true {
            var mangled = ""
            var first = true
            for name in named.components(separatedBy: ".") {
                mangled += nameAbbreviations[name] ?? mangle(name)
                out = nil
                if !first {
                    if let type = _typeByName(mangled+"C") {
                        mangled += "C" // class type
                        out = type
                    } else if let type = _typeByName(mangled+"V") {
                        mangled += "V" // value type
                        out = type
                    } else if let type = _typeByName(mangled+"O") {
                        mangled += "O" // enum type?
                        out = type
                    } else {
                        break
                    }
                }
                first = false
            }
        }
        typeCache[named] = out
        return out
    }

    /** pointer to a function implementing a Swift method */
    public typealias SIMP = @convention(c) () -> Void

    /**
     Value that crops up as a ClassSize since 5.2 runtime
     */
    static let invalidClassSize = 0x50AF17B0

    /**
     Layout of a class instance. Needs to be kept in sync with ~swift/include/swift/Runtime/Metadata.h
     */
    public struct TargetClassMetadata {

        let MetaClass: uintptr_t = 0, SuperClass: uintptr_t = 0
        let CacheData1: uintptr_t = 0, CacheData2: uintptr_t = 0

        public let Data: uintptr_t = 0

        /// Swift-specific class flags.
        public let Flags: UInt32 = 0

        /// The address point of instances of this type.
        public let InstanceAddressPoint: UInt32 = 0

        /// The required size of instances of this type.
        /// 'InstanceAddressPoint' bytes go before the address point;
        /// 'InstanceSize - InstanceAddressPoint' bytes go after it.
        public let InstanceSize: UInt32 = 0

        /// The alignment mask of the address point of instances of this type.
        public let InstanceAlignMask: UInt16 = 0

        /// Reserved for runtime use.
        public let Reserved: UInt16 = 0

        /// The total size of the class object, including prefix and suffix
        /// extents.
        public let ClassSize: UInt32 = 0

        /// The offset of the address point within the class object.
        public let ClassAddressPoint: UInt32 = 0

        /// An out-of-line Swift-specific description of the type, or null
        /// if this is an artificial subclass.  We currently provide no
        /// supported mechanism for making a non-artificial subclass
        /// dynamically.
        public let Description: uintptr_t = 0

        /// A function for destroying instance variables, used to clean up
        /// after an early return from a constructor.
        public var IVarDestroyer: SIMP? = nil

        // After this come the class members, laid out as follows:
        //   - class members for the superclass (recursively)
        //   - metadata reference for the parent, if applicable
        //   - generic parameters for this class
        //   - class variables (if we choose to support these)
        //   - "tabulated" virtual methods

    }

    /**
     Convert a executable symbol name "mangled" according to Swift's
     conventions into a human readable Swift language form
     */
    @objc open class func demangle(symbol: UnsafePointer<Int8>) -> String? {
        if let demangledNamePtr = _stdlib_demangleImpl(
            symbol, mangledNameLength: UInt(strlen(symbol)),
            outputBuffer: nil, outputBufferSize: nil, flags: 0) {
            let demangledName = String(cString: demangledNamePtr)
            free(demangledNamePtr)
            return demangledName
        }
        return nil
    }
}

/**
 Convenience extension to trap regex errors and report them
 */
extension NSRegularExpression {

    convenience init(regexp: String) {
        do {
            try self.init(pattern: regexp)
        }
        catch let error as NSError {
            fatalError("Invalid regexp: \(regexp): \(error.localizedDescription)")
        }
    }

    func matches(_ string: String) -> Bool {
        return rangeOfFirstMatch(in: string,
            range: NSRange(string.startIndex ..< string.endIndex,
                           in: string)).location != NSNotFound
    }
}
