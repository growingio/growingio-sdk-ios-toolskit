#source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!

install!'cocoapods',:deterministic_uuids=>false
platform :ios, '9.0'

workspace 'GrowingToolsKit.xcworkspace'

target 'Example' do
  project 'Example/Example'
  pod 'GrowingAnalytics/Autotracker'
#  pod 'GrowingAnalytics/Tracker'
#  pod 'GrowingAnalytics/Hybrid'
#  pod 'GrowingAnalytics/ENABLE_ENCRYPTION' #启用加密
#  pod 'GrowingAnalytics/Advertising'
#  pod 'GrowingAnalytics/DISABLE_IDFA' #禁用idfa
  pod 'SDCycleScrollView', '~> 1.75'
  pod 'MJRefresh'
  pod 'MBProgressHUD'
  pod 'GrowingToolsKit', :path => './GrowingToolsKit/'

end

target 'ExampleTests' do
   project 'Example/Example'
#   pod 'GrowingAnalytics/Autotracker'
#   pod 'GrowingAnalytics/Tracker'
   pod 'KIF', :configurations => ['Debug']
end


