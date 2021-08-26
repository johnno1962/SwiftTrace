//
//  SwiftSwizzle.swift
//  SwiftTrace
//
//  Created by John Holdsworth on 20/04/2020.
//  Copyright © 2020 John Holdsworth. All rights reserved.
//
//  Repo: https://github.com/johnno1962/SwiftTrace
//  $Id: //depot/SwiftTrace/SwiftTrace/SwiftSwizzle.swift#53 $
//
//  Mechanics of Swizzling Swift
//  ============================
//

import Foundation
#if SWIFT_PACKAGE
import SwiftTraceGuts
#endif

extension SwiftTrace {

    public typealias SIMP = SwiftMeta.SIMP

    /**
     Hook to intercept all trace output
     */
    public static var logOutput: (String, UnsafeRawPointer?, Int) -> () = {
        print($0, terminator: "")
        _ = ($1, $2) // self, indent
    }

    /** Used for real time filtering */
    static var includeFilter: NSRegularExpression?
    static var excludeFilter: NSRegularExpression?
    static var filterGeneration = 0

    /** Used to gather order in which methods are called */
    static var firstCalled: Swizzle?
    static var lastCalled: Swizzle?

    @objc open class var traceFilterInclude: String? {
        get { return includeFilter?.pattern }
        set(pattern) {
           includeFilter = pattern != nil && pattern != "" ?
               NSRegularExpression(regexp: pattern!) : nil
           filterGeneration += 1
        }
   }

    @objc open class var traceFilterExclude: String? {
        get { return excludeFilter?.pattern }
        set(pattern) {
           excludeFilter = pattern != nil && pattern != "" ?
               NSRegularExpression(regexp: pattern!) : nil
           filterGeneration += 1
        }
   }

    /// Map trampolines back to the original implementation swizzled
    /// - Parameter trampoline: a function entry point
    /// - Returns: original implementation swizzled
    open class func swizzled(forTrampoline: UnsafeMutableRawPointer)
        -> UnsafeMutableRawPointer? {
        var implementation = forTrampoline
        while let swizzle = findSwizzleOf(implementation) as? Swizzle {
            implementation = autoBitCast(swizzle.implementation)
        }
        return implementation != forTrampoline ? implementation : nil
    }

   /**
    Instances used to store information about a patch on a method
    */
   open class Swizzle: NSObject {

      /** string representing Swift or Objective-C method to user */
       public let signature: String

       /** trace that resulted in this Swizzle */
       let trace: SwiftTrace

       /** pointer to original function implementing method */
       open var implementation: IMP

       /** vtable slot patched for unpatching */
       var vtableSlot: UnsafeMutablePointer<SIMP>?

       /** Original objc method swizzled */
       let objcMethod: Method?
       let objcClass: AnyClass?

       /** Total time spent in this method */
       var totalElapsed: TimeInterval = 0.0

       /** Number of times this method has beeen called */
       var invocationCount = 0

       /** This Sizzle has been swizzled */
       var reSwizzled = false

       /** Closure that can be called instead of original implementation */
       public let nullImplmentation: nullImplementationType?

       /** lazy calculation of shouldTrace */
       var currentGeneration = 0
       var currentShouldTrace = true

       /** Used to gather linked list of call order */
       var nextCalled: Swizzle?

       /** is this method involved in Lifetime tracing? */
       var isLifetime: Bool { return false }

       /** Always trace allocations & deallocations unless explicitly filtered out */
       open func notFilteredOut() -> Bool {
           if currentGeneration != SwiftTrace.filterGeneration {
               currentGeneration = SwiftTrace.filterGeneration
               currentShouldTrace =
                   SwiftTrace.includeFilter?.matches(signature) != false &&
                   SwiftTrace.excludeFilter?.matches(signature) != true
           }
           return currentShouldTrace
       }

       /**
        Class used to create a specific "Invocation" of the "Swizzle" on entry
        */
       open var invocationFactory: Invocation.Type {
           return defaultInvocationFactory
       }

       /**
        The inner invocation instance on the stack of the current thread.
        */
       open func invocation() -> Invocation! {
           return Invocation.current
       }

