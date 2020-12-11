//
//  SwiftMeta.swift
//  SwiftTwaceApp
//
//  Created by John Holdsworth on 20/04/2020.
//  Copyright © 2020 John Holdsworth. All rights reserved.
//
//  Repo: https://github.com/johnno1962/SwiftTrace
//  $Id: //depot/SwiftTrace/SwiftTrace/SwiftMeta.swift#28 $
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
                    outPtr: UnsafeMutableRawPointer, type: Any.Type,
                    witness: UnsafeRawPointer? = nil)

/// generic function to find the Optional type for a wrapped type
public func getOptionalType<Type>(value: Type, out: inout Any.Type?) {
    out = Optional<Type>.self
}

/// generic function to find the Array type for an element type
public func getArrayType<Type>(value: Type, out: inout Any.Type?) {
    out = Array<Type>.self
}

/// generic function to find the ArraySlice slice type for an element type
public func getArraySliceType<Type>(value: Type, out: inout Any.Type?) {
    out = ArraySlice<Type>.self
}

/// generic function to find the Dictionary with String key for an element type
public func getDictionaryType<Type>(value: Type, out: inout Any.Type?) {
    out = Dictionary<String, Type>.self
}

// generic function to find the Set type for a Hashable wrapped type
public func getSetType<Type: Hashable>(value: Type, out: inout Any.Type?) {
    out = Set<Type>.self
}

public class SwiftMeta {

    /**
     Definitions related to auto-tracability of types
     */
    public static let modulePrefix =
        mangle(_typeName(SwiftMeta.self).components(separatedBy: ".")[0])
    static let RTLD_DEFAULT = UnsafeMutableRawPointer(bitPattern: -2)
    static func mangle(_ name: String) -> String {
        return "\(name.utf8.count)\(name)"
    }

    /**
     Find pointer for function processing type as generic
     */
    public static func bindGeneric(name: String, owner: String = modulePrefix,
                                   args: String = genericArgumentMangling)
                                                -> UnsafeMutableRawPointer {
        let symbol = "$s\(owner)\(mangle(name))\(args)"
        guard let genericFunctionPtr = dlsym(RTLD_DEFAULT, symbol) else {
            fatalError("Could lot locate generic function for symbol \(symbol)")
        }
        return genericFunctionPtr
    }

    /**
     Generic thunks that can be used to convert a type into the Optional/Array/Set for that type
     */
    public static let genericArgument = "5value3outyx"
    public static let returnAnyType = "_ypXpSgztlF"
    public static let genericArgumentMangling = genericArgument+returnAnyType

    static var getSetTypeFptr = bindGeneric(name: "getSetType",
                                        args: genericArgument+"_ypXpSgztSHRzlF")

    /// Handled compund types
    public static var wrapperHandlers = [
        "Swift.Optional<": bindGeneric(name: "getOptionalType"),
        "Swift.Array<": bindGeneric(name: "getArrayType"),
        "Swift.ArraySlice<": bindGeneric(name: "getArraySliceType"),
        "Swift.Dictionary<Swift.String, ": bindGeneric(name: "getDictionaryType"),
    ]

    public static var nameAbbreviations = [
        "Swift": "s"
    ]

    public static var typeLookupCache: [String: Any.Type?] = [
        // These types have non-standard manglings
        "Swift.String": String.self,
        "Swift.Double": Double.self,
        "Swift.Float": Float.self,
    ]
    static var typeLookupCacheLock = OS_SPINLOCK_INIT
    
    /**
     Best effort recovery of type from a qualified name
     */
    public static func lookupType(named: String,
                             exclude: NSRegularExpression? = nil) -> Any.Type? {
        OSSpinLockLock(&typeLookupCacheLock)
        defer { OSSpinLockUnlock(&typeLookupCacheLock) }
        var out: Any.Type?
        if let type = typeLookupCache[named] {
            return type
        }
        
        for (prefix, handler) in wrapperHandlers {
            OSSpinLockUnlock(&typeLookupCacheLock)
            if named.hasPrefix(prefix),
                let wrapped = named[safe: .start+prefix.count ..< .end-1],
                let wrappedType = SwiftMeta.lookupType(named: wrapped,
                                                       exclude: exclude) {
                thunkToGeneric(funcPtr: handler, valuePtr: nil,
                               outPtr: &out, type: wrappedType)
                break
            }
            OSSpinLockLock(&typeLookupCacheLock)
        }

        if out == nil && named.hasPrefix("Swift.Set<"),
            let element = named[safe: .start+10 ..< .end-1] {
            OSSpinLockUnlock(&typeLookupCacheLock)
            if let elementType = SwiftMeta.lookupType(named: element,
                                                      exclude: exclude),
                let hashableWitness = getHashableWitnessTable(for: elementType) {
                thunkToGeneric(funcPtr: getSetTypeFptr, valuePtr: nil,
                               outPtr: &out, type: elementType,
                               witness: hashableWitness)
            }
            OSSpinLockLock(&typeLookupCacheLock)
        } else if out == nil && exclude?.matches(named) != true {
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
        typeLookupCache[named] = out
        return out
    }

    public static func mangledName(for type: Any.Type) -> String? {
        var info = Dl_info()
        if dladdr(autoBitCast(type), &info) != 0,
            let metaTypeSymbol = info.dli_sname {
            return String(cString: metaTypeSymbol)[safe: ..<(.end-1)]
        }
        return nil
    }

    static func getHashableWitnessTable(for elementType: Any.Type)
        -> UnsafeRawPointer? {
        var hashableWitnessTable: UnsafeRawPointer?
        if let mangledName = mangledName(for: elementType) {
            if let theEasyWay = dlsym(RTLD_DEFAULT, mangledName+"SHsWP") {
                hashableWitnessTable = UnsafeRawPointer(theEasyWay)
            } else {
                let witnessSuffix = "ACSHAAWl"
                (mangledName + witnessSuffix).withCString { getWitnessSymbol in
                    typealias GetWitness = @convention(c) () -> UnsafeRawPointer
                    let bundlePath = Bundle.main.executablePath!
                    findSwiftSymbols(bundlePath, witnessSuffix) {
                        (address, symbol, _, _) in
                        if strcmp(symbol, getWitnessSymbol) == 0,
                            let witnessFptr: GetWitness = autoBitCast(address) {
                            hashableWitnessTable = witnessFptr()
                        }
                    }
                }
            }
        }
        return hashableWitnessTable
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
