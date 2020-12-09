//
//  StringIndex.swift
//  StringIndex
//
//  Created by John Holdsworth on 25/10/2020.
//  Copyright © 2020 John Holdsworth. All rights reserved.
//
//  A few operators simplifying offsettting a String index
//
//  Repo: https://github.com/johnno1962/StringIndex.git
//
//  $Id: //depot/StringIndex/Sources/StringIndex/StringIndex.swift#19 $
//

import Foundation

// Basic operators to offset String.Index when used in a subscript
public func + (index: String.Index?, offset: Int) -> String.OffsetIndex {
    return .offsetIndex(index: index, offset: offset)
}
public func - (index: String.Index?, offset: Int) -> String.OffsetIndex {
    return index + -offset
}
public func + (index: String.Index?, offset: String.OffsetIndex)
    -> String.OffsetIndex {
    return .offsetIndex(index: index, offset: 0) + offset
}

// Mixed String.Index and OffsetIndex in range
public func ..< (lhs: String.OffsetIndex, rhs: String.Index?)
    -> Range<String.OffsetIndex> {
    return lhs ..< rhs+0
}
public func ..< (lhs: String.Index?, rhs: String.OffsetIndex)
    -> Range<String.OffsetIndex> {
    return lhs+0 ..< rhs
}

extension Range where Bound == String.Index {
    public init?<S: StringProtocol>(_ range: Range<String.OffsetIndex>, in string: S) {
        guard let lower = string.index(of: range.lowerBound),
            let upper = string.index(of: range.upperBound) else {
            return nil
        }
        self = lower ..< upper
    }
}

extension NSRange {
    public init?<S: StringProtocol>(_ range: Range<String.OffsetIndex>, in string: S) {
        guard let lower = string.index(of: range.lowerBound),
            let upper = string.index(of: range.upperBound) else {
            return nil
        }
        self.init(lower ..< upper, in: string)
    }
}

extension String {

    /// Represents an index to be offset
    public indirect enum OffsetIndex: Comparable {
        case offsetIndex(index: Index?, offset: Int),
             start, end, first(of: String), last(of: String),
             chainedOffset(previous: OffsetIndex, offset: Int),
             chained(previous: OffsetIndex, offset: OffsetIndex),
             either(_ index: OffsetIndex, or: OffsetIndex)

        func safeIndex<S: StringProtocol>(_ index: Index, offsetBy: Int,
                                          in string: S) -> Index? {
            var out = index
            var offset = offsetBy
            while offset < 0 && index > string.startIndex {
                out = string.index(before: out)
                offset += 1
            }
            while offset > 0 && index < string.endIndex {
                out = string.index(after: out)
                offset -= 1
            }
            return offset == 0 ? out : nil
        }

        public func index<S: StringProtocol>(from: Index? = nil, in string: S)
            -> String.Index? {
            switch self {
            case .offsetIndex(let index, let offset):
                guard let index = index else { return nil }
                return safeIndex(index, offsetBy: offset, in: string)
            case .start:
                return string.startIndex
            case .end:
                return string.endIndex
            case .first(of: let c):
                return string.range(of: c, range:
                    (from ?? string.startIndex)..<string.endIndex)?.lowerBound
            case .last(of: let c):
                return string.range(of: c, options: .backwards, range:
                    string.startIndex..<(from ?? string.endIndex))?.lowerBound
            case .chainedOffset(let previous, let offset):
                guard let last = previous.index(in: string) else { return nil }
                return safeIndex(last, offsetBy: offset, in: string)
            case .chained(let previous, let offset):
                guard let last = previous.index(in: string) else { return nil }
                return offset.index(from: last, in: string)
            case .either(let index, let or):
                return index.index(in: string) ?? or.index(in: string)
            }
        }

        // Chaining offsets in expressions
        public static func + (index: OffsetIndex, offset: Int) -> OffsetIndex {
            return .chainedOffset(previous: index, offset: offset)
        }
        public static func - (index: OffsetIndex, offset: Int) -> OffsetIndex {
            return index + -offset
        }
        public static func + (index: OffsetIndex,
                              offset: OffsetIndex) -> OffsetIndex {
            return .chained(previous: index, offset: offset)
        }

        /// Required by Comparable check when creating ranges
        public static func < (lhs: OffsetIndex, rhs: OffsetIndex) -> Bool {
            return false // slight cheat here as we don't know the string
        }
    }
}

