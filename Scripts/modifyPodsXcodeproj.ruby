require 'xcodeproj'
project_path = ARGV[0]
project = Xcodeproj::Project.open(project_path)

project.targets.each do |target|
	puts target.name
	target.build_configurations.each do |config|
		if target.name == "GrowingToolsKit"
			config.build_settings['ENABLE_BITCODE'] = 'NO'
			config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
			config.build_settings['SKIP_INSTALL'] = 'NO'
		end
	end
end

project.save

