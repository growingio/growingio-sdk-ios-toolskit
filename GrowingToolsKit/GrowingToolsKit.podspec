#
# Be sure to run `pod lib lint GrowingToolsKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'GrowingToolsKit'
  s.version          = '0.1.0'
  s.summary          = 'GrowingToolsKit for iOS GrowingIO SDK'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://www.growingio.com/'
  s.license          = { :type => 'Apache2.0', :file => 'LICENSE' }
  s.author           = { 'GrowingIO' => 'support@growingio.com' }
  s.source           = { :git => 'https://github.com/growingio/ios_growing_tools_kit.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.ios.frameworks   = 'UIKit', 'WebKit'
  s.source_files     = 'GrowingToolsKit/GrowingToolsKit{.h,.m}'
  s.default_subspec  = 'Default'
  s.xcconfig         = { 'OTHER_LDFLAGS' => '-Wl,-U,_GrowingTrackerVersionName -Wl,-U,_GrowingTrackerVersionCode', 'ENABLE_BITCODE' => 'NO'}
  
  s.subspec 'Default' do |ss|
    ss.dependency 'GrowingToolsKit/Core'
    ss.dependency 'GrowingToolsKit/SDKCheck'
    ss.dependency 'GrowingToolsKit/SDKInfo'
    ss.dependency 'GrowingToolsKit/TrackList'
    ss.dependency 'GrowingToolsKit/EventsList'
    ss.dependency 'GrowingToolsKit/EventTrack'
  end

  s.subspec 'Core' do |ss|
    ss.source_files = 'GrowingToolsKit/Core/**/*{.h,.m,.c,.cpp,.mm}'
    ss.dependency 'GrowingToolsKit/Resources'
  end
  
  s.subspec 'Resources' do |ss|
    ss.resource_bundles = {'GrowingToolsKit' => ['GrowingToolsKit/Resource/**/*']}
  end
  
  s.subspec 'SDKCheck' do |ss|
    ss.source_files = 'GrowingToolsKit/SDKCheck/**/*{.h,.m,.c,.cpp,.mm}'
    ss.dependency 'GrowingToolsKit/Core'
  end
  
  s.subspec 'SDKInfo' do |ss|
    ss.source_files = 'GrowingToolsKit/SDKInfo/**/*{.h,.m,.c,.cpp,.mm}'
    ss.dependency 'GrowingToolsKit/Core'
  end
  
  s.subspec 'TrackList' do |ss|
    ss.source_files = 'GrowingToolsKit/TrackList/**/*{.h,.m,.c,.cpp,.mm}'
    ss.dependency 'GrowingToolsKit/Core'
  end
  
  s.subspec 'EventsList' do |ss|
    ss.source_files = 'GrowingToolsKit/EventsList/**/*{.h,.m,.c,.cpp,.mm}'
    ss.dependency 'GrowingToolsKit/Core'
  end
  
  s.subspec 'EventTrack' do |ss|
    ss.source_files = 'GrowingToolsKit/EventTrack/**/*{.h,.m,.c,.cpp,.mm}'
    ss.dependency 'GrowingToolsKit/Core'
  end
end
