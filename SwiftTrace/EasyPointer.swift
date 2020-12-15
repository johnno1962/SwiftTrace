//
//  EasyPointer.swift
//  EasyPointer
//
//  Created by John Holdsworth on 29/10/2020.
//  Copyright © 2020 John Holdsworth. All rights reserved.
//
//  Pragmatic extensions to unify conversions between various pointer types.
//
//  You must watch this video for context on why this may be a very bad idea:
//
//  https://developer.apple.com/videos/play/wwdc2020/10167/
//
//  Repo: https://github.com/johnno1962/EasyPointer.git
//
//  $Id: //depot/EasyPointer/Sources/EasyPointer/EasyPointer.swift#6 $
//

public func autoBitCast<IN,OUT>(_ x: IN) -> OUT {
    return unsafeBitCast(x, to: OUT.self)
}

extension UnsafePointer {
    public init<IN>(cast: UnsafePointer<IN>) {
        self = cast.withMemoryRebound(to: Pointee.self, capacity: 1) { $0 }
    }
    public init<IN>(cast: UnsafeMutablePointer<IN>) {
        self = autoBitCast(cast)
    }
    public init(cast: UnsafeMutableRawPointer) {
        self = autoBitCast(cast)
    }
    public init(cast: UnsafeRawPointer) {
        self = cast.bindMemory(to: Pointee.self, capacity: 1)
    }
    public init(cast: OpaquePointer) {
        self = autoBitCast(cast)
    }

    // It's handy to be able to compare Mutable and non-Mutable pointers
    public static func == (lhs: UnsafePointer,
                           rhs: UnsafeMutablePointer<Pointee>) -> Bool {
        return lhs == UnsafePointer(cast: rhs)
    }
    public static func == (lhs: UnsafeMutablePointer<Pointee>,
                           rhs: UnsafePointer) -> Bool {
        return UnsafePointer(cast: lhs) == lhs
    }
    public static func < (lhs: UnsafePointer,
                          rhs: UnsafeMutablePointer<Pointee>) -> Bool {
        return lhs == UnsafePointer(cast: rhs)
    }
    public static func < (lhs: UnsafeMutablePointer<Pointee>,
                          rhs: UnsafePointer) -> Bool {
        return UnsafePointer(cast: lhs) < lhs
    }
}

extension UnsafeMutablePointer {
    public init<IN>(cast: UnsafeMutablePointer<IN>) {
        self = cast.withMemoryRebound(to: Pointee.self, capacity: 1) { $0 }
    }
    public init(mutating cast: UnsafeRawPointer) {
        self = autoBitCast(cast)
    }
    public init(cast: UnsafeMutableRawPointer) {
        self = cast.bindMemory(to: Pointee.self, capacity: 1)
    }
    public init(cast: OpaquePointer) {
        self = autoBitCast(cast)
    }
}
