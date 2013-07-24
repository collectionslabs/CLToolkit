Pod::Spec.new do |s|
  s.name         =  'CLToolkit'
  s.version      =  '0.0.1'
  s.summary      =  'CLToolkit is a collections of common macros, classes and utilities for Mac / iOS.'
  s.homepage     =  'https://github.com/collections/CLToolkit'
  s.author       =  { 'Tony Xiao' => 'tony@collections.me' }
  s.source       =  { :git => 'https://github.com/collections/CLToolkit.git', :tag => '0.0.1' }
  s.license      =  'MIT'
  
  # Platform setup
  s.platform     = :osx, "10.8"
  s.osx.deployment_target = '10.8'
  s.requires_arc = true

  
  # Include only the core by default
  s.default_subspec = 'Core'

  ### Subspecs
  
  s.subspec 'Core' do |ss|
    ss.source_files =  'CLToolkit/Core/'
    ss.framework = 'Cocoa'
    
    ss.dependency 'ConciseKit'
    ss.dependency 'BlocksKit'
    ss.dependency 'ReactiveCocoa'
    ss.dependency 'NSLogger'

  end
  
  s.subspec 'Networking' do |ss|
    ss.source_files   = 'CLToolkit/Networking'
    
    ss.dependency       'CLToolkit/Core'
    ss.dependency       'AFNetworking'
  end
  
  s.subspec 'Operation' do |ss|
    ss.source_files   = 'CLToolkit/Operation'
    
    ss.dependency       'CLToolkit/Core'
  end
  
end
