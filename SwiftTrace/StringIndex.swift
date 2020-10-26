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
//  $Id: //depot/SwiftTrace/SwiftTrace/StringIndex.swift#5 $
//

// Basic operators to offset String.Index when used in a subscript
public func + (index: String.Index, offset: Int) -> String.OffsetIndex {
    return .indexOffset(index: index, offset: offset)
}
public func - (index: String.Index, offset: Int) -> String.OffsetIndex {
    return index + -offset
}

extension String {

    /// Represents an index to be offset
    public enum OffsetIndex: Comparable {
        case indexOffset(index: Index, offset: Int),
             start, startOffset(offset: Int), end, endOffset(offset: Int),
             first(of: Character), firstOffset(of: Character, offset: Int),
             last(of: Character), lastOffset(of: Character, offset: Int)

        public func index<S: StringProtocol>(in string: S) -> String.Index {
            switch self {
            case .indexOffset(let index, let offset):
                return string.index(index, offsetBy: offset)
            case .start:
                return string.startIndex
            case .startOffset(let offset):
                return string.index(string.startIndex, offsetBy: offset)
            case .end:
                return string.endIndex
            case .endOffset(let offset):
                return string.index(string.endIndex, offsetBy: offset)
            case .first(of: let c):
                guard let first = string.firstIndex(of: c) else {
                    fatalError("Unable to locate '\(c)' in: '\(string)'")
                }
                return first
            case .firstOffset(of: let c, offset: let offset):
                guard let first = string.firstIndex(of: c) else {
                    fatalError("Unable to locate '\(c)' in: '\(string)'")
                }
                return string.index(first, offsetBy: offset)
            case .last(of: let c):
                guard let last = string.lastIndex(of: c) else {
                    fatalError("Unable to locate '\(c)' in: '\(string)'")
                }
                return last
            case .lastOffset(of: let c, offset: let offset):
                guard let last = string.lastIndex(of: c) else {
                    fatalError("Unable to locate '\(c)' in: '\(string)'")
                }
                return string.index(last, offsetBy: offset)
            }
        }

        // Chaining offsets in expressions
        public static func + (index: OffsetIndex, offset: Int) -> OffsetIndex {
            switch index {
            case .indexOffset(let index, let offset0):
                return .indexOffset(index: index, offset: offset0 + offset)
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
                return .firstOffset(of: c, offset: offset)
            case .lastOffset(of: let c, offset: let offset0):
                return .firstOffset(of: c, offset: offset0 + offset)
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
    public typealias OISubstring = String // Can be Substring

    // Subscripts on StringProtocol for OffsetIndex type
    public subscript (offset: OffsetIndex) -> Character {
        get {
            return self[offset.index(in: self)]
        }
        set (newValue) {
            self[offset ..< offset+1] = OISubstring(String(newValue))
        }
    }

    // lhs ..< rhs operator
    public subscript (range: Range<OffsetIndex>) -> OISubstring {
        get {
            let from = range.lowerBound, to = range.upperBound
            return OISubstring(self[from.index(in: self) ..<
                                    to.index(in: self)])
        }
        set (newValue) {
            let before = self[..<range.lowerBound]
            let after = self[range.upperBound...]
            self = Self(String(before) + String(newValue) + String(after))!
        }
    }
    // ..<rhs operator
    public subscript (range: PartialRangeUpTo<OffsetIndex>) -> OISubstring {
        get {
            return self[.start ..< range.upperBound]
        }
        set (newValue) {
            self[.start ..< range.upperBound] = newValue
        }
    }
    // lhs... operator
    public subscript (range: PartialRangeFrom<OffsetIndex>) -> OISubstring {
        get {
            return self[range.lowerBound ..< .end]
        }
        set (newValue) {
            self[range.lowerBound ..< .end] = newValue
        }
    }

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
