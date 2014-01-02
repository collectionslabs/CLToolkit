Pod::Spec.new do |s|
  s.name         =  'CLToolkit'
  s.version      =  '0.1.3'
  s.summary      =  'CLToolkit is a collections of common macros, classes and utilities for Mac / iOS.'
  s.homepage     =  'https://github.com/collections/CLToolkit'
  s.author       =  { 'Tony Xiao' => 'tony@collections.me' }
  s.source       =  { :git => 'https://github.com/collections/CLToolkit.git', :tag => "#{s.version}" }
  s.license      =  'MIT'
  
  # Platform setup
  s.osx.deployment_target = '10.8'
  s.ios.deployment_target = '6.0'
  s.requires_arc = true

  
  # Include only the core by default
  s.default_subspec = 'Core'

  ### Subspecs
  
  s.subspec 'Core' do |ss|
    ss.source_files =  'CLToolkit/Core/**/*.{h,m,mm,c}'
    ss.osx.framework = 'Cocoa'
    ss.ios.framework = 'UIKit'
    
    ss.dependency 'Base64', '~> 1.0.1'
    ss.dependency 'ConciseKit', '~> 0.1.2'
    ss.dependency 'BlocksKit', '~> 2.0'
    ss.dependency 'libextobjc', '~> 0.3'
    ss.dependency 'ReactiveCocoa', '~> 2.1'
    ss.dependency 'NSLogger', '~> 1.1'
    ss.dependency 'ISO8601DateFormatter', '~> 0.7'

  end
  
  s.subspec 'Networking' do |ss|
    ss.source_files   = 'CLToolkit/Networking/**/*.{h,m,mm,c}'
    
    ss.dependency 'CLToolkit/Core'
    ss.dependency 'AFNetworking', '~> 2.0'
    ss.dependency 'Base64', '~> 1.0.1'
  end
  
  s.subspec 'Operation' do |ss|
    ss.source_files   = 'CLToolkit/Operation/**/*.{h,m,mm,c}'
    
    ss.dependency 'CLToolkit/Core'
  end
  
  s.subspec 'CoreData' do |ss|
    ss.source_files   = 'CLToolkit/CoreData/**/*.{h,m,mm,c}'
    ss.framework      = 'CoreData'
    
    ss.dependency 'CLToolkit/Core'
    ss.dependency 'CLToolkit/Operation'
    ss.dependency 'MagicalRecord', '~> 2.2'
    ss.dependency 'Base64', '~> 1.0.1'
  end
  
  s.subspec 'Firebase' do |ss|
    ss.source_files   = 'CLToolkit/Firebase/**/*.{h,m,mm,c}'

    ss.dependency     'CLToolkit/Core'
    ss.dependency     'CLToolkit/CoreData'
    ss.osx.dependency 'FirebaseMac', '~> 1.0.1'
    ss.ios.dependency 'Firebase', '~> 1.0.7'

    ss.xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => '"$(PODS_ROOT)/Firebase"' }
  end
  
  s.subspec 'UI' do |ss|
    ss.source_files   = 'CLToolkit/UI/**/*.{h,m,mm,c}'

    ss.dependency 'CLToolkit/Core'
  end
  
  s.subspec 'Misc' do |ss|
    ss.source_files   = 'CLToolkit/Misc/**/*.{h,m,mm,c}'

    ss.osx.frameworks = 'Quartz'
    ss.dependency 'CLToolkit/Core'
    ss.dependency 'NSHash', '~> 1.0.1'
  end

  s.subspec 'Testing' do |ss|
    ss.source_files   = 'CLToolkit/Testing/**/*.{h,m,mm,c}'

    # ss.dependency 'CLToolkit/Core'
    ss.dependency 'Kiwi/XCTest', '~> 2.2'

    ss.xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => 
      '$(inherited) "$(SDKROOT)/Developer/Library/Frameworks" "$(DEVELOPER_LIBRARY_DIR)/Frameworks"' }
  end
end
