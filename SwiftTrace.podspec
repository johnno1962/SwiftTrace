Pod::Spec.new do |s|
    s.name        = "SwiftTrace"
    s.version     = "5.4.0"
    s.summary     = "Log Swift or Objective-C method invocations"
    s.homepage    = "https://github.com/johnno1962/SwiftTrace"
    s.social_media_url = "https://twitter.com/Injection4Xcode"
    s.documentation_url = "https://github.com/johnno1962/SwiftTrace/blob/master/README.md"
    s.license     = { :type => "MIT" }
    s.authors     = { "johnno1962" => "swifttrace@johnholdsworth.com" }

    s.osx.deployment_target = "10.9"
    s.ios.deployment_target = "8.0"
    s.source   = { :git => "https://github.com/johnno1962/SwiftTrace.git", :tag => s.version }
    s.source_files = "SwiftTrace/*.{swift,h,mm,s}"
    s.swift_versions = "5.0"
end
