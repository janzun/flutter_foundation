Pod::Spec.new do |s|
  s.name             = 'core_camera'
  s.version          = '1.0.0'
  s.summary          = 'High-performance native camera plugin with ZSL capture and zero-copy vision analysis.'
  s.description      = <<-DESC
High-performance native camera plugin with Zero-Shutter-Lag capture, native 4:3 sensor alignment, and zero-copy vision analysis.
                       DESC
  s.homepage         = 'https://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'CoreTeam' => 'dev@example.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.platform         = :ios, '13.0'
  s.dependency 'Flutter'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