       /**
        designated initialiser
        - parameter name: string representing method being traced
        - parameter vtableSlot: pointer to vtable slot patched
        - parameter objcMethod: pointer to original Method patched
        - parameter replaceWith: implementation to replace that of class
        */
        public required init?(name signature: String,
                              vtableSlot: UnsafeMutablePointer<SIMP>? = nil,
                              objcMethod: Method? = nil, objcClass: AnyClass? = nil,
                              original: OpaquePointer? = nil,
                              replaceWith: nullImplementationType? = nil) {
           self.trace = SwiftTrace.lastSwiftTrace
           self.signature = signature
           self.vtableSlot = vtableSlot
           self.objcMethod = objcMethod
           self.objcClass = objcClass
           if let vtableSlot = vtableSlot {
               implementation = autoBitCast(vtableSlot.pointee)
           }
           else if let objcMethod = objcMethod {
               implementation = method_getImplementation(objcMethod)
           } else {
               implementation = original!
           }
           nullImplmentation = replaceWith
       }

       /** Called from assembly code on entry to Swizzled method */
       static var onEntry: @convention(c) (_ swizzle: Swizzle, _ returnAddress: UnsafeRawPointer,
           _ stackPointer: UnsafeMutablePointer<UInt64>) -> IMP? = {
               (swizzle, returnAddress, stackPointer) -> IMP? in
               let threadLocal = ThreadLocal.current()
               let invocation = swizzle.invocationFactory
                   .init(stackDepth: threadLocal.invocationStack.count, swizzle: swizzle,
                         returnAddress: returnAddress, stackPointer: stackPointer)
               invocation.saveLevelsTracing = threadLocal.levelsTracing
               threadLocal.invocationStack.append(invocation)
               swizzle.onEntry(stack: &invocation.entryStack.pointee)
               if invocation.shouldDecorate {
                    threadLocal.levelsTracing -= 1
               }
               return swizzle.nullImplmentation != nil ?
                   autoBitCast(swizzle.nullImplmentation) : swizzle.implementation
       }

       /** Called from assembly code when Patched method returns */
       static var onExit: @convention(c) () -> UnsafeRawPointer = {
           let threadLocal = ThreadLocal.current()
           let invocation = threadLocal.invocationStack.last!
           invocation.exitStack.pointee.frame.lr = invocation.returnAddress
           invocation.swizzle.onExit(stack: &invocation.exitStack.pointee)
           threadLocal.levelsTracing = invocation.saveLevelsTracing
           return threadLocal.invocationStack.removeLast().returnAddress
       }

       /**
           Return a unique pointer to a trampoline that will callback
           the oneEntry() and onExit() method in this class
        */
       open lazy var forwardingImplementation: SIMP = {
           /* create trampoline */
           let impl = imp_implementationForwardingToTracer(autoBitCast(self),
                       autoBitCast(Swizzle.onEntry), autoBitCast(Swizzle.onExit))
           trace.activeSwizzles[impl] = self // track Swizzles by trampoline and retain them

           var previousTrace: SwiftTrace? = trace.previousSwiftTrace
           while previousTrace != nil {
               if let previous = previousTrace!.activeSwizzles[implementation] {
                   previous.reSwizzled = true
               }
               previousTrace = previousTrace!.previousSwiftTrace
           }
           return autoBitCast(impl)
       }()

       /**
        method called before trampoline enters the target "Swizzle"
        */
       open func onEntry(stack: inout EntryStack) {
           if let invocation = invocation() {
               _ = objcAdjustStret(invocation: invocation, isReturn: false,
                                   intArgs: &invocation.entryStack.pointee.intArg1)
               if nextCalled == nil && lastCalled != self {
                   lastCalled?.nextCalled = self
                   lastCalled = self
                   if firstCalled == nil {
                       firstCalled = self
                   }
               }

               let shouldPrint = invocation.shouldDecorate && notFilteredOut()
               if shouldPrint || isLifetime,
                   let decorated = entryDecorate(stack: &stack), shouldPrint {
                   ThreadLocal.current().caller()?.subLogged = true
                   let indent = String(repeating: SwiftTrace.traceIndent,
                                       count: invocation.stackDepth)
                   logOutput("\(subLogging() ? "\n" : "")\(indent)\(decorated)",
                             autoBitCast(invocation.swiftSelf), invocation.stackDepth)
               }
           }
       }

       /**
        decorate funcition signature with argument values
        */
       open func entryDecorate(stack: inout EntryStack) -> String? {
           return signature
       }

       /**
        Is this method being called from one in the middle of logging
        */
       open func subLogging() -> Bool {
           return ThreadLocal.current().caller()?.subLogged == true
       }

