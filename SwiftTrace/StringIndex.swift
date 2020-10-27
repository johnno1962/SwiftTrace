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
//  $Id: //depot/SwiftTrace/SwiftTrace/StringIndex.swift#7 $
//

// Basic operators to offset String.Index when used in a subscript
public func + (index: String.Index, offset: Int) -> String.OffsetIndex {
    return .offsetIndex(index: index, offset: offset)
}
public func - (index: String.Index, offset: Int) -> String.OffsetIndex {
    return index + -offset
}

extension String {

    /// Represents an index to be offset
    public enum OffsetIndex: Comparable {
        case offsetIndex(index: Index, offset: Int),
             start, startOffset(offset: Int), end, endOffset(offset: Int),
             first(of: Character), firstOffset(of: Character, offset: Int),
             last(of: Character), lastOffset(of: Character, offset: Int)

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
            if offset == 0 {
                return out
            }
            return nil
        }

        public func index<S: StringProtocol>(in string: S) -> String.Index? {
            switch self {
            case .offsetIndex(let index, let offset):
                return safeIndex(index, offsetBy: offset, in: string)
            case .start:
                return string.startIndex
            case .startOffset(let offset):
                return safeIndex(string.startIndex, offsetBy: offset, in: string)
            case .end:
                return string.endIndex
            case .endOffset(let offset):
                return safeIndex(string.endIndex, offsetBy: offset, in: string)
            case .first(of: let c):
                guard let first = string.firstIndex(of: c) else { return nil }
                return first
            case .firstOffset(of: let c, offset: let offset):
                guard let first = string.firstIndex(of: c) else { return nil }
                return safeIndex(first, offsetBy: offset, in: string)
            case .last(of: let c):
                guard let last = string.lastIndex(of: c) else { return nil }
                return last
            case .lastOffset(of: let c, offset: let offset):
                guard let last = string.lastIndex(of: c) else { return nil }
                return safeIndex(last, offsetBy: offset, in: string)
            }
        }

        // Chaining offsets in expressions
        public static func + (index: OffsetIndex, offset: Int) -> OffsetIndex {
            switch index {
            case .offsetIndex(let index, let offset0):
                return .offsetIndex(index: index, offset: offset0 + offset)
            case .start:
                return .startOffset(offset: offset)
            case .startOffset(let offset0):
                return .startOffset(offset: offset0 + offset)
            case .end:
                return .endOffset(offset: offset)
            case .endOffset(let offset0):
                return .endOffset(offset: offset0 + offset)
            case .first(of: let c):
                return .firstOffset(of: c, offset: offset)
            case .firstOffset(of: let c, offset: let offset0):
                return .firstOffset(of: c, offset: offset0 + offset)
            case .last(of: let c):
                return .lastOffset(of: c, offset: offset)
            case .lastOffset(of: let c, offset: let offset0):
                return .lastOffset(of: c, offset: offset0 + offset)
            }
        }
        public static func - (index: OffsetIndex, offset: Int) -> OffsetIndex {
            return index + -offset
        }

        // Mixed String.Index and OffsetIndex in range
        public static func ..< (lhs: OffsetIndex, rhs: Index) -> Range<OffsetIndex> {
            return lhs ..< rhs + 0
        }
        public static func ..< (lhs: Index, rhs: OffsetIndex) -> Range<OffsetIndex> {
            return lhs + 0 ..< rhs
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

    // Subscripts on StringProtocol for OffsetIndex type
    public subscript (offset: OffsetIndex) -> Character {
        get {
            guard let result = self[safe: offset] else {
                fatalError("Invalid offset index \(offset), \(#function)")
            }
            return result
        }
        set (newValue) {
            guard let start = offset.index(in: self) else {
                fatalError("Invalid offset index \(offset), \(#function)")
            }
            let end = start + (start < endIndex ? 1 : 0)
            self[start ..< end] = OISubstring(String(newValue))
        }
    }

    // lhs ..< rhs operator
    public subscript (range: Range<OffsetIndex>) -> OISubstring {
        get {
            guard let result = self[safe: range] else {
                fatalError("Invalid offset range \(range.lowerBound) ..<  \(range.upperBound), \(#function)")
            }
            return result
        }
        set (newValue) {
            guard let from = range.lowerBound.index(in: self),
                let to = range.upperBound.index(in: self) else {
                fatalError("Invalid offset range \(range.lowerBound) ..<  \(range.upperBound), \(#function)")
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
        get {
            if let index = offset.index(in: self) {
                return self[index]
            } else {
                return nil
            }
        }
        set (newValue) { self[offset] = newValue! }
    }
    // lhs ..< rhs operator
    public subscript (safe range: Range<OffsetIndex>) -> OOISubstring {
        get {
            guard let from = range.lowerBound.index(in: self),
                let to = range.upperBound.index(in: self) else { return nil }
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