extension StringProtocol {
    public typealias OffsetIndex = String.OffsetIndex
    public typealias OISubstring = String // Can/should? be Substring
    public typealias OOISubstring = OISubstring? // "safe:" prefixed subscripts

    /// realise index from OffsetIndex
    public func index(of: OffsetIndex) -> String.Index? {
        return of.index(in: self)
    }

    /// Subscripts on StringProtocol for OffsetIndex type
    public subscript (offset: OffsetIndex) -> Character {
        get {
            guard let result = self[safe: offset] else {
                fatalError("Invalid offset index \(offset), \(#function)")
            }
            return result
        }
        set (newValue) {
            guard let start = index(of: offset) else {
                fatalError("Invalid offset index \(offset), \(#function)")
            }
            // Assigning Chacater to endIndex is an append.
            let end = start + (start < endIndex ? 1 : 0)
            self[start ..< end] = OISubstring(String(newValue))
        }
    }

    // lhs ..< rhs operator
    public subscript (range: Range<OffsetIndex>) -> OISubstring {
        get {
            guard let result = self[safe: range] else {
                fatalError("Invalid range of offset index \(range), \(#function)")
            }
            return result
        }
        set (newValue) {
            guard let from = index(of: range.lowerBound),
                let to = index(of: range.upperBound) else {
                fatalError("Invalid range of offset index \(range), \(#function)")
            }
            let before = self[..<from], after = self[to...]
            self = Self(String(before) + String(newValue) + String(after))!
        }
    }
    // ..<rhs operator
    public subscript (range: PartialRangeUpTo<OffsetIndex>) -> OISubstring {
        get { return self[.start ..< range.upperBound] }
        set (newValue) { self[.start ..< range.upperBound] = newValue }
    }
    // lhs... operator
    public subscript (range: PartialRangeFrom<OffsetIndex>) -> OISubstring {
        get { return self[range.lowerBound ..< .end] }
        set (newValue) { self[range.lowerBound ..< .end] = newValue }
    }

    // =================================================================
    // "safe" nil returning subscripts on StringProtocol for OffsetIndex
    // from:  https://forums.swift.org/t/optional-safe-subscripting-for-arrays
    public subscript (safe offset: OffsetIndex) -> Character? {
        get { return index(of: offset).flatMap { self[$0] } }
        set (newValue) { self[offset] = newValue! }
    }
    // lhs ..< rhs operator
    public subscript (safe range: Range<OffsetIndex>) -> OOISubstring {
        get {
            guard let from = index(of: range.lowerBound),
                let to = index(of: range.upperBound) else { return nil }
            return OISubstring(self[from ..< to])
        }
        set (newValue) { self[range] = newValue! }
    }
    // ..<rhs operator
    public subscript (safe range: PartialRangeUpTo<OffsetIndex>) -> OOISubstring {
        get { return self[safe: .start ..< range.upperBound] }
        set (newValue) { self[range] = newValue! }
    }
    // lhs... operator
    public subscript (safe range: PartialRangeFrom<OffsetIndex>) -> OOISubstring {
        get { return self[safe: range.lowerBound ..< .end] }
        set (newValue) { self[range] = newValue! }
    }

    // =================================================================
    // Misc.
    public mutating func replaceSubrange<C>(_ bounds: Range<OffsetIndex>,
        with newElements: C) where C : Collection, C.Element == Character {
        self[bounds] = OISubstring(newElements)
    }
    public mutating func insert<S>(contentsOf newElements: S, at i: OffsetIndex)
        where S : Collection, S.Element == Character {
        replaceSubrange(i ..< i, with: newElements)
    }
    public mutating func insert(_ newElement: Character, at i: OffsetIndex) {
        insert(contentsOf: String(newElement), at: i)
    }
}
