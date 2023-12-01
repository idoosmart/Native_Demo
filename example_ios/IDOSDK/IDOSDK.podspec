#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint protocol_ffi.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'IDOSDK'
  s.version          = '0.0.3'
  s.summary          = 'ido sdk'
  s.description      = <<-DESC
  ido sdk
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'IDO' => 'email@example.com' }

  s.source           = { :path => '.' }

  s.platform         = :ios, '9.0'
  s.libraries        = 'iconv','z','c++'

  s.vendored_frameworks = [
    'alexa_channel.xcframework',
    'App.xcframework',
    'connectivity_plus.xcframework',
    'flutter_bluetooth.xcframework',
    'flutter_image_compress_common.xcframework',
    'flutter_native_timezone.xcframework',
    'Flutter.xcframework',
    'FlutterPluginRegistrant.xcframework',
    'libwebp.xcframework',
    'Mantle.xcframework',
    'native_channel.xcframework',
    'package_info_plus.xcframework',
    'path_provider_foundation.xcframework',
    'protocol_channel.xcframework',
    'Reachability.xcframework',
    'SDWebImage.xcframework',
    'SDWebImageWebPCoder.xcframework',
    'protocol_c.framework'
   ]
   
   # Flutter.framework does not contain a i386 slice.
     s.pod_target_xcconfig = {
       'DEFINES_MODULE' => 'YES',
       'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386'
     }

     s.xcconfig = {
         'GCC_PREPROCESSOR_DEFINITIONS' => [
         'PLATFORM_TYPE=2',
         'HAVE_INTTYPES_H',
         'HAVE_PKCRYPT',
         'HAVE_STDINT_H',
         'HAVE_WZAES',
         'HAVE_ZLIB',
         'VAR_ARRAYS',
         'USE_ALLOCA',
         'NONTHREADSAFE_PSEUDOSTACK',
         'OPUS_BUILD',
         'STDC_HEADERS'
         ],
       }

     s.swift_version = '5.0'

 end
