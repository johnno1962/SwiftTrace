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
//  $Id: //depot/StringIndex/Sources/StringIndex/StringIndex.swift#33 $
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
            let upper = string.index(of: range.upperBound),
            lower <= upper else {
            return nil
        }
        self = lower ..< upper
    }
}

extension NSRange {
    public init?<S: StringProtocol>(_ range: Range<String.OffsetIndex>, in string: S) {
        guard let lower = string.index(of: range.lowerBound),
            let upper = string.index(of: range.upperBound),
            lower <= upper else {
            return nil
        }
        self.init(lower ..< upper, in: string)
    }
}

extension String {

    /// Represents an index to be offset
    public indirect enum OffsetIndex: Comparable {
        case offsetIndex(index: Index?, offset: Int), start, end,
            first(of: String, regex: Bool = false, end: Bool = false),
            last(of: String, regex: Bool = false, end: Bool = false),
            either(_ index: OffsetIndex, or: OffsetIndex),
            // can chain either an OffsetIndex or an integer offset
            chained(previous: OffsetIndex, next: OffsetIndex?, offset: Int)

        // Chaining offsets in expressions
        public static func + (index: OffsetIndex, offset: Int) -> OffsetIndex {
            return .chained(previous: index, next: nil, offset: offset)
        }
        public static func - (index: OffsetIndex, offset: Int) -> OffsetIndex {
            return index + -offset
        }
        public static func + (index: OffsetIndex,
                              offset: OffsetIndex) -> OffsetIndex {
            return .chained(previous: index, next: offset, offset: 0)
        }

        /// Required by Comparable to check when creating ranges
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
    public func index(of offset: OffsetIndex, from: Index? = nil) -> Index? {
        switch offset {
        case .offsetIndex(let index, let offset):
            guard let index = index else { return nil }
            return safeIndex(index, offsetBy: offset)

        // Public interface
        case .start:
            return startIndex
        case .end:
            return endIndex
        case .first(let target, let regex, let end):
            return locate(target: target, from: from,
                          last: false, regex: regex, end: end)
        case .last(let target, let regex, let end):
            return locate(target: target, from: from,
                          last: true, regex: regex, end: end)
        case .either(let first, let second):
            return index(of: first) ?? index(of: second)

        case .chained(let previous, let next, let offset):
            guard let from = index(of: previous) else { return nil }
            return next != nil ? index(of: next!, from: from) :
                safeIndex(from, offsetBy: offset)
        }
    }

    /// nilable version of index(_ i: Self.Index, offsetBy: Int)
    public func safeIndex(_ from: Index, offsetBy: Int) -> Index? {
        var from = from, offset = offsetBy
        while offset < 0 && from > startIndex {
            from = index(before: from)
            offset += 1
        }
        while offset > 0 && from < endIndex {
            from = index(after: from)
            offset -= 1
        }
        return offset == 0 ? from : nil
    }

    public func locate(target: String, from: Index?,
                       last: Bool, regex: Bool, end: Bool) -> Index? {
        let bounds = last ?
            startIndex..<(from ?? endIndex) :
            (from ?? startIndex)..<endIndex
        if regex {
            do {
                let regex = try NSRegularExpression(pattern: target, options: [])
                let string = String(self)
                if let match = (last ? regex.matches(in: string,
                        range: NSRange(bounds, in: string)).last :
                    regex.firstMatch(in: string,
                        range: NSRange(bounds, in: string)))?.range {
                    if #available(OSX 10.15, iOS 13.0, tvOS 13.0, *) {
                        return Range(match, in: string).flatMap {
                            return end ? $0.upperBound : $0.lowerBound
                        }
                    } else {
                        // Fallback on earlier versions
                        let loc = end ? NSMaxRange(match) : match.location
                        return NSString(string: string).substring(to: loc).endIndex
                    }
                }
            } catch {
                fatalError("StringIndex: Invalid regular expression: \(error)")
            }
        } else if let match = range(of: target,
            options: last ? .backwards : [], range: bounds) {
            return end ? match.upperBound : match.lowerBound
        }
        return nil
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
                let to = index(of: range.upperBound),
                from <= to else { return nil }
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