       /**
        method called after trampoline exits the target "Swizzle"
        */
       open func onExit(stack: inout ExitStack) {
           if let invocation = invocation() {
               let elapsed = Invocation.usecTime() - invocation.timeEntered
               let shouldPrint = invocation.shouldDecorate && notFilteredOut()
               if shouldPrint || isLifetime,
                   let returnValue = exitDecorate(stack: &stack), shouldPrint {
                   logOutput("""
                        \(invocation.subLogged ? """
                            \n\(String(repeating: "  ",
                                       count: invocation.stackDepth))<-
                            """ : objcMethod != nil ? " ->" : "") \
                        \(returnValue)\(String(format: SwiftTrace.timeFormat,
                                elapsed * 1000.0))\(subLogging() ? "" : "\n")
                        """, autoBitCast(invocation.swiftSelf), invocation.stackDepth)
               }
               totalElapsed += elapsed
               invocationCount += 1
           }
       }

       /**
        Provide the return value
        */
       open func exitDecorate(stack: inout ExitStack) -> String? {
           return signature
       }

        /**
         Use NSMethodSignature to know argument types of method
         */
        lazy var methodSignature: Any? = {
            return method_getSignature(self.objcMethod!)
        }()

        /**
         Special handling of methods that return a struct that
         doesn't fit into registers on x86_64 architectures.
         Argument register for `self` is offset by one.
         */
        open func objcAdjustStret(invocation: Invocation, isReturn: Bool,
                                  intArgs: UnsafePointer<intptr_t>) -> Bool {
            // Is method returning a struct?
            // If so there is an implicit argument which is the address
            // to write the struct into (even if the registers are used.)
            #if arch(arm64)
            return false
            #else
            guard objcMethod != nil && !isReturn else { return false }
            let returnType = methodSignature == nil ? "UNDECODABLE" :
                String(cString: sig_returnType(methodSignature!))
            let isStret = returnType.hasPrefix("{") &&
                returnType.hasSuffix("}") && returnType[.end-4] != "="
            if isStret && !isReturn {
                invocation.swiftSelf = intArgs[1]
            }
            return isStret
            #endif
        }

        /**
           Remove this swizzle
        */
       open func remove() {
           if let vtableSlot = vtableSlot {
               vtableSlot.pointee = autoBitCast(implementation)
           }
           else if let objcMethod = objcMethod {
               method_setImplementation(objcMethod, implementation)
           }
       }

       /**
           Remove all patches recursively
        */
       open func removeAll() {
           (SwiftTrace.originalSwizzle(for: implementation) ?? self).remove()
       }

       /** find "self" for the current invocation */
       open func getSelf<T>(as: T.Type = T.self) -> T {
           return autoBitCast(invocation().swiftSelf)
       }

       /** find Class for the current invocation */
       open func getClass() -> AnyClass {
           let id: AnyObject = autoBitCast(invocation().swiftSelf)
           return object_isClass(id) ? autoBitCast(id) : object_getClass(id)!
       }

       /** pointer to memory for return of struct */
       open func structReturn<T>(as: T.Type = T.self) -> UnsafeMutablePointer<T> {
           return UnsafeMutablePointer(cast: invocation().structReturn!)
       }

       /** convert arguments & return results to a specifi type */
       open func rebind<IN,OUT>(_ pointer: UnsafeMutablePointer<IN>,
                                to: OUT.Type = OUT.self) -> UnsafeMutablePointer<OUT> {
           return UnsafeMutablePointer(cast: pointer)
       }

       /**
        Represents a specific call to a member function on the "ThreadLocal" stack
        */
       public class Invocation {

           /** Time call was started */
           public let timeEntered: Double

           /** Number of calls above this on the stack of the current thread */
           public let stackDepth: Int

           /** "Swizzle" related to this call */
           public let swizzle: Swizzle

           /** signature with arguments substituted in */
           public var decorated: String?

           /** arguments parsed out of invocation */
           public var arguments = [Any]()

           /** Original return address of call to trampoline */
           public let returnAddress: UnsafeRawPointer

           /** levelsTracing on entry for restore */
           public var saveLevelsTracing = 0

           /** Offset through argument frame of saved registers */
           public var intArgumentOffset = 0

           /** Offset through return value frame of saved registers */
           public var floatArgumentOffset = 0

           /** Has a trace taken place during this invocation */
           public var subLogged = false

