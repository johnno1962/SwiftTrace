//
//  SwiftStats.swift
//  SwiftTrace
//
//  Created by John Holdsworth on 23/09/2020.
//  Copyright © 2020 John Holdsworth. All rights reserved.
//
//  $Id: //depot/SwiftTrace/SwiftTrace/SwiftStats.swift#2 $
//

import Foundation

extension SwiftTrace {

    func populate(elapsedTimes: inout [String: Double]) {
        previousSwiftTrace?.populate(elapsedTimes: &elapsedTimes)
        for (_, swizzle) in activeSwizzles {
            elapsedTimes[swizzle.signature] = swizzle.totalElapsed
        }
    }

    /**
     Accumulated amount of time spent in each swizzled method.
     */
    public static func elapsedTimes() -> [String: Double] {
        var elapsedTimes = [String: Double]()
        lastSwiftTrace.populate(elapsedTimes: &elapsedTimes)
        return elapsedTimes
    }

    /**
     Sorted descending accumulated amount of time spent in each swizzled method.
     */
    public static func sortedElapsedTimes(onlyFirst: Int? = nil) ->  [(key: String, value: TimeInterval)] {
        let sorted = elapsedTimes().sorted { $1.value < $0.value }
        return onlyFirst != nil && onlyFirst! < sorted.count ?
            Array(sorted[0 ... onlyFirst!]) : sorted
    }

    func populate(invocationCounts: inout [String: Int]) {
        previousSwiftTrace?.populate(invocationCounts: &invocationCounts)
        for (_, swizzle) in activeSwizzles {
            invocationCounts[swizzle.signature] = swizzle.invocationCount
        }
    }

    /**
     Numbers of times each swizzled method has been invoked.
     */
    public static func invocationCounts() -> [String: Int] {
        var invocationCounts = [String: Int]()
        lastSwiftTrace.populate(invocationCounts: &invocationCounts)
        return invocationCounts
    }

    /**
     Sorted descending numbers of times each swizzled method has been invoked.
     */
    public static func sortedInvocationCounts(onlyFirst: Int? = nil) ->  [(key: String, value: Int)] {
        let sorted = invocationCounts().sorted { $1.value < $0.value }
        return onlyFirst != nil && onlyFirst! < sorted.count ?
            Array(sorted[0 ... onlyFirst!]) : sorted
    }
}
