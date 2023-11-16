source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!

install!'cocoapods',:deterministic_uuids=>false
platform :ios, '11.0'

workspace 'GrowingToolsKit.xcworkspace'

target 'Example' do
  project 'Example/Example'
# SDK 3.0
  pod 'GrowingAnalytics-cdp/Autotracker', '3.7.1'
  pod 'GrowingAnalytics/Advert'
  pod 'GrowingAnalytics/APM'
#  pod 'GrowingAPM'
#  pod 'GrowingAnalytics/Hybrid'
#  pod 'GrowingAnalytics/DISABLE_IDFA' #禁用idfa

# SDK 2.0
#  pod 'GrowingAutoTrackKit'
#  pod 'GrowingCoreKit'

  pod 'SDCycleScrollView', '~> 1.75'
  pod 'LBXScan/LBXNative', '2.3'
  pod 'LBXScan/UI', '2.3'
  pod 'Bugly'
  
#  pod 'GrowingToolsKit/SDK30202', :path => './', :configurations => ['Debug']
#  pod 'GrowingToolsKit/SDK2nd', :path => './', :configurations => ['Debug']
  pod 'GrowingToolsKit', :path => './', :configurations => ['Debug']

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
    end
    if target.respond_to?(:product_type) and target.product_type == "com.apple.product-type.bundle"
      target.build_configurations.each do |config|
          config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
      end
    end
  end
end
