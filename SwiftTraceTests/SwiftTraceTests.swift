//
//  SwiftTraceTests.swift
//  SwiftTraceTests
//
//  Created by John Holdsworth on 13/06/2016.
//  Copyright © 2016 John Holdsworth. All rights reserved.
//

import XCTest
import SwiftTrace

struct TestStruct: Equatable {

    let a = 1.0, b = 2.0, c = 3.0
    let i = 111, j = 222, k = 333

}

func ==(lhs: TestStruct, rhs: TestStruct) -> Bool {

    return lhs.a == lhs.a && lhs.b == lhs.b && lhs.c == lhs.c && lhs.i == lhs.i && lhs.j == lhs.j && lhs.k == lhs.k
}

protocol P {

    func x()
    func y() -> Float
    func z( d: Int, f: Double, g: Float, h: Double, f1: Double, g1: Float, h1: Double, f2: Double, g2: Float, h2: Double, e: Int )
    func s( a: TestStruct ) -> TestStruct

}

var got = ""
var args = ""

class SwiftTwaceTests: XCTestCase {

    class TestClass: P {

        let i = 111

        func x() {
            got = "\(i)"
        }

        func y() -> Float {
            got = "\(i)"
            return -222.0
        }

        func z(d: Int, f: Double, g: Float, h: Double, f1: Double, g1: Float, h1: Double, f2: Double, g2: Float, h2: Double, e: Int) {
            got = "\(i) \(d) \(e) \(f) \(g) \(h) \(f1) \(g1) \(h1) \(f2) \(g2) \(h2)"
        }

        func s(a: TestStruct) -> TestStruct {
            return a
        }
    }

    class TestInvoke: SwiftTrace.Invocation {

        override func onEntry() {
            args = "\(theStack[1]) \(Unmanaged<TestClass>.fromOpaque(swiftSelf).takeUnretainedValue().i) \(Double(bitPattern: theStack[-1]))"
        }
    }

    let p: P = TestClass()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        SwiftTrace.invocationFactory = TestInvoke.self
        SwiftTrace.trace(aClass: TestClass.self)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        p.x()
        XCTAssertEqual(got, "111")

        XCTAssertEqual(p.y(), -222.0)
        XCTAssertEqual(got, "111")

        p.z( d: 88, f: 66, g: 55, h: 44, f1: 66, g1: 55, h1: 44, f2: 66, g2: 55, h2: 44, e: 77 )
        XCTAssertEqual(got, "111 88 77 66.0 55.0 44.0 66.0 55.0 44.0 66.0 55.0 44.0" )
        XCTAssertEqual(args, "88 111 66.0")

        XCTAssertEqual(p.s( a: TestStruct() ), TestStruct())
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
