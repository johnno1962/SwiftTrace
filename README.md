# SwiftTrace

Trace Swift and Objective-C method invocations of non-final classes in an app bundle or framework.
Think [Xtrace](https://github.com/johnno1962/Xtrace) but for Swift and Objective-C.

SwiftTrace is most easily used as a CocoaPod and can be added to your project by temporarily adding the
following line to it's Podfile:

    pod 'SwiftTrace'

Once the project has rebuilt import SwiftTrace into the application's AppDelegate and add something like
the following to the beginning of it's didFinishLaunchingWithOptions method:

    SwiftTrace.traceBundleContainingClass(self.dynamicType)

This traces all classes defined in the main application bundle.
To trace, for example, all classes in the RxSwift framework add the following

    SwiftTrace.traceBundleContainingClass(RxSwift.DisposeBase.self)

To trace a system framework such as UIKit you can trace classes using a pattern:

    SwiftTrace.traceClassesMatching( "^UI" )

This gives output in the Xcode debug console something like:

    RxSwift.SingleAssignmentDisposable.dispose () -> ()
    RxSwift.SingleAssignmentDisposable.disposable.setter : RxSwift.Disposable11
    RxSwift.CompositeDisposable.addDisposable (RxSwift.Disposable11) -> Swift.Optional<RxSwift.BagKey>
    RxSwift.CurrentThreadScheduler.schedule <A> (A, action : (A) -> RxSwift.Disposable11) -> RxSwift.Disposable11
    -[RxSwift.CurrentThreadSchedulerKey copyWithZone:] -> @24@0:8^v16
    RxSwift.CompositeDisposable.addDisposable (RxSwift.Disposable11) -> Swift.Optional<RxSwift.BagKey>
    RxSwift.CompositeDisposable.addDisposable (RxSwift.Disposable11) -> Swift.Optional<RxSwift.BagKey>
    RxSwift.SerialDisposable.disposable.setter : RxSwift.Disposable11
    RxSwift.SingleAssignmentDisposable.dispose () -> ()
    RxSwift.SingleAssignmentDisposable.disposable.setter : RxSwift.Disposable11
    RxSwift.SingleAssignmentDisposable.dispose () -> ()
    RxSwift.CompositeDisposable.removeDisposable (RxSwift.BagKey) -> ()
    RxSwift.SingleAssignmentDisposable.dispose () -> ()

The line beginning "-[RxSwift" is where the old Objective-C dynamic dispatch is being used.

Individual classes can be traced using the underlying:

    SwiftTrace.traceClass( MyClass.self )

Output can be filtered using inclusion and exclusion regexps. 

    SwiftTrace.include( "TestClass" )
    SwiftTrace.exclude( "\\.getter" )

These methods must be called before you start the trace as they are applied during the "Swizzle".
There is a default set of exclusions setup as a result of testing, tracing UIKit.
                      
    public let swiftTraceDefaultExclusions = "\\.getter|retain]|_tryRetain]|_isDeallocating]|\\[UINibStringIDTable|\\[UIView"

If you want to further process output you can define a custom tracing class:

    class MyTracer: SwiftTraceInfo {

        override func trace() -> IMP {
            print( ">> "+symbol )
            return original /// must return implmentation to call
        }
        
    }
    
    SwiftTrace.tracerClass = MyTracer.self
                      
#### How it works
                      
A Swift `AnyClass` instance has a layout similar to an Objective-C class with some
additional data documented in the `ClassMetadataSwift` in SwiftTrace.swift. After this data
there is a vtable of pointers to the class and instance member functions of the class up to
the size of the class instance. SwiftTrace replaces these function pointers with a pointer
to a unique assembly language "trampoline" entry point which has destination function and
data pointers associated with it. Registers are saved and this function is called passing
the data pointer to log the method name. The method name is determined by de-mangling the
symbol name associated the function address of the implementing method. The registers are
then restored and control is passed to the original function implementing the method. 
 
Please file an issue if you encounter a project that doesn't work while tracing. It should
be 100% reliable as it uses assembly language trampolines rather than Swizzling like Xtrace.
Otherwise, the author can be contacted on Twitter [@Injection4Xcode](https://twitter.com/@Injection4Xcode). 
Thanks to Oliver Letterer for [imp_implementationForwardingToSelector](https://github.com/OliverLetterer/imp_implementationForwardingToSelector)
used to set up the trampolines.

Enjoy!
