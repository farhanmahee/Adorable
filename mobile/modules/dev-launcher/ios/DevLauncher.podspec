Pod::Spec.new do |s|
  s.name           = 'DevLauncher'
  s.version        = '1.0.0'
  s.summary        = 'Dev Launcher for loading React Native apps from bundle URLs'
  s.description    = 'A module for loading React Native applications from dynamic bundle URLs in a modal'
  s.author         = '@theswerd'
  s.homepage       = 'https://docs.expo.dev/modules/'
  s.platforms      = {
    :ios => '16.0'
  }
  s.swift_version  = '5.2'
  s.source         = { git: 'https://github.com/freestyle-sh/adorable' }
  s.static_framework = true
  # Ensure SwiftUI framework is linked for the SwiftUI overlay
  s.frameworks = 'SwiftUI'

  s.source_files = "**/*.{h,m,mm,swift,hpp,cpp}"

  # Dependencies
  s.dependency 'ExpoModulesCore'
  s.dependency 'React-Core'
  s.dependency 'React-RCTAppDelegate'
  s.dependency 'ReactAppDependencyProvider'

  # Header search paths for Swift compatibility headers
  header_search_paths = [
    '"$(PODS_ROOT)/Headers/Private/React-Core"',
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
  }

  # User target configuration for Swift compatibility
  s.user_target_xcconfig = {
    'HEADER_SEARCH_PATHS' => '"${PODS_CONFIGURATION_BUILD_DIR}/DevLauncher/Swift Compatibility Header"',
  }
end
