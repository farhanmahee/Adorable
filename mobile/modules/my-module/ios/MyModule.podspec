Pod::Spec.new do |s|
  s.name           = 'MyModule'
  s.version        = '1.0.0'
  s.summary        = 'A sample project summary'
  s.description    = 'A sample project description'
  s.author         = ''
  s.homepage       = 'https://docs.expo.dev/modules/'
  s.platforms      = {
    :ios => '15.1',
    :tvos => '15.1'
  }
  s.source         = { git: '' }
  s.static_framework = true

  s.dependency 'ExpoModulesCore'
  s.dependency 'EXManifests'
  s.dependency 'EXUpdatesInterface'
  s.dependency 'Alamofire', '~> 5.0'
  s.dependency 'React-Core'
  s.dependency 'React-RCTAppDelegate'
  s.dependency 'Expo'

  # Swift/Objective-C compatibility
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'SWIFT_OPTIMIZATION_LEVEL' => '-Onone',
    'CLANG_ENABLE_MODULES' => 'YES',
    'SWIFT_VERSION' => '5.0'
  }

  s.source_files = "**/*.{h,m,mm,swift,hpp,cpp}"
end