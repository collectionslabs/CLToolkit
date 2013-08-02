# Default target gets auto created by Cocoapods
# target :default, :exclusive => true do

platform :ios, '6.0'
inhibit_all_warnings!
link_with []

# Pods from official Cocoapods/Specs repo

target :ios do
  platform :ios, '6.0'
  link_with 'CLToolkit-ios'
  pod 'NSLogger'
  pod 'Base64'
  pod 'BlocksKit'
  pod 'AFNetworking'
  pod 'ConciseKit'
  pod 'MagicalRecord'
  pod 'ReactiveCocoa'
  pod 'ISO8601DateFormatter'
  pod 'Firebase'
  pod 'Kiwi'
  pod 'Masonry'
  pod 'NSHash'

  pod 'AWSRuntime/S3', '1.5.0.head' # From Collections/Podspecs
  
end

target :osx do
  platform :osx, '10.8'
  link_with 'CLToolkit-osx'
  pod 'NSLogger'
  pod 'Base64'
  pod 'BlocksKit'
  pod 'AFNetworking'
  pod 'ConciseKit'
  pod 'MagicalRecord'
  pod 'ReactiveCocoa'
  pod 'ISO8601DateFormatter'
  pod 'Kiwi'
  # pod 'Masonry' # TODO: no reason masonry is not os x compatible...
  pod 'NSHash'

  pod 'AWSRuntime/S3', '1.5.0.head' # From Collections/Podspecs
  pod 'FirebaseMac', '1.0.1' # From Collections/Podspecs
end

# end
