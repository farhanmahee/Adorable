Pod::Spec.new do |s|
  s.name           = 'AdorableDevLauncher'
  s.version        = '1.0.0'
  s.summary        = 'A sample project summary'
  s.description    = 'A sample project description'
  s.author         = ''
  s.homepage       = 'https://docs.expo.dev/modules/'
  s.platforms      = {
    :ios => '15.1',
    :tvos => '15.1'
  }
  s.swift_version  = '5.2'
  s.source         = { git: '' }
  s.static_framework = true

  # Sources
  s.source_files = "**/*.{h,m,mm,swift,hpp,cpp}"
  s.exclude_files = 'ios/Tests/**/*'

  # Expose umbrella header and map headers under AdorableDevLauncher/
  s.public_header_files = 'AdorableDevLauncher.h', '**/*.h'
  s.header_dir = 'AdorableDevLauncher'

  # Dependencies
  s.dependency 'ExpoModulesCore'
  s.dependency 'React-Core'
  s.dependency 'React-RCTAppDelegate'
  s.dependency 'expo-dev-menu-interface'
  s.dependency 'EXManifests'
  s.dependency 'EXUpdatesInterface'
  s.dependency 'expo-dev-menu'
  s.dependency 'ReactAppDependencyProvider'

  # Header search paths for Swift compatibility headers
  header_search_paths = [
    '"$(PODS_ROOT)/Headers/Private/React-Core"',
    '"${PODS_ROOT}/Headers/Public/RNReanimated"',
    '"$(PODS_CONFIGURATION_BUILD_DIR)/EXManifests/Swift Compatibility Header"',
    '"$(PODS_CONFIGURATION_BUILD_DIR)/EXUpdatesInterface/Swift Compatibility Header"',
  ]

  # If using frameworks (check your Podfile for use_frameworks!)
  if ENV['USE_FRAMEWORKS']
    header_search_paths.concat([
      '"${PODS_CONFIGURATION_BUILD_DIR}/React-Mapbuffer/React_Mapbuffer.framework/Headers"',
      '"${PODS_CONFIGURATION_BUILD_DIR}/React-RuntimeApple/React_RuntimeApple.framework/Headers"',
      '"${PODS_CONFIGURATION_BUILD_DIR}/React-RuntimeCore/React_RuntimeCore.framework/Headers"',
      '"${PODS_CONFIGURATION_BUILD_DIR}/React-jserrorhandler/React_jserrorhandler.framework/Headers"',
      '"${PODS_CONFIGURATION_BUILD_DIR}/React-jsinspectortracing/jsinspector_moderntracing.framework/Headers"',
      '"${PODS_CONFIGURATION_BUILD_DIR}/React-jsinspectorcdp/jsinspector_moderncdp.framework/Headers"',
      '"${PODS_CONFIGURATION_BUILD_DIR}/React-jsitooling/JSITooling.framework/Headers"',
      '"${PODS_CONFIGURATION_BUILD_DIR}/React-nativeconfig/React_nativeconfig.framework/Headers"',
      '"${PODS_CONFIGURATION_BUILD_DIR}/React-runtimescheduler/React_runtimescheduler.framework/Headers"',
      '"${PODS_CONFIGURATION_BUILD_DIR}/React-performancetimeline/React_performancetimeline.framework/Headers"',
    ])
  end

  # Swift/Objective-C compatibility
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'CLANG_CXX_LANGUAGE_STANDARD' => 'c++20',
    'HEADER_SEARCH_PATHS' => header_search_paths.join(' '),
    'FRAMEWORK_SEARCH_PATHS' => '"${PODS_CONFIGURATION_BUILD_DIR}/RNReanimated"',
  }

  # User target configuration for Swift compatibility
  s.user_target_xcconfig = {
    'HEADER_SEARCH_PATHS' => '"${PODS_CONFIGURATION_BUILD_DIR}/AdorableDevLauncher/Swift Compatibility Header"',
  }
end