           /** This invocation qualifies for tracing */
           lazy public var shouldDecorate: Bool = {
                let threadLocal = ThreadLocal.current()
                if threadLocal.describing {
                    return false
                }
                if threadLocal.levelsTracing > 0 && !swizzle.reSwizzled {
                    return true
                }
                if (swizzle.trace.instanceFilter == nil ||
                    swizzle.trace.instanceFilter == swiftSelf) &&
                    (swizzle.trace.classFilter == nil ||
                     swizzle.trace.classFilter === swizzle.getClass()) {
                    ThreadLocal.current().levelsTracing = swizzle.trace.subLevels
                    return true
                }
                return false
           }()

           /** Architecture depenent place on stack where arguments stored */
           public let entryStack: UnsafeMutablePointer<EntryStack>

           public var exitStack: UnsafeMutablePointer<ExitStack> {
               return autoBitCast(entryStack)
           }

           /** copy of struct return register in case function throws */
           public var structReturn: UnsafeMutableRawPointer? = nil

           /** "self" for method invocations */
           public var swiftSelf: intptr_t

           /** for use relaying data from entry to exit */
           public var userInfo: Any?

           public var numberLive = 0

           /**
            micro-second precision time.
            */
           static public func usecTime() -> Double {
               var tv = timeval()
               gettimeofday(&tv, nil)
               return Double(tv.tv_sec) + Double(tv.tv_usec)/1_000_000.0
           }

           /**
            designated initialiser
            - parameter stackDepth: number of calls that have been made on the stack
            - parameter swizzle: associated Swizzle instance
            - parameter returnAddress: adress in process trampoline was called from
            - parameter stackPointer: stack pointer of thread with saved registers
            */
           public required init(stackDepth: Int, swizzle: Swizzle, returnAddress: UnsafeRawPointer,
                                stackPointer: UnsafeMutablePointer<UInt64>) {
               timeEntered = Invocation.usecTime()
               self.stackDepth = stackDepth
               self.swizzle = swizzle
               self.returnAddress = returnAddress
               self.entryStack = autoBitCast(stackPointer)
               self.swiftSelf = swizzle.objcMethod != nil ?
                   entryStack.pointee.intArg1 : entryStack.pointee.swiftSelf
               self.structReturn = UnsafeMutableRawPointer(bitPattern: entryStack.pointee.structReturn)
           }

           /**
            The inner invocation instance on the current thread.
            */
           public static var current: Invocation! {
               return ThreadLocal.current().invocationStack.last
           }
       }

       /**
        Class implementing thread local storage to arrange a call stack
        */
       public class ThreadLocal {

           private static var keyVar: pthread_key_t = 0

           private static var pthreadKey: pthread_key_t = {
               let ret = pthread_key_create(&keyVar, {
                   #if os(Linux) || os(Android)
                   Unmanaged<ThreadLocal>.fromOpaque($0!).release()
                   #else
                   Unmanaged<ThreadLocal>.fromOpaque($0).release()
                   #endif
               })
               if ret != 0 {
                   NSLog("Could not pthread_key_create: %s", strerror(ret))
               }
               return keyVar
           }()

           /**
            The stack of Invocations logged on this thread
            */
           public var invocationStack = [Invocation]()

           /**
            currently describing an instance
            */
           public var describing = false

           /**
            currently describing an instance
            */
           public var levelsTracing = 0

           /**
            Returns an instance of ThreadLocal specific to the current thread
            */
           static public func current() -> ThreadLocal {
               let keyVar = ThreadLocal.pthreadKey
               if let existing = pthread_getspecific(keyVar) {
                   return Unmanaged<ThreadLocal>.fromOpaque(existing).takeUnretainedValue()
               }
               else {
                   let unmanaged = Unmanaged.passRetained(ThreadLocal())
                   let ret = pthread_setspecific(keyVar, unmanaged.toOpaque())
                   if ret != 0 {
                       NSLog("Could not pthread_setspecific: %s", strerror(ret))
                   }
                   return unmanaged.takeUnretainedValue()
               }
           }

           static public func whileDescribing(block: () -> ()) {
               let threadLocal = current()
               let saveDescribing = threadLocal.describing
               threadLocal.describing = true
               block()
               threadLocal.describing = saveDescribing
           }

           public func caller() -> Invocation? {
                var caller = invocationStack.count - 2
                while caller >= 0 {
                    let invocation = invocationStack[caller]
                    if invocation.swizzle.notFilteredOut() {
                        return invocation
                    }
                    caller -= 1
                }
                return nil
           }
       }
   }
}
