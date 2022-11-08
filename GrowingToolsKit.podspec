#
# Be sure to run `pod lib lint GrowingToolsKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'GrowingToolsKit'
  s.version          = '1.0.8'
  s.summary          = 'GrowingToolsKit for iOS GrowingIO SDK'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://www.growingio.com/'
  s.license          = { :type => 'Apache2.0', :file => 'LICENSE' }
  s.author           = { 'GrowingIO' => 'support@growingio.com' }
  s.source           = { :git => 'https://github.com/growingio/growingio-sdk-ios-toolskit.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.ios.frameworks   = 'UIKit', 'WebKit'
  s.source_files     = 'GrowingToolsKit/GrowingToolsKit{.h,.m}'
  s.public_header_files = 'GrowingToolsKit/GrowingToolsKit.h'
  s.default_subspec  = 'Default'
  s.subspec 'Default' do |default|
    default.dependency 'GrowingToolsKit/Core'
    default.dependency 'GrowingToolsKit/SDKInfo'
    default.dependency 'GrowingToolsKit/EventsList'
    default.dependency 'GrowingToolsKit/XPathTrack'
    default.dependency 'GrowingToolsKit/NetFlow'
    default.dependency 'GrowingToolsKit/Realtime'
    default.dependency 'GrowingToolsKit/Settings'
    default.dependency 'GrowingToolsKit/CrashMonitor'
    default.dependency 'GrowingToolsKit/UIMonitor'
  end
  
  s.subspec 'SDK30202' do |sdk30202|
    sdk30202.source_files = 'GrowingToolsKit/GrowingToolsKit{.h,.m}'
    sdk30202.public_header_files = 'GrowingToolsKit/GrowingToolsKit.h'
    sdk30202.dependency 'GrowingToolsKit/Default'
    sdk30202.pod_target_xcconfig = {
      'GCC_PREPROCESSOR_DEFINITIONS' => 'GROWING_SDK30202=1',
      'OTHER_LDFLAGS' => '-Wl,-U,_GrowingTrackerVersionName -Wl,-U,_GrowingTrackerVersionCode'
    }
    sdk30202.xcconfig = { 'ENABLE_BITCODE' => 'NO'}
  end
  
  s.subspec 'SDK2nd' do |sdk2nd|
    sdk2nd.source_files = 'GrowingToolsKit/GrowingToolsKit{.h,.m}'
    sdk2nd.public_header_files = 'GrowingToolsKit/GrowingToolsKit.h'
    sdk2nd.dependency 'GrowingToolsKit/Default'
    sdk2nd.pod_target_xcconfig = {
      'GCC_PREPROCESSOR_DEFINITIONS' => 'GROWING_SDK2nd=1',
      'OTHER_LDFLAGS' => '-Wl,-U,_g_GDPRFlag -Wl,-U,_g_readClipBoardEnable -Wl,-U,_g_asaEnabled'
    }
    sdk2nd.xcconfig = { 'ENABLE_BITCODE' => 'NO'}
  end

  s.subspec 'Core' do |core|
    core.source_files = 'GrowingToolsKit/Core/**/*{.h,.m,.c,.cpp,.mm}'
    core.public_header_files = 'GrowingToolsKit/Core/Public/*.h'
    core.dependency 'GrowingToolsKit/Res'
  end
  
  s.subspec 'Res' do |res|
    res.resource_bundles = {'GrowingToolsKit' => ['GrowingToolsKit/Res/**/*']}
  end
  
  s.subspec 'SDKInfo' do |sdkInfo|
    sdkInfo.source_files = 'GrowingToolsKit/SDKInfo/**/*{.h,.m,.c,.cpp,.mm}'
    sdkInfo.public_header_files = 'GrowingToolsKit/SDKInfo/Public/*.h'
    sdkInfo.dependency 'GrowingToolsKit/Core'
  end
  
  s.subspec 'EventsList' do |eventsList|
    eventsList.source_files = 'GrowingToolsKit/EventsList/**/*{.h,.m,.c,.cpp,.mm}'
    eventsList.public_header_files = 'GrowingToolsKit/EventsList/Public/*.h'
    eventsList.dependency 'GrowingToolsKit/Core'
  end
  
  s.subspec 'XPathTrack' do |xpathTrack|
    xpathTrack.source_files = 'GrowingToolsKit/XPathTrack/**/*{.h,.m,.c,.cpp,.mm}'
    xpathTrack.public_header_files = 'GrowingToolsKit/XPathTrack/Public/*.h'
    xpathTrack.dependency 'GrowingToolsKit/Core'
  end
  
  s.subspec 'NetFlow' do |netflow|
    netflow.source_files = 'GrowingToolsKit/NetFlow/**/*{.h,.m,.c,.cpp,.mm}'
    netflow.public_header_files = 'GrowingToolsKit/NetFlow/Public/*.h'
    netflow.dependency 'GrowingToolsKit/Core'
  end

  s.subspec 'Realtime' do |realtime|
    realtime.source_files = 'GrowingToolsKit/Realtime/**/*{.h,.m,.c,.cpp,.mm}'
    realtime.public_header_files = 'GrowingToolsKit/Realtime/Public/*.h'
    realtime.dependency 'GrowingToolsKit/Core'
  end

  s.subspec 'APMCore' do |apm|
    apm.source_files = 'GrowingToolsKit/APMCore/**/*{.h,.m,.c,.cpp,.mm}'
    apm.dependency 'GrowingToolsKit/Core'
    apm.dependency 'GrowingAPM/Core'
  end

  s.subspec 'CrashMonitor' do |monitor|
    monitor.source_files = 'GrowingToolsKit/CrashMonitor/**/*{.h,.m,.c,.cpp,.mm}'
    monitor.public_header_files = 'GrowingToolsKit/CrashMonitor/Public/*.h'
    monitor.dependency 'GrowingToolsKit/APMCore'
    monitor.dependency 'GrowingAPM/CrashMonitor'
  end

  s.subspec 'UIMonitor' do |monitor|
    monitor.source_files = 'GrowingToolsKit/UIMonitor/**/*{.h,.m,.c,.cpp,.mm}'
    monitor.public_header_files = 'GrowingToolsKit/UIMonitor/Public/*.h'
    monitor.dependency 'GrowingToolsKit/APMCore'
    monitor.dependency 'GrowingAPM/UIMonitor'
  end

  s.subspec 'Settings' do |settings|
    settings.source_files = 'GrowingToolsKit/Settings/**/*{.h,.m,.c,.cpp,.mm}'
    settings.public_header_files = 'GrowingToolsKit/Settings/Public/*.h'
    settings.dependency 'GrowingToolsKit/Core'
  end
end
