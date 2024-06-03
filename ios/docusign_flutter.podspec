#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint docusign_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'docusign_flutter'
  s.version          = '0.0.1'
  s.summary          = 'Docusign SDK flutter plugin'
  s.description      = <<-DESC
Docusign SDK flutter plugin
                       DESC
  s.homepage         = 'https://unitedtraders.biz/'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'UnitedTraders' => 'welcome@unitedtraders.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'DocuSign', '~> 2.5.0'
  s.platform = :ios, '8.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
