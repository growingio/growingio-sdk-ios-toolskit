#
# Be sure to run `pod lib lint GrowingToolsKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'GrowingToolsKit'
  s.version          = '2.2.0'
  s.summary          = 'GrowingToolsKit for iOS GrowingIO SDK'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://www.growingio.com/'
  s.license          = { :type => 'Apache2.0', :file => 'LICENSE' }
  s.author           = { 'GrowingIO' => 'support@growingio.com' }
  s.source           = { :git => 'https://github.com/growingio/growingio-sdk-ios-toolskit.git', :tag => s.version.to_s }
  s.ios.deployment_target = '10.0'
  s.ios.frameworks   = 'UIKit', 'WebKit'
  s.source_files     = 'Sources/GrowingToolsKit/GrowingToolsKit{.h,.m}'
  s.public_header_files = 'Sources/GrowingToolsKit/GrowingToolsKit.h'
  s.default_subspec  = 'Default'

  s.subspec 'UseInRelease' do |subspec|
    subspec.source_files = 'Sources/GrowingToolsKit/GrowingToolsKit{.h,.m}', 'Sources/Core/UseInRelease/GrowingTKUseInRelease.m'
    subspec.public_header_files = 'Sources/GrowingToolsKit/GrowingToolsKit.h'
    subspec.dependency 'GrowingToolsKit/Default'
  end

  s.subspec 'Default' do |default|
    default.dependency 'GrowingToolsKit/Core'
    default.dependency 'GrowingToolsKit/SDKInfo'
    default.dependency 'GrowingToolsKit/EventsList'
    default.dependency 'GrowingToolsKit/XPathTrack'
    default.dependency 'GrowingToolsKit/NetFlow'
    default.dependency 'GrowingToolsKit/Realtime'
    default.dependency 'GrowingToolsKit/H5GioKit'
    default.dependency 'GrowingToolsKit/Settings'
  end

  s.subspec 'Core' do |core|
    core.source_files = 'Sources/Core/**/*{.h,.m,.c,.cpp,.mm}'
    core.public_header_files = 'Sources/Core/Public/*.h'
    core.exclude_files = 'Sources/Core/UseInRelease/GrowingTKUseInRelease.m'
    core.resource_bundles = {'GrowingToolsKitResource' => ['Sources/Core/Resources/**/*']}
  end
  
  s.subspec 'SDKInfo' do |sdkInfo|
    sdkInfo.source_files = 'Sources/SDKInfo/**/*{.h,.m,.c,.cpp,.mm}'
    sdkInfo.public_header_files = 'Sources/SDKInfo/Public/*.h'
    sdkInfo.dependency 'GrowingToolsKit/Core'
  end
  
  s.subspec 'EventsList' do |eventsList|
    eventsList.source_files = 'Sources/EventsList/**/*{.h,.m,.c,.cpp,.mm}'
    eventsList.public_header_files = 'Sources/EventsList/Public/*.h'
    eventsList.dependency 'GrowingToolsKit/Core'
  end
  
  s.subspec 'XPathTrack' do |xpathTrack|
    xpathTrack.source_files = 'Sources/XPathTrack/**/*{.h,.m,.c,.cpp,.mm}'
    xpathTrack.public_header_files = 'Sources/XPathTrack/Public/*.h'
    xpathTrack.dependency 'GrowingToolsKit/Core'
  end
  
  s.subspec 'NetFlow' do |netflow|
    netflow.source_files = 'Sources/NetFlow/**/*{.h,.m,.c,.cpp,.mm}'
    netflow.public_header_files = 'Sources/NetFlow/Public/*.h'
    netflow.dependency 'GrowingToolsKit/Core'
  end

  s.subspec 'Realtime' do |realtime|
    realtime.source_files = 'Sources/Realtime/**/*{.h,.m,.c,.cpp,.mm}'
    realtime.public_header_files = 'Sources/Realtime/Public/*.h'
    realtime.dependency 'GrowingToolsKit/Core'
  end

  s.subspec 'H5GioKit' do |h5GioKit|
    h5GioKit.source_files = 'Sources/H5GioKit/**/*{.h,.m,.c,.cpp,.mm}'
    h5GioKit.public_header_files = 'Sources/H5GioKit/Public/*.h'
    h5GioKit.dependency 'GrowingToolsKit/Core'
  end

  s.subspec 'Settings' do |settings|
    settings.source_files = 'Sources/Settings/**/*{.h,.m,.c,.cpp,.mm}'
    settings.public_header_files = 'Sources/Settings/Public/*.h'
    settings.dependency 'GrowingToolsKit/Core'
  end
end
