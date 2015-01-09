Pod::Spec.new do |s|
  s.name         =  'CLToolkit'
  s.version      =  '0.2.10'
  s.summary      =  'CLToolkit is a collections of common macros, classes and utilities for Mac / iOS.'
  s.homepage     =  'https://github.com/collections/CLToolkit'
  s.author       =  { 'Tony Xiao' => 'tony@collections.me' }
  s.source       =  { :git => 'https://github.com/collections/CLToolkit.git', :tag => "v#{s.version}" }
  s.license      =  'MIT'
  
  # Platform setup
  s.osx.deployment_target = '10.8'
  s.ios.deployment_target = '6.0'
  s.requires_arc = true

  
  # Include only the core by default
  s.default_subspec = 'Default'

  ### Subspecs
  
  s.subspec 'Default' do |ss|
    ss.dependency 'CLToolkit/Core'
    ss.dependency 'CLToolkit/Networking'
    ss.dependency 'CLToolkit/CoreData'
    ss.dependency 'CLToolkit/Operation'
    ss.dependency 'CLToolkit/UI'
    ss.dependency 'CLToolkit/Misc'
  end
  
  s.subspec 'Core' do |ss|
    ss.source_files =  'CLToolkit/Core/**/*.{h,m,mm,c}'
    ss.osx.framework = 'Cocoa'
    ss.ios.framework = 'UIKit'
    
    ss.dependency 'Base64', '~> 1.0'
    ss.dependency 'ConciseKit', '~> 0.1'
    ss.dependency 'BlocksKit', '~> 2'
    ss.dependency 'libextobjc', '~> 0.4'
    ss.dependency 'ReactiveCocoa', '~> 2.3'
    ss.dependency 'ISO8601DateFormatter', '~> 0.7'

  end
  
  s.subspec 'Networking' do |ss|
    ss.source_files   = 'CLToolkit/Networking/**/*.{h,m,mm,c}'
    
    ss.dependency 'CLToolkit/Core'
    ss.dependency 'AFNetworking', '~> 2.3'
    ss.dependency 'Base64', '~> 1.0'
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
    ss.dependency 'MagicalRecord', '~> 2.3.0-beta.5'
    ss.dependency 'Base64', '~> 1.0'
  end
  
  s.subspec 'Firebase' do |ss|
    ss.source_files   = 'CLToolkit/Firebase/**/*.{h,m,mm,c}'

    ss.dependency     'CLToolkit/Core'
    ss.dependency     'CLToolkit/CoreData'
    ss.osx.dependency 'FirebaseMac', '~> 1.0.1'
    ss.ios.dependency 'Firebase', '~> 1.0'

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
    ss.dependency 'NSHash', '~> 1.0'
  end

  s.subspec 'Testing' do |ss|
    ss.source_files   = 'CLToolkit/Testing/**/*.{h,m,mm,c}'

    # ss.dependency 'CLToolkit/Core'
    ss.dependency 'Kiwi/XCTest', '~> 2.2'

    ss.xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => 
      '$(inherited) "$(SDKROOT)/Developer/Library/Frameworks" "$(DEVELOPER_LIBRARY_DIR)/Frameworks"' }
  end
end
