Pod::Spec.new do |s|
  s.name                     = 'Mach1SpatialAPI'
  s.version                  = '0.1.23'
  s.summary                  = 'Mach1 Spatial APIs for iOS'

  s.description              = <<-DESC
Mach1 Spatial APIs are all contained in this pod which includes:
    [Mach1EncodeCAPI, Mach1DecodeCAPI, Mach1DecodePositionalCAPI, Mach1TranscodeCAPI]
                                  DESC

  s.homepage                 = 'http://dev.mach1.tech'
  s.license                  = { :type => 'Commercial', :file => 'LICENSE.txt' }
  s.author                   = { 'Mach1' => 'https://www.mach1.tech' }
  s.documentation_url        = 'https://dev.mach1.tech'
  s.source                   = { :git => 'https://github.com/Mach1Studios/Pod-Mach1SpatialAPI.git', :tag => s.version.to_s }
  s.platform                 = :ios, "9.3"
  s.swift_version            = "5.0"
  s.pod_target_xcconfig      = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.user_target_xcconfig     = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }

  s.source_files             = 'Mach1SpatialAPI/Classes/*.{h,swift}'
  s.public_header_files      = 'Mach1SpatialAPI/Classes/*.h'

  s.ios.vendored_libraries   = 'Mach1SpatialAPI/Lib/ios/*.a'
  s.ios.libraries            = 'c++'
end