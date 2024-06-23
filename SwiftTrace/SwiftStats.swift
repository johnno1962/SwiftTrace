//
//  SwiftStats.swift
//  SwiftTrace
//
//  Created by John Holdsworth on 23/09/2020.
//  Copyright © 2020 John Holdsworth. All rights reserved.
//
//  Obtaining invocation statistics
//  ===============================
//
//  $Id: //depot/SwiftTrace/SwiftTrace/SwiftStats.swift#7 $
//

#if DEBUG || !DEBUG_ONLY
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
        return onlyFirst != nil ? Array(sorted.prefix(onlyFirst!)) : sorted
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
        return onlyFirst != nil ? Array(sorted.prefix(onlyFirst!)) : sorted
    }

    public static func callOrder() -> [Swizzle] {
        var calls = [Swizzle]()
        var call = firstCalled
        while call != nil {
            calls.append(call!)
            call = call!.nextCalled
        }
        return calls
    }
}
#endif
