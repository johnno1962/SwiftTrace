//
//  SwiftMeta.swift
//  SwiftTwaceApp
//
//  Created by John Holdsworth on 20/04/2020.
//  Copyright © 2020 John Holdsworth. All rights reserved.
//
//  Repo: https://github.com/johnno1962/SwiftTrace
//  $Id: //depot/SwiftTrace/SwiftTrace/SwiftMeta.swift#3 $
//
//  Assumptions made about Swift MetaData
//  =====================================
//

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

extension SwiftTrace {

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

        let Data: uintptr_t = 0

        /// Swift-specific class flags.
        let Flags: UInt32 = 0

        /// The address point of instances of this type.
        let InstanceAddressPoint: UInt32 = 0

        /// The required size of instances of this type.
        /// 'InstanceAddressPoint' bytes go before the address point;
        /// 'InstanceSize - InstanceAddressPoint' bytes go after it.
        let InstanceSize: UInt32 = 0

        /// The alignment mask of the address point of instances of this type.
        let InstanceAlignMask: UInt16 = 0

        /// Reserved for runtime use.
        let Reserved: UInt16 = 0

        /// The total size of the class object, including prefix and suffix
        /// extents.
        let ClassSize: UInt32 = 0

        /// The offset of the address point within the class object.
        let ClassAddressPoint: UInt32 = 0

        /// An out-of-line Swift-specific description of the type, or null
        /// if this is an artificial subclass.  We currently provide no
        /// supported mechanism for making a non-artificial subclass
        /// dynamically.
        let Description: uintptr_t = 0

        /// A function for destroying instance variables, used to clean up
        /// after an early return from a constructor.
        var IVarDestroyer: SIMP? = nil

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
