# SwiftTrace

Trace Swift and Objective-C method invocations of non-final classes in an app bundle or framework.
Think [Xtrace](https://github.com/johnno1962/Xtrace) but for Swift and Objective-C.

SwiftTrace is most easily used as a CocoaPod and can be added to your project by temporarily adding the
following line to it's Podfile:

    pod 'SwiftTrace'

This project has been updated to Swift 5 from Xocde 10.2.:

    pod 'SwiftTrace', '5.1'

Once the project has rebuilt import SwiftTrace into the application's AppDelegate and add something like
the following to the beginning of it's didFinishLaunchingWithOptions method:

    SwiftTrace.traceBundleContaining( theClass: type(of: self) )

This traces all classes defined in the main application bundle.
To trace, for example, all classes in the RxSwift framework add the following

    SwiftTrace.traceBundleContaining( theClass: RxSwift.DisposeBase.self )

This gives output in the Xcode debug console something like:

            Unwrap.LearnCoordinator.activeStudyReview.setter : Swift.Optional<Unwrap.StudyReview> 0.0ms
                  Unwrap.TappableTextView.addCustomizations() -> () 0.6ms
                -[TappableTextView initWithFrame:textContainer:] -> @56@0:8{CGRect={CGPoint=dd}{CGSize=dd}}16@48 6.8ms
              -[StudyTextView initWithFrame:textContainer:] -> @56@0:8{CGRect={CGPoint=dd}{CGSize=dd}}16@48 6.8ms
            -[StudyViewController initWithNibName:bundle:] -> @32@0:8@16@24 7.1ms
            Unwrap.StudyViewController.chapter.setter : Swift.String 0.0ms
              Unwrap.StudyViewController.configureNavigation() -> () 0.2ms
            Unwrap.StudyViewController.coordinator.setter : Swift.Optional<Unwrap.LearnCoordinator> 0.3ms
          Unwrap.LearnCoordinator.studyViewController(for: Swift.String) -> Unwrap.StudyViewController 15.5ms
              -[CoordinatedNavigationController initWithNibName:bundle:] -> @32@0:8@16@24 0.1ms
            -[CoordinatedNavigationController initWithRootViewController:] -> @24@0:8@16 7.6ms
          Unwrap.LearnCoordinator.startStudying(using: __C.UIViewController) -> () 20.9ms
        Unwrap.LearnCoordinator.startStudying(title: Swift.String) -> () 36.5ms
      Unwrap.LearnViewController.startStudying(title: Swift.String) -> () 36.6ms
    -[LearnDataSource tableView:didSelectRowAtIndexPath:] -> v32@0:8@16@24 36.7ms

The line beginning "-[RxSwift" is where the old Objective-C dynamic dispatch is being used.

To trace a system framework such as UIKit you can trace classes using a pattern:

    SwiftTrace.traceClassesMatching( pattern:"^UI" )

Individual classes can be traced using the underlying:

    SwiftTrace.trace( aClass: MyClass.self )

Output can be filtered using inclusion and exclusion regexps. 

    SwiftTrace.include( pattern: "TestClass" )
    SwiftTrace.exclude( pattern: "\\.getter" )

These methods must be called before you start the trace as they are applied during the "Swizzle".
There is a default set of exclusions setup as a result of testing, tracing UIKit.
                      
    public let swiftTraceDefaultExclusions = "\\.getter|retain]|_tryRetain]|_isDeallocating]|^\\+\\[(Reader_Base64|UI(NibStringIDTable|NibDecoder|CollectionViewData|WebTouchEventsGestureRecognizer)) |^.\\[UIView |UIButton _defaultBackgroundImageForType:andState:|RxSwift.ScheduledDisposable.dispose"

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
