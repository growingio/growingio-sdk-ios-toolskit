#source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!

install!'cocoapods',:deterministic_uuids=>false
platform :ios, '9.0'

workspace 'GrowingToolsKit.xcworkspace'

target 'Example' do
  project 'Example/Example'
# SDK 3.0
  pod 'GrowingAnalytics/Autotracker'
#  pod 'GrowingAnalytics/Protobuf'
#  pod 'GrowingAnalytics/Tracker'
#  pod 'GrowingAnalytics/Hybrid'
#  pod 'GrowingAnalytics/Advertising'
#  pod 'GrowingAnalytics/DISABLE_IDFA' #禁用idfa

# SDK 2.0
#  pod 'GrowingAutoTrackKit'
#  pod 'GrowingCoreKit'

  pod 'SDCycleScrollView', '~> 1.75'
  pod 'MJRefresh'
  pod 'MBProgressHUD'
#  pod 'GrowingToolsKit/SDK30202', :path => './', :configurations => ['Debug']
#  pod 'GrowingToolsKit/SDK2nd', :path => './', :configurations => ['Debug']
  pod 'GrowingToolsKit', :path => './', :configurations => ['Debug']

end

target 'ExampleTests' do
   project 'Example/Example'
#   pod 'GrowingAnalytics/Autotracker'
#   pod 'GrowingAnalytics/Tracker'
   pod 'KIF', :configurations => ['Debug']
end


