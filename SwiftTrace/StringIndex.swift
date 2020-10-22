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

// Basic operators to offset String.Index when used in a subscript
public func + (index: String.Index?, offset: Int) -> String.OffsetIndex {
    precondition(index != nil, "nil String.Index being offset by \(offset)")
    return String.OffsetIndex(index: index!, offset: offset)
}
public func - (index: String.Index?, offset: Int) -> String.OffsetIndex {
    return index + -offset
}

extension String {

    /// Represents an index to be offset
    public struct OffsetIndex: Comparable {
        let index: Index, offset: Int

        // Chaining offsets in expressions
        public static func + (index: OffsetIndex, offset: Int) -> OffsetIndex {
            return OffsetIndex(index: index.index, offset: index.offset + offset)
        }
        public static func - (index: OffsetIndex, offset: Int) -> OffsetIndex {
            return index + -offset
        }

        // Mixed String.Index and OffsetIndex in range
        public static func ..< (lhs: OffsetIndex, rhs: Index?) -> Range<OffsetIndex> {
            return lhs ..< rhs + 0
        }
        public static func ..< (lhs: Index?, rhs: OffsetIndex) -> Range<OffsetIndex> {
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

    // Subscripts on StringProtocol for OffsetIndex type
    public subscript (offset: OffsetIndex) -> Character {
        get {
            return self[index(offset.index, offsetBy: offset.offset)]
        }
        set (newValue) {
            self[offset ..< offset+1] = OISubstring(String(newValue))
        }
    }

    // lhs ..< rhs operator
    public subscript (range: Range<OffsetIndex>) -> OISubstring {
        get {
            let from = range.lowerBound, to = range.upperBound
            return OISubstring(self[index(from.index, offsetBy: from.offset) ..<
                                    index(to.index, offsetBy: to.offset)])
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
            return self[startIndex ..< range.upperBound]
        }
        set (newValue) {
            self[startIndex ..< range.upperBound] = newValue
        }
    }
    // lhs... operator
    public subscript (range: PartialRangeFrom<OffsetIndex>) -> OISubstring {
        get {
            return self[range.lowerBound ..< endIndex]
        }
        set (newValue) {
            self[range.lowerBound ..< endIndex] = newValue
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
