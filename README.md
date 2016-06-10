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

If you want to further process output you can define a custom tracing class:

    class MyTracer: SwiftTraceInfo {

        override func trace() -> IMP {
            print( ">> "+symbol )
            return original /// must return implmentation to call
        }
        
    }
    
    SwiftTrace.tracerClass = MyTracer.self

Please file an issue if you encounter a project that doesn't work while tracing. It should
be 100% reliable as it uses assembly language trampolines rather than Swizzling like Xtrace.
Otherwise, the author can be contacted on Twitter [@Injection4Xcode](https://twitter.com/@Injection4Xcode). 
Big thanks goes out to Oliver Letterer for his [imp_implementationForwardingToSelector](https://github.com/OliverLetterer/imp_implementationForwardingToSelector)
to set up the trampolines.

Enjoy!
