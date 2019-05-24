#
# Be sure to run `pod lib lint Mach1SpatialAPI.podspec' to ensure this is a
# valid spec before submitting.

Pod::Spec.new do |s|
  s.name             = 'Mach1SpatialAPI'
  s.version          = '0.1.5'
  s.summary          = 'This is the Mach1 Spatial SDK for iOS'

  s.description      = <<-DESC
Mach1 Spatial APIs are all contained in this pod which includes:
    [Mach1EncodeCAPI, Mach1DecodeCAPI, Mach1DecodePositionalCAPI]
                       DESC

  s.homepage         = 'http://dev.mach1.xyz'
  s.license          = { :type => 'Commercial', :file => 'LICENSE' }
  s.author           = { 'Mach1' => 'http://www.mach1studios.com' }
  s.documentation_url = 'http://dev.mach1.xyz'
  s.source           = { :git => 'git@github.com:Mach1Studios/Pod-Mach1SpatialAPI.git', :tag => s.version.to_s }
  s.platform = :ios, "9.3"
  s.swift_version = "5.0"

  s.source_files = 'Mach1SpatialAPI/Classes/*.{h,swift}'
  s.public_header_files = 'Mach1SpatialAPI/Classes/*.h'

  s.ios.vendored_libraries = 'Mach1SpatialAPI/Lib/ios/*.a'
  s.ios.libraries       = 'c++'
end
