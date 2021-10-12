#
# Be sure to run `pod lib lint GrowingToolsKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'GrowingToolsKit'
  s.version          = '0.2.0'
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
  s.default_subspec  = 'Default'
  s.subspec 'Default' do |ss|
    ss.dependency 'GrowingToolsKit/Core'
    ss.dependency 'GrowingToolsKit/SDKInfo'
    ss.dependency 'GrowingToolsKit/EventsList'
    ss.dependency 'GrowingToolsKit/XPathTrack'
  end
  
  s.subspec 'SDK30202' do |ss|
    ss.source_files = 'GrowingToolsKit/GrowingToolsKit{.h,.m}'
    ss.dependency 'GrowingToolsKit/Default'
    ss.pod_target_xcconfig = {
      'GCC_PREPROCESSOR_DEFINITIONS' => 'GROWING_SDK30202=1',
      'OTHER_LDFLAGS' => '-Wl,-U,_GrowingTrackerVersionName -Wl,-U,_GrowingTrackerVersionCode'
    }
    ss.xcconfig = { 'ENABLE_BITCODE' => 'NO'}
  end
  
  s.subspec 'SDK2nd' do |ss|
    ss.source_files = 'GrowingToolsKit/GrowingToolsKit{.h,.m}'
    ss.dependency 'GrowingToolsKit/Default'
    ss.pod_target_xcconfig = {
      'GCC_PREPROCESSOR_DEFINITIONS' => 'GROWING_SDK2nd=1',
      'OTHER_LDFLAGS' => '-Wl,-U,_g_GDPRFlag'
    }
    ss.xcconfig = { 'ENABLE_BITCODE' => 'NO'}
  end

  s.subspec 'Core' do |ss|
    ss.source_files = 'GrowingToolsKit/Core/**/*{.h,.m,.c,.cpp,.mm}'
    ss.dependency 'GrowingToolsKit/Resources'
  end
  
  s.subspec 'Resources' do |ss|
    ss.resource_bundles = {'GrowingToolsKit' => ['GrowingToolsKit/Resource/**/*']}
  end
  
  s.subspec 'SDKInfo' do |ss|
    ss.source_files = 'GrowingToolsKit/SDKInfo/**/*{.h,.m,.c,.cpp,.mm}'
    ss.dependency 'GrowingToolsKit/Core'
  end
  
  s.subspec 'EventsList' do |ss|
    ss.source_files = 'GrowingToolsKit/EventsList/**/*{.h,.m,.c,.cpp,.mm}'
    ss.dependency 'GrowingToolsKit/Core'
  end
  
  s.subspec 'XPathTrack' do |ss|
    ss.source_files = 'GrowingToolsKit/XPathTrack/**/*{.h,.m,.c,.cpp,.mm}'
    ss.dependency 'GrowingToolsKit/Core'
  end
end
