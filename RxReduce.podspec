Pod::Spec.new do |s|

  s.name         = "RxReduce"
  s.version      = "0.10"
  s.summary      = "RxReduce is a lightweight framework that ease the implementation of a state container pattern in a Reactive Programming compliant way."

  s.description  = <<-DESC
RxReduce provides:

* State and Action abtractions
* A default, generic and reactive Store
* Type safe Reducers
* An elegant way to deal with asynchronicity outside Reducers
                   DESC

  s.homepage     = "https://github.com/RxSwiftCommunity/RxReduce"
  s.screenshots  = "https://raw.githubusercontent.com/RxSwiftCommunity/RxReduce/develop/Resources/RxReduce_Logo.png"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.authors      = { "Thibault Wittemberg" => "thibault.wittemberg@gmail.com", "RxSwiftCommunity" => "https://github.com/RxSwiftCommunity" }
  s.social_media_url   = "http://twitter.com/thwittem"
  s.platform     = :ios
  s.ios.deployment_target = "9.0"
  s.source       = { :git => "https://github.com/RxSwiftCommunity/RxReduce.git", :tag => s.version.to_s }
  s.source_files  = "RxReduce/**/*.swift"
  s.requires_arc     = true  
  s.dependency 'RxSwift', '>= 4.5.0'
  s.dependency 'RxCocoa', '>= 4.5.0'

end
